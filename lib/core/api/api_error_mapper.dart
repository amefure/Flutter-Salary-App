import 'dart:convert';

import 'package:salary/core/api/api_exception.dart';

class ApiErrorMapper {

  static ApiException fromResponse(
      int statusCode,
      Map<String, dynamic> result,
      ) {
    final error = result['error'] ?? {};
    final code = error['code'] as String?;
    final message = _parseErrorMessage(result);

    return ApiException(
      statusCode: statusCode,
      title: error['title'],
      code: code,
      message: message,
      details: error['details'],
      type: _mapCodeToErrorType(code),
    );
  }

  static String _parseErrorMessage(Map<String, dynamic> result) {
    final rawMessage = result['error']?['message'];

    if (rawMessage == null) {
      return 'Unknown error';
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
