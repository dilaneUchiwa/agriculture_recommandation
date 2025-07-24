import 'package:agriculture_recommandation/domain/models/user_recommendation.dart';
import 'package:get/get.dart';
import 'package:agriculture_recommandation/domain/models/rotation_models.dart';
import 'package:agriculture_recommandation/services/rotation_service.dart';
import 'package:agriculture_recommandation/services/recommendation_firebase_service.dart';
import 'package:agriculture_recommandation/controllers/toastController.dart';
import 'package:dio/dio.dart';

class RotationController extends GetxController {
  var isLoading = false.obs;
  var selectedCulture = ''.obs;
  var selectedRegion = ''.obs;
  var selectedClimate = ''.obs;
  var rotationResponse = Rxn<RotationResponse>();
  var isSaving = false.obs;
  var predictedPrice = Rxn<double>();

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

  final List<String> cultures2 = ['sorgho', 'tomate', 'mais', 'mangue', 'plantain', 'arachide',
       'patate', 'noixdecoco', 'onions', 'igname', 'okra', 'piment',
       'pommedeterre', 'ananas', 'manioc', 'mil', 'papaye', 'orange',
       'cafe', 'haricots', 'riz', 'banane', 'cacao'];
  
  final Map<String, Map<String, int>> cropDurations = {
      'sorgho': {'minDays': 90, 'maxDays': 120},
      'tomate': {'minDays': 60, 'maxDays': 90},
      'mais': {'minDays': 90, 'maxDays': 120},
      'mangue': {'minDays': 1095, 'maxDays': 1825},
      'plantain': {'minDays': 274, 'maxDays': 365},
      'arachide': {'minDays': 90, 'maxDays': 120},
      'patate': {'minDays': 90, 'maxDays': 120},
      'noixdecoco': {'minDays': 2190, 'maxDays': 3650},
      'onions': {'minDays': 90, 'maxDays': 120},
      'igname': {'minDays': 182, 'maxDays': 365},
      'okra': {'minDays': 50, 'maxDays': 60},
      'piment': {'minDays': 60, 'maxDays': 90},
      'pommedeterre': {'minDays': 90, 'maxDays': 120},
      'ananas': {'minDays': 365, 'maxDays': 548},
      'manioc': {'minDays': 274, 'maxDays': 365},
      'mil': {'minDays': 90, 'maxDays': 120},
      'papaye': {'minDays': 274, 'maxDays': 548},
      'orange': {'minDays': 243, 'maxDays': 365},
      'cafe': {'minDays': 1095, 'maxDays': 1460},
      'haricots': {'minDays': 60, 'maxDays': 90},
      'riz': {'minDays': 90, 'maxDays': 150},
      'banane': {'minDays': 274, 'maxDays': 548},
      'cacao': {'minDays': 1095, 'maxDays': 1825},
    };

  final List<String> regions = [
    'Nord (Adamaoua compris)', 'Sud', 'Centre', 'Ouest', 'Est',
    'NordOuest', 'SudOuest', 'ExtremeNord', 'Littoral', 'ZonesIrriguees'
  ];

  // Mapping entre les régions internes et la liste cible
  final Map<String, String> regionsMapping = {
    'Nord (Adamaoua compris)': 'Nord',
    'Sud': 'Sud',
    'Centre': 'Centre',
    'Ouest': 'Ouest',
    'Est': 'Est',
    'NordOuest': 'Nord-Ouest',
    'SudOuest': 'Sud-Ouest',
    'ExtremeNord': 'Extrême-Nord',
    'Littoral': 'Littoral',
    'ZonesIrriguees': 'Adamaoua',
  };

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
        // Pour chaque culture recommandée, calculer readyDate et prédire le prix
        final List<Culture> enrichedCultureObjects = [];
        final List<Map<String, dynamic>> enrichedCultures = [];
        for (final culture in response.cultures) {
          // Calculer la période (readyDate)
          DateTime? readyDate;
          final duration = cropDurations[culture.culture.toLowerCase()];
          if (duration != null) {
            final minDays = duration['minDays'] ?? 0;
            final maxDays = duration['maxDays'] ?? 0;
            final avgDays = ((minDays + maxDays) / 2).round();
            readyDate = DateTime.now().add(Duration(days: avgDays));
          }

          // Prédire le prix pour cette culture recommandée
          double? predictedPrice;
          if (duration != null) {
            final pricePayload = {
              'product': cultures2.contains(culture.culture.toLowerCase())
                  ? culture.culture.toLowerCase()
                  : null,
              'region': regionsMapping[selectedRegion.value] ?? selectedRegion.value,
              'zone': "",
              "month": readyDate?.month,
              "year": readyDate?.year,
            };
            predictedPrice = await RotationService.predictPriceFromPayload(pricePayload);
          }

          // Créer un nouvel objet Culture enrichi
          final enrichedCulture = Culture(
            culture: culture.culture,
            totalScore: culture.totalScore,
            sensitivityToDiseaseCreatedPercentage: culture.sensitivityToDiseaseCreatedPercentage,
            createdDiseaseCanBeCorrectedPercentage: culture.createdDiseaseCanBeCorrectedPercentage,
            nutrientAddsCanBeConsumedPercentage: culture.nutrientAddsCanBeConsumedPercentage,
            nutrientConsumesCanBeAddedPercentage: culture.nutrientConsumesCanBeAddedPercentage,
            predictedPrice: predictedPrice,
            readyDate: readyDate?.toIso8601String(),
          );
          enrichedCultureObjects.add(enrichedCulture);

          // Pour la sauvegarde Firestore
          enrichedCultures.add(enrichedCulture.toJson());
        }

        // Mettre à jour rotationResponse.value avec les cultures enrichies
        rotationResponse.value = RotationResponse(
          status: response.status,
          cultures: enrichedCultureObjects,
        );

        // Sauvegarder la recommandation enrichie dans Firestore
        if (enrichedCultures.isEmpty) {
          await _saveRecommendationEnriched(response.cultures.map((c) => c.toJson()).toList());
        } else {
          await _saveRecommendationEnriched(enrichedCultures);
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Sauvegarder la recommandation enrichie dans Firebase
  Future<void> _saveRecommendationEnriched(List<Map<String, dynamic>> enrichedCultures) async {
    if (enrichedCultures.isEmpty) return;

    isSaving.value = true;
    try {
      final recommendationId = await RecommendationFirebaseService.saveRecommendationEnriched(
        cultureName: selectedCulture.value,
        regionName: selectedRegion.value,
        climateName: selectedClimate.value,
        recommendedCultures: enrichedCultures,
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

  /// Sauvegarder la recommandation dans Firebase
  Future<void> _saveRecommendation(RotationResponse response, double? predictedPrice, DateTime? readyDate) async {
    if (response.cultures.isEmpty) return;

    isSaving.value = true;
    
    try {
      final recommendationId = await RecommendationFirebaseService.saveRecommendation(
        cultureName: selectedCulture.value,
        regionName: selectedRegion.value,
        climateName: selectedClimate.value,
        recommendedCultures: response.cultures,
        predictedPrice: predictedPrice,
        readyDate: readyDate,
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
