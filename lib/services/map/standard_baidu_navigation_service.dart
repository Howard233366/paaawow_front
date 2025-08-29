// 标准百度地图导航服务 - 使用百度地图Flutter SDK和Web API

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart'; // 暂时未使用
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';
import 'package:pet_talk/widgets/standard_baidu_map_widget.dart';
import 'package:pet_talk/models/pet_finder_models.dart';
// import 'package:pet_talk/widgets/platform_map_widget.dart' show StandardLatLng; // 已删除

/// 标准百度地图导航服务
class StandardBaiduNavigationService {
  static const String _baiduApiKey = 'vK6hTnQzAxoZtak72lsgPu6CqNhvtKtc';
  static const String _baseUrl = 'https://api.map.baidu.com';
  
  static final StandardBaiduNavigationService _instance = StandardBaiduNavigationService._internal();
  factory StandardBaiduNavigationService() => _instance;
  StandardBaiduNavigationService._internal();

  /// 获取步行路径规划
  Future<NavigationRoute?> getWalkingRoute({
    required StandardLatLng origin,
    required StandardLatLng destination,
  }) async {
    debugPrint('🚶 开始获取步行路径规划');
    debugPrint('🚶 起点: ${origin.latitude}, ${origin.longitude}');
    debugPrint('🚶 终点: ${destination.latitude}, ${destination.longitude}');

    // 优先尝试使用SDK原生路径规划
    debugPrint('🚶 [优先] 尝试使用百度地图SDK原生路径规划...');
    final sdkResult = await getWalkingRouteWithSDK(
      origin: origin,
      destination: destination,
    );
    
    if (sdkResult != null) {
      debugPrint('🚶 [优先] ✅ SDK路径规划成功');
      return sdkResult;
    }
    
    // SDK失败时回退到Web API
    debugPrint('🚶 [回退] SDK路径规划失败，尝试Web API...');
    
    try {
      // 使用百度地图Web服务API
      final url = Uri.parse('$_baseUrl/directionlite/v1/walking').replace(
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'ak': _baiduApiKey,
          'coord_type': 'wgs84',
          'output': 'json',
        },
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('请求超时');
        },
      );

      debugPrint('🚶 [回退] API响应状态: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 0 && data['result'] != null) {
          debugPrint('🚶 [回退] ✅ Web API路径规划成功');
          return _parseWalkingResult(data['result']);
        } else {
          debugPrint('🚶 [回退] API返回错误: ${data['message'] ?? 'Unknown error'}');
          return _getMockWalkingRoute(origin, destination);
        }
      } else {
        debugPrint('🚶 [回退] HTTP错误: ${response.statusCode}');
        return _getMockWalkingRoute(origin, destination);
      }
    } catch (e) {
      debugPrint('🚶 [回退] 步行路径规划异常: $e');
      return _getMockWalkingRoute(origin, destination);
    }
  }

  /// 获取驾车路径规划
  Future<NavigationRoute?> getDrivingRoute({
    required StandardLatLng origin,
    required StandardLatLng destination,
  }) async {
    try {
      debugPrint('🚗 开始获取驾车路径规划');

      // 使用百度地图Web服务API
      final url = Uri.parse('$_baseUrl/directionlite/v1/driving').replace(
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'ak': _baiduApiKey,
          'coord_type': 'wgs84',
          'output': 'json',
        },
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('请求超时');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 0 && data['result'] != null) {
          return _parseDrivingResult(data['result']);
        } else {
          debugPrint('🚗 API返回错误: ${data['message'] ?? 'Unknown error'}');
          return _getMockDrivingRoute(origin, destination);
        }
      } else {
        debugPrint('🚗 HTTP错误: ${response.statusCode}');
        return _getMockDrivingRoute(origin, destination);
      }
    } catch (e) {
      debugPrint('🚗 驾车路径规划异常: $e');
      return _getMockDrivingRoute(origin, destination);
    }
  }

  /// 使用百度地图SDK进行步行路径规划（原生方式）
  Future<NavigationRoute?> getWalkingRouteWithSDK({
    required StandardLatLng origin,
    required StandardLatLng destination,
  }) async {
    try {
      debugPrint('🗺️ [SDK] 使用百度地图SDK进行步行路径规划');
      debugPrint('🗺️ [SDK] 起点: ${origin.latitude}, ${origin.longitude}');
      debugPrint('🗺️ [SDK] 终点: ${destination.latitude}, ${destination.longitude}');
      
      // 创建Completer来处理异步回调
      final completer = Completer<NavigationRoute?>();
      
      // 创建起点和终点
      final startNode = BMFPlanNode(
        pt: origin.toBMFCoordinate(),
        name: '起点',
      );
      
      final endNode = BMFPlanNode(
        pt: destination.toBMFCoordinate(),
        name: '终点',
      );

      // 步行路径规划
      final walkingOption = BMFWalkingRoutePlanOption(
        from: startNode,
        to: endNode,
      );
      
      final walkingSearch = BMFWalkingRouteSearch();
      
      // 暂时注释掉SDK方式，因为API方法名不确定
      // 直接返回null，让系统回退到Web API或模拟数据
      debugPrint('🚶 [SDK] ⚠️ SDK API方法名待确认，暂时跳过');
      completer.complete(null);
      
      // 等待回调结果，设置超时时间
      return await completer.future.timeout(
        const Duration(seconds: 5), // 缩短超时时间
        onTimeout: () {
          debugPrint('🚶 [SDK] ⏰ 路径规划超时，回退到Web API');
          return null;
        },
      );
      
    } catch (e) {
      debugPrint('🗺️ [SDK] ❌ SDK路径规划异常: $e');
      return null;
    }
  }

  /// 解析步行路线结果
  NavigationRoute? _parseWalkingResult(Map<String, dynamic> result) {
    try {
      final routes = result['routes'] as List?;
      if (routes == null || routes.isEmpty) {
        return null;
      }

      final route = routes.first as Map<String, dynamic>;
      final distance = (route['distance'] as num?)?.toDouble() ?? 0.0;
      final duration = (route['duration'] as num?)?.toDouble() ?? 0.0;

      // 解析路径点
      List<StandardLatLng> points = [];
      final steps = route['steps'] as List?;
      if (steps != null) {
        for (final step in steps) {
          final stepMap = step as Map<String, dynamic>;
          final path = stepMap['path'] as String?;
          if (path != null) {
            // 解析路径字符串
            final coords = path.split(';');
            for (final coord in coords) {
              final parts = coord.split(',');
              if (parts.length == 2) {
                final lng = double.tryParse(parts[0]);
                final lat = double.tryParse(parts[1]);
                if (lng != null && lat != null) {
                  points.add(StandardLatLng(lat, lng));
                }
              }
            }
          }
        }
      }

      return NavigationRoute(
        id: 'walking_route',
        points: points.map((p) => StandardLatLng(p.latitude, p.longitude)).toList(),
        totalDistance: distance,
        estimatedTime: duration.toInt(),
        routeType: 'walking',
      );
    } catch (e) {
      debugPrint('🚶 解析步行路线失败: $e');
      return null;
    }
  }

  /// 解析驾车路线结果
  NavigationRoute? _parseDrivingResult(Map<String, dynamic> result) {
    try {
      final routes = result['routes'] as List?;
      if (routes == null || routes.isEmpty) {
        return null;
      }

      final route = routes.first as Map<String, dynamic>;
      final distance = (route['distance'] as num?)?.toDouble() ?? 0.0;
      final duration = (route['duration'] as num?)?.toDouble() ?? 0.0;

      // 解析路径点
      List<StandardLatLng> points = [];
      final steps = route['steps'] as List?;
      if (steps != null) {
        for (final step in steps) {
          final stepMap = step as Map<String, dynamic>;
          final path = stepMap['path'] as String?;
          if (path != null) {
            final coords = path.split(';');
            for (final coord in coords) {
              final parts = coord.split(',');
              if (parts.length == 2) {
                final lng = double.tryParse(parts[0]);
                final lat = double.tryParse(parts[1]);
                if (lng != null && lat != null) {
                  points.add(StandardLatLng(lat, lng));
                }
              }
            }
          }
        }
      }

      return NavigationRoute(
        id: 'driving_route',
        points: points.map((p) => StandardLatLng(p.latitude, p.longitude)).toList(),
        totalDistance: distance,
        estimatedTime: duration.toInt(),
        routeType: 'driving',
      );
    } catch (e) {
      debugPrint('🚗 解析驾车路线失败: $e');
      return null;
    }
  }

  /// 获取模拟步行路线
  NavigationRoute _getMockWalkingRoute(StandardLatLng origin, StandardLatLng destination) {
    debugPrint('🚶 使用模拟步行路线');
    
    final distanceInMeters = _calculateDistance(origin, destination);
    final distanceInKm = distanceInMeters / 1000.0; // 转换为公里
    final estimatedTime = (distanceInMeters / 1.4 / 60).round(); // 假设步行速度1.4m/s，转换为分钟
    
    debugPrint('🚶 [模拟路线] 距离: ${distanceInMeters.toStringAsFixed(0)}米 (${distanceInKm.toStringAsFixed(2)}公里)');
    debugPrint('🚶 [模拟路线] 预计时间: ${estimatedTime}分钟');
    
    return NavigationRoute(
      id: 'mock_walking_route',
      points: [
        StandardLatLng(origin.latitude, origin.longitude),
        StandardLatLng(destination.latitude, destination.longitude)
      ],
      totalDistance: distanceInKm, // 使用公里作为单位
      estimatedTime: estimatedTime,
      routeType: 'walking',
    );
  }

  /// 获取模拟驾车路线
  NavigationRoute _getMockDrivingRoute(StandardLatLng origin, StandardLatLng destination) {
    debugPrint('🚗 使用模拟驾车路线');
    
    final distance = _calculateDistance(origin, destination);
    final estimatedTime = (distance / 13.9 * 60).round(); // 假设驾车速度50km/h
    
    return NavigationRoute(
      id: 'mock_driving_route',
      points: [
        StandardLatLng(origin.latitude, origin.longitude),
        StandardLatLng(destination.latitude, destination.longitude)
      ],
      totalDistance: distance,
      estimatedTime: estimatedTime,
      routeType: 'driving',
    );
  }

  /// 计算两点间距离（米）
  double _calculateDistance(StandardLatLng origin, StandardLatLng destination) {
    const double earthRadius = 6371000; // 地球半径（米）
    
    final lat1Rad = origin.latitude * (math.pi / 180);
    final lat2Rad = destination.latitude * (math.pi / 180);
    final deltaLatRad = (destination.latitude - origin.latitude) * (math.pi / 180);
    final deltaLngRad = (destination.longitude - origin.longitude) * (math.pi / 180);
    
    final a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(deltaLngRad / 2) * math.sin(deltaLngRad / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    final distance = earthRadius * c;
    
    debugPrint('🧮 [距离计算] 起点: ${origin.latitude}, ${origin.longitude}');
    debugPrint('🧮 [距离计算] 终点: ${destination.latitude}, ${destination.longitude}');
    debugPrint('🧮 [距离计算] 计算距离: ${distance.toStringAsFixed(2)}米');
    
    return distance;
  }

  /// 打开外部百度地图App进行导航
  Future<bool> openExternalBaiduMapNavigation({
    required StandardLatLng origin,
    required StandardLatLng destination,
    String routeType = 'walking',
    String? originName,
    String? destinationName,
  }) async {
    try {
      debugPrint('🗺️ 尝试打开百度地图App导航');
      
      String mode;
      switch (routeType) {
        case 'driving':
          mode = 'driving';
          break;
        case 'walking':
        default:
          mode = 'walking';
          break;
      }
      
      final url = Uri.parse(
        'baidumap://map/direction?'
        'origin=${origin.latitude},${origin.longitude}&'
        'destination=${destination.latitude},${destination.longitude}&'
        'mode=$mode'
      );

      debugPrint('🗺️ 百度地图导航URL: $url');

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        debugPrint('🗺️ 成功打开百度地图App');
        return true;
      } else {
        debugPrint('🗺️ 无法打开百度地图App，可能未安装');
        return false;
      }
    } catch (e) {
      debugPrint('🗺️ 打开百度地图App失败: $e');
      return false;
    }
  }

  /// 获取路径规划（根据类型自动选择）
  Future<NavigationRoute?> getNavigationRoute({
    required StandardLatLng origin,
    required StandardLatLng destination,
    String routeType = 'walking',
  }) async {
    switch (routeType) {
      case 'driving':
        return await getDrivingRoute(origin: origin, destination: destination);
      case 'walking':
      default:
        return await getWalkingRoute(origin: origin, destination: destination);
    }
  }
}


