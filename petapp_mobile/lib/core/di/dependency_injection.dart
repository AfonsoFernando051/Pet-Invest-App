import 'package:petapp_mobile/core/network/api_client.dart';
import 'package:petapp_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:petapp_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:petapp_mobile/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:petapp_mobile/features/onboarding/data/repositories/onboarding_repository.dart';

class DI {
  static final ApiClient _apiClient = ApiClient();

  static final AuthRemoteDataSource _authRemoteDataSource =
      AuthRemoteDataSource(apiClient: _apiClient);
  // Not `final` so tests can replace it with a mock repository.
  static AuthRepository authRepository =
      AuthRepository(remoteDataSource: _authRemoteDataSource);

  static final OnboardingRemoteDataSource _onboardingRemoteDataSource =
      OnboardingRemoteDataSource(apiClient: _apiClient);
  static final OnboardingRepository onboardingRepository =
      OnboardingRepository(remoteDataSource: _onboardingRemoteDataSource);
}
