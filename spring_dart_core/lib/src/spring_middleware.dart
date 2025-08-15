import 'package:shelf/shelf.dart' show Handler;

abstract class SpringMiddleware {
  Handler handler(Handler innerHandler);
}
