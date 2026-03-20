import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petapp_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:petapp_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:petapp_mobile/features/auth/data/models/user_model.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late AuthRepository repository;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    repository = AuthRepository(remoteDataSource: mockRemoteDataSource);
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthRepository', () {
    const tEmail = 'test@test.com';
    const tPassword = 'password';
    final tUserModel = UserModel(email: tEmail, token: 'mock_token');

    test('should call login on remote data source and save token in SharedPreferences', () async {
      // arrange
      when(() => mockRemoteDataSource.login(any(), any()))
          .thenAnswer((_) async => tUserModel);

      // act
      await repository.login(tEmail, tPassword);

      // assert
      verify(() => mockRemoteDataSource.login(tEmail, tPassword)).called(1);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_token'), 'mock_token');
    });

    test('should return true if isLoggedIn when token exists', () async {
      // arrange
      SharedPreferences.setMockInitialValues({'auth_token': 'mock_token'});

      // act
      final result = await repository.isLoggedIn();

      // assert
      expect(result, isTrue);
    });

    test('should return false if isLoggedIn when token is null', () async {
      // act
      final result = await repository.isLoggedIn();

      // assert
      expect(result, isFalse);
    });

    test('should clear token on logout', () async {
      // arrange
      SharedPreferences.setMockInitialValues({'auth_token': 'mock_token'});

      // act
      await repository.logout();

      // assert
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_token'), isNull);
    });
  });
}
