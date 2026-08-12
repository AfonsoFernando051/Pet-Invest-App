import 'dart:convert';
import 'package:petrimonium/core/network/api_client.dart';
import 'package:petrimonium/core/network/api_error_parser.dart';
import 'package:petrimonium/core/constants/api_constants.dart';
import 'package:petrimonium/features/auth/data/models/user_model.dart';

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
      throw Exception(extractErrorDetail(response, fallback: 'Failed to login. Status Code: ${response.statusCode}'));
    }
  }

  Future<UserModel> register(String name, String email, String password) async {
    final response = await apiClient.post(
      ApiConstants.registerEndpoint,
      {
        'username': name,
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception(extractErrorDetail(response, fallback: 'Failed to register. Status Code: ${response.statusCode}'));
    }
  }
}
