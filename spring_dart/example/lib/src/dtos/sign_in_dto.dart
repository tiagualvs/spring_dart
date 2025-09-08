import 'package:spring_dart/spring_dart.dart';

@Dto()
class SignInDto {
  @Email(message: 'Invalid email!')
  final String email;

  @NotEmpty(message: 'Password is required!')
  final String password;

  const SignInDto({required this.email, required this.password});
}
