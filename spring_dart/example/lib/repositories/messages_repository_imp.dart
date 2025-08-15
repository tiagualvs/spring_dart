import 'package:spring_dart/spring_dart.dart';

import 'messages_repository.dart';

@Repository()
class MessagesRepositoryImp implements MessagesRepository {
  @override
  Future<String> createMessage() {
    return Future.value('Hello World');
  }
}
