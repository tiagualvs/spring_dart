import 'package:analyzer/dart/element/element.dart';
import 'package:spring_dart_gen/src/checkers.dart';
import 'package:spring_dart_gen/src/extensions/string_ext.dart';

class ControllerAdviceHelper {
  final Set<String> imports;
  final Set<({String name, String className, String content, List<MethodElement> methods})> controllerAdvices;
  final ClassElement element;

  const ControllerAdviceHelper(this.imports, this.controllerAdvices, this.element);

  String content() {
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

    if (methods.isEmpty) return '';

    imports.add(element.library.uri.toString());

    for (final method in methods) {
      imports.add(method.type.element?.library?.uri.toString() ?? '');
    }

    controllerAdvices.add(
      (
        className: className ?? '',
        name: className?.toCamelCase() ?? '',
        content: 'final ${className?.toCamelCase()} = $className()',
        methods: methods.map((m) => m.method).toList(),
      ),
    );
    return '';
  }
}
