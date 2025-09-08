import 'package:spring_dart_sql/spring_dart_sql.dart';

class SpringDartHelper {
  final String package;
  final Driver driver;
  final Set<String> imports;
  final Set<({String name, String className, String content})> springDartConfigurations;
  final Set<({String name, String className, String content})> configurations;
  final Set<({String name, String className, String content})> beans;
  final Set<({String name, String className, String content})> components;
  final Set<String> repositories;
  final Set<({String name, String className, String content})> services;
  final Set<({String name, String className, String content})> filters;
  final Set<({String name, String className, String content})> controllers;

  const SpringDartHelper(
    this.package,
    this.driver,
    this.imports,
    this.springDartConfigurations,
    this.configurations,
    this.beans,
    this.components,
    this.repositories,
    this.services,
    this.filters,
    this.controllers,
  );

  String content() {
    imports.add('package:spring_dart/spring_dart.dart');

    final importsSorted = _importsNormalized(imports);

    if (springDartConfigurations.length > 1) {
      throw Exception('Only one SpringDartConfiguration is allowed!');
    }

    return '''// POWERED BY SPRING DART - ${DateTime.now().toIso8601String()}
// GENERATED CODE - DO NOT MODIFY BY HAND

${importsSorted.join('\n')}

Future<void> server(List<String> args) async {
  final injector = Injector.instance;
  final router = Router(notFoundHandler: _defaultNotFoundHandler);${configurations.isNotEmpty ? '''\n// Configurations
  ${configurations.map((e) => '${e.content};').join('\n')}''' : ''}${beans.isNotEmpty ? '''\n// Beans
  ${beans.map((e) => '${e.content};').join('\n')}''' : ''}${beans.isNotEmpty ? 'await injector.commit();' : ''}${components.isNotEmpty ? '''\n // Components
  ${components.map((e) => '${e.content};').join('\n')}''' : ''}${repositories.isNotEmpty ? '''\n// Repositories
  ${repositories.map((e) => '$e;').join('\n')}''' : ''}${services.isNotEmpty ? '''\n// Services
  ${services.map((e) => '${e.content};').join('\n')}''' : ''}${controllers.isNotEmpty ? '''\n// Controllers
  ${controllers.map((e) => '${e.content};').join('\n')}''' : ''}
  // Server Configuration
  Handler handler = router.call;${filters.isNotEmpty ? '''handler = Pipeline()${filters.map((e) => e.content).join('\n')}.addHandler(handler);''' : ''}${springDartConfigurations.isEmpty ? '''final \$defaultServerConfiguration = SpringDartConfiguration.defaultConfiguration;
for (final middleware in \$defaultServerConfiguration.middlewares) {
  handler = middleware(handler);
}
SpringDartDefaults.instance.toEncodable = \$defaultServerConfiguration.toEncodable;
return await \$defaultServerConfiguration.setup(SpringDart((request) => _exceptionHandler(handler, request), injector));''' : springDartConfigurations.map((e) {
            return '''${e.content};
            for (final middleware in ${e.name}.middlewares) {
              handler = middleware(handler);
            }
            SpringDartDefaults.instance.toEncodable = ${e.name}.toEncodable;
            return await ${e.name}.setup(SpringDart((request) => _exceptionHandler(handler, request), injector));''';
          }).join('\n')}
}''';
  }

  List<String> _importsNormalized(Set<String> imports) {
    final dart = <String>[];
    final normalized = <String>[];

    for (final import in imports.map(Uri.parse)) {
      if (import.scheme == 'dart') {
        dart.add(import.toString());
      } else if (import.scheme == 'package' && import.pathSegments.first != package) {
        normalized.add('package:${import.pathSegments.first}/${import.pathSegments.first}.dart');
      } else {
        normalized.add(import.toString());
      }
    }

    dart.sort();

    normalized.sort();

    normalized.removeWhere((i) => i == 'package:spring_dart_core/spring_dart_core.dart');

    return [...dart.map((i) => 'import \'$i\';'), '', ...normalized.map((i) => 'import \'$i\';')];
  }
}
