import 'data_type.dart';

/// `@Entity`
class Entity {
  const Entity();
}

/// `@Table`
class Table {
  final String name;
  const Table(this.name);
}

/// `@Id`
class Id {
  const Id();
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

/// `@Default`
class Default {
  const Default();
}
