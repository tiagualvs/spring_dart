import 'dart:convert';

import 'package:spring_dart/spring_dart.dart';

@Dto()
class InsertOneUserDto {
  final String name;
  final String email;
  final String password;
  @WithParser(DateTimeParser)
  @JsonKey('created_at')
  final DateTime createdAt;

  const InsertOneUserDto({
    required this.name,
    required this.email,
    required this.password,
    required this.createdAt,
  });

  InsertOneUserDto copyWith({
    String? name,
    String? email,
    String? password,
    DateTime? createdAt,
  }) {
    return InsertOneUserDto(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory InsertOneUserDto.fromMap(Map<String, dynamic> map) {
    return InsertOneUserDto(
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory InsertOneUserDto.fromJson(String source) =>
      InsertOneUserDto.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CreateUserDto(name: $name, email: $email, password: $password, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant InsertOneUserDto other) {
    if (identical(this, other)) return true;

    return other.name == name && other.email == email && other.password == password && other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return name.hashCode ^ email.hashCode ^ password.hashCode ^ createdAt.hashCode;
  }
}

class DateTimeParser extends StringParser<DateTime> {
  @override
  DateTime? decode(String? value) {
    if (value == null) return null;
    return DateTime.parse(value);
  }

  @override
  String? encode(DateTime? value) {
    if (value == null) return null;
    return value.toIso8601String();
  }
}
