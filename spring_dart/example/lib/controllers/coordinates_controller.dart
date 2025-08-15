import 'dart:math';

import 'package:spring_dart/spring_dart.dart';

@Controller('/coordinates')
class CoordinatesController {
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
