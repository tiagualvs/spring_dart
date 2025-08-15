import 'package:spring_dart/spring_dart.dart';

@Dto()
class CreatePostDto {
  final String title;
  final String content;

  const CreatePostDto({required this.title, required this.content});
}
