// 🔵 Google认证服务 - 处理谷歌账号登录功能
// 提供谷歌登录、登出、获取用户信息等功能

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

/// Google认证结果
class GoogleAuthResult {
  final bool success;
  final String? error;
  final User? user;
  final String? displayName;
  final String? email;
  final String? photoUrl;

  GoogleAuthResult({
    required this.success,
    this.error,
    this.user,
    this.displayName,
    this.email,
    this.photoUrl,
  });
}

/// Google认证服务
class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  /// 获取当前用户
  User? get currentUser => _firebaseAuth.currentUser;

  /// 检查是否已登录
  bool get isSignedIn => currentUser != null;

  /// 谷歌登录
  Future<GoogleAuthResult> signInWithGoogle() async {
    try {
      // 开始谷歌登录流程
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // 用户取消登录
        return GoogleAuthResult(
          success: false,
          error: '用户取消登录',
        );
      }

      // 尝试使用Firebase认证（如果可用）
      try {
        // 获取认证详情
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // 创建Firebase凭证
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // 使用凭证登录Firebase
        final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          debugPrint('Google Firebase登录成功: ${user.displayName} (${user.email})');
          return GoogleAuthResult(
            success: true,
            user: user,
            displayName: user.displayName,
            email: user.email,
            photoUrl: user.photoURL,
          );
        }
      } catch (firebaseError) {
        debugPrint('Firebase登录失败，使用基本谷歌登录: $firebaseError');
        // 如果Firebase失败，直接使用谷歌账号信息
      }

      // 使用基本的谷歌账号信息（不依赖Firebase）
      debugPrint('使用基本Google登录: ${googleUser.displayName} (${googleUser.email})');
      return GoogleAuthResult(
        success: true,
        user: null, // 没有Firebase用户
        displayName: googleUser.displayName,
        email: googleUser.email,
        photoUrl: googleUser.photoUrl,
      );

    } catch (e) {
      debugPrint('Google登录错误: $e');
      return GoogleAuthResult(
        success: false,
        error: '登录失败: ${e.toString()}',
      );
    }
  }

  /// 退出登录
  Future<bool> signOut() async {
    bool googleSignedOut = false;
    bool firebaseSignedOut = false;
    
    try {
      // 尝试退出Google登录
      try {
        await _googleSignIn.signOut();
        googleSignedOut = true;
        debugPrint('Google登录已退出');
      } catch (e) {
        debugPrint('Google退出失败: $e');
      }
      
      // 尝试退出Firebase登录
      try {
        await _firebaseAuth.signOut();
        firebaseSignedOut = true;
        debugPrint('Firebase登录已退出');
      } catch (e) {
        debugPrint('Firebase退出失败: $e');
      }
      
      // 只要有一个成功就算成功
      final success = googleSignedOut || firebaseSignedOut;
      debugPrint('退出登录${success ? '成功' : '失败'}');
      return success;
      
    } catch (e) {
      debugPrint('退出登录总体错误: $e');
      return false;
    }
  }

  /// 获取用户信息
  Map<String, dynamic>? getUserInfo() {
    final user = currentUser;
    if (user == null) return null;

    return {
      'uid': user.uid,
      'displayName': user.displayName ?? '未知用户',
      'email': user.email ?? '',
      'photoUrl': user.photoURL ?? '',
      'emailVerified': user.emailVerified,
      'creationTime': user.metadata.creationTime?.toIso8601String(),
      'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String(),
    };
  }

  /// 监听认证状态变化
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// 重新认证（用于敏感操作）
  Future<bool> reauthenticate() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await currentUser?.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      debugPrint('重新认证错误: $e');
      return false;
    }
  }

  /// 删除账户
  Future<bool> deleteAccount() async {
    try {
      // 先重新认证
      final reauthSuccess = await reauthenticate();
      if (!reauthSuccess) {
        return false;
      }

      // 删除Firebase账户
      await currentUser?.delete();
      
      // 退出Google登录
      await _googleSignIn.signOut();
      
      debugPrint('账户已删除');
      return true;
    } catch (e) {
      debugPrint('删除账户错误: $e');
      return false;
    }
  }
}