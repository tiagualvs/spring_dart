import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:spring_dart_gen/src/checkers.dart';

String controllerHelper(ClassElement element, Set<String> imports, Set<String> controllers) {
  final constructors = element.constructors;
  final controllerPath = controllerChecker.firstAnnotationOf(element)?.getField('path')?.toStringValue() ?? '';
  final controllerClassName = element.name;

  imports.add(element.library.uri.toString());

  final constructorParams = switch (constructors.isNotEmpty) {
    true => constructors.first.formalParameters.map((p) {
      imports.add(p.type.element?.library?.uri.toString() ?? '-');
      final found = 'GetIt.instance.get<${p.type.getDisplayString()}>()';
      return p.isNamed ? '${p.name}: $found' : found;
    }).toList(),
    false => <String>[],
  };

  controllers.add('\'$controllerPath\': ${controllerClassName}Proxy(${constructorParams.join(', ')}).handler');

  return '''class ${controllerClassName}Proxy extends $controllerClassName {
      ${constructors.isNotEmpty ? '''${constructors.first.isConst ? 'const ' : ''}${controllerClassName}Proxy(${constructors.first.formalParameters.map((p) {
          return switch (p.isNamed) {
            true => '${p.name}: this.${p.name}',
            false => 'super.${p.name}',
          };
        }).join(', ')});''' : ''}

      Handler get handler {
        final router = Router();

        ${element.methods.map((method) {
    // Query params
    final queryParameters = method.formalParameters.where((e) => queryChecker.hasAnnotationOf(e)).map((q) => (query: q, name: queryChecker.firstAnnotationOf(q)?.getField('name')?.toStringValue() ?? '')).toList();
    if (!queryParameters.every((q) => stringChecker.isExactlyType(q.query.type))) {
      throw StateError('Query parameters must be a nullable `String` only!');
    }
    if (queryParameters.any((q) => q.query.type.nullabilitySuffix == NullabilitySuffix.none)) {
      throw StateError('Query parameters must be a nullable `String` only!');
    }

    // Path param
    final params = method.formalParameters.where((p) => paramChecker.hasAnnotationOf(p)).map((p) => (param: p, name: paramChecker.firstAnnotationOf(p)?.getField('name')?.toStringValue() ?? '')).toList();
    if (!params.every((p) => stringChecker.isExactlyType(p.param.type))) {
      throw StateError('Path parameters must be `@String` only!');
    }
    if (params.any((p) => p.param.type.nullabilitySuffix != NullabilitySuffix.none)) {
      throw StateError('Path parameters must be `String` only!');
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
      throw StateError('Header parameters must be a nullable `String` only!');
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
      throw StateError('Only classes with @Dto annotation or @Map<String, dynamic> are allowed as body arguments.');
    }

    final routeParams = method.formalParameters.map((e) {
      return switch (e.isNamed) {
        true => '${e.name}: ${e.name}',
        false => '${e.name}',
      };
    });

    // GET METHOD
    if (getChecker.hasAnnotationOf(method)) {
      final routePath = getChecker.firstAnnotationOf(method)?.getField('path')?.toStringValue() ?? '';
      return '''router.get('$routePath', (Request request$paramsString) async {
      ${queryParameters.map((q) {
        return '''    final ${q.name} = request.url.queryParameters['${q.name}'];''';
      }).join('\n')}
      ${headers.map((h) {
        return '''    final ${h.name} = request.headers['${h.name}'];''';
      }).join('\n')}
      ${contexts.map((c) {
        return '''    final ${c.context.name} = request.context['${c.name}'] as ${c.context.type.getDisplayString()};''';
      }).join('\n')}
      return ${method.name}(${routeParams.join(', ')});
  });''';
    }

    // POST METHOD
    if (postChecker.hasAnnotationOf(method)) {
      final routePath = postChecker.firstAnnotationOf(method)?.getField('path')?.toStringValue() ?? '';

      return '''router.post('$routePath', (Request request$paramsString) async {
      ${queryParameters.map((q) {
        return '''    final ${q.name} = request.url.queryParameters['${q.name}'];''';
      }).join('\n')}
      ${headers.map((h) {
        return '''    final ${h.name} = request.headers['${h.name}'];''';
      }).join('\n')}
      ${contexts.map((c) {
        return '''    final ${c.context.name} = request.context['${c.name}'] as ${c.context.type.getDisplayString()};''';
      }).join('\n')}
      ${dtos.map((p) {
        final dtoType = p.type.getDisplayString();
        final dtoName = p.name;

        if (!jsonChecker.isExactlyType(p.type)) {
          imports.add(p.type.element?.library?.uri.toString() ?? '');

          return '''  final body = json.decode(await request.readAsString());

        final $dtoName = $dtoType(
          ${classElementToString(p.type.element as ClassElement)}
        );''';
        } else {
          return '''  final $dtoName = json.decode(await request.readAsString()) as Map<String, dynamic>;''';
        }
      }).join('\n')}

        return ${method.name}(${routeParams.join(', ')});
      });''';
    }

    if (putChecker.hasAnnotationOf(method)) {
      final routePath = putChecker.firstAnnotationOf(method)?.getField('path')?.toStringValue() ?? '';

      return '''router.put('$routePath', (Request request$paramsString) async {
      ${queryParameters.map((q) {
        return '''    final ${q.name} = request.url.queryParameters['${q.name}'];''';
      }).join('\n')}
      ${headers.map((h) {
        return '''    final ${h.name} = request.headers['${h.name}'];''';
      }).join('\n')}
      ${contexts.map((c) {
        return '''    final ${c.context.name} = request.context['${c.name}'] as ${c.context.type.getDisplayString()};''';
      }).join('\n')}
      ${dtos.map((p) {
        final dtoType = p.type.getDisplayString();
        final dtoName = p.name;

        if (!jsonChecker.isExactlyType(p.type)) {
          imports.add(p.type.element?.library?.uri.toString() ?? '');

          return '''  final body = json.decode(await request.readAsString());

        final $dtoName = $dtoType(
          ${classElementToString(p.type.element as ClassElement)}
        );''';
        } else {
          return '''  final $dtoName = json.decode(await request.readAsString()) as Map<String, dynamic>;''';
        }
      }).join('\n')}

        return ${method.name}(${routeParams.join(', ')});
      });''';
    }

    if (deleteChecker.hasAnnotationOf(method)) {
      final routePath = deleteChecker.firstAnnotationOf(method)?.getField('path')?.toStringValue() ?? '';

      return '''router.delete('$routePath', (Request request$paramsString) async {
      ${queryParameters.map((q) {
        return '''    final ${q.name} = request.url.queryParameters['${q.name}'];''';
      }).join('\n')}
      ${headers.map((h) {
        return '''    final ${h.name} = request.headers['${h.name}'];''';
      }).join('\n')}
      ${contexts.map((c) {
        return '''    final ${c.context.name} = request.context['${c.name}'] as ${c.context.type.getDisplayString()};''';
      }).join('\n')}
      ${dtos.map((p) {
        final dtoType = p.type.getDisplayString();
        final dtoName = p.name;

        if (!jsonChecker.isExactlyType(p.type)) {
          imports.add(p.type.element?.library?.uri.toString() ?? '');

          return '''  final body = json.decode(await request.readAsString());

        final $dtoName = $dtoType(
          ${classElementToString(p.type.element as ClassElement)}
        );''';
        } else {
          return '''  final $dtoName = json.decode(await request.readAsString()) as Map<String, dynamic>;''';
        }
      }).join('\n')}

       return ${method.name}(${routeParams.join(', ')});
      });''';
    }

    if (patchChecker.hasAnnotationOf(method)) {}

    if (headChecker.hasAnnotationOf(method)) {}

    if (optionsChecker.hasAnnotationOf(method)) {}

    if (traceChecker.hasAnnotationOf(method)) {}

    if (connectChecker.hasAnnotationOf(method)) {}
  }).join('\n\n')}

        return router.call;
      }
  }''';
}

String classElementToString(ClassElement element) {
  final className = element.name;
  final constructors = element.constructors;
  if (constructors.isEmpty) throw StateError('Class $className has no constructors.');
  final constructor = constructors.first;
  final content = List.from(
    constructor.formalParameters.map((e) {
      return switch (e.isNamed) {
        true => '${e.name}: body[\'${e.name}\']',
        false => 'body[\'${e.name}\']',
      };
    }),
  );
  return content.join(',\n');
}
