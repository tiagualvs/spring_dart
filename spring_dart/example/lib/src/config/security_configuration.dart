import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:spring_dart/spring_dart.dart';

@Configuration()
class SecurityConfiguration {
  @Bean()
  JwtService jwtService() => _JwtService();

  @Bean()
  PasswordService passwordService() => _PasswordService();
}

abstract interface class JwtService {
  String sign(String sub, {Map<String, dynamic>? payload, String? issuer, Duration? expiresIn});
  Map<String, dynamic> decode(String token);
  Map<String, dynamic> verify(String token);
  bool isExpired(String token);
}

class _JwtService implements JwtService {
  @override
  String sign(String sub, {Map<String, dynamic>? payload, String? issuer, Duration? expiresIn}) {
    final jwt = JWT(payload ?? {}, subject: sub, issuer: issuer);
    return jwt.sign(SecretKey('secret'), expiresIn: expiresIn);
  }

  @override
  Map<String, dynamic> decode(String token) {
    final jwt = JWT.decode(token);
    return jwt.payload;
  }

  @override
  Map<String, dynamic> verify(String token) {
    final jwt = JWT.verify(token, SecretKey('secret'));
    return jwt.payload;
  }

  @override
  bool isExpired(String token) {
    final jwt = JWT.decode(token);
    final iat = jwt.payload['iat'] as int?;
    if (iat == null) return false;
    return DateTime.fromMillisecondsSinceEpoch(iat * 1000).isBefore(DateTime.now());
  }
}

abstract interface class PasswordService {
  String hash(String password);
  bool verify(String password, String hash);
}

class _PasswordService implements PasswordService {
  @override
  String hash(String password) => BCrypt.hashpw(password, BCrypt.gensalt());

  @override
  bool verify(String password, String hash) => BCrypt.checkpw(password, hash);
}
