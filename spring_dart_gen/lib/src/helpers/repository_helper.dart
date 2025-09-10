import 'package:analyzer/dart/element/element.dart';
import 'package:spring_dart_gen/src/extensions/string_ext.dart';

class RepositoryHelper {
  final Set<String> imports;
  final Set<String> repositories;
  final ClassElement element;

  const RepositoryHelper(this.imports, this.repositories, this.element);

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

    repositories.add(
      'injector.set<$className>(() => $className(${constructorParams.map((e) => 'injector.get()').join(', ')}))',
    );

    return '';
  }
}
