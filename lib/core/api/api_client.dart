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

  /// 共通ヘッダー
  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Uri _buildUri(String path) {
    return Uri.parse('$baseUrl$path');
  }

  Map<String, String> _mergeHeaders(Map<String, String>? headers) {
    return {
      ..._defaultHeaders,
      ...?headers,
    };
  }

  /// HTTP Methods GET
  Future<Map<String, dynamic>> get(
      String path, {
        Map<String, String>? headers,
      }) async {
    final response = await _client.get(
      _buildUri(path),
      headers: _mergeHeaders(headers),
    );
    return _handleResponse(response);
  }

  /// HTTP Methods POST
  Future<Map<String, dynamic>> post(
      String path, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
      }) async {
    final response = await _client.post(
      _buildUri(path),
      headers: _mergeHeaders(headers),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// HTTP Methods PUT
  Future<Map<String, dynamic>> put(
      String path, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
      }) async {
    final response = await _client.put(
      _buildUri(path),
      headers: _mergeHeaders(headers),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// HTTP Methods PATCH
  Future<Map<String, dynamic>> patch(
      String path, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
      }) async {
    final response = await _client.patch(
      _buildUri(path),
      headers: _mergeHeaders(headers),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// HTTP Methods DELETE
  Future<Map<String, dynamic>> delete(
      String path, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
      }) async {
    final response = await _client.delete(
      _buildUri(path),
      headers: _mergeHeaders(headers),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  /// Response Handling
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw ApiException(
      statusCode: statusCode,
      message: response.body,
    );
  }

  void dispose() {
    _client.close();
  }
}

