import 'dart:async';

import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:spring_dart_gen/src/checkers.dart';

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

    final controllers = <String>{};

    final injector = <String>{};

    final content = await buildStep.findAssets(Glob('lib/**.dart')).asyncExpand((assetId) async* {
      final library = await buildStep.resolver.libraryFor(assetId);
      final reader = LibraryReader(library);

      for (final element in reader.classes) {
        if (controllerChecker.hasAnnotationOf(element)) {
          yield controllerHelper(element, imports, controllers);
        } else if (repositoryChecker.hasAnnotationOf(element)) {
          final className = element.name;
          final superClassName = element.interfaces.firstOrNull?.getDisplayString();

          imports.add(element.library.uri.toString());

          injector.add('getIt.registerFactory<${superClassName ?? className}>(() => $className())');
        } else if (serviceChecker.hasAnnotationOf(element)) {
          final className = element.name;

          imports.add(element.library.uri.toString());

          injector.add('getIt.registerFactory<$className>(() => $className())');
        } else if (configurationChecker.hasAnnotationOf(element)) {
          final className = element.name;

          imports.add(element.library.uri.toString());

          injector.add('getIt.registerFactory<$className>(() => $className())');

          for (final method in element.methods.where((m) => beanChecker.hasAnnotationOf(m))) {
            final methodName = method.name;

            injector.add(
              'getIt.registerFactory<${method.type.returnType.getDisplayString()}>(() => getIt.get<$className>().$methodName())',
            );
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
  late final controllers = <String, Handler>{
    ${controllers.join(', ')}
  };

  Future<void> configurer() async {
    final getIt = GetIt.instance;

    ${injector.map((e) => '$e;').join('\n')}
  }

  Future<HttpServer> start({Object host = '0.0.0.0', int port = 8080}) async {
    final Router router = Router();

    for (final controller in controllers.entries) {
      router.mount(controller.key, controller.value);
    }

    return await serve(router.call, host, port);
  }    
}''');

    buffer.writeln(content.join('\n\n'));

    final outputId = AssetId(buildStep.inputId.package, p.join('lib', 'spring_dart.dart'));

    final formatted = DartFormatter(languageVersion: DartFormatter.latestLanguageVersion).format(buffer.toString());

    await buildStep.writeAsString(outputId, formatted);
  }
}
