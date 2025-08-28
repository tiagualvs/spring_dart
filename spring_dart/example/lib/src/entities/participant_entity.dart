import 'dart:convert';

import 'package:spring_dart_sql/spring_dart_sql.dart';

@Entity()
@PrimaryKeyConstraint(['chat_id', 'user_id'])
class ParticipantEntity {
  @References('chats', 'id')
  @Column('chat_id', INTEGER())
  final int chatId;

  @References('users', 'id')
  @Column('user_id', INTEGER())
  final int userId;

  @Default(CURRENT_TIMESTAMP)
  @Column('created_at', TIMESTAMP())
  final DateTime createdAt;

  const ParticipantEntity({required this.chatId, required this.userId, required this.createdAt});

  ParticipantEntity copyWith({int? chatId, int? userId, DateTime? createdAt}) {
    return ParticipantEntity(
      chatId: chatId ?? this.chatId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'chat_id': chatId, 'user_id': userId, 'created_at': createdAt.millisecondsSinceEpoch};
  }

  factory ParticipantEntity.fromMap(Map<String, dynamic> map) {
    return ParticipantEntity(
      chatId: map['chat_id'] as int,
      userId: map['user_id'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory ParticipantEntity.fromJson(String source) =>
      ParticipantEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ParticipantEntity(chatId: $chatId, userId: $userId, createdAt: $createdAt)';

  @override
  bool operator ==(covariant ParticipantEntity other) {
    if (identical(this, other)) return true;

    return other.chatId == chatId && other.userId == userId && other.createdAt == createdAt;
  }

  @override
  int get hashCode => chatId.hashCode ^ userId.hashCode ^ createdAt.hashCode;
}
