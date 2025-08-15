import 'package:source_gen/source_gen.dart';
import 'package:spring_dart_core/spring_dart_core.dart';

final controllerChecker = TypeChecker.typeNamed(Controller, inPackage: 'spring_dart_core');
final repositoryChecker = TypeChecker.typeNamed(Repository, inPackage: 'spring_dart_core');
final serviceChecker = TypeChecker.typeNamed(Service, inPackage: 'spring_dart_core');
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

final dtoChecker = TypeChecker.typeNamed(Dto, inPackage: 'spring_dart_core');
final jsonKeyChecker = TypeChecker.typeNamed(JsonKey, inPackage: 'spring_dart_core');
final withParserChecker = TypeChecker.typeNamed(WithParser, inPackage: 'spring_dart_core');

final requestChecker = TypeChecker.typeNamed(Request, inPackage: 'shelf');
final responseChecker = TypeChecker.typeNamed(Response, inPackage: 'shelf');

final stringChecker = TypeChecker.typeNamed(String);
final jsonChecker = TypeChecker.typeNamed(Map<String, dynamic>);
