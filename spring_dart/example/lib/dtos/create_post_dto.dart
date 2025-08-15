import 'package:example/parsers/date_time_parser.dart';
import 'package:spring_dart/spring_dart.dart';

@Dto()
class CreatePostDto {
  final String title;
  final String content;
  @JsonKey('created_at')
  @WithParser(DateTimeParser)
  final DateTime createdAt;

  const CreatePostDto({required this.title, required this.content, required this.createdAt});
}
