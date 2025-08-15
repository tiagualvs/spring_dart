class PasswordService {
  String encode(String password) => password;
  bool verify(String password, String encodedPassword) => password == encodedPassword;
}
