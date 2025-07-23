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
}
