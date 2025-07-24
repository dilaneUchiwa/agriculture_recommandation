/// Modèle pour l'entrée de la rotation
class RotationInput {
  final String cultureName;
  final String regionName;
  final String climateName;
  final String? cultureForPrice;
  final String? regionForPrice;
  final Map<String, dynamic>? durationForPrice;


  RotationInput({
    required this.cultureName,
    required this.regionName,
    required this.climateName,
    this.cultureForPrice,
    this.regionForPrice,
    this.durationForPrice,
  });

  Map<String, dynamic> toJson() => {
    'culture_name': cultureName,
    'region_name': regionName,
    'climate_name': climateName,
  };

  Map<String, dynamic> toJsonWithPrice() {
    final minDays = (durationForPrice?['minDays'] ?? 0) as int;
    final maxDays = (durationForPrice?['maxDays'] ?? 0) as int;
    final averageDays = ((minDays + maxDays) / 2).round();
    final ready = DateTime.now().add(Duration(days: averageDays));

    return {
      'product': cultureForPrice,
      'region': regionForPrice,
      'zone': "",
      "month": ready.month.toInt(),
      "year": ready.year.toInt(),
    };
  }
}

/// Modèle pour une culture recommandée
class Culture {
  final String culture;
  final double totalScore;
  final double sensitivityToDiseaseCreatedPercentage;
  final double createdDiseaseCanBeCorrectedPercentage;
  final double nutrientAddsCanBeConsumedPercentage;
  final double nutrientConsumesCanBeAddedPercentage;
  final double? predictedPrice;
  final String? readyDate;

  Culture({
    required this.culture,
    required this.totalScore,
    required this.sensitivityToDiseaseCreatedPercentage,
    required this.createdDiseaseCanBeCorrectedPercentage,
    required this.nutrientAddsCanBeConsumedPercentage,
    required this.nutrientConsumesCanBeAddedPercentage,
    this.predictedPrice,
    this.readyDate,
  });

  factory Culture.fromJson(Map<String, dynamic> json) {
    double? price;
    if (json['predictedPrice'] != null) {
      if (json['predictedPrice'] is String) {
        price = double.tryParse(json['predictedPrice']);
      } else if (json['predictedPrice'] is num) {
        price = (json['predictedPrice'] as num).toDouble();
      }
    }
    String? ready;
    if (json['readyDate'] != null) {
      ready = json['readyDate'].toString();
    }
    return Culture(
      culture: json['culture'] ?? '',
      totalScore: double.parse(((json['total_score'] ?? json['totalScore'] ?? 0).toDouble()).toString()),
      sensitivityToDiseaseCreatedPercentage: 
          (json['sensitivity_to_disease_created_percentage'] ?? json['sensitivityToDiseaseCreatedPercentage'] ?? 0).toDouble(),
      createdDiseaseCanBeCorrectedPercentage: 
          (json['created_disease_can_be_corrected_percentage'] ?? json['createdDiseaseCanBeCorrectedPercentage'] ?? 0).toDouble(),
      nutrientAddsCanBeConsumedPercentage: 
          (json['nutrient_adds_can_be_consumed_percentage'] ?? json['nutrientAddsCanBeConsumedPercentage'] ?? 0).toDouble(),
      nutrientConsumesCanBeAddedPercentage: 
          (json['nutrient_consumes_can_be_added_percentage'] ?? json['nutrientConsumesCanBeAddedPercentage'] ?? 0).toDouble(),
      predictedPrice: price,
      readyDate: ready,
    );
  }

  Map<String, dynamic> toJson() => {
    'culture': culture,
    'totalScore': totalScore,
    'sensitivityToDiseaseCreatedPercentage': sensitivityToDiseaseCreatedPercentage,
    'createdDiseaseCanBeCorrectedPercentage': createdDiseaseCanBeCorrectedPercentage,
    'nutrientAddsCanBeConsumedPercentage': nutrientAddsCanBeConsumedPercentage,
    'nutrientConsumesCanBeAddedPercentage': nutrientConsumesCanBeAddedPercentage,
    if (predictedPrice != null) 'predictedPrice': predictedPrice,
    if (readyDate != null) 'readyDate': readyDate,
  };
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
