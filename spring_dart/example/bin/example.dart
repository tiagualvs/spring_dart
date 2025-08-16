// POWERED BY SPRING DART
// GENERATED CODE - DO NOT MODIFY BY HAND

import 'dart:async';
import 'dart:convert';
import 'package:example/config/server_configuration.dart';
import 'package:example/configurations/security_configuration.dart';
import 'package:example/controllers/auth_controller.dart';
import 'package:example/controllers/coordinates_controller.dart';
import 'package:example/controllers/users_controller.dart';
import 'package:example/dtos/create_post_dto.dart';
import 'package:example/dtos/refresh_token_dto.dart';
import 'package:example/dtos/sign_in_dto.dart';
import 'package:example/dtos/sign_up_dto.dart';
import 'package:example/parsers/date_time_parser.dart';
import 'package:example/repositories/messages_repository_imp.dart';
import 'package:example/repositories/posts_repository.dart';
import 'package:example/repositories/users_repository.dart';
import 'package:spring_dart/spring_dart.dart';

void main(List<String> args) async {
  final router = Router();
  // Configurations
  final securityConfiguration = SecurityConfiguration();
  // Beans
  final passwordService = securityConfiguration.password();
  // Repositories
  final messagesRepository = MessagesRepositoryImp();
  final postsRepository = PostsRepository();
  final usersRepository = UsersRepository();
  // Controllers
  final authController = _$AuthController(passwordService, usersRepository);
  router.mount('/auth', authController.handler);
  final coordinatesController = _$CoordinatesController();
  router.mount('/coordinates', coordinatesController.handler);
  final usersController = _$UsersController(
    usersRepository,
    postsRepository,
    messagesRepository,
  );
  router.mount('/users', usersController.handler);
  // Server Configuration
  Handler handler = router.call;
  final serverConfiguration = ServerConfiguration();
  for (final middleware in serverConfiguration.middlewares) {
    handler = middleware(handler);
  }
  return await serverConfiguration.setup(SpringDart(handler));
}

class _$AuthController extends AuthController {
  const _$AuthController(super.passwordService, super.users);

  FutureOr<Response> handler(Request request) async {
    final router = Router();

    router.post('/sign-in', (Request request) async {
      final $json = await request.readAsString();
      final $body = Map<String, dynamic>.from(json.decode($json));
      final $dson = DSON();
      final dto = $dson.fromJson<SignInDto>($body, SignInDto.new);
      return signIn(dto);
    });

    router.post('/sign-up', (Request request) async {
      final $json = await request.readAsString();
      final $body = Map<String, dynamic>.from(json.decode($json));
      final $dson = DSON();
      final dto = $dson.fromJson<SignUpDto>($body, SignUpDto.new);
      return signUp(dto);
    });

    router.post('/refresh-token', (Request request) async {
      final $json = await request.readAsString();
      final $body = Map<String, dynamic>.from(json.decode($json));
      final $dson = DSON();
      final dto = $dson.fromJson<RefreshTokenDto>(
        $body,
        RefreshTokenDto.new,
        aliases: {
          RefreshTokenDto: {'refreshToken': 'refresh_token'},
        },
      );
      return refreshToken(dto);
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
      final $json = await request.readAsString();
      final $body = Map<String, dynamic>.from(json.decode($json));
      final timestampToDateTimeParser = TimestampToDateTimeParser();
      $body['created_at'] = timestampToDateTimeParser.decode(
        $body['created_at'],
      );
      final $dson = DSON();
      final dto = $dson.fromJson<CreatePostDto>(
        $body,
        CreatePostDto.new,
        aliases: {
          CreatePostDto: {'createdAt': 'created_at'},
        },
      );
      return createPost(id, lang, authorization, dto);
    });

    router.put('/posts/<id>/update', (Request request, String id) async {
      final $json = await request.readAsString();
      final body = Map<String, dynamic>.from(json.decode($json));
      return updatePost(id, body);
    });

    router.post('/posts/<id>/delete', (Request request, String id) async {
      final $json = await request.readAsString();
      final body = Map<String, dynamic>.from(json.decode($json));
      return deletePost(id, body);
    });
    return router.call(request);
  }
}

class _$CoordinatesController extends CoordinatesController {
  const _$CoordinatesController();

  FutureOr<Response> handler(Request request) async {
    final router = Router();

    router.get('/current', (Request request) async {
      return current(request);
    });
    return router.call(request);
  }
}

class _$UsersController extends UsersController {
  const _$UsersController(super.users, super.posts, super.messages);

  FutureOr<Response> handler(Request request) async {
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
      final $json = await request.readAsString();
      final body = Map<String, dynamic>.from(json.decode($json));
      return create(userId, body);
    });
    return router.call(request);
  }
}
