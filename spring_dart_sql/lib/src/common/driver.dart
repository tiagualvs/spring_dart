sealed class Driver {
  const Driver();

  factory Driver.fromConfig(Map<String, dynamic> config) {
    if (!config.containsKey('spring_dart_sql')) return NoneDriver();
    final data = Map<String, dynamic>.from(config['spring_dart_sql']);
    return switch (data['driver']) {
      'sqlite' when data['database'] == 'memory' => SqliteMemoryDriver(),
      'sqlite' when (data['database'] as String?)?.endsWith('.db') ?? false => SqliteFileDriver(data['database']),
      'postgres' => PostgresDriver(
        port: data['port'],
        host: data['host'],
        database: data['database'],
        username: data['username'],
        password: data['password'],
        useSsl: data['use_ssl'],
      ),
      _ => NoneDriver(),
    };
  }

  bool get isSqlite => this is SqliteFileDriver || this is SqliteMemoryDriver;
  bool get isPostgres => this is PostgresDriver;
  bool get isNone => this is NoneDriver;
}

final class NoneDriver extends Driver {
  const NoneDriver();
}

final class SqliteFileDriver extends Driver {
  final String path;
  const SqliteFileDriver(this.path);
}

final class SqliteMemoryDriver extends Driver {
  const SqliteMemoryDriver();
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
  });
}
