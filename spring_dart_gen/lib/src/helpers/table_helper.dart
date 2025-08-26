import 'package:inflection3/inflection3.dart';
import 'package:spring_dart_gen/src/extensions/string_ext.dart';
import 'package:spring_dart_sql/spring_dart_sql.dart';
import 'package:sqlite3/sqlite3.dart';

class TableHelper {
  final Driver driver;
  final Set<String> imports;
  final Set<String> repositories;
  final Set<({String name, String up, String down, Set<String> references})> tables;

  const TableHelper(this.driver, this.imports, this.repositories, this.tables);

  String content() {
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

String tableHelper(
  Driver driver,
  Set<String> imports,
  Set<String> repositories,
) {
  if (driver is NoneDriver) return '';

  if (driver is SqliteFileDriver || driver is SqliteMemoryDriver) {
    final db =
        switch (driver) {
              SqliteFileDriver d => sqlite3.open(d.path),
              SqliteMemoryDriver _ => sqlite3.openInMemory(),
              _ => null,
            }
            as Database;

    final tables = getTablesMetadata(db);

    final buffer = StringBuffer();

    for (final table in tables) {
      buffer.writeln('''abstract interface class ${table.repositoryName} {
        Future<${table.entityName}> insertOne();
        Future<${table.entityName}> findOne();
        Future<List<${table.entityName}>> findMany();
        Future<${table.entityName}> updateOne();
        Future<${table.entityName}> deleteOne();${tables.where((t) => t.fks.any((f) => f.refTable == table.name)).map((t) {
        return '''\nFuture<List<${t.entityName}>> find${t.name.toPascalCase()}ByUserId();''';
      }).join('')}
      }''');
    }

    return buffer.toString();
  } else {
    return '';
  }
}

String tableNameNormalizer(String name) {
  if (name.startsWith('tb_')) {
    return name.substring(3);
  } else if (name.startsWith('t_')) {
    return name.substring(2);
  } else {
    return name;
  }
}

List<TableMetadata> getTablesMetadata(Database db) {
  final tables = db.select('SELECT name FROM sqlite_master WHERE type="table" AND name NOT LIKE "sqlite_%"');

  final List<TableMetadata> result = [];

  for (final table in tables) {
    final tableName = table['name'] as String;

    // Colunas
    final colsResult = db.select('PRAGMA table_info($tableName)');
    final columns = colsResult.map((col) {
      return ColumnMetadata(
        name: col['name'] as String,
        type: col['type'] as String,
        notNull: (col['notnull'] as int) == 1,
        primaryKey: (col['pk'] as int) == 1,
        defaultValue: col['dflt_value']?.toString(),
      );
    }).toList();

    // Foreign Keys
    final fkResult = db.select('PRAGMA foreign_key_list($tableName)');
    final constraints = fkResult.map((fk) {
      return ConstraintMetadata(
        type: "FOREIGN KEY",
        column: fk['from'] as String,
        refTable: fk['table'] as String,
        refColumn: fk['to'] as String,
      );
    }).toList();

    result.add(
      TableMetadata(
        name: tableName,
        columns: columns,
        constraints: constraints,
      ),
    );
  }

  db.dispose();
  return result;
}

class ColumnMetadata {
  final String name;
  final String type;
  final bool notNull;
  final bool primaryKey;
  final String? defaultValue;

  ColumnMetadata({
    required this.name,
    required this.type,
    required this.notNull,
    required this.primaryKey,
    this.defaultValue,
  });

  @override
  String toString() {
    return 'Column(name: $name, type: $type, notNull: $notNull, pk: $primaryKey, default: $defaultValue)';
  }
}

class ConstraintMetadata {
  final String type; // Ex: "FOREIGN KEY"
  final String column;
  final String refTable;
  final String refColumn;

  ConstraintMetadata({
    required this.type,
    required this.column,
    required this.refTable,
    required this.refColumn,
  });

  @override
  String toString() {
    return '$type($column → $refTable.$refColumn)';
  }
}

class TableMetadata {
  final String name;
  final List<ColumnMetadata> columns;
  final List<ConstraintMetadata> constraints;

  String get repositoryName {
    final normalized = tableNameNormalizer(pluralize(name));

    return '${normalized.toPascalCase()}Repository';
  }

  String get entityName {
    final normalized = tableNameNormalizer(singularize(name));

    return '${normalized.toPascalCase()}Entity';
  }

  List<ConstraintMetadata> get fks => constraints.where((c) => c.type == 'FOREIGN KEY').toList();

  TableMetadata({
    required this.name,
    required this.columns,
    required this.constraints,
  });

  @override
  String toString() {
    final cols = columns.map((c) => "  - $c").join("\n");
    final cons = constraints.isNotEmpty ? constraints.map((c) => "  - $c").join("\n") : "  (nenhuma)";
    return '''
📌 Tabela: $name
🔹 Colunas:
$cols
🔹 Constraints:
$cons
''';
  }
}
