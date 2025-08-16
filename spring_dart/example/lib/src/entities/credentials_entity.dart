import 'dart:convert';

class CredentialsEntity {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  const CredentialsEntity({required this.accessToken, required this.refreshToken, required this.expiresIn});

  CredentialsEntity copyWith({String? accessToken, String? refreshToken, int? expiresIn}) {
    return CredentialsEntity(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresIn: expiresIn ?? this.expiresIn,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'access_token': accessToken, 'refresh_token': refreshToken, 'expires_in': expiresIn};
  }

  factory CredentialsEntity.fromMap(Map<String, dynamic> map) {
    return CredentialsEntity(
      accessToken: map['access_token'] as String,
      refreshToken: map['refresh_token'] as String,
      expiresIn: map['expires_in'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory CredentialsEntity.fromJson(String source) =>
      CredentialsEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  // @override
  // String toString() =>
  //     'CredentialsEntity(accessToken: $accessToken, refreshToken: $refreshToken, expiresIn: $expiresIn)';

  @override
  bool operator ==(covariant CredentialsEntity other) {
    if (identical(this, other)) return true;

    return other.accessToken == accessToken && other.refreshToken == refreshToken && other.expiresIn == expiresIn;
  }

  @override
  int get hashCode => accessToken.hashCode ^ refreshToken.hashCode ^ expiresIn.hashCode;
}
