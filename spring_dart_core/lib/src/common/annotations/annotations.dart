part 'dtos.dart';

/// `@Controller`
class Controller {
  final String path;
  const Controller(this.path);
}

/// `@Service`
class Service {
  const Service();
}

/// `@Repository`
class Repository {
  const Repository();
}

/// `@Component`
class Component {
  const Component();
}

/// `@Configuration`
class Configuration {
  const Configuration();
}

/// `@Bean`
class Bean {
  const Bean();
}

/// `@Get`
class Get {
  final String path;
  const Get([this.path = '/']);
}

/// `@Post`
class Post {
  final String path;
  const Post([this.path = '/']);
}

/// `@Put`
class Put {
  final String path;
  const Put([this.path = '/']);
}

/// `@Delete`
class Delete {
  final String path;
  const Delete([this.path = '/']);
}

/// `@Patch`
class Patch {
  final String path;
  const Patch([this.path = '/']);
}

/// `@Head`
class Head {
  final String path;
  const Head([this.path = '/']);
}

/// `@Options`
class Options {
  final String path;
  const Options([this.path = '/']);
}

/// `@Trace`
class Trace {
  final String path;
  const Trace([this.path = '/']);
}

/// `@Connect`
class Connect {
  final String path;
  const Connect([this.path = '/']);
}

/// `@ContentType`
class ContentType {
  final String value;
  const ContentType(this.value);
}

/// `@ApplicationJson`
class ApplicationJson extends ContentType {
  const ApplicationJson() : super('application/json');
}

/// `@FormUrlEncoded`
class FormUrlEncoded extends ContentType {
  const FormUrlEncoded() : super('application/x-www-form-urlencoded');
}

/// `@MultipartFormData`
class MultipartFormData extends ContentType {
  const MultipartFormData() : super('multipart/form-data');
}

/// `@TextPlain`
class TextPlain extends ContentType {
  const TextPlain() : super('text/plain');
}

/// `@TextHtml`
class TextHtml extends ContentType {
  const TextHtml() : super('text/html');
}

/// `@Body`
class Body {
  const Body();
}

/// `@Param`
class Param {
  final String name;
  const Param(this.name);
}

/// `@Query`
class Query {
  final String name;
  const Query(this.name);
}

/// `@Context`
class Context {
  final String name;
  const Context(this.name);
}

/// `@Header`
class Header {
  final String name;
  const Header(this.name);
}

/// `@WithMiddleware`
class WithFilter {
  final Type filter;
  const WithFilter(this.filter);
}

/// `@ControllerAdvice`
class ControllerAdvice {
  const ControllerAdvice();
}

/// `@ExceptionHandler`
class ExceptionHandler {
  final Type exception;
  const ExceptionHandler(this.exception);
}
