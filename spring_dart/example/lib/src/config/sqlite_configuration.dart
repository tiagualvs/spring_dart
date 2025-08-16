import 'package:spring_dart/spring_dart.dart';
import 'package:sqlite3/sqlite3.dart';

@Configuration()
class SqliteConfiguration {
  @Bean()
  Future<Database> database() async {
    final database = sqlite3.open('database.db');

    database.execute('''CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );''');

    return database;
  }
}
