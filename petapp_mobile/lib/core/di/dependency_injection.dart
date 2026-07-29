import 'package:petapp_mobile/core/network/api_client.dart';
import 'package:petapp_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:petapp_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:petapp_mobile/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:petapp_mobile/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:petapp_mobile/features/pet/data/datasources/pet_remote_datasource.dart';
import 'package:petapp_mobile/features/pet/data/repositories/pet_repository_impl.dart';
import 'package:petapp_mobile/features/pet/domain/repositories/pet_repository.dart';
import 'package:petapp_mobile/features/pet/data/repositories/mascot_repository_impl.dart';
import 'package:petapp_mobile/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petapp_mobile/features/investment/data/datasources/investment_remote_datasource.dart';
import 'package:petapp_mobile/features/investment/data/repositories/investment_repository.dart';
import 'package:petapp_mobile/features/portfolio/data/datasources/portfolio_remote_datasource.dart';
import 'package:petapp_mobile/features/portfolio/data/repositories/achievements_local_repository.dart';
import 'package:petapp_mobile/features/portfolio/data/repositories/portfolio_repository.dart';
import 'package:petapp_mobile/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:petapp_mobile/features/settings/data/repositories/settings_repository.dart';

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
      PetRepositoryImpl(remoteDataSource: _petRemoteDataSource);

  // Not `final` so tests can replace it with a mock repository.
  static MascotRepository mascotRepository = MascotRepositoryImpl();

  static final InvestmentRemoteDataSource _investmentRemoteDataSource =
      InvestmentRemoteDataSource(apiClient: _apiClient);
  static InvestmentRepository investmentRepository =
      InvestmentRepository(remoteDataSource: _investmentRemoteDataSource);

  static final SettingsRemoteDataSource _settingsRemoteDataSource =
      SettingsRemoteDataSource(apiClient: _apiClient);
  static SettingsRepository settingsRepository =
      SettingsRepository(remoteDataSource: _settingsRemoteDataSource);

  static final PortfolioRemoteDataSource _portfolioRemoteDataSource =
      PortfolioRemoteDataSource(apiClient: _apiClient);
  // Not `final` so tests can replace it with a mock repository.
  static PortfolioRepository portfolioRepository =
      PortfolioRepository(remoteDataSource: _portfolioRemoteDataSource);

  // Not `final` so tests can replace it with a mock repository.
  static AchievementsLocalRepository achievementsRepository = AchievementsLocalRepository();
}
