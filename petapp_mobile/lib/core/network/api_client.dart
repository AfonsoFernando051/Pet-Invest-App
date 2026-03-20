import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class ApiClient {
  final http.Client _client = http.Client();

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    
    return _client.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    
    return _client.get(
      url,
      headers: headers,
    );
  }
}
