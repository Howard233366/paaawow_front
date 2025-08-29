// 🔵 PetTalk 用户偏好设置 - 完全匹配旧Android项目的UserPreferences.kt
// 严格按照旧项目UserPreferences.kt逐行复刻数据存储逻辑

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pet_talk/models/user_models.dart';

/// 用户偏好设置管理器 - 完全匹配旧项目UserPreferences
class UserPreferences {
  static UserPreferences? _instance;
  static UserPreferences get instance => _instance ??= UserPreferences._();
  
  UserPreferences._();

  late SharedPreferences _prefs;
  bool _initialized = false;

  /// 初始化 - 匹配旧项目初始化逻辑
  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // ==================== 认证相关存储 - 匹配旧项目 ====================

  /// 认证Token存储键 - 匹配旧项目AUTH_TOKEN
  static const String _keyAuthToken = 'auth_token';
  
  /// 用户ID存储键 - 匹配旧项目USER_ID
  static const String _keyUserId = 'user_id';
  
  /// 用户邮箱存储键 - 匹配旧项目USER_EMAIL
  static const String _keyUserEmail = 'user_email';
  
  /// 用户名存储键 - 匹配旧项目USER_NAME
  static const String _keyUserName = 'user_name';
  
  /// 用户资料存储键 - 匹配旧项目USER_PROFILE
  static const String _keyUserProfile = 'user_profile';

  /// 保存认证Token - 匹配旧项目saveAuthToken
  Future<void> saveAuthToken(String token) async {
    await _ensureInitialized();
    await _prefs.setString(_keyAuthToken, token);
  }

  /// 获取认证Token - 匹配旧项目getAuthToken
  Future<String?> getAuthToken() async {
    await _ensureInitialized();
    return _prefs.getString(_keyAuthToken);
  }

  /// 清除认证Token - 匹配旧项目clearAuthToken
  Future<void> clearAuthToken() async {
    await _ensureInitialized();
    await _prefs.remove(_keyAuthToken);
  }

  /// 保存用户信息 - 匹配旧项目saveUser
  Future<void> saveUser(String userId, String email, String username) async {
    await _ensureInitialized();
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserName, username);
  }

  /// 获取用户ID - 匹配旧项目getUserId
  Future<String?> getUserId() async {
    await _ensureInitialized();
    return _prefs.getString(_keyUserId);
  }

  /// 获取用户邮箱 - 匹配旧项目getUserEmail
  Future<String?> getUserEmail() async {
    await _ensureInitialized();
    return _prefs.getString(_keyUserEmail);
  }

  /// 获取用户名 - 匹配旧项目getUserName
  Future<String?> getUserName() async {
    await _ensureInitialized();
    return _prefs.getString(_keyUserName);
  }

  /// 保存用户资料 - 匹配旧项目saveUserProfile
  Future<void> saveUserProfile(UserProfile profile) async {
    await _ensureInitialized();
    final profileJson = jsonEncode(profile.toJson());
    await _prefs.setString(_keyUserProfile, profileJson);
  }

  /// 获取用户资料 - 匹配旧项目getUserProfile
  Future<UserProfile?> getUserProfile() async {
    await _ensureInitialized();
    final profileJson = _prefs.getString(_keyUserProfile);
    if (profileJson != null) {
      try {
        final json = jsonDecode(profileJson) as Map<String, dynamic>;
        return UserProfile.fromJson(json);
      } catch (e) {
        // 如果解析失败，返回null
        return null;
      }
    }
    return null;
  }

  /// 清除用户信息 - 匹配旧项目clearUser
  Future<void> clearUser() async {
    await _ensureInitialized();
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyUserProfile);
  }

  /// 检查是否已登录 - 匹配旧项目isLoggedIn
  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== 应用设置存储 - 匹配旧项目 ====================

  /// 主题模式存储键
  static const String _keyThemeMode = 'theme_mode';
  
  /// 语言设置存储键
  static const String _keyLanguage = 'language';
  
  /// 通知设置存储键
  static const String _keyNotificationsEnabled = 'notifications_enabled';

  /// 保存主题模式 - 匹配旧项目setThemeMode
  Future<void> setThemeMode(String themeMode) async {
    await _ensureInitialized();
    await _prefs.setString(_keyThemeMode, themeMode);
  }

  /// 获取主题模式 - 匹配旧项目getThemeMode
  Future<String> getThemeMode() async {
    await _ensureInitialized();
    return _prefs.getString(_keyThemeMode) ?? 'system';
  }

  /// 保存语言设置 - 匹配旧项目setLanguage
  Future<void> setLanguage(String language) async {
    await _ensureInitialized();
    await _prefs.setString(_keyLanguage, language);
  }

  /// 获取语言设置 - 匹配旧项目getLanguage
  Future<String> getLanguage() async {
    await _ensureInitialized();
    return _prefs.getString(_keyLanguage) ?? 'zh_CN';
  }

  /// 设置通知开关 - 匹配旧项目setNotificationsEnabled
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _ensureInitialized();
    await _prefs.setBool(_keyNotificationsEnabled, enabled);
  }

  /// 获取通知开关 - 匹配旧项目getNotificationsEnabled
  Future<bool> getNotificationsEnabled() async {
    await _ensureInitialized();
    return _prefs.getBool(_keyNotificationsEnabled) ?? true;
  }

  // ==================== 蓝牙设备存储 - 匹配旧项目 ====================

  /// 最后连接的蓝牙设备ID
  static const String _keyLastBluetoothDevice = 'last_bluetooth_device';
  
  /// 蓝牙自动连接开关
  static const String _keyBluetoothAutoConnect = 'bluetooth_auto_connect';

  /// 保存最后连接的蓝牙设备 - 匹配旧项目setLastBluetoothDevice
  Future<void> setLastBluetoothDevice(String deviceId) async {
    await _ensureInitialized();
    await _prefs.setString(_keyLastBluetoothDevice, deviceId);
  }

  /// 获取最后连接的蓝牙设备 - 匹配旧项目getLastBluetoothDevice
  Future<String?> getLastBluetoothDevice() async {
    await _ensureInitialized();
    return _prefs.getString(_keyLastBluetoothDevice);
  }

  /// 设置蓝牙自动连接 - 匹配旧项目setBluetoothAutoConnect
  Future<void> setBluetoothAutoConnect(bool enabled) async {
    await _ensureInitialized();
    await _prefs.setBool(_keyBluetoothAutoConnect, enabled);
  }

  /// 获取蓝牙自动连接 - 匹配旧项目getBluetoothAutoConnect
  Future<bool> getBluetoothAutoConnect() async {
    await _ensureInitialized();
    return _prefs.getBool(_keyBluetoothAutoConnect) ?? true;
  }

  // ==================== 宠物信息存储 - 匹配旧项目 ====================

  /// 当前宠物ID
  static const String _keyCurrentPetId = 'current_pet_id';
  
  // /// 宠物列表 - 预留功能
  // static const String _keyPetList = 'pet_list';

  /// 设置当前宠物ID - 匹配旧项目setCurrentPetId
  Future<void> setCurrentPetId(String petId) async {
    await _ensureInitialized();
    await _prefs.setString(_keyCurrentPetId, petId);
  }

  /// 获取当前宠物ID - 匹配旧项目getCurrentPetId
  Future<String?> getCurrentPetId() async {
    await _ensureInitialized();
    return _prefs.getString(_keyCurrentPetId);
  }

  // ==================== 应用状态存储 - 匹配旧项目 ====================

  /// 首次启动标记
  static const String _keyFirstLaunch = 'first_launch';
  
  /// 最后同步时间
  static const String _keyLastSyncTime = 'last_sync_time';

  /// 设置首次启动标记 - 匹配旧项目setFirstLaunch
  Future<void> setFirstLaunch(bool isFirst) async {
    await _ensureInitialized();
    await _prefs.setBool(_keyFirstLaunch, isFirst);
  }

  /// 获取首次启动标记 - 匹配旧项目isFirstLaunch
  Future<bool> isFirstLaunch() async {
    await _ensureInitialized();
    return _prefs.getBool(_keyFirstLaunch) ?? true;
  }

  /// 设置最后同步时间 - 匹配旧项目setLastSyncTime
  Future<void> setLastSyncTime(int timestamp) async {
    await _ensureInitialized();
    await _prefs.setInt(_keyLastSyncTime, timestamp);
  }

  /// 获取最后同步时间 - 匹配旧项目getLastSyncTime
  Future<int> getLastSyncTime() async {
    await _ensureInitialized();
    return _prefs.getInt(_keyLastSyncTime) ?? 0;
  }

  // ==================== 工具方法 - 匹配旧项目 ====================

  /// 确保已初始化
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
  }

  /// 清除所有数据 - 匹配旧项目clearAll
  Future<void> clearAll() async {
    await _ensureInitialized();
    await _prefs.clear();
  }

  /// 导出所有设置（用于备份） - 新增功能
  Future<Map<String, dynamic>> exportSettings() async {
    await _ensureInitialized();
    final keys = _prefs.getKeys();
    final settings = <String, dynamic>{};
    
    for (final key in keys) {
      final value = _prefs.get(key);
      if (value != null) {
        settings[key] = value;
      }
    }
    
    return settings;
  }

  /// 导入设置（用于恢复） - 新增功能
  Future<void> importSettings(Map<String, dynamic> settings) async {
    await _ensureInitialized();
    
    for (final entry in settings.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (value is String) {
        await _prefs.setString(key, value);
      } else if (value is int) {
        await _prefs.setInt(key, value);
      } else if (value is double) {
        await _prefs.setDouble(key, value);
      } else if (value is bool) {
        await _prefs.setBool(key, value);
      } else if (value is List<String>) {
        await _prefs.setStringList(key, value);
      }
    }
  }

  /// 刷新Token存储键 - 新增
  static const String _keyRefreshToken = 'refresh_token';

  /// 保存刷新Token - 新增方法
  Future<void> saveRefreshToken(String token) async {
    await _ensureInitialized();
    await _prefs.setString(_keyRefreshToken, token);
  }

  /// 获取刷新Token - 新增方法
  Future<String?> getRefreshToken() async {
    await _ensureInitialized();
    return _prefs.getString(_keyRefreshToken);
  }

  /// 保存用户ID - 新增方法
  Future<void> saveUserId(String userId) async {
    await _ensureInitialized();
    await _prefs.setString(_keyUserId, userId);
  }

  /// 保存用户邮箱 - 新增方法
  Future<void> saveUserEmail(String email) async {
    await _ensureInitialized();
    await _prefs.setString(_keyUserEmail, email);
  }

  /// 清除所有用户数据 - 新增方法
  Future<void> clearUserData() async {
    await _ensureInitialized();
    await _prefs.remove(_keyAuthToken);
    await _prefs.remove(_keyRefreshToken);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyUserProfile);
  }
}