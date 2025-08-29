/**
 * 这是Flutter应用的主入口文件(main.dart)
 * 负责应用的初始化和启动配置
 * 1. 初始化Flutter框架绑定
 * 2. 配置Firebase云服务（用户认证、数据存储）
 * 3. 初始化地图服务（宠物定位、安全区域）
 * 4. 设置用户偏好和网络管理
 * 5. 启动应用程序主界面
 * 技术栈：
 * - Flutter: 跨平台移动应用开发框架
 * - Riverpod: 状态管理解决方案
 * - Firebase: 谷歌云服务平台
 * - Material Design: Google设计语言
 */

// Flutter核心包，提供Material Design组件和基础功能
import 'package:flutter/material.dart';
// Riverpod状态管理包，用于管理应用状态
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Firebase核心包，用于云服务集成（如认证、数据库等）
import 'package:firebase_core/firebase_core.dart';

// 应用主题配置，定义颜色、字体等UI样式
import 'package:pet_talk/theme/app_theme.dart';
// 应用路由配置，管理页面间的导航
import 'package:pet_talk/navigation/app_navigation.dart';
// 地图服务初始化工具，用于百度地图等地图功能
import 'package:pet_talk/utils/map_initializer.dart';
// 网络管理服务，处理API请求和网络连接
import 'package:pet_talk/services/network/network_manager.dart';
// 用户偏好设置服务，存储用户配置信息
import 'package:pet_talk/services/user/user_preferences.dart';

void main() async {
  // 初始化Flutter绑定
  // 确保Flutter框架完全初始化后再执行后续代码
  // 这是在runApp()之前进行异步操作的必要步骤
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化Firebase云服务
  // Firebase是谷歌提供的移动应用开发平台，提供认证、数据库、分析等服务
  // 使用try-catch确保即使Firebase初始化失败，应用也能正常启动
  try {
    // 异步初始化Firebase，等待完成后继续
    await Firebase.initializeApp();
    // 在调试控制台打印成功信息
    debugPrint('✅ Firebase初始化成功');
  } catch (e) {
    // 如果初始化失败，打印错误信息但不终止应用
    debugPrint('❌ Firebase初始化失败，应用将继续运行但部分功能可能受限: $e');
    // 说明：Firebase功能包括用户认证、云数据库等，失败后这些功能将不可用
  }
  
  // 初始化地图服务
  // 地图服务用于显示宠物位置、设置安全区域等功能
  debugPrint('📱 ========== 开始初始化地图服务 ==========');
  
  try {
    // 异步初始化地图服务
    // MapInitializer会设置API密钥、权限等
    await MapInitializer.initialize();
    debugPrint('📱 [SUCCESS] ✅ 地图服务初始化成功');
  } catch (e, stackTrace) {
    // 地图初始化失败时打印错误信息
    // stackTrace包含详细的错误堆栈，帮助调试
    debugPrint('📱 [ERROR] ❌ 地图服务初始化失败: $e');
    debugPrint('📱 [STACK] 错误堆栈: $stackTrace');
  }
  debugPrint('📱 ========== 地图服务初始化结束 ==========');
  
  // 初始化用户偏好设置和网络服务
  try {
    // 初始化用户偏好设置服务
    // UserPreferences用于存储用户的个人设置，如语言、主题等
    // instance表示使用单例模式，确保全局只有一个实例
    await UserPreferences.instance.init();
    
    // 初始化网络管理器
    // NetworkManager负责处理所有的API请求、网络状态监听等
    await NetworkManager.initialize();
    
    debugPrint('✅ 网络服务初始化成功');
  } catch (e) {
    // 网络服务初始化失败，但不影响应用启动
    debugPrint('❌ 网络服务初始化失败，API功能可能受限: $e');
  }
  
  // 启动Flutter应用
  // runApp是Flutter的核心函数，用于启动应用程序
  runApp(
    // ProviderScope是Riverpod状态管理的根组件
    // 它为整个应用提供状态管理功能，类似于React的Context Provider
    const ProviderScope(
      // PetTalkApp是我们自定义的根应用组件
      child: PetTalkApp(),
    ),
  );
}

/**
 * PetTalkApp - 应用程序的根组件
 * 
 * StatelessWidget: 无状态组件，表示这个组件不会改变
 * 它只负责配置应用的基本设置，如主题、路由等
 */
class PetTalkApp extends StatelessWidget {
  // 构造函数，super.key是Flutter 3.0+的新语法，用于组件优化，用key来识别和区分不同的Widget
  // 旧版本写法（Flutter 3.0之前）： const PetTalkApp({Key? key}) : super(key: key);
  const PetTalkApp({super.key});

  /**
   * build方法 - 构建UI界面
   * 每个Widget都必须实现这个方法来定义如何显示
   * @param context 构建上下文，包含应用的环境信息
   * @return Widget 返回要显示的组件
   */
  @override
  Widget build(BuildContext context) {
    // MaterialApp.router - 使用路由的Material Design应用
    // Material Design是Google的设计语言，提供统一的UI风格
    return MaterialApp.router(
      // 应用基本信息
      // 应用标题，在任务管理器中显示
      title: 'PetTalk - Smart Pet Translator',
      
      // 主题配置
      // 浅色主题 - 定义应用在白天模式下的外观
      theme: AppTheme.lightTheme,
      // 深色主题 - 定义应用在夜间模式下的外观
      darkTheme: AppTheme.darkTheme,
      // 主题模式 - 跟随系统设置自动切换浅色/深色主题
      themeMode: ThemeMode.system,
      
      // 路由配置
      // AppNavigation.router包含了所有页面的路径和跳转逻辑
      routerConfig: AppNavigation.router,
      
      // 调试设置
      // 隐藏右上角的"DEBUG"横幅（仅在调试模式显示）
      debugShowCheckedModeBanner: false,
    );
  }
}