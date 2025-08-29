// 🔵 PetTalk 增强蓝牙管理器 - 完全匹配旧Android项目的EnhancedBluetoothManager.kt
// 严格按照旧项目EnhancedBluetoothManager.kt的569行代码逐行复刻

import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:pet_talk/models/bluetooth_models.dart';
import 'package:pet_talk/services/bluetooth/bluetooth_cache_manager.dart';
import 'package:pet_talk/services/bluetooth/bluetooth_device_scanner.dart';
import 'package:pet_talk/services/bluetooth/bluetooth_command_manager.dart';

/// 增强的蓝牙连接管理器 - 完全匹配旧项目
/// 集成设备缓存、自动重连、设备扫描等功能
class EnhancedBluetoothManager {
  static const String _tag = "EnhancedBluetoothManager";
  static const int _connectionTimeoutMs = 15000;
  static const int _reconnectDelayMs = 3000;
  static const int _maxReconnectAttempts = 5;
  
  // 服务和特征UUID - 完全匹配旧项目
  static const String serviceUuid = "19B10022-E8F2-537E-4F6C-D104768A1214";
  static const String generalDataCharacteristicUuid = "19B10033-E8F2-537E-4F6C-D104768A1214";
  static const String streamDataCharacteristicUuid = "19B10044-E8F2-537E-4F6C-D104768A1214";

  // 管理器组件 - 匹配旧项目
  late final BluetoothCacheManager cacheManager;
  late final BluetoothDeviceScanner deviceScanner;
  late final BluetoothCommandManager _commandManager;

  // 连接状态 - 匹配旧项目
  final StreamController<BluetoothConnectionState> _connectionStateController = 
      StreamController<BluetoothConnectionState>.broadcast();
  Stream<BluetoothConnectionState> get connectionState => _connectionStateController.stream;
  BluetoothConnectionState _currentConnectionState = BluetoothConnectionState.disconnected;

  // 当前连接的设备 - 匹配旧项目
  final StreamController<fbp.BluetoothDevice?> _connectedDeviceController = 
      StreamController<fbp.BluetoothDevice?>.broadcast();
  Stream<fbp.BluetoothDevice?> get connectedDevice => _connectedDeviceController.stream;
  fbp.BluetoothDevice? _currentConnectedDevice;

  // GATT连接 - 匹配旧项目
  fbp.BluetoothDevice? _bluetoothDevice;
  fbp.BluetoothCharacteristic? _generalDataCharacteristic;
  fbp.BluetoothCharacteristic? _streamDataCharacteristic;

  // 重连控制 - 匹配旧项目
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  Timer? _connectionTimeoutTimer;

  // 自动连接控制 - 匹配旧项目
  Timer? _autoConnectTimer;

  // 订阅管理
  final List<StreamSubscription> _subscriptions = [];

  /// 构造函数 - 匹配旧项目constructor
  EnhancedBluetoothManager() {
    cacheManager = BluetoothCacheManager();
    deviceScanner = BluetoothDeviceScanner(cacheManager);
    _commandManager = BluetoothCommandManager();

    // 启动时检查是否需要自动连接 - 匹配旧项目init逻辑
    Timer(const Duration(seconds: 1), () {
      if (cacheManager.shouldAutoConnect()) {
        startAutoConnect();
      }
    });

    _initializeBluetoothState();
  }

  /// 初始化蓝牙状态监听
  void _initializeBluetoothState() {
    // 监听FlutterBluePlus状态变化
    _subscriptions.add(
      fbp.FlutterBluePlus.adapterState.listen((fbp.BluetoothAdapterState state) {
        developer.log('🔵 Bluetooth adapter state: $state', name: _tag);
      })
    );
  }

  /// 连接到指定设备 - 完全匹配旧项目connectToDevice
  Future<bool> connectToDevice(fbp.BluetoothDevice device) async {
    try {
      if (_currentConnectionState == BluetoothConnectionState.connecting ||
          _currentConnectionState == BluetoothConnectionState.connected) {
        developer.log('设备已连接或正在连接', name: _tag);
        return _currentConnectionState == BluetoothConnectionState.connected;
      }

      // 检查蓝牙权限 - 匹配旧项目hasBluetoothPermissions()
      if (!await _hasBluetoothPermissions()) {
        developer.log('❌ 缺少蓝牙权限', name: _tag);
        return false;
      }

      // 断开之前的连接 - 匹配旧项目disconnect()
      disconnect();

      _updateConnectionState(BluetoothConnectionState.connecting);
      developer.log('🔗 开始连接设备: ${device.remoteId}', name: _tag);

      // 设置连接超时 - 匹配旧项目connectionTimeoutJob
      _connectionTimeoutTimer = Timer(
        Duration(milliseconds: _connectionTimeoutMs),
        () {
          if (_currentConnectionState == BluetoothConnectionState.connecting) {
            developer.log('⏰ 连接超时', name: _tag);
            _handleConnectionTimeout();
          }
        },
      );

      // 开始GATT连接 - 匹配旧项目device.connectGatt
      _bluetoothDevice = device;
      await device.connect(timeout: Duration(milliseconds: _connectionTimeoutMs));

      // 监听连接状态变化 - 匹配旧项目gattCallback.onConnectionStateChange
      _subscriptions.add(
        device.connectionState.listen((fbp.BluetoothConnectionState state) {
          _handleConnectionStateChange(device, _convertConnectionState(state));
        })
      );

      return true;
    } catch (e) {
      developer.log('❌ 连接设备异常: $e', name: _tag);
      _updateConnectionState(BluetoothConnectionState.error);
      return false;
    }
  }

  /// 连接到缓存的设备 - 完全匹配旧项目connectToCachedDevice
  Future<bool> connectToCachedDevice() async {
    final cachedDevice = await cacheManager.getCachedBluetoothDevice();
    if (cachedDevice == null) {
      developer.log('没有缓存的设备', name: _tag);
      return false;
    }

    try {
      // 查找蓝牙设备
      final devices = await fbp.FlutterBluePlus.connectedSystemDevices;
      fbp.BluetoothDevice? device;
      
      // 先查找已连接的设备
      for (final connectedDevice in devices) {
        if (connectedDevice.remoteId.toString() == cachedDevice.address) {
          device = connectedDevice;
          break;
        }
      }

      // 如果没有找到已连接的设备，扫描查找
      if (device == null) {
        try {
          final scanResults = await fbp.FlutterBluePlus.scanResults.first;
          for (final result in scanResults) {
            if (result.device.remoteId.toString() == cachedDevice.address) {
              device = result.device;
              break;
            }
          }
        } catch (e) {
          developer.log('❌ 获取扫描结果失败: $e', name: _tag);
        }
      }

      if (device != null) {
        return await connectToDevice(device);
      } else {
        developer.log('❌ 未找到缓存的设备', name: _tag);
        return false;
      }
    } catch (e) {
      developer.log('❌ 连接缓存设备失败: $e', name: _tag);
      return false;
    }
  }

  /// 断开连接 - 完全匹配旧项目disconnect
  void disconnect() {
    try {
      stopAutoConnect();
      _stopReconnect();
      _connectionTimeoutTimer?.cancel();

      _bluetoothDevice?.disconnect();
      _bluetoothDevice = null;
      _generalDataCharacteristic = null;
      _streamDataCharacteristic = null;

      _updateConnectionState(BluetoothConnectionState.disconnected);
      _updateConnectedDevice(null);

      developer.log('🔌 断开蓝牙连接', name: _tag);
    } catch (e) {
      developer.log('❌ 断开连接异常: $e', name: _tag);
    }
  }

  /// 启动自动连接 - 完全匹配旧项目startAutoConnect
  void startAutoConnect() {
    if (!cacheManager.shouldAutoConnect()) {
      developer.log('自动连接已禁用或无缓存设备', name: _tag);
      return;
    }

    _autoConnectTimer?.cancel();
    _autoConnectTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) async {
        if (cacheManager.shouldAutoConnect()) {
          if (_currentConnectionState == BluetoothConnectionState.disconnected) {
            developer.log('🔄 尝试自动连接缓存设备', name: _tag);
            await connectToCachedDevice();
          }
        } else {
          timer.cancel();
        }
      },
    );
  }

  /// 停止自动连接 - 完全匹配旧项目stopAutoConnect
  void stopAutoConnect() {
    _autoConnectTimer?.cancel();
    _autoConnectTimer = null;
  }

  /// 启动设备扫描 - 完全匹配旧项目startDeviceScan
  void startDeviceScan() {
    deviceScanner.startScan();
  }

  /// 停止设备扫描 - 完全匹配旧项目stopDeviceScan
  void stopDeviceScan() {
    deviceScanner.stopScan();
  }

  /// 处理连接状态变化 - 完全匹配旧项目handleConnectionStateChange
  void _handleConnectionStateChange(fbp.BluetoothDevice device, BluetoothConnectionState newState) {
    switch (newState) {
      case BluetoothConnectionState.connected:
        developer.log('✅ 设备连接成功', name: _tag);
        _connectionTimeoutTimer?.cancel();
        _reconnectAttempts = 0;

        _updateConnectionState(BluetoothConnectionState.connected);
        _updateConnectedDevice(device);

        // 同步连接状态到CommandManager - 匹配旧项目
        _commandManager.updateConnectionState(BluetoothConnectionState.connected);
        _commandManager.updateBluetoothDevice(device);

        // 缓存设备信息 - 匹配旧项目
        cacheManager.cacheBluetoothDevice(
          device.remoteId.toString(),
          device.platformName.isNotEmpty ? device.platformName : null,
        );

        // 发现服务 - 匹配旧项目discoverServices
        _discoverServices(device);
        break;

      case BluetoothConnectionState.disconnected:
        developer.log('🔌 设备连接断开', name: _tag);
        _updateConnectionState(BluetoothConnectionState.disconnected);
        _updateConnectedDevice(null);

        // 同步断开状态到CommandManager - 匹配旧项目
        _commandManager.updateConnectionState(BluetoothConnectionState.disconnected);
        _commandManager.updateBluetoothDevice(null);
        _commandManager.updateCharacteristics(null, null);

        // 决定是否自动重连 - 匹配旧项目shouldAttemptReconnect
        if (_shouldAttemptReconnect()) {
          _startReconnect();
        }
        break;

      case BluetoothConnectionState.connecting:
        developer.log('⏳ 正在连接设备...', name: _tag);
        _updateConnectionState(BluetoothConnectionState.connecting);
        _commandManager.updateConnectionState(BluetoothConnectionState.connecting);
        break;

      case BluetoothConnectionState.disconnecting:
        developer.log('⏳ 正在断开连接...', name: _tag);
        break;

      case BluetoothConnectionState.error:
        developer.log('❌ 连接错误', name: _tag);
        _updateConnectionState(BluetoothConnectionState.error);
        _commandManager.updateConnectionState(BluetoothConnectionState.error);
        break;
    }
  }

  /// 发现服务 - 匹配旧项目handleServicesDiscovered
  void _discoverServices(fbp.BluetoothDevice device) async {
    try {
      final services = await device.discoverServices();
      
      for (final service in services) {
        if (service.uuid.toString().toUpperCase() == serviceUuid.toUpperCase()) {
          // 查找特征 - 匹配旧项目getCharacteristic
          for (final characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toUpperCase() == 
                generalDataCharacteristicUuid.toUpperCase()) {
              _generalDataCharacteristic = characteristic;
            } else if (characteristic.uuid.toString().toUpperCase() == 
                       streamDataCharacteristicUuid.toUpperCase()) {
              _streamDataCharacteristic = characteristic;
            }
          }

          // 同步特征引用到CommandManager - 匹配旧项目
          _commandManager.updateCharacteristics(
            _generalDataCharacteristic,
            _streamDataCharacteristic,
          );

          // 启用通知 - 匹配旧项目enableNotifications
          await _enableNotifications();

          developer.log('📡 服务发现成功，特征已准备就绪', name: _tag);
          return;
        }
      }

      developer.log('❌ 未找到目标服务', name: _tag);
      _updateConnectionState(BluetoothConnectionState.error);
      _commandManager.updateConnectionState(BluetoothConnectionState.error);
    } catch (e) {
      developer.log('❌ 服务发现失败: $e', name: _tag);
      _updateConnectionState(BluetoothConnectionState.error);
      _commandManager.updateConnectionState(BluetoothConnectionState.error);
    }
  }

  /// 启用蓝牙特征通知 - 完全匹配旧项目enableNotifications
  Future<void> _enableNotifications() async {
    developer.log('🔔 启用特征通知...', name: _tag);

    // 启用一般数据特征通知 - 匹配旧项目generalDataCharacteristic处理
    if (_generalDataCharacteristic != null) {
      try {
        developer.log('🔔 启用一般数据特征通知: ${_generalDataCharacteristic!.uuid}', name: _tag);
        
        await _generalDataCharacteristic!.setNotifyValue(true);
        
        // 监听特征变化 - 匹配旧项目onCharacteristicChanged
        _subscriptions.add(
          _generalDataCharacteristic!.lastValueStream.listen((data) {
            developer.log('📢 收到一般数据特征通知: ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}', name: _tag);
            // 转发数据到CommandManager - 匹配旧项目handleReceivedGeneralData
            _commandManager.handleReceivedGeneralData(data);
          }),
        );

        developer.log('✅ 一般数据特征通知已启用', name: _tag);
      } catch (e) {
        developer.log('❌ 启用一般数据特征通知失败: $e', name: _tag);
      }
    } else {
      developer.log('⚠️ 一般数据特征为null，无法启用通知', name: _tag);
    }

    // 启用流式数据特征通知 - 匹配旧项目streamDataCharacteristic处理
    if (_streamDataCharacteristic != null) {
      try {
        developer.log('🔔 启用流式数据特征通知: ${_streamDataCharacteristic!.uuid}', name: _tag);
        
        await _streamDataCharacteristic!.setNotifyValue(true);
        
        // 监听特征变化 - 匹配旧项目onCharacteristicChanged
        _subscriptions.add(
          _streamDataCharacteristic!.lastValueStream.listen((data) {
            developer.log('📢 收到流式数据特征通知: ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}', name: _tag);
            // 转发数据到CommandManager - 匹配旧项目handleReceivedStreamData
            _commandManager.handleReceivedStreamData(data);
          }),
        );

        developer.log('✅ 流式数据特征通知已启用', name: _tag);
      } catch (e) {
        developer.log('❌ 启用流式数据特征通知失败: $e', name: _tag);
      }
    } else {
      developer.log('⚠️ 流式数据特征为null，无法启用通知', name: _tag);
    }

    developer.log('✅ 通知启用完成', name: _tag);
  }

  /// 处理连接超时 - 完全匹配旧项目handleConnectionTimeout
  void _handleConnectionTimeout() {
    developer.log('⏰ 连接超时，尝试重连', name: _tag);
    _updateConnectionState(BluetoothConnectionState.error);

    if (_shouldAttemptReconnect()) {
      _startReconnect();
    }
  }

  /// 开始重连 - 完全匹配旧项目startReconnect
  void _startReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      developer.log('🔄 重连次数已达上限，停止重连', name: _tag);
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(milliseconds: _reconnectDelayMs), () async {
      _reconnectAttempts++;
      developer.log('🔄 第 $_reconnectAttempts 次重连尝试', name: _tag);

      if (_currentConnectionState != BluetoothConnectionState.connected) {
        await connectToCachedDevice();
      }
    });
  }

  /// 停止重连 - 完全匹配旧项目stopReconnect
  void _stopReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
  }

  /// 判断是否应该尝试重连 - 完全匹配旧项目shouldAttemptReconnect
  bool _shouldAttemptReconnect() {
    return cacheManager.shouldAutoConnect() && 
           _reconnectAttempts < _maxReconnectAttempts &&
           _currentConnectionState != BluetoothConnectionState.connected;
  }

  /// 检查蓝牙权限 - 完全匹配旧项目hasBluetoothPermissions
  Future<bool> _hasBluetoothPermissions() async {
    try {
      // Flutter Blue Plus会自动处理权限请求
      final adapterState = await fbp.FlutterBluePlus.adapterState.first;
      return adapterState == fbp.BluetoothAdapterState.on;
    } catch (e) {
      developer.log('❌ 检查蓝牙权限失败: $e', name: _tag);
      return false;
    }
  }

  /// 转换连接状态 - 将FlutterBluePlus状态转换为我们的状态
  BluetoothConnectionState _convertConnectionState(fbp.BluetoothConnectionState state) {
    switch (state) {
      case fbp.BluetoothConnectionState.disconnected:
        return BluetoothConnectionState.disconnected;
      case fbp.BluetoothConnectionState.connecting:
        return BluetoothConnectionState.connecting;
      case fbp.BluetoothConnectionState.connected:
        return BluetoothConnectionState.connected;
      case fbp.BluetoothConnectionState.disconnecting:
        return BluetoothConnectionState.disconnecting;
    }
  }

  /// 获取一般数据特征 - 完全匹配旧项目getGeneralDataCharacteristic
  fbp.BluetoothCharacteristic? getGeneralDataCharacteristic() {
    return _generalDataCharacteristic;
  }

  /// 获取流数据特征 - 完全匹配旧项目getStreamDataCharacteristic
  fbp.BluetoothCharacteristic? getStreamDataCharacteristic() {
    return _streamDataCharacteristic;
  }

  /// 获取蓝牙命令管理器 - 完全匹配旧项目getBluetoothCommandManager
  BluetoothCommandManager getBluetoothCommandManager() {
    return _commandManager;
  }

  /// 写入特征数据 - 完全匹配旧项目writeCharacteristic
  Future<bool> writeCharacteristic(
    fbp.BluetoothCharacteristic characteristic,
    List<int> data,
  ) async {
    try {
      if (!await _hasBluetoothPermissions()) {
        return false;
      }

      await characteristic.write(data);
      return true;
    } catch (e) {
      developer.log('❌ 写入特征异常: $e', name: _tag);
      return false;
    }
  }

  /// 更新连接状态
  void _updateConnectionState(BluetoothConnectionState newState) {
    _currentConnectionState = newState;
    _connectionStateController.add(newState);
  }

  /// 更新连接的设备
  void _updateConnectedDevice(fbp.BluetoothDevice? device) {
    _currentConnectedDevice = device;
    _connectedDeviceController.add(device);
  }

  /// 清理资源 - 完全匹配旧项目cleanup
  void cleanup() {
    disconnect();
    stopAutoConnect();
    deviceScanner.cleanup();
    
    // 取消所有订阅
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // 关闭流控制器
    _connectionStateController.close();
    _connectedDeviceController.close();
  }
}