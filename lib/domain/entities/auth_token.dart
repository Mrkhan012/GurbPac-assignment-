import 'package:equatable/equatable.dart';

class AuthToken extends Equatable {
  final String accessToken;
  final String refreshToken;
  final int accessTokenExpiresInSeconds;
  final int refreshTokenExpiresInSeconds;
  final DateTime issuedAt;

  AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresInSeconds,
    required this.refreshTokenExpiresInSeconds,
    DateTime? issuedAt,
  }) : issuedAt = issuedAt ?? DateTime.now();

  DateTime get expiryTime => issuedAt.add(Duration(seconds: accessTokenExpiresInSeconds));
  bool get isExpired => DateTime.now().isAfter(expiryTime);

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
        accessTokenExpiresInSeconds,
        refreshTokenExpiresInSeconds,
        issuedAt,
      ];
}
