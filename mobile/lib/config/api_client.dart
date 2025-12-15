import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'environment.dart';

/// HTTP client configuration using Dio.
/// Handles authentication tokens and request/response interceptors.
class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  ApiClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: Environment.apiBaseUrl,
      connectTimeout: Duration(milliseconds: Environment.connectionTimeout),
      receiveTimeout: Duration(milliseconds: Environment.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _setupInterceptors();
  }
  
  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }
  
  Dio get dio => _dio;
  
  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read(key: _accessTokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        if (Environment.enableLogging) {
          print('REQUEST[${options.method}] => PATH: ${options.path}');
        }
        
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (Environment.enableLogging) {
          print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
        }
        return handler.next(response);
      },
      onError: (error, handler) async {
        if (Environment.enableLogging) {
          print('ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
        }
        
        // Handle 401 Unauthorized - attempt token refresh
        if (error.response?.statusCode == 401) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry the original request
            final retryResponse = await _retryRequest(error.requestOptions);
            return handler.resolve(retryResponse);
          }
        }
        
        return handler.next(error);
      },
    ));
  }
  
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      if (refreshToken == null) return false;
      
      final response = await Dio().post(
        '${Environment.apiBaseUrl}/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      
      if (response.statusCode == 200) {
        await saveTokens(
          accessToken: response.data['access_token'],
          refreshToken: response.data['refresh_token'],
        );
        return true;
      }
    } catch (e) {
      if (Environment.enableLogging) {
        print('Token refresh failed: $e');
      }
    }
    return false;
  }
  
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final token = await _secureStorage.read(key: _accessTokenKey);
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $token',
      },
    );
    
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
  
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }
  
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }
  
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }
  
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }
}
