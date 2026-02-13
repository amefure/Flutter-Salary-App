import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:salary/core/api/api_error_mapper.dart';
import 'package:salary/core/api/token_storage.dart';
import 'package:salary/core/models/secrets.dart';
import 'package:salary/core/utils/logger.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
      baseUrl: StaticKey.baseURL,
      tokenStorage: ref.read(tokenStorageProvider)
  );
});


class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.tokenStorage,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;
  final TokenStorage tokenStorage;

  /// 共通ヘッダー
  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, String>> _authorizedHeaders(
      Map<String, String>? headers) async {
    final token = await tokenStorage.read();

    return {
      ..._defaultHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };
  }

  Uri _buildUri(String path) {
    return Uri.parse('$baseUrl$path');
  }

  /// HTTP Methods GET
  Future<Map<String, dynamic>> get(
      String path, {
        Map<String, String>? headers,
      }) async {
    logger('======= GET Request Header =======');
    logger(headers);
    logger('======= GET Request Header =======');
    final response = await _client.get(
      _buildUri(path),
      headers: await _authorizedHeaders(headers),
    );
    return _handleResponse(response);
  }

  /// HTTP Methods POST
  Future<Map<String, dynamic>> post(
      String path, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
      }) async {
    logger('======= POST Request body =======');
    logger(body);
    logger('======= POST Request body =======');
    final response = await _client.post(
      _buildUri(path),
      headers: await _authorizedHeaders(headers),
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
    logger('======= PUT Request body =======');
    logger(body);
    logger('======= PUT Request body =======');
    final response = await _client.put(
      _buildUri(path),
      headers: await _authorizedHeaders(headers),
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
    logger('======= PATCH Request body =======');
    logger(body);
    logger('======= PATCH Request body =======');
    final response = await _client.patch(
      _buildUri(path),
      headers: await _authorizedHeaders(headers),
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
    logger('======= DELETE Request body =======');
    logger(body);
    logger('======= DELETE Request body =======');
    final response = await _client.delete(
      _buildUri(path),
      headers: await _authorizedHeaders(headers),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  /// Response Handling
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    final result =
    jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      logger('======= Success API Response =======');
      logger(result);
      logger('======= Success API Response =======');
      return result;
    }

    // 認証エラーはストレージをクリア
    if (statusCode == 401) {
      tokenStorage.clear();
    }

    throw ApiErrorMapper.fromResponse(statusCode, result);
  }

  void dispose() {
    _client.close();
  }
}

