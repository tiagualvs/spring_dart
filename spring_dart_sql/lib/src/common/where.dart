import 'operators.dart';

class Where {
  final String column;
  final Operator operator;
  final dynamic value;
  const Where(this.column, this.operator, this.value);

  String get query => switch (this) {
    And a => a.conditions.map((w) => w.query).join(' AND '),
    Or o => o.conditions.map((w) => w.query).join(' OR '),
    Where w => '${w.column} ${w.operator.value} ?',
  };

  List<dynamic> get values => switch (this) {
    And a => a.conditions.expand((w) => w.values).toList(),
    Or o => o.conditions.expand((w) => w.values).toList(),
    Where w => [w.value],
  };
}

class And extends Where {
  final List<Where> conditions;
  const And(this.conditions) : super('', const Eq(), '');
}

class Or extends Where {
  final List<Where> conditions;
  const Or(this.conditions) : super('', const Eq(), '');
}
