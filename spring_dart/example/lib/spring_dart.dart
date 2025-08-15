// GENERATED CODE - DO NOT MODIFY BY HAND
// POWERED BY SPRING DART

import 'package:spring_dart/spring_dart.dart';
import 'dart:io';
import 'dart:convert';
import 'package:example/configurations/security_configuration.dart';
import 'package:example/controllers/auth_controller.dart';
import 'package:example/configurations/password_service.dart';
import 'package:example/repositories/users_repository.dart';
import 'package:example/dtos/sign_in_dto.dart';
import 'package:example/dtos/sign_up_dto.dart';
import 'package:example/dtos/create_post_dto.dart';
import 'package:example/controllers/users_controller.dart';
import 'package:example/repositories/posts_repository.dart';
import 'package:example/repositories/messages_repository.dart';
import 'package:example/repositories/messages_repository_imp.dart';
import 'package:example/services/jwt_service.dart';

class SpringDart {
  late final controllers = <String, Handler>{
    '/auth': AuthControllerProxy(
      GetIt.instance.get<PasswordService>(),
      GetIt.instance.get<UsersRepository>(),
    ).handler,
    '/users': UsersControllerProxy(
      GetIt.instance.get<UsersRepository>(),
      GetIt.instance.get<PostsRepository>(),
      GetIt.instance.get<MessagesRepository>(),
    ).handler,
  };

  Future<void> configurer() async {
    final getIt = GetIt.instance;

    getIt.registerFactory<SecurityConfiguration>(() => SecurityConfiguration());
    getIt.registerFactory<PasswordService>(
      () => getIt.get<SecurityConfiguration>().password(),
    );
    getIt.registerFactory<MessagesRepository>(() => MessagesRepositoryImp());
    getIt.registerFactory<PostsRepository>(() => PostsRepository());
    getIt.registerFactory<UsersRepository>(() => UsersRepository());
    getIt.registerFactory<JwtService>(() => JwtService());
  }

  Future<HttpServer> start({Object host = '0.0.0.0', int port = 8080}) async {
    final Router router = Router();

    for (final controller in controllers.entries) {
      router.mount(controller.key, controller.value);
    }

    return await serve(router.call, host, port);
  }
}

class AuthControllerProxy extends AuthController {
  const AuthControllerProxy(super.passwordService, super.users);

  Handler get handler {
    final router = Router();

    router.post('/sign-in', (Request request) async {
      final body = json.decode(await request.readAsString());

      final dto = SignInDto(body['email'], body['password']);

      return signIn(dto);
    });

    router.post('/sign-up', (Request request) async {
      final body = json.decode(await request.readAsString());

      final dto = SignUpDto(
        name: body['name'],
        email: body['email'],
        password: body['password'],
      );

      return signUp(dto);
    });

    router.post('/refresh-token', (Request request) async {
      return refreshToken(request);
    });

    router.get('/<id>', (Request request, String id) async {
      return findOneUser(id);
    });

    router.get('/users', (Request request) async {
      final name = request.url.queryParameters['name'];

      return findManyUsers(name);
    });

    router.post('/posts/<id>/create', (Request request, String id) async {
      final lang = request.url.queryParameters['lang'];
      final authorization = request.headers['authorization'];
      final age = request.context['age'] as int;
      final body = json.decode(await request.readAsString());

      final dto = CreatePostDto(title: body['title'], content: body['content']);

      return createPost(id, lang, age, authorization, dto);
    });

    router.put('/posts/<id>/update', (Request request, String id) async {
      final body =
          json.decode(await request.readAsString()) as Map<String, dynamic>;

      return updatePost(id, body);
    });

    router.delete('/posts/<id>/delete', (Request request, String id) async {
      final body =
          json.decode(await request.readAsString()) as Map<String, dynamic>;

      return deletePost(id, body);
    });

    return router.call;
  }
}

class UsersControllerProxy extends UsersController {
  const UsersControllerProxy(super.users, super.posts, super.messages);

  Handler get handler {
    final router = Router();

    router.get('/', (Request request) async {
      final name = request.url.queryParameters['name'];
      final age = request.url.queryParameters['age'];
      final email = request.url.queryParameters['email'];
      final password = request.url.queryParameters['password'];

      return findMany(name, age, email, password);
    });

    router.get('/<id|[0-9]>', (Request request, String id) async {
      return findOne(id);
    });

    router.post('/', (Request request) async {
      final userId = request.context['user_id'] as String;
      final body =
          json.decode(await request.readAsString()) as Map<String, dynamic>;

      return create(userId, body);
    });

    return router.call;
  }
}
