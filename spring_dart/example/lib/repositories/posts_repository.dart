import 'package:spring_dart/spring_dart.dart';

@Repository()
class PostsRepository {
  const PostsRepository();

  Future<String> findMany() async => 'HELLO WORLD';
}
