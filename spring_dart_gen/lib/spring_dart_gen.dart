library;

import 'package:build/build.dart';

import 'src/server_builder.dart';
import 'src/spring_dart_builder.dart';

Builder springDartBuilder(BuilderOptions options) {
  return SpringDartBuilder();
}

Builder serverBuilder(BuilderOptions options) {
  return ServerBuilder();
}
