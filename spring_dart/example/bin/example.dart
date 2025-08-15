import 'package:example/spring_dart.dart';

void main() async {
  final spring = SpringDart();

  await spring.configurer();

  await spring.start();
}
