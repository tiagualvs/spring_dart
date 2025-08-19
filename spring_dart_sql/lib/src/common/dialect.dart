enum Dialect {
  postgres,
  mysql,
  sqlite;

  const Dialect();

  static Dialect? fromString(String? dialect) {
    return switch (dialect) {
      'postgres' => Dialect.postgres,
      'mysql' => Dialect.mysql,
      'sqlite' => Dialect.sqlite,
      _ => null,
    };
  }
}
