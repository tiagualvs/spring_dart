import 'package:example/server.dart';
import 'package:example/src/config/beans/password_bean.dart';
import 'package:example/src/config/security_configuration.dart';
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
    final result = await usersRepository.insertOne(
      InsertOneUserParams(
        name: dto.name,
        username: '',
        email: dto.email,
        password: passwordService.hash(dto.password),
      ),
    );

    return result;
  }

  AsyncResult<UserEntity> signIn(SignInDto dto) async {
    final result = await usersRepository.findMany(FindManyUsersParams(Where('email', Eq(), dto.email)));

    return result.fold(
      (users) {
        if (users.isEmpty) return Error(NotFoundException('User not found!'));

        final user = users.first;

        if (!passwordService.verify(dto.password, user.password)) {
          return Error(UnauthorizedException('User not found!'));
        }

        return Success(user);
      },
      (error) {
        return Error(error);
      },
    );
  }
}
