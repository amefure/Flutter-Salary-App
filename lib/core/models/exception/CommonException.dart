
class CommonException implements Exception {
  final String message;

  const CommonException({
    required this.message,
  });

  @override
  String toString() {
    return 'CommonException$message';
  }
}
