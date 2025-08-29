// 真实定位服务
// 负责获取用户的真实GPS位置信息

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pet_talk/widgets/standard_baidu_map_widget.dart';
import 'package:pet_talk/utils/coordinate_converter.dart';

/// 定位服务状态枚举
enum LocationServiceStatus {
  /// 定位成功
  success,
  /// 权限被拒绝
  permissionDenied,
  /// 权限被永久拒绝
  permissionDeniedForever,
  /// 定位服务未开启
  serviceDisabled,
  /// 定位超时
  timeout,
  /// 其他错误
  error,
}

/// 定位结果数据类
class LocationResult {
  /// 定位状态
  final LocationServiceStatus status;
  /// 位置坐标（成功时有值）
  final StandardLatLng? position;
  /// 错误信息（失败时有值）
  final String? errorMessage;
  /// 位置精度（米）
  final double? accuracy;
  /// 位置获取时间
  final DateTime timestamp;

  const LocationResult({
    required this.status,
    this.position,
    this.errorMessage,
    this.accuracy,
    required this.timestamp,
  });

  /// 是否定位成功
  bool get isSuccess => status == LocationServiceStatus.success && position != null;

  /// 创建成功结果
  factory LocationResult.success(StandardLatLng position, double accuracy) {
    return LocationResult(
      status: LocationServiceStatus.success,
      position: position,
      accuracy: accuracy,
      timestamp: DateTime.now(),
    );
  }

  /// 创建失败结果
  factory LocationResult.error(LocationServiceStatus status, String message) {
    return LocationResult(
      status: status,
      errorMessage: message,
      timestamp: DateTime.now(),
    );
  }
}

/// 真实定位服务
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// 获取当前位置
  /// [timeout] 超时时间，默认15秒
  /// [highAccuracy] 是否使用高精度定位，默认true
  /// 返回定位结果
  Future<LocationResult> getCurrentLocation({
    Duration timeout = const Duration(seconds: 15),
    bool highAccuracy = true,
  }) async {
    try {
      debugPrint('📍 开始获取当前位置...');

      // 1. 检查定位服务是否可用
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('📍 定位服务未开启');
        return LocationResult.error(
          LocationServiceStatus.serviceDisabled,
          '定位服务未开启，请在设置中开启位置服务',
        );
      }

      // 2. 检查和请求权限
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('📍 当前定位权限状态: $permission');

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint('📍 权限请求结果: $permission');
      }

      if (permission == LocationPermission.denied) {
        debugPrint('📍 定位权限被拒绝');
        return LocationResult.error(
          LocationServiceStatus.permissionDenied,
          '定位权限被拒绝，无法获取位置信息',
        );
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('📍 定位权限被永久拒绝');
        return LocationResult.error(
          LocationServiceStatus.permissionDeniedForever,
          '定位权限被永久拒绝，请在设置中手动开启位置权限',
        );
      }

      // 3. 配置定位参数已在getCurrentPosition中直接设置

      // 4. 获取位置
      debugPrint('📍 正在获取GPS位置...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: highAccuracy ? LocationAccuracy.high : LocationAccuracy.medium,
      ).timeout(
        timeout,
        onTimeout: () {
          throw Exception('定位超时');
        },
      );

      debugPrint('📍 定位成功 (WGS84): ${position.latitude}, ${position.longitude}');
      debugPrint('📍 定位精度: ${position.accuracy}米');

      // 5. 坐标系转换：WGS84 → BD09ll（百度地图坐标系）
      final wgs84Coord = StandardLatLng(position.latitude, position.longitude);
      final bd09llCoord = CoordinateConverter.wgs84ToBd09ll(wgs84Coord);
      
      debugPrint('📍 坐标转换完成 (BD09ll): ${bd09llCoord.latitude}, ${bd09llCoord.longitude}');

      // 6. 返回转换后的百度坐标系结果
      return LocationResult.success(
        bd09llCoord,
        position.accuracy,
      );

    } catch (e) {
      debugPrint('📍 定位失败: $e');
      
      // 根据错误类型返回不同状态
      if (e.toString().contains('timeout') || e.toString().contains('超时')) {
        return LocationResult.error(
          LocationServiceStatus.timeout,
          '定位超时，请检查网络连接和GPS信号',
        );
      } else {
        return LocationResult.error(
          LocationServiceStatus.error,
          '定位失败: ${e.toString()}',
        );
      }
    }
  }

  /// 获取最后已知位置
  /// 返回设备缓存的最后一次定位结果，速度更快但可能不是最新位置
  Future<LocationResult> getLastKnownLocation() async {
    try {
      debugPrint('📍 获取最后已知位置...');
      
      Position? position = await Geolocator.getLastKnownPosition();
      
      if (position != null) {
        debugPrint('📍 最后已知位置 (WGS84): ${position.latitude}, ${position.longitude}');
        
        // 坐标系转换：WGS84 → BD09ll
        final wgs84Coord = StandardLatLng(position.latitude, position.longitude);
        final bd09llCoord = CoordinateConverter.wgs84ToBd09ll(wgs84Coord);
        
        debugPrint('📍 最后已知位置坐标转换完成 (BD09ll): ${bd09llCoord.latitude}, ${bd09llCoord.longitude}');
        
        return LocationResult.success(
          bd09llCoord,
          position.accuracy,
        );
      } else {
        debugPrint('📍 没有最后已知位置');
        return LocationResult.error(
          LocationServiceStatus.error,
          '没有缓存的位置信息',
        );
      }
    } catch (e) {
      debugPrint('📍 获取最后已知位置失败: $e');
      return LocationResult.error(
        LocationServiceStatus.error,
        '获取最后已知位置失败: ${e.toString()}',
      );
    }
  }

  /// 获取位置（优先使用缓存，失败则获取新位置）
  /// 这是推荐的方法，平衡了速度和准确性
  Future<LocationResult> getLocation({
    Duration timeout = const Duration(seconds: 15),
    bool highAccuracy = true,
  }) async {
    debugPrint('📍 智能获取位置...');

    // 首先尝试获取最后已知位置
    LocationResult lastKnownResult = await getLastKnownLocation();
    
    // 如果有缓存位置且不超过5分钟，直接使用
    if (lastKnownResult.isSuccess) {
      DateTime now = DateTime.now();
      Duration cacheAge = now.difference(lastKnownResult.timestamp);
      
      if (cacheAge.inMinutes < 5) {
        debugPrint('📍 使用缓存位置（${cacheAge.inMinutes}分钟前）');
        return lastKnownResult;
      }
    }

    // 缓存位置太旧或不存在，获取新位置
    debugPrint('📍 缓存位置过期或不存在，获取新位置...');
    return getCurrentLocation(
      timeout: timeout,
      highAccuracy: highAccuracy,
    );
  }

  /// 计算两点之间的距离（米）
  static double calculateDistance(
    StandardLatLng point1,
    StandardLatLng point2,
  ) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  /// 打开应用设置页面（用于手动开启权限）
  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  /// 打开位置设置页面
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}
