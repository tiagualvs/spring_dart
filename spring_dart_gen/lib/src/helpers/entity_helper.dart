import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:inflection3/inflection3.dart';
import 'package:spring_dart_gen/src/checkers.dart';
import 'package:spring_dart_gen/src/extensions/iterable_ext.dart';
import 'package:spring_dart_gen/src/extensions/string_ext.dart';
import 'package:spring_dart_sql/spring_dart_sql.dart';

class EntityHelper {
  final Set<String> imports;
  final Set<String> repositories;
  final Driver driver;
  final ClassElement element;
  final Set<({String name, String className, String content})> entities;
  final Set<({String name, String up, String down, Set<String> references})> tables;

  const EntityHelper(this.imports, this.repositories, this.driver, this.element, this.entities, this.tables);

  String content() {
    if (driver is NoneDriver) return '';

    imports.add(driver.import);

    final entityName = element.name ?? '';
    final tableName =
        tableChecker.firstAnnotationOf(element)?.getField('name')?.toStringValue() ??
        pluralize(entityName.removeSuffixes(['Entity', 'Model']).toLowerCase());
    final repositoryName = '${tableName}Repository'.toPascalCase();
    final insertOneParamClassName = 'InsertOne${singularize(tableName).toPascalCase()}Params'.toPascalCase();
    final findManyParamClassName = 'FindMany${tableName.toPascalCase()}Params'.toPascalCase();
    final findOneParamClassName = 'FindOne${singularize(tableName).toPascalCase()}Params'.toPascalCase();
    final updateOneParamClassName = 'UpdateOne${singularize(tableName).toPascalCase()}Params'.toPascalCase();
    final deleteOneParamClassName = 'DeleteOne${singularize(tableName).toPascalCase()}Params'.toPascalCase();

    final fields = element.fields.where((f) => f.name != 'hashCode' && f.name != 'runtimeType');

    imports.add('package:spring_dart_sql/spring_dart_sql.dart');

    imports.add(element.library.uri.toString());

    final driverCreate = switch (driver) {
      SqliteMemoryDriver d => <String>[
        'final db = sqlite3.openInMemory()',
        'db.execute(\'\'\'CREATE TABLE IF NOT EXISTS _migrations (version INTEGER PRIMARY KEY, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP);\'\'\')',
        ...switch (d.ddl) {
          DDL.create => [
            '// DDL AUTO CREATE - DROPPING AND RE-CREATING TABLES',
            'final migration = DefaultMigration()',
            'db.execute(await migration.down())',
            'db.execute(await migration.up())',
            'db.execute(\'DELETE FROM _migrations\')',
            'db.execute(\'INSERT INTO _migrations (version) VALUES (1)\', [migration.version])',
          ],
          _ => [],
        },
      ],
      SqliteFileDriver d => <String>[
        'final db = sqlite3.open(\'${d.path}\')',
        'db.execute(\'\'\'CREATE TABLE IF NOT EXISTS _migrations (version INTEGER PRIMARY KEY, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP);\'\'\')',
        ...switch (d.ddl) {
          DDL.create => [
            '// DDL AUTO CREATE - DROPPING AND RE-CREATING TABLES',
            'final migration = DefaultMigration()',
            'db.execute(await migration.down())',
            'db.execute(await migration.up())',
            'db.execute(\'DELETE FROM _migrations;\')',
            'db.execute(\'INSERT INTO _migrations (version) VALUES (?);\', [migration.version])',
          ],
          _ => [],
        },
      ],
      _ => <String>[],
    };

    repositories.addAll(driverCreate);

    repositories.add('injector.set<$repositoryName>(() => $repositoryName(db))');

    final constraints = constraintChecker.annotationsOf(element);

    final primaryKeyConstraint = primaryKeyConstraintChecker
        .firstAnnotationOf(element)
        ?.getField('columns')
        ?.toListValue()
        ?.map(
          (obj) => fields.firstWhere((f) {
            final columnName = columnChecker.firstAnnotationOf(f)?.getField('name')?.toStringValue() ?? f.name;
            return columnName == obj.toStringValue();
          }),
        );

    final primaryKey = [
      ...?primaryKeyConstraint,
      ?fields.firstWhereOrNull((f) => primaryKeyChecker.hasAnnotationOf(f)),
    ];

    final script = tableScript(driver, entityName, tableName, fields, constraints);

    if (script != null) {
      final (:up, :down, :references) = script;

      tables.add((name: tableName, up: up, down: down, references: references));
    }

    return '''class $repositoryName extends CrudRepository<$entityName> {
  final ${driver.className} ${driver.varName};
  const $repositoryName(this.${driver.varName});
  
  @override
  AsyncResult<$entityName> insertOne(InsertOneParams<$entityName> params) async {
    ${insertOneMethodBuilder(driver, tableName, element)}
  }

  @override
  AsyncResult<$entityName> findOne(FindOneParams<$entityName> params) async {
    ${findOneMethodBuilder(driver, tableName, element)}
  }

  @override
  AsyncResult<List<$entityName>> findMany(FindManyParams<$entityName> params) async {
    ${findManyMethodBuilder(driver, tableName, element)}
  }

  @override
  AsyncResult<$entityName> updateOne(UpdateOneParams<$entityName> params) async {
    ${updateOneMethodBuilder(driver, tableName, element)}
  }

  @override
  AsyncResult<$entityName> deleteOne(DeleteOneParams<$entityName> params) async {
    ${deleteOneMethodBuilder(driver, tableName, element)}
  }
}

${insertOneParamsBuilder(driver, entityName, tableName, insertOneParamClassName, fields)}

${findOneParamsBuilder(driver, entityName, tableName, findOneParamClassName, fields, primaryKey)}

${findManyParamsbuilder(driver, entityName, tableName, findManyParamClassName, fields)}

${updateOneParamsBuilder(driver, entityName, tableName, updateOneParamClassName, fields, primaryKey)}

${deleteOneParamsBuilder(driver, entityName, tableName, deleteOneParamClassName, primaryKey)}''';
  }
}

({String up, String down, Set<String> references})? tableScript(
  Driver driver,
  String? className,
  String? tableName,
  Iterable<FieldElement> fields,
  Iterable<DartObject> constraints,
) {
  if (driver is NoneDriver) return null;
  final referencedTables = <String>{};
  final constraintStrings = constraints
      .map((v) {
        final type = v.type;
        if (type == null) return '';
        if (foreignKeyConstraintChecker.isExactlyType(type)) {
          final fromColumns = v.getField('fromColumns')?.toListValue();
          final toTable = v.getField('toTable')?.toStringValue() ?? '';
          final toColumns = v.getField('toColumns')?.toListValue();
          final onDelete = v.getField('onDelete')?.getField('value')?.toStringValue() ?? '';
          final onUpdate = v.getField('onUpdate')?.getField('value')?.toStringValue() ?? '';

          referencedTables.add(toTable);

          return 'CONSTRAINT fk_${tableName}_${fromColumns?.map((e) => e.toStringValue()).join('_')} FOREIGN KEY (${fromColumns?.map((e) => e.toStringValue()).join(', ')}) REFERENCES $toTable (${toColumns?.map((e) => e.toStringValue()).join(', ')}) ON DELETE $onDelete ON UPDATE $onUpdate';
        } else if (primaryKeyConstraintChecker.isExactlyType(type)) {
          final columns = v.getField('columns')?.toListValue();
          return 'CONSTRAINT pk_${tableName}_${columns?.map((e) => e.toStringValue()).join('_')} PRIMARY KEY (${columns?.map((e) => e.toStringValue()).join(', ')})';
        } else if (uniqueConstraintChecker.isExactlyType(type)) {
          final columns = v.getField('columns')?.toListValue();
          return 'CONSTRAINT uq_${tableName}_${columns?.map((e) => e.toStringValue()).join('_')} UNIQUE (${columns?.map((e) => e.toStringValue()).join(', ')})';
        } else {
          return '';
        }
      })
      .where((v) => v.isNotEmpty)
      .map((v) => v)
      .toList();
  return (
    up:
        '''CREATE TABLE IF NOT EXISTS $tableName (
${fields.map((f) {
          final column = columnChecker.firstAnnotationOf(f);
          final columnName = column?.getField('name')?.toStringValue() ?? f.name;
          final columnType = buildColumnType(driver, f);
          final hasPk = primaryKeyChecker.hasAnnotationOf(f);
          final hasUnique = uniqueChecker.hasAnnotationOf(f);
          final hasNullable = nullableChecker.hasAnnotationOf(f);
          final hasCheck = checkChecker.hasAnnotationOf(f);
          final hasDefault = defaultChecker.hasAnnotationOf(f);
          final hasGeneratedValue = generatedValueChecker.hasAnnotationOf(f);
          final hasReferences = referencesChecker.hasAnnotationOf(f);
          final primaryKeyString = hasPk ? ' PRIMARY KEY' : '';
          final uniqueString = hasUnique && !hasPk ? ' UNIQUE' : '';
          final nullableString = !hasNullable && !hasPk ? ' NOT NULL' : '';
          if (hasDefault && hasGeneratedValue) {
            throw Exception('Cannot use generated value and default value at the same time!');
          }
          final defaultString = switch (hasDefault) {
            true => ' DEFAULT ${defaultChecker.firstAnnotationOf(f)?.getField('value')?.getField('value')?.toStringValue() ?? ''}',
            _ => '',
          };
          final generatedValueString = switch (hasGeneratedValue) {
            true => defaultGeneratedValueByType(columnType),
            _ => '',
          };
          final referencesString = switch (hasReferences) {
            true => referencesStringBuilder(referencesChecker.firstAnnotationOf(f), referencedTables),
            _ => '',
          };
          final checkString = switch (hasCheck) {
            true => checkStringBuilder(f),
            _ => '',
          };
          return '  $columnName $columnType$primaryKeyString$nullableString$uniqueString$defaultString$generatedValueString$referencesString$checkString';
        }).join(',\n')}${constraintStrings.isNotEmpty ? ',\n  ${constraintStrings.join(',\n  ')}' : ''}
);''',
    down: 'DROP TABLE IF EXISTS $tableName;',
    references: referencedTables,
  );
}

String buildColumnType(Driver driver, FieldElement field) {
  final column = columnChecker.firstAnnotationOf(field);
  final columnType = column?.getField('type')?.getField('(super)')?.getField('value')?.toStringValue();
  if (columnType == null) return genericSqlType(driver, field.type);
  return switch (columnType) {
    'UUID' when driver.sqlite => 'TEXT',
    'TIMESTAMP' when driver.sqlite => 'TEXT',
    'BOOLEAN' when driver.sqlite => 'INTEGER',
    _ => columnType,
  };
}

String genericSqlType(Driver driver, DartType type) {
  return switch (driver) {
    SqliteFileDriver _ || SqliteMemoryDriver _ => genericSqliteType(type),
    _ => 'NULL',
  };
}

String genericSqliteType(DartType type) {
  return switch (type.getDisplayString()) {
    'int' => 'INTEGER',
    'String' => 'TEXT',
    'DateTime' => 'TEXT',
    'bool' => 'INTEGER',
    _ => 'TEXT',
  };
}

String defaultGeneratedValueByType(String type) {
  return switch (type) {
    'INTEGER' => ' AUTOINCREMENT',
    'UUID' => ' DEFAULT gen_random_uuid()',
    'TEXT' => '',
    _ => '',
  };
}

String checkStringBuilder(FieldElement field) {
  final column = columnChecker.firstAnnotationOf(field);
  final columnName = column?.getField('name')?.toStringValue() ?? field.name;
  final check = checkChecker.firstAnnotationOf(field);
  if (check == null) return '';
  final operator = check.getField('operator')?.getField('(super)')?.getField('value')?.toStringValue() ?? '';
  final condition = check.getField('condition');
  final conditionValue = switch (condition?.type?.getDisplayString()) {
    'List<String>' => '(${condition?.toListValue()?.map((d) => '\'${d.toStringValue()}\'').join(', ')})',
    'String' => '\'${condition?.toStringValue()}\'',
    _ => condition?.toStringValue(),
  };
  return ' CHECK ($columnName $operator $conditionValue)';
}

String referencesStringBuilder(DartObject? type, Set<String> referencedTables) {
  if (type == null) return '';
  final table = type.getField('table')?.toStringValue() ?? '';
  final column = type.getField('column')?.toStringValue() ?? '';
  final onDelete = type.getField('onDelete')?.getField('value')?.toStringValue() ?? '';
  final onUpdate = type.getField('onUpdate')?.getField('value')?.toStringValue() ?? '';
  assert(table.isNotEmpty && column.isNotEmpty, Exception('Invalid references annotation!'));
  referencedTables.add(table);
  return ' REFERENCES $table($column) ON DELETE $onDelete ON UPDATE $onUpdate';
}

String insertOneMethodBuilder(
  Driver driver,
  String tableName,
  ClassElement classElement,
) {
  return switch (driver) {
    SqliteFileDriver _ || SqliteMemoryDriver _ => _insertOneInSQLITE(driver.varName, tableName, classElement),
    _ => '',
  };
}

String findOneMethodBuilder(
  Driver driver,
  String tableName,
  ClassElement classElement,
) {
  return switch (driver) {
    SqliteFileDriver _ || SqliteMemoryDriver _ => _findOneInSQLITE(driver.varName, tableName, classElement),
    _ => '',
  };
}

String findManyMethodBuilder(
  Driver driver,
  String tableName,
  ClassElement classElement,
) {
  return switch (driver) {
    SqliteFileDriver _ || SqliteMemoryDriver _ => _findManyInSQLITE(driver.varName, tableName, classElement),
    _ => '',
  };
}

String updateOneMethodBuilder(
  Driver driver,
  String tableName,
  ClassElement classElement,
) {
  return switch (driver) {
    SqliteFileDriver _ || SqliteMemoryDriver _ => _updateOneInSQLITE(driver.varName, tableName, classElement),
    _ => '',
  };
}

String deleteOneMethodBuilder(
  Driver driver,
  String tableName,
  ClassElement classElement,
) {
  return switch (driver) {
    SqliteFileDriver _ || SqliteMemoryDriver _ => _deleteOneInSQLITE(driver.varName, tableName, classElement),
    _ => '',
  };
}

String insertOneParamsBuilder(
  Driver driver,
  String entityName,
  String tableName,
  String className,
  Iterable<FieldElement> fields,
) {
  final classFields = fields
      .map((f) {
        final nullable =
            nullableChecker.hasAnnotationOf(f) ||
                primaryKeyChecker.hasAnnotationOf(f) ||
                defaultChecker.hasAnnotationOf(f) ||
                generatedValueChecker.hasAnnotationOf(f)
            ? '?'
            : '';
        return 'final ${f.type.getDisplayString()}${f.type.nullabilitySuffix == NullabilitySuffix.none ? nullable : ''} ${f.name};';
      })
      .join('\n');

  final classParams = fields
      .map((f) {
        final nullable =
            nullableChecker.hasAnnotationOf(f) ||
                primaryKeyChecker.hasAnnotationOf(f) ||
                defaultChecker.hasAnnotationOf(f) ||
                generatedValueChecker.hasAnnotationOf(f)
            ? ''
            : 'required ';
        return '${nullable}this.${f.name},';
      })
      .join('\n');

  final classQuery =
      '''INSERT INTO $tableName (\${_map().keys.map((k) => k).join(', ')}) VALUES (\${_map().keys.map((_) => '?').join(', ')}) RETURNING *;''';

  final classValues = r'newMap.values.toList()';

  return '''class $className extends InsertOneParams<$entityName> {
  $classFields

  const $className({$classParams});

  Map<String, dynamic> _map() => <String, dynamic>{
    ${fields.map((f) {
    final nullable = nullableChecker.hasAnnotationOf(f) || primaryKeyChecker.hasAnnotationOf(f) || defaultChecker.hasAnnotationOf(f) || generatedValueChecker.hasAnnotationOf(f);
    final columnName = columnChecker.firstAnnotationOf(f)?.getField('name')?.toStringValue() ?? f.name;
    return '${nullable ? 'if (${f.name} != null) ' : ''}\'$columnName\': ${f.name},';
  }).join('\n')}
  };

  @override
  String get query => '$classQuery';

  @override
  List<Object?> get values {
    final newMap = _map();

    for (final key in _map().keys) {
      if (_map()[key] is DateTime) {
        newMap[key] = (_map()[key] as DateTime).toIso8601String();
      }
    }

    return $classValues;
  }
}''';
}

String findOneParamsBuilder(
  Driver driver,
  String entityName,
  String tableName,
  String className,
  Iterable<FieldElement> fields,
  Iterable<FieldElement> primaryKey,
) {
  final classFields = switch (primaryKey.isNotEmpty) {
    true => primaryKey.map((f) => 'final ${f.type.getDisplayString()} ${f.name};').join('\n'),
    false => 'final Where where;',
  };

  final classParams = switch (primaryKey.isNotEmpty) {
    true => primaryKey.map((f) => 'this.${f.name}').join(', '),
    false => 'this.where',
  };

  final classQuery = switch (primaryKey.isNotEmpty) {
    true =>
      '''return 'SELECT * FROM $tableName WHERE ${primaryKey.map((f) {
        final columnName = columnChecker.firstAnnotationOf(f)?.getField('name')?.toStringValue() ?? f.name;
        return '$columnName = ?';
      }).join(' AND ')}';''',
    false =>
      '''if (where.isEmpty) throw Exception('empty_params');
    
    return 'SELECT * FROM $tableName WHERE \${where.query}';''',
  };

  final classValues = switch (primaryKey.isNotEmpty) {
    true =>
      'return [${primaryKey.map((f) {
        final isDateTime = dateTimeChecker.isExactlyType(f.type);
        return '${f.name}${isDateTime ? '.toIso8601String()' : ''}';
      }).join(', ')}];',
    false =>
      '''if (where.isEmpty) throw Exception('empty_params');
    
    return where.values;''',
  };

  return '''class $className extends FindOneParams<$entityName> {
  $classFields
  const $className($classParams);

  @override
  String get query {
    $classQuery
  }

  @override
  List<Object?> get values {
    $classValues
  }
}''';
}

String findManyParamsbuilder(
  Driver driver,
  String entityName,
  String tableName,
  String className,
  Iterable<FieldElement> fields,
) {
  return '''class $className extends FindManyParams<$entityName> {
  final Where? where;
  const $className([this.where]);

  @override
  String get query => switch (where != null) {
    true => 'SELECT * FROM $tableName WHERE \${where?.query}',
    _ => 'SELECT * FROM $tableName;',
  };

  @override
  List<Object?> get values => where?.values ?? [];
}''';
}

String updateOneParamsBuilder(
  Driver driver,
  String entityName,
  String tableName,
  String className,
  Iterable<FieldElement> fields,
  Iterable<FieldElement> primaryKey,
) {
  final requiredFields = switch (primaryKey.isNotEmpty) {
    true => primaryKey.map((f) => 'final ${f.type.getDisplayString()} ${f.name};').join('\n'),
    _ => 'final Where where;',
  };

  final classFields = '''$requiredFields
${fields.where((f) => !primaryKey.contains(f)).map((f) => 'final ${f.type.getDisplayString()}${f.type.nullabilitySuffix == NullabilitySuffix.none ? '?' : ''} ${f.name};').join('\n')}''';

  final requiredParams = switch (primaryKey.isNotEmpty) {
    true => primaryKey.map((f) => 'this.${f.name},').join('\n'),
    _ => 'this.where',
  };

  final classParams =
      '''$requiredParams{
${fields.where((f) => !primaryKey.contains(f)).map((f) => 'this.${f.name}').join(', ')}
}''';

  final classQuery = switch (primaryKey.isNotEmpty) {
    true =>
      '''return 'UPDATE $tableName SET \${_map().entries.map((e) => '\${e.key} = ?').join(', ')} WHERE ${primaryKey.map((f) {
        final fieldName = columnChecker.firstAnnotationOf(f)?.getField('name')?.toStringValue() ?? f.name;
        return '$fieldName = ?';
      }).join(' AND ')} RETURNING *;';''',
    false =>
      '''if (where.isEmpty) throw Exception('no_filters_given');
    
    return 'UPDATE $tableName SET \${_map().entries.map((e) => '{e.key} = ?').join(', ')} WHERE \${where.query} RETURNING *;';''',
  };

  final classValues = switch (primaryKey.isNotEmpty) {
    true =>
      '''return [..._map().values, ${primaryKey.map((f) {
        final isDateTime = dateTimeChecker.isExactlyType(f.type);
        return '${f.name}${isDateTime ? '.toIso8601String()' : ''}';
      }).join(', ')}];''',
    false =>
      '''if (where.isEmpty) throw Exception('no_filters_given');

    return [..._map().values, ...where.values];''',
  };

  return '''class $className extends UpdateOneParams<$entityName> {
  $classFields
  const $className($classParams);

  Map<String, dynamic> _map() => <String, dynamic>{
    ${fields.where((f) => !primaryKey.contains(f)).map((f) {
    final columnName = columnChecker.firstAnnotationOf(f)?.getField('name')?.toStringValue() ?? f.name;
    return 'if (${f.name} != null) \'$columnName\': ${f.name},';
  }).join('\n')}
  };

  @override
  String get query {
    if (_map().isEmpty) {
      throw Exception('no_fields_to_update');
    }

    $classQuery
  }

  @override
  List<Object?> get values {
    if (_map().isEmpty) {
      throw Exception('no_fields_to_update');
    }

    $classValues
  }
}''';
}

String deleteOneParamsBuilder(
  Driver driver,
  String entityName,
  String tableName,
  String className,
  Iterable<FieldElement> primaryKey,
) {
  final classFields = switch (primaryKey.isNotEmpty) {
    true => primaryKey.map((f) => 'final ${f.type.getDisplayString()} ${f.name};').join('\n'),
    false => 'final Where where;',
  };

  final classParams = switch (primaryKey.isNotEmpty) {
    true => primaryKey.map((f) => 'this.${f.name}').join(', '),
    false => 'this.where',
  };

  final classQuery = switch (primaryKey.isNotEmpty) {
    true =>
      '''return 'DELETE FROM $tableName WHERE ${primaryKey.map((f) {
        final columnName = columnChecker.firstAnnotationOf(f)?.getField('name')?.toStringValue() ?? f.name;
        return '$columnName = ?';
      }).join(' AND ')}';''',
    false =>
      '''if (where.isEmpty) throw Exception('empty_params');
    
    return 'DELETE FROM $tableName WHERE \${where.query}';''',
  };

  final classValues = switch (primaryKey.isNotEmpty) {
    true =>
      'return [${primaryKey.map((f) {
        final isDateTime = dateTimeChecker.isExactlyType(f.type);
        return '${f.name}${isDateTime ? '.toIso8601String()' : ''}';
      }).join(', ')}];',
    false =>
      '''if (where.isEmpty) throw Exception('empty_params');
    
    return where.values;''',
  };

  return '''class $className extends DeleteOneParams<$entityName> {
  $classFields
  const $className($classParams);

  @override
  String get query {
    $classQuery
  }

  @override
  List<Object?> get values {
    $classValues
  }
}''';
}

String _insertOneInSQLITE(
  String dialectVarName,
  String tableName,
  ClassElement classElement,
) {
  return '''try {
  final stmt = $dialectVarName.prepare(params.query);

  final result = stmt.select(params.values);

  if (result.isEmpty) {
    throw NotFoundSqlException('fail_to_insert_on_${singularize(tableName)}');
  }

  final row = result.first;

  final entity = ${buildObjectFromConstructor(classElement: classElement, valueBuilder: (v) => 'row[\'$v\']')};

  return Success(entity);
} on SqlException catch (e) {
  return Error(e);
} on Exception catch (e, s) {
  return Error(UnknownSqlException('fail_to_insert_on_${singularize(tableName)}', s));
}''';
}

String _findOneInSQLITE(
  String dialectVarName,
  String tableName,
  ClassElement classElement,
) {
  return '''try {
  final stmt = $dialectVarName.prepare(params.query);

  final result = stmt.select(params.values);

  if (result.isEmpty) {
    throw NotFoundSqlException('${singularize(tableName)}_not_found');
  }

  final row = result.first;

  final entity = ${buildObjectFromConstructor(classElement: classElement, valueBuilder: (v) => 'row[\'$v\']')};

  return Success(entity);
} on SqlException catch (e) {
  return Error(e);
} on Exception catch (e, s) {
  return Error(UnknownSqlException('fail_to_insert_on_${singularize(tableName)}', s));
}''';
}

String _findManyInSQLITE(
  String dialectVarName,
  String tableName,
  ClassElement classElement,
) {
  return '''try {
  final stmt = $dialectVarName.prepare(params.query);

  final result = stmt.select(params.values);

  final entities = result.map((row) {
    return ${buildObjectFromConstructor(classElement: classElement, valueBuilder: (v) => 'row[\'$v\']')};
  }).toList();

  return Success(entities);
} on Exception catch (e, s) {
  return Error(UnknownSqlException('fail_to_get_$tableName', s));
}''';
}

String _updateOneInSQLITE(
  String dialectVarName,
  String tableName,
  ClassElement classElement,
) {
  return '''try {
  final stmt = $dialectVarName.prepare(params.query);

  final result = stmt.select(params.values);

  if (result.isEmpty) {
    throw NotFoundSqlException('${singularize(tableName)}_not_found');
  }

  final row = result.first;

  final entity =  ${buildObjectFromConstructor(classElement: classElement, valueBuilder: (v) => 'row[\'$v\']')};

  return Success(entity);
} on SqlException catch (e) {
  return Error(e);
} on Exception catch (e, s) {
  return Error(UnknownSqlException('fail_to_update_${singularize(tableName)}', s));
}''';
}

String _deleteOneInSQLITE(
  String dialectVarName,
  String tableName,
  ClassElement classElement,
) {
  return '''try {
  final stmt = $dialectVarName.prepare(params.query);

  final result = stmt.select(params.values);

  if (result.isEmpty) {
    throw NotFoundSqlException('${singularize(tableName)}_not_found');
  }

  final row = result.first;

  final entity = ${buildObjectFromConstructor(classElement: classElement, valueBuilder: (v) => 'row[\'$v\']')};
  
  return Success(entity);
} on SqlException catch (e) {
  return Error(e);
} on Exception catch (e, s) {
  return Error(UnknownSqlException('fail_to_delete_${singularize(tableName)}', s));
}''';
}

String buildObjectFromConstructor({
  required ClassElement classElement,
  String Function(String? value)? valueBuilder,
}) {
  final className = classElement.name;
  final constructor = classElement.constructors.firstWhereOrNull((c) => c.formalParameters.isNotEmpty);
  if (constructor == null) return '';
  final constructorParams = constructor.formalParameters;
  final parsers = classElement.fields
      .where((f) => withParserChecker.hasAnnotationOf(f))
      .map(
        (f) => (
          field: f,
          type: withParserChecker.firstAnnotationOf(f)?.getField('parser')?.toTypeValue()!,
        ),
      );
  return '$className(${constructorParams.map((p) {
    String buildValue() {
      if (parsers.any((parser) => parser.field.name == p.name)) {
        final parser = parsers.firstWhere((parser) => parser.field.name == p.name);
        return '${parser.type}().decode(${valueBuilder?.call(p.name?.toSnakeCase()) ?? p.name?.toSnakeCase()})';
      }

      if (p.type.getDisplayString().startsWith('DateTime')) {
        return 'DateTime.tryParse(${valueBuilder?.call(p.name?.toSnakeCase()) ?? p.name?.toSnakeCase()})';
      }
      return '${valueBuilder?.call(p.name?.toSnakeCase()) ?? p.name?.toSnakeCase()}';
    }

    String buildDefault() {
      if (p.type.isDartCoreString) return ' ?? \'\'';
      if (p.type.isDartCoreInt) return ' ?? 0';
      if (p.type.isDartCoreDouble) return ' ?? 0.0';
      if (p.type.isDartCoreBool) return ' ?? false';
      if (p.type.isDartCoreList) return ' ?? []';
      if (p.type.isDartCoreMap) return ' ?? {}';
      if (p.type.isDartCoreSet) return ' ?? {}';
      if (p.type.isDartCoreIterable) return ' ?? Iterable.empty()';
      if (p.type.getDisplayString().startsWith('DateTime')) return ' ?? DateTime.now()';

      return '';
    }

    final key = p.isNamed ? '${p.name}' : '';
    return '$key: ${buildValue()}${buildDefault()}';
  }).join(', ')})';
}
