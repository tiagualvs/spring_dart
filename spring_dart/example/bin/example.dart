// POWERED BY SPRING DART
// GENERATED CODE - DO NOT MODIFY BY HAND

import 'dart:async';
import 'dart:convert';
import 'package:example/src/config/security_configuration.dart';
import 'package:example/src/config/server_configuration.dart';
import 'package:example/src/config/sqlite_configuration.dart';
import 'package:example/src/controllers/auth_controller.dart';
import 'package:example/src/dtos/sign_in_dto.dart';
import 'package:example/src/dtos/sign_up_dto.dart';
import 'package:example/src/repositories/users_repository.dart';
import 'package:example/src/services/auth_service.dart';
import 'package:spring_dart/spring_dart.dart';

void main(List<String> args) async {
  final router = Router();
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
  return await serverConfiguration.setup(SpringDart(handler));
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
