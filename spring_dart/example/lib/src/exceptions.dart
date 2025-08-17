abstract class ServerException implements Exception {
  final int statusCode;
  final String message;
  const ServerException(this.statusCode, this.message);
}

class BadRequestException extends ServerException {
  const BadRequestException([String? message]) : super(400, message ?? 'Bad Request');
}
