import 'package:agriculture_recommandation/domain/models/user_recommendation.dart';
import 'package:get/get.dart';
import 'package:agriculture_recommandation/domain/models/rotation_models.dart';
import 'package:agriculture_recommandation/services/rotation_service.dart';
import 'package:agriculture_recommandation/services/recommendation_firebase_service.dart';
import 'package:agriculture_recommandation/controllers/toastController.dart';

class RotationController extends GetxController {
  var isLoading = false.obs;
  var selectedCulture = ''.obs;
  var selectedRegion = ''.obs;
  var selectedClimate = ''.obs;
  var rotationResponse = Rxn<RotationResponse>();
  var isSaving = false.obs;

  // Listes des options disponibles basées sur l'API
  final List<String> cultures = [
    'Mais', 'Mil', 'Arachide', 'Haricots', 'Plantain', 'Banane', 'Manioc',
    'Igname', 'Tomate', 'Piment', 'Aubergine', 'Coton', 'Tabac', 'Sorgho',
    'Riz', 'Niebe', 'Voandzou', 'Sesame', 'Patate', 'Taro', 'Brachiaria',
    'Soja', 'Mucuna', 'Crotalaria', 'Dolichos', 'PalmierHuile', 'Caoutchouc',
    'PommeDeTerre', 'Poivre', 'Okra', 'Macabo', 'Cacao', 'Tournesol',
    'Ndole', 'Mangue', 'Papaye', 'Ananas', 'Avocat', 'Basilic', 'Gingembre',
    'Citronnelle', 'Goyave', 'Melon', 'Pastèque', 'Corossol', 'Rambutan',
    'Mangoustan'
  ];

  final List<String> regions = [
    'Nord (Adamaoua compris)', 'Sud', 'Centre', 'Ouest', 'Est',
    'NordOuest', 'SudOuest', 'ExtremeNord', 'Littoral', 'ZonesIrriguees'
  ];

  final List<String> climates = [
    'Tropical', 'TropicalHumide', 'TropicalSec', 'SemiAride',
    'Temperé', 'TemperéChaud', 'TropicalTemperé'
  ];

  void resetForm() {
    selectedCulture.value = '';
    selectedRegion.value = '';
    selectedClimate.value = '';
    rotationResponse.value = null;
  }

  bool isFormValid() {
    return selectedCulture.value.isNotEmpty &&
           selectedRegion.value.isNotEmpty &&
           selectedClimate.value.isNotEmpty;
  }

  Future<void> getRotationRecommendations() async {
    if (!isFormValid()) return;

    isLoading.value = true;
    
    try {
      final input = RotationInput(
        cultureName: selectedCulture.value,
        regionName: selectedRegion.value,
        climateName: selectedClimate.value,
      );

      final response = await RotationService.getRotationRecommendations(input);
      
      if (response != null) {
        rotationResponse.value = response;
        
        // Sauvegarder automatiquement la recommandation
        await _saveRecommendation(response);
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Sauvegarder la recommandation dans Firebase
  Future<void> _saveRecommendation(RotationResponse response) async {
    if (response.cultures.isEmpty) return;

    isSaving.value = true;
    
    try {
      final recommendationId = await RecommendationFirebaseService.saveRecommendation(
        cultureName: selectedCulture.value,
        regionName: selectedRegion.value,
        climateName: selectedClimate.value,
        recommendedCultures: response.cultures,
      );

      if (recommendationId != null) {
        ToastController(
          title: 'Succès',
          message: 'Recommandation sauvegardée avec succès',
          type: ToastType.success,
        ).showToast();
      }
    } catch (e) {
      print('Erreur lors de la sauvegarde: $e');
    } finally {
      isSaving.value = false;
    }
  }

  /// Charger une recommandation existante pour affichage
  void loadExistingRecommendation(UserRecommendation recommendation) {
    selectedCulture.value = recommendation.cultureName;
    selectedRegion.value = recommendation.regionName;
    selectedClimate.value = recommendation.climateName;
    
    // Trier les cultures par score décroissant pour avoir la meilleure en premier
    final sortedCultures = List<Culture>.from(recommendation.recommendedCultures);
    sortedCultures.sort((a, b) => b.totalScore.compareTo(a.totalScore));
    
    // Créer une RotationResponse à partir des données existantes
    rotationResponse.value = RotationResponse(
      status: 'success',
      cultures: sortedCultures,
    );
  }

  /// Obtenir les cultures triées par score
  List<Culture> getSortedCultures() {
    if (rotationResponse.value == null) return [];
    
    final cultures = List<Culture>.from(rotationResponse.value!.cultures);
    cultures.sort((a, b) => b.totalScore.compareTo(a.totalScore));
    return cultures;
  }

  /// Obtenir le rang d'une culture (1 = meilleure)
  int getCultureRank(Culture culture) {
    final sortedCultures = getSortedCultures();
    return sortedCultures.indexOf(culture) + 1;
  }
}
