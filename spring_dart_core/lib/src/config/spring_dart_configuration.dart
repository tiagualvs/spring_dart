import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

class Next {
  final Handler handler;

  const Next(this.handler);

  Future<HttpServer> call({Object host = '0.0.0.0', int port = 8080}) async {
    return await serve(handler, host, port);
  }
}

abstract class SpringDartConfiguration {
  Future<HttpServer> setup(Next next) {
    return next();
  }
}
