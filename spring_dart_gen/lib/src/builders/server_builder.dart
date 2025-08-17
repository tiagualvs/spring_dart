import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

import '../checkers.dart';
import '../extensions/string_ext.dart';
import '../helpers/controller_helper.dart';
import '../helpers/entity_helper.dart';

typedef ClassContent = ({String name, String className, String content});

class ServerBuilder extends Builder {
  late final Map<String, List<String>> _buildExtensions;

  ServerBuilder() {
    final package = p.basename(Directory.current.path);

    _buildExtensions = {
      r'$package$': [p.join('bin', '$package.dart'), p.join('lib', 'spring_dart.dart')],
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

    final repositories = <ClassContent>{};

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
                        'final ${realReturnType.getDisplayString().toCamelCase()} = await ${className?.toCamelCase()}.$methodName()',
                  ),
                );
              } else {
                final methodReturnType = returnType.getDisplayString();

                beans.add(
                  (
                    name: methodReturnType.toCamelCase(),
                    className: className ?? '',
                    content: 'final ${methodReturnType.toCamelCase()} = ${className?.toCamelCase()}.$methodName()',
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
            (
              name: className?.toCamelCase() ?? '',
              className: className ?? '',
              content: 'final ${className?.toCamelCase()} = $className(${constructorParams.join(', ')})',
            ),
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
              content: 'final ${className?.toCamelCase()} = $className(${constructorParams.join(', ')})',
            ),
          );
        } else if (controllerChecker.hasAnnotationOf(element)) {
          yield controllerHelper(element, imports, controllers);
        } else if (entityChecker.hasAnnotationOf(element)) {
          yield entityHelper(element, imports, entities);
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

    buffer.writeln('''void main(List<String> args) async {
  final router = Router();${configurations.isNotEmpty ? '''\n// Configurations
  ${configurations.map((e) => '${e.content};').join('\n')}''' : ''}${beans.isNotEmpty ? '''\n// Beans
  ${beans.map((e) => '${e.content};').join('\n')}''' : ''}${components.isNotEmpty ? '''\n // Components
  ${components.map((e) => '${e.content};').join('\n')}''' : ''}${repositories.isNotEmpty ? '''\n// Repositories
  ${repositories.map((e) => '${e.content};').join('\n')}''' : ''}${services.isNotEmpty ? '''\n// Services
  ${services.map((e) => '${e.content};').join('\n')}''' : ''}${controllers.isNotEmpty ? '''\n// Controllers
  ${controllers.map((e) => '${e.content};').join('\n')}''' : ''}${exceptionHandler.isNotEmpty ? '''\n // Exception Handlers
  ${exceptionHandler.map((e) => '${e.content};').join('\n')}''' : ''}
  // Server Configuration
  Handler handler = router.call;${filters.isNotEmpty ? '''handler = Pipeline()${filters.map((e) => e.content).join('\n')}.addHandler(handler);''' : ''}${springDartConfiguration.isEmpty ? '''final \$defaultServerConfiguration = SpringDartConfiguration.defaultConfiguration;
for (final middleware in \$defaultServerConfiguration.middlewares) {
  handler = middleware(handler);
}
SpringDartDefaults.instance.toEncodable = \$defaultServerConfiguration.toEncodable;${exceptionHandler.isNotEmpty ? '''handler = (Request request) async {
  try {
    return await handler(request);
  } on Exception catch (e) {
    ${exceptionHandler.map((e) => '''if (e is ${e.className}) {
      return ${e.name}.handler(e);
    }''').join('\n')}
    return Json(
      500,
      body: {
        'error': e.toString(),
      },
    );
  }
};''' : ''}
return await \$defaultServerConfiguration.setup(SpringDart(handler));''' : springDartConfiguration.map((e) {
            return '''${e.content};
            for (final middleware in ${e.name}.middlewares) {
              handler = middleware(handler);
            }
            SpringDartDefaults.instance.toEncodable = ${e.name}.toEncodable;${exceptionHandler.isNotEmpty ? '''handler = (Request request) async {
  try {
    return await handler(request);
  }  catch (e) {
    ${exceptionHandler.map((e) => e.methods.map((m) => '''if (e is ${exceptionHandlerChecker.firstAnnotationOf(m)?.getField('exception')?.toTypeValue()}) {
      return ${e.name}.${m.name}(e);
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
};''' : ''}
            return await ${e.name}.setup(SpringDart(handler));''';
          }).join('\n')}
}''');

    buffer.writeln(content.join('\n\n'));

    final outputId = AssetId(buildStep.inputId.package, p.join('bin', '${buildStep.inputId.package}.dart'));

    final formatted = DartFormatter(languageVersion: DartFormatter.latestLanguageVersion).format(buffer.toString());

    await buildStep.writeAsString(outputId, formatted);
  }
}
