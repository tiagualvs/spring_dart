import 'package:bcrypt/bcrypt.dart';

abstract interface class PasswordBean {
  String hash(String password);
  bool verify(String password, String hash);
}

class PasswordBeanImp implements PasswordBean {
  @override
  String hash(String password) => BCrypt.hashpw(password, BCrypt.gensalt());

  @override
  bool verify(String password, String hash) => BCrypt.checkpw(password, hash);
}
