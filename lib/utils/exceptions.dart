class CustomException implements Exception {
  final dynamic cause;
  CustomException([this.cause]);

  @override
  String toString() {
    Object? cause = this.cause;
    if (cause == null) return "ConnectionTimeoutException";
    return cause.toString();
  }
}