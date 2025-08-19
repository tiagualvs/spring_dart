library;

import 'package:build/build.dart';

import 'src/builders/server_builder.dart';

Builder serverBuilder(BuilderOptions options) {
  return ServerBuilder(options);
}
