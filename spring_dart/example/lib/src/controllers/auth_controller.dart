import 'package:example/server.dart';
import 'package:example/src/entities/credentials_entity.dart';
import 'package:spring_dart/spring_dart.dart';

import '../dtos/sign_in_dto.dart';
import '../dtos/sign_up_dto.dart';
import '../services/auth_service.dart';

@Controller('/auth')
class AuthController {
  final AuthService authService;

  const AuthController(this.authService);

  @Post('/sign-up')
  Future<Response> signUp(@Body() SignUpDto dto) async {
    final result = await authService.signUp(dto);
    return result.fold(
      (user) {
        return Json.created(body: user);
      },
      (error) {
        return error.toResponse();
      },
    );
  }

  @Post('/sign-in')
  Future<Response> signIn(@Body() SignInDto dto) async {
    final result = await authService.signIn(dto);
    return result.fold(
      (user) {
        final credentials = CredentialsEntity(
          accessToken: authService.jwtService.sign(user.id.toString(), expiresIn: Duration(hours: 1)),
          refreshToken: authService.jwtService.sign(user.id.toString(), expiresIn: Duration(days: 7)),
          expiresIn: 3600,
        );
        return Json.ok(body: {'user': user, 'credentials': credentials});
      },
      (error) {
        return error.toResponse();
      },
    );
  }

  @Post('/sign-out')
  Future<Response> signOut() async {
    return Json.ok();
  }

  @Post('/refresh-token')
  Future<Response> refreshToken(@Body() Map<String, dynamic> body) async {
    if (!body.containsKey('refresh_token')) return Json.badRequest();
    final payload = authService.jwtService.verify(body['refresh_token']);
    final id = int.tryParse(payload['sub'] ?? '');
    if (id == null) return Json.unauthorized();
    final user = await authService.usersRepository.findOne(FindOneUserParams(id));
    final credentials = CredentialsEntity(
      accessToken: authService.jwtService.sign(user.id.toString(), expiresIn: Duration(hours: 1)),
      refreshToken: authService.jwtService.sign(user.id.toString(), expiresIn: Duration(days: 7)),
      expiresIn: 3600,
    );
    return Json.ok(body: credentials);
  }
}
