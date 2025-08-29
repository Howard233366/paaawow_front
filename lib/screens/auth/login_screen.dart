// 🔵 PetTalk 登录屏幕 - 完全匹配旧Android项目的LoginScreen.kt
// 严格按照旧项目LoginScreen.kt逐行复刻登录界面

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_talk/services/auth/auth_repository.dart';
import 'package:pet_talk/services/auth/google_auth_service.dart';
import 'package:pet_talk/services/auth/apple_auth_service.dart';
import 'dart:ui';

// 登录方式枚举 - 匹配旧项目LoginMode
enum LoginMode {
  EMAIL_PASSWORD,
  EMAIL_CODE
}

/// 登录屏幕 - 完全匹配旧项目LoginScreen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ===== 背景轮播相关状态 =====
  int _currentImageIndex = 0;
  final List<String> _backgroundImages = [
    'assets/images/login/12.png',
    'assets/images/login/16.png', 
    'assets/images/login/19.png',
    'assets/images/login/22.png',
    'assets/images/login/126.png'
  ];

  // ===== 登录表单相关状态 =====
  LoginMode _loginMode = LoginMode.EMAIL_PASSWORD;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  bool _passwordVisible = false;
  bool _isLoading = false;
  bool _isSendingCode = false;
  int _remainingTime = 0;
  String _errorMessage = '';
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _startImageRotation();
    _startCountdown();
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  // ===== 邮箱输入变化联动按钮可用状态 =====
  void _onEmailChanged() {
    // 触发重建以刷新“发送验证码”按钮的enabled状态
    if (mounted) setState(() {});
  }

  // ===== 背景图片轮播 =====
  void _startImageRotation() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _backgroundImages.length;
        });
        _startImageRotation();
      }
    });
  }

  // ===== 验证码倒计时 =====
  void _startCountdown() {
    if (_remainingTime > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _remainingTime--;
          });
          _startCountdown();
        }
      });
    }
  }

  // ===== 发送验证码 =====
  Future<void> _sendVerificationCode() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter email first';
        _showError = true;
      });
      return;
    }

    setState(() {
      _isSendingCode = true;
      _showError = false;
    });

    try {
      final result = await AuthRepository.instance.sendCode(_emailController.text.trim());
      if (result.isSuccess) {
        setState(() {
          _remainingTime = 60;
          _isSendingCode = false;
        });
        _startCountdown();
      } else {
        setState(() {
          _errorMessage = result.error?.toString() ?? '发送验证码失败';
          _showError = true;
          _isSendingCode = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '网络连接失败，请检查网络设置';
        _showError = true;
        _isSendingCode = false;
      });
    }
  }

  // ===== 谷歌登录处理 =====
  Future<void> _handleGoogleLogin() async {
    debugPrint('🔵 开始谷歌登录流程');
    
    setState(() {
      _isLoading = true;
      _showError = false;
    });

    // 显示加载提示
    try {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🚀 正在启动谷歌登录...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('🔵 显示SnackBar失败: $e');
    }

    try {
      debugPrint('🔵 尝试简化版谷歌登录（跳过Firebase）');
      
      // 显示更详细的加载状态
      try {
        if (mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🔄 正在处理谷歌登录，请耐心等待...'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 15), // 延长显示时间
            ),
          );
        }
      } catch (e) {
        debugPrint('🔵 显示处理SnackBar失败: $e');
      }
      
      // 使用GoogleAuthService进行登录
      debugPrint('🔵 尝试谷歌登录...');
      final googleResult = await GoogleAuthService().signInWithGoogle();
      
      debugPrint('🔵 谷歌登录结果: ${googleResult.success}');
      debugPrint('🔵 错误信息（如果有）: ${googleResult.error}');
      
      if (mounted) {
        if (googleResult.success) {
          debugPrint('🔵 谷歌登录成功: ${googleResult.displayName}');
          debugPrint('🔵 用户邮箱: ${googleResult.email}');
          debugPrint('🔵 用户UID: ${googleResult.user?.uid}');
          
          // 简化版谷歌登录成功
          try {
            if (context.mounted) {
              ScaffoldMessenger.of(context).clearSnackBars(); // 清除之前的SnackBar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🎉 欢迎，${googleResult.displayName ?? '用户'}！'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            debugPrint('🔵 显示成功SnackBar失败: $e');
          }
          
          // 延迟跳转，让用户看到成功提示
          await Future.delayed(const Duration(milliseconds: 1500));
          
          if (mounted) {
            debugPrint('🔵 跳转到主页');
            context.go('/home');
          }
        } else {
          debugPrint('🔵 谷歌登录失败: ${googleResult.error}');
          
          // 改进错误信息显示
          String userFriendlyError = googleResult.error ?? '谷歌登录失败';
          if (userFriendlyError.contains('用户取消登录或登录超时')) {
            userFriendlyError = '登录被取消或超时，请重试';
          } else if (userFriendlyError.contains('网络连接错误')) {
            userFriendlyError = '网络连接失败，请检查网络后重试';
          }
          
          setState(() {
            _errorMessage = userFriendlyError;
            _showError = true;
          });
          
          // 同时显示SnackBar提供更好的反馈
          try {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ $userFriendlyError'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: '重试',
                    textColor: Colors.white,
                    onPressed: () => _handleGoogleLogin(),
                  ),
                ),
              );
            }
          } catch (e) {
            debugPrint('🔵 显示错误SnackBar失败: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('🔵 谷歌登录异常: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '谷歌登录错误: ${e.toString()}';
          _showError = true;
        });
      }
    } finally {
      if (mounted) {
        debugPrint('🔵 谷歌登录流程结束，设置loading=false');
        setState(() => _isLoading = false);
      }
    }
  }

  // ===== 苹果登录处理 =====
  Future<void> _handleAppleLogin() async {
    debugPrint('🍎 开始苹果登录流程');
    
    setState(() {
      _isLoading = true;
      _showError = false;
    });

    // 显示加载提示
    try {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🍎 正在启动苹果登录...'),
            backgroundColor: Colors.black,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('🍎 显示SnackBar失败: $e');
    }

    try {
      debugPrint('🍎 尝试简化版苹果登录');
      
      // 显示更详细的加载状态
      try {
        if (mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🔄 正在处理苹果登录，请耐心等待...'),
              backgroundColor: Colors.grey,
              duration: Duration(seconds: 15),
            ),
          );
        }
      } catch (e) {
        debugPrint('🍎 显示处理SnackBar失败: $e');
      }
      
      // 首先检查苹果登录可用性
      final isAvailable = await AppleAuthService().isAppleSignInAvailable();
      if (!isAvailable) {
        debugPrint('🍎 当前设备不支持苹果登录');
        if (mounted) {
          setState(() {
            _errorMessage = '当前设备不支持苹果登录';
            _showError = true;
          });
        }
        return;
      }
      
      // 使用简化版苹果登录
      final appleResult = await AppleAuthService().signInWithAppleSimple();
      
      debugPrint('🍎 苹果登录结果: ${appleResult.success}');
      debugPrint('🍎 错误信息（如果有）: ${appleResult.error}');
      
      if (mounted) {
        if (appleResult.success) {
          debugPrint('🍎 苹果登录成功: ${appleResult.displayName}');
          debugPrint('🍎 用户邮箱: ${appleResult.email}');
          debugPrint('🍎 用户ID: ${appleResult.userId}');
          
          // 苹果登录成功
          try {
            if (context.mounted) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🎉 欢迎，${appleResult.displayName ?? 'Apple用户'}！'),
                  backgroundColor: Colors.black,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            debugPrint('🍎 显示成功SnackBar失败: $e');
          }
          
          // 延迟跳转，让用户看到成功提示
          await Future.delayed(const Duration(milliseconds: 1500));
          
          if (mounted) {
            debugPrint('🍎 跳转到主页');
            context.go('/home');
          }
        } else {
          debugPrint('🍎 苹果登录失败: ${appleResult.error}');
          
          // 改进错误信息显示
          String userFriendlyError = appleResult.error ?? '苹果登录失败';
          if (userFriendlyError.contains('用户取消了苹果登录')) {
            userFriendlyError = '登录被取消，请重试';
          } else if (userFriendlyError.contains('不支持苹果登录')) {
            userFriendlyError = '当前设备不支持苹果登录';
          } else if (userFriendlyError.contains('网络连接错误')) {
            userFriendlyError = '网络连接失败，请检查网络后重试';
          }
          
          setState(() {
            _errorMessage = userFriendlyError;
            _showError = true;
          });
          
          // 同时显示SnackBar提供更好的反馈
          try {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ $userFriendlyError'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: '重试',
                    textColor: Colors.white,
                    onPressed: () => _handleAppleLogin(),
                  ),
                ),
              );
            }
          } catch (e) {
            debugPrint('🍎 显示错误SnackBar失败: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('🍎 苹果登录异常: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '苹果登录错误: ${e.toString()}';
          _showError = true;
        });
      }
    } finally {
      if (mounted) {
        debugPrint('🍎 苹果登录流程结束，设置loading=false');
        setState(() => _isLoading = false);
      }
    }
  }

  // ===== 显示即将推出提示 =====
  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature功能即将推出'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // ===== 登录处理 =====
  Future<void> _handleLogin() async {
    final isValid = _loginMode == LoginMode.EMAIL_PASSWORD
        ? _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty
        : _emailController.text.isNotEmpty && _verificationCodeController.text.length == 6;

    if (!isValid) {
      setState(() {
        _errorMessage = _loginMode == LoginMode.EMAIL_PASSWORD
            ? 'Please enter email and password'
            : 'Please enter email and 6-digit verification code';
        _showError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showError = false;
    });

    try {
      final result = _loginMode == LoginMode.EMAIL_PASSWORD
          ? await AuthRepository.instance.login(_emailController.text.trim(), _passwordController.text)
          : await AuthRepository.instance.loginWithCode(_emailController.text.trim(), _verificationCodeController.text);

      if (mounted) {
        if (result.isSuccess) {
          context.go('/home');
        } else {
          setState(() {
            _errorMessage = result.error?.toString() ?? 'Login failed';
            _showError = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Network connection failed: ${e.toString()}';
          _showError = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ===== 第一层：背景轮播图 =====
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000),
            child: Container(
              key: ValueKey(_currentImageIndex),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_backgroundImages[_currentImageIndex]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // ===== 第二层：背景遮罩效果 =====
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
            ),
          ),

          // ===== 第三层：主要内容区域 =====
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // ===== 品牌标识区域 =====
                  _buildBrandHeader(),

                  const SizedBox(height: 6),

                  // ===== 标语区域 =====
                  const Text(
                    'To be closer',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== 主要表单容器 =====
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // ===== 登录标题 =====
                        const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ===== 登录方式切换按钮 =====
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _loginMode = LoginMode.EMAIL_PASSWORD),
                                  child: Container(
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: _loginMode == LoginMode.EMAIL_PASSWORD
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Password',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _loginMode = LoginMode.EMAIL_CODE),
                                  child: Container(
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: _loginMode == LoginMode.EMAIL_CODE
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Code',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ===== Email输入框 =====
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(25)),
                                borderSide: BorderSide(color: Colors.grey, width: 0.6),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(25)),
                                borderSide: BorderSide(color: Colors.grey, width: 0.6),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(25)),
                                borderSide: BorderSide(color: Colors.grey, width: 0.6),
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ===== 密码输入框或验证码输入 =====
                        if (_loginMode == LoginMode.EMAIL_PASSWORD) ...[
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: !_passwordVisible,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: const TextStyle(color: Colors.grey),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                                ),
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(25)),
                                  borderSide: BorderSide(color: Colors.grey, width: 0.6),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(25)),
                                  borderSide: BorderSide(color: Colors.grey, width: 0.6),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(25)),
                                  borderSide: BorderSide(color: Colors.grey, width: 0.6),
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                              ),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ] else ...[
                          // 发送验证码按钮
                          Container(
                            width: double.infinity,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextButton(
                              onPressed: _emailController.text.isNotEmpty && !_isSendingCode && _remainingTime == 0
                                  ? _sendVerificationCode
                                  : null,
                              child: _isSendingCode
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                  : Text(
                                      _remainingTime > 0
                                          ? '${_remainingTime}s'
                                          : 'Send Code',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // 验证码输入框
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: TextField(
                              controller: _verificationCodeController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              decoration: const InputDecoration(
                                labelText: '6-Digit Code',
                                labelStyle: TextStyle(color: Colors.grey),
                                hintText: 'Enter verification code',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(25)),
                                  borderSide: BorderSide(color: Colors.grey, width: 0.6),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(25)),
                                  borderSide: BorderSide(color: Colors.grey, width: 0.6),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(25)),
                                  borderSide: BorderSide(color: Colors.grey, width: 0.6),
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                                counterText: '',
                              ),
                              style: const TextStyle(color: Colors.black),
                              onChanged: (value) {
                                if (value.length <= 6 && RegExp(r'^\d*$').hasMatch(value)) {
                                  _verificationCodeController.value =
                                      _verificationCodeController.value.copyWith(text: value);
                                }
                              },
                            ),
                          ),
                        ],

                        const SizedBox(height: 10),

                        // ===== 登录按钮 =====
                        Container(
                          width: double.infinity,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ===== 调试按键 =====
                        Container(
                          width: double.infinity,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextButton(
                            onPressed: () => context.go('/home'),
                            child: const Text(
                              '🔧 Debug: Skip to Profile Setup',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // ===== 错误提示 =====
                        if (_showError) ...[
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // ===== 分割线 =====
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ===== 第三方登录按钮区域 =====
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildSpecialLoginButton(
                              'assets/images/login/1.png', 
                              'X Login',
                              onTap: () => _showComingSoon('X登录'),
                            ),
                            _buildSpecialLoginButton(
                              'assets/images/login/2.png', 
                              'Apple Login',
                              onTap: _handleAppleLogin,
                            ),
                            _buildSpecialLoginButton(
                              'assets/images/login/3.png', 
                              'Facebook Login',
                              onTap: () => _showComingSoon('Facebook登录'),
                            ),
                            _buildSpecialLoginButton(
                              'assets/images/login/4.png', 
                              'Google Login',
                              onTap: _handleGoogleLogin,
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // ===== 谷歌登录提示 =====
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue, size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '选择账号后，请在"正在核对信息"页面耐心等待3-5分钟，不要返回',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ===== 调试按钮（测试用） =====
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          child: ElevatedButton(
                            onPressed: () {
                              debugPrint('🔴 调试：直接跳转到主页');
                              context.go('/home');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              '🔴 调试：直接进入应用',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ===== 注册和忘记密码链接区域 =====
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () => context.go('/signup'),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.go('/reset_password'),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ===== 隐私政策和用户协议区域 =====
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () => context.go('/privacy_policy'),
                                child: const Text(
                                  'Privacy Policy',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.go('/user_agreement'),
                                child: const Text(
                                  'User Agreement',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== 品牌标识组件 =====
  Widget _buildBrandHeader() {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'PaaaW',
            style: TextStyle(
              color: Colors.black,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: 'O',
            style: TextStyle(
              color: Colors.red,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: 'W',
            style: TextStyle(
              color: Colors.black,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ===== 第三方登录按钮组件 =====
  Widget _buildSpecialLoginButton(String imagePath, String description, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          boxShadow: onTap != null ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Center(
          child: Image.asset(
            imagePath,
            width: 44,
            height: 44,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.login,
                size: 24,
                color: Colors.grey[600],
              );
            },
          ),
        ),
      ),
    );
  }
}