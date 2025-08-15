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

/// `@Dto`
class Dto {
  const Dto();
}

/// `@JsonKey`
class JsonKey {
  final String name;
  const JsonKey(this.name);
}

/// `@WithParser`
class WithParser {
  final Type parser;
  const WithParser(this.parser);
}
