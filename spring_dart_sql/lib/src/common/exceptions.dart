import 'dart:convert';

import 'package:spring_dart_core/spring_dart_core.dart';

abstract class SqlException implements Exception {
  final int statusCode;
  final String message;
  final StackTrace? stackTrace;
  const SqlException(this.statusCode, this.message, [this.stackTrace]);

  Response toResponse() {
    return Response(
      statusCode,
      body: json.encode(
        {'message': message},
      ),
    );
  }
}

class NotFoundSqlException extends SqlException {
  const NotFoundSqlException(String message, [StackTrace? stackTrace]) : super(404, message, stackTrace);
}

class DuplicateSqlException extends SqlException {
  const DuplicateSqlException(String message, [StackTrace? stackTrace]) : super(409, message, stackTrace);
}

class UnknownSqlException extends SqlException {
  const UnknownSqlException(String message, [StackTrace? stackTrace]) : super(500, message, stackTrace);
}
