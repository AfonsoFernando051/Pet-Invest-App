import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/network/api_client.dart';
import 'package:petrimonium/core/constants/api_constants.dart';
import 'package:petrimonium/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:petrimonium/features/auth/data/models/user_model.dart';

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
        (_) async => http.Response(jsonEncode({'email': tEmail, 'accessToken': 'mock_token'}), 200),
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

    test('should surface the backend\'s specific reason instead of just the status code', () async {
      // Mirrors the real shape GlobalExceptionHandler returns for a 401 on
      // bad credentials — previously this detail was discarded entirely and
      // the user only ever saw "Failed to login. Status Code: 401".
      when(() => mockApiClient.post(any(), any())).thenAnswer(
        (_) async => http.Response(jsonEncode({'detail': 'Invalid email or password'}), 401),
      );

      await expectLater(
        () => dataSource.login(tEmail, tPassword),
        throwsA(predicate((e) => e is Exception && e.toString().contains('Invalid email or password'))),
      );
    });

    test('falls back to a generic message when the error body has no detail', () async {
      when(() => mockApiClient.post(any(), any())).thenAnswer(
        (_) async => http.Response('Bad Request', 400),
      );

      await expectLater(
        () => dataSource.login(tEmail, tPassword),
        throwsA(predicate((e) => e is Exception && e.toString().contains('Status Code: 400'))),
      );
    });
  });

  group('AuthRemoteDataSource - register', () {
    final tName = 'Test User';
    final tEmail = 'test@example.com';
    final tPassword = 'password123';
    
    test('should return UserModel when the response code is 200/201 (success)', () async {
      // arrange
      when(() => mockApiClient.post(any(), any())).thenAnswer(
        (_) async => http.Response(jsonEncode({'email': tEmail, 'accessToken': 'mock_token'}), 201),
      );

      // act
      final result = await dataSource.register(tName, tEmail, tPassword);

      // assert
      expect(result, isA<UserModel>());
      expect(result.email, tEmail);
      verify(() => mockApiClient.post(
            ApiConstants.registerEndpoint,
            {
              'username': tName,
              'email': tEmail,
              'password': tPassword,
            },
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
      expect(() => call(tName, tEmail, tPassword), throwsA(isA<Exception>()));
    });

    test('should surface the backend\'s validation reason instead of just the status code', () async {
      // Reproduces the reported bug: registering with a name shorter than
      // the backend's minimum used to show only "Failed to register. Status
      // Code: 400", with no indication of what was actually wrong.
      when(() => mockApiClient.post(any(), any())).thenAnswer(
        (_) async => http.Response(
          jsonEncode({'detail': 'username: Username must be between 3 and 50 characters'}),
          400,
        ),
      );

      await expectLater(
        () => dataSource.register(tName, tEmail, tPassword),
        throwsA(predicate((e) =>
            e is Exception && e.toString().contains('Username must be between 3 and 50 characters'))),
      );
    });

    test('should surface a duplicate-email conflict reason', () async {
      when(() => mockApiClient.post(any(), any())).thenAnswer(
        (_) async => http.Response(jsonEncode({'detail': 'User already exists'}), 409),
      );

      await expectLater(
        () => dataSource.register(tName, tEmail, tPassword),
        throwsA(predicate((e) => e is Exception && e.toString().contains('User already exists'))),
      );
    });
  });
}
