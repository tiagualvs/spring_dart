import 'form_field.dart';

class Form {
  final int contentLength;
  final Stream<FormField> fields;

  const Form(this.contentLength, this.fields);
}
