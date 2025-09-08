import 'package:spring_dart/spring_dart.dart';

@Dto()
class SignUpDto {
  @NotEmpty(message: 'Name is required!')
  final String name;

  @Email(message: 'Email is invalid!')
  final String email;

  @Min(6)
  @Pattern('[a-z]', message: 'Password must have a least one lowercase!')
  @Pattern('[A-Z]', message: 'Password must have a least one uppercase!')
  @Pattern('[0-9]', message: 'Password must have a least one number!')
  @Pattern(r'[!@#$%^&*(),.?"{}|<>]', message: 'Password must have a least one special character!')
  final String password;

  const SignUpDto({required this.name, required this.email, required this.password});
}
