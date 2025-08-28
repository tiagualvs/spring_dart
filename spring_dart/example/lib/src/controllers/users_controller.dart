import 'package:spring_dart/spring_dart.dart';

@Controller('/users')
class UsersController {
  @Post('/upload')
  Future<Response> upload(@Body(ContentType.multipartFormData()) List<FormData> fields) async {
    return Json.noContent();
  }
}
