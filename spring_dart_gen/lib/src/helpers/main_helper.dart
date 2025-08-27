class MainHelper {
  final String package;
  final Set<String> imports;

  const MainHelper(this.package, this.imports);

  String content() {
    return '''import 'package:$package/server.dart';

void main(List<String> args) async => server(args);''';
  }
}
