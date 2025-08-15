import 'package:spring_dart/spring_dart.dart';

class DateTimeParser extends ParamParser<DateTime> {
  @override
  DateTime? decode(String? value) {
    return DateTime.tryParse(value ?? '');
  }

  @override
  String? encode(DateTime? value) {
    return value?.toIso8601String();
  }
}
