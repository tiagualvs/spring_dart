import 'package:spring_dart/spring_dart.dart';

class TimestampToDateTimeParser extends IntParser<DateTime> {
  @override
  DateTime? decode(int? value) {
    if (value == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(value * 1000);
  }

  @override
  int? encode(DateTime? value) {
    if (value == null) return null;
    return value.millisecondsSinceEpoch ~/ 1000;
  }
}
