import 'package:shared_preferences/shared_preferences.dart';
import 'package:petapp_mobile/features/auth/data/datasources/auth_remote_datasource.dart';

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepository({required this.remoteDataSource});

  Future<void> login(String email, String password) async {
    final user = await remoteDataSource.login(email, password);
    await _saveToken(user.token);
  }

  Future<void> register(String name, String email, String password) async {
    final user = await remoteDataSource.register(name, email, password);
    await _saveToken(user.token);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<void> _saveToken(String? token) async {
    if (token != null && token.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }
}
