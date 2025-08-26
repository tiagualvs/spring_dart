import 'package:analyzer/dart/element/element.dart';
import 'package:spring_dart_gen/src/checkers.dart';
import 'package:spring_dart_gen/src/extensions/string_ext.dart';

class ComponentHelper {
  final Set<String> imports;
  final Set<({String name, String className, String content})> filters;
  final Set<({String name, String className, String content})> components;
  final ClassElement element;

  const ComponentHelper(this.imports, this.filters, this.components, this.element);

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

    return '';
  }
}
