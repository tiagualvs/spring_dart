import 'package:spring_dart/spring_dart.dart';

@Repository()
class UsersRepository {
  const UsersRepository();

  Future<List<Map<String, dynamic>>> findMany() async {
    return [];
  }
}
