import 'package:example/server.dart';
import 'package:example/src/dtos/insert_one_user_dto.dart';
import 'package:spring_dart/spring_dart.dart';

@Controller('/users')
class UsersController {
  final UsersRepository repository;

  UsersController(this.repository);

  @Post('/upload')
  @MultipartFormData()
  Future<Response> upload(@Body() Form form) async {
    await for (final field in form.fields) {
      if (field is TextFormField) {
        // final text = await field.readString();
      } else if (field is FileFormField) {
        // final bytes = await field.readBytes();
        // final filename = field.filename;
        // final mimeType = field.mimeType;
      }
    }
    return Json.noContent();
  }

  @Get('/')
  Future<Response> get() async {
    return Json.ok();
  }

  @Post('/')
  Future<Response> insertOne(@Body() InsertOneUserDto dto) async {
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
