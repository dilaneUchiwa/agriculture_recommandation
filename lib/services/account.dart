import 'package:dio/dio.dart';
import 'package:agriculture_recommandation/domain/models/account.dart';
import 'package:agriculture_recommandation/helpers/urls.dart';
import 'package:agriculture_recommandation/services/utils/dioPrivate.dart';

Future<Account?> getMe() async {
  try {
    final Dio dio = await getDioPrivate();
    final response = await dio.get(
      '${URL.nodeBaseUrl}/me/authenticated',
    );

    if (response.statusCode == 200) {
      return Account.fromJson(response.data);
    } else {
      print('Failed to load data: ${response.statusCode}');
      return null;
    }
  } catch (error) {
    print('Error: $error');
    return null;
  }
}

Future<bool> updateMe(Account account) async {
  try {
    final Dio dio = await getDioPrivate();
    final response = await dio.patch(
      '${URL.updateNodeUrl}${account.baseNode.id}',
      data: account.baseNode.toJson(), // Envoi des données du baseNode
    );

    return response.statusCode == 200;
  } catch (e) {
    print('Error: $e');
    return false;
  }
}
