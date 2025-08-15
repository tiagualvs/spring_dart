import 'package:spring_dart/spring_dart.dart';

class LogMiddleware extends SpringMiddleware {
  @override
  Handler handler(Handler innerHandler) {
    return (request) async {
      final sw = Stopwatch()..start();
      final response = await innerHandler(request);
      sw.stop();
      print('time: ${sw.elapsedMilliseconds}ms');
      return response;
    };
  }
}
