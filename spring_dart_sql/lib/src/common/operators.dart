sealed class Operator {
  final String value;
  const Operator(this.value);
}

final class Eq extends Operator {
  const Eq() : super('=');
}

final class Gt extends Operator {
  const Gt() : super('>');
}

final class Gte extends Operator {
  const Gte() : super('>=');
}

final class Lt extends Operator {
  const Lt() : super('<');
}

final class Lte extends Operator {
  const Lte() : super('<=');
}

final class In extends Operator {
  const In() : super('IN');
}

final class NotIn extends Operator {
  const NotIn() : super('NOT IN');
}

final class IsNull extends Operator {
  const IsNull() : super('IS NULL');
}

final class IsNotNull extends Operator {
  const IsNotNull() : super('IS NOT NULL');
}

final class StartsWith extends Operator {
  const StartsWith({bool caseSensitive = true}) : super(caseSensitive ? 'LIKE' : 'ILIKE');
}

final class EndsWith extends Operator {
  const EndsWith({bool caseSensitive = true}) : super(caseSensitive ? 'LIKE' : 'ILIKE');
}

final class Contains extends Operator {
  const Contains({bool caseSensitive = true}) : super(caseSensitive ? 'LIKE' : 'ILIKE');
}
