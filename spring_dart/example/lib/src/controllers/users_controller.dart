import 'package:example/server.dart';
import 'package:spring_dart/spring_dart.dart';

@Controller('/users')
class UsersController {
  final UsersRepository repository;

  UsersController(this.repository);

  @Post('/upload')
  Future<Response> upload(@Body(ContentType.multipartFormData()) List<FormData> fields) async {
    return Json.noContent();
  }

  @Get('/')
  Future<Response> get() async {
    return Json.ok();
  }

  @Post('/')
  Future<Response> post() async {
    return Json.ok();
  }

  @Get('/<id>')
  Future<Response> getById(@Param('id') String id) async {
    return Json.ok();
  }

  @Put('/<id>')
  Future<Response> put(@Param('id') String id) async {
    return Json.ok();
  }

  @Delete('/<id>')
  Future<Response> delete(@Param('id') String id) async {
    return Json.ok();
  }
}
