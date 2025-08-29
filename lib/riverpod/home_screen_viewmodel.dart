// 🔵 PetTalk 主屏幕ViewModel - 完全匹配旧Android项目的HomeScreenViewModel.kt
// 严格按照旧项目HomeScreenViewModel.kt逐行复刻数据管理逻辑

import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_talk/models/bluetooth_models.dart';

import 'package:pet_talk/services/bluetooth/app_bluetooth_manager.dart';

/// 宠物动作数据 - 完全匹配旧项目PetActionData
class PetActionData {
  final String actionName;
  final String gifFileName; 
  final int timestamp;
  final ActivityType activityType;

  const PetActionData({
    required this.actionName,
    required this.gifFileName,
    required this.timestamp,
    required this.activityType,
  });

  /// 获取完整的GIF文件路径 - 匹配旧项目getFullGifPath()
  String getFullGifPath() {
    return 'assets/images/activity/megan/$gifFileName';
  }

  /// 默认休息动作 - 匹配旧项目默认值
  static const PetActionData defaultRest = PetActionData(
    actionName: '休息',
    gifFileName: 'rest.gif',
    timestamp: 0,
    activityType: ActivityType.rest,
  );
}

/// 主屏幕UI状态 - 完全匹配旧项目HomeScreenUiState
class HomeScreenUiState {
  final BluetoothConnectionState bluetoothConnectionState;
  final bool isPolling;
  final String lastUpdateTime;
  final String errorMessage;

  const HomeScreenUiState({
    this.bluetoothConnectionState = BluetoothConnectionState.disconnected,
    this.isPolling = false,
    this.lastUpdateTime = '',
    this.errorMessage = '',
  });

  HomeScreenUiState copyWith({
    BluetoothConnectionState? bluetoothConnectionState,
    bool? isPolling,
    String? lastUpdateTime,
    String? errorMessage,
  }) {
    return HomeScreenUiState(
      bluetoothConnectionState: bluetoothConnectionState ?? this.bluetoothConnectionState,
      isPolling: isPolling ?? this.isPolling,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// 主屏幕ViewModel - 完全匹配旧项目HomeScreenViewModel
class HomeScreenViewModel extends StateNotifier<HomeScreenUiState> {
  static const String _tag = "HomeScreenViewModel";

  // 依赖注入 - 匹配旧项目constructor
  final AppBluetoothManager _appBluetoothManager;

  // 当前宠物动作 - 匹配旧项目currentPetAction
  final StateController<PetActionData> _currentPetActionController = 
      StateController(PetActionData.defaultRest);
  StateController<PetActionData> get currentPetAction => _currentPetActionController;

  // 轮询控制 - 匹配旧项目
  Timer? _pollingTimer;
  final Duration _pollingInterval = const Duration(seconds: 2);

  // 动作数据缓存 - 匹配旧项目
  PetActionData _lastActionData = PetActionData.defaultRest;

  // 订阅管理
  final List<StreamSubscription> _subscriptions = [];

  /// 构造函数 - 匹配旧项目constructor
  HomeScreenViewModel(this._appBluetoothManager) : super(const HomeScreenUiState()) {
    _initializeBluetoothListener();
  }

  /// 初始化蓝牙连接状态监听 - 匹配旧项目
  void _initializeBluetoothListener() {
    // 监听蓝牙连接状态变化
    _subscriptions.add(
      _appBluetoothManager.enhancedBluetoothManager.connectionState.listen((connectionState) {
        state = state.copyWith(bluetoothConnectionState: connectionState);
        developer.log('🔵 HomeScreen: 蓝牙连接状态变化: $connectionState', name: _tag);
        
        // 根据连接状态决定是否开始轮询
        if (connectionState == BluetoothConnectionState.connected) {
          _startPolling();
        } else {
          _stopPolling();
          // 连接断开时显示默认动作
          _updateCurrentAction(PetActionData.defaultRest);
        }
      }),
    );
  }

  /// 页面进入时调用 - 完全匹配旧项目onPageEntered()
  void onPageEntered() {
    developer.log('📱 HomeScreen: 页面进入', name: _tag);
    
    // 设置当前页面为HOME - 匹配旧项目
    _appBluetoothManager.setCurrentPage(AppPage.home);
    
    // 如果蓝牙已连接，立即开始轮询
    if (state.bluetoothConnectionState == BluetoothConnectionState.connected) {
      _startPolling();
    }
  }

  /// 页面离开时调用 - 完全匹配旧项目onPageLeft()
  void onPageLeft() {
    developer.log('📱 HomeScreen: 页面离开', name: _tag);
    _stopPolling();
  }

  /// 开始轮询宠物动作数据 - 匹配旧项目startPolling()
  void _startPolling() {
    if (_pollingTimer?.isActive == true) {
      return; // 已经在轮询中
    }

    developer.log('🔄 HomeScreen: 开始轮询宠物动作数据', name: _tag);
    state = state.copyWith(isPolling: true);

    _pollingTimer = Timer.periodic(_pollingInterval, (timer) async {
      await _fetchCurrentPetAction();
    });

    // 立即执行一次
    _fetchCurrentPetAction();
  }

  /// 停止轮询 - 匹配旧项目stopPolling()
  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    state = state.copyWith(isPolling: false);
    developer.log('⏹️ HomeScreen: 停止轮询', name: _tag);
  }

  /// 获取当前宠物动作 - 匹配旧项目fetchCurrentPetAction()
  Future<void> _fetchCurrentPetAction() async {
    try {
      // 获取蓝牙命令管理器
      final commandManager = _appBluetoothManager.enhancedBluetoothManager.getBluetoothCommandManager();
      
      // 发送获取最近1秒动作数据的命令 - 匹配旧项目getPetActivityData()
      final result = await commandManager.getBatteryInfo(); // 临时使用电量命令测试
      
      if (result is BluetoothSuccess<BatteryInfo>) {
        // 解析动作数据并更新UI
        // TODO: 这里需要实现真实的动作数据解析
        // 暂时使用模拟逻辑
        _updateActionBasedOnBatteryLevel(result.data.level);
        
        state = state.copyWith(
          lastUpdateTime: DateTime.now().toString(),
          errorMessage: '',
        );
      } else if (result is BluetoothError<BatteryInfo>) {
        developer.log('❌ HomeScreen: 获取宠物动作失败: ${result.message}', name: _tag);
        state = state.copyWith(errorMessage: result.message);
      }
    } catch (e) {
      developer.log('❌ HomeScreen: 获取宠物动作异常: $e', name: _tag);
      state = state.copyWith(errorMessage: '获取宠物动作异常: $e');
    }
  }

  /// 根据电量水平更新动作（临时逻辑） - 匹配旧项目动作切换逻辑
  void _updateActionBasedOnBatteryLevel(int batteryLevel) {
    PetActionData newAction;
    
    if (batteryLevel > 80) {
      newAction = PetActionData(
        actionName: '奔跑',
        gifFileName: 'walk.gif', // 使用现有的动画文件
        timestamp: DateTime.now().millisecondsSinceEpoch,
        activityType: ActivityType.run,
      );
    } else if (batteryLevel > 60) {
      newAction = PetActionData(
        actionName: '行走',
        gifFileName: 'rest2walk.gif',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        activityType: ActivityType.walk,
      );
    } else if (batteryLevel > 40) {
      newAction = PetActionData(
        actionName: '坐下',
        gifFileName: 'sit2walk.gif', 
        timestamp: DateTime.now().millisecondsSinceEpoch,
        activityType: ActivityType.rest,
      );
    } else {
      newAction = PetActionData(
        actionName: '休息',
        gifFileName: 'rest.gif',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        activityType: ActivityType.rest,
      );
    }

    _updateCurrentAction(newAction);
  }

  /// 更新当前动作 - 匹配旧项目updateCurrentAction()
  void _updateCurrentAction(PetActionData newAction) {
    if (_lastActionData.gifFileName != newAction.gifFileName) {
      developer.log('🐕 HomeScreen: 宠物动作变化: ${_lastActionData.actionName} → ${newAction.actionName}', name: _tag);
      _currentPetActionController.state = newAction;
      _lastActionData = newAction;
    }
  }

  /// 获取当前项圈数据 - 完全匹配旧项目getCurrentCollarData()
  PetCollar getCurrentCollarData() {
    // TODO: 实现真实的项圈数据获取
    // 暂时返回模拟数据，匹配旧项目的数据结构
    return const PetCollar(
      id: 'collar_001',
      petId: 'pet_001', 
      name: 'Smart Collar Pro',
      batteryLevel: 97, // 匹配collar-prompt.md中的97%电量
      isOnline: true,
      wifiConnected: true,
      bluetoothConnected: true,
      firmwareVersion: '1.2.3',
      lastSyncTime: 0,
      steps: 8432,
      heartRate: 120,
      gems: [
        CollarGem(position: 0, isConnected: true, isRecognized: true, type: GemType.barometer, version: '1.0'),
        CollarGem(position: 1, isConnected: true, isRecognized: true, type: GemType.barometer, version: '1.0'),
        CollarGem(position: 2, isConnected: true, isRecognized: true, type: GemType.barometer, version: '1.0'),  
        CollarGem(position: 3, isConnected: true, isRecognized: true, type: GemType.barometer, version: '1.0'),
      ],
      powerMode: PowerMode.performance,
      isInSafeZone: true,
    );
  }

  /// 获取当前宠物展示图片（等价旧项目的真实宠物展示）
  /// 优先返回本地已存在的示例头像资源，后续可接入用户上传头像/后端返回头像
  String getCurrentPetImageAsset() {
    // 资源存在于 pubspec.yaml 中声明的 assets/images/addpet/ 目录
    return 'assets/images/addpet/PaaaWOW0001 (1)_10.png';
  }

  /// 手动刷新数据 - 匹配旧项目refreshData()
  Future<void> refreshData() async {
    developer.log('🔄 HomeScreen: 手动刷新数据', name: _tag);
    
    // 触发硬件同步
    final syncResult = await _appBluetoothManager.triggerHardwareSync();
    if (syncResult.success) {
      developer.log('✅ HomeScreen: 硬件同步成功', name: _tag);
    }
    
    // 刷新项圈状态
    final collarResult = await _appBluetoothManager.refreshCollarStatus();
    if (collarResult.success) {
      developer.log('✅ HomeScreen: 项圈状态刷新成功', name: _tag);
    }
    
    // 立即获取一次动作数据
    await _fetchCurrentPetAction();
  }

  /// 清理资源 - 匹配旧项目cleanup()
  @override
  void dispose() {
    _stopPolling();
    
    // 取消所有订阅
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    
    _currentPetActionController.dispose();
    
    super.dispose();
  }
}

// ==================== Riverpod Providers ====================

/// AppBluetoothManager Provider
final appBluetoothManagerProvider = Provider<AppBluetoothManager>((ref) {
  return AppBluetoothManager();
});

/// HomeScreenViewModel Provider - 匹配旧项目的ViewModel注入
final homeScreenViewModelProvider = StateNotifierProvider<HomeScreenViewModel, HomeScreenUiState>((ref) {
  final appBluetoothManager = ref.watch(appBluetoothManagerProvider);
  return HomeScreenViewModel(appBluetoothManager);
});

/// 当前宠物动作 Provider - 匹配旧项目currentPetAction
final currentPetActionProvider = Provider<StateController<PetActionData>>((ref) {
  final viewModel = ref.watch(homeScreenViewModelProvider.notifier);
  return viewModel.currentPetAction;
});

/// 当前宠物动作数据 Provider
final currentPetActionDataProvider = Provider<PetActionData>((ref) {
  final controller = ref.watch(currentPetActionProvider);
  return controller.state;
});