import 'dart:convert';

import 'package:spring_dart_sql/spring_dart_sql.dart';

@Entity()
@Table('chats')
class ChatEntity {
  @PrimaryKey()
  @GeneratedValue()
  final int id;

  @Nullable()
  final String? name;

  @Nullable()
  final String? image;

  @Check.any(<String>['private', 'group'])
  @Column('type', VARCHAR(24))
  final String type;

  @Default(CURRENT_TIMESTAMP)
  @Column('created_at', TIMESTAMP())
  final DateTime createdAt;

  @Default(CURRENT_TIMESTAMP)
  @Column('updated_at', TIMESTAMP())
  final DateTime updatedAt;

  const ChatEntity({
    required this.id,
    this.name,
    this.image,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  ChatEntity copyWith({
    int? id,
    String? Function()? name,
    String? Function()? image,
    String? type,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatEntity(
      id: id ?? this.id,
      name: name != null ? name() : this.name,
      image: image != null ? image() : this.image,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'image': image,
      'type': type,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory ChatEntity.fromMap(Map<String, dynamic> map) {
    return ChatEntity(
      id: map['id'] as int,
      name: map['name'] != null ? map['name'] as String : null,
      image: map['image'] != null ? map['image'] as String : null,
      type: map['type'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatEntity.fromJson(String source) => ChatEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ChatEntity(id: $id, name: $name, image: $image, type: $type, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant ChatEntity other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.image == image &&
        other.type == type &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ image.hashCode ^ type.hashCode ^ createdAt.hashCode ^ updatedAt.hashCode;
  }
}
