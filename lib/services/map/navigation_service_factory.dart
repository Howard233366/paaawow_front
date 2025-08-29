// 导航服务工厂 - 根据平台自动选择合适的导航服务
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pet_talk/services/map/standard_baidu_navigation_service.dart';
import 'package:pet_talk/services/map/google_navigation_service.dart';
import 'package:pet_talk/widgets/standard_baidu_map_widget.dart';
import 'package:pet_talk/models/pet_finder_models.dart';

/// 统一的导航服务接口
abstract class NavigationServiceInterface {
  Future<NavigationRoute?> getWalkingRoute({
    required StandardLatLng origin,
    required StandardLatLng destination,
  });

  Future<NavigationRoute?> getDrivingRoute({
    required StandardLatLng origin,
    required StandardLatLng destination,
  });

  Future<NavigationRoute?> getNavigationRoute({
    required StandardLatLng origin,
    required StandardLatLng destination,
    String routeType = 'walking',
  });

  Future<bool> openExternalNavigation({
    required StandardLatLng origin,
    required StandardLatLng destination,
    String routeType = 'walking',
    String? originName,
    String? destinationName,
  });
}

/// 百度地图导航服务适配器
class BaiduNavigationAdapter implements NavigationServiceInterface {
  final StandardBaiduNavigationService _service = StandardBaiduNavigationService();

  @override
  Future<NavigationRoute?> getWalkingRoute({
    required StandardLatLng origin,
    required StandardLatLng destination,
  }) {
    return _service.getWalkingRoute(origin: origin, destination: destination);
  }

  @override
  Future<NavigationRoute?> getDrivingRoute({
    required StandardLatLng origin,
    required StandardLatLng destination,
  }) {
    return _service.getDrivingRoute(origin: origin, destination: destination);
  }

  @override
  Future<NavigationRoute?> getNavigationRoute({
    required StandardLatLng origin,
    required StandardLatLng destination,
    String routeType = 'walking',
  }) {
    return _service.getNavigationRoute(
      origin: origin,
      destination: destination,
      routeType: routeType,
    );
  }

  @override
  Future<bool> openExternalNavigation({
    required StandardLatLng origin,
    required StandardLatLng destination,
    String routeType = 'walking',
    String? originName,
    String? destinationName,
  }) {
    return _service.openExternalBaiduMapNavigation(
      origin: origin,
      destination: destination,
      routeType: routeType,
      originName: originName,
      destinationName: destinationName,
    );
  }
}

/// Google Maps导航服务适配器
class GoogleNavigationAdapter implements NavigationServiceInterface {
  final GoogleNavigationService _service = GoogleNavigationService();

  @override
  Future<NavigationRoute?> getWalkingRoute({
    required StandardLatLng origin,
    required StandardLatLng destination,
  }) {
    return _service.getWalkingRoute(origin: origin, destination: destination);
  }

  @override
  Future<NavigationRoute?> getDrivingRoute({
    required StandardLatLng origin,
    required StandardLatLng destination,
  }) {
    return _service.getDrivingRoute(origin: origin, destination: destination);
  }

  Future<NavigationRoute?> getCyclingRoute({
    required StandardLatLng origin,
    required StandardLatLng destination,
  }) {
    return _service.getCyclingRoute(origin: origin, destination: destination);
  }

  @override
  Future<NavigationRoute?> getNavigationRoute({
    required StandardLatLng origin,
    required StandardLatLng destination,
    String routeType = 'walking',
  }) {
    return _service.getNavigationRoute(
      origin: origin,
      destination: destination,
      routeType: routeType,
    );
  }

  @override
  Future<bool> openExternalNavigation({
    required StandardLatLng origin,
    required StandardLatLng destination,
    String routeType = 'walking',
    String? originName,
    String? destinationName,
  }) {
    return _service.openExternalGoogleMapsNavigation(
      origin: origin,
      destination: destination,
      routeType: routeType,
      originName: originName,
      destinationName: destinationName,
    );
  }
}

/// 导航服务工厂
class NavigationServiceFactory {
  static NavigationServiceInterface? _instance;

  /// 获取适合当前平台的导航服务实例
  static NavigationServiceInterface getInstance() {
    if (_instance != null) {
      return _instance!;
    }

    if (kIsWeb) {
      debugPrint('🗺️ [Factory] Web平台 - 使用Google Maps导航服务');
      _instance = GoogleNavigationAdapter();
    } else if (Platform.isIOS) {
      debugPrint('🗺️ [Factory] iOS平台 - 使用Google Maps导航服务');
      _instance = GoogleNavigationAdapter();
    } else if (Platform.isAndroid) {
      debugPrint('🗺️ [Factory] Android平台 - 使用百度地图导航服务');
      _instance = BaiduNavigationAdapter();
    } else {
      debugPrint('🗺️ [Factory] 其他平台 (${Platform.operatingSystem}) - 使用Google Maps导航服务');
      _instance = GoogleNavigationAdapter();
    }

    return _instance!;
  }

  /// 重置实例（主要用于测试）
  static void reset() {
    _instance = null;
  }

  /// 获取当前使用的导航服务类型
  static String getCurrentServiceType() {
    if (kIsWeb || Platform.isIOS) {
      return 'Google Maps';
    } else if (Platform.isAndroid) {
      return 'Baidu Maps';
    } else {
      return 'Google Maps';
    }
  }
}
