import 'package:example/configurations/password_service.dart';
import 'package:example/dtos/create_post_dto.dart';
import 'package:example/dtos/refresh_token_dto.dart';
import 'package:example/dtos/sign_in_dto.dart';
import 'package:example/dtos/sign_up_dto.dart';
import 'package:example/repositories/users_repository.dart';
import 'package:spring_dart/spring_dart.dart';

@Controller('/auth')
class AuthController {
  final PasswordService passwordService;
  final UsersRepository users;

  const AuthController(this.passwordService, this.users);

  @Post('/sign-in')
  Future<Response> signIn(@Body() SignInDto dto) async {
    return Response.ok('Test');
  }

  @Post('/sign-up')
  Future<Response> signUp(@Body() SignUpDto dto) async {
    if (dto.name.isEmpty) {
      return Json.badRequest(body: {'error': 'Name is required.'});
    }

    if (dto.email.isEmpty) {
      return Json.badRequest(body: {'error': 'Email is required.'});
    }

    if (dto.password.isEmpty) {
      return Json.badRequest(body: {'error': 'Password is required.'});
    }

    return Json.ok(body: dto);
  }

  @Post('/refresh-token')
  Future<Response> refreshToken(@Body() RefreshTokenDto dto) async {
    return Json.ok(body: {'refresh_token': dto.refreshToken});
  }

  @Get('/<id>')
  Future<Response> findOneUser(@Param('id') String id) async {
    return Response.ok('Test');
  }

  @Get('/users')
  Future<Response> findManyUsers(@Query('name') String? name) async {
    return Response.ok('Test');
  }

  @Post('/posts/<id>/create')
  Future<Response> createPost(
    @Param('id') String id,
    @Query('lang') String? lang,
    @Header('authorization') String? authorization,
    @Body() CreatePostDto dto,
  ) async {
    return Json.ok(
      body: {
        'title': dto.title,
        'content': dto.content,
        'created_at': dto.createdAt.toIso8601String(),
      },
    );
  }

  @Put('/posts/<id>/update')
  Future<Response> updatePost(@Param('id') String id, @Body() Map<String, dynamic> body) async {
    return Response.ok('Test');
  }

  @Post('/posts/<id>/delete')
  Future<Response> deletePost(@Param('id') String id, @Body() Map<String, dynamic> body) async {
    return Response.ok('Test');
  }
}
