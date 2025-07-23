/// Modèle pour l'entrée de la rotation
class RotationInput {
  final String cultureName;
  final String regionName;
  final String climateName;

  RotationInput({
    required this.cultureName,
    required this.regionName,
    required this.climateName,
  });

  Map<String, dynamic> toJson() => {
    'culture_name': cultureName,
    'region_name': regionName,
    'climate_name': climateName,
  };
}

/// Modèle pour une culture recommandée
class Culture {
  final String culture;
  final double totalScore;
  final double sensitivityToDiseaseCreatedPercentage;
  final double createdDiseaseCanBeCorrectedPercentage;
  final double nutrientAddsCanBeConsumedPercentage;
  final double nutrientConsumesCanBeAddedPercentage;

  Culture({
    required this.culture,
    required this.totalScore,
    required this.sensitivityToDiseaseCreatedPercentage,
    required this.createdDiseaseCanBeCorrectedPercentage,
    required this.nutrientAddsCanBeConsumedPercentage,
    required this.nutrientConsumesCanBeAddedPercentage,
  });

  factory Culture.fromJson(Map<String, dynamic> json) {
    return Culture(
      culture: json['culture'] ?? '',
      totalScore: (json['total_score'] ?? 0).toDouble(),
      sensitivityToDiseaseCreatedPercentage: 
          (json['sensitivity_to_disease_created_percentage'] ?? 0).toDouble(),
      createdDiseaseCanBeCorrectedPercentage: 
          (json['created_disease_can_be_corrected_percentage'] ?? 0).toDouble(),
      nutrientAddsCanBeConsumedPercentage: 
          (json['nutrient_adds_can_be_consumed_percentage'] ?? 0).toDouble(),
      nutrientConsumesCanBeAddedPercentage: 
          (json['nutrient_consumes_can_be_added_percentage'] ?? 0).toDouble(),
    );
  }
}

/// Modèle pour la réponse de rotation
class RotationResponse {
  final String status;
  final List<Culture> cultures;

  RotationResponse({
    required this.status,
    required this.cultures,
  });

  factory RotationResponse.fromJson(Map<String, dynamic> json) {
    return RotationResponse(
      status: json['status'] ?? '',
      cultures: (json['cultures'] as List<dynamic>?)
          ?.map((item) => Culture.fromJson(item))
          .toList() ?? [],
    );
  }
}
