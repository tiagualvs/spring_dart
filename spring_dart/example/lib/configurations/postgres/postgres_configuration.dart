import 'package:postgres/postgres.dart';
import 'package:spring_dart/spring_dart.dart';

// @Configuration()
class PostgresConfiguration {
  @Bean()
  Future<Connection> connection() async {
    return Connection.open(
      Endpoint(host: 'localhost', port: 5432, database: 'postgres'),
    );
  }
}
