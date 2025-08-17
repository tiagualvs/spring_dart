import 'dart:io';

import '../../spring_dart_core.dart';

typedef ToEncodable = Object? Function(Object? obj);

class SpringDart {
  final Handler handler;

  const SpringDart(this.handler);

  Future<HttpServer> start({Object host = '0.0.0.0', int port = 8080}) async {
    return await serve(handler, host, port);
  }
}

abstract class SpringDartConfiguration {
  /// Setups and starts [SpringDart]
  Future<void> setup(SpringDart spring) {
    return spring.start();
  }

  /// Defines the global [Middleware] for [SpringDart]
  List<Middleware> get middlewares => [logRequests()];

  /// Defines the default [ToEncodable] function for [SpringDart]
  ToEncodable? get toEncodable => null;

  static SpringDartConfiguration get defaultConfiguration => _DefaultSpringDartConfiguration();
}

class _DefaultSpringDartConfiguration extends SpringDartConfiguration {}
