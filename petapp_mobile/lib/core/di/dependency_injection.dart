import 'package:petapp_mobile/core/network/api_client.dart';
import 'package:petapp_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:petapp_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:petapp_mobile/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:petapp_mobile/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:petapp_mobile/features/pet/data/datasources/pet_remote_datasource.dart';
import 'package:petapp_mobile/features/pet/data/repositories/pet_repository.dart';
import 'package:petapp_mobile/features/investment/data/datasources/investment_remote_datasource.dart';
import 'package:petapp_mobile/features/investment/data/repositories/investment_repository.dart';

class DI {
  static final ApiClient _apiClient = ApiClient();

  static final AuthRemoteDataSource _authRemoteDataSource =
     
      AuthRemoteDataSource(apiClient: _apiClient);
  // Not `final` so tests can replace it with a mock repository.
  static AuthRepository authRepository =
      AuthRepository(remoteDataSource: _authRemoteDataSource);

  static final OnboardingRemoteDataSource _onboardingRemoteDataSource =
      OnboardingRemoteDataSource(apiClient: _apiClient);
  // Not `final` so tests can replace it with a mock repository.
  static OnboardingRepository onboardingRepository =
      OnboardingRepository(remoteDataSource: _onboardingRemoteDataSource);

  static final PetRemoteDataSource _petRemoteDataSource =
      PetRemoteDataSource(apiClient: _apiClient);
  // Not `final` so tests can replace it with a mock repository.
  static PetRepository petRepository =
      PetRepository(remoteDataSource: _petRemoteDataSource);

  static final InvestmentRemoteDataSource _investmentRemoteDataSource =
      InvestmentRemoteDataSource(apiClient: _apiClient);
  static InvestmentRepository investmentRepository =
      InvestmentRepository(remoteDataSource: _investmentRemoteDataSource);
}
