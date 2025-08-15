import 'package:example/configurations/password_service.dart';
import 'package:spring_dart/spring_dart.dart';

@Configuration()
class SecurityConfiguration {
  @Bean()
  PasswordService password() => PasswordService();
}
