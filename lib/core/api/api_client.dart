import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
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
      Map<String, String>? headers,
      String? token
  ) async {
    return {
      ..._defaultHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };
  }

  /// リクエスト前の事前チェック（オフライン・トークン）
  /// [requiresAuth] が true の場合のみトークンチェックを行う
  Future<String?> _preRequestCheck({bool requiresAuth = true}) async {
    // オフラインチェック
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      throw ApiErrorMapper.fromOffline();
    }

    if (requiresAuth) {
      final token = await tokenStorage.read();
      if (requiresAuth && token == null) {
        // トークンがない場合のエラーを投げる
        throw ApiErrorMapper.fromPreCheckUnauthorized();
      }
      return token;
    } else {
      return null;
    }

  }

  /// Uriを組み立てるメソッド
  Uri _buildUri(String path, [Map<String, String>? queryParameters]) {
    final uri = Uri.parse('$baseUrl$path');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      // 既存のURLにクエリパラメータをマージして新しいUriを返す
      return uri.replace(queryParameters: {
        ...uri.queryParameters,
        ...queryParameters,
      });
    }
    return uri;
  }
  /// HTTP Methods GET
  Future<Map<String, dynamic>> get(
      String path, {
        Map<String, String>? headers,
        Map<String, dynamic>? queryParameters,
        required bool requiresAuth
      }) async {
    // トークン & オフラインチェック
    final token = await _preRequestCheck(requiresAuth: requiresAuth);
    // queryParameters を String に変換 (Uri.https 等で使うため)
    final stringQuery = queryParameters?.map((key, value) => MapEntry(key, value.toString()));

    logger('======= GET Request =======');
    logger('path：$path');
    logger('queries：$queryParameters');
    logger('======= GET Request =======');
    final response = await _client.get(
      _buildUri(path, stringQuery),
      headers: await _authorizedHeaders(headers, token),
    );
    return _handleResponse(response);
  }

  /// HTTP Methods POST
  Future<Map<String, dynamic>> post(
      String path, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
        required bool requiresAuth
      }) async {
    // トークン & オフラインチェック
    final token = await _preRequestCheck(requiresAuth: requiresAuth);
    logger('======= POST Request body =======');
    logger('path：$path');
    logger('body：$body');
    logger('======= POST Request body =======');
    final response = await _client.post(
      _buildUri(path),
      headers: await _authorizedHeaders(headers, token),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// HTTP Methods PUT
  Future<Map<String, dynamic>> put(
      String path, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
        required bool requiresAuth
      }) async {
    // トークン & オフラインチェック
    final token = await _preRequestCheck(requiresAuth: requiresAuth);
    logger('======= PUT Request body =======');
    logger('path：$path');
    logger('body：$body');
    logger('======= PUT Request body =======');
    final response = await _client.put(
      _buildUri(path),
      headers: await _authorizedHeaders(headers, token),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// HTTP Methods PATCH
  Future<Map<String, dynamic>> patch(
      String path, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
        required bool requiresAuth
      }) async {
    // トークン & オフラインチェック
    final token = await _preRequestCheck(requiresAuth: requiresAuth);
    logger('======= PATCH Request body =======');
    logger('path：$path');
    logger('body：$body');
    logger('======= PATCH Request body =======');
    final response = await _client.patch(
      _buildUri(path),
      headers: await _authorizedHeaders(headers, token),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// HTTP Methods DELETE
  Future<Map<String, dynamic>> delete(
      String path, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
        required bool requiresAuth
      }) async {
    // トークン & オフラインチェック
    final token = await _preRequestCheck(requiresAuth: requiresAuth);
    logger('======= DELETE Request body =======');
    logger('path：$path');
    logger('body：$body');
    logger('======= DELETE Request body =======');
    final response = await _client.delete(
      _buildUri(path),
      headers: await _authorizedHeaders(headers, token),
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
    logger('======= ❌ Error API Response =======');
    logger(result);
    logger('======= ❌ Error API Response =======');

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

