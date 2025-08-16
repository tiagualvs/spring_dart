import 'dart:io';

import 'package:spring_dart/spring_dart.dart';

@Configuration()
class ServerConfiguration extends SpringDartConfiguration {
  @override
  Future<HttpServer> setup(Next next) async {
    final server = await next(port: 3001);
    print('Server started at http://${server.address.host}:${server.port}');
    return server;
  }
}
