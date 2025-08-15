import 'package:example/configurations/ntp_service.dart';
import 'package:example/configurations/password_service.dart';
import 'package:spring_dart/spring_dart.dart';

@Configuration()
class SecurityConfiguration {
  @Bean()
  PasswordService password() => PasswordService();

  @Bean()
  Future<NtpService> ntpService() => Future.value(NtpService());
}
