class AssertException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  AssertException({
    required this.message,
    this.stackTrace,
  });

  //toString
  @override
  String toString() => 'AssertException(message: $message, stackTrace: $stackTrace)';
}
