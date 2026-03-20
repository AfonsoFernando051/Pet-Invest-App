import 'package:petapp_mobile/core/network/api_client.dart';
import 'package:petapp_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:petapp_mobile/features/auth/data/repositories/auth_repository.dart';

class DI {
  static final ApiClient _apiClient = ApiClient();
  static final AuthRemoteDataSource _authRemoteDataSource = AuthRemoteDataSource(apiClient: _apiClient);
  static final AuthRepository authRepository = AuthRepository(remoteDataSource: _authRemoteDataSource);
}
