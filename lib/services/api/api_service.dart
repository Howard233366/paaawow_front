// 🔵 PetTalk API服务 - 完全匹配旧Android项目的ApiService.kt
// 严格按照旧项目ApiService.kt逐行复刻API接口定义

import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:pet_talk/services/network/network_manager.dart';
import 'package:pet_talk/models/user_models.dart';
import 'package:pet_talk/services/api/api_config.dart';

// ==================== 请求模型 - 匹配旧项目 ====================

/// 登录请求 - 匹配旧项目LoginRequest
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

/// 发送验证码请求 - 匹配旧项目SendCodeRequest
class SendCodeRequest {
  final String email;
  final String type; // "login", "register", "reset"

  const SendCodeRequest({
    required this.email,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'type': type,
    };
  }
}

/// 验证码注册请求 - 匹配旧项目CodeRegisterRequest
class CodeRegisterRequest {
  final String email;
  final String verificationCode;

  const CodeRegisterRequest({
    required this.email,
    required this.verificationCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'verificationCode': verificationCode,
    };
  }
}

/// 注册请求 - 匹配旧项目RegisterRequest
class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final UserProfileData profile;

  const RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.profile,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'profile': profile.toJson(),
    };
  }
}

// ==================== 响应模型 - 匹配旧项目 ====================

/// 认证响应 - 匹配旧项目AuthResponse
class AuthResponse {
  final bool success;
  final String message;
  final AuthData? data;

  const AuthResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? AuthData.fromJson(json['data']) : null,
    );
  }
}

/// 认证数据 - 匹配旧项目AuthData
class AuthData {
  final UserProfile user;
  final String token;

  const AuthData({
    required this.user,
    required this.token,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      user: UserProfile.fromJson(json['user']),
      token: json['token'] ?? '',
    );
  }
}

/// 健康检查响应 - 匹配旧项目HealthCheckResponse
class HealthCheckResponse {
  final bool success;
  final String message;
  final String? version;

  const HealthCheckResponse({
    required this.success,
    required this.message,
    this.version,
  });

  factory HealthCheckResponse.fromJson(Map<String, dynamic> json) {
    return HealthCheckResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      version: json['version'],
    );
  }
}

// ==================== API服务主类 - 匹配旧项目 ====================

/// API服务 - 完全匹配旧项目ApiService接口
class ApiService {
  static const String _tag = "ApiService";
  
  final NetworkManager _networkManager;

  ApiService({NetworkManager? networkManager}) 
      : _networkManager = networkManager ?? NetworkManager.instance;

  // ==================== 认证API - 匹配旧项目 ====================

  /// 用户注册 - 匹配旧项目register
  Future<ApiResult<AuthResponse>> register(RegisterRequest request) async {
    try {
      developer.log('API: register request', name: _tag);
      
      final response = await _networkManager.post(
        ApiConfig.authRegister,
        data: request.toJson(),
      );
      
      final authResponse = AuthResponse.fromJson(response.data);
      return ApiResult.success(authResponse);
    } catch (e) {
      developer.log('API: register error: $e', name: _tag);
      return ApiResult.failure(_handleError(e));
    }
  }

  /// 验证码注册 - 匹配旧项目registerWithCode
  Future<ApiResult<AuthResponse>> registerWithCode(CodeRegisterRequest request) async {
    try {
      developer.log('API: registerWithCode request', name: _tag);
      
      final response = await _networkManager.post(
        ApiConfig.authRegisterCode,
        data: request.toJson(),
      );
      
      final authResponse = AuthResponse.fromJson(response.data);
      return ApiResult.success(authResponse);
    } catch (e) {
      developer.log('API: registerWithCode error: $e', name: _tag);
      return ApiResult.failure(_handleError(e));
    }
  }

  /// 发送验证码 - 匹配旧项目sendVerificationCode
  Future<ApiResult<AuthResponse>> sendVerificationCode(SendCodeRequest request) async {
    try {
      developer.log('API: sendVerificationCode request', name: _tag);
      
      final response = await _networkManager.post(
        ApiConfig.authSendCode,
        data: request.toJson(),
      );
      
      final authResponse = AuthResponse.fromJson(response.data);
      return ApiResult.success(authResponse);
    } catch (e) {
      developer.log('API: sendVerificationCode error: $e', name: _tag);
      return ApiResult.failure(_handleError(e));
    }
  }

  /// 用户登录 - 匹配旧项目login
  Future<ApiResult<AuthResponse>> login(LoginRequest request) async {
    try {
      developer.log('API: login request', name: _tag);
      
      final response = await _networkManager.post(
        ApiConfig.authLogin,
        data: request.toJson(),
      );
      
      final authResponse = AuthResponse.fromJson(response.data);
      return ApiResult.success(authResponse);
    } catch (e) {
      developer.log('API: login error: $e', name: _tag);
      return ApiResult.failure(_handleError(e));
    }
  }

  /// 验证码登录 - 新增方法匹配AuthRepository
  Future<ApiResult<AuthResponse>> loginWithCode(CodeRegisterRequest request) async {
    try {
      developer.log('API: loginWithCode request', name: _tag);
      
      final response = await _networkManager.post(
        ApiConfig.authLoginWithCode,
        data: request.toJson(),
      );
      
      final authResponse = AuthResponse.fromJson(response.data);
      return ApiResult.success(authResponse);
    } catch (e) {
      developer.log('API: loginWithCode error: $e', name: _tag);
      return ApiResult.failure(_handleError(e));
    }
  }

  /// 重置密码 - 新增方法匹配AuthRepository
  Future<ApiResult<AuthResponse>> resetPassword(Map<String, dynamic> request) async {
    try {
      developer.log('API: resetPassword request', name: _tag);
      
      final response = await _networkManager.post(
        ApiConfig.authResetPassword,
        data: request,
      );
      
      final authResponse = AuthResponse.fromJson(response.data);
      return ApiResult.success(authResponse);
    } catch (e) {
      developer.log('API: resetPassword error: $e', name: _tag);
      return ApiResult.failure(_handleError(e));
    }
  }

  /// 刷新Token - 新增方法匹配AuthRepository
  Future<ApiResult<AuthResponse>> refreshToken(Map<String, dynamic> request) async {
    try {
      developer.log('API: refreshToken request', name: _tag);
      
      final response = await _networkManager.post(
        ApiConfig.authRefreshToken,
        data: request,
      );
      
      final authResponse = AuthResponse.fromJson(response.data);
      return ApiResult.success(authResponse);
    } catch (e) {
      developer.log('API: refreshToken error: $e', name: _tag);
      return ApiResult.failure(_handleError(e));
    }
  }

  /// 获取用户资料 - 新增方法匹配AuthRepository
  Future<ApiResult<AuthResponse>> getUserProfile(Map<String, dynamic> params) async {
    try {
      developer.log('API: getUserProfile request', name: _tag);
      
      final response = await _networkManager.get(
        ApiConfig.authProfile,
        queryParameters: params,
      );
      
      final authResponse = AuthResponse.fromJson(response.data);
      return ApiResult.success(authResponse);
    } catch (e) {
      developer.log('API: getUserProfile error: $e', name: _tag);
      return ApiResult.failure(_handleError(e));
    }
  }

  /// 获取当前用户 - 匹配旧项目getCurrentUser
  Future<ApiResult<AuthResponse>> getCurrentUser() async {
    try {
      developer.log('API: getCurrentUser request', name: _tag);
      
      final response = await _networkManager.get(ApiConfig.authMe);
      
      final authResponse = AuthResponse.fromJson(response.data);
      return ApiResult.success(authResponse);
    } catch (e) {
      developer.log('API: getCurrentUser error: $e', name: _tag);
      return ApiResult.failure(_handleError(e));
    }
  }

  // ==================== GPT API - 匹配旧项目 ====================

  /// 宠物聊天 - 匹配旧项目petGeneralChat
  Future<ApiResult<Map<String, dynamic>>> petGeneralChat(Map<String, dynamic> request) async {
    try {
      developer.log('API: petGeneralChat request', name: _tag);
      
      final response = await _networkManager.post(
        ApiConfig.gptChat,
        data: request,
      );
      
      return ApiResult.success(response.data);
    } catch (e) {
      developer.log('API: petGeneralChat error: $e', name: _tag);
      return ApiResult.failure(_handleError(e));
    }
  }

  /// 训练建议 - 匹配旧项目petTrainingAdvice
  Future<ApiResult<Map<String, dynamic>>> petTrainingAdvice(Map<String, dynamic> request) async {
    try {
      developer.log('API: petTrainingAdvice request', name: _tag);
      
      final response = await _networkManager.post(
        ApiConfig.gptTraining,
        data: request,
      );
      
      return ApiResult.success(response.data);
    } catch (e) {
      developer.log('API: petTrainingAdvice error: $e', name: _tag);
      return ApiResult.failure(_handleError(e));
    }
  }

  /// 狗语翻译 - 匹配旧项目dogLanguageTranslation
  Future<ApiResult<Map<String, dynamic>>> dogLanguageTranslation(Map<String, dynamic> request) async {
    try {
      developer.log('API: dogLanguageTranslation request', name: _tag);
      
      final response = await _networkManager.post(
        ApiConfig.gptTranslate,
        data: request,
      );
      
      return ApiResult.success(response.data);
    } catch (e) {
      developer.log('API: dogLanguageTranslation error: $e', name: _tag);
      return ApiResult.failure(_handleError(e));
    }
  }

  /// 健康检查 - 匹配旧项目gptHealthCheck
  Future<ApiResult<HealthCheckResponse>> gptHealthCheck() async {
    try {
      developer.log('API: gptHealthCheck request', name: _tag);
      
      final response = await _networkManager.get(ApiConfig.healthCheck);
      
      final healthResponse = HealthCheckResponse.fromJson(response.data);
      return ApiResult.success(healthResponse);
    } catch (e) {
      developer.log('API: gptHealthCheck error: $e', name: _tag);
      return ApiResult.failure(_handleError(e));
    }
  }

  // ==================== 健康API - 匹配旧项目 ====================

  /// 获取健康情绪数据 - 匹配旧项目getHealthMoodData
  Future<ApiResult<Map<String, dynamic>>> getHealthMoodData({
    required String petId,
    String? date,
  }) async {
    try {
      developer.log('API: getHealthMoodData request', name: _tag);
      
      final response = await _networkManager.get(
        ApiConfig.healthMood,
        queryParameters: {
          'pet_id': petId,
          if (date != null) 'date': date,
        },
      );
      
      return ApiResult.success(response.data);
    } catch (e) {
      developer.log('API: getHealthMoodData error: $e', name: _tag);
      return ApiResult.failure(_handleError(e));
    }
  }

  // ==================== 错误处理 - 匹配旧项目 ====================

  /// 处理API错误 - 匹配旧项目错误处理
  String _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return '网络连接超时';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data?['message'];
          if (message != null) {
            return message.toString();
          }
          return '请求失败 (状态码: $statusCode)';
        case DioExceptionType.cancel:
          return '请求已取消';
        case DioExceptionType.unknown:
        default:
          return '网络请求失败: ${error.message}';
      }
    }
    return error.toString();
  }
}

// ==================== 结果封装 - 匹配旧项目Result模式 ====================

/// API结果封装 - 匹配旧项目Result模式
class ApiResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  ApiResult._({this.data, this.error, required this.isSuccess});

  factory ApiResult.success(T data) {
    return ApiResult._(data: data, isSuccess: true);
  }

  factory ApiResult.failure(String error) {
    return ApiResult._(error: error, isSuccess: false);
  }

  bool get isFailure => !isSuccess;
}