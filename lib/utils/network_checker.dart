// 网络连接检查工具
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NetworkChecker {
  /// 检查网络连接状态
  static Future<bool> checkInternetConnection() async {
    try {
      debugPrint('🌐 开始检查网络连接...');
      
      // 尝试连接百度地图API服务器
      final response = await http.get(
        Uri.parse('https://api.map.baidu.com/'),
        headers: {'User-Agent': 'PetTalk/1.0'},
      ).timeout(const Duration(seconds: 5));
      
      debugPrint('🌐 百度地图API连接状态: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 404; // 404也说明能连接到服务器
    } catch (e) {
      debugPrint('🌐 ❌ 网络连接检查失败: $e');
      return false;
    }
  }

  /// 检查百度地图API Key有效性（使用正确的API）
  static Future<bool> checkBaiduApiKey(String apiKey) async {
    try {
      debugPrint('🔑 开始检查百度地图API Key有效性...');
      debugPrint('🔑 API Key: ${apiKey.substring(0, 8)}...(已隐藏)');
      
      // 使用百度地图静态图API来验证API Key（这个API权限要求较低）
      final response = await http.get(
        Uri.parse('https://api.map.baidu.com/staticimage/v2?ak=$apiKey&center=116.404,39.915&width=100&height=100&zoom=11'),
        headers: {'User-Agent': 'PetTalk/1.0'},
      ).timeout(const Duration(seconds: 10));
      
      debugPrint('🔑 API Key验证响应状态: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        // 静态图API返回200表示API Key有效
        debugPrint('🔑 ✅ API Key验证成功');
        return true;
      } else {
        debugPrint('🔑 ❌ API Key验证失败，HTTP状态: ${response.statusCode}');
        // 尝试解析错误响应
        if (response.body.isNotEmpty) {
          debugPrint('🔑 错误响应: ${response.body.length > 200 ? response.body.substring(0, 200) + "..." : response.body}');
        }
        return false;
      }
    } catch (e) {
      debugPrint('🔑 ❌ API Key验证过程出错: $e');
      return false;
    }
  }

  /// 综合网络和API检查
  static Future<Map<String, dynamic>> performFullNetworkCheck() async {
    debugPrint('🔍 ========== 开始全面网络检查 ==========');
    
    final results = <String, dynamic>{};
    
    // 1. 基础网络连接
    results['internetConnection'] = await checkInternetConnection();
    debugPrint('🔍 网络连接: ${results['internetConnection'] ? "✅ 正常" : "❌ 异常"}');
    
    // 2. 百度地图API Key
    const apiKey = 'vK6hTnQzAxoZtak72lsgPu6CqNhvtKtc';
    results['apiKeyValid'] = await checkBaiduApiKey(apiKey);
    debugPrint('🔍 API Key: ${results['apiKeyValid'] ? "✅ 有效" : "❌ 无效"}');
    
    // 3. DNS解析检查
    try {
      final addresses = await InternetAddress.lookup('api.map.baidu.com');
      results['dnsResolution'] = addresses.isNotEmpty;
      debugPrint('🔍 DNS解析: ${results['dnsResolution'] ? "✅ 正常" : "❌ 异常"}');
      if (addresses.isNotEmpty) {
        debugPrint('🔍 解析到的IP: ${addresses.first.address}');
      }
    } catch (e) {
      results['dnsResolution'] = false;
      debugPrint('🔍 DNS解析: ❌ 失败 - $e');
    }
    
    debugPrint('🔍 ========== 网络检查完成 ==========');
    return results;
  }
}
