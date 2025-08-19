import 'package:spring_dart/spring_dart.dart';

abstract class ServerException implements Exception {
  final int statusCode;
  final String message;
  const ServerException(this.statusCode, this.message);

  Response toResponse() {
    return Json(statusCode, body: {'error': message});
  }
}

class BadRequestException extends ServerException {
  const BadRequestException([String? message]) : super(400, message ?? 'Bad Request');
}

class UnauthorizedException extends ServerException {
  const UnauthorizedException([String? message]) : super(401, message ?? 'Unauthorized');
}

class ForbiddenException extends ServerException {
  const ForbiddenException([String? message]) : super(403, message ?? 'Forbidden');
}

class NotFoundException extends ServerException {
  const NotFoundException([String? message]) : super(404, message ?? 'Not Found');
}

class ConflictException extends ServerException {
  const ConflictException([String? message]) : super(409, message ?? 'Conflict');
}

class InternalServerException extends ServerException {
  const InternalServerException([String? message]) : super(500, message ?? 'Internal Server Error');
}
