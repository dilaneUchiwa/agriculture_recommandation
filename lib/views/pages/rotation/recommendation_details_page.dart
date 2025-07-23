import 'package:agriculture_recommandation/views/components/common/app_logo_fixed.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agriculture_recommandation/controllers/rotation_controller.dart';
import 'package:agriculture_recommandation/themes/theme.dart';
import 'package:agriculture_recommandation/domain/models/rotation_models.dart';
import 'package:agriculture_recommandation/domain/models/user_recommendation.dart';
import 'package:agriculture_recommandation/views/components/common/app_logo.dart';
import 'package:intl/intl.dart';

/// Page de détails des recommandations
class RecommendationDetailsPage extends StatelessWidget {
  const RecommendationDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>?;
    final RotationController controller = arguments?['controller'] ?? Get.put(RotationController());
    final UserRecommendation? existingRecommendation = arguments?['existingRecommendation'];
    final bool isNewRecommendation = arguments?['isNewRecommendation'] ?? false;
    
    // Charger la recommandation existante si fournie
    if (existingRecommendation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadExistingRecommendation(existingRecommendation);
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            const AppLogo(size: 32, showText: false),
            const SizedBox(width: 12),
            Text(
              existingRecommendation != null 
                  ? 'Détails de la Recommandation'
                  : 'Analyse Complète',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.rotationResponse.value == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        return _buildAllResults(controller, existingRecommendation);
      }),
    );
  }

  Widget _buildAllResults(RotationController controller, UserRecommendation? existingRecommendation) {
    final response = controller.rotationResponse.value!;
    final sortedCultures = controller.getSortedCultures();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informations sur la demande
          if (existingRecommendation != null || 
              (controller.selectedCulture.value.isNotEmpty))
            _buildRequestInfo(controller, existingRecommendation),
          
          const SizedBox(height: 24),
          
          // Résumé des recommandations
          _buildRecommendationSummary(sortedCultures),
          
          const SizedBox(height: 24),
          
          // Synthèse globale
          _buildGlobalSynthesis(sortedCultures),
          
          const SizedBox(height: 24),
          
          // Toutes les recommandations avec analyses détaillées
          Text(
            'Analyses détaillées de toutes les recommandations',
            style: TextStyle(
              fontSize: 20,
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

  Widget _buildRequestInfo(RotationController controller, UserRecommendation? existingRecommendation) {
    String cultureName = existingRecommendation?.cultureName ?? controller.selectedCulture.value;
    String regionName = existingRecommendation?.regionName ?? controller.selectedRegion.value;
    String climateName = existingRecommendation?.climateName ?? controller.selectedClimate.value;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Informations de la demande',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Culture actuelle', cultureName, Icons.grass),
          _buildInfoRow('Région', regionName, Icons.location_on),
          _buildInfoRow('Climat', climateName, Icons.wb_sunny),
          if (existingRecommendation != null)
            _buildInfoRow(
              'Date',
              _formatDate(existingRecommendation.createdAt),
              Icons.calendar_today,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationSummary(List<Culture> cultures) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(Icons.summarize, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              Text(
                'Résumé des recommandations',
                style: TextStyle(
                  fontSize: 20,
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
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Top 3 avec badges
          Row(
            children: [
              Expanded(
                child: _buildRankingCard(cultures.isNotEmpty ? cultures[0] : null, 1, Colors.amber),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRankingCard(cultures.length > 1 ? cultures[1] : null, 2, Colors.grey),
              ),
              const SizedBox(width: 12),
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
        height: 100,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
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
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            culture.culture,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            '${culture.totalScore.toStringAsFixed(1)}%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedCultureCard(Culture culture, int rank, int totalCount) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec rang, nom et score
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getRankColor(rank),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        culture.culture,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rang $rank sur $totalCount',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
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
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Badge de performance
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getPerformanceColor(culture.totalScore).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getPerformanceColor(culture.totalScore),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getPerformanceIcon(culture.totalScore),
                    color: _getPerformanceColor(culture.totalScore),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getPerformanceLabel(culture.totalScore),
                    style: TextStyle(
                      color: _getPerformanceColor(culture.totalScore),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Analyses détaillées avec graphiques
            Text(
              'Analyses détaillées',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Évaluation complète des facteurs de compatibilité',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            
            // Grille d'analyses
            _buildAnalysisGrid(culture),
            
            const SizedBox(height: 24),
            
            // Section d'interprétation
            _buildInterpretationSection(culture, rank),
            
            const SizedBox(height: 20),
            
            // Recommandations spécifiques
            _buildRecommendationsSection(culture, rank),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisGrid(Culture culture) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDetailedProgressIndicator(
                'Sensibilité aux maladies',
                'Risque de développement de maladies spécifiques',
                culture.sensitivityToDiseaseCreatedPercentage,
                Colors.red[400]!,
                Icons.warning_amber_rounded,
                isNegative: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDetailedProgressIndicator(
                'Correction des maladies',
                'Capacité à corriger les maladies du sol',
                culture.createdDiseaseCanBeCorrectedPercentage,
                Colors.green[400]!,
                Icons.healing_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDetailedProgressIndicator(
                'Absorption nutriments',
                'Efficacité d\'utilisation des nutriments',
                culture.nutrientAddsCanBeConsumedPercentage,
                Colors.blue[400]!,
                Icons.water_drop_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDetailedProgressIndicator(
                'Apport nutritif',
                'Enrichissement pour cultures suivantes',
                culture.nutrientConsumesCanBeAddedPercentage,
                Colors.orange[400]!,
                Icons.eco_rounded,
              ),
            ),
          ],
        ),
      ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
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
          const SizedBox(height: 16),
          
          // Barre de progression avec gradient
          Container(
            height: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.grey[200],
            ),
            child: Stack(
              children: [
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.grey[200],
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: value / 100,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.7),
                          color,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getProgressLabel(value, isNegative),
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${value.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInterpretationSection(Culture culture, int rank) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_rounded, color: Colors.blue[700], size: 24),
              const SizedBox(width: 12),
              Text(
                'Interprétation des résultats',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildInterpretationItem(
            'Score global',
            _getScoreInterpretation(culture.totalScore),
            _getScoreColor(culture.totalScore),
          ),
          
          _buildInterpretationItem(
            'Gestion des maladies',
            _getDiseaseManagementInterpretation(
              culture.sensitivityToDiseaseCreatedPercentage,
              culture.createdDiseaseCanBeCorrectedPercentage,
            ),
            _getDiseaseManagementColor(
              culture.sensitivityToDiseaseCreatedPercentage,
              culture.createdDiseaseCanBeCorrectedPercentage,
            ),
          ),
          
          _buildInterpretationItem(
            'Gestion nutritive',
            _getNutrientManagementInterpretation(
              culture.nutrientAddsCanBeConsumedPercentage,
              culture.nutrientConsumesCanBeAddedPercentage,
            ),
            _getNutrientManagementColor(
              culture.nutrientAddsCanBeConsumedPercentage,
              culture.nutrientConsumesCanBeAddedPercentage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterpretationItem(String title, String interpretation, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  interpretation,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(Culture culture, int rank) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Recommandations pratiques',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...(_getDetailedRecommendations(culture, rank).map((rec) => 
            _buildRecommendationItem(rec['icon'], rec['title'], rec['description'])
          )),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalSynthesis(List<Culture> sortedCultures) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.05),
          ],
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
              Icon(Icons.assessment_rounded, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              Text(
                'Synthèse globale de l\'analyse',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildSynthesisMetric(
            'Score moyen global',
            '${_calculateAverageScore(sortedCultures).toStringAsFixed(1)}%',
            _getScoreColor(_calculateAverageScore(sortedCultures)),
            Icons.trending_up_rounded,
          ),
          
          _buildSynthesisMetric(
            'Cultures à faible risque sanitaire',
            '${_countLowDiseaseRisk(sortedCultures)} sur ${sortedCultures.length}',
            _countLowDiseaseRisk(sortedCultures) > sortedCultures.length / 2 
                ? Colors.green : Colors.orange,
            Icons.health_and_safety_rounded,
          ),
          
          _buildSynthesisMetric(
            'Cultures enrichissantes',
            '${_countHighNutrientContribution(sortedCultures)} sur ${sortedCultures.length}',
            _countHighNutrientContribution(sortedCultures) > sortedCultures.length / 2 
                ? Colors.green : Colors.orange,
            Icons.eco_rounded,
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Text(
              _getGlobalRecommendation(sortedCultures),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSynthesisMetric(String label, String value, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateAverageScore(List<Culture> cultures) {
    if (cultures.isEmpty) return 0;
    return cultures.map((c) => c.totalScore).reduce((a, b) => a + b) / cultures.length;
  }

  int _countLowDiseaseRisk(List<Culture> cultures) {
    return cultures.where((c) => c.sensitivityToDiseaseCreatedPercentage <= 40).length;
  }

  int _countHighNutrientContribution(List<Culture> cultures) {
    return cultures.where((c) => c.nutrientConsumesCanBeAddedPercentage >= 60).length;
  }

  String _getGlobalRecommendation(List<Culture> cultures) {
    final averageScore = _calculateAverageScore(cultures);
    final lowRiskCount = _countLowDiseaseRisk(cultures);
    final highNutrientCount = _countHighNutrientContribution(cultures);
    
    if (averageScore >= 70 && lowRiskCount > cultures.length / 2) {
      return 'Excellentes perspectives pour votre rotation ! La majorité des cultures recommandées présentent des scores élevés avec des risques sanitaires maîtrisés. Vous pouvez procéder avec confiance en suivant les recommandations spécifiques de chaque culture.';
    } else if (averageScore >= 50) {
      return 'Bonnes perspectives avec quelques points d\'attention. Concentrez-vous sur les cultures les mieux classées et renforcez la surveillance pour celles à risques plus élevés. Une approche progressive est recommandée.';
    }
    return 'Rotation nécessitant une gestion technique renforcée. Les cultures recommandées présentent des défis importants. Nous recommandons fortement de consulter un agronome spécialisé pour optimiser votre plan de rotation.';
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1: return Colors.amber;
      case 2: return Colors.grey[600]!;
      case 3: return Colors.brown;
      default: return AppColors.primary;
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  // Méthodes d'aide pour les interprétations
  Color _getPerformanceColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.red;
    return Colors.red[800]!;
  }

  IconData _getPerformanceIcon(double score) {
    if (score >= 80) return Icons.stars_rounded;
    if (score >= 60) return Icons.star_half_rounded;
    return Icons.star_border_rounded;
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

  String _getScoreInterpretation(double score) {
    if (score >= 80) {
      return 'Cette culture présente une excellente compatibilité avec votre système de rotation. Tous les indicateurs sont favorables pour une intégration optimale.';
    } else if (score >= 60) {
      return 'Bonne option pour votre rotation avec des avantages significatifs. Quelques points d\'attention à considérer pour maximiser les bénéfices.';
    } else if (score >= 40) {
      return 'Compatibilité moyenne. Cette culture peut convenir mais nécessite une gestion particulière et des précautions spécifiques.';
    }
    return 'Faible compatibilité. Cette culture présente des défis importants et des risques élevés pour votre système de rotation actuel.';
  }

  String _getDiseaseManagementInterpretation(double sensitivity, double correction) {
    if (sensitivity <= 30 && correction >= 70) {
      return 'Excellent profil sanitaire : très faible risque de développer des maladies et excellente capacité de correction des problèmes existants.';
    } else if (sensitivity <= 50 && correction >= 50) {
      return 'Bon équilibre sanitaire avec une gestion des maladies acceptable. Surveillance régulière recommandée.';
    } else if (sensitivity > 70) {
      return 'Attention particulière requise : cette culture est très sensible aux maladies. Programme de prévention intensif nécessaire.';
    }
    return 'Gestion sanitaire complexe requise. Surveillance étroite et traitements préventifs indispensables pour éviter les complications.';
  }

  String _getNutrientManagementInterpretation(double absorption, double contribution) {
    if (absorption >= 70 && contribution >= 70) {
      return 'Profil nutritif exceptionnel : utilise très efficacement les nutriments disponibles et enrichit significativement le sol pour les cultures suivantes.';
    } else if (absorption >= 50 && contribution >= 50) {
      return 'Profil nutritif équilibré avec des bénéfices modérés pour le système de rotation et la fertilité du sol.';
    } else if (absorption < 40 && contribution < 40) {
      return 'Profil nutritif déficitaire. Cette culture nécessite des apports importants et contribue peu à l\'enrichissement du sol.';
    }
    return 'Profil nutritif moyen. Compléments nutritionnels et amendements organiques fortement recommandés pour optimiser les rendements.';
  }

  Color _getDiseaseManagementColor(double sensitivity, double correction) {
    if (sensitivity <= 30 && correction >= 70) return Colors.green;
    if (sensitivity <= 50 && correction >= 50) return Colors.orange;
    if (sensitivity > 70) return Colors.red[700]!;
    return Colors.red;
  }

  Color _getNutrientManagementColor(double absorption, double contribution) {
    if (absorption >= 70 && contribution >= 70) return Colors.green;
    if (absorption >= 50 && contribution >= 50) return Colors.orange;
    if (absorption < 40 && contribution < 40) return Colors.red[700]!;
    return Colors.orange[700]!;
  }

  List<Map<String, dynamic>> _getDetailedRecommendations(Culture culture, int rank) {
    List<Map<String, dynamic>> recommendations = [];

    // Recommandations basées sur le rang
    if (rank == 1) {
      recommendations.add({
        'icon': Icons.trending_up_rounded,
        'title': 'Choix prioritaire optimal',
        'description': 'Cette culture est votre meilleur choix. Priorisez sa mise en place pour maximiser les bénéfices de votre rotation.',
      });
    } else if (rank == 2) {
      recommendations.add({
        'icon': Icons.star_rounded,
        'title': 'Excellent choix alternatif',
        'description': 'Deuxième meilleur option. Considérez cette culture si la première n\'est pas réalisable immédiatement.',
      });
    } else if (rank == 3) {
      recommendations.add({
        'icon': Icons.thumb_up_rounded,
        'title': 'Bonne option de rotation',
        'description': 'Troisième choix viable avec des avantages intéressants pour diversifier votre rotation.',
      });
    } else {
      recommendations.add({
        'icon': Icons.info_rounded,
        'title': 'Option avec précautions',
        'description': 'Cette culture nécessite une attention particulière et une gestion spécialisée.',
      });
    }

    // Recommandations basées sur la sensibilité aux maladies
    if (culture.sensitivityToDiseaseCreatedPercentage > 70) {
      recommendations.add({
        'icon': Icons.medical_services_rounded,
        'title': 'Surveillance sanitaire intensive',
        'description': 'Risque élevé de maladies. Mettez en place un programme de surveillance hebdomadaire et préparez des traitements préventifs.',
      });
    } else if (culture.sensitivityToDiseaseCreatedPercentage > 40) {
      recommendations.add({
        'icon': Icons.health_and_safety_rounded,
        'title': 'Surveillance sanitaire modérée',
        'description': 'Contrôles sanitaires bi-mensuels recommandés avec traitements préventifs selon les conditions climatiques.',
      });
    }

    // Recommandations basées sur la contribution nutritive
    if (culture.nutrientConsumesCanBeAddedPercentage >= 70) {
      recommendations.add({
        'icon': Icons.eco_rounded,
        'title': 'Enrichissement optimal du sol',
        'description': 'Cette culture enrichira significativement votre sol. Idéale avant des cultures exigeantes en nutriments.',
      });
    } else if (culture.nutrientConsumesCanBeAddedPercentage >= 50) {
      recommendations.add({
        'icon': Icons.nature_rounded,
        'title': 'Contribution nutritive modérée',
        'description': 'Apport nutritif acceptable. Complétez avec des amendements organiques pour optimiser les bénéfices.',
      });
    }

    // Recommandations basées sur l'absorption nutritive
    if (culture.nutrientAddsCanBeConsumedPercentage < 40) {
      recommendations.add({
        'icon': Icons.agriculture_rounded,
        'title': 'Fertilisation intensive requise',
        'description': 'Cette culture a des besoins nutritifs élevés. Prévoyez un programme de fertilisation adapté et des analyses de sol régulières.',
      });
    } else if (culture.nutrientAddsCanBeConsumedPercentage < 60) {
      recommendations.add({
        'icon': Icons.grass_rounded,
        'title': 'Fertilisation modérée recommandée',
        'description': 'Apports nutritionnels moyens nécessaires. Adaptez la fertilisation selon les analyses de sol.',
      });
    }

    // Recommandations de timing
    recommendations.add({
      'icon': Icons.schedule_rounded,
      'title': 'Planification saisonnière',
      'description': 'Respectez les périodes optimales de plantation selon votre région climatique et les conditions météorologiques.',
    });

    // Recommandations de gestion
    if (culture.totalScore < 60) {
      recommendations.add({
        'icon': Icons.psychology_rounded,
        'title': 'Gestion technique renforcée',
        'description': 'Score modéré nécessitant une expertise technique. Consultez un agronome pour optimiser la conduite culturale.',
      });
    }

    // Recommandations économiques
    if (rank <= 3) {
      recommendations.add({
        'icon': Icons.monetization_on_rounded,
        'title': 'Opportunité économique',
        'description': 'Excellente perspective de rentabilité. Étudiez les marchés locaux pour optimiser la commercialisation.',
      });
    }

    return recommendations;
  }

  /// Formate la date sans dépendance de localisation
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    
    // Noms des mois en français
    const monthNames = [
      '', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    
    return '$day ${monthNames[date.month]} $year à $hour:$minute';
  }
}
