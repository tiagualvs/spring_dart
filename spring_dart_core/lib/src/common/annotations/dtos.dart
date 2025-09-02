part of 'annotations.dart';

/// `@Dto`
class Dto {
  const Dto();
}

sealed class Validator {
  final String message;
  final String code;
  const Validator(this.message, this.code);
}

/// `@Email`
final class Email extends Validator {
  const Email({String? message}) : super(message ?? 'Email is not valid!', 'invalid_email');
}

/// `@NotBlank`
final class NotEmpty extends Validator {
  const NotEmpty({String? message}) : super(message ?? 'Field is empty!', 'empty_field');
}

/// `@NotNull`
final class NotNull extends Validator {
  const NotNull({String? message}) : super(message ?? 'Field is null!', 'null_field');
}

/// `@Size`
final class Size extends Validator {
  final int min;
  final int max;
  const Size(this.min, this.max, {String? message}) : super(message ?? 'Field size is invalid!', 'size_field');
}

/// `@Pattern`
final class Pattern extends Validator {
  final String regexp;
  const Pattern(this.regexp, {String? message}) : super(message ?? 'Field is not valid!', 'pattern_field');
}

/// `@Greater`
final class GreaterThan extends Validator {
  final int value;
  const GreaterThan(this.value, {String? message}) : super(message ?? 'Field less or equal $value!', 'greater_field');
}

/// `@GreaterThanOrEqual`
final class GreaterThanOrEqual extends Validator {
  final int value;
  const GreaterThanOrEqual(this.value, {String? message})
    : super(message ?? 'Field less than $value!', 'greater_equal_field');
}

/// `@LessThan`
final class LessThan extends Validator {
  final int value;
  const LessThan(this.value, {String? message}) : super(message ?? 'Field greater or equal $value!', 'less_field');
}

/// `@LessThanOrEqual`
final class LessThanOrEqual extends Validator {
  final int value;
  const LessThanOrEqual(this.value, {String? message})
    : super(message ?? 'Field greater than $value!', 'less_equal_field');
}

/// `@Min`
final class Min extends Validator {
  final int value;
  const Min(this.value, {String? message}) : super(message ?? 'Field less than $value!', 'min_field');
}

/// `@Max`
final class Max extends Validator {
  final int value;
  const Max(this.value, {String? message}) : super(message ?? 'Field greater than $value!', 'max_field');
}

/// `@Validated`
class Validated {
  const Validated();
}

/// `@JsonKey`
class JsonKey {
  final String name;
  const JsonKey(this.name);
}

/// `@WithParser`
class WithParser {
  final Type parser;
  const WithParser(this.parser);
}
