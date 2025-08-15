import 'package:spring_dart/spring_dart.dart';

@Dto()
class RefreshTokenDto {
  @JsonKey('refresh_token')
  final String refreshToken;

  const RefreshTokenDto(this.refreshToken);
}
