import 'package:spring_dart/spring_dart.dart';

@Dto()
class SignInDto {
  final String email;
  final String password;

  const SignInDto({required this.email, required this.password});
}
