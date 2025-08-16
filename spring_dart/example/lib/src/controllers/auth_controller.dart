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
    final user = await authService.signUp(dto);
    return Json.created(body: user);
  }

  @Post('/sign-in')
  Future<Response> signIn(@Body() SignInDto dto) async {
    final user = await authService.signIn(dto);
    if (user == null) return Json.unauthorized();
    final credentials = CredentialsEntity(
      accessToken: authService.jwtService.sign(user.id.toString(), expiresIn: Duration(hours: 1)),
      refreshToken: authService.jwtService.sign(user.id.toString(), expiresIn: Duration(days: 7)),
      expiresIn: 3600,
    );
    return Json.ok(body: {'user': user, 'credentials': credentials});
  }

  @Post('/sign-out')
  Future<Response> signOut() async {
    return Json.ok();
  }

  @Post('/refresh-token')
  Future<Response> refreshToken(@Body() Map<String, dynamic> body) async {
    if (!body.containsKey('refresh_token')) return Json.badRequest();
    final payload = authService.jwtService.verify(body['refresh_token']);
    final user = await authService.usersRepository.findOne(int.parse(payload['sub'] as String));
    if (user == null) return Json.unauthorized();
    final credentials = CredentialsEntity(
      accessToken: authService.jwtService.sign(user.id.toString(), expiresIn: Duration(hours: 1)),
      refreshToken: authService.jwtService.sign(user.id.toString(), expiresIn: Duration(days: 7)),
      expiresIn: 3600,
    );
    return Json.ok(body: credentials);
  }
}
