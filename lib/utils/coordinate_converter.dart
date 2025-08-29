// 坐标系转换工具
// 严格按照百度地图官方文档实现坐标系转换
// 参考：https://lbsyun.baidu.com/faq/api?title=androidsdk/guide/create-map/location

import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:pet_talk/widgets/standard_baidu_map_widget.dart';

/// 坐标系转换工具类
/// 支持WGS84、GCJ02、BD09ll坐标系之间的转换
class CoordinateConverter {
  static const double _x_PI = 3.14159265358979324 * 3000.0 / 180.0;
  static const double _PI = 3.1415926535897932384626;
  static const double _a = 6378245.0;
  static const double _ee = 0.00669342162296594323;

  /// WGS84坐标转GCJ02坐标（GPS坐标转火星坐标）
  static StandardLatLng wgs84ToGcj02(StandardLatLng wgs84) {
    debugPrint('🌐 [坐标转换] WGS84 → GCJ02: (${wgs84.latitude}, ${wgs84.longitude})');
    
    if (_outOfChina(wgs84.latitude, wgs84.longitude)) {
      debugPrint('🌐 [坐标转换] 位置在中国境外，无需转换');
      return wgs84;
    }
    
    double dlat = _transformlat(wgs84.longitude - 105.0, wgs84.latitude - 35.0);
    double dlng = _transformlng(wgs84.longitude - 105.0, wgs84.latitude - 35.0);
    double radlat = wgs84.latitude / 180.0 * _PI;
    double magic = math.sin(radlat);
    magic = 1 - _ee * magic * magic;
    double sqrtmagic = math.sqrt(magic);
    dlat = (dlat * 180.0) / ((_a * (1 - _ee)) / (magic * sqrtmagic) * _PI);
    dlng = (dlng * 180.0) / (_a / sqrtmagic * math.cos(radlat) * _PI);
    double mglat = wgs84.latitude + dlat;
    double mglng = wgs84.longitude + dlng;
    
    final result = StandardLatLng(mglat, mglng);
    debugPrint('🌐 [坐标转换] GCJ02结果: (${result.latitude}, ${result.longitude})');
    return result;
  }

  /// GCJ02坐标转BD09ll坐标（火星坐标转百度坐标）
  static StandardLatLng gcj02ToBd09ll(StandardLatLng gcj02) {
    debugPrint('🌐 [坐标转换] GCJ02 → BD09ll: (${gcj02.latitude}, ${gcj02.longitude})');
    
    double z = math.sqrt(gcj02.longitude * gcj02.longitude + gcj02.latitude * gcj02.latitude) + 0.00002 * math.sin(gcj02.latitude * _x_PI);
    double theta = math.atan2(gcj02.latitude, gcj02.longitude) + 0.000003 * math.cos(gcj02.longitude * _x_PI);
    double bd_lng = z * math.cos(theta) + 0.0065;
    double bd_lat = z * math.sin(theta) + 0.006;
    
    final result = StandardLatLng(bd_lat, bd_lng);
    debugPrint('🌐 [坐标转换] BD09ll结果: (${result.latitude}, ${result.longitude})');
    return result;
  }

  /// WGS84坐标直接转BD09ll坐标（GPS坐标直接转百度坐标）
  /// 这是我们主要需要的转换函数
  static StandardLatLng wgs84ToBd09ll(StandardLatLng wgs84) {
    debugPrint('🌐 [坐标转换] WGS84 → BD09ll 开始转换...');
    debugPrint('🌐 [坐标转换] 输入WGS84: (${wgs84.latitude}, ${wgs84.longitude})');
    
    // 两步转换：WGS84 → GCJ02 → BD09ll
    final gcj02 = wgs84ToGcj02(wgs84);
    final bd09ll = gcj02ToBd09ll(gcj02);
    
    debugPrint('🌐 [坐标转换] 最终BD09ll: (${bd09ll.latitude}, ${bd09ll.longitude})');
    debugPrint('🌐 [坐标转换] 转换完成 ✅');
    
    return bd09ll;
  }

  /// BD09ll坐标转WGS84坐标（百度坐标转GPS坐标）
  static StandardLatLng bd09llToWgs84(StandardLatLng bd09ll) {
    debugPrint('🌐 [坐标转换] BD09ll → WGS84: (${bd09ll.latitude}, ${bd09ll.longitude})');
    
    // 两步转换：BD09ll → GCJ02 → WGS84
    final gcj02 = bd09llToGcj02(bd09ll);
    final wgs84 = gcj02ToWgs84(gcj02);
    
    debugPrint('🌐 [坐标转换] 最终WGS84: (${wgs84.latitude}, ${wgs84.longitude})');
    return wgs84;
  }

  /// BD09ll坐标转GCJ02坐标（百度坐标转火星坐标）
  static StandardLatLng bd09llToGcj02(StandardLatLng bd09ll) {
    double x = bd09ll.longitude - 0.0065;
    double y = bd09ll.latitude - 0.006;
    double z = math.sqrt(x * x + y * y) - 0.00002 * math.sin(y * _x_PI);
    double theta = math.atan2(y, x) - 0.000003 * math.cos(x * _x_PI);
    double gcj_lng = z * math.cos(theta);
    double gcj_lat = z * math.sin(theta);
    return StandardLatLng(gcj_lat, gcj_lng);
  }

  /// GCJ02坐标转WGS84坐标（火星坐标转GPS坐标）
  static StandardLatLng gcj02ToWgs84(StandardLatLng gcj02) {
    if (_outOfChina(gcj02.latitude, gcj02.longitude)) {
      return gcj02;
    }
    
    double dlat = _transformlat(gcj02.longitude - 105.0, gcj02.latitude - 35.0);
    double dlng = _transformlng(gcj02.longitude - 105.0, gcj02.latitude - 35.0);
    double radlat = gcj02.latitude / 180.0 * _PI;
    double magic = math.sin(radlat);
    magic = 1 - _ee * magic * magic;
    double sqrtmagic = math.sqrt(magic);
    dlat = (dlat * 180.0) / ((_a * (1 - _ee)) / (magic * sqrtmagic) * _PI);
    dlng = (dlng * 180.0) / (_a / sqrtmagic * math.cos(radlat) * _PI);
    double mglat = gcj02.latitude - dlat;
    double mglng = gcj02.longitude - dlng;
    return StandardLatLng(mglat, mglng);
  }

  /// 判断是否在中国境外
  static bool _outOfChina(double lat, double lng) {
    return lng < 72.004 || lng > 137.8347 || lat < 0.8293 || lat > 55.8271;
  }

  /// 纬度转换辅助函数
  static double _transformlat(double lng, double lat) {
    double ret = -100.0 + 2.0 * lng + 3.0 * lat + 0.2 * lat * lat + 0.1 * lng * lat + 0.2 * math.sqrt(lng.abs());
    ret += (20.0 * math.sin(6.0 * lng * _PI) + 20.0 * math.sin(2.0 * lng * _PI)) * 2.0 / 3.0;
    ret += (20.0 * math.sin(lat * _PI) + 40.0 * math.sin(lat / 3.0 * _PI)) * 2.0 / 3.0;
    ret += (160.0 * math.sin(lat / 12.0 * _PI) + 320 * math.sin(lat * _PI / 30.0)) * 2.0 / 3.0;
    return ret;
  }

  /// 经度转换辅助函数
  static double _transformlng(double lng, double lat) {
    double ret = 300.0 + lng + 2.0 * lat + 0.1 * lng * lng + 0.1 * lng * lat + 0.1 * math.sqrt(lng.abs());
    ret += (20.0 * math.sin(6.0 * lng * _PI) + 20.0 * math.sin(2.0 * lng * _PI)) * 2.0 / 3.0;
    ret += (20.0 * math.sin(lng * _PI) + 40.0 * math.sin(lng / 3.0 * _PI)) * 2.0 / 3.0;
    ret += (150.0 * math.sin(lng / 12.0 * _PI) + 300.0 * math.sin(lng / 30.0 * _PI)) * 2.0 / 3.0;
    return ret;
  }
}
