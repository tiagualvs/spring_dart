typedef AsyncResult<T> = Future<Result<T>>;

sealed class Result<T> {
  const Result();
  const factory Result.value(T value) = Value<T>;
  const factory Result.error(Exception error) = Error<T>;
  bool hasValue() => this is Value<T>;
  T get value => switch (hasValue()) {
    true => (this as Value<T>)._value,
    false => throw Exception('Result has no value!'),
  };
  bool hasError() => this is Error<T>;
  Exception get error => switch (hasError()) {
    true => (this as Error<T>)._error,
    false => throw Exception('Result has no error!'),
  };
  S fold<S>(S Function(T value) onValue, S Function(Exception error) onError) {
    return switch (hasValue()) {
      true => onValue(value),
      false => onError(error),
    };
  }
}

final class Value<T> extends Result<T> {
  final T _value;
  const Value(this._value);
}

final class Error<T> extends Result<T> {
  final Exception _error;
  const Error(this._error);
}
