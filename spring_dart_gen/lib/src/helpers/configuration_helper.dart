import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:spring_dart_gen/src/checkers.dart';
import 'package:spring_dart_gen/src/extensions/string_ext.dart';

class ConfigurationHelper {
  final Set<String> imports;
  final Set<({String name, String className, String content})> configurations;
  final Set<({String name, String className, String content})> beans;
  final Set<({String name, String className, String content})> springDartConfigurations;
  final ClassElement element;

  const ConfigurationHelper(this.imports, this.configurations, this.beans, this.springDartConfigurations, this.element);

  String content() {
    final className = element.name;

    imports.add(element.library.uri.toString());

    final superType = element.supertype;

    if (superType != null && springDartConfigurationChecker.isExactly(superType.element)) {
      springDartConfigurations.add(
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

          final uri = realReturnType.element?.library?.uri;

          if (uri != null && uri.scheme == 'package') {
            final package = uri.pathSegments.first;

            imports.add('package:$package/$package.dart');
          } else {
            imports.add(uri?.toString() ?? '');
          }

          beans.add(
            (
              name: realReturnType.getDisplayString().toCamelCase(),
              className: className ?? '',
              content:
                  'getIt.registerLazySingletonAsync<${realReturnType.getDisplayString()}>(() => ${className?.toCamelCase()}.$methodName())',
            ),
          );
        } else {
          final methodReturnType = returnType.getDisplayString();

          imports.add(returnType.element?.library?.uri.toString() ?? '');

          beans.add(
            (
              name: methodReturnType.toCamelCase(),
              className: className ?? '',
              content:
                  'getIt.registerLazySingleton<$methodReturnType>(() => ${className?.toCamelCase()}.$methodName())',
            ),
          );
        }
      }
    }

    return '';
  }
}
