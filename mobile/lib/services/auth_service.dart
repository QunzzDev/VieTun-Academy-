import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../models/auth_tokens.dart';
import '../repositories/auth_repository.dart';

/// Authentication service managing user login state.
/// Requirements: 1.1, 1.4
class AuthService extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  User? _currentUser;
  AuthTokens? _tokens;
  bool _isLoading = false;
  String? _error;
  
  AuthService(this._authRepository);
  
  User? get currentUser => _currentUser;
  AuthTokens? get tokens => _tokens;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null && _tokens != null;
  
  /// Login with username and password
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _authRepository.login(username, password);
      _tokens = result.tokens;
      _currentUser = result.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Refresh access token
  Future<bool> refreshToken() async {
    if (_tokens == null) return false;
    
    try {
      final newTokens = await _authRepository.refreshToken(_tokens!.refreshToken);
      _tokens = newTokens;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }
  
  /// Logout and clear session
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _authRepository.logout();
    } catch (e) {
      // Ignore logout errors, clear local state anyway
    }
    
    _currentUser = null;
    _tokens = null;
    _isLoading = false;
    notifyListeners();
  }
  
  /// Check if user has a specific role
  bool hasRole(UserRole role) {
    return _currentUser?.role == role;
  }
  
  /// Check if user is a student
  bool get isStudent => hasRole(UserRole.student);
  
  /// Check if user is a parent
  bool get isParent => hasRole(UserRole.parent);
  
  /// Check if user is a teacher
  bool get isTeacher => hasRole(UserRole.teacher);
  
  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
