import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:salary/core/api/api_exception.dart';

class ApiClient {
  ApiClient({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
  };

  Future<Map<String, dynamic>> get(
      String path, {
        Map<String, String>? headers,
      }) async {
    final response = await _client.get(
      Uri.parse('$baseUrl$path'),
      headers: {..._defaultHeaders, ...?headers},
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
      String path, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
      }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: {..._defaultHeaders, ...?headers},
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
  }
}
