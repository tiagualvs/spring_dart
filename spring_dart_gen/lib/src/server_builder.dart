import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

import 'checkers.dart';
import 'controller_helper.dart';
import 'extensions/string_ext.dart';

class ServerBuilder extends Builder {
  late final Map<String, List<String>> _buildExtensions;

  ServerBuilder() {
    final package = p.basename(Directory.current.path);

    _buildExtensions = {
      r'$package$': [p.join('bin', '$package.dart')],
    };
  }

  @override
  Map<String, List<String>> get buildExtensions => _buildExtensions;

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final buffer = StringBuffer();

    final imports = <String>{};

    final beans = <String>{};

    final configurations = <String>{};

    final services = <String>{};

    final filters = <({String name, String className})>{};

    final controllers = <String>{};

    final repositories = <String>{};

    final springDartConfiguration = <({String name, String className})>{};

    final content = await buildStep.findAssets(Glob('lib/**.dart')).asyncExpand((assetId) async* {
      final library = await buildStep.resolver.libraryFor(assetId);
      final reader = LibraryReader(library);

      for (final element in reader.classes) {
        if (controllerChecker.hasAnnotationOf(element)) {
          yield controllerHelper(element, imports, controllers);
        } else if (componentChecker.hasAnnotationOf(element)) {
          final className = element.name;

          imports.add(element.library.uri.toString());

          final superType = element.supertype;

          if (superType != null && filterChecker.isExactly(superType.element)) {
            filters.add((name: className?.toCamelCase() ?? '', className: className ?? ''));
          }
        } else if (repositoryChecker.hasAnnotationOf(element)) {
          final className = element.name;
          final superClassName = element.interfaces.firstOrNull?.getDisplayString();
          final name = superClassName ?? className;

          imports.add(element.library.uri.toString());

          final constructors = element.constructors;

          final constructorParams = switch (constructors.isNotEmpty) {
            true => constructors.first.formalParameters.map((p) {
              final found = p.type.getDisplayString().toCamelCase();
              return p.isNamed ? '${p.name}: $found' : found;
            }).toList(),
            false => <String>[],
          };

          repositories.add('final ${name?.toCamelCase()} = $className(${constructorParams.join(', ')})');
        } else if (serviceChecker.hasAnnotationOf(element)) {
          final className = element.name;

          imports.add(element.library.uri.toString());

          services.add('final ${className?.toCamelCase()} = $className()');
        } else if (configurationChecker.hasAnnotationOf(element)) {
          final className = element.name;

          imports.add(element.library.uri.toString());

          final superType = element.supertype;

          if (superType != null && springDartConfigurationChecker.isExactly(superType.element)) {
            springDartConfiguration.add((name: className?.toCamelCase() ?? '', className: className ?? ''));
          } else {
            configurations.add('final ${className?.toCamelCase()} = $className()');

            for (final method in element.methods.where((m) => beanChecker.hasAnnotationOf(m))) {
              final methodName = method.name;
              final type = method.type;
              final returnType = type.returnType;

              if (returnType.isDartAsyncFuture || returnType.isDartAsyncFutureOr) {
                final realReturnType = (returnType as ParameterizedType).typeArguments.first;
                beans.add(
                  'final ${realReturnType.getDisplayString().toCamelCase()} = await ${className?.toCamelCase()}.$methodName()',
                );
              } else {
                final methodReturnType = returnType.getDisplayString();

                beans.add('final ${methodReturnType.toCamelCase()} = ${className?.toCamelCase()}.$methodName()');
              }
            }
          }
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
  ${configurations.map((e) => '$e;').join('\n')}''' : ''}${beans.isNotEmpty ? '''\n// Beans
  ${beans.map((e) => '$e;').join('\n')}''' : ''}${repositories.isNotEmpty ? '''\n// Repositories
  ${repositories.map((e) => '$e;').join('\n')}''' : ''}${services.isNotEmpty ? '''\n// Services
  ${services.map((e) => '$e;').join('\n')}''' : ''}${controllers.isNotEmpty ? '''\n// Controllers
  ${controllers.map((e) => '$e;').join('\n')}''' : ''}
  // Server Configuration
  Handler handler = router.call;${filters.isNotEmpty ? '''handler = Pipeline()${filters.map((e) {
            return '''.addMiddleware(${e.className}().toShelfMiddleware)''';
          }).join('\n')}.addHandler(handler);''' : ''}${springDartConfiguration.isEmpty ? '''final \$defaultServerConfiguration = SpringDartConfiguration.defaultConfiguration;
return await \$defaultServerConfiguration.setup(SpringDart(handler));''' : springDartConfiguration.map((e) {
            return '''final ${e.name} = ${e.className}();
            for (final middleware in ${e.name}.middlewares) {
              handler = middleware(handler);
            }
            return await ${e.name}.setup(SpringDart(handler));''';
          }).join('\n')}
}''');

    buffer.writeln(content.join('\n\n'));

    final outputId = AssetId(buildStep.inputId.package, p.join('bin', '${buildStep.inputId.package}.dart'));

    final formatted = DartFormatter(languageVersion: DartFormatter.latestLanguageVersion).format(buffer.toString());

    await buildStep.writeAsString(outputId, formatted);
  }
}
