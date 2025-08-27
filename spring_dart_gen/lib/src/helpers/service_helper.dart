import 'package:analyzer/dart/element/element.dart';
import 'package:spring_dart_gen/src/extensions/string_ext.dart';

class ServiceHelper {
  final Set<String> imports;
  final Set<({String name, String className, String content})> services;
  final ClassElement element;

  const ServiceHelper(this.imports, this.services, this.element);

  String content() {
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
            'injector.set<$className>(() => $className(${constructorParams.map((e) => 'injector.get()').join(', ')}))',
      ),
    );

    return '';
  }
}
