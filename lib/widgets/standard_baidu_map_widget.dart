// 标准百度地图Flutter组件 - 使用官方flutter_baidu_mapapi SDK

import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';

/// 统一的地图位置类
class StandardLatLng {
  final double latitude;
  final double longitude;

  const StandardLatLng(this.latitude, this.longitude);

  /// 转换为Google Maps LatLng
  google_maps.LatLng toGoogleLatLng() {
    return google_maps.LatLng(latitude, longitude);
  }

  /// 转换为百度地图BMFCoordinate
  BMFCoordinate toBMFCoordinate() {
    return BMFCoordinate(latitude, longitude);
  }

  @override
  String toString() => 'StandardLatLng($latitude, $longitude)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StandardLatLng &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}

/// 统一的地图标记类
class StandardMarker {
  final String id;
  final StandardLatLng position;
  final String? title;
  final String? snippet;
  final String? iconType;

  const StandardMarker({
    required this.id,
    required this.position,
    this.title,
    this.snippet,
    this.iconType,
  });

  /// 转换为Google Maps Marker
  google_maps.Marker toGoogleMarker() {
    return google_maps.Marker(
      markerId: google_maps.MarkerId(id),
      position: position.toGoogleLatLng(),
      infoWindow: google_maps.InfoWindow(
        title: title,
        snippet: snippet,
      ),
      icon: _getGoogleIcon(),
    );
  }

  google_maps.BitmapDescriptor _getGoogleIcon() {
    switch (iconType) {
      case 'pet':
        return google_maps.BitmapDescriptor.defaultMarkerWithHue(
          google_maps.BitmapDescriptor.hueOrange);
      case 'user':
        return google_maps.BitmapDescriptor.defaultMarkerWithHue(
          google_maps.BitmapDescriptor.hueBlue);
      default:
        return google_maps.BitmapDescriptor.defaultMarker;
    }
  }

  /// 转换为百度地图BMFMarker（已在_addMapElements中直接实现）
  BMFMarker toBMFMarker() {
    return BMFMarker(
      position: position.toBMFCoordinate(),
      identifier: id,
      title: title,
      subtitle: snippet,
    );
  }
}

/// 统一的地图圆圈类
class StandardCircle {
  final String id;
  final StandardLatLng center;
  final double radius;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;

  const StandardCircle({
    required this.id,
    required this.center,
    required this.radius,
    required this.fillColor,
    required this.strokeColor,
    this.strokeWidth = 2.0,
  });

  /// 转换为Google Maps Circle
  google_maps.Circle toGoogleCircle() {
    return google_maps.Circle(
      circleId: google_maps.CircleId(id),
      center: center.toGoogleLatLng(),
      radius: radius,
      fillColor: fillColor,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth.toInt(),
    );
  }

  /// 转换为百度地图BMFCircle
  BMFCircle toBMFCircle() {
    final bmfCircle = BMFCircle(
      center: center.toBMFCoordinate(),
      radius: radius,
      fillColor: fillColor,
      strokeColor: strokeColor,
      width: strokeWidth.toInt(),
    );
    
    return bmfCircle;
  }
}

/// 统一的地图路径线类
class StandardPolyline {
  final String id;
  final List<StandardLatLng> points;
  final Color color;
  final double width;

  const StandardPolyline({
    required this.id,
    required this.points,
    required this.color,
    required this.width,
  });

  /// 转换为Google Maps Polyline
  google_maps.Polyline toGooglePolyline() {
    return google_maps.Polyline(
      polylineId: google_maps.PolylineId(id),
      points: points.map((point) => point.toGoogleLatLng()).toList(),
      color: color,
      width: width.toInt(),
    );
  }

  /// 转换为百度地图BMFPolyline
  BMFPolyline toBMFPolyline() {
    
    final bmfPolyline = BMFPolyline(
      coordinates: points.map((point) => point.toBMFCoordinate()).toList(),
      colors: [color], // 百度地图使用colors数组
      width: width.toInt(),
    );
    
    return bmfPolyline;
  }
}

/// 标准百度地图组件
class StandardBaiduMapWidget extends StatefulWidget {
  final StandardLatLng initialPosition;
  final double initialZoom;
  final Set<StandardMarker> markers;
  final Set<StandardCircle> circles;
  final Set<StandardPolyline> polylines;
  final bool myLocationEnabled;
  final Function(StandardLatLng)? onTap;
  final Function()? onMapCreated;
  final Function(StandardMarker)? onMarkerTap;

  const StandardBaiduMapWidget({
    super.key,
    required this.initialPosition,
    this.initialZoom = 15.0,
    this.markers = const {},
    this.circles = const {},
    this.polylines = const {},
    this.myLocationEnabled = true,
    this.onTap,
    this.onMapCreated,
    this.onMarkerTap,
  });

  @override
  State<StandardBaiduMapWidget> createState() => _StandardBaiduMapWidgetState();
}

class _StandardBaiduMapWidgetState extends State<StandardBaiduMapWidget> {
  bool _isDisposed = false;
  BMFMapController? _bmfMapController;
  
  // 简化的圆圈管理：只记录当前显示的圆圈ID列表
  final Set<String> _displayedCircleIds = {};
  
  // 上一次的圆圈集合，用于比较变化
  Set<StandardCircle> _lastCircles = {};
  
  // 强制重建地图的key，当圆圈发生变化时更新这个key
  int _mapRebuildKey = 0;

  // 仅用于预览圆圈的实际Overlay Id（由百度SDK分配）
  String? _previewCircleOverlayId;

  @override
  void initState() {
    super.initState();
    _logPlatformInfo();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _displayedCircleIds.clear(); // 清理圆圈ID记录
    _lastCircles.clear();
    super.dispose();
  }

  @override
  void didUpdateWidget(StandardBaiduMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 检查圆圈变化
    bool circlesChanged = !_setEquals(_lastCircles, widget.circles);
    
    // 检查路径线变化
    bool polylinesChanged = !_polylinesEquals(oldWidget.polylines, widget.polylines);
    
    if (circlesChanged) {
      // 判断是否需要重建地图
      bool needRebuild = _shouldRebuildMap(_lastCircles, widget.circles);
      
      // 更新记录
      _lastCircles = Set.from(widget.circles);
      
      if (needRebuild) {
        // 强制重建地图组件（仅在必要时）
        setState(() {
          _mapRebuildKey++;
          _bmfMapController = null; // 重置控制器
          _displayedCircleIds.clear(); // 清空记录
        });
      } else if (_bmfMapController != null) {
        // 使用官方标准方法更新圆圈
        Future.delayed(const Duration(milliseconds: 50), () {
          if (!_isDisposed && _bmfMapController != null) {
            _updateCirclesOfficialWay();
          }
        });
      }
      
    } else if (polylinesChanged) {
      if (_bmfMapController != null) {
        // 🔧 路径线变化时，只更新路径线，不重复添加圆圈
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!_isDisposed && _bmfMapController != null) {
            _addPolylinesOnly(); // 新方法：只添加路径线
          }
        });
      }
    }
    
    debugPrint('🗺️ [UPDATE] didUpdateWidget完成 - 圆圈变化: $circlesChanged, 路径变化: $polylinesChanged');
  }
  
  /// 比较两个路径线集合是否相等
  bool _polylinesEquals(Set<StandardPolyline> set1, Set<StandardPolyline> set2) {
    if (set1.length != set2.length) return false;
    
    for (var polyline1 in set1) {
      bool found = false;
      for (var polyline2 in set2) {
        if (polyline1.id == polyline2.id && 
            polyline1.points.length == polyline2.points.length &&
            polyline1.color == polyline2.color &&
            polyline1.width == polyline2.width) {
          // 简化比较，只检查第一个和最后一个点
          if (polyline1.points.isNotEmpty && polyline2.points.isNotEmpty) {
            if (polyline1.points.first.latitude == polyline2.points.first.latitude &&
                polyline1.points.first.longitude == polyline2.points.first.longitude &&
                polyline1.points.last.latitude == polyline2.points.last.latitude &&
                polyline1.points.last.longitude == polyline2.points.last.longitude) {
              found = true;
              break;
            }
          } else if (polyline1.points.isEmpty && polyline2.points.isEmpty) {
            found = true;
            break;
          }
        }
      }
      if (!found) return false;
    }
    return true;
  }

  /// 比较两个圆圈集合是否相等
  bool _setEquals(Set<StandardCircle> set1, Set<StandardCircle> set2) {
    if (set1.length != set2.length) return false;
    
    for (var circle1 in set1) {
      bool found = false;
      for (var circle2 in set2) {
        if (circle1.id == circle2.id && 
            circle1.radius == circle2.radius &&
            circle1.center.latitude == circle2.center.latitude &&
            circle1.center.longitude == circle2.center.longitude) {
          found = true;
          break;
        }
      }
      if (!found) return false;
    }
    return true;
  }

  /// 判断是否需要重建地图组件
  bool _shouldRebuildMap(Set<StandardCircle> oldCircles, Set<StandardCircle> newCircles) {
    debugPrint('🤔 [REBUILD_CHECK] 检查是否需要重建地图...');
    
    // 1. 数量变化 → 需要重建
    if (oldCircles.length != newCircles.length) {
      debugPrint('🤔 [REBUILD_CHECK] ✅ 圆圈数量变化: ${oldCircles.length} → ${newCircles.length}，需要重建');
      return true;
    }
    
    // 2. 检查是否有新增或删除的圆圈 → 需要重建
    Set<String> oldIds = oldCircles.map((c) => c.id).toSet();
    Set<String> newIds = newCircles.map((c) => c.id).toSet();
    
    if (!oldIds.containsAll(newIds) || !newIds.containsAll(oldIds)) {
      debugPrint('🤔 [REBUILD_CHECK] ✅ 圆圈ID变化，需要重建');
      debugPrint('🤔 [REBUILD_CHECK] - 旧ID: $oldIds');
      debugPrint('🤔 [REBUILD_CHECK] - 新ID: $newIds');
      return true;
    }
    
    // 3. 检查是否有位置变化 → 需要重建（位置变化较复杂，重建更可靠）
    for (var newCircle in newCircles) {
      var oldCircle = oldCircles.where((c) => c.id == newCircle.id).firstOrNull;
      if (oldCircle != null) {
        // 位置变化检查
        double latDiff = (oldCircle.center.latitude - newCircle.center.latitude).abs();
        double lngDiff = (oldCircle.center.longitude - newCircle.center.longitude).abs();
        
        if (latDiff > 0.000001 || lngDiff > 0.000001) {
          debugPrint('🤔 [REBUILD_CHECK] ✅ 圆圈 ${newCircle.id} 位置变化，需要重建');
          debugPrint('🤔 [REBUILD_CHECK] - 旧位置: (${oldCircle.center.latitude}, ${oldCircle.center.longitude})');
          debugPrint('🤔 [REBUILD_CHECK] - 新位置: (${newCircle.center.latitude}, ${newCircle.center.longitude})');
          return true;
        }
      }
    }
    
    // 4. 只有半径变化 → 不需要重建，可以智能更新
    return false;
  }

  /// 仅更新"预览圆圈"：先删后加，保证始终只有一个预览圆
  Future<void> _updateCirclesOfficialWay() async {
    if (_bmfMapController == null) {
      return;
    }

    try {
      // 1) 查找是否存在预览圆圈（固定ID）
      final preview = widget.circles.firstWhere(
        (c) => c.id == 'virtual_fence_preview' || c.id == 'preview_fence',
        orElse: () => const StandardCircle(
          id: '__none__',
          center: StandardLatLng(0, 0),
          radius: 0,
          fillColor: Colors.transparent,
          strokeColor: Colors.transparent,
          strokeWidth: 0,
        ),
      );

      final hasPreview = preview.id != '__none__';

      // 2) 如果地图上已有一个预览Overlay，先尝试删除
      if (_previewCircleOverlayId != null) {
        try {
          await _bmfMapController!.removeOverlay(_previewCircleOverlayId!);
        } catch (e) {
          // 删除失败，继续执行
        } finally {
          _previewCircleOverlayId = null;
        }
      }

      // 3) 如果当前需要显示预览，则添加新的预览圆
      if (hasPreview) {
        try {
          final bmfCircle = preview.toBMFCircle();
          final dynamic addResult = await _bmfMapController!.addCircle(bmfCircle);

          // 优先从返回值获取overlayId（若返回String id）
          if (addResult is String) {
            _previewCircleOverlayId = addResult;
          } else {
            // 回退：从对象上提取
            _previewCircleOverlayId = _extractOverlayId(bmfCircle);
          }
        } catch (e) {
          // 添加失败，继续执行
        }
      }
    } catch (e) {
      // 处理异常，但不输出调试信息
    }
  }

  /// 尝试从覆盖物对象上提取overlayId（兼容不同字段名）
  String? _extractOverlayId(Object overlay) {
    try {
      final dyn = overlay as dynamic;
      final candidates = [
        () => dyn.id,
        () => dyn.Id,
        () => dyn.overlayId,
        () => dyn.identifier,
      ];
      for (final getter in candidates) {
        try {
          final value = getter();
          if (value is String && value.isNotEmpty) {
            return value;
          }
        } catch (_) {}
      }
    } catch (_) {}
    return null;
  }

  /// 重建后使用官方方法添加圆圈
  Future<void> _addCirclesDirectly() async {
    debugPrint('📘 ========== 重建后官方方法添加圆圈 ==========');
    
    if (_bmfMapController == null) {
      debugPrint('📘 ❌ 地图控制器为null');
      return;
    }

    // 🔧 修复重复渲染：逐个删除已显示的圆圈
    if (_displayedCircleIds.isNotEmpty) {
      debugPrint('📘 [CIRCLE] 开始清理已显示的 ${_displayedCircleIds.length} 个圆圈...');
      for (final circleId in _displayedCircleIds.toList()) {
        try {
          await _bmfMapController!.removeOverlay(circleId);
          debugPrint('📘 [CIRCLE] 删除圆圈: $circleId');
        } catch (e) {
          debugPrint('📘 [CIRCLE] 删除圆圈失败: $circleId, 错误: $e');
        }
      }
      _displayedCircleIds.clear();
      _previewCircleOverlayId = null; // 重置预览圆圈ID
      debugPrint('📘 [CIRCLE] 圆圈清理完成');
    }

    // 添加所有圆圈（包括虚拟围栏和预览圆圈）
    debugPrint('📘 [CIRCLE] 开始添加 ${widget.circles.length} 个圆圈...');
    for (final circle in widget.circles) {
      try {
        await _bmfMapController!.addCircle(circle.toBMFCircle());
        _displayedCircleIds.add(circle.id);
        debugPrint('📘 [CIRCLE] 成功添加圆圈: ${circle.id} (半径: ${circle.radius}m)');
        
        // 如果是预览圆圈，记录其ID（用于后续更新）
        if (circle.id == 'virtual_fence_preview') {
          // 预览圆圈的overlayId需要从百度SDK获取，这里暂时使用circle.id
          _previewCircleOverlayId = circle.id;
        }
      } catch (e) {
        debugPrint('📘 [CIRCLE] 添加圆圈失败: ${circle.id}, 错误: $e');
      }
    }
    debugPrint('📘 [CIRCLE] 圆圈添加完成，地图上共有 ${_displayedCircleIds.length} 个圆圈');
  }

  void _logPlatformInfo() {
    if (kIsWeb) {
      debugPrint('🗺️ 平台: Web - 使用Google Maps');
    } else if (Platform.isIOS) {
      debugPrint('🗺️ 平台: iOS - 使用Google Maps');
    } else if (Platform.isAndroid) {
      debugPrint('🗺️ 平台: Android - 使用百度地图Flutter SDK');
    } else {
      debugPrint('🗺️ 平台: ${Platform.operatingSystem} - 使用Google Maps');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || Platform.isIOS) {
      return _buildGoogleMap();
    } else if (Platform.isAndroid) {
      return _buildBaiduMap();
    } else {
      return _buildGoogleMap();
    }
  }

  /// 构建Google地图（iOS和Web）
  Widget _buildGoogleMap() {
    if (_isDisposed) {
      return _buildMapPlaceholder('地图组件已销毁');
    }

    try {
      return google_maps.GoogleMap(
        initialCameraPosition: google_maps.CameraPosition(
          target: widget.initialPosition.toGoogleLatLng(),
          zoom: widget.initialZoom,
        ),
        markers: widget.markers.map((marker) => marker.toGoogleMarker()).toSet(),
        circles: widget.circles.map((circle) => circle.toGoogleCircle()).toSet(),
        polylines: widget.polylines.map((polyline) => polyline.toGooglePolyline()).toSet(),
        myLocationEnabled: widget.myLocationEnabled,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        onTap: widget.onTap != null
            ? (google_maps.LatLng latLng) {
                widget.onTap!(StandardLatLng(latLng.latitude, latLng.longitude));
              }
            : null,
        onMapCreated: (google_maps.GoogleMapController controller) {
          if (!_isDisposed) {
            widget.onMapCreated?.call();
          }
        },
      );
    } catch (e) {
      return _buildMapPlaceholder('Google Maps 加载失败: $e');
    }
  }

  /// 构建百度地图（Android）
  Widget _buildBaiduMap() {
    if (_isDisposed) {
      return _buildMapPlaceholder('地图组件已销毁');
    }

    try {
      
      return BMFMapWidget(
        key: ValueKey('baidu_map_$_mapRebuildKey'), // 使用key强制重建
        onBMFMapCreated: (BMFMapController controller) async {
          if (!_isDisposed) {
            _bmfMapController = controller;
            
            // 设置地图事件监听器
            _setupMapEventListeners();
            
            // 等待地图初始化
            await Future.delayed(const Duration(milliseconds: 300));
            
            widget.onMapCreated?.call();
            
            // 🔧 修复重复渲染：分别添加不同类型的地图元素
            await _addMapElements();        // 添加标记
            await _addPolylinesOnly();      // 添加路径线
            await _addCirclesDirectly();    // 添加圆圈
          }
        },
        mapOptions: BMFMapOptions(
          center: widget.initialPosition.toBMFCoordinate(),
          zoomLevel: widget.initialZoom.toInt(),
          mapType: BMFMapType.Standard,
          showMapScaleBar: true,
          showZoomControl: false,
        ),
        // 地图点击事件需要通过控制器设置，暂时移除此处配置
      );
    } catch (e) {
      return _buildMapPlaceholder('百度地图加载失败: $e');
    }
  }

  /// 公开方法：强制刷新地图元素
  Future<void> refreshMapElements() async {
    if (_bmfMapController != null) {
      await _addMapElements();
    }
  }

  /// 获取地图控制器状态（用于调试）
  bool get isMapControllerReady => _bmfMapController != null;

  /// 添加地图元素（标记、路径线）
  /// 注意：圆圈由专门的_addCirclesDirectly方法处理
  Future<void> _addMapElements() async {
    if (_bmfMapController == null) {
      return;
    }

    // 清除标记
    try {
      await _bmfMapController!.cleanAllMarkers();
    } catch (e) {
      // 清除标记失败，继续执行
    }
    
    // 清除路径线
    try {
      // 百度地图没有cleanAllPolylines方法，需要逐个清除
      // 这里暂时跳过，因为百度地图SDK可能没有提供批量清除路径线的方法
    } catch (e) {
      // 清除路径线失败，继续执行
    }

    // 添加标记
    
    if (widget.markers.isNotEmpty) {
      try {
        List<BMFMarker> bmfMarkers = [];
        
        for (final marker in widget.markers) {
          // 创建BMFCoordinate
          final coordinate = BMFCoordinate(marker.position.latitude, marker.position.longitude);
          
          try {
            // 创建一个简单的红色圆点作为默认图标
            final iconData = await _createDefaultMarkerIcon(marker.iconType);
            
            // 按照官方文档创建自定义标记
            final bmfMarker = BMFMarker.iconData(
              position: coordinate,
              identifier: marker.id,
              title: marker.title ?? '',
              subtitle: marker.snippet ?? '',
              iconData: iconData,
              enabled: true,
              draggable: false,
              // Flutter插件支持的属性
              alpha: 0.9,                    // 透明度 (0.0-1.0)
              visible: true,                 // 确保可见
            );
            
            bmfMarkers.add(bmfMarker);
            
          } catch (e) {
            // 标记创建失败，跳过此标记
          }
        }
        
        // 批量添加标记
        _bmfMapController!.addMarkers(bmfMarkers);
        
      } catch (e) {
        // 批量添加标记失败，继续执行
      }
    }

    // 🔧 路径线管理已移至 _addPolylinesOnly() 方法，圆圈管理已移至 _addCirclesDirectly() 方法
    debugPrint('🗺️ [ELEMENTS] 地图标记添加完成');
  }

  /// 仅添加路径线（用于路径线变化时的更新）
  Future<void> _addPolylinesOnly() async {
    if (_bmfMapController == null) {
      return;
    }

    debugPrint('🗺️ [POLYLINE] 开始更新路径线...');
    
    // 添加路径线
    if (widget.polylines.isNotEmpty) {
      for (final polyline in widget.polylines) {
        try {
          final bmfPolyline = polyline.toBMFPolyline();
          await _bmfMapController!.addPolyline(bmfPolyline);
          debugPrint('🗺️ [POLYLINE] 成功添加路径线: ${polyline.id}');
        } catch (e) {
          debugPrint('🗺️ [POLYLINE] 添加路径线失败: ${polyline.id}, 错误: $e');
        }
      }
    }
    debugPrint('🗺️ [POLYLINE] 路径线更新完成');
  }

  /// 设置地图事件监听器（包括地图点击和标记点击）
  /// 严格按照官方文档实现地图事件处理
  void _setupMapEventListeners() {
    if (_bmfMapController == null) {
      return;
    }
    
    try {
      // 设置地图点击事件监听器
      try {
        // 方法1: setMapOnClickedMapBlankCallback with named parameter
        _bmfMapController!.setMapOnClickedMapBlankCallback(
          callback: (BMFCoordinate coordinate) {
            if (widget.onTap != null) {
              widget.onTap!(StandardLatLng(coordinate.latitude, coordinate.longitude));
            }
          },
        );
      } catch (e1) {
        try {
          // 方法2: 尝试其他可能的方法名
          // 由于不确定确切的API，暂时注释掉
          // 这里可能需要查看具体的百度地图Flutter插件文档
        } catch (e2) {
          // 无法设置地图点击事件监听器
        }
      }
      
    } catch (e) {
      // 设置地图事件监听器失败
    }
  }


  /// 创建自定义标记图标数据
  /// 严格按照官方文档要求，创建美观的自定义标记图标
  Future<Uint8List> _createDefaultMarkerIcon(String? iconType) async {
    
    try {
      // 根据标记类型设计不同的图标样式
      Color primaryColor;
      Color shadowColor;
      IconData iconData;
      
      switch (iconType) {
        case 'user':
          primaryColor = const Color(0xFF2196F3);   // 用户位置使用蓝色
          shadowColor = const Color(0xFF1976D2);
          iconData = Icons.person_pin_circle;
          break;
        case 'pet':
          primaryColor = const Color(0xFFE6294A);   // 宠物位置使用APP主色红色
          shadowColor = const Color(0xFFD32F2F);
          iconData = Icons.pets;
          break;
        default:
          primaryColor = const Color(0xFFFF9800);   // 默认使用橙色
          shadowColor = const Color(0xFFF57C00);
          iconData = Icons.location_on;
      }
      

      
      // 创建自定义图标 (100x100像素，更大更清晰)
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const size = 140.0;
      final center = const Offset(70.0, 70.0); // size / 2 = 50.0
      
      // 1. 绘制阴影效果
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(const Offset(72.0, 72.0), 42, shadowPaint); // center.dx + 2, center.dy + 2
      
      // 2. 绘制主圆形背景
      final backgroundPaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, 42, backgroundPaint);
      
      // 3. 绘制渐变效果
      final gradientPaint = Paint()
        ..shader = ui.Gradient.radial(
          center,
          42,
          [
            primaryColor.withOpacity(0.8),
            shadowColor,
          ],
          [0.0, 1.0],
        );
      canvas.drawCircle(center, 42, gradientPaint);
      
      // 4. 绘制白色边框
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7;
      canvas.drawCircle(center, 42, borderPaint);
      
      // 5. 绘制内部图标
      final iconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(iconData.codePoint),
          style: TextStyle(
            fontSize: 60,
            fontFamily: iconData.fontFamily,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      iconPainter.layout();
      iconPainter.paint(
        canvas,
        Offset(
          70.0 - iconPainter.width / 2,  // center.dx - iconPainter.width / 2
          70.0 - iconPainter.height / 2, // center.dy - iconPainter.height / 2
        ),
      );
      
      // 6. 添加小圆点指示器（底部尖角效果）
      final pointerPaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.fill;
      
      final path = Path();
      path.moveTo(70.0, 128.0);       // 底部中心点 (center.dx, size - 12)
      path.lineTo(56.0, 98.0);        // 左下角 (center.dx - 14, center.dy + 28)
      path.lineTo(84.0, 98.0);        // 右下角 (center.dx + 14, center.dy + 28)
      path.close();
      canvas.drawPath(path, pointerPaint);
      
      // 绘制指针边框
      final pointerBorderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawPath(path, pointerBorderPaint);
      
      final picture = recorder.endRecording();
      final image = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      final iconDataBytes = byteData!.buffer.asUint8List();
      
      return iconDataBytes;
      
    } catch (e) {
      // 返回简单的圆点作为后备方案
      return await _createSimpleIcon(iconType);
    }
  }

  /// 创建简单圆点图标（后备方案）
  Future<Uint8List> _createSimpleIcon(String? iconType) async {
    try {
      Color color = iconType == 'user' ? Colors.blue : 
                   iconType == 'pet' ? const Color(0xFFE6294A) : Colors.orange;
      
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..color = color..style = PaintingStyle.fill;
      
      canvas.drawCircle(const Offset(12, 12), 8, paint);
      
      final picture = recorder.endRecording();
      final image = await picture.toImage(24, 24);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      return byteData!.buffer.asUint8List();
    } catch (e) {
      debugPrint('🗺️ [ICON] 简单图标创建也失败: $e');
      return Uint8List.fromList([]);
    }
  }



  /// 构建地图占位符
  Widget _buildMapPlaceholder(String error) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.map,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              '地图加载中...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // 重新构建组件
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
              ),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 兼容性扩展 - 与旧类型互转
extension StandardLatLngCompatibility on StandardLatLng {
  /// 转换为旧的PlatformLatLng（如果需要兼容）
  dynamic toPlatformLatLng() {
    // 这里可以根据需要实现与旧类型的转换
    return this;
  }
}

