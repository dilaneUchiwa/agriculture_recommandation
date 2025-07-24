import 'package:dio/dio.dart';
import 'package:agriculture_recommandation/domain/models/rotation_models.dart';
import 'package:agriculture_recommandation/controllers/errorController.dart';

class RotationService {
  static const String baseUrl = 'http://10.0.2.2'; // Remplacer par l'URL réelle
  static const String rotationEndpoint = '/api/v1/rotation';

  static Future<RotationResponse?> getRotationRecommendations(
      RotationInput input) async {
    try {
      final Dio dio = Dio();
      
      final response = await dio.post(
        '$baseUrl$rotationEndpoint',
        data: input.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return RotationResponse.fromJson(response.data);
      } else {
        ErrorController.handleError(response);
        return null;
      }
    } catch (error) {
      ErrorController.handleError(error);
      return null;
    }
  }

  /// Appeler l'API de prédiction de prix pour le produit sélectionné
  static Future<double?> predictPrice(RotationInput input) async {

    if (input.cultureForPrice == null || input.regionForPrice == null || input.durationForPrice == null) {
      print('Données insuffisantes pour la prédiction de prix');
      return null;
    }
    
    try {
      final pricePayload = input.toJsonWithPrice();
      final Dio dio = Dio();
      final response = await dio.post(
        '$baseUrl/predict',
        data: pricePayload,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      if (response.statusCode == 200 && response.data != null && response.data['prediction'] != null) {
        final predictionList = response.data['prediction'];
        if (predictionList is List && predictionList.isNotEmpty) {
          return (predictionList.first as num).toDouble();
        }
      }
      return null;
    } catch (e) {
      print('Erreur lors de la prédiction du prix: $e');
      return null;
    }
  }

  /// Prédire le prix à partir d'un payload générique (pour chaque culture recommandée)
  static Future<double?> predictPriceFromPayload(Map<String, dynamic> pricePayload) async {

    if (pricePayload.isEmpty || 
        pricePayload['product'] == null || 
        pricePayload['region'] == null || 
        pricePayload['month'] == null || 
        pricePayload['year'] == null) {
      print('Données insuffisantes pour la prédiction de prix');
      return null;
    }


    try {
      final Dio dio = Dio();
      final response = await dio.post(
        '$baseUrl/predict',
        data: pricePayload,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      if (response.statusCode == 200 && response.data != null && response.data['prediction'] != null) {
        final predictionList = response.data['prediction'];
        if (predictionList is List && predictionList.isNotEmpty) {
          return (predictionList.first as num).toDouble();
        }
      }
      return null;
    } catch (e) {
      print('Erreur lors de la prédiction du prix: $e');
      return null;
    }
  }
}
