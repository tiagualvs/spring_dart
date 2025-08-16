import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

class SpringDart {
  final Handler handler;

  const SpringDart(this.handler);

  Future<HttpServer> start({Object host = '0.0.0.0', int port = 8080}) async {
    return await serve(handler, host, port);
  }
}

abstract class SpringDartConfiguration {
  Future<void> setup(SpringDart spring) {
    return spring.start();
  }

  List<Middleware> get middlewares => [logRequests()];

  static SpringDartConfiguration get defaultConfiguration => _DefaultSpringDartConfiguration();
}

class _DefaultSpringDartConfiguration extends SpringDartConfiguration {}
