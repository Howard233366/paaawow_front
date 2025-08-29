import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pet_talk/theme/app_colors.dart';

/// PetTalk主题 - 严格按照旧项目Theme.kt实现
class AppTheme {
  /// 浅色主题 - 严格匹配旧项目PetTalkLightColorScheme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.petTalkPrimary,           // 主色调 #E6294A
      onPrimary: AppColors.petTalkOnPrimary,       // 主色调上的文字（白色）
      secondary: AppColors.petTalkSecondary,       // 次要色调 #F1EEF0
      onSecondary: AppColors.petTalkOnSecondary,   // 次要色调上的文字
      tertiary: AppColors.petTalkPrimaryDark,     // 第三色调
      onTertiary: AppColors.petTalkOnPrimary,     // 第三色调上的文字
      background: AppColors.petTalkBackground,     // 背景色 #F1EEF0
      onBackground: AppColors.petTalkOnSurface,   // 背景上的文字
      surface: AppColors.petTalkSurface,          // 表面色（白色）
      onSurface: AppColors.petTalkOnSurface,      // 表面上的文字
      surfaceVariant: AppColors.petTalkSecondary, // 表面变体色
      onSurfaceVariant: AppColors.petTalkOnSecondary, // 表面变体上的文字
      outline: AppColors.petTalkPrimary,          // 轮廓色
      outlineVariant: AppColors.petTalkPrimaryLight, // 轮廓变体色
      error: AppColors.petTalkError,              // 错误色
      onError: AppColors.petTalkOnError,          // 错误色上的文字
    ),
    fontFamily: 'PaaaWow', // 使用旧项目的自定义字体
    
    // AppBar主题 - 白底黑字样式
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white, // 白色背景
      foregroundColor: Colors.black, // 黑色文字和图标
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'PaaaWow',
      ),
      iconTheme: IconThemeData(color: Colors.black), // 图标颜色
      actionsIconTheme: IconThemeData(color: Colors.black), // 操作图标颜色
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.white, // 白色状态栏
        statusBarIconBrightness: Brightness.dark, // 深色图标
      ),
    ),
    
    // 底部导航栏主题
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.petTalkSurface,
      selectedItemColor: AppColors.petTalkPrimary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    // 卡片主题
    cardTheme: const CardThemeData(
      elevation: 4,
      color: AppColors.petTalkSurface,
    ),
    
    // 按钮主题
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.petTalkPrimary,
        foregroundColor: AppColors.petTalkOnPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    
    // 文本主题
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.petTalkOnSurface),
      displayMedium: TextStyle(color: AppColors.petTalkOnSurface),
      displaySmall: TextStyle(color: AppColors.petTalkOnSurface),
      headlineLarge: TextStyle(color: AppColors.petTalkOnSurface),
      headlineMedium: TextStyle(color: AppColors.petTalkOnSurface),
      headlineSmall: TextStyle(color: AppColors.petTalkOnSurface),
      titleLarge: TextStyle(color: AppColors.petTalkOnSurface),
      titleMedium: TextStyle(color: AppColors.petTalkOnSurface),
      titleSmall: TextStyle(color: AppColors.petTalkOnSurface),
      bodyLarge: TextStyle(color: AppColors.petTalkOnSurface),
      bodyMedium: TextStyle(color: AppColors.petTalkOnSurface),
      bodySmall: TextStyle(color: AppColors.petTalkOnSurface),
      labelLarge: TextStyle(color: AppColors.petTalkOnSurface),
      labelMedium: TextStyle(color: AppColors.petTalkOnSurface),
      labelSmall: TextStyle(color: AppColors.petTalkOnSurface),
    ),
  );

  /// 深色主题 - 严格匹配旧项目PetTalkDarkColorScheme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.petTalkPrimary,           // 主色调保持不变
      onPrimary: AppColors.petTalkOnPrimary,       // 主色调上的文字（白色）
      secondary: AppColors.petTalkPrimaryDark,     // 次要色调使用深色主色调
      onSecondary: AppColors.petTalkOnPrimary,     // 次要色调上的文字
      tertiary: AppColors.petTalkPrimaryLight,    // 第三色调使用浅色主色调
      onTertiary: AppColors.petTalkOnPrimary,     // 第三色调上的文字
      background: Color(0xFF121212),               // 深色背景
      onBackground: Color(0xFFFFFFFF),            // 深色背景上的文字
      surface: Color(0xFF1E1E1E),                 // 深色表面
      onSurface: Color(0xFFFFFFFF),               // 深色表面上的文字
      surfaceVariant: Color(0xFF2A2A2A),          // 深色表面变体
      onSurfaceVariant: Color(0xFFE0E0E0),        // 深色表面变体上的文字
      outline: AppColors.petTalkPrimary,          // 轮廓色保持主色调
      outlineVariant: AppColors.petTalkPrimaryLight, // 轮廓变体色
      error: AppColors.petTalkError,              // 错误色保持主色调
      onError: AppColors.petTalkOnError,          // 错误色上的文字
    ),
    fontFamily: 'PaaaWow', // 使用旧项目的自定义字体
    
    // AppBar主题 - 白底黑字样式
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white, // 白色背景
      foregroundColor: Colors.black, // 黑色文字和图标
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'PaaaWow',
      ),
      iconTheme: IconThemeData(color: Colors.black), // 图标颜色
      actionsIconTheme: IconThemeData(color: Colors.black), // 操作图标颜色
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.white, // 白色状态栏
        statusBarIconBrightness: Brightness.dark, // 深色图标
      ),
    ),
    
    // 底部导航栏主题
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: AppColors.petTalkPrimary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    // 卡片主题
    cardTheme: const CardThemeData(
      elevation: 4,
      color: Color(0xFF1E1E1E),
    ),
    
    // 按钮主题
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.petTalkPrimary,
        foregroundColor: AppColors.petTalkOnPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    
    // 文本主题
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Color(0xFFFFFFFF)),
      displayMedium: TextStyle(color: Color(0xFFFFFFFF)),
      displaySmall: TextStyle(color: Color(0xFFFFFFFF)),
      headlineLarge: TextStyle(color: Color(0xFFFFFFFF)),
      headlineMedium: TextStyle(color: Color(0xFFFFFFFF)),
      headlineSmall: TextStyle(color: Color(0xFFFFFFFF)),
      titleLarge: TextStyle(color: Color(0xFFFFFFFF)),
      titleMedium: TextStyle(color: Color(0xFFFFFFFF)),
      titleSmall: TextStyle(color: Color(0xFFFFFFFF)),
      bodyLarge: TextStyle(color: Color(0xFFFFFFFF)),
      bodyMedium: TextStyle(color: Color(0xFFFFFFFF)),
      bodySmall: TextStyle(color: Color(0xFFFFFFFF)),
      labelLarge: TextStyle(color: Color(0xFFFFFFFF)),
      labelMedium: TextStyle(color: Color(0xFFFFFFFF)),
      labelSmall: TextStyle(color: Color(0xFFFFFFFF)),
    ),
  );
}