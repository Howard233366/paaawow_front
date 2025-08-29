// 🔵 PetTalk 网络管理器 - 完全匹配旧Android项目的NetworkManager.kt
// 严格按照旧项目NetworkManager.kt逐行复刻网络服务架构

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pet_talk/services/api/api_config.dart';
import 'package:pet_talk/services/user/user_preferences.dart';
// import 'package:pretty_dio_logger/pretty_dio_logger.dart'; // 注释掉，需要时再添加依赖

/// 认证拦截器 - 完全匹配旧项目AuthInterceptor
class AuthInterceptor extends Interceptor {
  final UserPreferences _userPreferences;

  AuthInterceptor(this._userPreferences);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // 获取JWT token - 匹配旧项目逻辑
      final token = await _userPreferences.getAuthToken();
      
      // 如果有token，添加到请求头 - 匹配旧项目
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      
      handler.next(options);
    } catch (e) {
      handler.next(options);
    }
  }
}

/// 网络管理器 - 完全匹配旧项目NetworkManager
class NetworkManager {
  static NetworkManager? _instance;
  static NetworkManager get instance => _instance!;

  late Dio _dio;
  late UserPreferences _userPreferences;

  /// 私有构造函数
  NetworkManager._();

  /// 初始化网络管理器 - 匹配旧项目initialize方法
  static Future<void> initialize() async {
    if (_instance != null) return;
    
    _instance = NetworkManager._();
    await _instance!._initializeDio();
  }

  /// 初始化Dio实例 - 匹配旧项目的OkHttpClient配置
  Future<void> _initializeDio() async {
    _userPreferences = UserPreferences.instance;
    
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConfig.readTimeout),
      sendTimeout: Duration(milliseconds: ApiConfig.writeTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 添加认证拦截器 - 匹配旧项目
    _dio.interceptors.add(AuthInterceptor(_userPreferences));

    // 添加日志拦截器 - 匹配旧项目loggingInterceptor
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        logPrint: (obj) => print('🌐 API: $obj'),
      ));
    }

    // 添加错误处理拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        _handleNetworkError(error);
        handler.next(error);
      },
    ));
  }

  /// 获取Dio实例
  Dio get dio => _dio;

  /// 网络错误处理 - 增强版错误处理
  void _handleNetworkError(DioException error) {
    String errorMessage = '';
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = '网络连接超时，请检查网络设置';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode != null) {
          switch (statusCode) {
            case 401:
              errorMessage = '认证失败，请重新登录';
              _handleUnauthorized();
              break;
            case 403:
              errorMessage = '权限不足';
              break;
            case 404:
              errorMessage = '请求的资源不存在';
              break;
            case 500:
              errorMessage = '服务器内部错误';
              break;
            default:
              errorMessage = '请求失败 (状态码: $statusCode)';
          }
        } else {
          errorMessage = '网络请求失败';
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = '请求已取消';
        break;
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          errorMessage = '网络连接失败，请检查网络设置';
        } else {
          errorMessage = '未知网络错误: ${error.message}';
        }
        break;
      default:
        errorMessage = '网络请求异常';
    }

    if (kDebugMode) {
      print('🔴 网络错误: $errorMessage');
      print('🔴 错误详情: ${error.toString()}');
    }
  }

  /// 处理401未授权错误 - 匹配旧项目认证失效处理
  Future<void> _handleUnauthorized() async {
    try {
      // 清除认证信息
      await _userPreferences.clearAuthToken();
      await _userPreferences.clearUser();
      
      // TODO: 导航到登录页面
      // 这里需要配合路由管理器实现
      
    } catch (e) {
      if (kDebugMode) {
        print('🔴 处理未授权错误失败: $e');
      }
    }
  }

  /// GET请求 - 匹配旧项目封装
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// POST请求 - 匹配旧项目封装
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// PUT请求 - 匹配旧项目封装
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// DELETE请求 - 匹配旧项目封装
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// 上传文件 - 新增功能
  Future<Response<T>> uploadFile<T>(
    String path,
    String filePath, {
    String? fileName,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    final formData = FormData();
    
    if (data != null) {
      formData.fields.addAll(data.entries.map((e) => MapEntry(e.key, e.value.toString())));
    }
    
    formData.files.add(MapEntry(
      'file',
      await MultipartFile.fromFile(filePath, filename: fileName),
    ));

    return await _dio.post<T>(
      path,
      data: formData,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
    );
  }

  /// 清理资源
  void dispose() {
    _dio.close();
  }
}