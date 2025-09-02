import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:spring_dart_core/spring_dart_core.dart';
import 'package:spring_dart_gen/src/checkers.dart';
import 'package:spring_dart_gen/src/extensions/iterable_ext.dart';
import 'package:spring_dart_gen/src/extensions/string_ext.dart';
import 'package:spring_dart_gen/src/helpers/entity_helper.dart';

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

        final contentType = contentTypeExtractor(method);

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

        // Body
        final bodies = method.formalParameters.where((e) => bodyChecker.hasAnnotationOf(e)).toList();

        if (bodies.isNotEmpty) imports.add('dart:convert');

        final everyDtoHasAnnotation = switch (contentType is ApplicationJson && bodies.isNotEmpty) {
          true => bodies.any(
            (d) {
              if (jsonChecker.isExactlyType(d.type)) return true;
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
          ),
          false => true,
        };

        if (!everyDtoHasAnnotation) {
          throw Exception('${element.name}/${method.name} - Only classes with @Dto annotation or @Map<String, dynamic> are allowed as body arguments.');
        }

        final routeParams = method.formalParameters.map((e) {
          return switch (e.isNamed) {
            true => '${e.name}: ${e.name}',
            false => '${e.name}',
          };
        });

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

        methodBuffer.write(switch (contentType is MultipartFormData) {
          true => '''final \$contentLength = request.contentLength ?? 0;
            final \$controller = StreamController<FormField>.broadcast();
            final ${routeParams.first} = Form(\$contentLength, \$controller.stream);
            if (request.formData() case var form?) {
              form.formData.map(FormField.fromFormData).listen(\$controller.add, onDone: \$controller.close, onError: \$controller.addError);
            }''',
          _ => '',
        });

        final validators = <String>[];

        methodBuffer.write(
          switch (contentType is ApplicationJson) {
            true => bodies.map((p) {
              final validated = validatedChecker.hasAnnotationOf(p);
              final dtoElement = p.type.element as ClassElement;
              final dtoFields = dtoElement.fields;
              final dtoConstructors = dtoElement.constructors;
              final dtoConstructor = dtoConstructors.firstWhereOrNull((c) => c.formalParameters.isNotEmpty);
              if (dtoConstructor == null) throw Exception('dto_constructor_not_found');
              final dtoName = p.name;

              if (!jsonChecker.isExactlyType(p.type)) {
                if (validated) {
                  for (final field in dtoFields) {
                    final email = validatorChecker.email.firstAnnotationOf(field);
                    if (email != null) {
                      validators.add('''if (!Validators.isEmail($dtoName.${field.name})) BadRequestException('${email.getField('(super)')?.getField('message')?.toStringValue()}')''');
                    }
                    final notNull = validatorChecker.notNull.firstAnnotationOf(field);
                    if (notNull != null) {
                      validators.add('''if (!Validators.isNotNull($dtoName.${field.name})) BadRequestException('${notNull.getField('(super)')?.getField('message')?.toStringValue()}')''');
                    }
                    final notEmpty = validatorChecker.notEmpty.firstAnnotationOf(field);
                    if (notEmpty != null) {
                      validators.add('''if (!Validators.isNotEmpty($dtoName.${field.name})) BadRequestException('${notEmpty.getField('(super)')?.getField('message')?.toStringValue()}')''');
                    }
                    final patterns = validatorChecker.pattern.annotationsOf(field);
                    for (final pattern in patterns) {
                      final patternString = pattern.getField('regexp')?.toStringValue() ?? '';
                      validators.add('''if (!Validators.patternMatches($dtoName.${field.name}, r'$patternString')) BadRequestException('${pattern.getField('(super)')?.getField('message')?.toStringValue()}')''');
                    }
                    final min = validatorChecker.min.firstAnnotationOf(field);
                    if (min != null) {
                      final minInt = min.getField('value')?.toIntValue();
                      validators.add('''if (!Validators.isGreaterThanOrEqual($dtoName.${field.name}, $minInt)) BadRequestException('${min.getField('(super)')?.getField('message')?.toStringValue()}')''');
                    }
                    final max = validatorChecker.max.firstAnnotationOf(field);
                    if (max != null) {
                      final maxInt = max.getField('value')?.toIntValue();
                      validators.add('''if (!Validators.isLessThanOrEqual($dtoName.${field.name}, $maxInt)) BadRequestException('${max.getField('(super)')?.getField('message')?.toStringValue()}')''');
                    }
                    final size = validatorChecker.size.firstAnnotationOf(field);
                    if (size != null) {
                      final minInt = size.getField('min')?.toIntValue();
                      final maxInt = size.getField('max')?.toIntValue();
                      validators.add('''if (!Validators.isBetween($dtoName.${field.name}, $minInt, $maxInt)) BadRequestException('${size.getField('(super)')?.getField('message')?.toStringValue()}')''');
                    }
                    final gt = validatorChecker.greaterThan.firstAnnotationOf(field);
                    if (gt != null) {
                      final gtInt = gt.getField('value')?.toIntValue();
                      validators.add('''if (!Validators.isGreaterThan($dtoName.${field.name}, $gtInt)) BadRequestException('${gt.getField('(super)')?.getField('message')?.toStringValue()}')''');
                    }
                    final gte = validatorChecker.greaterThanOrEqual.firstAnnotationOf(field);
                    if (gte != null) {
                      final gteInt = gte.getField('value')?.toIntValue();
                      validators.add('''if (!Validators.isGreaterThanOrEqual($dtoName.${field.name}, $gteInt)) BadRequestException('${gte.getField('(super)')?.getField('message')?.toStringValue()}')''');
                    }
                    final lt = validatorChecker.lessThan.firstAnnotationOf(field);
                    if (lt != null) {
                      final ltInt = lt.getField('value')?.toIntValue();
                      validators.add('''if (!Validators.isLessThan($dtoName.${field.name}, $ltInt)) BadRequestException('${lt.getField('(super)')?.getField('message')?.toStringValue()}')''');
                    }
                    final lte = validatorChecker.lessThanOrEqual.firstAnnotationOf(field);
                    if (lte != null) {
                      final lteInt = lte.getField('value')?.toIntValue();
                      validators.add('''if (!Validators.isLessThanOrEqual($dtoName.${field.name}, $lteInt)) BadRequestException('${lte.getField('(super)')?.getField('message')?.toStringValue()}')''');
                    }
                  }
                }

                imports.add(p.type.element?.library?.uri.toString() ?? '');

                final parsers = (p.type.element as ClassElement).fields.where((f) => withParserChecker.hasAnnotationOf(f)).map((f) => (
                  field: f,
                  type: withParserChecker.firstAnnotationOf(f)?.getField('parser')?.toTypeValue()!,
                )).toList();

                for (final parser in parsers) {
                  imports.add(parser.type?.element?.library?.uri.toString() ?? '');
                }

                return '''
          final \$json = await request.readAsString();
          final \$body = Map<String, dynamic>.from(json.decode(\$json));
          final $dtoName = ${buildObjectFromConstructor(classElement: dtoElement, valueBuilder: (v) => '\$body[\'$v\']')};''';
              } else {
                return '''
          final \$json = await request.readAsString();
          final $dtoName = Map<String, dynamic>.from(json.decode(\$json));''';
              }
            }).join('\n'),
            _ => '',
          },
        );

        return '''router.$verb('$routePath', (Request request$paramsString) async {
        $methodBuffer${validators.isNotEmpty ? '''final \$exceptions = <SpringDartException>[${validators.join(', ')}];
        if (\$exceptions.isNotEmpty) {
          throw CustomException(400, \$exceptions, 'Request validation fail!');
        }''' : ''}
        return ${method.name}(${routeParams.join(', ')});
      });''';
      }
    }).join('\n\n')}
        return router.call(request);
      }
  }''';
  }
}
