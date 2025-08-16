import 'package:example/src/entities/user_entity.dart';
import 'package:spring_dart/spring_dart.dart';
import 'package:sqlite3/sqlite3.dart';

@Repository()
class UsersRepository {
  final Database db;

  const UsersRepository(this.db);

  Future<UserEntity> insertOne(String name, String email, String password) async {
    final statement = db.prepare('INSERT INTO users (name, email, password) VALUES (?, ?, ?) RETURNING *;');
    final result = statement.select([name, email, password]);
    return UserEntity.fromMap(result.first);
  }

  Future<UserEntity?> findOne(int id) async {
    final statement = db.prepare('SELECT * FROM users WHERE id = ?;');
    final result = statement.select([id]);
    if (result.isEmpty) return null;
    return UserEntity.fromMap(result.first);
  }

  Future<UserEntity?> findOneByEmail(String email) async {
    final statement = db.prepare('SELECT * FROM users WHERE email = ?;');
    final result = statement.select([email]);
    if (result.isEmpty) return null;
    return UserEntity.fromMap(result.first);
  }
}
