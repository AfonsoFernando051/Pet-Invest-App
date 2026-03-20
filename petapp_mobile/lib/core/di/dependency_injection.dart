import 'package:petapp_mobile/core/network/api_client.dart';
import 'package:petapp_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:petapp_mobile/features/auth/data/repositories/auth_repository.dart';

class DI {
  static ApiClient _apiClient = ApiClient();
  static AuthRemoteDataSource _authRemoteDataSource = AuthRemoteDataSource(apiClient: _apiClient);
  static AuthRepository authRepository = AuthRepository(remoteDataSource: _authRemoteDataSource);
}
