import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:petapp_mobile/core/network/api_client.dart';
import 'package:petapp_mobile/core/constants/api_constants.dart';
import 'package:petapp_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:petapp_mobile/features/auth/data/models/user_model.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late AuthRemoteDataSource dataSource;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = AuthRemoteDataSource(apiClient: mockApiClient);
  });

  group('AuthRemoteDataSource - login', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    
    test('should return UserModel when the response code is 200/201 (success)', () async {
      // arrange
      when(() => mockApiClient.post(any(), any())).thenAnswer(
        (_) async => http.Response(jsonEncode({'email': tEmail, 'token': 'mock_token'}), 200),
      );

      // act
      final result = await dataSource.login(tEmail, tPassword);

      // assert
      expect(result.email, equals(tEmail));
      expect(result.token, equals('mock_token'));
      verify(() => mockApiClient.post(
            ApiConstants.loginEndpoint,
            {'email': tEmail, 'password': tPassword},
          )).called(1);
    });

    test('should throw an Exception when the response code is not successful', () async {
      // arrange
      when(() => mockApiClient.post(any(), any())).thenAnswer(
        (_) async => http.Response('Bad Request', 400),
      );

      // act
      final call = dataSource.login;

      // assert
      expect(() => call(tEmail, tPassword), throwsA(isA<Exception>()));
    });
  });

  group('AuthRemoteDataSource - register', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    
    test('should return UserModel when the response code is 200/201 (success)', () async {
      // arrange
      when(() => mockApiClient.post(any(), any())).thenAnswer(
        (_) async => http.Response(jsonEncode({'email': tEmail, 'token': 'mock_token'}), 201),
      );

      // act
      final result = await dataSource.register(tEmail, tPassword);

      // assert
      expect(result.email, equals(tEmail));
      expect(result.token, equals('mock_token'));
      verify(() => mockApiClient.post(
            ApiConstants.registerEndpoint,
            {'email': tEmail, 'password': tPassword},
          )).called(1);
    });

    test('should throw an Exception when the response code is not successful', () async {
      // arrange
      when(() => mockApiClient.post(any(), any())).thenAnswer(
        (_) async => http.Response('Bad Request', 400),
      );

      // act
      final call = dataSource.register;

      // assert
      expect(() => call(tEmail, tPassword), throwsA(isA<Exception>()));
    });
  });
}
