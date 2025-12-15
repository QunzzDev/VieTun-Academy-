import 'package:equatable/equatable.dart';

/// Authentication tokens returned from login/refresh
class AuthTokens extends Equatable {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });
  
  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: json['expires_in'] as int,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
    };
  }
  
  @override
  List<Object?> get props => [accessToken, refreshToken, expiresIn];
}
