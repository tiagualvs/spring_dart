import 'dart:io';

import 'package:spring_dart_core/spring_dart_core.dart';

typedef ToEncodable = Object? Function(Object? obj);

class SpringDart {
  final Handler handler;
  final Injector injector;

  const SpringDart(this.handler, this.injector);

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
