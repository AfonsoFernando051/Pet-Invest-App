import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrimonium/features/auth/data/datasources/auth_remote_datasource.dart';

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepository({required this.remoteDataSource});

  Future<void> login(String email, String password) async {
    final user = await remoteDataSource.login(email, password);
    await _saveToken(user.token);
    await _saveEmail(email);
  }

  Future<void> register(String name, String email, String password) async {
    final user = await remoteDataSource.register(name, email, password);
    await _saveToken(user.token);
    await _saveEmail(email);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_email');
  }

  Future<void> _saveToken(String? token) async {
    if (token != null && token.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    }
  }

  Future<void> _saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_email', email);
  }

  Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_email');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }
}
