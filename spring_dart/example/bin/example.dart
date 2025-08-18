// POWERED BY SPRING DART
// GENERATED CODE - DO NOT MODIFY BY HAND

import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:example/src/config/security_configuration.dart';
import 'package:example/src/config/server_configuration.dart';
import 'package:example/src/config/sqlite_configuration.dart';
import 'package:example/src/controllers/auth_controller.dart';
import 'package:example/src/dtos/sign_in_dto.dart';
import 'package:example/src/dtos/sign_up_dto.dart';
import 'package:example/src/entities/user_entity.dart';
import 'package:example/src/exceptions.dart';
import 'package:example/src/repositories/users_repository.dart';
import 'package:example/src/server_controller_advice.dart';
import 'package:example/src/services/auth_service.dart';
import 'package:spring_dart/spring_dart.dart';

void main(List<String> args) async {
  final router = Router(notFoundHandler: _defaultNotFoundHandler);
  // Configurations
  final securityConfiguration = SecurityConfiguration();
  final sqliteConfiguration = SqliteConfiguration();
  // Beans
  final jwtService = securityConfiguration.jwtService();
  final passwordService = securityConfiguration.passwordService();
  final database = await sqliteConfiguration.database();
  // Repositories
  final usersRepository = UsersRepository(database);
  // Services
  final authService = AuthService(usersRepository, jwtService, passwordService);
  // Controllers
  final authController = _$AuthController(authService);
  router.mount('/auth', authController.handler);
  // Server Configuration
  Handler handler = router.call;
  final serverConfiguration = ServerConfiguration();
  for (final middleware in serverConfiguration.middlewares) {
    handler = middleware(handler);
  }
  SpringDartDefaults.instance.toEncodable = serverConfiguration.toEncodable;
  return await serverConfiguration.setup(
    SpringDart((request) => _exceptionHandler(handler, request)),
  );
}

class _$AuthController extends AuthController {
  const _$AuthController(super.authService);

  FutureOr<Response> handler(Request request) async {
    final router = Router();

    router.post('/sign-up', (Request request) async {
      final $json = await request.readAsString();
      final $body = Map<String, dynamic>.from(json.decode($json));
      final $dson = DSON();
      final dto = $dson.fromJson<SignUpDto>($body, SignUpDto.new);
      return signUp(dto);
    });

    router.post('/sign-in', (Request request) async {
      final $json = await request.readAsString();
      final $body = Map<String, dynamic>.from(json.decode($json));
      final $dson = DSON();
      final dto = $dson.fromJson<SignInDto>($body, SignInDto.new);
      return signIn(dto);
    });

    router.post('/sign-out', (Request request) async {
      return signOut();
    });

    router.post('/refresh-token', (Request request) async {
      final $json = await request.readAsString();
      final body = Map<String, dynamic>.from(json.decode($json));
      return refreshToken(body);
    });
    return router.call(request);
  }
}

class UsersRepositoryImp extends CrudRepository<UserEntity, int> {
  @override
  AsyncResult<UserEntity, Exception> insertOne(
    InsertOneParams<UserEntity> params,
  ) {
    throw UnimplementedError();
  }

  @override
  AsyncResult<UserEntity, Exception> findOne(FindOneParams<UserEntity> params) {
    throw UnimplementedError();
  }

  @override
  AsyncResult<List<UserEntity>, Exception> findMany(
    FindManyParams<UserEntity> params,
  ) {
    throw UnimplementedError();
  }

  @override
  AsyncResult<UserEntity, Exception> updateOne(
    UpdateOneParams<UserEntity> params,
  ) {
    throw UnimplementedError();
  }

  @override
  AsyncResult<UserEntity, Exception> deleteOne(
    DeleteOneParams<UserEntity> params,
  ) {
    throw UnimplementedError();
  }
}

class UsersInsertOneParams extends InsertOneParams<UserEntity> {
  final String name;
  final String email;
  final String password;

  const UsersInsertOneParams({
    required this.name,
    required this.email,
    required this.password,
  });
}

FutureOr<Response> _defaultNotFoundHandler(Request request) async {
  final path = request.url.path;

  return Json(404, body: {'error': 'Route not found: $path'});
}

FutureOr<Response> _exceptionHandler(Handler handler, Request request) async {
  try {
    return await handler(request);
  } catch (e) {
    if (e is Exception) {
      return ServerControllerAdvice().exceptionHandler(e);
    } else if (e is ServerException) {
      return ServerControllerAdvice().serverExceptionHandler(e);
    } else {
      return Json(500, body: {'error': e.toString()});
    }
  }
}
