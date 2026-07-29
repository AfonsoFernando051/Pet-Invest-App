import 'dart:convert';
import 'package:petapp_mobile/core/error/app_exceptions.dart';
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
    }

    throw _mapLoginError(response.statusCode);
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
    }

    throw _mapRegisterError(response.statusCode);
  }

  ApiException _mapLoginError(int statusCode) {
    switch (statusCode) {
      case 401:
        return const ApiException(401, 'E-mail ou senha incorretos.');
      default:
        return ApiException(statusCode, 'Não foi possível entrar. Tente novamente.');
    }
  }

  ApiException _mapRegisterError(int statusCode) {
    switch (statusCode) {
      case 409:
        return const ApiException(409, 'Este e-mail já está cadastrado.');
      default:
        return ApiException(statusCode, 'Não foi possível criar a conta. Tente novamente.');
    }
  }
}
