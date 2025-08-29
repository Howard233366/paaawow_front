// 🍎 苹果登录服务 - Sign in with Apple 实现
// 支持iOS、macOS和Web平台的苹果账号登录

import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 苹果登录认证结果
class AppleAuthResult {
  final bool success;
  final String? error;
  final String? displayName;
  final String? email;
  final String? userId;
  final User? firebaseUser; // Firebase用户（如果集成Firebase）

  AppleAuthResult({
    required this.success,
    this.error,
    this.displayName,
    this.email,
    this.userId,
    this.firebaseUser,
  });
}

/// 苹果登录认证服务
class AppleAuthService {
  static final AppleAuthService _instance = AppleAuthService._internal();
  factory AppleAuthService() => _instance;
  AppleAuthService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// 检查是否支持苹果登录
  /// 主要用于iOS 13.0+, macOS 10.15+, 或Web平台
  Future<bool> isAppleSignInAvailable() async {
    try {
      final isAvailable = await SignInWithApple.isAvailable();
      debugPrint('🍎 苹果登录可用性: $isAvailable');
      return isAvailable;
    } catch (e) {
      debugPrint('🍎 检查苹果登录可用性失败: $e');
      return false;
    }
  }

  /// 苹果登录 - 完整版（包含Firebase集成）
  Future<AppleAuthResult> signInWithApple() async {
    try {
      debugPrint('🍎 开始苹果登录流程...');

      // 检查是否支持苹果登录
      final isAvailable = await isAppleSignInAvailable();
      if (!isAvailable) {
        debugPrint('🍎 ❌ 当前设备不支持苹果登录');
        return AppleAuthResult(
          success: false,
          error: '当前设备不支持苹果登录',
        );
      }

      debugPrint('🍎 🚀 启动苹果登录界面...');

      // 请求苹果登录凭证
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.pettalk.translator.pet-talk', // 需要替换为实际的Client ID
          redirectUri: Uri.parse('https://pettalk-app.firebaseapp.com/__/auth/handler'),
        ),
      ).timeout(
        const Duration(minutes: 3), // 3分钟超时
        onTimeout: () {
          debugPrint('🍎 ⏰ 苹果登录超时');
          throw Exception('苹果登录超时');
        },
      );

      debugPrint('🍎 📋 苹果登录凭证获取成功');
      debugPrint('🍎 👤 用户ID: ${credential.userIdentifier}');
      debugPrint('🍎 📧 邮箱: ${credential.email ?? "未提供"}');
      debugPrint('🍎 🏷️ 姓名: ${credential.givenName ?? ""} ${credential.familyName ?? ""}');

      // 尝试Firebase集成（可选）
      User? firebaseUser;
      try {
        debugPrint('🍎 🔥 尝试Firebase集成...');
        
        // 创建OAuth凭证
        final oauthCredential = OAuthProvider("apple.com").credential(
          idToken: credential.identityToken,
          accessToken: credential.authorizationCode,
        );

        // 使用凭证登录Firebase
        final userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);
        firebaseUser = userCredential.user;
        
        debugPrint('🍎 🔥 Firebase集成成功: ${firebaseUser?.displayName}');
      } catch (firebaseError) {
        debugPrint('🍎 ⚠️ Firebase集成失败，继续使用基本苹果登录: $firebaseError');
        // 即使Firebase失败，我们仍然可以使用基本的苹果登录信息
      }

      // 构建显示名称
      String? displayName;
      if (credential.givenName != null || credential.familyName != null) {
        displayName = '${credential.givenName ?? ""} ${credential.familyName ?? ""}'.trim();
        if (displayName.isEmpty) displayName = null;
      }
      
      // 如果基本信息没有显示名称，尝试从Firebase获取
      if (displayName == null && firebaseUser?.displayName != null) {
        displayName = firebaseUser!.displayName;
      }
      
      // 如果还是没有，使用默认名称
      if (displayName == null || displayName.isEmpty) {
        displayName = 'Apple用户';
      }

      debugPrint('🍎 ✅ 苹果登录成功！');
      debugPrint('🍎 👤 最终显示名称: $displayName');

      return AppleAuthResult(
        success: true,
        displayName: displayName,
        email: credential.email ?? firebaseUser?.email,
        userId: credential.userIdentifier,
        firebaseUser: firebaseUser,
      );

    } catch (e) {
      debugPrint('🍎 💥 苹果登录错误: $e');
      debugPrint('🍎 🔍 错误类型: ${e.runtimeType}');

      // 根据错误类型提供更具体的错误信息
      String errorMessage;
      if (e.toString().contains('The user canceled the authorization request')) {
        errorMessage = '用户取消了苹果登录';
      } else if (e.toString().contains('network')) {
        errorMessage = '网络连接错误，请检查网络设置';
      } else if (e.toString().contains('timeout') || e.toString().contains('超时')) {
        errorMessage = '登录超时，请重试';
      } else if (e.toString().contains('not available')) {
        errorMessage = '当前设备不支持苹果登录';
      } else {
        errorMessage = '苹果登录失败: ${e.toString()}';
      }

      return AppleAuthResult(
        success: false,
        error: errorMessage,
      );
    }
  }

  /// 简化版苹果登录 - 不依赖Firebase
  Future<AppleAuthResult> signInWithAppleSimple() async {
    try {
      debugPrint('🍎 🟢 开始简化版苹果登录...');

      // 检查是否支持苹果登录
      final isAvailable = await isAppleSignInAvailable();
      if (!isAvailable) {
        debugPrint('🍎 🟢 ❌ 当前设备不支持苹果登录');
        return AppleAuthResult(
          success: false,
          error: '当前设备不支持苹果登录',
        );
      }

      debugPrint('🍎 🟢 🚀 启动简化版苹果登录界面...');

      // 请求苹果登录凭证（简化版）
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      ).timeout(
        const Duration(minutes: 3), // 3分钟超时
        onTimeout: () {
          debugPrint('🍎 🟢 ⏰ 简化版苹果登录超时');
          throw Exception('苹果登录超时');
        },
      );

      debugPrint('🍎 🟢 📋 简化版苹果登录凭证获取成功');
      debugPrint('🍎 🟢 👤 用户ID: ${credential.userIdentifier}');
      debugPrint('🍎 🟢 📧 邮箱: ${credential.email ?? "未提供"}');

      // 构建显示名称
      String displayName = 'Apple用户';
      if (credential.givenName != null || credential.familyName != null) {
        final fullName = '${credential.givenName ?? ""} ${credential.familyName ?? ""}'.trim();
        if (fullName.isNotEmpty) {
          displayName = fullName;
        }
      }

      debugPrint('🍎 🟢 ✅ 简化版苹果登录成功！');
      debugPrint('🍎 🟢 👤 显示名称: $displayName');

      return AppleAuthResult(
        success: true,
        displayName: displayName,
        email: credential.email,
        userId: credential.userIdentifier,
      );

    } catch (e) {
      debugPrint('🍎 🟢 💥 简化版苹果登录错误: $e');

      String errorMessage;
      if (e.toString().contains('The user canceled the authorization request')) {
        errorMessage = '用户取消了苹果登录';
      } else if (e.toString().contains('timeout') || e.toString().contains('超时')) {
        errorMessage = '登录超时，请重试';
      } else {
        errorMessage = '苹果登录失败: ${e.toString()}';
      }

      return AppleAuthResult(
        success: false,
        error: errorMessage,
      );
    }
  }

  /// 退出苹果登录
  Future<bool> signOut() async {
    try {
      // 苹果登录本身不需要特殊的退出操作
      // 但如果集成了Firebase，需要退出Firebase
      if (_firebaseAuth.currentUser != null) {
        await _firebaseAuth.signOut();
        debugPrint('🍎 Firebase苹果登录已退出');
      }
      
      debugPrint('🍎 苹果登录已退出');
      return true;
    } catch (e) {
      debugPrint('🍎 苹果登录退出失败: $e');
      return false;
    }
  }

  /// 获取当前Firebase用户信息
  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  /// 检查是否已通过苹果登录
  bool get isSignedIn => currentFirebaseUser != null;
}