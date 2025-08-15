abstract class ParamParser<T extends Object?> {
  String? encode(T? value);
  T? decode(String? value);
}
