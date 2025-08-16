import 'package:spring_dart/spring_dart.dart';

@Configuration()
class ServerConfiguration extends SpringDartConfiguration {
  @override
  Future<void> setup(SpringDart spring) async {
    final server = await spring.start(port: 3001);
    print('Server started at http://${server.address.host}:${server.port}');
  }

  @override
  List<Middleware> get middlewares => [logRequests()];
}
