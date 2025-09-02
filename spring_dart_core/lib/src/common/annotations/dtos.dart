part of 'annotations.dart';

/// `@Dto`
class Dto {
  const Dto();
}

/// `@Validator`
sealed class Validator {
  final String message;
  final String code;
  const Validator(this.message, this.code);
}

/// `@Email`
final class Email extends Validator {
  const Email({String? message}) : super(message ?? 'Email is not valid!', 'email_validator');
}

/// `@NotBlank`
final class NotEmpty extends Validator {
  const NotEmpty({String? message}) : super(message ?? 'Field is empty!', 'not_empty_validator');
}

/// `@NotNull`
final class NotNull extends Validator {
  const NotNull({String? message}) : super(message ?? 'Field is null!', 'not_null_validator');
}

/// `@Size`
final class Size extends Validator {
  final int min;
  final int max;
  const Size(this.min, this.max, {String? message}) : super(message ?? 'Field size is invalid!', 'size_validator');
}

/// `@Pattern`
final class Pattern extends Validator {
  final String regexp;
  const Pattern(this.regexp, {String? message}) : super(message ?? 'Field is not valid!', 'pattern_validator');
}

/// `@Greater`
final class GreaterThan extends Validator {
  final int value;
  const GreaterThan(this.value, {String? message})
    : super(message ?? 'Field less or equal $value!', 'greater_than_validator');
}

/// `@GreaterThanOrEqual`
final class GreaterThanOrEqual extends Validator {
  final int value;
  const GreaterThanOrEqual(this.value, {String? message})
    : super(message ?? 'Field less than $value!', 'greater_than_or_equal_validator');
}

/// `@LessThan`
final class LessThan extends Validator {
  final int value;
  const LessThan(this.value, {String? message})
    : super(message ?? 'Field greater or equal $value!', 'less_than_validator');
}

/// `@LessThanOrEqual`
final class LessThanOrEqual extends Validator {
  final int value;
  const LessThanOrEqual(this.value, {String? message})
    : super(message ?? 'Field greater than $value!', 'less_than_or_equal_validator');
}

/// `@Min`
final class Min extends Validator {
  final int value;
  const Min(this.value, {String? message}) : super(message ?? 'Field less than $value!', 'min_validator');
}

/// `@Max`
final class Max extends Validator {
  final int value;
  const Max(this.value, {String? message}) : super(message ?? 'Field greater than $value!', 'max_validator');
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
