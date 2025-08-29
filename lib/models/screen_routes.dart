// 🔵 PetTalk 路由定义 - 完全匹配旧Android项目的Screen.kt
// 严格按照旧项目Screen.kt逐行复刻所有路由定义

/// 路由常量类 - 匹配旧项目的sealed class Screen(val route: String)
class AppRoutes {
  // ==================== 认证相关 ====================
  // 一级页面：登录
  static const String login = "/login";
  
  // 二级页面：注册  
  static const String signUp = "/signup";
  
  // 二级页面：重置密码
  static const String resetPassword = "/reset_password";
  
  // 二级页面：隐私政策
  static const String privacyPolicy = "/privacy_policy";
  
  // 二级页面：用户协议
  static const String userAgreement = "/user_agreement";
  
  // 首次登录信息补充
  static const String profileSetup = "/profile_setup";
  
  // 宠物信息填写
  static const String petSetup = "/pet_setup";
  
  // 宠物信息填写完成
  static const String petSetupComplete = "/pet_setup_complete";
  
  // 项圈配网
  static const String collarSetup = "/collar_setup";
  
  // 蓝牙搜索
  static const String bluetoothScan = "/bluetooth_scan";
  
  // WiFi配网
  static const String wifiSetup = "/wifi_setup";

  // ==================== 主要功能页面 ====================
  // 首页/宠物页面
  static const String home = "/home";
  
  // 社区
  static const String community = "/community";
  
  // 商城
  static const String shop = "/shop";
  
  // 我的
  static const String profile = "/profile";

  // ==================== 翻译相关 ====================
  static const String translation = "/translation";

  // ==================== AI功能 ====================
  // AI功能选择页面
  static const String aiFunctionSelect = "/ai_function_select";
  
  // AI聊天页面 - 带参数路由
  static const String aiChat = "/ai_chat/:function";
  
  // 即将推出页面 - 带参数路由
  static const String comingSoon = "/coming_soon/:feature";

  // ==================== 宠物相关 ====================
  // 宠物详情页面 - 带参数路由
  static const String petDetail = "/pet_detail/:petId";

  // ==================== 项圈相关 ====================
  // 项圈详情页面 - 带参数路由
  static const String collarDetail = "/collar_detail/:collarId";
  
  // 真实项圈状态页面 - 带参数路由
  static const String realCollarStatus = "/real_collar_status/:collarId";
  
  // 宝石详情页面 - 带参数路由
  static const String gemDetail = "/gem_detail/:gemType";
  
  // WiFi管理页面
  static const String wifiManagement = "/wifi_management";

  // ==================== 社区相关 ====================
  // 帖子详情页面 - 带参数路由
  static const String postDetail = "/post_detail/:postId";
  
  // 创建帖子页面
  static const String createPost = "/create_post";

  // ==================== 健康信息相关 ====================
  // 宠物基础信息
  static const String healthInformation = "/health_information";
  
  // 编辑宠物基础信息
  static const String healthInformationEdit = "/health_information_edit";
  
  // 宠物健康数据
  static const String healthData = "/health_data";
  
  // 宠物健康日历
  static const String healthCalendar = "/health_calendar";

  // ==================== Profile相关页面 ====================
  // 编辑资料
  static const String profileEdit = "/profile_edit";
  
  // 系统消息
  static const String systemAlert = "/system_alert";
  
  // 添加宠物
  static const String addingPets = "/adding_pets";
  
  // 反馈
  static const String feedback = "/feedback";
  
  // 关于我们
  static const String aboutUs = "/about_us";
  
  // 急救功能介绍
  static const String firstAid = "/first_aid";

  // ==================== 设置相关 ====================
  // 设置页面
  static const String settings = "/settings";
  
  // 宠物选择页面
  static const String petSelection = "/pet_selection";

  // ==================== 路由创建工具方法 - 匹配旧项目fun createRoute ====================
  /// 创建AI聊天路由 - 匹配旧项目AIChatScreen.createRoute
  static String createAIChatRoute(String function) => "/ai_chat/$function";
  
  /// 创建即将推出路由 - 匹配旧项目ComingSoonScreen.createRoute
  static String createComingSoonRoute(String feature) => "/coming_soon/$feature";
  
  /// 创建宠物详情路由 - 匹配旧项目PetDetailScreen.createRoute
  static String createPetDetailRoute(String petId) => "/pet_detail/$petId";
  
  /// 创建项圈详情路由 - 匹配旧项目CollarDetailScreen.createRoute
  static String createCollarDetailRoute(String collarId) => "/collar_detail/$collarId";
  
  /// 创建真实项圈状态路由 - 匹配旧项目RealCollarStatusScreen.createRoute
  static String createRealCollarStatusRoute(String collarId) => "/real_collar_status/$collarId";
  
  /// 创建宝石详情路由 - 匹配旧项目GemDetailScreen.createRoute
  static String createGemDetailRoute(String gemType) => "/gem_detail/$gemType";
  
  /// 创建帖子详情路由 - 匹配旧项目PostDetailScreen.createRoute
  static String createPostDetailRoute(String postId) => "/post_detail/$postId";
}