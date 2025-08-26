import 'dart:async';

abstract class Migration {
  final int version;

  const Migration(this.version);

  FutureOr<String> up();
  FutureOr<String> down();
}
