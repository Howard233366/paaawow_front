import 'package:flutter/material.dart';

class AppColors {
  // PetTalk Color Palette - 严格匹配旧Android项目Color.kt
  static const Color petTalkPrimary = Color(0xFFE6294A);      // 主色调 #E6294A
  static const Color petTalkPrimaryLight = Color(0xFFEB4C69); // 浅一点的主色调
  static const Color petTalkPrimaryDark = Color(0xFFD11D3A);  // 深一点的主色调
  static const Color petTalkBackground = Color(0xFFF1EEF0);   // 背景色 #F1EEF0
  static const Color petTalkSurface = Color(0xFFFFFFFF);      // 表面色（白色）
  static const Color petTalkOnSurface = Color(0xFF000000);    // 文字色 #000000
  static const Color petTalkOnPrimary = Color(0xFFFFFFFF);    // 主色调上的文字（白色）
  static const Color petTalkSecondary = Color(0xFFF1EEF0);    // 次要色调
  static const Color petTalkOnSecondary = Color(0xFF000000);  // 次要色调上的文字
  static const Color petTalkError = Color(0xFFE6294A);        // 错误色使用主色调
  static const Color petTalkOnError = Color(0xFFFFFFFF);      // 错误色上的文字
  
  // 兼容性颜色定义 - 保持向后兼容
  static const Color primary = petTalkPrimary;                // 主色调兼容
  static const Color primaryLight = petTalkPrimaryLight;      // 浅色兼容
  static const Color primaryDark = petTalkPrimaryDark;        // 深色兼容
  static const Color secondary = petTalkSecondary;            // 次要色调兼容
  static const Color background = petTalkBackground;          // 背景色兼容
  static const Color surface = petTalkSurface;               // 表面色兼容
  static const Color textPrimary = petTalkOnSurface;         // 文字色兼容
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color onPrimary = petTalkOnPrimary;           // 主色调上的文字兼容
  static const Color onSecondary = petTalkOnSecondary;       // 次要色调上的文字兼容
  static const Color error = petTalkError;                   // 错误色兼容
  static const Color onError = petTalkOnError;               // 错误色上的文字兼容
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Legacy compatibility colors
  static const Color cardBlue = Color(0xFF479276);
  static const Color cardPurple = Color(0xFF610DE9);
  static const Color loginGreen = Color(0xFF0D8C47);
  static const Color loginTeal = Color(0xFF407873);
  static const Color loginBlue = Color(0xFF4AA0FC);
  static const Color loginMint = Color(0xFF5CDEB1);
  static const Color loginYellow = Color(0xFFEFF64F);
  static const Color iconGreen = Color(0xFF49F33D);
  static const Color iconYellow = Color(0xFFCCAE1E);
  static const Color iconOrange = Color(0xFFFEE798);
  static const Color divider = Color(0xFFE0E0E0);
  
  // Alias for compatibility
  static const Color tertiary = Color(0xFF407873);
}