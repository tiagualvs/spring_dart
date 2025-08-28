sealed class ContentType {
  final String value;

  const ContentType(this.value);
  const factory ContentType.applicationJson() = _ApplicationJson;
  const factory ContentType.formUrlEncoded() = _FormUrlEncoded;
  const factory ContentType.multipartFormData() = _MultipartFormData;
  const factory ContentType.textPlain() = _TextPlain;
  const factory ContentType.textHtml() = _TextHtml;
}

final class _ApplicationJson extends ContentType {
  const _ApplicationJson() : super('application/json');
}

final class _FormUrlEncoded extends ContentType {
  const _FormUrlEncoded() : super('application/x-www-form-urlencoded');
}

final class _MultipartFormData extends ContentType {
  const _MultipartFormData() : super('multipart/form-data');
}

final class _TextPlain extends ContentType {
  const _TextPlain() : super('text/plain');
}

final class _TextHtml extends ContentType {
  const _TextHtml() : super('text/html');
}
