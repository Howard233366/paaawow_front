// 电子围栏相关数据模型

import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 电子围栏类型
enum VirtualFenceType {
  safe,      // 安全区域
  restricted // 限制区域
}

/// 电子围栏形状
enum VirtualFenceShape {
  circle,    // 圆形
  polygon    // 多边形
}

/// 电子围栏状态
enum VirtualFenceStatus {
  active,    // 激活
  inactive,  // 未激活
  deleted    // 已删除
}

/// 电子围栏模型
class VirtualFence {
  final String id;
  final String name;
  final String? description;
  final VirtualFenceType type;
  final VirtualFenceShape shape;
  final VirtualFenceStatus status;
  final LatLng center;
  final double radius; // 圆形围栏的半径（米）
  final List<LatLng> polygonPoints; // 多边形围栏的顶点
  final String icon;
  final bool activateImmediately;
  final DateTime createdAt;
  final DateTime? updatedAt;

  VirtualFence({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.shape,
    required this.status,
    required this.center,
    required this.radius,
    required this.polygonPoints,
    required this.icon,
    required this.activateImmediately,
    required this.createdAt,
    this.updatedAt,
  });

  /// 从JSON创建VirtualFence对象
  factory VirtualFence.fromJson(Map<String, dynamic> json) {
    return VirtualFence(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      type: VirtualFenceType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => VirtualFenceType.safe,
      ),
      shape: VirtualFenceShape.values.firstWhere(
        (e) => e.toString().split('.').last == json['shape'],
        orElse: () => VirtualFenceShape.circle,
      ),
      status: VirtualFenceStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => VirtualFenceStatus.active,
      ),
      center: LatLng(
        json['center']['latitude'] ?? 0.0,
        json['center']['longitude'] ?? 0.0,
      ),
      radius: (json['radius'] ?? 100.0).toDouble(),
      polygonPoints: (json['polygonPoints'] as List<dynamic>?)
          ?.map((point) => LatLng(point['latitude'], point['longitude']))
          .toList() ?? [],
      icon: json['icon'] ?? '🏠',
      activateImmediately: json['activateImmediately'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
      'shape': shape.toString().split('.').last,
      'status': status.toString().split('.').last,
      'center': {
        'latitude': center.latitude,
        'longitude': center.longitude,
      },
      'radius': radius,
      'polygonPoints': polygonPoints.map((point) => {
        'latitude': point.latitude,
        'longitude': point.longitude,
      }).toList(),
      'icon': icon,
      'activateImmediately': activateImmediately,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// 复制并修改部分属性
  VirtualFence copyWith({
    String? id,
    String? name,
    String? description,
    VirtualFenceType? type,
    VirtualFenceShape? shape,
    VirtualFenceStatus? status,
    LatLng? center,
    double? radius,
    List<LatLng>? polygonPoints,
    String? icon,
    bool? activateImmediately,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VirtualFence(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      shape: shape ?? this.shape,
      status: status ?? this.status,
      center: center ?? this.center,
      radius: radius ?? this.radius,
      polygonPoints: polygonPoints ?? this.polygonPoints,
      icon: icon ?? this.icon,
      activateImmediately: activateImmediately ?? this.activateImmediately,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 围栏设置流程状态
enum FenceSetupStep {
  welcome,        // 欢迎页面
  lookingForPet,  // 寻找宠物页面
  selectArea,     // 选择区域
  configFence     // 配置围栏
}

/// 围栏设置状态
class FenceSetupState {
  final FenceSetupStep currentStep;
  final LatLng? selectedLocation;
  final double selectedRadius;
  final String fenceName;
  final String selectedIcon;
  final bool activateImmediately;
  final List<VirtualFence> existingFences;

  FenceSetupState({
    required this.currentStep,
    this.selectedLocation,
    this.selectedRadius = 100.0,
    this.fenceName = '',
    this.selectedIcon = '🏠',
    this.activateImmediately = false,
    this.existingFences = const [],
  });

  FenceSetupState copyWith({
    FenceSetupStep? currentStep,
    LatLng? selectedLocation,
    double? selectedRadius,
    String? fenceName,
    String? selectedIcon,
    bool? activateImmediately,
    List<VirtualFence>? existingFences,
  }) {
    return FenceSetupState(
      currentStep: currentStep ?? this.currentStep,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      selectedRadius: selectedRadius ?? this.selectedRadius,
      fenceName: fenceName ?? this.fenceName,
      selectedIcon: selectedIcon ?? this.selectedIcon,
      activateImmediately: activateImmediately ?? this.activateImmediately,
      existingFences: existingFences ?? this.existingFences,
    );
  }
}

/// 宠物位置信息
class PetLocation {
  final String petId;
  final String petName;
  final LatLng location;
  final DateTime timestamp;
  final double accuracy; // 位置精度（米）
  final bool isInSafeZone;

  PetLocation({
    required this.petId,
    required this.petName,
    required this.location,
    required this.timestamp,
    required this.accuracy,
    required this.isInSafeZone,
  });

  factory PetLocation.fromJson(Map<String, dynamic> json) {
    return PetLocation(
      petId: json['petId'] ?? '',
      petName: json['petName'] ?? '',
      location: LatLng(
        json['location']['latitude'] ?? 0.0,
        json['location']['longitude'] ?? 0.0,
      ),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      accuracy: (json['accuracy'] ?? 10.0).toDouble(),
      isInSafeZone: json['isInSafeZone'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'petId': petId,
      'petName': petName,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'timestamp': timestamp.toIso8601String(),
      'accuracy': accuracy,
      'isInSafeZone': isInSafeZone,
    };
  }
}