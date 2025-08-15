import 'package:spring_dart/spring_dart.dart';

@Dto()
class CoordinatesDto {
  final double latitude;
  final double longitude;

  const CoordinatesDto(this.latitude, this.longitude);
}
