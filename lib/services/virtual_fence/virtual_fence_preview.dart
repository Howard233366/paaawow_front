// 虚拟围栏预览管理器
// 专门管理创建过程中的预览圆圈，确保只有一个

import 'package:flutter/material.dart';
import 'package:pet_talk/widgets/standard_baidu_map_widget.dart';

/// 虚拟围栏预览管理器
/// 负责管理创建过程中的预览圆圈状态
class VirtualFencePreview {
  // 预览状态
  bool _isActive = false;
  StandardLatLng? _center;
  double _radius = 50.0;
  
  // 预览圆圈的固定样式
  static const Color _fillColor = Color(0x80FF0000); // 半透明红色
  static const Color _strokeColor = Color(0xFFFF0000); // 纯红色
  static const double _strokeWidth = 3.0; // 圆圈边框宽度
  static const String _previewId = 'virtual_fence_preview';
  
  // 性能优化：缓存上次生成的圆圈，避免重复创建
  StandardCircle? _cachedCircle;
  double? _lastCachedRadius;
  StandardLatLng? _lastCachedCenter;

  /// 开始预览模式
  void startPreview() {
    debugPrint('🔄 [PREVIEW] 开始预览模式');
    _isActive = true;
    _center = null; // 清空位置，等待用户点击
    // 清空缓存
    _cachedCircle = null;
    _lastCachedRadius = null;
    _lastCachedCenter = null;
  }

  /// 结束预览模式
  void endPreview() {
    debugPrint('🔄 [PREVIEW] 结束预览模式');
    _isActive = false;
    _center = null;
    _radius = 50.0;
    // 清空缓存
    _cachedCircle = null;
    _lastCachedRadius = null;
    _lastCachedCenter = null;
  }

  /// 设置预览圆圈的中心位置
  void setCenter(StandardLatLng center) {
    _center = center;
    // 位置变化时清空缓存
    if (_lastCachedCenter == null || 
        (_lastCachedCenter!.latitude - center.latitude).abs() > 0.00001 ||
        (_lastCachedCenter!.longitude - center.longitude).abs() > 0.00001) {
      _cachedCircle = null;
      _lastCachedCenter = null;
    }
  }

  /// 设置预览圆圈的半径
  void setRadius(double radius) {
    _radius = radius;
    // 半径变化时清空缓存
    if (_lastCachedRadius == null || (_lastCachedRadius! - radius).abs() > 0.1) {
      _cachedCircle = null;
      _lastCachedRadius = null;
    }
  }

  /// 获取当前预览圆圈（如果存在）
  StandardCircle? getCurrentCircle() {
    if (!_isActive || _center == null) {
      debugPrint('🔄 [PREVIEW] 预览未激活或无中心位置，返回null');
      return null;
    }

    // 检查是否可以使用缓存的圆圈
    if (_cachedCircle != null && 
        _lastCachedRadius == _radius && 
        _lastCachedCenter != null &&
        (_lastCachedCenter!.latitude - _center!.latitude).abs() < 0.00001 &&
        (_lastCachedCenter!.longitude - _center!.longitude).abs() < 0.00001) {
      debugPrint('🔄 [PREVIEW] 使用缓存的预览圆圈: $_previewId');
      return _cachedCircle;
    }

    // 创建新的圆圈并缓存
    _cachedCircle = StandardCircle(
      id: _previewId,
      center: _center!,
      radius: _radius,
      fillColor: _fillColor,
      strokeColor: _strokeColor,
      strokeWidth: _strokeWidth,
    );
    _lastCachedRadius = _radius;
    _lastCachedCenter = _center;
    debugPrint('🔄 [PREVIEW] 创建新的预览圆圈: $_previewId (半径: ${_radius}m)');
    return _cachedCircle;
  }

  /// 检查是否处于预览模式
  bool get isActive => _isActive;

  /// 检查是否已设置中心位置
  bool get hasCenter => _center != null;

  /// 获取当前中心位置
  StandardLatLng? get center => _center;

  /// 获取当前半径
  double get radius => _radius;

  /// 获取预览圆圈的ID
  static String get previewId => _previewId;
}
