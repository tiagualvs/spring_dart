import 'package:spring_dart/spring_dart.dart';

@ControllerAdvice()
class ServerControllerAdvice {
  @ExceptionHandler(Exception)
  Response exceptionHandler(Exception exception) {
    return Json(500, body: {'error': exception.toString()});
  }

  @ExceptionHandler(SpringDartException)
  Response serverExceptionHandler(SpringDartException exception) {
    return Json(exception.statusCode, body: {'error': exception.message});
  }
}
