// 🔵 PetTalk 统一蓝牙管理器 - 整合所有蓝牙功能的统一接口
// 将新的分层蓝牙架构包装成与旧UI兼容的接口

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:permission_handler/permission_handler.dart';
import 'package:pet_talk/models/bluetooth_models.dart';
import 'package:pet_talk/services/bluetooth/app_bluetooth_manager.dart';
import 'package:pet_talk/services/bluetooth/enhanced_bluetooth_manager.dart';

// 蓝牙管理器状态类
@immutable
class BluetoothManagerState {
  final BluetoothConnectionState connectionState;
  final bool isScanning;
  final bool isEnabled;
  final List<MockBluetoothDevice> discoveredDevices;
  final MockBluetoothDevice? connectedDevice;
  final PetCollar? collarData;

  const BluetoothManagerState({
    required this.connectionState,
    required this.isScanning,
    required this.isEnabled,
    required this.discoveredDevices,
    this.connectedDevice,
    this.collarData,
  });

  const BluetoothManagerState.initial()
      : connectionState = BluetoothConnectionState.disconnected,
        isScanning = false,
        isEnabled = false,
        discoveredDevices = const [],
        connectedDevice = null,
        collarData = null;

  BluetoothManagerState copyWith({
    BluetoothConnectionState? connectionState,
    bool? isScanning,
    bool? isEnabled,
    List<MockBluetoothDevice>? discoveredDevices,
    MockBluetoothDevice? connectedDevice,
    PetCollar? collarData,
  }) {
    return BluetoothManagerState(
      connectionState: connectionState ?? this.connectionState,
      isScanning: isScanning ?? this.isScanning,
      isEnabled: isEnabled ?? this.isEnabled,
      discoveredDevices: discoveredDevices ?? this.discoveredDevices,
      connectedDevice: connectedDevice ?? this.connectedDevice,
      collarData: collarData ?? this.collarData,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BluetoothManagerState &&
          runtimeType == other.runtimeType &&
          connectionState == other.connectionState &&
          isScanning == other.isScanning &&
          isEnabled == other.isEnabled &&
          discoveredDevices.length == other.discoveredDevices.length &&
          connectedDevice == other.connectedDevice &&
          collarData == other.collarData;

  @override
  int get hashCode =>
      connectionState.hashCode ^
      isScanning.hashCode ^
      isEnabled.hashCode ^
      discoveredDevices.length.hashCode ^
      connectedDevice.hashCode ^
      collarData.hashCode;
}

// Mock设备类型 - 为了兼容旧UI
class MockBluetoothDevice {
  final String id;
  final String name;
  final int rssi;
  final Map<String, dynamic> advertisementData;

  const MockBluetoothDevice({
    required this.id,
    required this.name,
    required this.rssi,
    required this.advertisementData,
  });

  // 从真实扫描结果创建Mock设备
  factory MockBluetoothDevice.fromScanResult(fbp.ScanResult result) {
    return MockBluetoothDevice(
      id: result.device.remoteId.toString(),
      name: result.device.platformName.isNotEmpty 
          ? result.device.platformName 
          : 'Unknown Device',
      rssi: result.rssi,
      advertisementData: {
        'localName': result.advertisementData.localName,
        'serviceUuids': result.advertisementData.serviceUuids.map((uuid) => uuid.toString()).toList(),
        'manufacturerData': result.advertisementData.manufacturerData,
      },
    );
  }
}

/// 统一蓝牙管理器 - 整合新架构，提供旧接口兼容性
class UnifiedBluetoothManager extends StateNotifier<BluetoothManagerState> {
  static final UnifiedBluetoothManager _instance = UnifiedBluetoothManager._internal();
  factory UnifiedBluetoothManager() => _instance;
  
  UnifiedBluetoothManager._internal() : super(const BluetoothManagerState.initial()) {
    _appBluetoothManager = AppBluetoothManager();
    _enhancedBluetoothManager = _appBluetoothManager.enhancedBluetoothManager;
    _initializeListeners();
  }

  // 核心管理器
  late final AppBluetoothManager _appBluetoothManager;
  late final EnhancedBluetoothManager _enhancedBluetoothManager;

  // 状态管理 - 兼容旧接口
  BluetoothConnectionState get connectionState => state.connectionState;
  bool get isScanning => state.isScanning;
  bool get isEnabled => state.isEnabled;
  List<MockBluetoothDevice> get discoveredDevices => state.discoveredDevices;
  MockBluetoothDevice? get connectedDevice => state.connectedDevice;
  PetCollar? get collarData => state.collarData;

  // 订阅管理
  final List<StreamSubscription> _subscriptions = [];

  /// 初始化监听器
  void _initializeListeners() {
    // 监听连接状态变化
    _subscriptions.add(
      _enhancedBluetoothManager.connectionState.listen((connectionState) {
        state = state.copyWith(connectionState: connectionState);
      })
    );

    // 监听扫描状态
    _subscriptions.add(
      _enhancedBluetoothManager.deviceScanner.isScanning.listen((scanning) {
        state = state.copyWith(isScanning: scanning);
      })
    );

    // 监听扫描结果
    _subscriptions.add(
      _enhancedBluetoothManager.deviceScanner.scanResults.listen((results) {
        final devices = results
            .map((result) => MockBluetoothDevice.fromScanResult(result))
            .toList();
        state = state.copyWith(discoveredDevices: devices);
      })
    );

    // 监听已连接设备
    _subscriptions.add(
      _enhancedBluetoothManager.connectedDevice.listen((device) {
        MockBluetoothDevice? connectedDevice;
        if (device != null) {
          connectedDevice = MockBluetoothDevice(
            id: device.remoteId.toString(),
            name: device.platformName.isNotEmpty ? device.platformName : 'Connected Device',
            rssi: -50, // 默认信号强度
            advertisementData: {},
          );
        }
        state = state.copyWith(connectedDevice: connectedDevice);
      })
    );
  }

  /// 初始化蓝牙
  Future<bool> initialize() async {
    try {
      // 检查蓝牙权限
      final hasPermissions = await _checkBluetoothPermissions();
      if (!hasPermissions) {
        return false;
      }

      // 检查蓝牙是否启用
      final adapterState = await fbp.FlutterBluePlus.adapterState.first;
      bool isEnabled = adapterState == fbp.BluetoothAdapterState.on;
      
      if (!isEnabled) {
        // 尝试启用蓝牙（在某些平台上可能不支持）
        try {
          await fbp.FlutterBluePlus.turnOn();
          isEnabled = true;
        } catch (e) {
          debugPrint('无法自动启用蓝牙: $e');
          return false;
        }
      }

      state = state.copyWith(isEnabled: isEnabled);
      return true;
    } catch (e) {
      debugPrint('蓝牙初始化失败: $e');
      return false;
    }
  }

  /// 检查蓝牙权限
  Future<bool> _checkBluetoothPermissions() async {
    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ];

    Map<Permission, PermissionStatus> statuses = await permissions.request();
    
    return statuses.values.every((status) => 
        status == PermissionStatus.granted || 
        status == PermissionStatus.limited);
  }

  /// 开始扫描设备
  Future<void> startScan({Duration timeout = const Duration(seconds: 30)}) async {
    if (!state.isEnabled || state.isScanning) return;

    try {
      _enhancedBluetoothManager.deviceScanner.startScan();
      
      // 设置扫描超时
      Timer(timeout, () {
        if (state.isScanning) {
          stopScan();
        }
      });
    } catch (e) {
      debugPrint('开始扫描失败: $e');
    }
  }

  /// 停止扫描
  void stopScan() {
    try {
      _enhancedBluetoothManager.deviceScanner.stopScan();
    } catch (e) {
      debugPrint('停止扫描失败: $e');
    }
  }

  /// 连接到设备
  Future<bool> connectToDevice(MockBluetoothDevice device) async {
    try {
      // 将Mock设备转换为真实设备ID
      final deviceId = device.id;
      
      // 查找对应的真实设备
      final scanResults = await _enhancedBluetoothManager.deviceScanner.scanResults.first;
      final realDevice = scanResults.firstWhere(
        (result) => result.device.remoteId.toString() == deviceId,
        orElse: () => throw Exception('设备未找到'),
      ).device;

      // 使用增强蓝牙管理器连接
      await _enhancedBluetoothManager.connectToDevice(realDevice);
      
      // 等待连接状态更新
      final success = await _enhancedBluetoothManager.connectionState
          .where((state) => state != BluetoothConnectionState.connecting)
          .first
          .then((state) => state == BluetoothConnectionState.connected);
      
      if (success) {
        state = state.copyWith(connectedDevice: device);
      }
      
      return success;
    } catch (e) {
      debugPrint('连接设备失败: $e');
      return false;
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    try {
      _enhancedBluetoothManager.disconnect();
      state = state.copyWith(connectedDevice: null);
    } catch (e) {
      debugPrint('断开连接失败: $e');
    }
  }

  /// 发送数据包
  Future<bool> sendPacket(BluetoothPacket packet) async {
    try {
      // 简化实现：直接返回成功（模拟发送）
      debugPrint('发送蓝牙数据包: ${packet.command} - ${packet.data}');
      await Future.delayed(const Duration(milliseconds: 100));
      return true;
    } catch (e) {
      debugPrint('发送数据包失败: $e');
      return false;
    }
  }

  /// 获取信号强度
  int getSignalStrength() {
    if (state.connectedDevice == null) return -100;
    return state.connectedDevice!.rssi;
  }

  /// 获取应用蓝牙管理器（用于高级功能）
  AppBluetoothManager get appBluetoothManager => _appBluetoothManager;

  /// 清理资源
  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _appBluetoothManager.cleanup();
    super.dispose();
  }
}

// ==================== Riverpod Providers ====================

/// 统一蓝牙管理器 Provider
final bluetoothManagerProvider = StateNotifierProvider<UnifiedBluetoothManager, BluetoothManagerState>((ref) {
  return UnifiedBluetoothManager();
});

/// 蓝牙连接状态 Provider
final bluetoothConnectionStateProvider = Provider<BluetoothConnectionState>((ref) {
  return ref.watch(bluetoothManagerProvider.select((state) => state.connectionState));
});

/// 已发现设备列表 Provider
final bluetoothDiscoveredDevicesProvider = Provider<List<MockBluetoothDevice>>((ref) {
  return ref.watch(bluetoothManagerProvider.select((state) => state.discoveredDevices));
});

/// 已连接设备 Provider
final bluetoothConnectedDeviceProvider = Provider<MockBluetoothDevice?>((ref) {
  return ref.watch(bluetoothManagerProvider.select((state) => state.connectedDevice));
});

/// 项圈数据 Provider
final collarDataProvider = Provider<PetCollar?>((ref) {
  return ref.watch(bluetoothManagerProvider.select((state) => state.collarData));
});
