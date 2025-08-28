sealed class ParamParser<A, B> {
  const ParamParser();
  B? encode(A? value);
  A? decode(B? value);
}

abstract class StringParser<T> extends ParamParser<T, String> {
  const StringParser();
}

abstract class IntParser<T> extends ParamParser<T, int> {
  const IntParser();
}

abstract class DoubleParser<T> extends ParamParser<T, double> {
  const DoubleParser();
}

abstract class BoolParser<T> extends ParamParser<T, bool> {
  const BoolParser();
}
