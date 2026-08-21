import '../../domain/entities/auth_token.dart';

class AuthTokenModel extends AuthToken {
  AuthTokenModel({
    required super.accessToken,
    required super.refreshToken,
    required super.accessTokenExpiresInSeconds,
    required super.refreshTokenExpiresInSeconds,
    super.issuedAt,
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    return AuthTokenModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      accessTokenExpiresInSeconds: json['access_token_expires_in_seconds'] as int? ?? 900,
      refreshTokenExpiresInSeconds: json['refresh_token_expires_in_seconds'] as int? ?? 604800,
      issuedAt: json['issued_at'] != null ? DateTime.tryParse(json['issued_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'access_token_expires_in_seconds': accessTokenExpiresInSeconds,
      'refresh_token_expires_in_seconds': refreshTokenExpiresInSeconds,
      'issued_at': issuedAt.toIso8601String(),
    };
  }
}
