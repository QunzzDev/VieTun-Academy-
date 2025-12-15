import '../config/api_client.dart';
import '../models/user.dart';
import '../models/auth_tokens.dart';

/// Repository for authentication operations.
/// Requirements: 1.1, 1.3, 1.4
class AuthRepository {
  final ApiClient _apiClient = ApiClient.instance;
  
  /// Login with username and password
  Future<LoginResult> login(String username, String password) async {
    final response = await _apiClient.dio.post(
      '/auth/login',
      data: {
        'username': username,
        'password': password,
      },
    );
    
    final tokens = AuthTokens.fromJson(response.data);
    await _apiClient.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    
    // Get user info
    final userResponse = await _apiClient.dio.get('/auth/me');
    final user = User.fromJson(userResponse.data);
    
    return LoginResult(tokens: tokens, user: user);
  }
  
  /// Refresh access token
  Future<AuthTokens> refreshToken(String refreshToken) async {
    final response = await _apiClient.dio.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
    
    final tokens = AuthTokens.fromJson(response.data);
    await _apiClient.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    
    return tokens;
  }
  
  /// Logout and invalidate session
  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/auth/logout');
    } finally {
      await _apiClient.clearTokens();
    }
  }
  
  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _apiClient.getAccessToken();
    return token != null;
  }
}

/// Result of login operation
class LoginResult {
  final AuthTokens tokens;
  final User user;
  
  LoginResult({required this.tokens, required this.user});
}
