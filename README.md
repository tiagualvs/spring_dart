# Spring Dart

[![Dart Version](https://img.shields.io/badge/Dart-3.9.0+-00B4AB.svg)](https://dart.dev/)

A powerful and elegant framework for building REST APIs with Dart, inspired by Spring Boot. Spring Dart brings the familiar Spring Boot programming model to Dart developers, making it easy to create robust, maintainable web applications.

## Features

- **Annotation-based routing**: Define controllers and routes using annotations like `@Controller`, `@Get`, `@Post`, etc.
- **Dependency injection**: Automatic dependency management with `@Service`, `@Repository`, `@Component`, and `@Bean` annotations
- **Configuration management**: Use `@Configuration` to define application configurations
- **Database integration**: Built-in support for SQL databases with the `spring_dart_sql` package
- **Automatic repository generation**: Repositories are automatically created and injected for each entity in your project
- **Request validation**: Validate incoming requests with built-in validators
- **Exception handling**: Centralized exception handling with controller advice
- **JSON serialization/deserialization**: Automatic conversion between Dart objects and JSON

## Project Structure

Spring Dart is organized into several packages:

- **spring_dart**: The main package that brings everything together
- **spring_dart_core**: Core functionality including annotations, routing, and request handling
- **spring_dart_sql**: Database integration and ORM capabilities
- **spring_dart_gen**: Code generation tools for Spring Dart applications

## Getting Started

### Installation

Add Spring Dart to your `pubspec.yaml`:

```yaml
dependencies:
  spring_dart: ^0.0.1
```

### Server Generation

Spring Dart's build system automatically generates two important files for your application:

1. `lib/server.dart`: Contains the generated server configuration code, including dependency injection setup, controllers, repositories, and middleware configuration.
2. `bin/$package$.dart`: The main entry point that calls your server implementation.

The main entry point is very simple:

```dart
import 'package:your_package/server.dart';

void main(List<String> args) async => server(args);
```

You don't need to write these files manually - they are generated automatically when you build your application.

### Basic Usage

DTOs:

```dart
import 'package:spring_dart/spring_dart.dart';

@Dto()
class InsertOneUserDto {
  @NotEmpty(message: 'Name is required!')
  final String name;

  @Size(3, 24, message: 'Username must be between 3 and 24 characters!')
  @Pattern('[a-zA-Z0-9_]', message: 'Username must contain only letters, numbers and underscores!')
  final String username;

  @Email(message: 'Email is invalid!')
  final String email;

  @Min(6)
  @Pattern('[a-z]', message: 'Password must have a least one lowercase!')
  @Pattern('[A-Z]', message: 'Password must have a least one uppercase!')
  @Pattern('[0-9]', message: 'Password must have a least one number!')
  @Pattern(r'[!@#$%^&*(),.?"{}|<>]', message: 'Password must have a least one special character!')
  final String password;

  const InsertOneUserDto({required this.name, required this.username, required this.email, required this.password});
}
```

Controllers:

```dart
import 'package:spring_dart/spring_dart.dart';

@Controller('/users')
class UsersController {
  final UsersRepository repository;

  const UsersController(this.repository); // Dependency injection

  @Get('/')
  Future<Response> findMany() async {
    final result = await repository.findMany();
    return result.fold(
      (users) => Json.ok(body: users), // Serialization configurated on ServerConfiguration below
      (error) => error.toResponse(),
    );
  }

  @Get('/<id>')
  Future<Response> findOne(@Param('id') String id) async {
    final result = await repository.findOne(FindOneUserParams(id));
    return result.fold(
      (user) => Json.ok(body: user), // Serialization configurated on ServerConfiguration below
      (error) => error.toResponse(),
    );
  }

  @Post('/')
  Future<Response> insertOne(@Body() InsertOneUserDto dto) async {
    final result = await repository.insertOne(
      InsertOneUserParams(
        name: dto.name,
        username: dto.username,
        email: dto.email,
        password: dto.password,
      ),
    );
    return result.fold(
      (user) => Json.created(body: user), // Serialization configurated on ServerConfiguration below
      (error) => error.toResponse(),
    );
  }

  @Put('/<id>')
  Future<Response> updateOne(@Param('id') String id, @Body() UpdateOneUserDto dto) async {
    final result = await repository.updateOne(
      UpdateOneUserParams(
        id,
        name: dto.name,
        username: dto.username,
        email: dto.email,
        password: dto.password,
      ),
    );
    return result.fold(
      (user) => Json.ok(body: user), // Serialization configurated on ServerConfiguration below
      (error) => error.toResponse(),
    );
  }

  @Delete('/<id>')
  Future<Response> deleteOne(@Param('id') String id) async {
    final result = await repository.deleteOne(DeleteOneUserParams(id));
    return result.fold(
      (_) => Json.noContent(),
      (error) => error.toResponse(),
    );
  }
}
```

Entities

```dart
import 'package:spring_dart_sql/spring_dart_sql.dart';

@Entity()
@Table('users')
class UserEntity {
  @PrimaryKey()
  @GeneratedValue()
  final int id;

  @Column('name', VARCHAR(255))
  final String name;

  @Unique()
  @Column('username', VARCHAR(24))
  final String username;

  @Unique()
  final String email;

  final String password;

  @Nullable()
  final String? image;

  @Default(CURRENT_TIMESTAMP)
  @Column('created_at', TIMESTAMP())
  final DateTime createdAt;

  @Default(CURRENT_TIMESTAMP)
  @Column('updated_at', TIMESTAMP())
  final DateTime updatedAt;

  const UserEntity({
    this.id = 0,
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'image': image,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
```

Database Configuration:

```yaml
host: 0.0.0.0
port: 8080
database_url: sqlite://database.db
ddl-auto: create
```

## Automatic Repository Generation

Spring Dart automatically generates repositories for all entities in your project. This means:

1. You don't need to manually create repository classes for your entities
2. Repositories are automatically injected and available for use in your controllers
3. Each generated repository extends `CrudRepository<YourEntity>` with the following methods:
   - `insertOne`: Insert a new entity
   - `findOne`: Find a single entity by criteria
   - `findMany`: Find multiple entities by criteria
   - `updateOne`: Update an entity
   - `deleteOne`: Delete an entity

### Database Configuration

Currently, Spring Dart supports SQLite as the database. Configure it in your `config.yaml` file:

```yaml
database_url: sqlite://database.db  # Path to your SQLite database file
ddl-auto: create                    # Options: create, update, none
```

## Server Configuration

### Customizing Server Configuration

You can customize your server's behavior by creating a class that extends `SpringDartConfiguration`. This allows you to:

1. Configure how the server starts
2. Define global middleware
3. Customize JSON serialization

Example:

```dart
import 'package:spring_dart/spring_dart.dart';

@Configuration()
class ServerConfiguration extends SpringDartConfiguration {
  @Override
  Future<void> setup(SpringDart spring) async {
    final server = await spring.start(host: 'localhost', port: 3000);
    print('Server started on http://localhost:${server.port}');
  }

  @Override
  List<Middleware> get middlewares => [
    logRequests(),
    // Add your custom middleware here
  ];

  @Override
  ToEncodable? get toEncodable => (Object? obj) {
    // Custom serialization logic
    if (obj is UserEntity) return obj.toMap();
    if (obj is DateTime) return obj.toIso8601String();
    return null; // Fall back to default serialization
  };
}
```

The build system will automatically detect your configuration class and use it instead of the default configuration.

The `ddl-auto` option controls how the database schema is managed:
- `create`: Drop and recreate all tables on startup
- `update`: Update existing tables (add new columns/tables but don't drop existing ones)
- `none`: Don't modify the database schema

## Roadmap

Future features planned for Spring Dart include:

- **Automatic serialization/deserialization**: Built-in serialization for DTOs and entities without manual mapping
- **Expanded SQL support**: Full support for both SQLite and PostgreSQL databases
- **More validation features**: Enhanced request validation capabilities
- **Security enhancements**: Additional authentication and authorization options
- **Testing utilities**: Simplified testing for Spring Dart applications

## Example Project

See [spring_dart/example](https://github.com/tiagualvs/spring_dart/tree/main/spring_dart/example) for a complete working example.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.