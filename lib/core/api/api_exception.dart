enum ApiErrorType {
  /// オフライン
  offline,           // EA000
  /// バリデーション
  validation,        // EA001
  /// 認証失敗 or トークンなし
  unauthorized,      // EA002
  /// 更新権限のないユーザー
  forbidden,         // EA003
  /// データが見つからない
  notFound,          // EA004
  /// サーバー内部エラー
  server,            // EA005
  /// 不明なエラー
  unknown,
}

enum ApiErrorCode {
  validation('EA001'),
  unauthorized('EA002'),
  forbidden('EA003'),
  notFound('EA004'),
  server('EA005');

  final String code;
  const ApiErrorCode(this.code);

  static ApiErrorCode? fromCode(String? code) {
    return ApiErrorCode.values.firstWhere((e) => e.code == code);
  }
}
class ApiException implements Exception {
  final int statusCode;
  final String? title;
  final String? code;
  final String message;
  final Map<String, dynamic>? details;
  final ApiErrorType type;

  const ApiException({
    required this.statusCode,
    required this.message,
    required this.type,
    this.title,
    this.code,
    this.details,
  });

  @override
  String toString() {
    return 'ApiException($code): $message';
  }
}
