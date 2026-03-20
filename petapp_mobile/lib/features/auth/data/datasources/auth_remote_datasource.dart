import 'dart:convert';
import 'package:petapp_mobile/core/network/api_client.dart';
import 'package:petapp_mobile/core/constants/api_constants.dart';
import 'package:petapp_mobile/features/auth/data/models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource({required this.apiClient});

  Future<UserModel> login(String email, String password) async {
    final response = await apiClient.post(
      ApiConstants.loginEndpoint,
      {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception('Failed to login. Status Code: ${response.statusCode}');
    }
  }

  Future<UserModel> register(String email, String password) async {
    final response = await apiClient.post(
      ApiConstants.registerEndpoint,
      {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception('Failed to register. Status Code: ${response.statusCode}');
    }
  }
}
