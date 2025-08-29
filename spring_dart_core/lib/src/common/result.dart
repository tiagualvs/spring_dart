typedef AsyncResult<T> = Future<Result<T>>;

sealed class Result<T> {
  const Result._();

  bool get isSuccess => this is Success<T>;

  T get success => switch (this) {
    Success<T> s => s._succes,
    Error<T> _ => throw Exception('Result is not success'),
  };

  bool get isError => this is Error<T>;

  Exception get error => switch (this) {
    Success<T> _ => throw Exception('Result is not error'),
    Error<T> e => e._error,
  };

  S fold<S>(
    S Function(T success) onSuccess,
    S Function(Exception error) onError,
  ) {
    return switch (this) {
      Success<T> s => onSuccess(s._succes),
      Error<T> e => onError(e._error),
    };
  }
}

final class Success<T> extends Result<T> {
  final T _succes;
  const Success(this._succes) : super._();
}

final class Error<T> extends Result<T> {
  final Exception _error;
  const Error(this._error) : super._();
}
