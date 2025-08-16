import 'dart:convert';

import 'package:shelf/shelf.dart' show Response;

import 'common/spring_dart_defaults.dart';

/// [Json] class for [Response] objects with JSON body
class Json extends Response {
  Json._(super.statusCode, {super.body, super.headers, super.context, super.encoding});

  factory Json(int statusCode, {Object? body, Map<String, String>? headers, Map<String, String>? context}) {
    return Json._(
      statusCode,
      body: SpringDartDefaults.instance.toJson(body),
      headers: {...?headers, 'Content-Type': 'application/json'},
      context: context,
      encoding: utf8,
    );
  }

  factory Json.ok({Object? body, Map<String, String>? headers, Map<String, String>? context}) {
    return Json(200, body: body, headers: headers, context: context);
  }

  factory Json.created({Object? body, Map<String, String>? headers, Map<String, String>? context}) {
    return Json(201, body: body, headers: headers, context: context);
  }

  factory Json.noContent({Object? body, Map<String, String>? headers, Map<String, String>? context}) {
    return Json(204, body: body, headers: headers, context: context);
  }

  factory Json.badRequest({Object? body, Map<String, String>? headers, Map<String, String>? context}) {
    return Json(400, body: body, headers: headers, context: context);
  }

  factory Json.unauthorized({Object? body, Map<String, String>? headers, Map<String, String>? context}) {
    return Json(401, body: body, headers: headers, context: context);
  }

  factory Json.forbidden({Object? body, Map<String, String>? headers, Map<String, String>? context}) {
    return Json(403, body: body, headers: headers, context: context);
  }

  factory Json.notFound({Object? body, Map<String, String>? headers, Map<String, String>? context}) {
    return Json(404, body: body, headers: headers, context: context);
  }

  factory Json.serverError({Object? body, Map<String, String>? headers, Map<String, String>? context}) {
    return Json(500, body: body, headers: headers, context: context);
  }

  factory Json.notImplemented({Object? body, Map<String, String>? headers, Map<String, String>? context}) {
    return Json(501, body: body, headers: headers, context: context);
  }
}
