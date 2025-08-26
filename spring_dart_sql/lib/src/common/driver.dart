enum DDL {
  /// Always create the schema (dropping them first if they already exist).
  create,

  /// Create the schema and drop when done.
  createDrop,

  /// Update the schema if necessary.
  update,

  /// Validate the schema.
  validate,

  /// No DDL.
  none;

  const DDL();

  static DDL fromString(String? value) {
    return switch (value) {
      'create' => DDL.create,
      'create-drop' => DDL.createDrop,
      'update' => DDL.update,
      'validate' => DDL.validate,
      _ => DDL.none,
    };
  }
}

sealed class Driver {
  final DDL ddl;
  final String import;
  final String className;
  final String varName;
  const Driver({
    this.ddl = DDL.none,
    required this.import,
    required this.className,
    required this.varName,
  });

  factory Driver.fromConfig(Map<String, dynamic> config) {
    final databaseURL = config['database_url'] as String? ?? '';
    final ddl = DDL.fromString(config['ddl-auto'] as String?);
    if (databaseURL.isEmpty) return NoneDriver(ddl: ddl);
    final uri = Uri.parse(databaseURL);
    return switch (uri.scheme) {
      'sqlite' when uri.host == 'memory' => SqliteMemoryDriver(ddl: ddl),
      'sqlite' when uri.host.endsWith('.db') => SqliteFileDriver(path: uri.host, ddl: ddl),
      _ => NoneDriver(ddl: ddl),
    };
  }

  /// Driver is Sqlite
  bool get sqlite => this is SqliteFileDriver || this is SqliteMemoryDriver;

  /// Driver is Postgres
  bool get postgres => this is PostgresDriver;

  /// Driver is None
  bool get none => this is NoneDriver;
}

final class NoneDriver extends Driver {
  const NoneDriver({super.ddl}) : super(import: '', className: '', varName: '');
}

final class SqliteFileDriver extends Driver {
  final String path;
  const SqliteFileDriver({required this.path, super.ddl})
    : super(import: 'package:sqlite3/sqlite3.dart', className: 'Database', varName: 'db');
}

final class SqliteMemoryDriver extends Driver {
  const SqliteMemoryDriver({super.ddl})
    : super(import: 'package:sqlite3/sqlite3.dart', className: 'Database', varName: 'db');
}

final class PostgresDriver extends Driver {
  final int port;
  final String host;
  final String database;
  final String? username;
  final String? password;
  final bool useSsl;
  const PostgresDriver({
    this.port = 5432,
    required this.host,
    required this.database,
    this.username,
    this.password,
    this.useSsl = false,
    super.ddl,
  }) : super(import: 'package:postgres/postgres.dart', className: 'Connection', varName: 'conn');
}
