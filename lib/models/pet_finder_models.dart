// 寻宠功能数据模型

import 'package:pet_talk/widgets/standard_baidu_map_widget.dart';

/// 宠物位置数据模型
class PetLocationData {
  final String id;
  final String name;
  final String imageUrl;
  final StandardLatLng location;
  final String address;
  final DateTime lastUpdated;
  final int batteryLevel;
  final bool isOnline;

  const PetLocationData({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.location,
    required this.address,
    required this.lastUpdated,
    required this.batteryLevel,
    required this.isOnline,
  });

  /// 从JSON创建实例
  factory PetLocationData.fromJson(Map<String, dynamic> json) {
    return PetLocationData(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      location: StandardLatLng(
        json['latitude'] as double,
        json['longitude'] as double,
      ),
      address: json['address'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      batteryLevel: json['batteryLevel'] as int,
      isOnline: json['isOnline'] as bool,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'address': address,
      'lastUpdated': lastUpdated.toIso8601String(),
      'batteryLevel': batteryLevel,
      'isOnline': isOnline,
    };
  }
}

/// 用户位置数据模型
class UserLocationData {
  final StandardLatLng location;
  final String address;

  const UserLocationData({
    required this.location,
    required this.address,
  });
}

/// 导航路径数据模型
class NavigationRoute {
  final String id;
  final List<StandardLatLng> points;
  final double totalDistance; // 总距离（公里）
  final int estimatedTime; // 预计时间（分钟）
  final String routeType; // 路径类型：walking, driving, cycling
  final List<NavigationStep> steps; // 详细步骤列表

  const NavigationRoute({
    required this.id,
    required this.points,
    required this.totalDistance,
    required this.estimatedTime,
    required this.routeType,
    this.steps = const [],
  });

  factory NavigationRoute.fromJson(Map<String, dynamic> json) {
    return NavigationRoute(
      id: json['id'] as String,
      points: (json['points'] as List)
          .map((point) => StandardLatLng(
                point['latitude'] as double,
                point['longitude'] as double,
              ))
          .toList(),
      totalDistance: json['totalDistance'] as double,
      estimatedTime: json['estimatedTime'] as int,
      routeType: json['routeType'] as String,
      steps: (json['steps'] as List<dynamic>? ?? [])
          .map((e) => NavigationStep.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// 导航步骤（来自高德API的steps解析）
class NavigationStep {
  final String instruction; // 步骤指引文字
  final double distanceMeters; // 步骤距离（米）
  final int durationSeconds; // 预计耗时（秒）
  final List<StandardLatLng> points; // 该步骤的折线点

  const NavigationStep({
    required this.instruction,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.points,
  });

  factory NavigationStep.fromJson(Map<String, dynamic> json) {
    return NavigationStep(
      instruction: json['instruction'] as String? ?? '',
      distanceMeters: (json['distanceMeters'] as num? ?? 0).toDouble(),
      durationSeconds: (json['durationSeconds'] as num? ?? 0).toInt(),
      points: ((json['points'] as List<dynamic>? ?? [])
              .map((p) => StandardLatLng(
                    (p['latitude'] as num).toDouble(),
                    (p['longitude'] as num).toDouble(),
                  ))
              .toList()),
    );
  }

  Map<String, dynamic> toJson() => {
        'instruction': instruction,
        'distanceMeters': distanceMeters,
        'durationSeconds': durationSeconds,
        'points': points
            .map((e) => {
                  'latitude': e.latitude,
                  'longitude': e.longitude,
                })
            .toList(),
      };
}

/// 虚拟围栏简化模型（用于寻宠页面显示）
class VirtualFenceInfo {
  final String id;
  final String name;
  final StandardLatLng center;
  final double radius;
  final bool isActive;

  const VirtualFenceInfo({
    required this.id,
    required this.name,
    required this.center,
    required this.radius,
    required this.isActive,
  });

  factory VirtualFenceInfo.fromJson(Map<String, dynamic> json) {
    return VirtualFenceInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      center: StandardLatLng(
        json['centerLat'] as double,
        json['centerLng'] as double,
      ),
      radius: json['radius'] as double,
      isActive: json['isActive'] as bool,
    );
  }
}

/// 地图标记类型枚举
enum MarkerType {
  pet,
  user,
  fence,
}

/// 自定义地图标记模型
class CustomMarker {
  final String id;
  final StandardLatLng position;
  final MarkerType type;
  final String title;
  final String? subtitle;
  final String? imageUrl;

  const CustomMarker({
    required this.id,
    required this.position,
    required this.type,
    required this.title,
    this.subtitle,
    this.imageUrl,
  });
}

/// 寻宠API响应模型
class PetFinderResponse {
  final bool success;
  final PetLocationData? petData;
  final String? error;
  final DateTime timestamp;

  const PetFinderResponse({
    required this.success,
    this.petData,
    this.error,
    required this.timestamp,
  });

  factory PetFinderResponse.fromJson(Map<String, dynamic> json) {
    return PetFinderResponse(
      success: json['success'] as bool,
      petData: json['petData'] != null 
          ? PetLocationData.fromJson(json['petData'] as Map<String, dynamic>)
          : null,
      error: json['error'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}