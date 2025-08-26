class MainHelper {
  final String package;
  final Set<String> imports;

  const MainHelper(this.package, this.imports);

  String content() {
    return '''import 'package:$package/server.dart';

void main(List<String> args) async => server(args);''';
  }
}

String mainHelper({required Set<String> imports}) {
  return '''${imports.map((i) => 'import \'$i\';').join('\n')}

void main(List<String> args) async => SpringDartServer.start(args);''';
}
