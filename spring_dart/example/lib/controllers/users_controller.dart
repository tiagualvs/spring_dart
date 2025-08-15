import 'package:example/repositories/messages_repository.dart';
import 'package:example/repositories/posts_repository.dart';
import 'package:example/repositories/users_repository.dart';
import 'package:spring_dart/spring_dart.dart';

@Controller('/users')
class UsersController {
  final UsersRepository users;
  final PostsRepository posts;
  final MessagesRepository messages;

  const UsersController(this.users, this.posts, this.messages);

  @Get('/')
  Future<Response> findMany(
    @Query('name') String? name,
    @Query('age') String? age,
    @Query('email') String? email,
    @Query('password') String? password,
  ) async {
    return Response.ok('Test');
  }

  @Get('/<id|[0-9]>')
  Future<Response> findOne(@Param('id') String id) async {
    return Response.ok('Test');
  }

  @Post('/')
  Future<Response> create(@Context('user_id') String userId, @Body() Map<String, dynamic> body) async {
    return Response.ok('Test');
  }
}
