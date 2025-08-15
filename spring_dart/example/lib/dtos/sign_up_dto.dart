import 'package:spring_dart/spring_dart.dart';

@Dto()
class SignUpDto {
  final String name;
  final String email;
  final String password;

  const SignUpDto({required this.name, required this.email, required this.password});

  @override
  String toString() => 'SignUpDto(name: $name, email: $email, password: $password)';
}
