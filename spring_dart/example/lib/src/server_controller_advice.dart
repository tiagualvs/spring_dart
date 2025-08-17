import 'package:example/src/exceptions.dart';
import 'package:spring_dart/spring_dart.dart';

@ControllerAdvice()
class ServerControllerAdvice {
  @ExceptionHandler(Exception)
  Response exceptionHandler(Exception exception) {
    return Json(500, body: {'error': exception.toString()});
  }

  @ExceptionHandler(ServerException)
  Response serverExceptionHandler(ServerException exception) {
    return Json(exception.statusCode, body: {'error': exception.message});
  }
}
