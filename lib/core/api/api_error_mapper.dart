import 'dart:convert';

import 'package:salary/core/api/api_exception.dart';
import 'package:salary/core/config/json_keys.dart';

class ApiErrorMapper {

  static ApiException fromOffline() {
    return const ApiException(
      statusCode: 0,
      message: 'インターネットに接続されていません。電波の良い場所で再度お試しください。',
      type: ApiErrorType.offline,
      code: 'OFFLINE',
    );
  }

  static ApiException fromPreCheckUnauthorized() {
    return const ApiException(
      statusCode: 401,
      message: 'ログインセッションがありません。再度ログインしてください。',
      type: ApiErrorType.unauthorized,
      code: 'AUTH_TOKEN_NOT_FOUND',
    );
  }

  static ApiException fromResponse(
      int statusCode,
      Map<String, dynamic> result,
      ) {
    final error = result[ApiErrorJsonKeys.error] ?? {};
    final code = error[ApiErrorJsonKeys.code] as String?;
    final message = _parseErrorMessage(result);

    return ApiException(
      statusCode: statusCode,
      title: error[ApiErrorJsonKeys.title],
      code: code,
      message: message,
      details: error[ApiErrorJsonKeys.details],
      type: _mapCodeToErrorType(code),
    );
  }

  static String _parseErrorMessage(Map<String, dynamic> result) {
    final rawMessage = result[ApiErrorJsonKeys.error]?[ApiErrorJsonKeys.message];

    if (rawMessage == null) {
      return '不明なエラー';
    }

    if (rawMessage is! String) {
      return rawMessage.toString();
    }

    try {
      final decoded = jsonDecode(rawMessage);

      if (decoded is Map<String, dynamic>) {
        return decoded.values
            .expand((e) => e as List)
            .join('\n');
      }

      if (decoded is List) {
        return decoded.join('\n');
      }

      return decoded.toString();
    } catch (_) {
      // JSONではなかった場合
      return rawMessage;
    }
  }

  static ApiErrorType _mapCodeToErrorType(String? code) {
    final errorCode = ApiErrorCode.fromCode(code);
    switch (errorCode) {
      case ApiErrorCode.validation:
        return ApiErrorType.validation;
      case ApiErrorCode.unauthorized:
        return ApiErrorType.unauthorized;
      case ApiErrorCode.forbidden:
        return ApiErrorType.forbidden;
      case ApiErrorCode.notFound:
        return ApiErrorType.notFound;
      case ApiErrorCode.server:
        return ApiErrorType.server;
      default:
        return ApiErrorType.unknown;
    }
  }

}
