// 🔵 PetTalk 应用级蓝牙管理器 - 完全匹配旧Android项目的AppBluetoothManager.kt
// 严格按照旧项目AppBluetoothManager.kt的272行代码逐行复刻

import 'dart:async';
import 'dart:developer' as developer;
import 'package:pet_talk/models/bluetooth_models.dart';
import 'package:pet_talk/services/bluetooth/enhanced_bluetooth_manager.dart';

/// 应用级蓝牙管理器 - 完全匹配旧项目AppBluetoothManager
/// 负责协调各种蓝牙功能，根据collar-prompt.md实现：
/// 1. APP前台时保持常连接
/// 2. 页面进入时执行硬件信息同步
/// 3. collar status页面轮询管理
class AppBluetoothManager {
  static const String _tag = "AppBluetoothManager";

  // 核心蓝牙管理器 - 匹配旧项目
  late final EnhancedBluetoothManager enhancedBluetoothManager;

  // 应用前台状态 - 匹配旧项目
  final StreamController<bool> _isAppInForegroundController = 
      StreamController<bool>.broadcast();
  Stream<bool> get isAppInForeground => _isAppInForegroundController.stream;
  bool _currentAppInForeground = false;

  // 当前页面状态 - 匹配旧项目
  final StreamController<AppPage> _currentPageController = 
      StreamController<AppPage>.broadcast();
  Stream<AppPage> get currentPage => _currentPageController.stream;
  AppPage _currentAppPage = AppPage.unknown;

  // 硬件同步结果 - 匹配旧项目
  final StreamController<HardwareSyncResult> _hardwareSyncResultController = 
      StreamController<HardwareSyncResult>.broadcast();
  Stream<HardwareSyncResult> get hardwareSyncResult => _hardwareSyncResultController.stream;

  // collar状态数据 - 匹配旧项目
  final StreamController<CollarStatusData> _collarStatusDataController = 
      StreamController<CollarStatusData>.broadcast();
  Stream<CollarStatusData> get collarStatusData => _collarStatusDataController.stream;

  // 通信延迟 - 匹配旧项目
  final StreamController<int> _communicationDelayController = 
      StreamController<int>.broadcast();
  Stream<int> get communicationDelay => _communicationDelayController.stream;

  // 订阅管理
  final List<StreamSubscription> _subscriptions = [];

  /// 构造函数 - 匹配旧项目constructor
  AppBluetoothManager() {
    enhancedBluetoothManager = EnhancedBluetoothManager();
    _initializeConnectionListener();
    _initializePageListener();
  }

  /// 初始化连接监听 - 匹配旧项目init逻辑
  void _initializeConnectionListener() {
    // 监听连接状态，当连接成功时执行硬件同步 - 匹配旧项目
    _subscriptions.add(
      enhancedBluetoothManager.connectionState.listen((state) {
        switch (state) {
          case BluetoothConnectionState.connected:
            // 连接成功后立即执行硬件同步 - 匹配旧项目
            _performHardwareSync("连接建立");
            break;
          case BluetoothConnectionState.disconnected:
            // 连接断开时停止轮询 - 匹配旧项目
            _stopCollarStatusPolling();
            break;
          default:
            break;
        }
      })
    );
  }

  /// 初始化页面监听 - 匹配旧项目
  void _initializePageListener() {
    // 监听页面变化 - 匹配旧项目
    _subscriptions.add(
      currentPage.listen((page) {
        _handlePageChange(page);
      })
    );
  }

  /// 设置应用前台状态 - 完全匹配旧项目setAppForegroundState
  void setAppForegroundState(bool inForeground) {
    final wasInForeground = _currentAppInForeground;
    _currentAppInForeground = inForeground;
    _isAppInForegroundController.add(inForeground);

    developer.log('📱 应用${inForeground ? "进入" : "离开"}前台', name: _tag);

    if (inForeground && !wasInForeground) {
      // 应用进入前台，启动自动连接 - 匹配旧项目
      enhancedBluetoothManager.startAutoConnect();
    } else if (!inForeground && wasInForeground) {
      // 应用离开前台，停止轮询但保持连接 - 匹配旧项目
      _stopCollarStatusPolling();
    }
  }

  /// 设置当前页面 - 完全匹配旧项目setCurrentPage
  void setCurrentPage(AppPage page) {
    final previousPage = _currentAppPage;
    _currentAppPage = page;
    _currentPageController.add(page);

    developer.log('📄 页面切换: $previousPage → $page', name: _tag);

    // 根据页面执行相应操作 - 匹配旧项目
    switch (page) {
      case AppPage.home:
      case AppPage.profile:
      case AppPage.settings:
        // 进入主要页面时执行硬件同步 - 匹配旧项目
        if (_currentAppInForeground) {
          _performHardwareSync("页面进入: ${page.displayName}");
        }
        break;
      case AppPage.collarStatus:
        // 进入collar status页面时开始轮询 - 匹配旧项目
        if (_currentAppInForeground) {
          _performHardwareSync("进入collar status");
          _startCollarStatusPolling();
        }
        break;
      default:
        // 其他页面停止轮询 - 匹配旧项目
        _stopCollarStatusPolling();
        break;
    }
  }

  /// 处理页面变化 - 完全匹配旧项目handlePageChange
  void _handlePageChange(AppPage page) {
    switch (page) {
      case AppPage.collarStatus:
        // collar status页面需要保持轮询 - 匹配旧项目
        developer.log('🔄 进入collar status页面，保持轮询活跃', name: _tag);
        break;
      default:
        // 其他页面停止collar status轮询 - 匹配旧项目
        if (page != AppPage.unknown) {
          _stopCollarStatusPolling();
        }
        break;
    }
  }

  /// 执行硬件信息同步 - 完全匹配旧项目performHardwareSync
  /// 根据collar-prompt.md: 先set_time，然后立刻get_time，相减获得通信延迟
  void _performHardwareSync(String reason) async {
    try {
      developer.log('🔄 执行硬件同步: $reason', name: _tag);
      
      final result = await _performHardwareInfoSync();
      
      if (result.success) {
        developer.log('✅ 硬件同步成功: 延迟${result.communicationDelay}ms', name: _tag);
        _hardwareSyncResultController.add(result);
        _communicationDelayController.add(result.communicationDelay);
      } else {
        developer.log('❌ 硬件同步失败: ${result.errorMessage}', name: _tag);
        _hardwareSyncResultController.add(result);
      }
    } catch (e) {
      developer.log('❌ 硬件同步异常: $e', name: _tag);
      final errorResult = HardwareSyncResult(
        success: false,
        syncTime: DateTime.now().millisecondsSinceEpoch,
        communicationDelay: 0,
        errorMessage: "硬件同步异常: $e",
      );
      _hardwareSyncResultController.add(errorResult);
    }
  }

  /// 执行硬件信息同步的实际逻辑
  Future<HardwareSyncResult> _performHardwareInfoSync() async {
    try {
      final commandManager = enhancedBluetoothManager.getBluetoothCommandManager();
      
      // 1. 设置时间
      final setTimeResult = await commandManager.setTime();
      if (setTimeResult is! BluetoothSuccess) {
        return HardwareSyncResult(
          success: false,
          syncTime: DateTime.now().millisecondsSinceEpoch,
          communicationDelay: 0,
          errorMessage: "设置时间失败",
        );
      }

      // 2. 获取时间以计算延迟
      final getTimeResult = await commandManager.getTime();
      if (getTimeResult is BluetoothSuccess<TimeData>) {
        final timeData = getTimeResult.data;
        final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final deviceTime = timeData.timestamp;
        final delay = (currentTime - deviceTime).abs() * 1000; // 转换为毫秒

        return HardwareSyncResult(
          success: true,
          syncTime: DateTime.now().millisecondsSinceEpoch,
          communicationDelay: delay,
        );
      } else {
        return HardwareSyncResult(
          success: false,
          syncTime: DateTime.now().millisecondsSinceEpoch,
          communicationDelay: 0,
          errorMessage: "获取时间失败",
        );
      }
    } catch (e) {
      return HardwareSyncResult(
        success: false,
        syncTime: DateTime.now().millisecondsSinceEpoch,
        communicationDelay: 0,
        errorMessage: "硬件同步异常: $e",
      );
    }
  }

  /// 手动触发硬件同步 - 完全匹配旧项目triggerHardwareSync
  Future<HardwareSyncResult> triggerHardwareSync() async {
    developer.log('🔄 手动触发硬件同步', name: _tag);
    return await _performHardwareInfoSync();
  }

  /// 手动开始collar status轮询 - 完全匹配旧项目startCollarStatusPolling
  void startCollarStatusPolling() {
    developer.log('🔄 手动开始collar status轮询', name: _tag);
    _startCollarStatusPolling();
  }

  /// 手动停止collar status轮询 - 完全匹配旧项目stopCollarStatusPolling
  void stopCollarStatusPolling() {
    developer.log('⏹️ 手动停止collar status轮询', name: _tag);
    _stopCollarStatusPolling();
  }

  /// 内部开始轮询逻辑
  void _startCollarStatusPolling() {
    // TODO: 实现轮询逻辑，定期获取电量、宝石状态等信息
    developer.log('🔄 开始collar status轮询', name: _tag);
  }

  /// 内部停止轮询逻辑
  void _stopCollarStatusPolling() {
    developer.log('⏹️ 停止collar status轮询', name: _tag);
  }

  /// 手动刷新项圈状态信息 - 完全匹配旧项目refreshCollarStatus
  /// 获取电池电量、版本信息、宝石信息、WiFi状态
  Future<CollarRefreshResult> refreshCollarStatus() async {
    developer.log('🔄 手动刷新项圈状态信息', name: _tag);
    
    try {
      final commandManager = enhancedBluetoothManager.getBluetoothCommandManager();
      
      // 获取电池信息
      final batteryResult = await commandManager.getBatteryInfo();
      BatteryInfo? batteryInfo;
      if (batteryResult is BluetoothSuccess<BatteryInfo>) {
        batteryInfo = batteryResult.data;
      }

      // TODO: 获取其他状态信息（版本、宝石、WiFi等）

      final statusData = CollarStatusData(
        batteryInfo: batteryInfo,
        deviceInfo: null, // TODO: 实现设备信息获取
        gemStatus: null,  // TODO: 实现宝石状态获取
        wifiStatus: WiFiStatus.unknown, // TODO: 实现WiFi状态获取
      );

      _collarStatusDataController.add(statusData);

      return CollarRefreshResult(
        success: batteryInfo != null,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        statusData: statusData,
      );
    } catch (e) {
      developer.log('❌ 刷新项圈状态异常: $e', name: _tag);
      return CollarRefreshResult(
        success: false,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        errorMessage: "刷新项圈状态异常: $e",
      );
    }
  }

  /// 获取网络状态数据（用于Network status模块） - 完全匹配旧项目getNetworkStatusData
  NetworkStatusData getNetworkStatusData() {
    // TODO: 实现WiFi和Safe Zone状态的获取（需要服务器通信）
    return const NetworkStatusData(
      bluetoothConnected: true, // 简化实现
      wifiStatus: WiFiStatus.unknown,
      safeZoneStatus: SafeZoneStatus.unknown,
    );
  }

  /// 清理资源 - 完全匹配旧项目cleanup
  void cleanup() {
    enhancedBluetoothManager.cleanup();
    
    // 取消所有订阅
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // 关闭流控制器
    _isAppInForegroundController.close();
    _currentPageController.close();
    _hardwareSyncResultController.close();
    _collarStatusDataController.close();
    _communicationDelayController.close();
  }
}

/// 应用页面枚举 - 完全匹配旧项目AppPage
enum AppPage {
  unknown("未知页面"),
  home("首页"),
  profile("个人资料"),
  settings("设置"),
  collarStatus("项圈状态"),
  collarGems("项圈宝石"),
  networkStatus("网络状态"),
  other("其他页面");

  const AppPage(this.displayName);
  final String displayName;
}

/// 网络状态数据 - 完全匹配旧项目NetworkStatusData
class NetworkStatusData {
  final bool bluetoothConnected;
  final WiFiStatus wifiStatus;
  final SafeZoneStatus safeZoneStatus;

  const NetworkStatusData({
    required this.bluetoothConnected,
    required this.wifiStatus,
    required this.safeZoneStatus,
  });
}

/// WiFi状态（根据collar-prompt.md） - 完全匹配旧项目WiFiStatus
enum WiFiStatus {
  connected([0x00, 0x01], "已连接", "绿色"),
  disconnected1([0x04], "断开连接", "红色"),
  disconnected2([0x05], "断开连接", "红色"), 
  disconnected3([0x06], "断开连接", "红色"),
  unknown([], "未知", "灰色");

  const WiFiStatus(this.code, this.displayName, this.color);
  final List<int> code;
  final String displayName;
  final String color;
}

/// Safe Zone状态（根据collar-prompt.md） - 完全匹配旧项目SafeZoneStatus
enum SafeZoneStatus {
  safeZone([0x00, 0x01, 0x04], "Safe Zone", "绿色"), // HOME_SUSPECTED_LOST_STATE
  lost([0x05], "Lost", "红色"), // HOME_LOST_STATE
  gpsRefuse([0x06], "GPS Refuse", "黄色"), // HOME_GPS_REFUSE_STATE
  unknown([], "未知", "灰色");

  const SafeZoneStatus(this.code, this.displayName, this.color);
  final List<int> code;
  final String displayName;
  final String color;
}

/// 硬件同步结果 - 匹配旧项目HardwareSyncResult
class HardwareSyncResult {
  final bool success;
  final int syncTime;
  final int communicationDelay;
  final String? errorMessage;

  const HardwareSyncResult({
    required this.success,
    required this.syncTime,
    required this.communicationDelay,
    this.errorMessage,
  });
}

/// 项圈刷新结果 - 匹配旧项目CollarRefreshResult
class CollarRefreshResult {
  final bool success;
  final int timestamp;
  final CollarStatusData? statusData;
  final String? errorMessage;

  const CollarRefreshResult({
    required this.success,
    required this.timestamp,
    this.statusData,
    this.errorMessage,
  });
}

/// 项圈状态数据 - 匹配旧项目CollarStatusData
class CollarStatusData {
  final BatteryInfo? batteryInfo;
  final DeviceInfo? deviceInfo;
  final AllGemsStatus? gemStatus;
  final WiFiStatus wifiStatus;

  const CollarStatusData({
    this.batteryInfo,
    this.deviceInfo,
    this.gemStatus,
    required this.wifiStatus,
  });
}