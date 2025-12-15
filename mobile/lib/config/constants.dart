/// Application-wide constants
class AppConstants {
  AppConstants._();
  
  /// Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  
  /// Auto-save interval for exam answers (in seconds)
  static const int autoSaveIntervalSeconds = 10;
  
  /// Maximum file upload size (10MB)
  static const int maxFileUploadSize = 10 * 1024 * 1024;
  
  /// Allowed file extensions for upload
  static const List<String> allowedFileExtensions = ['pdf', 'jpg', 'jpeg', 'png'];
  
  /// Notification retry settings
  static const int maxNotificationRetries = 3;
  
  /// Sync settings
  static const int syncRetryDelaySeconds = 5;
  static const int maxSyncRetries = 3;
  
  /// Time sync tolerance (in seconds)
  static const int timeSyncToleranceSeconds = 5;
}

/// API endpoint paths
class ApiEndpoints {
  ApiEndpoints._();
  
  // Auth
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  
  // Exams
  static const String exams = '/exams';
  static String examById(String id) => '/exams/$id';
  static String joinExam(String id) => '/exams/$id/join';
  
  // Attempts
  static const String attempts = '/attempts';
  static String attemptById(String id) => '/attempts/$id';
  static String attemptQuestions(String id) => '/attempts/$id/questions';
  static String attemptAnswers(String id) => '/attempts/$id/answers';
  static String submitAttempt(String id) => '/attempts/$id/submit';
  
  // Time sync
  static const String serverTime = '/time';
  
  // Files
  static const String files = '/files';
  static String fileById(String id) => '/files/$id';
}
