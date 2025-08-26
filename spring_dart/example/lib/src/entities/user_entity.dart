import 'dart:convert';

import 'package:spring_dart_sql/spring_dart_sql.dart';

@Entity()
@Table('users')
@UniqueConstraint(['email', 'username'])
@PrimaryKeyConstraint(['id'])
class UserEntity {
  @GeneratedValue()
  final int id;

  @Column('name', VARCHAR(255))
  final String name;

  @Column('username', VARCHAR(24))
  final String username;

  @Unique()
  final String email;

  @Check.isNotEmpty()
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
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  UserEntity copyWith({
    int? id,
    String? name,
    String? username,
    String? email,
    String? password,
    String? Function()? image,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      image: image != null ? image() : this.image,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'image': image,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id'] as int,
      name: map['name'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      image: map['image'] != null ? map['image'] as String : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserEntity.fromJson(String source) => UserEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserEntity(id: $id, name: $name, username: $username, email: $email, password: $password, image: $image, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant UserEntity other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.username == username &&
        other.email == email &&
        other.password == password &&
        other.image == image &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        username.hashCode ^
        email.hashCode ^
        password.hashCode ^
        image.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
