import 'package:example/src/entities/credentials_entity.dart';
import 'package:example/src/entities/user_entity.dart';
import 'package:spring_dart/spring_dart.dart';

@Configuration()
class ServerConfiguration extends SpringDartConfiguration {
  @override
  Future<void> setup(SpringDart spring) async {
    final server = await spring.start();
    print('Server started on port http://localhost:${server.port}');
  }

  @override
  ToEncodable? get toEncodable => (Object? obj) {
    if (obj is UserEntity) return obj.toMap();
    if (obj is CredentialsEntity) return obj.toMap();
    if (obj is DateTime) return obj.toIso8601String();
    return obj.toString();
  };
}
