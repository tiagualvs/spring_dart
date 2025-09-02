import 'dart:typed_data';

import 'package:spring_dart_core/spring_dart_core.dart';

sealed class FormField {
  final String name;
  final Stream<List<int>> stream;
  const FormField(this.name, this.stream);

  Future<Uint8List> readBytes() async {
    final bytes = <int>[];
    await for (final chunk in stream) {
      bytes.addAll(chunk);
    }
    return Uint8List.fromList(bytes);
  }

  Future<String> readString() async {
    final bytes = await readBytes();
    return String.fromCharCodes(bytes);
  }

  static FormField fromFormData(FormData formData) {
    if (formData.filename == null) {
      return TextFormField(formData.name, formData.part);
    } else {
      return FileFormField(
        formData.name,
        formData.filename!,
        formData.part.headers['Content-Type'] ?? 'application/octet-stream',
        formData.part,
      );
    }
  }

  @override
  String toString() {
    return '$runtimeType($name${this is FileFormField ? ', ${(this as FileFormField).filename}, ${(this as FileFormField).mimeType}' : ''})';
  }
}

final class TextFormField extends FormField {
  const TextFormField(super.name, super.stream);
}

final class FileFormField extends FormField {
  final String filename;
  final String mimeType;
  const FileFormField(super.name, this.filename, this.mimeType, super.stream);
}
