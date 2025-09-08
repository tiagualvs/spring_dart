import 'dart:convert';

import 'package:shelf/shelf.dart';

abstract class SpringDartException implements Exception {
  final int statusCode;
  final String message;
  final StackTrace? stackTrace;
  const SpringDartException(this.statusCode, this.message, [this.stackTrace]);

  Response toResponse() {
    return Response(
      statusCode,
      body: json.encode({'message': message}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

class CustomException extends SpringDartException {
  final List<SpringDartException> exceptions;
  const CustomException(int statusCode, this.exceptions, String message, [StackTrace? stackTrace])
    : super(
        statusCode,
        message,
        stackTrace,
      );

  @override
  Response toResponse() {
    return Response(
      statusCode,
      body: json.encode(
        {
          'message': message,
          'errors': List.from(
            exceptions.map(
              (e) {
                return {
                  'status_code': e.statusCode,
                  'message': e.message,
                };
              },
            ),
          ),
        },
      ),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

class BadRequestException extends SpringDartException {
  const BadRequestException(String message, [StackTrace? stackTrace]) : super(400, message, stackTrace);
}

class UnauthorizedException extends SpringDartException {
  const UnauthorizedException(String message, [StackTrace? stackTrace]) : super(401, message, stackTrace);
}

class ForbiddenException extends SpringDartException {
  const ForbiddenException(String message, [StackTrace? stackTrace]) : super(403, message, stackTrace);
}

class NotFoundException extends SpringDartException {
  const NotFoundException(String message, [StackTrace? stackTrace]) : super(404, message, stackTrace);
}

class MethodNotAllowedException extends SpringDartException {
  const MethodNotAllowedException(String message, [StackTrace? stackTrace]) : super(405, message, stackTrace);
}

class ConflictException extends SpringDartException {
  const ConflictException(String message, [StackTrace? stackTrace]) : super(409, message, stackTrace);
}

class InternalServerErrorException extends SpringDartException {
  const InternalServerErrorException(String message, [StackTrace? stackTrace]) : super(500, message, stackTrace);
}
