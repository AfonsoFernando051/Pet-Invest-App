import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:petapp_mobile/core/constants/api_constants.dart';
import 'package:petapp_mobile/core/error/app_exceptions.dart';
import 'package:petapp_mobile/core/storage/secure_token_storage.dart';

class ApiClient {
  final http.Client _client = http.Client();

  static const _requestTimeout = Duration(seconds: 15);

  /// Invoked whenever a request comes back 401 — the token is stale/expired.
  /// Set once at app startup so the network layer can trigger a global
  /// logout + redirect-to-login without depending on any UI feature.
  static Future<void> Function()? onUnauthorized;

  Future<Map<String, String>> _getHeaders() async {
    final token = await SecureTokenStorage.readToken();

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> post(String endpoint, dynamic body) {
    return _send((headers, url) => _client.post(url, headers: headers, body: jsonEncode(body)), endpoint);
  }

  Future<http.Response> get(String endpoint) {
    return _send((headers, url) => _client.get(url, headers: headers), endpoint);
  }

  Future<http.Response> put(String endpoint, dynamic body) {
    return _send((headers, url) => _client.put(url, headers: headers, body: jsonEncode(body)), endpoint);
  }

  Future<http.Response> _send(
    Future<http.Response> Function(Map<String, String> headers, Uri url) request,
    String endpoint,
  ) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

    http.Response response;
    try {
      response = await request(headers, url).timeout(_requestTimeout);
    } on TimeoutException {
      throw const RequestTimeoutException();
    } on SocketException {
      throw const NetworkException();
    } on HttpException {
      throw const NetworkException();
    }

    if (response.statusCode == 401) {
      await onUnauthorized?.call();
    }

    return response;
  }
}
