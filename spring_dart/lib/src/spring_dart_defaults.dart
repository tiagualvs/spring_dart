import 'dart:convert';

import 'package:spring_dart/spring_dart.dart' show ToEncodable;

class SpringDartDefaults {
  static final SpringDartDefaults _instance = SpringDartDefaults._();

  ToEncodable? toEncodable;

  SpringDartDefaults._();

  static SpringDartDefaults get instance => _instance;

  String? toJson(Object? obj) {
    if (obj == null) return null;
    if (obj is String) return obj;
    return json.encode(obj, toEncodable: toEncodable ?? _defaultToEncodable);
  }

  Object? _defaultToEncodable(Object? obj) => obj.toString();
}
