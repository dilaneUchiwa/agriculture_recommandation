import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agriculture_recommandation/controllers/rotation_controller.dart';
import 'package:agriculture_recommandation/themes/theme.dart';
import 'package:agriculture_recommandation/domain/models/rotation_models.dart';
import 'package:agriculture_recommandation/domain/models/user_recommendation.dart';
import 'package:intl/intl.dart';

class RotationDialog extends StatelessWidget {
  final UserRecommendation? existingRecommendation;
  
  const RotationDialog({Key? key, this.existingRecommendation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RotationController controller = Get.put(RotationController());
    
    // Si on affiche une recommandation existante, la charger
    if (existingRecommendation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadExistingRecommendation(existingRecommendation!);
      });
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: 600,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() => controller.rotationResponse.value == null
                  ? _buildForm(controller)
                  : _buildAllResults(controller)),
            ),
            _buildActions(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.agriculture, color: AppColors.primary, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            existingRecommendation != null 
                ? 'Analyse Complète de la Recommandation'
                : 'Recommandation de Rotation',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildForm(RotationController controller) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sélectionnez les informations de votre terrain :',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          
          // Culture actuelle
          _buildDropdown(
            label: 'Culture actuelle',
            value: controller.selectedCulture.value,
            items: controller.cultures,
            onChanged: (value) => controller.selectedCulture.value = value ?? '',
            icon: Icons.grass,
          ),
          
          const SizedBox(height: 16),
          
          // Région
          _buildDropdown(
            label: 'Région',
            value: controller.selectedRegion.value,
            items: controller.regions,
            onChanged: (value) => controller.selectedRegion.value = value ?? '',
            icon: Icons.location_on,
          ),
          
          const SizedBox(height: 16),
          
          // Climat
          _buildDropdown(
            label: 'Type de climat',
            value: controller.selectedClimate.value,
            items: controller.climates,
            onChanged: (value) => controller.selectedClimate.value = value ?? '',
            icon: Icons.wb_sunny,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: value.isEmpty ? null : value,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.primary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            hint: Text(
              'Sélectionner $label',
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
            isExpanded: true, // Ajout pour éviter l'overflow
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildAllResults(RotationController controller) {
    final response = controller.rotationResponse.value!;
    final sortedCultures = controller.getSortedCultures();
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informations sur la demande
          if (existingRecommendation != null || 
              (controller.selectedCulture.value.isNotEmpty))
            _buildRequestInfo(controller),
          
          const SizedBox(height: 20),
          
          // Résumé des recommandations
          _buildRecommendationSummary(sortedCultures),
          
          const SizedBox(height: 20),
          
          // Toutes les recommandations avec analyses détaillées
          Text(
            'Analyses détaillées de toutes les recommandations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          
          ...sortedCultures.map((culture) => _buildDetailedCultureCard(
            culture, 
            controller.getCultureRank(culture),
            sortedCultures.length,
          )),
        ],
      ),
    );
  }

  Widget _buildRecommendationSummary(List<Culture> cultures) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.summarize, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Résumé des recommandations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Text(
            '${cultures.length} cultures recommandées pour la rotation',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          // Top 3 avec badges
          Row(
            children: [
              Expanded(
                child: _buildRankingCard(cultures.isNotEmpty ? cultures[0] : null, 1, Colors.amber),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRankingCard(cultures.length > 1 ? cultures[1] : null, 2, Colors.grey),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRankingCard(cultures.length > 2 ? cultures[2] : null, 3, Colors.brown),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankingCard(Culture? culture, int rank, Color color) {
    if (culture == null) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'N/A',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            culture.culture,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${culture.totalScore.toStringAsFixed(1)}%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedCultureCard(Culture culture, int rank, int totalCount) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec rang, nom et score
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getRankColor(rank),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        culture.culture,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rang $rank sur $totalCount',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getScoreColor(culture.totalScore),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    '${culture.totalScore.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Badge de performance
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getPerformanceColor(culture.totalScore).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getPerformanceColor(culture.totalScore),
                  width: 1,
                ),
              ),
              child: Text(
                _getPerformanceLabel(culture.totalScore),
                style: TextStyle(
                  color: _getPerformanceColor(culture.totalScore),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Analyses détaillées
            Text(
              'Analyses détaillées',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildDetailedProgressIndicator(
              'Sensibilité aux maladies créées',
              'Risque que cette culture développe des maladies spécifiques',
              culture.sensitivityToDiseaseCreatedPercentage,
              Colors.red[400]!,
              Icons.warning,
              isNegative: true,
            ),
            
            _buildDetailedProgressIndicator(
              'Correction des maladies',
              'Capacité à corriger les maladies existantes du sol',
              culture.createdDiseaseCanBeCorrectedPercentage,
              Colors.green[400]!,
              Icons.healing,
            ),
            
            _buildDetailedProgressIndicator(
              'Absorption des nutriments',
              'Efficacité d\'utilisation des nutriments disponibles',
              culture.nutrientAddsCanBeConsumedPercentage,
              Colors.blue[400]!,
              Icons.water_drop,
            ),
            
            _buildDetailedProgressIndicator(
              'Apport en nutriments',
              'Contribution nutritive pour les cultures suivantes',
              culture.nutrientConsumesCanBeAddedPercentage,
              Colors.orange[400]!,
              Icons.eco,
            ),
            
            // Recommandation spécifique
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getRecommendationText(culture, rank),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedProgressIndicator(
    String title, 
    String description, 
    double value, 
    Color color,
    IconData icon, {
    bool isNegative = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${value.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            _getProgressLabel(value, isNegative),
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestInfo(RotationController controller) {
    String cultureName = existingRecommendation?.cultureName ?? controller.selectedCulture.value;
    String regionName = existingRecommendation?.regionName ?? controller.selectedRegion.value;
    String climateName = existingRecommendation?.climateName ?? controller.selectedClimate.value;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Informations de la demande',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Culture actuelle', cultureName, Icons.grass),
          _buildInfoRow('Région', regionName, Icons.location_on),
          _buildInfoRow('Climat', climateName, Icons.wb_sunny),
          if (existingRecommendation != null)
            _buildInfoRow(
              'Date',
              '${existingRecommendation!.createdAt.day}/${existingRecommendation!.createdAt.month}/${existingRecommendation!.createdAt.year}',
              Icons.calendar_today,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1: return Colors.amber;
      case 2: return Colors.grey[600]!;
      case 3: return Colors.brown;
      default: return AppColors.primary;
    }
  }

  Color _getPerformanceColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.red;
    return Colors.red[800]!;
  }

  String _getPerformanceLabel(double score) {
    if (score >= 80) return 'Excellente compatibilité';
    if (score >= 60) return 'Bonne compatibilité';
    if (score >= 40) return 'Compatibilité moyenne';
    return 'Faible compatibilité';
  }

  String _getProgressLabel(double value, bool isNegative) {
    if (isNegative) {
      if (value <= 20) return 'Très faible risque';
      if (value <= 40) return 'Faible risque';
      if (value <= 60) return 'Risque modéré';
      if (value <= 80) return 'Risque élevé';
      return 'Risque très élevé';
    } else {
      if (value <= 20) return 'Très faible';
      if (value <= 40) return 'Faible';
      if (value <= 60) return 'Modéré';
      if (value <= 80) return 'Élevé';
      return 'Très élevé';
    }
  }

  String _getRecommendationText(Culture culture, int rank) {
    if (rank == 1) {
      return 'Choix optimal pour votre rotation. Cette culture offre le meilleur équilibre entre tous les facteurs analysés.';
    } else if (rank <= 3) {
      return 'Excellent choix alternatif. Cette culture présente de bonnes caractéristiques pour votre rotation.';
    } else {
      return 'Option acceptable mais nécessite une attention particulière aux facteurs de risque identifiés.';
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildActions(RotationController controller) {
    return Obx(() => Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          if (controller.rotationResponse.value != null)
            Expanded(
              flex: 1,
              child: TextButton(
                onPressed: () {
                  controller.resetForm();
                },
                child: const Text('Nouvelle recherche'),
              ),
            ),
          if (controller.rotationResponse.value != null)
            const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextButton(
              onPressed: () => Get.back(),
              child: const Text('Fermer'),
            ),
          ),
          const SizedBox(width: 8),
          if (controller.rotationResponse.value == null)
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: controller.isFormValid()
                    ? () => controller.getRotationRecommendations()
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Obtenir recommandations',
                        style: TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            ),
        ],
      ),
    ));
  }
}
