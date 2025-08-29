// POWERED BY SPRING DART
// GENERATED CODE - DO NOT MODIFY BY HAND

import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:example/src/config/beans/password_bean.dart';
import 'package:example/src/config/security_configuration.dart';
import 'package:example/src/config/server_configuration.dart';
import 'package:example/src/controllers/auth_controller.dart';
import 'package:example/src/controllers/users_controller.dart';
import 'package:example/src/dtos/sign_in_dto.dart';
import 'package:example/src/dtos/sign_up_dto.dart';
import 'package:example/src/entities/chat_entity.dart';
import 'package:example/src/entities/comment_entity.dart';
import 'package:example/src/entities/participant_entity.dart';
import 'package:example/src/entities/post_entity.dart';
import 'package:example/src/entities/user_entity.dart';
import 'package:example/src/exceptions.dart';
import 'package:example/src/server_controller_advice.dart';
import 'package:example/src/services/auth_service.dart';
import 'package:spring_dart/spring_dart.dart';
import 'package:spring_dart_sql/spring_dart_sql.dart';
import 'package:sqlite3/sqlite3.dart';

Future<void> server(List<String> args) async {
  final injector = Injector.instance;
  final router = Router(notFoundHandler: _defaultNotFoundHandler);
  // Configurations
  final securityConfiguration = SecurityConfiguration();
  // Beans
  injector.set<JwtService>(() => securityConfiguration.jwtService());
  injector.set<PasswordBean>(() => securityConfiguration.passwordService());
  await injector.commit();
  // Repositories
  final db = sqlite3.open('database.db');
  db.execute(
    '''CREATE TABLE IF NOT EXISTS _migrations (version INTEGER PRIMARY KEY, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP);''',
  );
  // DDL AUTO CREATE - DROPPING AND RE-CREATING TABLES;
  final migration = DefaultMigration();
  db.execute(await migration.down());
  db.execute(await migration.up());
  db.execute('DELETE FROM _migrations;');
  db.execute('INSERT INTO _migrations (version) VALUES (?);', [
    migration.version,
  ]);
  injector.set<ChatsRepository>(() => ChatsRepository(db));
  injector.set<CommentsRepository>(() => CommentsRepository(db));
  injector.set<ParticipantsRepository>(() => ParticipantsRepository(db));
  injector.set<PostsRepository>(() => PostsRepository(db));
  injector.set<UsersRepository>(() => UsersRepository(db));
  // Services
  injector.set<AuthService>(
    () => AuthService(injector.get(), injector.get(), injector.get()),
  );
  // Controllers
  final authController = _$AuthController(injector.get());
  router.mount('/auth', authController.handler);
  final usersController = _$UsersController(injector.get());
  router.mount('/users', usersController.handler);
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

class _$UsersController extends UsersController {
  _$UsersController(super.repository);

  FutureOr<Response> handler(Request request) async {
    final router = Router();

    router.post('/upload', (Request request) async {
      final fields = <FormData>[];
      if (request.formData() case var form?) {
        await for (final formData in form.formData) {
          fields.add(formData);
        }
      }
      if (fields.isEmpty) {
        throw Exception('empty_form_data');
      }
      return upload(fields);
    });

    router.get('/', (Request request) async {
      return get();
    });

    router.post('/', (Request request) async {
      return post();
    });

    router.get('/<id>', (Request request, String id) async {
      return getById(id);
    });

    router.put('/<id>', (Request request, String id) async {
      return put(id);
    });

    router.delete('/<id>', (Request request, String id) async {
      return delete(id);
    });
    return router.call(request);
  }
}

class ChatsRepository extends CrudRepository<ChatEntity> {
  final Database db;
  const ChatsRepository(this.db);

  @override
  AsyncResult<ChatEntity> insertOne(InsertOneParams<ChatEntity> params) async {
    try {
      final stmt = db.prepare(params.query);

      final result = stmt.select(params.values);

      if (result.isEmpty) {
        throw NotFoundSqlException('fail_to_insert_on_chat');
      }

      final row = result.first;

      final entity = ChatEntity(
        id: row['id'] ?? 0,
        name: row['name'] ?? '',
        image: row['image'] ?? '',
        type: row['type'] ?? '',
        createdAt: DateTime.tryParse(row['created_at']) ?? DateTime.now(),
        updatedAt: DateTime.tryParse(row['updated_at']) ?? DateTime.now(),
      );

      return Success(entity);
    } on SqlException catch (e) {
      return Error(e);
    } on Exception catch (e, s) {
      return Error(UnknownSqlException('fail_to_insert_on_chat', s));
    }
  }

  @override
  AsyncResult<ChatEntity> findOne(FindOneParams<ChatEntity> params) async {
    try {
      final stmt = db.prepare(params.query);

      final result = stmt.select(params.values);

      if (result.isEmpty) {
        throw NotFoundSqlException('chat_not_found');
      }

      final row = result.first;

      final entity = ChatEntity(
        id: row['id'] ?? 0,
        name: row['name'] ?? '',
        image: row['image'] ?? '',
        type: row['type'] ?? '',
        createdAt: DateTime.tryParse(row['created_at']) ?? DateTime.now(),
        updatedAt: DateTime.tryParse(row['updated_at']) ?? DateTime.now(),
      );

      return Success(entity);
    } on SqlException catch (e) {
      return Error(e);
    } on Exception catch (e, s) {
      return Error(UnknownSqlException('fail_to_insert_on_chat', s));
    }
  }

  @override
  AsyncResult<List<ChatEntity>> findMany(
    FindManyParams<ChatEntity> params,
  ) async {
    try {
      final stmt = db.prepare(params.query);

      final result = stmt.select(params.values);

      final entities = result.map((row) {
        return ChatEntity(
          id: row['id'] ?? 0,
          name: row['name'] ?? '',
          image: row['image'] ?? '',
          type: row['type'] ?? '',
          createdAt: DateTime.tryParse(row['created_at']) ?? DateTime.now(),
          updatedAt: DateTime.tryParse(row['updated_at']) ?? DateTime.now(),
        );
      }).toList();

      return Success(entities);
    } on Exception catch (e, s) {
      return Error(UnknownSqlException('fail_to_get_chats', s));
    }
  }

  @override
  AsyncResult<ChatEntity> updateOne(UpdateOneParams<ChatEntity> params) async {
    try {
      final stmt = db.prepare(params.query);

      final result = stmt.select(params.values);

      if (result.isEmpty) {
        throw NotFoundSqlException('chat_not_found');
      }

      final row = result.first;

      final entity = ChatEntity(
        id: row['id'] ?? 0,
        name: row['name'] ?? '',
        image: row['image'] ?? '',
        type: row['type'] ?? '',
        createdAt: DateTime.tryParse(row['created_at']) ?? DateTime.now(),
        updatedAt: DateTime.tryParse(row['updated_at']) ?? DateTime.now(),
      );

      return Success(entity);
    } on SqlException catch (e) {
      return Error(e);
    } on Exception catch (e, s) {
      return Error(UnknownSqlException('fail_to_update_chat', s));
    }
  }

  @override
  AsyncResult<ChatEntity> deleteOne(DeleteOneParams<ChatEntity> params) async {
    try {
      final stmt = db.prepare(params.query);

      final result = stmt.select(params.values);

      if (result.isEmpty) {
        throw NotFoundSqlException('chat_not_found');
      }

      final row = result.first;

      final entity = ChatEntity(
        id: row['id'] ?? 0,
        name: row['name'] ?? '',
        image: row['image'] ?? '',
        type: row['type'] ?? '',
        createdAt: DateTime.tryParse(row['created_at']) ?? DateTime.now(),
        updatedAt: DateTime.tryParse(row['updated_at']) ?? DateTime.now(),
      );

      return Success(entity);
    } on SqlException catch (e) {
      return Error(e);
    } on Exception catch (e, s) {
      return Error(UnknownSqlException('fail_to_delete_chat', s));
    }
  }
}

class InsertOneChatParams extends InsertOneParams<ChatEntity> {
  final int? id;
  final String? name;
  final String? image;
  final String type;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InsertOneChatParams({
    this.id,
    this.name,
    this.image,
    required this.type,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> _map() => <String, dynamic>{
    if (id != null) 'id': id,
    if (name != null) 'name': name,
    if (image != null) 'image': image,
    'type': type,
    if (createdAt != null) 'created_at': createdAt,
    if (updatedAt != null) 'updated_at': updatedAt,
  };

  @override
  String get query =>
      'INSERT INTO chats (${_map().keys.map((k) => k).join(', ')}) VALUES (${_map().keys.map((_) => '?').join(', ')}) RETURNING *;';

  @override
  List<Object?> get values {
    final newMap = _map();

    for (final key in _map().keys) {
      if (_map()[key] is DateTime) {
        newMap[key] = (_map()[key] as DateTime).toIso8601String();
      }
    }

    return newMap.values.toList();
  }
}

class FindOneChatParams extends FindOneParams<ChatEntity> {
  final int id;
  const FindOneChatParams(this.id);

  @override
  String get query {
    return 'SELECT * FROM chats WHERE id = ?';
  }

  @override
  List<Object?> get values {
    return [id];
  }
}

class FindManyChatsParams extends FindManyParams<ChatEntity> {
  final Where? where;
  const FindManyChatsParams([this.where]);

  @override
  String get query => switch (where != null) {
    true => 'SELECT * FROM chats WHERE ${where?.query}',
    _ => 'SELECT * FROM chats;',
  };

  @override
  List<Object?> get values => where?.values ?? [];
}

class UpdateOneChatParams extends UpdateOneParams<ChatEntity> {
  final int id;
  final String? name;
  final String? image;
  final String? type;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const UpdateOneChatParams(
    this.id, {
    this.name,
    this.image,
    this.type,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> _map() => <String, dynamic>{
    if (name != null) 'name': name,
    if (image != null) 'image': image,
    if (type != null) 'type': type,
    if (createdAt != null) 'created_at': createdAt,
    if (updatedAt != null) 'updated_at': updatedAt,
  };

  @override
  String get query {
    if (_map().isEmpty) {
      throw Exception('no_fields_to_update');
    }

    return 'UPDATE chats SET ${_map().entries.map((e) => '${e.key} = ?').join(', ')} WHERE id = ? RETURNING *;';
  }

  @override
  List<Object?> get values {
    if (_map().isEmpty) {
      throw Exception('no_fields_to_update');
    }

    return [..._map().values, id];
  }
}

class DeleteOneChatParams extends DeleteOneParams<ChatEntity> {
  final int id;
  const DeleteOneChatParams(this.id);

  @override
  String get query {
    return 'DELETE FROM chats WHERE id = ?';
  }

  @override
  List<Object?> get values {
    return [id];
  }
}

class CommentsRepository extends CrudRepository<CommentEntity> {
  final Database db;
  const CommentsRepository(this.db);

  @override
  AsyncResult<CommentEntity> insertOne(
    InsertOneParams<CommentEntity> params,
  ) async {
    try {
      final stmt = db.prepare(params.query);

      final result = stmt.select(params.values);

      if (result.isEmpty) {
        throw NotFoundSqlException('fail_to_insert_on_comment');
      }

      final row = result.first;

      final entity = CommentEntity(
        id: row['id'] ?? 0,
        content: row['content'] ?? '',
        userId: row['user_id'] ?? 0,
        postId: row['post_id'] ?? 0,
        createdAt: DateTime.tryParse(row['created_at']) ?? DateTime.now(),
        updatedAt: DateTime.tryParse(row['updated_at']) ?? DateTime.now(),
      );

      return Success(entity);
    } on SqlException catch (e) {
      return Error(e);
    } on Exception catch (e, s) {
      return Error(UnknownSqlException('fail_to_insert_on_comment', s));
    }
  }

  @override
  AsyncResult<CommentEntity> findOne(
    FindOneParams<CommentEntity> params,
  ) async {
    try {
      final stmt = db.prepare(params.query);

      final result = stmt.select(params.values);

      if (result.isEmpty) {
        throw NotFoundSqlException('comment_not_found');
      }

      final row = result.first;

      final entity = CommentEntity(
        id: row['id'] ?? 0,
        content: row['content'] ?? '',
        userId: row['user_id'] ?? 0,
        postId: row['post_id'] ?? 0,
        createdAt: DateTime.tryParse(row['created_at']) ?? DateTime.now(),
        updatedAt: DateTime.tryParse(row['updated_at']) ?? DateTime.now(),
      );

      return Success(entity);
    } on SqlException catch (e) {
      return Error(e);
    } on Exception catch (e, s) {
      return Error(UnknownSqlException('fail_to_insert_on_comment', s));
    }
  }

  @override
  AsyncResult<List<CommentEntity>> findMany(
    FindManyParams<CommentEntity> params,
  ) async {
    try {
      final stmt = db.prepare(params.query);

      final result = stmt.select(params.values);

      final entities = result.map((row) {
        return CommentEntity(
          id: row['id'] ?? 0,
          content: row['content'] ?? '',
          userId: row['user_id'] ?? 0,
          postId: row['post_id'] ?? 0,
          createdAt: DateTime.tryParse(row['created_at']) ?? DateTime.now(),
          updatedAt: DateTime.tryParse(row['updated_at']) ?? DateTime.now(),
        );
      }).toList();

      return Success(entities);
    } on Exception catch (e, s) {
      return Error(UnknownSqlException('fail_to_get_comments', s));
    }
  }

  @override
  AsyncResult<CommentEntity> updateOne(
    UpdateOneParams<CommentEntity> params,
  ) async {
    try {
      final stmt = db.prepare(params.query);

      final result = stmt.select(params.values);

      if (result.isEmpty) {
        throw NotFoundSqlException('comment_not_found');
      }

      final row = result.first;

      final entity = CommentEntity(
        id: row['id'] ?? 0,
        content: row['content'] ?? '',
        userId: row['user_id'] ?? 0,
        postId: row['post_id'] ?? 0,
        createdAt: DateTime.tryParse(row['created_at']) ?? DateTime.now(),
        updatedAt: DateTime.tryParse(row['updated_at']) ?? DateTime.now(),
      );

      return Success(entity);
    } on SqlException catch (e) {
      return Error(e);
    } on Exception catch (e, s) {
      return Error(UnknownSqlException('fail_to_update_comment', s));
    }
  }

  @override
  AsyncResult<CommentEntity> deleteOne(
    DeleteOneParams<CommentEntity> params,
  ) async {
    try {
      final stmt = db.prepare(params.query);

      final result = stmt.select(params.values);

      if (result.isEmpty) {
        throw NotFoundSqlException('comment_not_found');
      }

      final row = result.first;

      final entity = CommentEntity(
        id: row['id'] ?? 0,
        content: row['content'] ?? '',
        userId: row['user_id'] ?? 0,
        postId: row['post_id'] ?? 0,
        createdAt: DateTime.tryParse(row['created_at']) ?? DateTime.now(),
        updatedAt: DateTime.tryParse(row['updated_at']) ?? DateTime.now(),
      );

      return Success(entity);
    } on SqlException catch (e) {
      return Error(e);
    } on Exception catch (e, s) {
      return Error(UnknownSqlException('fail_to_delete_comment', s));
    }
  }
}

class InsertOneCommentParams extends InsertOneParams<CommentEntity> {
  final int? id;
  final String content;
  final int userId;
  final int postId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InsertOneCommentParams({
    this.id,
    required this.content,
    required this.userId,
    required this.postId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> _map() => <String, dynamic>{
    if (id != null) 'id': id,
    'content': content,
    'user_id': userId,
    'post_id': postId,
    if (createdAt != null) 'created_at': createdAt,
    if (updatedAt != null) 'updated_at': updatedAt,
  };

  @override
  String get query =>
      'INSERT INTO comments (${_map().keys.map((k) => k).join(', ')}) VALUES (${_map().keys.map((_) => '?').join(', ')}) RETURNING *;';

  @override
  List<Object?> get values {
    final newMap = _map();

    for (final key in _map().keys) {
      if (_map()[key] is DateTime) {
        newMap[key] = (_map()[key] as DateTime).toIso8601String();
      }
    }

    return newMap.values.toList();
  }
}

class FindOneCommentParams extends FindOneParams<CommentEntity> {
  final int id;
  const FindOneCommentParams(this.id);

  @override
  String get query {
    return 'SELECT * FROM comments WHERE id = ?';
  }

  @override
  List<Object?> get values {
    return [id];
  }
}

class FindManyCommentsParams extends FindManyParams<CommentEntity> {
  final Where? where;
  const FindManyCommentsParams([this.where]);

  @override
  String get query => switch (where != null) {
    true => 'SELECT * FROM comments WHERE ${where?.query}',
    _ => 'SELECT * FROM comments;',
  };

  @override
  List<Object?> get values => where?.values ?? [];
}

class UpdateOneCommentParams extends UpdateOneParams<CommentEntity> {
  final int id;
  final String? content;
  final int? userId;
  final int? postId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const UpdateOneCommentParams(
    this.id, {
    this.content,
    this.userId,
    this.postId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> _map() => <String, dynamic>{
    if (content != null) 'content': content,
    if (userId != null) 'user_id': userId,
    if (postId != null) 'post_id': postId,
    if (createdAt != null) 'created_at': createdAt,
    if (updatedAt != null) 'updated_at': updatedAt,
  };

  @override
  String get query {
    if (_map().isEmpty) {
      throw Exception('no_fields_to_update');
    }

    return 'UPDATE comments SET ${_map().entries.map((e) => '${e.key} = ?').join(', ')} WHERE id = ? RETURNING *;';
  }

  @override
  List<Object?> get values {
    if (_map().isEmpty) {
      throw Exception('no_fields_to_update');
    }

    return [..._map().values, id];
  }
}

class DeleteOneCommentParams extends DeleteOneParams<CommentEntity> {
  final int id;
  const DeleteOneCommentParams(this.id);

  @override
  String get query {
    return 'DELETE FROM comments WHERE id = ?';
  }

  @override
  List<Object?> get values {
    return [id];
  }
}

class ParticipantsRepository extends CrudRepository<ParticipantEntity> {
  final Database db;
  const ParticipantsRepository(this.db);

  @override
  AsyncResult<ParticipantEntity> insertOne(
    InsertOneParams<ParticipantEntity> params,
  ) async {
    try {
      final stmt = db.prepare(params.query);

      final result = stmt.select(params.values);

      if (result.isEmpty) {
        throw NotFoundSqlException('fail_to_insert_on_participant');
      }

      final row = result.first;

      final entity = ParticipantEntity(
        chatId: row['chat_id'] ?? 0,
        userId: row['user_id'] ?? 0,
        createdAt: DateTime.tryParse(row['created_at']) ?? DateTime.now(),
      );

      return Success(entity);
    } on SqlException catch (e) {
      return Error(e);
    } on Exception catch (e, s) {
      return Error(UnknownSqlException('fail_to_insert_on_participant', s));
    }
  }

  @override
  AsyncResult<ParticipantEntity> findOne(
    FindOneParams<ParticipantEntity> params,
  ) async {
    try {
      final stmt = db.prepare(params.query);

      final result = stmt.select(params.values);

      if (result.isEmpty) {
        throw NotFoundSqlException('participant_not_found');
      }

      final row = result.first;

      final entity = ParticipantEntity(
        chatId: row['chat_id'] ?? 0,
        userId: row['user_id'] ?? 0,
        createdAt: DateTime.tryParse(row['created_at']) ?? DateTime.now(),
      );

      return Success(entity);
    } on SqlException catch (e) {
      return Error(e);
    } on Exception catch (e, s) {
      return Error(UnknownSqlException('fail_to_insert_on_participant', s));
    }
  }

  @override
  AsyncResult<List<ParticipantEntity>> findMany(
    FindManyParams<ParticipantEntity> params,
  ) async {
    try {
      final stmt = db.prepare(params.query);

      final result = stmt.select(params.values);

      final entities = result.map((row) {
        return ParticipantEntity(
          chatId: row['chat_id'] ?? 0,
          userId: row['user_id'] ?? 0,
          createdAt: DateTime.tryParse(row['created_at']) ?? DateTime.now(),
        );
      }).toList();

      return Success(entities);
    } on Exception catch (e, s) {
      return Error(UnknownSqlException('fail_to_get_participants', s));
    }
  }

  @override
  AsyncResult<ParticipantEntity> updateOne(
    UpdateOneParams<ParticipantEntity> params,
  ) async {
    try {
      final stmt = db.prepare(params.query);

      final result = stmt.select(params.values);

      if (result.isEmpty) {
        throw NotFoundSqlException('participant_not_found');
      }

      final row = result.first;

      final entity = ParticipantEntity(
        chatId: row['chat_id'] ?? 0,
        userId: row['user_id'] ?? 0,
        createdAt: DateTime.tryParse(row['created_at']) ?? DateTime.now(),
      );

      return Success(entity);
    } on SqlException catch (e) {
      return Error(e);
    } on Exception catch (e, s) {
      return Error(UnknownSqlException('fail_to_update_participant', s));
    }
  }

  @override
  AsyncResult<ParticipantEntity> deleteOne(
    DeleteOneParams<ParticipantEntity> params,
  ) async {
    try {
      final stmt = db.prepare(params.query);

      final result = stmt.select(params.values);

      if (result.isEmpty) {
        throw NotFoundSqlException('participant_not_found');
      }

      final row = result.first;

      final entity = ParticipantEntity(
        chatId: row['chat_id'] ?? 0,
        userId: row['user_id'] ?? 0,
        createdAt: DateTime.tryParse(row['created_at']) ?? DateTime.now(),
      );

      return Success(entity);
    } on SqlException catch (e) {
      return Error(e);
    } on Exception catch (e, s) {
      return Error(UnknownSqlException('fail_to_delete_participant', s));
    }
  }
}

class InsertOneParticipantParams extends InsertOneParams<ParticipantEntity> {
  final int chatId;
  final int userId;
  final DateTime? createdAt;

  const InsertOneParticipantParams({
    required this.chatId,
    required this.userId,
    this.createdAt,
  });

  Map<String, dynamic> _map() => <String, dynamic>{
    'chat_id': chatId,
    'user_id': userId,
    if (createdAt != null) 'created_at': createdAt,
  };

  @override
  String get query =>
      'INSERT INTO participants (${_map().keys.map((k) => k).join(', ')}) VALUES (${_map().keys.map((_) => '?').join(', ')}) RETURNING *;';

  @override
  List<Object?> get values {
    final newMap = _map();

    for (final key in _map().keys) {
      if (_map()[key] is DateTime) {
        newMap[key] = (_map()[key] as DateTime).toIso8601String();
      }
    }

    return newMap.values.toList();
  }
}

class FindOneParticipantParams extends FindOneParams<ParticipantEntity> {
  final int chatId;
  final int userId;
  const FindOneParticipantParams(this.chatId, this.userId);

  @override
  String get query {
    return 'SELECT * FROM participants WHERE chat_id = ? AND user_id = ?';
  }

  @override
  List<Object?> get values {
    return [chatId, userId];
  }
}

class FindManyParticipantsParams extends FindManyParams<ParticipantEntity> {
  final Where? where;
  const FindManyParticipantsParams([this.where]);

  @override
  String get query => switch (where != null) {
    true => 'SELECT * FROM participants WHERE ${where?.query}',
    _ => 'SELECT * FROM participants;',
  };

  @override
  List<Object?> get values => where?.values ?? [];
}

class UpdateOneParticipantParams extends UpdateOneParams<ParticipantEntity> {
  final int chatId;
  final int userId;
  final DateTime? createdAt;
  const UpdateOneParticipantParams(this.chatId, this.userId, {this.createdAt});

  Map<String, dynamic> _map() => <String, dynamic>{
    if (createdAt != null) 'created_at': createdAt,
  };

  @override
  String get query {
    if (_map().isEmpty) {
      throw Exception('no_fields_to_update');
    }

    return 'UPDATE participants SET ${_map().entries.map((e) => '${e.key} = ?').join(', ')} WHERE chat_id = ? AND user_id = ? RETURNING *;';
  }

  @override
  List<Object?> get values {
    if (_map().isEmpty) {
      throw Exception('no_fields_to_update');
    }

    return [..._map().values, chatId, userId];
  }
}

class DeleteOneParticipantParams extends DeleteOneParams<ParticipantEntity> {
  final int chatId;
  final int userId;
  const DeleteOneParticipantParams(this.chatId, this.userId);

  @override
  String get query {
    return 'DELETE FROM participants WHERE chat_id = ? AND user_id = ?';
  }

  @override
  List<Object?> get values {
    return [chatId, userId];
  }
}

class PostsRepository extends CrudRepository<PostEntity> {
  final Database db;
  const PostsRepository(this.db);

  @override
  AsyncResult<PostEntity> insertOne(InsertOneParams<PostEntity> params) async {
    try {
      final stmt = db.prepare(params.query);

      final result = stmt.select(params.values);

      if (result.isEmpty) {
        throw NotFoundSqlException('fail_to_insert_on_post');
      }

      final row = result.first;

      final entity = PostEntity(
        id: row['id'] ?? 0,
        title: row['title'] ?? '',
        body: row['body'] ?? '',
        userId: row['user_id'] ?? 0,
        createdAt: DateTime.tryParse(row['created_at']) ?? DateTime.now(),
        updatedAt: DateTime.tryParse(row['updated_at']) ?? DateTime.now(),
      );

      return Success(entity);
    } on SqlException catch (e) {
      return Error(e);
    } on Exception catch (e, s) {
      return Error(UnknownSqlException('fail_to_insert_on_post', s));
    }
  }

  @override
  AsyncResult<PostEntity> findOne(FindOneParams<PostEntity> params) async {
    try {
      final stmt = db.prepare(params.query);

      final result = stmt.select(params.values);

      if (result.isEmpty) {
        throw NotFoundSqlException('post_not_found');
      }

      final row = result.first;

      final entity = PostEntity(
        id: row['id'] ?? 0,
        title: row['title'] ?? '',
        body: row['body'] ?? '',
        userId: row['user_id'] ?? 0,
        createdAt: DateTime.tryParse(row['created_at']) ?? DateTime.now(),
        updatedAt: DateTime.tryParse(row['updated_at']) ?? DateTime.now(),
      );

      return Success(entity);
    } on SqlException catch (e) {
      return Error(e);
    } on Exception catch (e, s) {
      return Error(UnknownSqlException('fail_to_insert_on_post', s));
    }
  }

  @override
  AsyncResult<List<PostEntity>> findMany(
    FindManyParams<PostEntity> params,
  ) async {
    try {
      final stmt = db.prepare(params.query);

      final result = stmt.select(params.values);

      final entities = result.map((row) {
        return PostEntity(
          id: row['id'] ?? 0,
          title: row['title'] ?? '',
          body: row['body'] ?? '',
          userId: row['user_id'] ?? 0,
          createdAt: DateTime.tryParse(row['created_at']) ?? DateTime.now(),
          updatedAt: DateTime.tryParse(row['updated_at']) ?? DateTime.now(),
        );
      }).toList();

      return Success(entities);
    } on Exception catch (e, s) {
      return Error(UnknownSqlException('fail_to_get_posts', s));
    }
  }

  @override
  AsyncResult<PostEntity> updateOne(UpdateOneParams<PostEntity> params) async {
    try {
      final stmt = db.prepare(params.query);

      final result = stmt.select(params.values);

      if (result.isEmpty) {
        throw NotFoundSqlException('post_not_found');
      }

      final row = result.first;

      final entity = PostEntity(
        id: row['id'] ?? 0,
        title: row['title'] ?? '',
        body: row['body'] ?? '',
        userId: row['user_id'] ?? 0,
        createdAt: DateTime.tryParse(row['created_at']) ?? DateTime.now(),
        updatedAt: DateTime.tryParse(row['updated_at']) ?? DateTime.now(),
      );

      return Success(entity);
    } on SqlException catch (e) {
      return Error(e);
    } on Exception catch (e, s) {
      return Error(UnknownSqlException('fail_to_update_post', s));
    }
  }

  @override
  AsyncResult<PostEntity> deleteOne(DeleteOneParams<PostEntity> params) async {
    try {
      final stmt = db.prepare(params.query);

      final result = stmt.select(params.values);

      if (result.isEmpty) {
        throw NotFoundSqlException('post_not_found');
      }

      final row = result.first;

      final entity = PostEntity(
        id: row['id'] ?? 0,
        title: row['title'] ?? '',
        body: row['body'] ?? '',
        userId: row['user_id'] ?? 0,
        createdAt: DateTime.tryParse(row['created_at']) ?? DateTime.now(),
        updatedAt: DateTime.tryParse(row['updated_at']) ?? DateTime.now(),
      );

      return Success(entity);
    } on SqlException catch (e) {
      return Error(e);
    } on Exception catch (e, s) {
      return Error(UnknownSqlException('fail_to_delete_post', s));
    }
  }
}

class InsertOnePostParams extends InsertOneParams<PostEntity> {
  final int? id;
  final String title;
  final String body;
  final int userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InsertOnePostParams({
    this.id,
    required this.title,
    required this.body,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> _map() => <String, dynamic>{
    if (id != null) 'id': id,
    'title': title,
    'body': body,
    'user_id': userId,
    if (createdAt != null) 'created_at': createdAt,
    if (updatedAt != null) 'updated_at': updatedAt,
  };

  @override
  String get query =>
      'INSERT INTO posts (${_map().keys.map((k) => k).join(', ')}) VALUES (${_map().keys.map((_) => '?').join(', ')}) RETURNING *;';

  @override
  List<Object?> get values {
    final newMap = _map();

    for (final key in _map().keys) {
      if (_map()[key] is DateTime) {
        newMap[key] = (_map()[key] as DateTime).toIso8601String();
      }
    }

    return newMap.values.toList();
  }
}

class FindOnePostParams extends FindOneParams<PostEntity> {
  final int id;
  const FindOnePostParams(this.id);

  @override
  String get query {
    return 'SELECT * FROM posts WHERE id = ?';
  }

  @override
  List<Object?> get values {
    return [id];
  }
}

class FindManyPostsParams extends FindManyParams<PostEntity> {
  final Where? where;
  const FindManyPostsParams([this.where]);

  @override
  String get query => switch (where != null) {
    true => 'SELECT * FROM posts WHERE ${where?.query}',
    _ => 'SELECT * FROM posts;',
  };

  @override
  List<Object?> get values => where?.values ?? [];
}

class UpdateOnePostParams extends UpdateOneParams<PostEntity> {
  final int id;
  final String? title;
  final String? body;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const UpdateOnePostParams(
    this.id, {
    this.title,
    this.body,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> _map() => <String, dynamic>{
    if (title != null) 'title': title,
    if (body != null) 'body': body,
    if (userId != null) 'user_id': userId,
    if (createdAt != null) 'created_at': createdAt,
    if (updatedAt != null) 'updated_at': updatedAt,
  };

  @override
  String get query {
    if (_map().isEmpty) {
      throw Exception('no_fields_to_update');
    }

    return 'UPDATE posts SET ${_map().entries.map((e) => '${e.key} = ?').join(', ')} WHERE id = ? RETURNING *;';
  }

  @override
  List<Object?> get values {
    if (_map().isEmpty) {
      throw Exception('no_fields_to_update');
    }

    return [..._map().values, id];
  }
}

class DeleteOnePostParams extends DeleteOneParams<PostEntity> {
  final int id;
  const DeleteOnePostParams(this.id);

  @override
  String get query {
    return 'DELETE FROM posts WHERE id = ?';
  }

  @override
  List<Object?> get values {
    return [id];
  }
}

class UsersRepository extends CrudRepository<UserEntity> {
  final Database db;
  const UsersRepository(this.db);

  @override
  AsyncResult<UserEntity> insertOne(InsertOneParams<UserEntity> params) async {
    try {
      final stmt = db.prepare(params.query);

      final result = stmt.select(params.values);

      if (result.isEmpty) {
        throw NotFoundSqlException('fail_to_insert_on_user');
      }

      final row = result.first;

      final entity = UserEntity(
        id: row['id'] ?? 0,
        name: row['name'] ?? '',
        username: row['username'] ?? '',
        email: row['email'] ?? '',
        password: row['password'] ?? '',
        image: row['image'] ?? '',
        createdAt: DateTime.tryParse(row['created_at']) ?? DateTime.now(),
        updatedAt: DateTime.tryParse(row['updated_at']) ?? DateTime.now(),
      );

      return Success(entity);
    } on SqlException catch (e) {
      return Error(e);
    } on Exception catch (e, s) {
      return Error(UnknownSqlException('fail_to_insert_on_user', s));
    }
  }

  @override
  AsyncResult<UserEntity> findOne(FindOneParams<UserEntity> params) async {
    try {
      final stmt = db.prepare(params.query);

      final result = stmt.select(params.values);

      if (result.isEmpty) {
        throw NotFoundSqlException('user_not_found');
      }

      final row = result.first;

      final entity = UserEntity(
        id: row['id'] ?? 0,
        name: row['name'] ?? '',
        username: row['username'] ?? '',
        email: row['email'] ?? '',
        password: row['password'] ?? '',
        image: row['image'] ?? '',
        createdAt: DateTime.tryParse(row['created_at']) ?? DateTime.now(),
        updatedAt: DateTime.tryParse(row['updated_at']) ?? DateTime.now(),
      );

      return Success(entity);
    } on SqlException catch (e) {
      return Error(e);
    } on Exception catch (e, s) {
      return Error(UnknownSqlException('fail_to_insert_on_user', s));
    }
  }

  @override
  AsyncResult<List<UserEntity>> findMany(
    FindManyParams<UserEntity> params,
  ) async {
    try {
      final stmt = db.prepare(params.query);

      final result = stmt.select(params.values);

      final entities = result.map((row) {
        return UserEntity(
          id: row['id'] ?? 0,
          name: row['name'] ?? '',
          username: row['username'] ?? '',
          email: row['email'] ?? '',
          password: row['password'] ?? '',
          image: row['image'] ?? '',
          createdAt: DateTime.tryParse(row['created_at']) ?? DateTime.now(),
          updatedAt: DateTime.tryParse(row['updated_at']) ?? DateTime.now(),
        );
      }).toList();

      return Success(entities);
    } on Exception catch (e, s) {
      return Error(UnknownSqlException('fail_to_get_users', s));
    }
  }

  @override
  AsyncResult<UserEntity> updateOne(UpdateOneParams<UserEntity> params) async {
    try {
      final stmt = db.prepare(params.query);

      final result = stmt.select(params.values);

      if (result.isEmpty) {
        throw NotFoundSqlException('user_not_found');
      }

      final row = result.first;

      final entity = UserEntity(
        id: row['id'] ?? 0,
        name: row['name'] ?? '',
        username: row['username'] ?? '',
        email: row['email'] ?? '',
        password: row['password'] ?? '',
        image: row['image'] ?? '',
        createdAt: DateTime.tryParse(row['created_at']) ?? DateTime.now(),
        updatedAt: DateTime.tryParse(row['updated_at']) ?? DateTime.now(),
      );

      return Success(entity);
    } on SqlException catch (e) {
      return Error(e);
    } on Exception catch (e, s) {
      return Error(UnknownSqlException('fail_to_update_user', s));
    }
  }

  @override
  AsyncResult<UserEntity> deleteOne(DeleteOneParams<UserEntity> params) async {
    try {
      final stmt = db.prepare(params.query);

      final result = stmt.select(params.values);

      if (result.isEmpty) {
        throw NotFoundSqlException('user_not_found');
      }

      final row = result.first;

      final entity = UserEntity(
        id: row['id'] ?? 0,
        name: row['name'] ?? '',
        username: row['username'] ?? '',
        email: row['email'] ?? '',
        password: row['password'] ?? '',
        image: row['image'] ?? '',
        createdAt: DateTime.tryParse(row['created_at']) ?? DateTime.now(),
        updatedAt: DateTime.tryParse(row['updated_at']) ?? DateTime.now(),
      );

      return Success(entity);
    } on SqlException catch (e) {
      return Error(e);
    } on Exception catch (e, s) {
      return Error(UnknownSqlException('fail_to_delete_user', s));
    }
  }
}

class InsertOneUserParams extends InsertOneParams<UserEntity> {
  final int? id;
  final String name;
  final String username;
  final String email;
  final String password;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InsertOneUserParams({
    this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> _map() => <String, dynamic>{
    if (id != null) 'id': id,
    'name': name,
    'username': username,
    'email': email,
    'password': password,
    if (image != null) 'image': image,
    if (createdAt != null) 'created_at': createdAt,
    if (updatedAt != null) 'updated_at': updatedAt,
  };

  @override
  String get query =>
      'INSERT INTO users (${_map().keys.map((k) => k).join(', ')}) VALUES (${_map().keys.map((_) => '?').join(', ')}) RETURNING *;';

  @override
  List<Object?> get values {
    final newMap = _map();

    for (final key in _map().keys) {
      if (_map()[key] is DateTime) {
        newMap[key] = (_map()[key] as DateTime).toIso8601String();
      }
    }

    return newMap.values.toList();
  }
}

class FindOneUserParams extends FindOneParams<UserEntity> {
  final int id;
  const FindOneUserParams(this.id);

  @override
  String get query {
    return 'SELECT * FROM users WHERE id = ?';
  }

  @override
  List<Object?> get values {
    return [id];
  }
}

class FindManyUsersParams extends FindManyParams<UserEntity> {
  final Where? where;
  const FindManyUsersParams([this.where]);

  @override
  String get query => switch (where != null) {
    true => 'SELECT * FROM users WHERE ${where?.query}',
    _ => 'SELECT * FROM users;',
  };

  @override
  List<Object?> get values => where?.values ?? [];
}

class UpdateOneUserParams extends UpdateOneParams<UserEntity> {
  final int id;
  final String? name;
  final String? username;
  final String? email;
  final String? password;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const UpdateOneUserParams(
    this.id, {
    this.name,
    this.username,
    this.email,
    this.password,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> _map() => <String, dynamic>{
    if (name != null) 'name': name,
    if (username != null) 'username': username,
    if (email != null) 'email': email,
    if (password != null) 'password': password,
    if (image != null) 'image': image,
    if (createdAt != null) 'created_at': createdAt,
    if (updatedAt != null) 'updated_at': updatedAt,
  };

  @override
  String get query {
    if (_map().isEmpty) {
      throw Exception('no_fields_to_update');
    }

    return 'UPDATE users SET ${_map().entries.map((e) => '${e.key} = ?').join(', ')} WHERE id = ? RETURNING *;';
  }

  @override
  List<Object?> get values {
    if (_map().isEmpty) {
      throw Exception('no_fields_to_update');
    }

    return [..._map().values, id];
  }
}

class DeleteOneUserParams extends DeleteOneParams<UserEntity> {
  final int id;
  const DeleteOneUserParams(this.id);

  @override
  String get query {
    return 'DELETE FROM users WHERE id = ?';
  }

  @override
  List<Object?> get values {
    return [id];
  }
}

class DefaultMigration extends Migration {
  const DefaultMigration() : super(1);

  @override
  Future<String> up() async {
    return '''CREATE TABLE IF NOT EXISTS chats (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT,
  image TEXT,
  type VARCHAR(24) NOT NULL CHECK (type IN ('private', 'group')),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(255) NOT NULL,
  username VARCHAR(24) NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL CHECK (password != ''),
  image TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_users_email_username UNIQUE (email, username)
);

CREATE TABLE IF NOT EXISTS comments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  content TEXT NOT NULL CHECK (content != ''),
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE ON UPDATE CASCADE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS participants (
  chat_id INTEGER NOT NULL REFERENCES chats(id) ON DELETE CASCADE ON UPDATE CASCADE,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_participants_chat_id_user_id PRIMARY KEY (chat_id, user_id)
);

CREATE TABLE IF NOT EXISTS posts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL CHECK (title != ''),
  body TEXT NOT NULL CHECK (body != ''),
  user_id INTEGER NOT NULL,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_posts_user_id FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE
);''';
  }

  @override
  Future<String> down() async {
    return '''DROP TABLE IF EXISTS posts;

DROP TABLE IF EXISTS participants;

DROP TABLE IF EXISTS comments;

DROP TABLE IF EXISTS users;

DROP TABLE IF EXISTS chats;''';
  }
}

FutureOr<Response> _defaultNotFoundHandler(Request request) async {
  return Json(404, body: {'error': 'Route not found!'});
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
