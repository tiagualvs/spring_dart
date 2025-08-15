import 'dart:async';

import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:spring_dart_gen/src/checkers.dart';
import 'package:spring_dart_gen/src/extensions/string_ext.dart';

import 'controller_helper.dart';

class SpringDartBuilder extends Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
    r'$package$': [p.join('lib', 'spring_dart.dart')],
  };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final buffer = StringBuffer();

    final imports = <String>{};

    final beans = <String>{};

    final configurations = <String>{};

    final services = <String>{};

    final controllers = <String>{};

    final repositories = <String>{};

    final content = await buildStep.findAssets(Glob('lib/**.dart')).asyncExpand((assetId) async* {
      final library = await buildStep.resolver.libraryFor(assetId);
      final reader = LibraryReader(library);

      for (final element in reader.classes) {
        if (controllerChecker.hasAnnotationOf(element)) {
          yield controllerHelper(element, imports, controllers);
        } else if (repositoryChecker.hasAnnotationOf(element)) {
          final className = element.name;
          final superClassName = element.interfaces.firstOrNull?.getDisplayString();
          final name = superClassName ?? className;

          imports.add(element.library.uri.toString());

          final constructors = element.constructors;

          final constructorParams = switch (constructors.isNotEmpty) {
            true => constructors.first.formalParameters.map((p) {
              imports.add(p.type.element?.library?.uri.toString() ?? '-');
              final found = p.type.getDisplayString().toCamelCase();
              return p.isNamed ? '${p.name}: $found' : found;
            }).toList(),
            false => <String>[],
          };

          repositories.add('final $name ${name?.toCamelCase()} = $className(${constructorParams.join(', ')})');
        } else if (serviceChecker.hasAnnotationOf(element)) {
          final className = element.name;
          final superClassName = element.interfaces.firstOrNull?.getDisplayString();
          final name = superClassName ?? className;

          imports.add(element.library.uri.toString());

          services.add('final $name ${className?.toCamelCase()} = $className()');
        } else if (configurationChecker.hasAnnotationOf(element)) {
          final className = element.name;
          final superClassName = element.interfaces.firstOrNull?.getDisplayString();
          final name = superClassName ?? className;

          imports.add(element.library.uri.toString());

          configurations.add('final $name ${name?.toCamelCase()} = $className()');

          for (final method in element.methods.where((m) => beanChecker.hasAnnotationOf(m))) {
            final methodName = method.name;
            final type = method.type;
            final returnType = type.returnType;

            if (returnType.isDartAsyncFuture || returnType.isDartAsyncFutureOr) {
              final realReturnType = (returnType as ParameterizedType).typeArguments.first;
              imports.add(realReturnType.element?.library?.uri.toString() ?? '');
              beans.add(
                'final ${realReturnType.getDisplayString()} ${realReturnType.getDisplayString().toCamelCase()} = await ${name?.toCamelCase()}.$methodName()',
              );
            } else {
              final methodReturnType = returnType.getDisplayString();

              beans.add(
                'final $methodReturnType ${methodReturnType.toCamelCase()} = ${name?.toCamelCase()}.$methodName()',
              );
            }
          }
        }
      }
    }).toList();

    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');

    buffer.writeln('// POWERED BY SPRING DART\n\n');

    buffer.writeln('import \'package:spring_dart/spring_dart.dart\';');

    buffer.writeln('import \'dart:io\';');

    buffer.writeln('import \'dart:convert\';');

    buffer.writeAll(imports.map((i) => 'import \'$i\';'), '\n');

    buffer.writeln('''class SpringDart {
  final Router router;

  SpringDart._(this.router);

  static Future<SpringDart> create() async {
    final router = Router();

    // Configurations

    ${configurations.map((e) => '$e;').join('\n')}

    // Beans

    ${beans.map((e) => '$e;').join('\n')}

    // Repositories

    ${repositories.map((e) => '$e;').join('\n')}

    // Services

    ${services.map((e) => '$e;').join('\n')}

    // Controllers

    ${controllers.map((e) => '$e;\n').join('\n')}

    return SpringDart._(router);
  }

  Future<HttpServer> start({Object host = '0.0.0.0', int port = 8080}) async {
    final handler = Pipeline().addMiddleware(logRequests()).addHandler(router.call);
    return await serve(handler, host, port);
  }    
}''');

    buffer.writeln(content.join('\n\n'));

    final outputId = AssetId(buildStep.inputId.package, p.join('lib', 'spring_dart.dart'));

    final formatted = DartFormatter(languageVersion: DartFormatter.latestLanguageVersion).format(buffer.toString());

    await buildStep.writeAsString(outputId, formatted);
  }
}
