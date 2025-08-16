import 'dart:async';

import 'package:spring_dart/spring_dart.dart';

@Component()
class AuthFilter extends Filter {
  const AuthFilter();

  @override
  FutureOr<Response> doFilter(Request request, Handler next) async {
    print('AuthFilter');
    return next(request);
  }
}
