import 'dart:math';

import 'package:example/middlewares/log_middleware.dart';
import 'package:spring_dart/spring_dart.dart';

@WithMiddleware(LogMiddleware)
@Controller('/coordinates')
class CoordinatesController {
  const CoordinatesController();

  @Get('/current')
  Future<Response> current(Request request) async {
    return Json.ok(
      body: {
        'latitude': Random().nextDouble() * 90,
        'longitude': Random().nextDouble() * 180,
      },
    );
  }
}
