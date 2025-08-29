// Google Maps 导航服务 - iOS平台使用
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:pet_talk/widgets/standard_baidu_map_widget.dart';
import 'package:pet_talk/models/pet_finder_models.dart';

/// Google Maps 导航服务（iOS使用）
class GoogleNavigationService {
  static const String _googleApiKey = 'AIzaSyBvOkBwgglgXulFl6ZiYSv1JFVhftFDdOI';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api';
  
  static final GoogleNavigationService _instance = GoogleNavigationService._internal();
  factory GoogleNavigationService() => _instance;
  GoogleNavigationService._internal();

  /// 获取步行路径规划
  Future<NavigationRoute?> getWalkingRoute({
    required StandardLatLng origin,
    required StandardLatLng destination,
  }) async {
    debugPrint('🚶 [Google] 开始获取步行路径规划');
    debugPrint('🚶 [Google] 起点: ${origin.latitude}, ${origin.longitude}');
    debugPrint('🚶 [Google] 终点: ${destination.latitude}, ${destination.longitude}');

    try {
      // 使用Google Directions API
      final url = Uri.parse('$_baseUrl/directions/json').replace(
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'mode': 'walking',
          'key': _googleApiKey,
        },
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('请求超时');
        },
      );

      debugPrint('🚶 [Google] API响应状态: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['routes'] != null && data['routes'].isNotEmpty) {
          debugPrint('🚶 [Google] ✅ 路径规划成功');
          return _parseGoogleRoute(data['routes'][0], 'walking');
        } else {
          debugPrint('🚶 [Google] API返回错误: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
          return _getMockWalkingRoute(origin, destination);
        }
      } else {
        debugPrint('🚶 [Google] HTTP错误: ${response.statusCode}');
        return _getMockWalkingRoute(origin, destination);
      }
    } catch (e) {
      debugPrint('🚶 [Google] 步行路径规划异常: $e');
      return _getMockWalkingRoute(origin, destination);
    }
  }

  /// 获取驾车路径规划
  Future<NavigationRoute?> getDrivingRoute({
    required StandardLatLng origin,
    required StandardLatLng destination,
  }) async {
    debugPrint('🚗 [Google] 开始获取驾车路径规划');

    try {
      final url = Uri.parse('$_baseUrl/directions/json').replace(
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'mode': 'driving',
          'key': _googleApiKey,
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
        
        if (data['status'] == 'OK' && data['routes'] != null && data['routes'].isNotEmpty) {
          return _parseGoogleRoute(data['routes'][0], 'driving');
        } else {
          debugPrint('🚗 [Google] API返回错误: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
          return _getMockDrivingRoute(origin, destination);
        }
      } else {
        debugPrint('🚗 [Google] HTTP错误: ${response.statusCode}');
        return _getMockDrivingRoute(origin, destination);
      }
    } catch (e) {
      debugPrint('🚗 [Google] 驾车路径规划异常: $e');
      return _getMockDrivingRoute(origin, destination);
    }
  }

  /// 获取骑行路径规划
  Future<NavigationRoute?> getCyclingRoute({
    required StandardLatLng origin,
    required StandardLatLng destination,
  }) async {
    debugPrint('🚴 [Google] 开始获取骑行路径规划');

    try {
      final url = Uri.parse('$_baseUrl/directions/json').replace(
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'mode': 'bicycling',
          'key': _googleApiKey,
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
        
        if (data['status'] == 'OK' && data['routes'] != null && data['routes'].isNotEmpty) {
          return _parseGoogleRoute(data['routes'][0], 'cycling');
        } else {
          debugPrint('🚴 [Google] API返回错误: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
          return _getMockCyclingRoute(origin, destination);
        }
      } else {
        debugPrint('🚴 [Google] HTTP错误: ${response.statusCode}');
        return _getMockCyclingRoute(origin, destination);
      }
    } catch (e) {
      debugPrint('🚴 [Google] 骑行路径规划异常: $e');
      return _getMockCyclingRoute(origin, destination);
    }
  }

  /// 解析Google路线结果
  NavigationRoute? _parseGoogleRoute(Map<String, dynamic> route, String routeType) {
    try {
      final legs = route['legs'] as List?;
      if (legs == null || legs.isEmpty) {
        return null;
      }

      final leg = legs.first as Map<String, dynamic>;
      final distance = leg['distance']?['value'] ?? 0; // 米
      final duration = leg['duration']?['value'] ?? 0; // 秒

      // 解析路径点
      List<StandardLatLng> points = [];
      final steps = leg['steps'] as List?;
      if (steps != null) {
        for (final step in steps) {
          final stepMap = step as Map<String, dynamic>;
          final polyline = stepMap['polyline']?['points'] as String?;
          if (polyline != null) {
            // 解码Google polyline
            final decodedPoints = _decodePolyline(polyline);
            points.addAll(decodedPoints);
          }
        }
      }

      return NavigationRoute(
        id: '${routeType}_route_google',
        points: points,
        totalDistance: distance / 1000.0, // 转换为公里
        estimatedTime: (duration / 60).round(), // 转换为分钟
        routeType: routeType,
      );
    } catch (e) {
      debugPrint('🗺️ [Google] 解析路线失败: $e');
      return null;
    }
  }

  /// 解码Google polyline
  List<StandardLatLng> _decodePolyline(String encoded) {
    List<StandardLatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(StandardLatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  /// 获取模拟步行路线
  NavigationRoute _getMockWalkingRoute(StandardLatLng origin, StandardLatLng destination) {
    debugPrint('🚶 [Google] 使用模拟步行路线');
    
    final distanceInMeters = _calculateDistance(origin, destination);
    final distanceInKm = distanceInMeters / 1000.0;
    final estimatedTime = (distanceInMeters / 1.4 / 60).round(); // 步行速度1.4m/s
    
    return NavigationRoute(
      id: 'mock_walking_route_google',
      points: [origin, destination],
      totalDistance: distanceInKm,
      estimatedTime: estimatedTime,
      routeType: 'walking',
    );
  }

  /// 获取模拟驾车路线
  NavigationRoute _getMockDrivingRoute(StandardLatLng origin, StandardLatLng destination) {
    debugPrint('🚗 [Google] 使用模拟驾车路线');
    
    final distanceInMeters = _calculateDistance(origin, destination);
    final distanceInKm = distanceInMeters / 1000.0;
    final estimatedTime = (distanceInKm / 50 * 60).round(); // 驾车速度50km/h
    
    return NavigationRoute(
      id: 'mock_driving_route_google',
      points: [origin, destination],
      totalDistance: distanceInKm,
      estimatedTime: estimatedTime,
      routeType: 'driving',
    );
  }

  /// 获取模拟骑行路线
  NavigationRoute _getMockCyclingRoute(StandardLatLng origin, StandardLatLng destination) {
    debugPrint('🚴 [Google] 使用模拟骑行路线');
    
    final distanceInMeters = _calculateDistance(origin, destination);
    final distanceInKm = distanceInMeters / 1000.0;
    final estimatedTime = (distanceInKm / 15 * 60).round(); // 骑行速度15km/h
    
    return NavigationRoute(
      id: 'mock_cycling_route_google',
      points: [origin, destination],
      totalDistance: distanceInKm,
      estimatedTime: estimatedTime,
      routeType: 'cycling',
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
    
    return earthRadius * c;
  }

  /// 打开外部Google Maps App进行导航
  Future<bool> openExternalGoogleMapsNavigation({
    required StandardLatLng origin,
    required StandardLatLng destination,
    String routeType = 'walking',
    String? originName,
    String? destinationName,
  }) async {
    try {
      debugPrint('🗺️ [Google] 尝试打开Google Maps App导航');
      
      String mode;
      switch (routeType) {
        case 'driving':
          mode = 'driving';
          break;
        case 'cycling':
          mode = 'bicycling';
          break;
        case 'walking':
        default:
          mode = 'walking';
          break;
      }
      
      final url = Uri.parse(
        'https://www.google.com/maps/dir/?'
        'api=1&'
        'origin=${origin.latitude},${origin.longitude}&'
        'destination=${destination.latitude},${destination.longitude}&'
        'travelmode=$mode'
      );

      debugPrint('🗺️ [Google] 导航URL: $url');

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        debugPrint('🗺️ [Google] 成功打开Google Maps App');
        return true;
      } else {
        debugPrint('🗺️ [Google] 无法打开Google Maps App');
        return false;
      }
    } catch (e) {
      debugPrint('🗺️ [Google] 打开Google Maps App失败: $e');
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
      case 'cycling':
        return await getCyclingRoute(origin: origin, destination: destination);
      case 'walking':
      default:
        return await getWalkingRoute(origin: origin, destination: destination);
    }
  }
}
