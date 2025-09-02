class Validators {
  const Validators._();

  static bool isEmail(String value) {
    return RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value);
  }

  static bool isNotEmpty(Object? value) {
    if (value == null) return false;
    if (value is String) return value.isNotEmpty;
    if (value is List) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    if (value is Set) return value.isNotEmpty;
    if (value is Iterable) return value.isNotEmpty;
    return false;
  }

  static bool isLessThan(int value, int compare) {
    return value < compare;
  }

  static bool isLessThanOrEqual(int value, int compare) {
    return value <= compare;
  }

  static bool isGreaterThan(int value, int compare) {
    return value > compare;
  }

  static bool isGreaterThanOrEqual(Object value, int compare) {
    if (value is String) return value.length >= compare;
    if (value is List) return value.length >= compare;
    if (value is Set) return value.length >= compare;
    if (value is Iterable) return value.length >= compare;
    if (value is Map) return value.length >= compare;
    if (value is num) return value >= compare;
    return false;
  }

  static bool isBetween(int value, int min, int max) {
    return value >= min && value <= max;
  }

  static bool patternMatches(String value, String pattern) {
    return RegExp(pattern).hasMatch(value);
  }
}
