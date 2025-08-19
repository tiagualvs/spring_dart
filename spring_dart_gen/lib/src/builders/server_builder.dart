import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:spring_dart_sql/spring_dart_sql.dart';
import 'package:yaml/yaml.dart';

import '../checkers.dart';
import '../extensions/string_ext.dart';
import '../helpers/controller_helper.dart';
import '../helpers/entity_helper.dart';

typedef ClassContent = ({String name, String className, String content});

class ServerBuilder extends Builder {
  late final Driver driver;
  late final Map<String, List<String>> _buildExtensions;

  ServerBuilder(BuilderOptions options) {
    driver = Driver.fromConfig(options.config);
    final file = File(p.join(Directory.current.path, 'pubspec.yaml'));
    final yaml = loadYaml(file.readAsStringSync());
    final package = yaml['name'] as String? ?? 'server';

    _buildExtensions = {
      r'$package$': [p.join('bin', '$package.dart'), p.join('lib', 'server.dart')],
    };
  }

  @override
  Map<String, List<String>> get buildExtensions => _buildExtensions;

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final buffer = StringBuffer();

    final imports = <String>{};

    final configurations = <ClassContent>{};

    final beans = <ClassContent>{};

    final services = <ClassContent>{};

    final components = <ClassContent>{};

    final filters = <ClassContent>{};

    final repositories = <String>{};

    final controllers = <ClassContent>{};

    final springDartConfiguration = <ClassContent>{};

    final entities = <ClassContent>{};

    final exceptionHandler = <({String name, String className, String content, List<MethodElement> methods})>{};

    final content = await buildStep.findAssets(Glob('lib/**.dart')).asyncExpand((assetId) async* {
      final library = await buildStep.resolver.libraryFor(assetId);
      final reader = LibraryReader(library);

      for (final element in reader.classes) {
        if (configurationChecker.hasAnnotationOf(element)) {
          final className = element.name;

          imports.add(element.library.uri.toString());

          final superType = element.supertype;

          if (superType != null && springDartConfigurationChecker.isExactly(superType.element)) {
            springDartConfiguration.add(
              (
                name: className?.toCamelCase() ?? '',
                className: className ?? '',
                content: 'final ${className?.toCamelCase()} = $className()',
              ),
            );
          } else {
            configurations.add(
              (
                name: className?.toCamelCase() ?? '',
                className: className ?? '',
                content: 'final ${className?.toCamelCase()} = $className()',
              ),
            );

            for (final method in element.methods.where((m) => beanChecker.hasAnnotationOf(m))) {
              final methodName = method.name;
              final type = method.type;
              final returnType = type.returnType;

              if (returnType.isDartAsyncFuture || returnType.isDartAsyncFutureOr) {
                final realReturnType = (returnType as ParameterizedType).typeArguments.first;

                beans.add(
                  (
                    name: realReturnType.getDisplayString().toCamelCase(),
                    className: className ?? '',
                    content:
                        'getIt.registerLazySingletonAsync<${realReturnType.getDisplayString()}>(() => ${className?.toCamelCase()}.$methodName())',
                  ),
                );
              } else {
                final methodReturnType = returnType.getDisplayString();

                beans.add(
                  (
                    name: methodReturnType.toCamelCase(),
                    className: className ?? '',
                    content:
                        'getIt.registerLazySingleton<$methodReturnType>(() => ${className?.toCamelCase()}.$methodName())',
                    // content: 'final ${methodReturnType.toCamelCase()} = ${className?.toCamelCase()}.$methodName()',
                  ),
                );
              }
            }
          }
        } else if (componentChecker.hasAnnotationOf(element)) {
          final className = element.name;

          imports.add(element.library.uri.toString());

          final constructors = element.constructors;

          final constructorParams = switch (constructors.isNotEmpty) {
            true => constructors.first.formalParameters.map((p) {
              final found = p.type.getDisplayString().toCamelCase();
              return p.isNamed ? '${p.name}: $found' : found;
            }).toList(),
            false => <String>[],
          };

          final superType = element.supertype;

          if (superType != null && filterChecker.isExactly(superType.element)) {
            filters.add(
              (
                name: '${className?.toCamelCase()}',
                className: className ?? '',
                content: '.addMiddleware($className(${constructorParams.join(', ')}).toShelfMiddleware)',
              ),
            );
          } else {
            components.add(
              (
                name: '${className?.toCamelCase()}',
                className: className ?? '',
                content: 'final ${className?.toCamelCase()} = $className(${constructorParams.join(', ')})',
              ),
            );
          }
        } else if (repositoryChecker.hasAnnotationOf(element)) {
          final className = element.name;

          imports.add(element.library.uri.toString());

          final constructors = element.constructors;

          final constructorParams = switch (constructors.isNotEmpty) {
            true => constructors.first.formalParameters.map((p) {
              final found = p.type.getDisplayString().toCamelCase();
              return p.isNamed ? '${p.name}: $found' : found;
            }).toList(),
            false => <String>[],
          };

          repositories.add(
            'getIt.registerLazySingleton<$className>(() => $className(${constructorParams.join(', ')}))',
          );
        } else if (serviceChecker.hasAnnotationOf(element)) {
          final className = element.name;

          imports.add(element.library.uri.toString());

          final constructors = element.constructors;

          final constructorParams = switch (constructors.isNotEmpty) {
            true => constructors.first.formalParameters.map((p) {
              final found = p.type.getDisplayString().toCamelCase();
              return p.isNamed ? '${p.name}: $found' : found;
            }).toList(),
            false => <String>[],
          };

          services.add(
            (
              name: className?.toCamelCase() ?? '',
              className: className ?? '',
              content:
                  'getIt.registerLazySingleton<$className>(() => $className(${constructorParams.map((e) => 'getIt()').join(', ')}))',
              // content: 'final ${className?.toCamelCase()} = $className(${constructorParams.join(', ')})',
            ),
          );
        } else if (controllerChecker.hasAnnotationOf(element)) {
          yield controllerHelper(element, imports, controllers);
        } else if (entityChecker.hasAnnotationOf(element)) {
          yield entityHelper(driver, element, imports, repositories, entities);
        } else if (controllerAdviceChecker.hasAnnotationOf(element)) {
          final className = element.name;
          final methods = element.methods
              .where((m) => exceptionHandlerChecker.hasAnnotationOf(m))
              .map(
                (m) => (
                  method: m,
                  type: exceptionHandlerChecker.firstAnnotationOf(m)!.getField('exception')!.toTypeValue()!,
                ),
              )
              .where(
                (m) {
                  final typeElement = m.type.element as ClassElement?;
                  final superType = typeElement?.supertype;

                  if (superType != null) {
                    return exceptionChecker.isExactlyType(m.type) ||
                        exceptionChecker.isExactlyType(superType) ||
                        (typeElement?.interfaces.any((i) => exceptionChecker.isExactlyType(i)) ?? false);
                  }

                  return exceptionChecker.isExactlyType(m.type);
                },
              )
              .where(
                (m) =>
                    futureResponseChecker.isExactlyType(m.method.returnType) ||
                    futureOrResponseChecker.isExactlyType(m.method.returnType) ||
                    responseChecker.isExactlyType(m.method.returnType),
              );

          if (methods.isEmpty) continue;

          imports.add(element.library.uri.toString());

          for (final method in methods) {
            imports.add(method.type.element?.library?.uri.toString() ?? '');
          }

          exceptionHandler.add(
            (
              className: className ?? '',
              name: className?.toCamelCase() ?? '',
              content: 'final ${className?.toCamelCase()} = $className()',
              methods: methods.map((m) => m.method).toList(),
            ),
          );
        }
      }
    }).toList();

    buffer.writeln('// POWERED BY SPRING DART');

    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND\n\n');

    imports.add('package:spring_dart/spring_dart.dart');

    imports.add('dart:convert');

    final sortedImports = imports.toList()..sort();

    buffer.writeAll(sortedImports.map((i) => 'import \'$i\';'), '\n');

    if (springDartConfiguration.length > 1) {
      throw Exception('Only one SpringDartConfiguration is allowed!');
    }

    buffer.writeln('''Future<void> server(List<String> args) async {
  final getIt = GetIt.instance;
  final router = Router(notFoundHandler: _defaultNotFoundHandler);${configurations.isNotEmpty ? '''\n// Configurations
  ${configurations.map((e) => '${e.content};').join('\n')}''' : ''}${beans.isNotEmpty ? '''\n// Beans
  ${beans.map((e) => '${e.content};').join('\n')}''' : ''}${beans.isNotEmpty ? 'await GetIt.instance.allReady();' : ''}${components.isNotEmpty ? '''\n // Components
  ${components.map((e) => '${e.content};').join('\n')}''' : ''}${repositories.isNotEmpty ? '''\n// Repositories
  ${repositories.map((e) => '$e;').join('\n')}''' : ''}${services.isNotEmpty ? '''\n// Services
  ${services.map((e) => '${e.content};').join('\n')}''' : ''}${controllers.isNotEmpty ? '''\n// Controllers
  ${controllers.map((e) => '${e.content};').join('\n')}''' : ''}
  // Server Configuration
  Handler handler = router.call;${filters.isNotEmpty ? '''handler = Pipeline()${filters.map((e) => e.content).join('\n')}.addHandler(handler);''' : ''}${springDartConfiguration.isEmpty ? '''final \$defaultServerConfiguration = SpringDartConfiguration.defaultConfiguration;
for (final middleware in \$defaultServerConfiguration.middlewares) {
  handler = middleware(handler);
}
SpringDartDefaults.instance.toEncodable = \$defaultServerConfiguration.toEncodable;
return await \$defaultServerConfiguration.setup(SpringDart((request) => _exceptionHandler(handler, request)));''' : springDartConfiguration.map((e) {
            return '''${e.content};
            for (final middleware in ${e.name}.middlewares) {
              handler = middleware(handler);
            }
            SpringDartDefaults.instance.toEncodable = ${e.name}.toEncodable;
            return await ${e.name}.setup(SpringDart((request) => _exceptionHandler(handler, request)));''';
          }).join('\n')}
}''');

    buffer.writeln(content.join('\n\n'));

    buffer.writeln(defaultNotFoundHandler());

    buffer.writeln(exceptionHandlerHelper(exceptionHandler));

    final entryPointAssetId = AssetId(buildStep.inputId.package, p.join('bin', '${buildStep.inputId.package}.dart'));

    final serverAssetId = AssetId(buildStep.inputId.package, p.join('lib', 'server.dart'));

    final formatter = DartFormatter(languageVersion: DartFormatter.latestLanguageVersion);

    await buildStep.writeAsString(serverAssetId, formatter.format(buffer.toString()));

    await buildStep.writeAsString(
      entryPointAssetId,
      formatter.format('''import 'package:${buildStep.inputId.package}/server.dart';

void main(List<String> args) async => server(args);'''),
    );
  }

  String defaultNotFoundHandler() {
    return '''FutureOr<Response> _defaultNotFoundHandler(Request request) async {
      return Json(
        404,
        body: {
          'error': 'Route not found!',
        },
      );
    }''';
  }

  String exceptionHandlerHelper(
    Set<({String name, String className, String content, List<MethodElement> methods})> exceptionHandler,
  ) {
    return '''FutureOr<Response> _exceptionHandler(Handler handler, Request request) async {
  try {
    return await handler(request);
  }  catch (e) {
    ${exceptionHandler.map((e) => e.methods.map((m) => '''if (e is ${exceptionHandlerChecker.firstAnnotationOf(m)?.getField('exception')?.toTypeValue()}) {
      return ${e.className}().${m.name}(e);
    }''').join('else \n')).join('\n')}
    else {
      return Json(
      500,
      body: {
        'error': e.toString(),
      },
    );
    }
  }
}''';
  }
}
