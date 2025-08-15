import 'package:example/spring_dart.dart';

void main() async {
  final spring = await SpringDart.create();

  await spring.start();
}
