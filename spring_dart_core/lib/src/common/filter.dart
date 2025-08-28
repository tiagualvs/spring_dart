import 'dart:async';

import 'package:shelf/shelf.dart' show Handler, Middleware, Request, Response;

abstract class Filter {
  const Filter();

  FutureOr<Response> doFilter(Request request, Handler next);

  Middleware get toShelfMiddleware {
    return (h) {
      return (r) {
        return doFilter(r, h);
      };
    };
  }
}
