class Validators {
  const Validators._();

  static bool isEmail(String value) {
    return RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value);
  }

  static bool isNotNull(Object? value) {
    return value != null;
  }

  static bool isNotEmpty(Object? value) {
    if (value is String) return value.isNotEmpty;
    if (value is List) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    if (value is Set) return value.isNotEmpty;
    if (value is Iterable) return value.isNotEmpty;
    return false;
  }

  static bool isLessThan(Object? value, int compare) {
    if (value is String) return value.length < compare;
    if (value is List) return value.length < compare;
    if (value is Set) return value.length < compare;
    if (value is Iterable) return value.length < compare;
    if (value is Map) return value.length < compare;
    return false;
  }

  static bool isLessThanOrEqual(Object? value, int compare) {
    if (value is String) return value.length <= compare;
    if (value is List) return value.length <= compare;
    if (value is Set) return value.length <= compare;
    if (value is Iterable) return value.length <= compare;
    if (value is Map) return value.length <= compare;
    return false;
  }

  static bool isGreaterThan(Object? value, int compare) {
    if (value is String) return value.length > compare;
    if (value is List) return value.length > compare;
    if (value is Set) return value.length > compare;
    if (value is Iterable) return value.length > compare;
    if (value is Map) return value.length > compare;
    if (value is num) return value > compare;
    return false;
  }

  static bool isGreaterThanOrEqual(Object? value, int compare) {
    if (value is String) return value.length >= compare;
    if (value is List) return value.length >= compare;
    if (value is Set) return value.length >= compare;
    if (value is Iterable) return value.length >= compare;
    if (value is Map) return value.length >= compare;
    if (value is num) return value >= compare;
    return false;
  }

  static bool isBetween(Object? value, int min, int max) {
    if (value is String) return value.length >= min && value.length <= max;
    if (value is List) return value.length >= min && value.length <= max;
    if (value is Set) return value.length >= min && value.length <= max;
    if (value is Iterable) return value.length >= min && value.length <= max;
    if (value is Map) return value.length >= min && value.length <= max;
    if (value is num) return value >= min && value <= max;
    return false;
  }

  static bool patternMatches(String value, String pattern) {
    return RegExp(pattern).hasMatch(value);
  }
}
