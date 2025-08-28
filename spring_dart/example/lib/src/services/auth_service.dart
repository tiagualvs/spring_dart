import 'package:example/server.dart';
import 'package:example/src/config/beans/password_bean.dart';
import 'package:example/src/config/security_configuration.dart';
import 'package:example/src/core/result.dart';
import 'package:example/src/dtos/sign_in_dto.dart';
import 'package:example/src/entities/user_entity.dart';
import 'package:example/src/exceptions.dart';
import 'package:spring_dart/spring_dart.dart';
import 'package:spring_dart_sql/spring_dart_sql.dart';

import '../dtos/sign_up_dto.dart';

@Service()
class AuthService {
  final UsersRepository usersRepository;
  final JwtService jwtService;
  final PasswordBean passwordService;

  const AuthService(this.usersRepository, this.jwtService, this.passwordService);

  AsyncResult<UserEntity> signUp(SignUpDto dto) async {
    try {
      final user = await usersRepository.insertOne(
        InsertOneUserParams(
          name: dto.name,
          username: '',
          email: dto.email,
          password: passwordService.hash(dto.password),
        ),
      );
      return Value(user);
    } on Exception catch (e) {
      return Error(InternalServerException(e.toString()));
    }
  }

  AsyncResult<UserEntity> signIn(SignInDto dto) async {
    try {
      final users = await usersRepository.findMany(FindManyUsersParams(Where('email', Eq(), dto.email)));

      if (users.isEmpty) return Error(NotFoundException('User not found!'));

      final user = users.first;

      if (!passwordService.verify(dto.password, user.password)) {
        return Error(UnauthorizedException('User not found!'));
      }

      return Value(user);
    } on Exception catch (e) {
      return Error(InternalServerException(e.toString()));
    }
  }
}
