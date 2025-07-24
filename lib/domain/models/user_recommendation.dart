import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agriculture_recommandation/domain/models/rotation_models.dart';

class UserRecommendation {
  final String id;
  final String userId;
  final String cultureName;
  final String regionName;
  final String climateName;
  final List<Culture> recommendedCultures;
  final DateTime createdAt;
  final String status;

  UserRecommendation({
    required this.id,
    required this.userId,
    required this.cultureName,
    required this.regionName,
    required this.climateName,
    required this.recommendedCultures,
    required this.createdAt,
    this.status = 'active',
  });

  factory UserRecommendation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime createdAt;
    final rawCreatedAt = data['createdAt'];
    if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      createdAt = DateTime.parse(rawCreatedAt);
    } else {
      createdAt = DateTime.now();
    }
    return UserRecommendation(
      id: doc.id,
      userId: data['userId'] ?? '',
      cultureName: data['cultureName'] ?? '',
      regionName: data['regionName'] ?? '',
      climateName: data['climateName'] ?? '',
      recommendedCultures: (data['recommendedCultures'] as List<dynamic>?)
          ?.map((item) => Culture.fromJson(item))
          .toList() ?? [],
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'cultureName': cultureName,
      'regionName': regionName,
      'climateName': climateName,
      'recommendedCultures': recommendedCultures.map((culture) => {
        'culture': culture.culture,
        'total_score': culture.totalScore,
        'sensitivity_to_disease_created_percentage': culture.sensitivityToDiseaseCreatedPercentage,
        'created_disease_can_be_corrected_percentage': culture.createdDiseaseCanBeCorrectedPercentage,
        'nutrient_adds_can_be_consumed_percentage': culture.nutrientAddsCanBeConsumedPercentage,
        'nutrient_consumes_can_be_added_percentage': culture.nutrientConsumesCanBeAddedPercentage,
      }).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }

  // Obtenir la meilleure culture recommandée
  Culture? get bestRecommendation {
    if (recommendedCultures.isEmpty) return null;
    return recommendedCultures.reduce(
      (a, b) => a.totalScore > b.totalScore ? a : b,
    );
  }

  // Obtenir le nombre de cultures recommandées
  int get recommendationCount => recommendedCultures.length;
}
