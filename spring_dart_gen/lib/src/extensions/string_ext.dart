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

  String removeSuffixes(List<String> suffixes) {
    for (final suffix in suffixes) {
      if (endsWith(suffix)) {
        return substring(0, length - suffix.length);
      }
    }
    return this;
  }
}
