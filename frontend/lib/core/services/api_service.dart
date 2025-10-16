import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import 'auth_service.dart';

class ApiService {
  static final Dio _dio = Dio();
  static bool _isInitialized = false;

  static void initialize() {
    if (_isInitialized) return;

    // Base configuration
    _dio.options.baseUrl = '${AppConfig.baseUrl}${AppConfig.apiVersion}';
    _dio.options.connectTimeout = AppConfig.requestTimeout;
    _dio.options.receiveTimeout = AppConfig.requestTimeout;
    _dio.options.sendTimeout = AppConfig.requestTimeout;

    // Request interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final token = await AuthService.getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Add device info
          options.headers['User-Agent'] = 'BTCBaran/1.0.0';
          options.headers['Accept'] = 'application/json';
          options.headers['Content-Type'] = 'application/json';

          // Add request ID for tracking
          options.headers['X-Request-ID'] = _generateRequestId();

          if (kDebugMode) {
            print('🌐 API Request: ${options.method} ${options.path}');
            print('📤 Headers: ${options.headers}');
            if (options.data != null) {
              print('📤 Data: ${options.data}');
            }
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
            print('📥 Data: ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            print('❌ API Error: ${error.response?.statusCode} ${error.requestOptions.path}');
            print('📥 Error Data: ${error.response?.data}');
          }

          // Handle token expiration
          if (error.response?.statusCode == 401) {
            try {
              await AuthService.refreshToken();
              // Retry the original request
              final token = await AuthService.getAuthToken();
              if (token != null) {
                error.requestOptions.headers['Authorization'] = 'Bearer $token';
                final response = await _dio.fetch(error.requestOptions);
                handler.resolve(response);
                return;
              }
            } catch (e) {
              // Refresh failed, redirect to login
              await AuthService.logout();
            }
          }

          handler.next(error);
        },
      ),
    );

    // Response interceptor for error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          // Handle network errors
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout) {
            error = DioException(
              requestOptions: error.requestOptions,
              type: DioExceptionType.connectionTimeout,
              error: 'Connection timeout',
            );
          }

          // Handle connection errors
          if (error.type == DioExceptionType.connectionError) {
            error = DioException(
              requestOptions: error.requestOptions,
              type: DioExceptionType.connectionError,
              error: 'No internet connection',
            );
          }

          handler.next(error);
        },
      ),
    );

    _isInitialized = true;
  }

  // GET request
  static Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    _ensureInitialized();
    
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  static Future<Map<String, dynamic>> post(
    String path,
    dynamic data, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    _ensureInitialized();
    
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  static Future<Map<String, dynamic>> put(
    String path,
    dynamic data, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    _ensureInitialized();
    
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  static Future<Map<String, dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    _ensureInitialized();
    
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH request
  static Future<Map<String, dynamic>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    _ensureInitialized();
    
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Upload file
  static Future<Map<String, dynamic>> uploadFile(
    String path,
    File file, {
    String fieldName = 'file',
    Map<String, dynamic>? extraData,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    _ensureInitialized();
    
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(file.path),
        ...?extraData,
      });

      final response = await _dio.post(
        path,
        data: formData,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Download file
  static Future<void> downloadFile(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    _ensureInitialized();
    
    try {
      await _dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Helper methods
  static void _ensureInitialized() {
    if (!_isInitialized) {
      initialize();
    }
  }

  static Map<String, dynamic> _handleResponse(Response response) {
    if (response.data is Map<String, dynamic>) {
      return response.data;
    } else if (response.data is String) {
      try {
        return jsonDecode(response.data);
      } catch (e) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Response parsed as string',
        };
      }
    } else {
      return {
        'success': true,
        'data': response.data,
        'message': 'Response received',
      };
    }
  }

  static Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return Exception('Connection timeout. Please try again.');
        
        case DioExceptionType.connectionError:
          return Exception('No internet connection. Please check your network.');
        
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;
          
          if (data is Map<String, dynamic> && data['message'] != null) {
            return Exception(data['message']);
          }
          
          switch (statusCode) {
            case 400:
              return Exception('Bad request. Please check your input.');
            case 401:
              return Exception('Unauthorized. Please login again.');
            case 403:
              return Exception('Access denied. You don\'t have permission.');
            case 404:
              return Exception('Resource not found.');
            case 429:
              return Exception('Too many requests. Please try again later.');
            case 500:
              return Exception('Server error. Please try again later.');
            case 502:
            case 503:
            case 504:
              return Exception('Service unavailable. Please try again later.');
            default:
              return Exception('Request failed with status code: $statusCode');
          }
        
        case DioExceptionType.cancel:
          return Exception('Request was cancelled.');
        
        case DioExceptionType.unknown:
        default:
          if (error.error is SocketException) {
            return Exception('Network error. Please check your connection.');
          }
          return Exception('An unexpected error occurred: ${error.message}');
      }
    }
    
    return Exception('An unexpected error occurred: ${error.toString()}');
  }

  static String _generateRequestId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Cancel all requests
  static void cancelAllRequests() {
    _dio.close();
  }

  // Get Dio instance (for advanced usage)
  static Dio get dio => _dio;
}
