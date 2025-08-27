import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:spring_dart_gen/src/checkers.dart';
import 'package:spring_dart_gen/src/extensions/iterable_ext.dart';
import 'package:spring_dart_gen/src/extensions/string_ext.dart';

class ControllerHelper {
  final Set<String> imports;
  final Set<({String name, String className, String content})> controllers;
  final ClassElement element;

  const ControllerHelper(this.imports, this.controllers, this.element);

  String content() {
    final constructors = element.constructors;
    final controllerPath = controllerChecker.firstAnnotationOf(element)?.getField('path')?.toStringValue() ?? '';
    final controllerClassName = element.name;

    imports.add(element.library.uri.toString());

    imports.add('dart:async');

    final constructorParams = switch (constructors.isNotEmpty) {
      true => constructors.first.formalParameters.map((p) {
        final found = p.type.getDisplayString().toCamelCase();
        return p.isNamed ? '${p.name}: $found' : found;
      }).toList(),
      false => <String>[],
    };

    controllers.add(
      (
        name: '${controllerClassName?.toCamelCase()}',
        className: controllerClassName ?? '',
        content:
            'final ${controllerClassName?.toCamelCase()} = _\$$controllerClassName(${constructorParams.map((e) => 'injector.get()').join(', ')})',
        // content: 'final ${controllerClassName?.toCamelCase()} = _\$$controllerClassName(${constructorParams.join(', ')})',
      ),
    );

    controllers.add(
      (
        name: '${controllerClassName?.toCamelCase()}',
        className: controllerClassName ?? '',
        content: 'router.mount(\'$controllerPath\', ${controllerClassName?.toCamelCase()}.handler)',
      ),
    );

    return '''class _\$$controllerClassName extends $controllerClassName {
      ${constructors.isNotEmpty ? '''${constructors.first.isConst ? 'const ' : ''}_\$$controllerClassName(${constructors.first.formalParameters.map((p) {
            return switch (p.isNamed) {
              true => '${p.name}: this.${p.name}',
              false => 'super.${p.name}',
            };
          }).join(', ')});''' : ''}

      FutureOr<Response> handler(Request request) async {
        final router = Router();

        ${element.methods.map((method) {
      // Query params
      final queryParameters = method.formalParameters.where((e) => queryChecker.hasAnnotationOf(e)).map((q) => (query: q, name: queryChecker.firstAnnotationOf(q)?.getField('name')?.toStringValue() ?? '')).toList();
      if (!queryParameters.every((q) => stringChecker.isExactlyType(q.query.type))) {
        throw Exception('Query parameters must be a nullable `String` only!');
      }
      if (queryParameters.any((q) => q.query.type.nullabilitySuffix == NullabilitySuffix.none)) {
        throw Exception('Query parameters must be a nullable `String` only!');
      }

      // Path param
      final params = method.formalParameters.where((p) => paramChecker.hasAnnotationOf(p)).map((p) => (param: p, name: paramChecker.firstAnnotationOf(p)?.getField('name')?.toStringValue() ?? '')).toList();
      if (!params.every((p) => stringChecker.isExactlyType(p.param.type))) {
        throw Exception('Path parameters must be `@String` only!');
      }
      if (params.any((p) => p.param.type.nullabilitySuffix != NullabilitySuffix.none)) {
        throw Exception('Path parameters must be `String` only!');
      }
      final paramsString = switch (params.isEmpty) {
        true => '',
        false => ', ${params.map((p) => '${p.param.type.getDisplayString()} ${p.param.name}').join(', ')}',
      };

      // Context param
      final contexts = method.formalParameters.where((c) => contextChecker.hasAnnotationOf(c)).map((c) => (context: c, name: contextChecker.firstAnnotationOf(c)?.getField('name')?.toStringValue() ?? '')).toList();

      // Header param
      final headers = method.formalParameters.where((h) => headerChecker.hasAnnotationOf(h));
      if (headers.any((h) => h.type.nullabilitySuffix == NullabilitySuffix.none)) {
        throw Exception('Header parameters must be a nullable `String` only!');
      }

      // Dtos
      final dtos = method.formalParameters.where((e) => bodyChecker.hasAnnotationOf(e)).toList();
      final everyDtoHasAnnotation = dtos.isEmpty ? true : dtos.any(
              (d) {
                if (jsonChecker.isExactlyType(d.type)) {
                  return true;
                }
                final dtoElement = d.type.element;
                if (dtoElement == null) return false;
                return dtoElement.metadata.annotations.any(
                  (a) {
                    final type = a.computeConstantValue()?.type;
                    if (type == null) return false;
                    return dtoChecker.isExactlyType(type);
                  },
                );
              },
            );
      if (!everyDtoHasAnnotation) {
        throw Exception('Only classes with @Dto annotation or @Map<String, dynamic> are allowed as body arguments.');
      }

      final routeParams = method.formalParameters.map((e) {
        return switch (e.isNamed) {
          true => '${e.name}: ${e.name}',
          false => '${e.name}',
        };
      });

      if (getChecker.hasAnnotationOf(method) //
          || postChecker.hasAnnotationOf(method) //
          || putChecker.hasAnnotationOf(method) //
          || deleteChecker.hasAnnotationOf(method) //
          || patchChecker.hasAnnotationOf(method) //
          || headChecker.hasAnnotationOf(method) //
          || optionsChecker.hasAnnotationOf(method) //
          || traceChecker.hasAnnotationOf(method) //
          || connectChecker.hasAnnotationOf(method) //
          ) {
        final annotation = getChecker.firstAnnotationOf(method) //
            ?? postChecker.firstAnnotationOf(method) //
            ?? putChecker.firstAnnotationOf(method) //
            ?? deleteChecker.firstAnnotationOf(method) //
            ?? patchChecker.firstAnnotationOf(method) //
            ?? headChecker.firstAnnotationOf(method) //
            ?? optionsChecker.firstAnnotationOf(method) //
            ?? traceChecker.firstAnnotationOf(method) //
            ?? connectChecker.firstAnnotationOf(method);

        final verb = switch (annotation?.type?.getDisplayString()) {
          'Post' => 'post',
          'Put' => 'put',
          'Delete' => 'delete',
          'Get' => 'get',
          'Patch' => 'patch',
          'Head' => 'head',
          'Options' => 'options',
          'Trace' => 'trace',
          'Connect' => 'connect',
          _ => 'get',
        };

        final methodBuffer = StringBuffer();
        final routePath = getChecker.firstAnnotationOf(method)?.getField('path')?.toStringValue() //
            ?? postChecker.firstAnnotationOf(method)?.getField('path')?.toStringValue() //
            ?? putChecker.firstAnnotationOf(method)?.getField('path')?.toStringValue() //
            ?? deleteChecker.firstAnnotationOf(method)?.getField('path')?.toStringValue() //
            ?? patchChecker.firstAnnotationOf(method)?.getField('path')?.toStringValue() //
            ?? headChecker.firstAnnotationOf(method)?.getField('path')?.toStringValue() //
            ?? optionsChecker.firstAnnotationOf(method)?.getField('path')?.toStringValue() //
            ?? traceChecker.firstAnnotationOf(method)?.getField('path')?.toStringValue() //
            ?? connectChecker.firstAnnotationOf(method)?.getField('path')?.toStringValue() //
            ?? '';

        methodBuffer.write(
          switch (queryParameters.isEmpty) {
            true => '',
            false => queryParameters.map((q) {
              return '''    final ${q.name} = request.url.queryParameters['${q.name}'];''';
            }).join('\n'),
          },
        );

        methodBuffer.write(
          switch (headers.isEmpty) {
            true => '',
            false => headers.map((h) {
              return '''    final ${h.name} = request.headers['${h.name}'];''';
            }).join('\n'),
          },
        );

        methodBuffer.write(
          switch (contexts.isEmpty) {
            true => '',
            false => contexts.map((c) {
              return '''final ${c.context.name} = request.context['${c.name}'] as ${c.context.type.getDisplayString()};''';
            }).join('\n'),
          },
        );

        methodBuffer.write(
          switch (dtos.isEmpty) {
            true => '',
            false => dtos.map((p) {
              final dtoType = p.type.getDisplayString();
              final dtoName = p.name;

              if (!jsonChecker.isExactlyType(p.type)) {
                imports.add(p.type.element?.library?.uri.toString() ?? '');

                final keys = (p.type.element as ClassElement).fields.where((f) => jsonKeyChecker.hasAnnotationOf(f)).map((f) => (
                  field: f,
                  key: jsonKeyChecker.firstAnnotationOf(f)?.getField('name')?.toStringValue() ?? '',
                )).toList();

                final parsers = (p.type.element as ClassElement).fields.where((f) => withParserChecker.hasAnnotationOf(f)).map((f) => (
                  field: f,
                  type: withParserChecker.firstAnnotationOf(f)?.getField('parser')?.toTypeValue()!,
                )).toList();

                for (final parser in parsers) {
                  imports.add(parser.type?.element?.library?.uri.toString() ?? '');
                }

                return '''
          final \$json = await request.readAsString();
          final \$body = Map<String, dynamic>.from(json.decode(\$json));${switch (parsers.isEmpty) {
                  true => '',
                  false => parsers.map((p) {
                    final key = keys.firstWhereOrNull((k) => k.field.name == p.field.name)?.key ?? p.field.name;

                    return '''final ${p.type?.getDisplayString().toCamelCase()} = ${p.type?.getDisplayString()}();
          \$body['$key'] = ${p.type?.getDisplayString().toCamelCase()}.decode(\$body['$key']);''';
                  }).join('\n'),
                }}
          final \$dson = DSON();
          final $dtoName = \$dson.fromJson<$dtoType>(
            \$body, 
            $dtoType.new,
            ${switch (keys.isNotEmpty) {
                  true => '''aliases: {
                ${keys.map((k) {
                    return '''${p.type.getDisplayString()}: {'${k.field.name}' : '${k.key}'},''';
                  }).join(',\n')}
              }''',
                  false => '',
                }}
          );''';
              } else {
                return '''
          final \$json = await request.readAsString();
          final $dtoName = Map<String, dynamic>.from(json.decode(\$json));''';
              }
            }).join('\n'),
          },
        );

        return '''router.$verb('$routePath', (Request request$paramsString) async {
        $methodBuffer
        return ${method.name}(${routeParams.join(', ')});
      });''';
      }
    }).join('\n\n')}
        return router.call(request);
      }
  }''';
  }
}
