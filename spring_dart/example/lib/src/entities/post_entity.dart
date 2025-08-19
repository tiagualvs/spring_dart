import 'dart:convert';

import 'package:spring_dart_sql/spring_dart_sql.dart';

@Entity()
@Table('posts')
class PostEntity {
  @Id()
  final int id;

  @Column('title')
  final String title;

  @Column('body')
  final String body;

  @Column('user_id')
  final int userId;

  @Default()
  @Column('created_at', TIMESTAMP())
  final DateTime createdAt;

  @Default()
  @Column('updated_at', TIMESTAMP())
  final DateTime updatedAt;

  const PostEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  PostEntity copyWith({int? id, String? title, String? body, int? userId, DateTime? createdAt, DateTime? updatedAt}) {
    return PostEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'user_id': userId,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory PostEntity.fromMap(Map<String, dynamic> map) {
    return PostEntity(
      id: map['id'] as int,
      title: map['title'] as String,
      body: map['body'] as String,
      userId: map['user_id'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory PostEntity.fromJson(String source) => PostEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PostEntity(id: $id, title: $title, body: $body, userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant PostEntity other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.body == body &&
        other.userId == userId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ body.hashCode ^ userId.hashCode ^ createdAt.hashCode ^ updatedAt.hashCode;
  }
}
