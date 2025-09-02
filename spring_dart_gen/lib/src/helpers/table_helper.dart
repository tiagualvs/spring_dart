import 'package:spring_dart_sql/spring_dart_sql.dart';

class TableHelper {
  final Driver driver;
  final Set<String> imports;
  final Set<String> repositories;
  final Set<({String name, String up, String down, Set<String> references})> tables;

  const TableHelper(this.driver, this.imports, this.repositories, this.tables);

  String content() {
    if (driver is NoneDriver || tables.isEmpty) return '';

    final listTables = tables.toList()
      ..sort((a, b) {
        if (a.references.contains(b.name)) {
          return 1;
        } else {
          return -1;
        }
      });

    return '''class DefaultMigration extends Migration {
    const DefaultMigration() : super(1);

  @override
  Future<String> up() async {
    return \'\'\'${listTables.map((t) => t.up).join('\n\n')}\'\'\';
  }

  @override
  Future<String> down() async {
    return \'\'\'${listTables.reversed.map((t) => t.down).join('\n\n')}\'\'\';
  }
}''';
  }
}
