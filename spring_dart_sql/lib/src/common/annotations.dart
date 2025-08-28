import 'data_type.dart';
import 'operators.dart';

/// `@Entity`
class Entity {
  const Entity();
}

/// `@Table`
class Table {
  final String name;
  const Table(this.name);
}

/// `@PrimaryKey`
class PrimaryKey {
  const PrimaryKey();
}

/// `@Column`
class Column {
  final String name;
  final DataType? type;
  const Column(this.name, [this.type]);
}

/// `@GeneratedValue`
class GeneratedValue {
  const GeneratedValue();
}

/// `@Unique`
class Unique {
  const Unique();
}

/// `@Nullable`
class Nullable {
  const Nullable();
}

/// `@Check`
class Check {
  final Operator operator;
  final Object condition;
  const Check(this.operator, this.condition);
  const Check.any(List<Object> values) : operator = const In(), condition = values;
  const Check.gt(Object value) : operator = const Gt(), condition = value;
  const Check.gte(Object value) : operator = const Gte(), condition = value;
  const Check.lt(Object value) : operator = const Lt(), condition = value;
  const Check.lte(Object value) : operator = const Lte(), condition = value;
  const Check.isNotNull(Object value) : operator = const IsNotNull(), condition = value;
  const Check.isNull(Object value) : operator = const IsNull(), condition = value;
  const Check.isNotEmpty() : operator = const Neq(), condition = '';
}

/// `@Default`
class Default {
  final DefaultValue value;
  const Default(this.value);
}

/// `@DefaultValue`
sealed class DefaultValue {
  const DefaultValue();
}

/// `@DefaultFunction`
final class DefaultFunction extends DefaultValue {
  final String value;
  const DefaultFunction(this.value);
  const DefaultFunction.now() : value = 'NOW()';
  const DefaultFunction.currentTimestamp() : value = 'CURRENT_TIMESTAMP';
  const DefaultFunction.uuidGenerateV(int version) : value = 'uuid_generate_v$version()';
  const DefaultFunction.genRandomUuid() : value = 'gen_random_uuid()';
}

const NOW = DefaultFunction.now();
const CURRENT_TIMESTAMP = DefaultFunction.currentTimestamp();
const UUID_GENERATE_V1 = DefaultFunction.uuidGenerateV(1);
const UUID_GENERATE_V4 = DefaultFunction.uuidGenerateV(4);
const GEN_RANDOM_UUID = DefaultFunction.genRandomUuid();

/// `@DefaultObject`
final class DefaultObject extends DefaultValue {
  final Object? value;
  const DefaultObject(this.value);
}

/// `@References`
class References {
  final String table;
  final String column;
  final Action onDelete;
  final Action onUpdate;
  const References(this.table, this.column, {this.onDelete = CASCADE, this.onUpdate = CASCADE});
}

/// `@Action`
class Action {
  final String value;
  const Action._(this.value);
}

const CASCADE = Action._('CASCADE');
const RESTRICT = Action._('RESTRICT');
const SET_NULL = Action._('SET NULL');
const SET_DEFAULT = Action._('SET DEFAULT');
const NO_ACTION = Action._('NO ACTION');

sealed class Constraint {
  const Constraint();
}

final class PrimaryKeyConstraint extends Constraint {
  final List<String> columns;
  const PrimaryKeyConstraint(this.columns);
}

final class ForeignKeyConstraint extends Constraint {
  final List<String> fromColumns;
  final String toTable;
  final List<String> toColumns;
  final Action onDelete;
  final Action onUpdate;
  const ForeignKeyConstraint(
    this.fromColumns,
    this.toTable,
    this.toColumns, {
    this.onDelete = CASCADE,
    this.onUpdate = CASCADE,
  });
}

final class UniqueConstraint extends Constraint {
  final List<String> columns;
  const UniqueConstraint(this.columns);
}
