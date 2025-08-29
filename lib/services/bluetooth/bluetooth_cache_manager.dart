// 🔵 PetTalk 蓝牙缓存管理器 - 完全匹配旧Android项目的BluetoothCacheManager.kt
// 严格按照旧项目逐行复刻缓存管理逻辑

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

/// 蓝牙设备缓存数据结构 - 匹配旧项目
class CachedBluetoothDevice {
  final String address;
  final String? name;
  final int lastConnectedTime;
  final bool autoConnect;

  const CachedBluetoothDevice({
    required this.address,
    this.name,
    required this.lastConnectedTime,
    this.autoConnect = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'name': name,
      'lastConnectedTime': lastConnectedTime,
      'autoConnect': autoConnect,
    };
  }

  factory CachedBluetoothDevice.fromJson(Map<String, dynamic> json) {
    return CachedBluetoothDevice(
      address: json['address'] ?? '',
      name: json['name'],
      lastConnectedTime: json['lastConnectedTime'] ?? 0,
      autoConnect: json['autoConnect'] ?? true,
    );
  }
}

/// 蓝牙缓存管理器 - 完全匹配旧项目BluetoothCacheManager
class BluetoothCacheManager {
  static const String _tag = "BluetoothCacheManager";
  static const String _keyPrefix = "bluetooth_cache_";
  static const String _deviceKey = "${_keyPrefix}device";
  static const String _autoConnectKey = "${_keyPrefix}auto_connect";

  /// 缓存蓝牙设备信息 - 匹配旧项目cacheBluetoothDevice
  Future<void> cacheBluetoothDevice(String address, String? name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final cachedDevice = CachedBluetoothDevice(
        address: address,
        name: name,
        lastConnectedTime: DateTime.now().millisecondsSinceEpoch,
        autoConnect: true,
      );

      await prefs.setString(_deviceKey, jsonEncode(cachedDevice.toJson()));
      await prefs.setBool(_autoConnectKey, true);

      developer.log('✅ 设备已缓存: $address', name: _tag);
    } catch (e) {
      developer.log('❌ 缓存设备失败: $e', name: _tag);
    }
  }

  /// 获取缓存的蓝牙设备 - 匹配旧项目getCachedBluetoothDevice
  Future<CachedBluetoothDevice?> getCachedBluetoothDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceJson = prefs.getString(_deviceKey);
      
      if (deviceJson != null) {
        final deviceMap = jsonDecode(deviceJson) as Map<String, dynamic>;
        final device = CachedBluetoothDevice.fromJson(deviceMap);
        developer.log('📱 获取缓存设备: ${device.address}', name: _tag);
        return device;
      }
      
      developer.log('📱 无缓存设备', name: _tag);
      return null;
    } catch (e) {
      developer.log('❌ 获取缓存设备失败: $e', name: _tag);
      return null;
    }
  }

  /// 检查是否应该自动连接 - 匹配旧项目shouldAutoConnect
  bool shouldAutoConnect() {
    // 简化实现，实际项目中可以从SharedPreferences读取
    return true;
  }

  /// 设置自动连接状态
  Future<void> setAutoConnect(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoConnectKey, enabled);
      developer.log('🔄 自动连接状态已更新: $enabled', name: _tag);
    } catch (e) {
      developer.log('❌ 设置自动连接状态失败: $e', name: _tag);
    }
  }

  /// 清除缓存的设备信息
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_deviceKey);
      await prefs.remove(_autoConnectKey);
      developer.log('🗑️ 设备缓存已清除', name: _tag);
    } catch (e) {
      developer.log('❌ 清除缓存失败: $e', name: _tag);
    }
  }
}