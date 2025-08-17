typedef AsyncResult<S, F> = Future<Result<S, F>>;

sealed class Result<S, F> {
  const Result();
  const factory Result.success(S success) = Success<S, F>;
  const factory Result.failure(F failure) = Failure<S, F>;
  bool get isSuccess => this is Success<S, F>;
  S get success => switch (isSuccess) {
    true => (this as Success<S, F>)._success,
    false => throw Exception('Result is not Success!'),
  };
  bool get isFailure => this is Failure<S, F>;
  F get failure => switch (isFailure) {
    true => (this as Failure<S, F>)._failure,
    false => throw Exception('Result is not Failure!'),
  };
  A fold<A>(A Function(S success) onSuccess, A Function(F failure) onFailure) {
    return switch (isSuccess) {
      true => onSuccess(success),
      false => onFailure(failure),
    };
  }
}

final class Success<S, F> extends Result<S, F> {
  final S _success;
  const Success(this._success);
}

final class Failure<S, F> extends Result<S, F> {
  final F _failure;
  const Failure(this._failure);
}
