import 'package:analyzer/dart/element/element.dart';
import 'package:spring_dart_gen/src/checkers.dart';
import 'package:spring_dart_gen/src/extensions/string_ext.dart';

String entityHelper(
  ClassElement element,
  Set<String> imports,
  Set<({String name, String className, String content})> entities,
) {
  final className = element.name;
  final tableName =
      tableChecker.firstAnnotationOf(element)?.getField('name')?.toStringValue() ??
      className?.removeSuffixes(['Entity', 'Model']);
  final repositoryName = '${tableName}Repository'.toPascalCase();
  final insertOneParamName = '${tableName}InsertOneParams'.toPascalCase();

  final fields = element.fields.where((f) => f.name != 'hashCode' && f.name != 'runtimeType');

  final requiredFields = fields.where(
    (f) => defaultChecker.hasAnnotationOf(f) == false && generatedValueChecker.hasAnnotationOf(f) == false,
  );

  if (!fields.any((f) => idChecker.hasAnnotationOf(f))) return '';

  imports.add(element.library.uri.toString());

  final id = fields.firstWhere((f) => idChecker.hasAnnotationOf(f));

  final idType = id.type.getDisplayString();

  return '''class ${repositoryName}Imp extends CrudRepository<$className, $idType> {
    @override
    AsyncResult<$className, Exception> insertOne(InsertOneParams<$className> params) {
      throw UnimplementedError();
    }

    @override
    AsyncResult<$className, Exception> findOne(FindOneParams<$className> params) {
      throw UnimplementedError();
    }

    @override
    AsyncResult<List<$className>, Exception> findMany(FindManyParams<$className> params) {
      throw UnimplementedError();
    }

    @override
    AsyncResult<$className, Exception> updateOne(UpdateOneParams<$className> params) {
      throw UnimplementedError();
    }

    @override
    AsyncResult<$className, Exception> deleteOne(DeleteOneParams<$className> params) {
      throw UnimplementedError();
    }
  }
  
  class $insertOneParamName extends InsertOneParams<$className> {
    ${requiredFields.map((f) => 'final ${f.type.getDisplayString()} ${f.name};').join('\n')}

    const $insertOneParamName({
      ${requiredFields.map((f) => 'required this.${f.name},').join('\n')}
    });
  }''';
}
