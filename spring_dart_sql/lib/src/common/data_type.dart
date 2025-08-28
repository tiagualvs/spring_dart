sealed class DataType {
  final String value;
  const DataType(this.value);
}

final class TEXT extends DataType {
  const TEXT() : super('TEXT');
}

final class VARCHAR extends DataType {
  const VARCHAR([int len = 255]) : super('VARCHAR($len)');
}

final class INTEGER extends DataType {
  const INTEGER() : super('INTEGER');
}

final class BOOLEAN extends DataType {
  const BOOLEAN() : super('BOOLEAN');
}

final class DATETIME extends DataType {
  const DATETIME() : super('DATETIME');
}

final class DOUBLE extends DataType {
  const DOUBLE() : super('DOUBLE');
}

final class TIMESTAMP extends DataType {
  const TIMESTAMP() : super('TIMESTAMP');
}

final class BLOB extends DataType {
  const BLOB() : super('BLOB');
}

final class JSON extends DataType {
  const JSON() : super('JSON');
}

final class JSONB extends DataType {
  const JSONB() : super('JSONB');
}

final class UUID extends DataType {
  const UUID() : super('UUID');
}
