// Bluetooth and device related data models
// 🔵 PetTalk 蓝牙协议数据模型 - 完全匹配旧Android项目
// 严格按照BluetoothProtocolModels.kt逐行复刻所有数据结构

import 'dart:typed_data';
import 'dart:convert';

/// 蓝牙协议命令枚举 - 完全匹配旧项目
enum BluetoothCommand {
  // 时间同步协议 (0x10)
  timeSet(0x10, "Set Time"), // 设置时间
  timeGet(0x10, "Get Time"), // 获取时间
  
  // WiFi配置协议 (0x13)
  wifiSet(0x13, "Set WiFi"), // 设置WiFi
  wifiGet(0x13, "Get WiFi"), // 获取WiFi
  
  // 设备信息协议 (0x21)
  deviceInfoGet(0x21, "Get Device Info"), // 获取设备信息
  
  // 电量信息协议 (0x22)
  batteryGet(0x22, "Get Battery"), // 获取电量
  
  // 宝石信息协议 (0x23)
  gemDataGet(0x23, "Get Gem Data"), // 获取宝石数据
  
  // 模式控制协议 (0x24)
  modelSet(0x24, "Set Mode"), // 设置模式
  modelGet(0x24, "Get Mode"), // 获取模式
  
  // 动作数据协议 (0x25)
  activityDataGet(0x25, "Get Activity Data"), // 获取动作数据
  
  // 本地数据协议 (0x30)
  localDataGet(0x30, "Get Local Data"), // 获取本地数据
  
  // 音频数据协议 (0x40)
  microphoneDataStart(0x40, "Start Recording"), // 开始录音
  microphoneDataStop(0x40, "Stop Recording"), // 停止录音
  
  // 训宠功能协议 (0x41)
  trainPetStart(0x41, "Start Pet Training"), // 开始训宠
  trainPetStop(0x41, "Stop Pet Training"); // 停止训宠

  const BluetoothCommand(this.code, this.description);
  
  final int code;
  final String description;
}

/// 蓝牙协议数据包 - 完全匹配旧项目
class BluetoothPacket {
  final BluetoothCommand command;
  final int subCommand; // 0=SET, 1=GET
  final Uint8List data;
  final bool isStreamData;

  const BluetoothPacket({
    required this.command,
    this.subCommand = 0,
    required this.data,
    this.isStreamData = false,
  });

  /// 转换为发送的字节数组 - 匹配旧项目逻辑
  Uint8List toByteArray() {
    final buffer = ByteData(4 + data.length);
    
    // 协议头：00 00 [命令码] [子命令] - 使用小端序
    buffer.setUint8(0, 0x00);
    buffer.setUint8(1, 0x00);
    buffer.setUint8(2, command.code);
    buffer.setUint8(3, subCommand);
    
    // 数据部分
    for (int i = 0; i < data.length; i++) {
      buffer.setUint8(4 + i, data[i]);
    }
    
    return buffer.buffer.asUint8List();
  }

  /// 从字节数组创建数据包
  factory BluetoothPacket.fromByteArray(Uint8List bytes) {
    if (bytes.length < 4) {
      throw ArgumentError('Invalid packet length');
    }
    
    final buffer = ByteData.sublistView(bytes);
    final commandCode = buffer.getUint8(2);
    final subCommand = buffer.getUint8(3);
    final data = bytes.sublist(4);
    
    // 查找匹配的命令
    final command = BluetoothCommand.values.firstWhere(
      (cmd) => cmd.code == commandCode,
      orElse: () => BluetoothCommand.deviceInfoGet,
    );
    
    return BluetoothPacket(
      command: command,
      subCommand: subCommand,
      data: data,
    );
  }

  // Factory methods for common commands - 匹配旧项目
  factory BluetoothPacket.timeSet(DateTime time) {
    final timeData = ByteData(8);
    timeData.setInt64(0, time.millisecondsSinceEpoch ~/ 1000, Endian.little);
    return BluetoothPacket(
      command: BluetoothCommand.timeSet,
      subCommand: 0,
      data: timeData.buffer.asUint8List(),
    );
  }

  factory BluetoothPacket.batteryGet() {
    return BluetoothPacket(
      command: BluetoothCommand.batteryGet,
      subCommand: 1,
      data: Uint8List(0),
    );
  }

  factory BluetoothPacket.deviceInfoGet() {
    return BluetoothPacket(
      command: BluetoothCommand.deviceInfoGet,
      subCommand: 1,
      data: Uint8List(0),
    );
  }

  factory BluetoothPacket.gemDataGet() {
    return BluetoothPacket(
      command: BluetoothCommand.gemDataGet,
      subCommand: 1,
      data: Uint8List(0),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BluetoothPacket &&
          runtimeType == other.runtimeType &&
          command == other.command &&
          subCommand == other.subCommand &&
          _listEquals(data, other.data) &&
          isStreamData == other.isStreamData;

  @override
  int get hashCode =>
      command.hashCode ^
      subCommand.hashCode ^
      data.hashCode ^
      isStreamData.hashCode;

  static bool _listEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

enum BluetoothConnectionState {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error;

  String get displayName {
    switch (this) {
      case BluetoothConnectionState.disconnected:
        return 'Disconnected'; // 未连接
      case BluetoothConnectionState.connecting:
        return 'Connecting'; // 连接中
      case BluetoothConnectionState.connected:
        return 'Connected'; // 已连接
      case BluetoothConnectionState.disconnecting:
        return 'Disconnecting'; // 断开中
      case BluetoothConnectionState.error:
        return 'Connection Error'; // 连接错误
    }
  }
}

class BluetoothDevice {
  final String name;
  final String address;
  final bool isConnected;
  final int? rssi;

  const BluetoothDevice({
    required this.name,
    required this.address,
    required this.isConnected,
    this.rssi,
  });

  factory BluetoothDevice.fromJson(Map<String, dynamic> json) {
    return BluetoothDevice(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      isConnected: json['isConnected'] ?? false,
      rssi: json['rssi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'isConnected': isConnected,
      'rssi': rssi,
    };
  }
}

class WiFiNetwork {
  final String ssid;
  final bool isSecured;
  final int signalStrength;
  final bool isConnected;

  const WiFiNetwork({
    required this.ssid,
    required this.isSecured,
    required this.signalStrength,
    this.isConnected = false,
  });

  factory WiFiNetwork.fromJson(Map<String, dynamic> json) {
    return WiFiNetwork(
      ssid: json['ssid'] ?? '',
      isSecured: json['isSecured'] ?? false,
      signalStrength: json['signalStrength'] ?? 0,
      isConnected: json['isConnected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ssid': ssid,
      'isSecured': isSecured,
      'signalStrength': signalStrength,
      'isConnected': isConnected,
    };
  }
}

class NetworkConfig {
  final String wifiSSID;
  final String wifiPassword;
  final String collarId;

  const NetworkConfig({
    required this.wifiSSID,
    required this.wifiPassword,
    required this.collarId,
  });

  factory NetworkConfig.fromJson(Map<String, dynamic> json) {
    return NetworkConfig(
      wifiSSID: json['wifiSSID'] ?? '',
      wifiPassword: json['wifiPassword'] ?? '',
      collarId: json['collarId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wifiSSID': wifiSSID,
      'wifiPassword': wifiPassword,
      'collarId': collarId,
    };
  }
}

enum PowerMode {
  performance,
  battery,
  energySaving,
  balanced;

  String get displayName {
    switch (this) {
      case PowerMode.performance:
        return 'Performance Mode'; // 性能模式
      case PowerMode.battery:
        return 'Battery Mode'; // 续航模式
      case PowerMode.energySaving:
        return 'Energy Saving Mode'; // 节能模式
      case PowerMode.balanced:
        return 'Balanced Mode'; // 平衡模式
    }
  }
}

enum GemType {
  none,
  barometer,
  accelerometer,
  gyroscope,
  magnetometer;

  String get displayName {
    switch (this) {
      case GemType.none:
        return 'No Function Module'; // 无功能模块
      case GemType.barometer:
        return 'Barometer Module'; // 气压计模块
      case GemType.accelerometer:
        return 'Accelerometer Module'; // 加速计模块
      case GemType.gyroscope:
        return 'Gyroscope Module'; // 陀螺仪模块
      case GemType.magnetometer:
        return 'Magnetometer Module'; // 磁力计模块
    }
  }
}

class CollarGem {
  final int position;
  final bool isConnected;
  final bool isRecognized;
  final GemType type;
  final String version;

  const CollarGem({
    required this.position,
    required this.isConnected,
    required this.isRecognized,
    required this.type,
    required this.version,
  });

  factory CollarGem.fromJson(Map<String, dynamic> json) {
    return CollarGem(
      position: json['position'] ?? 0,
      isConnected: json['isConnected'] ?? false,
      isRecognized: json['isRecognized'] ?? false,
      type: GemType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => GemType.none,
      ),
      version: json['version'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'isConnected': isConnected,
      'isRecognized': isRecognized,
      'type': type.name,
      'version': version,
    };
  }
}

class SafeWifiNetwork {
  final String ssid;
  final bool isConnected;
  final int signalStrength;
  final String? address;

  const SafeWifiNetwork({
    required this.ssid,
    required this.isConnected,
    required this.signalStrength,
    this.address,
  });

  factory SafeWifiNetwork.fromJson(Map<String, dynamic> json) {
    return SafeWifiNetwork(
      ssid: json['ssid'] ?? '',
      isConnected: json['isConnected'] ?? false,
      signalStrength: json['signalStrength'] ?? 0,
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ssid': ssid,
      'isConnected': isConnected,
      'signalStrength': signalStrength,
      'address': address,
    };
  }
}

class Location {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;
  final int timestamp;

  const Location({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    required this.timestamp,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      altitude: json['altitude']?.toDouble(),
      accuracy: json['accuracy']?.toDouble(),
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'accuracy': accuracy,
      'timestamp': timestamp,
    };
  }
}

class PetCollar {
  final String id;
  final String petId;
  final String name;
  final int batteryLevel;
  final bool isOnline;
  final bool wifiConnected;
  final bool bluetoothConnected;
  final String firmwareVersion;
  final int lastSyncTime;
  final Location? location;
  final double? temperature;
  final int steps;
  final int? heartRate;
  final List<CollarGem> gems;
  final PowerMode powerMode;
  final bool isInSafeZone;
  final List<SafeWifiNetwork> connectedWifiNetworks;

  const PetCollar({
    required this.id,
    required this.petId,
    required this.name,
    required this.batteryLevel,
    required this.isOnline,
    required this.wifiConnected,
    required this.bluetoothConnected,
    required this.firmwareVersion,
    required this.lastSyncTime,
    this.location,
    this.temperature,
    this.steps = 0,
    this.heartRate,
    this.gems = const [],
    this.powerMode = PowerMode.performance,
    this.isInSafeZone = false,
    this.connectedWifiNetworks = const [],
  });

  factory PetCollar.fromJson(Map<String, dynamic> json) {
    return PetCollar(
      id: json['id'] ?? '',
      petId: json['petId'] ?? '',
      name: json['name'] ?? '',
      batteryLevel: json['batteryLevel'] ?? 0,
      isOnline: json['isOnline'] ?? false,
      wifiConnected: json['wifiConnected'] ?? false,
      bluetoothConnected: json['bluetoothConnected'] ?? false,
      firmwareVersion: json['firmwareVersion'] ?? '',
      lastSyncTime: json['lastSyncTime'] ?? 0,
      location: json['location'] != null 
          ? Location.fromJson(json['location'])
          : null,
      temperature: json['temperature']?.toDouble(),
      steps: json['steps'] ?? 0,
      heartRate: json['heartRate'],
      gems: (json['gems'] as List<dynamic>?)
              ?.map((e) => CollarGem.fromJson(e))
              .toList() ??
          [],
      powerMode: PowerMode.values.firstWhere(
        (e) => e.name == json['powerMode'],
        orElse: () => PowerMode.performance,
      ),
      isInSafeZone: json['isInSafeZone'] ?? false,
      connectedWifiNetworks: (json['connectedWifiNetworks'] as List<dynamic>?)
              ?.map((e) => SafeWifiNetwork.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'name': name,
      'batteryLevel': batteryLevel,
      'isOnline': isOnline,
      'wifiConnected': wifiConnected,
      'bluetoothConnected': bluetoothConnected,
      'firmwareVersion': firmwareVersion,
      'lastSyncTime': lastSyncTime,
      'location': location?.toJson(),
      'temperature': temperature,
      'steps': steps,
      'heartRate': heartRate,
      'gems': gems.map((e) => e.toJson()).toList(),
      'powerMode': powerMode.name,
      'isInSafeZone': isInSafeZone,
      'connectedWifiNetworks': connectedWifiNetworks.map((e) => e.toJson()).toList(),
    };
  }

  PetCollar copyWith({
    String? id,
    String? petId,
    String? name,
    int? batteryLevel,
    bool? isOnline,
    bool? wifiConnected,
    bool? bluetoothConnected,
    String? firmwareVersion,
    int? lastSyncTime,
    Location? location,
    double? temperature,
    int? steps,
    int? heartRate,
    List<CollarGem>? gems,
    PowerMode? powerMode,
    bool? isInSafeZone,
    List<SafeWifiNetwork>? connectedWifiNetworks,
  }) {
    return PetCollar(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      name: name ?? this.name,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      isOnline: isOnline ?? this.isOnline,
      wifiConnected: wifiConnected ?? this.wifiConnected,
      bluetoothConnected: bluetoothConnected ?? this.bluetoothConnected,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      location: location ?? this.location,
      temperature: temperature ?? this.temperature,
      steps: steps ?? this.steps,
      heartRate: heartRate ?? this.heartRate,
      gems: gems ?? this.gems,
      powerMode: powerMode ?? this.powerMode,
      isInSafeZone: isInSafeZone ?? this.isInSafeZone,
      connectedWifiNetworks: connectedWifiNetworks ?? this.connectedWifiNetworks,
    );
  }
}

// ==================== 时间同步相关 - 匹配旧项目 ====================

/// 时间数据 - 完全匹配旧项目TimeData
class TimeData {
  final int timestamp; // Unix时间戳
  final String timezone; // 时区，默认东八区

  const TimeData({
    required this.timestamp,
    this.timezone = "+8",
  });

  /// 转换为字节数组 - 匹配旧项目toByteArray()
  Uint8List toByteArray() {
    final buffer = ByteData(10);
    
    // 4字节填充
    buffer.setInt32(0, 0, Endian.little);
    // 4字节时间戳
    buffer.setInt32(4, timestamp, Endian.little);
    // 2字节时区 (ASCII码)
    buffer.setUint8(8, timezone.codeUnitAt(0)); // '+'
    buffer.setUint8(9, timezone.codeUnitAt(1)); // '8'
    
    return buffer.buffer.asUint8List();
  }

  /// 从字节数组创建 - 匹配旧项目fromByteArray
  static TimeData? fromByteArray(Uint8List data) {
    if (data.length < 10) return null;
    
    final buffer = ByteData.sublistView(data);
    
    // 跳过4字节填充
    // 读取时间戳
    final timestamp = buffer.getInt32(4, Endian.little);
    // 读取时区
    final tz1 = String.fromCharCode(buffer.getUint8(8));
    final tz2 = String.fromCharCode(buffer.getUint8(9));
    final timezone = tz1 + tz2;
    
    return TimeData(timestamp: timestamp, timezone: timezone);
  }
}

// ==================== WiFi配置相关 - 匹配旧项目 ====================

/// WiFi配置数据 - 完全匹配旧项目WiFiConfig
class WiFiConfig {
  final String ssid;
  final String password;

  const WiFiConfig({
    required this.ssid,
    required this.password,
  });

  /// 转换为JSON字节数组 - 匹配旧项目toJsonByteArray()
  Uint8List toJsonByteArray() {
    final json = '{"ssid":"$ssid","password":"$password"}';
    return Uint8List.fromList(utf8.encode(json));
  }

  /// 从JSON字节数组创建 - 匹配旧项目fromJsonByteArray
  static WiFiConfig? fromJsonByteArray(Uint8List data) {
    try {
      final json = utf8.decode(data);
      // 简单的JSON解析
      final ssidStart = json.indexOf('"ssid":"') + 8;
      final ssidEnd = json.indexOf('"', ssidStart);
      final passwordStart = json.indexOf('"password":"') + 12;
      final passwordEnd = json.indexOf('"', passwordStart);
      
      if (ssidStart > 7 && ssidEnd > ssidStart && 
          passwordStart > 11 && passwordEnd > passwordStart) {
        return WiFiConfig(
          ssid: json.substring(ssidStart, ssidEnd),
          password: json.substring(passwordStart, passwordEnd),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

/// WiFi配置响应数据 - 完全匹配旧项目WiFiConfigResponse
/// 根据协议规范：{"ssid":"test","isAvailable":"1","isConnected":"1"}
class WiFiConfigResponse {
  final String ssid;
  final bool isAvailable; // 是否在范围内
  final bool isConnected; // 是否处于连接状态

  const WiFiConfigResponse({
    required this.ssid,
    required this.isAvailable,
    required this.isConnected,
  });

  /// 从JSON字符串创建 - 匹配旧项目fromJsonString
  static WiFiConfigResponse? fromJsonString(String json) {
    try {
      // 简单的JSON解析，避免依赖外部库
      final ssidPattern = RegExp(r'"ssid"\s*:\s*"([^"]+)"');
      final isAvailablePattern = RegExp(r'"isAvailable"\s*:\s*"([^"]+)"');
      final isConnectedPattern = RegExp(r'"isConnected"\s*:\s*"([^"]+)"');
      
      final ssidMatch = ssidPattern.firstMatch(json);
      final isAvailableMatch = isAvailablePattern.firstMatch(json);
      final isConnectedMatch = isConnectedPattern.firstMatch(json);
      
      if (ssidMatch != null && isAvailableMatch != null && isConnectedMatch != null) {
        final ssid = ssidMatch.group(1)!;
        final isAvailable = isAvailableMatch.group(1) == "1";
        final isConnected = isConnectedMatch.group(1) == "1";
        
        return WiFiConfigResponse(
          ssid: ssid, 
          isAvailable: isAvailable, 
          isConnected: isConnected
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

// ==================== 设备信息相关 - 匹配旧项目 ====================

/// 设备信息 - 完全匹配旧项目DeviceInfo
class DeviceInfo {
  final String deviceId;
  final String version;

  const DeviceInfo({
    required this.deviceId,
    required this.version,
  });
}

// ==================== 电量信息相关 - 匹配旧项目 ====================

/// 电量信息 - 完全匹配旧项目BatteryInfo
class BatteryInfo {
  final int level; // 0-100

  const BatteryInfo({required this.level});

  /// 从字节数组创建 - 匹配旧项目fromByteArray
  static BatteryInfo? fromByteArray(Uint8List data) {
    if (data.isEmpty) return null;
    // 协议：00(0%) - 64(100%)，转换为0-100
    final rawLevel = data[0];
    final percentage = (rawLevel * 100) ~/ 100; // 假设0x64=100对应100%
    return BatteryInfo(level: percentage.clamp(0, 100));
  }
}

// ==================== 宝石信息相关 - 匹配旧项目 ====================

/// 宝石功能模块 - 完全匹配旧项目GemFunctionModule
enum GemFunctionModule {
  none(0x00, "No Function Module"), // 无功能模块
  barometer(0x01, "Barometer Module"); // 气压计模块

  const GemFunctionModule(this.code, this.description);
  final int code;
  final String description;
}

/// 宝石状态信息 - 完全匹配旧项目GemStatus
class GemStatus {
  final int position; // 0-3
  final bool isConnected;
  final bool isRecognized;
  final GemFunctionModule functionModule;
  final int gemVersion;

  const GemStatus({
    required this.position,
    required this.isConnected,
    required this.isRecognized,
    required this.functionModule,
    required this.gemVersion,
  });

  /// 从两个字节创建 - 完全匹配旧项目fromTwoBytes
  static GemStatus fromTwoBytes(int position, int byte1, int byte2) {
    // 解析16位数据
    final data = (byte1 << 8) | byte2;
    
    // 最高位：连接状态
    final isConnected = (data & 0x8000) != 0;
    // 第二位：识别状态  
    final isRecognized = (data & 0x4000) != 0;
    // 第3-8位：功能模块
    final functionBits = (data & 0x3F00) >> 8;
    final functionModule = functionBits == 0x01 
        ? GemFunctionModule.barometer 
        : GemFunctionModule.none;
    // 剩余位：宝石版本
    final gemVersion = data & 0xFF;
    
    return GemStatus(
      position: position,
      isConnected: isConnected,
      isRecognized: isRecognized,
      functionModule: functionModule,
      gemVersion: gemVersion,
    );
  }
}

/// 所有宝石状态 - 完全匹配旧项目AllGemsStatus
class AllGemsStatus {
  final List<GemStatus> gems;

  const AllGemsStatus({required this.gems});

  /// 从字节数组创建 - 匹配旧项目fromByteArray
  static AllGemsStatus? fromByteArray(Uint8List data) {
    if (data.length < 8) return null; // 4个宝石，每个2字节
    
    final gems = <GemStatus>[];
    for (int i = 0; i < 4; i++) {
      final byte1 = data[i * 2];
      final byte2 = data[i * 2 + 1];
      gems.add(GemStatus.fromTwoBytes(i, byte1, byte2));
    }
    
    return AllGemsStatus(gems: gems);
  }
}

// ==================== 模式控制相关 - 匹配旧项目 ====================

/// 基础模式类型 - 完全匹配旧项目BaseMode
enum BaseMode {
  homeNormal(0x00, "Home Normal State"), // 在家默认状态
  homeSleep(0x01, "Sleep State"), // 休眠状态
  homeSuspectedLost(0x04, "Suspected Lost State"), // 疑似丢失状态
  homeLost(0x05, "Lost State"), // 丢失状态
  homeGpsRefuse(0x06, "GPS Denied State"); // GPS拒止状态

  const BaseMode(this.code, this.description);
  final int code;
  final String description;

  /// 从代码获取模式 - 匹配旧项目fromCode
  static BaseMode fromCode(int code) {
    return BaseMode.values.firstWhere(
      (mode) => mode.code == code,
      orElse: () => BaseMode.homeNormal,
    );
  }
}

/// 设备模式 - 完全匹配旧项目DeviceMode
class DeviceMode {
  final int modeCode;
  final bool isHighPerformance;
  final BaseMode baseMode;

  const DeviceMode({
    required this.modeCode,
    required this.isHighPerformance,
    required this.baseMode,
  });

  /// 从字节创建 - 匹配旧项目fromByte
  static DeviceMode fromByte(int modeByte) {
    final isHighPerformance = (modeByte & 0xF0) == 0x00;
    final baseCode = modeByte & 0x0F;
    final baseMode = BaseMode.fromCode(baseCode);
    
    return DeviceMode(
      modeCode: modeByte,
      isHighPerformance: isHighPerformance,
      baseMode: baseMode,
    );
  }

  /// 创建设备模式 - 匹配旧项目create
  static DeviceMode create(BaseMode baseMode, bool isHighPerformance) {
    final modeCode = isHighPerformance 
        ? baseMode.code 
        : 0x30 | baseMode.code;
    return DeviceMode(
      modeCode: modeCode,
      isHighPerformance: isHighPerformance,
      baseMode: baseMode,
    );
  }

  /// 转换为字节数组 - 匹配旧项目toByteArray
  Uint8List toByteArray() => Uint8List.fromList([modeCode]);
}

// ==================== 动作数据相关 - 匹配旧项目 ====================

/// 动作类型 - 完全匹配旧项目ActivityType
enum ActivityType {
  rest(0x00, "Rest"), // 休息
  walk(0x01, "Walk"), // 走路
  eat(0x02, "Eat"), // 进食
  run(0x03, "Run"), // 跑步
  jump(0x04, "Jump"), // 跳跃
  bark(0x05, "Bark"), // 狂吠
  lick(0x06, "Lick"), // 舔毛
  scratch(0x07, "Scratch"); // 搔抓

  const ActivityType(this.code, this.description);
  final int code;
  final String description;

  /// 从代码获取动作 - 匹配旧项目fromCode
  static ActivityType fromCode(int code) {
    return ActivityType.values.firstWhere(
      (activity) => activity.code == code,
      orElse: () => ActivityType.rest,
    );
  }
}

/// 宠物当前动作 - 完全匹配旧项目PetCurrentActivity
class PetCurrentActivity {
  final int actionCode;
  final ActivityType activityType;

  const PetCurrentActivity({
    required this.actionCode,
    required this.activityType,
  });
}

/// 动作数据 - 完全匹配旧项目ActivityData
class ActivityData {
  final List<ActivityType> activities;

  const ActivityData({required this.activities});

  /// 从字节数组创建 - 匹配旧项目fromByteArray
  static ActivityData fromByteArray(Uint8List data) {
    final activities = <ActivityType>[];
    
    for (final byte in data) {
      // 每个字节包含2个动作（每个动作4位）
      final activity1 = ActivityType.fromCode((byte & 0xF0) >> 4);
      final activity2 = ActivityType.fromCode(byte & 0x0F);
      activities.add(activity1);
      activities.add(activity2);
    }
    
    return ActivityData(activities: activities);
  }

  /// 从单字节创建 - 匹配旧项目fromSingleByte
  static ActivityData fromSingleByte(Uint8List data) {
    if (data.isNotEmpty) {
      final activityCode = data[0];
      return ActivityData(activities: [ActivityType.fromCode(activityCode)]);
    } else {
      return const ActivityData(activities: []);
    }
  }
}

// ==================== 流式数据相关 - 匹配旧项目 ====================

/// 流式数据类型 - 完全匹配旧项目StreamDataType
enum StreamDataType {
  localData,    // 本地历史数据
  audioData,    // 音频数据
  trainAudio    // 训宠音频数据
}

/// 流式数据包 - 完全匹配旧项目StreamDataPacket
class StreamDataPacket {
  final StreamDataType type;
  final Uint8List data;
  final bool isComplete;
  final int timestamp;

  const StreamDataPacket({
    required this.type,
    required this.data,
    this.isComplete = false,
    int? timestamp,
  }) : timestamp = timestamp ?? 0; // DateTime.now().millisecondsSinceEpoch

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreamDataPacket &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          _listEquals(data, other.data) &&
          isComplete == other.isComplete &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      type.hashCode ^
      data.hashCode ^
      isComplete.hashCode ^
      timestamp.hashCode;

  static bool _listEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// 音频分割标识符 - 完全匹配旧项目AudioSeparator
class AudioSeparator {
  static final Uint8List separatorBytes = Uint8List.fromList([0x01, 0x02, 0x03, 0x04]);
  
  /// 检查是否为音频分割符 - 匹配旧项目isAudioSeparator
  static bool isAudioSeparator(Uint8List data, {int offset = 0}) {
    if (data.length < offset + 4) return false;
    final slice = data.sublist(offset, offset + 4);
    return _listEquals(slice, separatorBytes);
  }

  static bool _listEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

// ==================== 响应结果相关 - 匹配旧项目 ====================

/// 蓝牙操作结果 - 完全匹配旧项目BluetoothResult<out T>
abstract class BluetoothResult<T> {
  const BluetoothResult();
}

class BluetoothSuccess<T> extends BluetoothResult<T> {
  final T data;
  const BluetoothSuccess(this.data);
}

class BluetoothError<T> extends BluetoothResult<T> {
  final String message;
  final Object? exception;
  const BluetoothError(this.message, [this.exception]);
}

class BluetoothLoading<T> extends BluetoothResult<T> {
  const BluetoothLoading();
}

/// 蓝牙操作回调接口 - 完全匹配旧项目BluetoothOperationCallback<T>
abstract class BluetoothOperationCallback<T> {
  void onSuccess(T result);
  void onError(String message, [Object? exception]);
  void onProgress(int progress); // 用于流式数据传输进度
}

/// 流式数据回调接口 - 完全匹配旧项目StreamDataCallback
abstract class StreamDataCallback {
  void onDataReceived(StreamDataPacket packet);
  void onStreamComplete(StreamDataType type);
  void onStreamError(StreamDataType type, String error);
}

/// 蓝牙协议解析结果 - 完全匹配旧项目BluetoothParseResult
class BluetoothParseResult {
  final BluetoothCommand command;
  final dynamic data;
  final bool isSuccess;
  final String? errorMessage;

  const BluetoothParseResult({
    required this.command,
    this.data,
    required this.isSuccess,
    this.errorMessage,
  });
}