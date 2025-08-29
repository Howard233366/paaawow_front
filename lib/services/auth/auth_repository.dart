// 🔵 PetTalk 认证存储库 - 完全匹配旧Android项目的AuthRepository.kt
// 严格按照旧项目AuthRepository.kt逐行复刻认证逻辑

import 'dart:developer' as developer;
import 'package:pet_talk/services/api/api_service.dart';
import 'package:pet_talk/services/user/user_preferences.dart';
import 'package:pet_talk/models/common_models.dart';
import 'package:pet_talk/models/user_models.dart';

/// 认证存储库 - 匹配旧项目AuthRepository
class AuthRepository {
  static const String _tag = 'AuthRepository';
  
  // 单例模式 - 匹配旧项目getInstance
  static AuthRepository? _instance;
  static AuthRepository get instance => _instance ??= AuthRepository._();
  
  final ApiService _apiService = ApiService();
  final UserPreferences _userPreferences = UserPreferences.instance;
  
  AuthRepository._();

  /// 登录 - 匹配旧项目login(email, password)
  Future<Result<String>> login(String email, String password) async {
    try {
      developer.log('Attempting login for email: $email', name: _tag);
      
      final result = await _apiService.login(LoginRequest(
        email: email,
        password: password,
      ));
      
      if (result.isSuccess && result.data != null) {
        final responseData = result.data!;
        
        if (responseData.data != null) {
          // 保存用户信息和令牌
          await _userPreferences.saveAuthToken(responseData.data!.token);
          await _userPreferences.saveUserId(responseData.data!.user.id);
          await _userPreferences.saveUserEmail(email);
          
          developer.log('Login successful', name: _tag);
          return Result.success('登录成功');
        } else {
          return Result.error('登录响应数据异常');
        }
      } else {
        return Result.error(result.error ?? '登录失败');
      }
    } catch (e) {
      developer.log('Login error: $e', name: _tag);
      return Result.error('登录失败: ${e.toString()}');
    }
  }

  /// 验证码登录 - 匹配旧项目loginWithCode
  Future<Result<String>> loginWithCode(String email, String code) async {
    try {
      developer.log('Attempting login with code for email: $email', name: _tag);
      
      final result = await _apiService.loginWithCode(CodeRegisterRequest(
        email: email,
        verificationCode: code,
      ));
      
      if (result.isSuccess && result.data != null) {
        final responseData = result.data!;
        
        if (responseData.data != null) {
          // 保存用户信息和令牌
          await _userPreferences.saveAuthToken(responseData.data!.token);
          await _userPreferences.saveUserId(responseData.data!.user.id);
          await _userPreferences.saveUserEmail(email);
          
          developer.log('Login with code successful', name: _tag);
          return Result.success('登录成功');
        } else {
          return Result.error('登录响应数据异常');
        }
      } else {
        return Result.error(result.error ?? '验证码登录失败');
      }
    } catch (e) {
      developer.log('Login with code error: $e', name: _tag);
      return Result.error('验证码登录失败: ${e.toString()}');
    }
  }

  /// 发送验证码 - 匹配旧项目sendVerificationCode
  Future<Result<String>> sendCode(String email) async {
    try {
      developer.log('Sending verification code to email: $email', name: _tag);
      
      final result = await _apiService.sendVerificationCode(SendCodeRequest(
        email: email,
        type: 'login',
      ));
      
      if (result.isSuccess) {
        developer.log('Verification code sent successfully', name: _tag);
        return Result.success('验证码已发送');
      } else {
        return Result.error(result.error ?? '发送验证码失败');
      }
    } catch (e) {
      developer.log('Send verification code error: $e', name: _tag);
      return Result.error('发送验证码失败: ${e.toString()}');
    }
  }

  /// 注册 - 匹配旧项目register
  Future<Result<String>> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      developer.log('Attempting registration for email: $email', name: _tag);
      
      final result = await _apiService.register(RegisterRequest(
        username: username,
        email: email,
        password: password,
        profile: UserProfileData(
          firstName: firstName,
          lastName: lastName,
        ),
      ));
      
      if (result.isSuccess && result.data != null) {
        final responseData = result.data!;
        
        if (responseData.data != null) {
          // 保存用户信息和令牌
          await _userPreferences.saveAuthToken(responseData.data!.token);
          await _userPreferences.saveUserId(responseData.data!.user.id);
          await _userPreferences.saveUserEmail(email);
          
          developer.log('Registration successful', name: _tag);
          return Result.success('注册成功');
        } else {
          return Result.error('注册响应数据异常');
        }
      } else {
        return Result.error(result.error ?? '注册失败');
      }
    } catch (e) {
      developer.log('Registration error: $e', name: _tag);
      return Result.error('注册失败: ${e.toString()}');
    }
  }

  /// 验证码注册 - 匹配旧项目registerWithCode
  Future<Result<String>> registerWithCode(String email, String code) async {
    try {
      developer.log('Attempting registration with code for email: $email', name: _tag);
      
      final result = await _apiService.registerWithCode(CodeRegisterRequest(
        email: email,
        verificationCode: code,
      ));
      
      if (result.isSuccess && result.data != null) {
        final responseData = result.data!;
        
        if (responseData.data != null) {
          // 保存用户信息和令牌
          await _userPreferences.saveAuthToken(responseData.data!.token);
          await _userPreferences.saveUserId(responseData.data!.user.id);
          await _userPreferences.saveUserEmail(email);
          
          developer.log('Registration with code successful', name: _tag);
          return Result.success('注册成功');
        } else {
          return Result.error('注册响应数据异常');
        }
      } else {
        return Result.error(result.error ?? '验证码注册失败');
      }
    } catch (e) {
      developer.log('Registration with code error: $e', name: _tag);
      return Result.error('验证码注册失败: ${e.toString()}');
    }
  }

  /// 重置密码 - 匹配旧项目resetPassword
  Future<Result<String>> resetPassword(String email) async {
    try {
      developer.log('Attempting password reset for email: $email', name: _tag);
      
      final result = await _apiService.resetPassword({
        'email': email,
      });
      
      if (result.isSuccess) {
        developer.log('Password reset successful', name: _tag);
        return Result.success('密码重置链接已发送到您的邮箱');
      } else {
        return Result.error(result.error ?? '重置密码失败');
      }
    } catch (e) {
      developer.log('Password reset error: $e', name: _tag);
      return Result.error('重置密码失败: ${e.toString()}');
    }
  }

  /// 登出 - 匹配旧项目logout
  Future<Result<String>> logout() async {
    try {
      developer.log('Attempting logout', name: _tag);
      
      // 清除本地存储的用户信息
      await _userPreferences.clearUserData();
      
      developer.log('Logout successful', name: _tag);
      return Result.success('登出成功');
    } catch (e) {
      developer.log('Logout error: $e', name: _tag);
      return Result.error('登出失败: ${e.toString()}');
    }
  }

  /// 检查是否已登录 - 匹配旧项目isLoggedIn
  Future<bool> isLoggedIn() async {
    try {
      final token = await _userPreferences.getAuthToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      developer.log('Check login status error: $e', name: _tag);
      return false;
    }
  }

  /// 检查是否已认证 - 匹配旧项目isAuthenticated（别名方法）
  Future<bool> isAuthenticated() async {
    return await isLoggedIn();
  }

  /// 刷新Token - 新增功能（为未来扩展）
  Future<Result<String>> refreshToken() async {
    try {
      developer.log('Refreshing token', name: _tag);
      
      final refreshToken = await _userPreferences.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return Result.error('没有有效的刷新令牌');
      }
      
      final result = await _apiService.refreshToken({
        'refresh_token': refreshToken,
      });
      
      if (result.isSuccess && result.data != null) {
        final responseData = result.data!;
        
        if (responseData.data != null) {
          // 保存新的访问令牌
          await _userPreferences.saveAuthToken(responseData.data!.token);
          
          developer.log('Token refresh successful', name: _tag);
          return Result.success('令牌刷新成功');
        } else {
          return Result.error('刷新令牌响应数据异常');
        }
      } else {
        return Result.error(result.error ?? '刷新令牌失败');
      }
    } catch (e) {
      developer.log('Token refresh error: $e', name: _tag);
      return Result.error('刷新令牌失败: ${e.toString()}');
    }
  }

  /// 获取当前用户信息 - 匹配旧项目getCurrentUser
  Future<Result<UserProfile>> getCurrentUser() async {
    try {
      developer.log('Getting current user info', name: _tag);
      
      final result = await _apiService.getUserProfile({});
      
      if (result.isSuccess && result.data != null) {
        final responseData = result.data!;
        
        if (responseData.data != null) {
          final userProfile = responseData.data!.user;
          developer.log('Get current user successful', name: _tag);
          return Result.success(userProfile);
        } else {
          return Result.error('用户信息响应数据异常');
        }
      } else {
        return Result.error(result.error ?? '获取用户信息失败');
      }
    } catch (e) {
      developer.log('Get current user error: $e', name: _tag);
      return Result.error('获取用户信息失败: ${e.toString()}');
    }
  }
}