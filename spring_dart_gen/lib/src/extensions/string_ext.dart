import 'package:strings/strings.dart' as s;

extension StringExt on String {
  String toCamelCase() {
    return s.Strings.toCamelCase(s.Strings.toSnakeCase(this), lower: true);
  }

  String toPascalCase() {
    return s.Strings.toCamelCase(s.Strings.toSnakeCase(this));
  }

  String toSnakeCase() {
    return s.Strings.toSnakeCase(this);
  }
}
