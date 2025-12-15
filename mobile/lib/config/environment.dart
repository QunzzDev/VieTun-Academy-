/// Environment configuration for the mobile application.
/// Supports development, staging, and production environments.
/// Requirements: 21.1
class Environment {
  static late EnvironmentConfig _config;
  
  static EnvironmentConfig get config => _config;
  
  static Future<void> initialize() async {
    // Default to development environment
    // In production, this would be set via build configuration
    const env = String.fromEnvironment('ENV', defaultValue: 'development');
    
    switch (env) {
      case 'production':
        _config = EnvironmentConfig.production();
        break;
      case 'staging':
        _config = EnvironmentConfig.staging();
        break;
      default:
        _config = EnvironmentConfig.development();
    }
  }
  
  static String get apiBaseUrl => _config.apiBaseUrl;
  static String get environment => _config.environment;
  static bool get enableLogging => _config.enableLogging;
  static int get connectionTimeout => _config.connectionTimeout;
  static int get receiveTimeout => _config.receiveTimeout;
  static int get autoSaveIntervalSeconds => _config.autoSaveIntervalSeconds;
}

class EnvironmentConfig {
  final String apiBaseUrl;
  final String environment;
  final bool enableLogging;
  final int connectionTimeout;
  final int receiveTimeout;
  final int autoSaveIntervalSeconds;
  
  const EnvironmentConfig({
    required this.apiBaseUrl,
    required this.environment,
    required this.enableLogging,
    required this.connectionTimeout,
    required this.receiveTimeout,
    required this.autoSaveIntervalSeconds,
  });
  
  factory EnvironmentConfig.development() {
    return const EnvironmentConfig(
      apiBaseUrl: 'http://localhost:8000/api',
      environment: 'development',
      enableLogging: true,
      connectionTimeout: 30000,
      receiveTimeout: 30000,
      autoSaveIntervalSeconds: 10,
    );
  }
  
  factory EnvironmentConfig.staging() {
    return const EnvironmentConfig(
      apiBaseUrl: 'https://staging-api.examplatform.com/api',
      environment: 'staging',
      enableLogging: true,
      connectionTimeout: 30000,
      receiveTimeout: 30000,
      autoSaveIntervalSeconds: 10,
    );
  }
  
  factory EnvironmentConfig.production() {
    return const EnvironmentConfig(
      apiBaseUrl: 'https://api.examplatform.com/api',
      environment: 'production',
      enableLogging: false,
      connectionTimeout: 30000,
      receiveTimeout: 30000,
      autoSaveIntervalSeconds: 10,
    );
  }
}
