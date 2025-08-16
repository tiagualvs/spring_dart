import 'package:example/src/config/security_configuration.dart';
import 'package:example/src/dtos/sign_in_dto.dart';
import 'package:example/src/entities/user_entity.dart';
import 'package:example/src/repositories/users_repository.dart';
import 'package:spring_dart/spring_dart.dart';

import '../dtos/sign_up_dto.dart';

@Service()
class AuthService {
  final UsersRepository usersRepository;
  final JwtService jwtService;
  final PasswordService passwordService;

  const AuthService(this.usersRepository, this.jwtService, this.passwordService);

  Future<UserEntity> signUp(SignUpDto dto) async {
    return await usersRepository.insertOne(dto.name, dto.email, passwordService.hash(dto.password));
  }

  Future<UserEntity?> signIn(SignInDto dto) async {
    final user = await usersRepository.findOneByEmail(dto.email);
    if (user == null) return null;
    if (!passwordService.verify(dto.password, user.password)) return null;
    return user;
  }
}
