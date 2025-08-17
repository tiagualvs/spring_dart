String mainHelper({required Set<String> imports}) {
  return '''${imports.map((i) => 'import \'$i\';').join('\n')}

void main(List<String> args) async => SpringDartServer.start(args);''';
}
