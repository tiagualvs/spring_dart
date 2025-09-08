import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:spring_dart_gen/src/helpers/component_helper.dart';
import 'package:spring_dart_gen/src/helpers/configuration_helper.dart';
import 'package:spring_dart_gen/src/helpers/controller_advice_helper.dart';
import 'package:spring_dart_gen/src/helpers/main_helper.dart';
import 'package:spring_dart_gen/src/helpers/repository_helper.dart';
import 'package:spring_dart_gen/src/helpers/service_helper.dart';
import 'package:spring_dart_gen/src/helpers/spring_dart_helper.dart';
import 'package:spring_dart_gen/src/helpers/table_helper.dart';
import 'package:spring_dart_sql/spring_dart_sql.dart';
import 'package:yaml/yaml.dart';

import '../checkers.dart';
import '../helpers/controller_helper.dart';
import '../helpers/entity_helper.dart';

typedef ClassContent = ({String name, String className, String content});

class ServerBuilder extends Builder {
  late final Driver driver;
  late final Map<String, List<String>> _buildExtensions;

  ServerBuilder() {
    final pubspec = loadYaml(File(p.join(Directory.current.path, 'pubspec.yaml')).readAsStringSync());

    final package = pubspec['name'] as String? ?? 'server';

    if (File(p.join(Directory.current.path, 'config.yaml')).existsSync()) {
      final config = loadYaml(File(p.join(Directory.current.path, 'config.yaml')).readAsStringSync());
      driver = Driver.fromConfig(Map<String, dynamic>.from(config));
    } else {
      driver = NoneDriver();
    }

    final dependencies = pubspec['dependencies'] as YamlMap? ?? {};

    if ((driver is SqliteFileDriver || driver is SqliteMemoryDriver) && !dependencies.containsKey('sqlite3')) {
      throw Exception('sqlite3 package not found!');
    }

    if (driver is PostgresDriver && !dependencies.containsKey('postgres')) {
      throw Exception('postgres package not found!');
    }

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

    final springDartConfigurations = <ClassContent>{};

    final entities = <ClassContent>{};

    final controllerAdvices = <({String name, String className, String content, List<MethodElement> methods})>{};

    final tables = <({String name, String up, String down, Set<String> references})>{};

    final body = await buildStep.findAssets(Glob('lib/**.dart')).asyncExpand((assetId) async* {
      final library = await buildStep.resolver.libraryFor(assetId);
      final reader = LibraryReader(library);

      for (final element in reader.classes) {
        if (configurationChecker.hasAnnotationOf(element)) {
          yield ConfigurationHelper(imports, configurations, beans, springDartConfigurations, element).content();
        } else if (componentChecker.hasAnnotationOf(element)) {
          yield ComponentHelper(imports, filters, components, element).content();
        } else if (repositoryChecker.hasAnnotationOf(element)) {
          yield RepositoryHelper(imports, repositories, element).content();
        } else if (serviceChecker.hasAnnotationOf(element)) {
          yield ServiceHelper(imports, services, element).content();
        } else if (controllerChecker.hasAnnotationOf(element)) {
          yield ControllerHelper(imports, controllers, element).content();
        } else if (entityChecker.hasAnnotationOf(element)) {
          yield EntityHelper(imports, repositories, driver, element, entities, tables).content();
        } else if (controllerAdviceChecker.hasAnnotationOf(element)) {
          yield ControllerAdviceHelper(imports, controllerAdvices, element).content();
        }
      }
    }).toList();

    buffer.writeln(
      SpringDartHelper(
        buildStep.inputId.package,
        driver,
        imports,
        springDartConfigurations,
        configurations,
        beans,
        components,
        repositories,
        services,
        filters,
        controllers,
      ).content(),
    );

    buffer.writeln(body.join('\n\n'));

    buffer.writeln(TableHelper(driver, imports, repositories, tables).content());

    buffer.writeln(defaultNotFoundHandler());

    buffer.writeln(exceptionHandlerHelper(controllerAdvices));

    final entryPointAssetId = AssetId(buildStep.inputId.package, p.join('bin', '${buildStep.inputId.package}.dart'));

    final serverAssetId = AssetId(buildStep.inputId.package, p.join('lib', 'server.dart'));

    final formatter = DartFormatter(languageVersion: DartFormatter.latestLanguageVersion);

    await buildStep.writeAsString(serverAssetId, formatter.format(buffer.toString()));

    await buildStep.writeAsString(
      entryPointAssetId,
      formatter.format(MainHelper(buildStep.inputId.package, imports).content()),
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
    ${exceptionHandler.isNotEmpty ? ''' ${exceptionHandler.map((e) => e.methods.map((m) => '''if (e is ${exceptionHandlerChecker.firstAnnotationOf(m)?.getField('exception')?.toTypeValue()}) {
      return ${e.className}().${m.name}(e);
    }''').join('else \n')).join('\n')}
    else {
      return Json(
      500,
      body: {
        'error': e.toString(),
      },
    );
    }''' : '''return Json(
  500,
  body: {
    'error': e.toString(),
  },
);'''}
  }
}''';
  }
}
