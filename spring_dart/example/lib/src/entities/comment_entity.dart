import 'dart:convert';

import 'package:spring_dart_sql/spring_dart_sql.dart';

@Entity()
@Table('comments')
class CommentEntity {
  @PrimaryKey()
  @GeneratedValue()
  final int id;

  @Check.isNotEmpty()
  final String content;

  @References('users', 'id')
  @Column('user_id', INTEGER())
  final int userId;

  @References('posts', 'id')
  @Column('post_id', INTEGER())
  final int postId;

  @Default(CURRENT_TIMESTAMP)
  @Column('created_at', DATETIME())
  final DateTime createdAt;

  @Default(CURRENT_TIMESTAMP)
  @Column('updated_at', DATETIME())
  final DateTime updatedAt;

  const CommentEntity({
    required this.id,
    required this.content,
    required this.userId,
    required this.postId,
    required this.createdAt,
    required this.updatedAt,
  });

  CommentEntity copyWith({
    int? id,
    String? content,
    int? userId,
    int? postId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommentEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      userId: userId ?? this.userId,
      postId: postId ?? this.postId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'content': content,
      'user_id': userId,
      'post_id': postId,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory CommentEntity.fromMap(Map<String, dynamic> map) {
    return CommentEntity(
      id: map['id'] as int,
      content: map['content'] as String,
      userId: map['user_id'] as int,
      postId: map['post_id'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory CommentEntity.fromJson(String source) => CommentEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CommentEntity(id: $id, content: $content, userId: $userId, postId: $postId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant CommentEntity other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.content == content &&
        other.userId == userId &&
        other.postId == postId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ content.hashCode ^ userId.hashCode ^ postId.hashCode ^ createdAt.hashCode ^ updatedAt.hashCode;
  }
}
