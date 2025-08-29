// 地图初始化工具类 - 统一处理百度地图SDK和Google Maps的初始化

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_bmflocation/flutter_bmflocation.dart';
import 'package:pet_talk/utils/network_checker.dart';

/// 地图初始化器
/// 负责在应用启动时初始化相应的地图SDK
class MapInitializer {
  static bool _isInitialized = false;
  
  /// 初始化地图SDK
  /// 根据平台选择合适的地图服务进行初始化
  static Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      // 进行服务状态检查（使用正确的API）
      debugPrint('🗺️ 执行服务状态检查...');
      final networkResults = await NetworkChecker.performFullNetworkCheck();
      
      if (!networkResults['internetConnection']) {
        debugPrint('🗺️ ⚠️ 网络连接异常，地图功能可能受限');
      }
      
      if (!networkResults['apiKeyValid']) {
        debugPrint('🗺️ ⚠️ API Key验证失败，地图功能可能受限');
      }
      
      if (kIsWeb) {
        debugPrint('🗺️ Web平台 - 使用Google Maps，无需初始化');
      } else if (Platform.isIOS) {
        debugPrint('🗺️ iOS平台 - 使用Google Maps，无需初始化');
      } else if (Platform.isAndroid) {
        debugPrint('🗺️ Android平台 - 初始化百度地图SDK');
        await _initializeBaiduMapSDK();
      } else {
        debugPrint('🗺️ 其他平台: ${Platform.operatingSystem} - 使用Google Maps，无需初始化');
      }
      
      _isInitialized = true;
      debugPrint('🗺️ ✅ 地图服务初始化完成');
    } catch (e, stackTrace) {
      debugPrint('🗺️ ❌ 地图服务初始化失败: $e');
      debugPrint('🗺️ 错误堆栈: $stackTrace');
      // 即使初始化失败也标记为已初始化，避免重复尝试
      _isInitialized = true;
    }
    debugPrint('🗺️ ========== 地图服务初始化结束 ==========');
  }

  /// 初始化百度地图SDK
  /// 严格按照官方文档要求的顺序进行初始化
  static Future<void> _initializeBaiduMapSDK() async {
    try {
      debugPrint('🗺️ ========== 开始百度地图SDK初始化流程 ==========');
      debugPrint('🗺️ Flutter版本: ${WidgetsBinding.instance.runtimeType}');
      debugPrint('🗺️ 当前平台: ${Platform.operatingSystem}');
      
      // 第一步：必须首先调用隐私合规接口（官方文档强制要求）
      // 这是v7.5.0+版本的强制要求，必须在任何其他SDK接口调用前执行
      BMFMapSDK.setAgreePrivacy(true);
      
      // 第二步：等待Flutter插件完成内部初始化
      await Future.delayed(const Duration(milliseconds: 100));
      
      // 第三步：设置API Key和坐标系类型
      const String baiduApiKey = 'vK6hTnQzAxoZtak72lsgPu6CqNhvtKtc';
      
      BMFMapSDK.setApiKeyAndCoordType(baiduApiKey, BMF_COORD_TYPE.BD09LL);
      
      // 第四步：初始化定位服务的隐私政策
      try {
        LocationFlutterPlugin().setAgreePrivacy(true);
      } catch (locationError) {
        debugPrint('🗺️ ⚠️ 百度定位服务初始化失败: $locationError');
      }
      
      // 第五步：等待初始化完成（给SDK一点时间完成内部初始化）
      await Future.delayed(const Duration(milliseconds: 500));
      
      debugPrint('🗺️ ========== 百度地图SDK初始化流程结束 ==========');
      
    } catch (e, stackTrace) {
      debugPrint('🗺️ ❌ 百度地图SDK初始化失败: $e');
      debugPrint('🗺️ 错误堆栈: $stackTrace');
      rethrow;
    }
  }

  /// 检查是否已初始化
  static bool get isInitialized => _isInitialized;

  /// 重置初始化状态（主要用于测试）
  static void reset() {
    _isInitialized = false;
    debugPrint('🗺️ 地图初始化状态已重置');
  }
}
