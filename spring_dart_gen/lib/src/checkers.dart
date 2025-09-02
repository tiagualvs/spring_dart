import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:spring_dart_core/spring_dart_core.dart';
import 'package:spring_dart_sql/spring_dart_sql.dart';

final controllerAdviceChecker = TypeChecker.typeNamed(ControllerAdvice, inPackage: 'spring_dart_core');
final exceptionHandlerChecker = TypeChecker.typeNamed(ExceptionHandler, inPackage: 'spring_dart_core');

final controllerChecker = TypeChecker.typeNamed(Controller, inPackage: 'spring_dart_core');
final repositoryChecker = TypeChecker.typeNamed(Repository, inPackage: 'spring_dart_core');
final serviceChecker = TypeChecker.typeNamed(Service, inPackage: 'spring_dart_core');
final componentChecker = TypeChecker.typeNamed(Component, inPackage: 'spring_dart_core');
final configurationChecker = TypeChecker.typeNamed(Configuration, inPackage: 'spring_dart_core');
final beanChecker = TypeChecker.typeNamed(Bean, inPackage: 'spring_dart_core');

final getChecker = TypeChecker.typeNamed(Get, inPackage: 'spring_dart_core');
final postChecker = TypeChecker.typeNamed(Post, inPackage: 'spring_dart_core');
final putChecker = TypeChecker.typeNamed(Put, inPackage: 'spring_dart_core');
final deleteChecker = TypeChecker.typeNamed(Delete, inPackage: 'spring_dart_core');
final patchChecker = TypeChecker.typeNamed(Patch, inPackage: 'spring_dart_core');
final headChecker = TypeChecker.typeNamed(Head, inPackage: 'spring_dart_core');
final optionsChecker = TypeChecker.typeNamed(Options, inPackage: 'spring_dart_core');
final traceChecker = TypeChecker.typeNamed(Trace, inPackage: 'spring_dart_core');
final connectChecker = TypeChecker.typeNamed(Connect, inPackage: 'spring_dart_core');

final bodyChecker = TypeChecker.typeNamed(Body, inPackage: 'spring_dart_core');
final queryChecker = TypeChecker.typeNamed(Query, inPackage: 'spring_dart_core');
final paramChecker = TypeChecker.typeNamed(Param, inPackage: 'spring_dart_core');
final headerChecker = TypeChecker.typeNamed(Header, inPackage: 'spring_dart_core');
final contextChecker = TypeChecker.typeNamed(Context, inPackage: 'spring_dart_core');

ContentType contentTypeExtractor(Element element) {
  final contentTypes = [
    ApplicationJson(),
    MultipartFormData(),
    FormUrlEncoded(),
    TextPlain(),
    TextHtml(),
  ];

  for (final type in contentTypes) {
    if (TypeChecker.typeNamed(type.runtimeType, inPackage: 'spring_dart_core').hasAnnotationOf(element)) {
      return type;
    }
  }

  return contentTypes.first;
}

final dtoChecker = TypeChecker.typeNamed(Dto, inPackage: 'spring_dart_core');
final validatedChecker = TypeChecker.typeNamed(Validated, inPackage: 'spring_dart_core');
final validatorChecker = (
  core: TypeChecker.typeNamed(Validator, inPackage: 'spring_dart_core'),
  email: TypeChecker.typeNamed(Email, inPackage: 'spring_dart_core'),
  notNull: TypeChecker.typeNamed(NotNull, inPackage: 'spring_dart_core'),
  notEmpty: TypeChecker.typeNamed(NotEmpty, inPackage: 'spring_dart_core'),
  min: TypeChecker.typeNamed(Min, inPackage: 'spring_dart_core'),
  max: TypeChecker.typeNamed(Max, inPackage: 'spring_dart_core'),
  size: TypeChecker.typeNamed(Size, inPackage: 'spring_dart_core'),
  pattern: TypeChecker.typeNamed(Pattern, inPackage: 'spring_dart_core'),
  greaterThan: TypeChecker.typeNamed(GreaterThan, inPackage: 'spring_dart_core'),
  greaterThanOrEqual: TypeChecker.typeNamed(GreaterThanOrEqual, inPackage: 'spring_dart_core'),
  lessThan: TypeChecker.typeNamed(LessThan, inPackage: 'spring_dart_core'),
  lessThanOrEqual: TypeChecker.typeNamed(LessThanOrEqual, inPackage: 'spring_dart_core'),
);
final jsonKeyChecker = TypeChecker.typeNamed(JsonKey, inPackage: 'spring_dart_core');
final withParserChecker = TypeChecker.typeNamed(WithParser, inPackage: 'spring_dart_core');

final requestChecker = TypeChecker.typeNamed(Request, inPackage: 'shelf');
final responseChecker = TypeChecker.typeNamed(Response, inPackage: 'shelf');
final futureResponseChecker = TypeChecker.typeNamed(Future<Response>);
final futureOrResponseChecker = TypeChecker.typeNamed(FutureOr<Response>);

final filterChecker = TypeChecker.typeNamed(Filter, inPackage: 'spring_dart_core');

final springDartConfigurationChecker = TypeChecker.typeNamed(SpringDartConfiguration, inPackage: 'spring_dart_core');

final entityChecker = TypeChecker.typeNamed(Entity, inPackage: 'spring_dart_sql');
final tableChecker = TypeChecker.typeNamed(Table, inPackage: 'spring_dart_sql');
final constraintChecker = TypeChecker.typeNamed(Constraint, inPackage: 'spring_dart_sql');
final foreignKeyConstraintChecker = TypeChecker.typeNamed(ForeignKeyConstraint, inPackage: 'spring_dart_sql');
final primaryKeyConstraintChecker = TypeChecker.typeNamed(PrimaryKeyConstraint, inPackage: 'spring_dart_sql');
final uniqueConstraintChecker = TypeChecker.typeNamed(UniqueConstraint, inPackage: 'spring_dart_sql');
final columnChecker = TypeChecker.typeNamed(Column, inPackage: 'spring_dart_sql');
final primaryKeyChecker = TypeChecker.typeNamed(PrimaryKey, inPackage: 'spring_dart_sql');
final generatedValueChecker = TypeChecker.typeNamed(GeneratedValue, inPackage: 'spring_dart_sql');
final uniqueChecker = TypeChecker.typeNamed(Unique, inPackage: 'spring_dart_sql');
final nullableChecker = TypeChecker.typeNamed(Nullable, inPackage: 'spring_dart_sql');
final checkChecker = TypeChecker.typeNamed(Check, inPackage: 'spring_dart_sql');
final defaultChecker = TypeChecker.typeNamed(Default, inPackage: 'spring_dart_sql');
final dataTypeChecker = TypeChecker.typeNamed(DataType, inPackage: 'spring_dart_sql');
final referencesChecker = TypeChecker.typeNamed(References, inPackage: 'spring_dart_sql');
final timestampChecker = TypeChecker.typeNamed(TIMESTAMP, inPackage: 'spring_dart_sql');

final stringChecker = TypeChecker.typeNamed(String);
final dateTimeChecker = TypeChecker.typeNamed(DateTime);
final jsonChecker = TypeChecker.typeNamed(Map<String, dynamic>);
final exceptionChecker = TypeChecker.typeNamed(Exception);
