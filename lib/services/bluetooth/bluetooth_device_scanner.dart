// 🔵 PetTalk 蓝牙设备扫描器 - 完全匹配旧Android项目的BluetoothDeviceScanner.kt
// 严格按照旧项目逐行复刻设备扫描逻辑

import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:pet_talk/services/bluetooth/bluetooth_cache_manager.dart';

/// 蓝牙设备扫描器 - 完全匹配旧项目BluetoothDeviceScanner
class BluetoothDeviceScanner {
  static const String _tag = "BluetoothDeviceScanner";
  static const int _scanTimeoutSeconds = 30;

  final BluetoothCacheManager _cacheManager;
  
  // 扫描状态管理
  final StreamController<List<ScanResult>> _scanResultsController = 
      StreamController<List<ScanResult>>.broadcast();
  Stream<List<ScanResult>> get scanResults => _scanResultsController.stream;

  final StreamController<bool> _scanningController = 
      StreamController<bool>.broadcast();
  Stream<bool> get isScanning => _scanningController.stream;

  Timer? _scanTimeoutTimer;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  bool _isCurrentlyScanning = false;

  /// 构造函数 - 匹配旧项目constructor
  BluetoothDeviceScanner(this._cacheManager);

  /// 启动设备扫描 - 完全匹配旧项目startScan
  void startScan() async {
    if (_isCurrentlyScanning) {
      developer.log('🔍 扫描已在进行中', name: _tag);
      return;
    }

    try {
      developer.log('🔍 开始蓝牙设备扫描', name: _tag);
      _isCurrentlyScanning = true;
      _scanningController.add(true);

      // 设置扫描超时 - 匹配旧项目扫描超时处理
      _scanTimeoutTimer = Timer(Duration(seconds: _scanTimeoutSeconds), () {
        developer.log('⏰ 扫描超时，停止扫描', name: _tag);
        stopScan();
      });

      // 开始扫描 - 使用FlutterBluePlus
      await FlutterBluePlus.startScan(
        timeout: Duration(seconds: _scanTimeoutSeconds),
        withServices: [], // 扫描所有设备
        withNames: [], // 扫描所有名称
      );

      // 监听扫描结果 - 匹配旧项目扫描回调
      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          developer.log('📡 发现 ${results.length} 个设备', name: _tag);
          _scanResultsController.add(results);
          
          // 记录发现的设备详情
          for (final result in results) {
            final device = result.device;
            final rssi = result.rssi;
            final name = device.platformName.isNotEmpty ? device.platformName : '未知设备';
            developer.log('📱 发现设备: $name (${device.remoteId}) RSSI: $rssi', name: _tag);
          }
        },
        onError: (error) {
          developer.log('❌ 扫描错误: $error', name: _tag);
          stopScan();
        },
      );

    } catch (e) {
      developer.log('❌ 启动扫描失败: $e', name: _tag);
      stopScan();
    }
  }

  /// 停止设备扫描 - 完全匹配旧项目stopScan
  void stopScan() async {
    if (!_isCurrentlyScanning) {
      return;
    }

    try {
      developer.log('⏹️ 停止蓝牙设备扫描', name: _tag);
      
      // 停止扫描
      await FlutterBluePlus.stopScan();
      
      // 清理资源
      _scanTimeoutTimer?.cancel();
      _scanTimeoutTimer = null;
      
      await _scanSubscription?.cancel();
      _scanSubscription = null;

      _isCurrentlyScanning = false;
      _scanningController.add(false);

      developer.log('✅ 扫描已停止', name: _tag);
    } catch (e) {
      developer.log('❌ 停止扫描失败: $e', name: _tag);
      _isCurrentlyScanning = false;
      _scanningController.add(false);
    }
  }

  /// 按设备名称过滤扫描结果
  Stream<List<ScanResult>> filterByName(String deviceName) {
    return scanResults.map((results) {
      return results.where((result) {
        final name = result.device.platformName;
        return name.isNotEmpty && name.toLowerCase().contains(deviceName.toLowerCase());
      }).toList();
    });
  }

  /// 按RSSI强度过滤扫描结果
  Stream<List<ScanResult>> filterByRssi(int minRssi) {
    return scanResults.map((results) {
      return results.where((result) => result.rssi >= minRssi).toList();
    });
  }

  /// 获取PetTalk相关设备
  Stream<List<ScanResult>> getPetTalkDevices() {
    return scanResults.map((results) {
      return results.where((result) {
        final name = result.device.platformName.toLowerCase();
        // 根据项目需求过滤相关设备名称
        return name.contains('pettalk') || 
               name.contains('pet') || 
               name.contains('collar') ||
               name.contains('smart');
      }).toList();
    });
  }

  /// 检查当前扫描状态
  bool get isCurrentlyScanning => _isCurrentlyScanning;

  /// 清理资源 - 完全匹配旧项目cleanup
  void cleanup() {
    stopScan();
    _scanResultsController.close();
    _scanningController.close();
  }
}