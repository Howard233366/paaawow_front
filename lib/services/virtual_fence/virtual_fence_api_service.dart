// 虚拟围栏API服务 - 预留后端接口
// 负责与后端通信，处理虚拟围栏的CRUD操作

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pet_talk/widgets/standard_baidu_map_widget.dart';
import 'package:pet_talk/models/virtual_fence_models.dart';

/// 虚拟围栏创建请求数据模型
class VirtualFenceCreateRequest {
  final String name;
  final StandardLatLng center;
  final double radius;
  final String icon;
  final bool activateImmediately;

  const VirtualFenceCreateRequest({
    required this.name,
    required this.center,
    required this.radius,
    required this.icon,
    required this.activateImmediately,
  });

  /// 转换为JSON格式
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'center': {
        'latitude': center.latitude,
        'longitude': center.longitude,
      },
      'radius': radius,
      'icon': icon,
      'activate_immediately': activateImmediately,
      'type': 'safe', // 默认为安全区域
      'shape': 'circle', // 默认为圆形
    };
  }
}

/// 虚拟围栏API响应数据模型
class VirtualFenceResponse {
  final bool success;
  final String? message;
  final String? fenceId;
  final Map<String, dynamic>? data;

  const VirtualFenceResponse({
    required this.success,
    this.message,
    this.fenceId,
    this.data,
  });

  /// 从JSON创建响应对象
  factory VirtualFenceResponse.fromJson(Map<String, dynamic> json) {
    return VirtualFenceResponse(
      success: json['success'] ?? false,
      message: json['message'],
      fenceId: json['fence_id'],
      data: json['data'],
    );
  }
}

/// 虚拟围栏API服务
class VirtualFenceApiService {
  // TODO: 替换为实际的后端API地址
  static const String _baseUrl = 'https://api.pettalk.com/v1';
  
  static final VirtualFenceApiService _instance = VirtualFenceApiService._internal();
  factory VirtualFenceApiService() => _instance;
  VirtualFenceApiService._internal();

  /// 创建虚拟围栏
  /// [request] 围栏创建请求数据
  /// 返回是否创建成功
  Future<bool> createFence(VirtualFenceCreateRequest request) async {
    try {
      debugPrint('🔒 开始创建虚拟围栏...');
      debugPrint('🔒 围栏数据: ${request.toJson()}');
      
      // TODO: 实现真实的API调用
      final url = Uri.parse('$_baseUrl/virtual-fences');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_getAuthToken()}',
        },
        body: json.encode(request.toJson()),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('请求超时');
        },
      );

      debugPrint('🔒 API响应状态: ${response.statusCode}');
      debugPrint('🔒 API响应内容: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final apiResponse = VirtualFenceResponse.fromJson(responseData);
        
        if (apiResponse.success) {
          debugPrint('🔒 ✅ 虚拟围栏创建成功: ${apiResponse.fenceId}');
          return true;
        } else {
          debugPrint('🔒 ❌ 虚拟围栏创建失败: ${apiResponse.message}');
          return false;
        }
      } else {
        debugPrint('🔒 ❌ HTTP错误: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('🔒 ❌ 创建虚拟围栏异常: $e');
      
      // 如果是网络错误，返回模拟成功（开发阶段）
      if (e.toString().contains('Failed host lookup') || 
          e.toString().contains('Connection refused') ||
          e.toString().contains('请求超时')) {
        debugPrint('🔒 ⚠️ 网络连接失败，使用模拟成功（开发模式）');
        await _simulateApiCall();
        return true;
      }
      
      return false;
    }
  }

  /// 获取用户的虚拟围栏列表
  /// [userId] 用户ID
  /// 返回围栏列表
  Future<List<VirtualFence>> getUserFences(String userId) async {
    try {
      debugPrint('🔒 获取用户虚拟围栏列表: $userId');
      
      // TODO: 实现真实的API调用
      final url = Uri.parse('$_baseUrl/virtual-fences?user_id=$userId');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_getAuthToken()}',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('请求超时');
        },
      );

      debugPrint('🔒 API响应状态: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> fencesJson = responseData['data'];
          return fencesJson.map((json) => VirtualFence.fromJson(json)).toList();
        } else {
          debugPrint('🔒 API返回错误: ${responseData['message']}');
          return [];
        }
      } else {
        debugPrint('🔒 HTTP错误: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('🔒 获取围栏列表异常: $e');
      return [];
    }
  }

  /// 删除虚拟围栏
  /// [fenceId] 围栏ID
  /// 返回是否删除成功
  Future<bool> deleteFence(String fenceId) async {
    try {
      debugPrint('🔒 删除虚拟围栏: $fenceId');
      
      // TODO: 实现真实的API调用
      final url = Uri.parse('$_baseUrl/virtual-fences/$fenceId');
      
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_getAuthToken()}',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('请求超时');
        },
      );

      debugPrint('🔒 API响应状态: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('🔒 ✅ 虚拟围栏删除成功');
        return true;
      } else {
        debugPrint('🔒 ❌ HTTP错误: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('🔒 ❌ 删除虚拟围栏异常: $e');
      return false;
    }
  }

  /// 更新虚拟围栏
  /// [fenceId] 围栏ID
  /// [request] 更新请求数据
  /// 返回是否更新成功
  Future<bool> updateFence(String fenceId, VirtualFenceCreateRequest request) async {
    try {
      debugPrint('🔒 更新虚拟围栏: $fenceId');
      debugPrint('🔒 更新数据: ${request.toJson()}');
      
      // TODO: 实现真实的API调用
      final url = Uri.parse('$_baseUrl/virtual-fences/$fenceId');
      
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_getAuthToken()}',
        },
        body: json.encode(request.toJson()),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('请求超时');
        },
      );

      debugPrint('🔒 API响应状态: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final apiResponse = VirtualFenceResponse.fromJson(responseData);
        
        if (apiResponse.success) {
          debugPrint('🔒 ✅ 虚拟围栏更新成功');
          return true;
        } else {
          debugPrint('🔒 ❌ 虚拟围栏更新失败: ${apiResponse.message}');
          return false;
        }
      } else {
        debugPrint('🔒 ❌ HTTP错误: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('🔒 ❌ 更新虚拟围栏异常: $e');
      return false;
    }
  }

  /// 激活/停用虚拟围栏
  /// [fenceId] 围栏ID
  /// [isActive] 是否激活
  /// 返回是否操作成功
  Future<bool> toggleFenceStatus(String fenceId, bool isActive) async {
    try {
      debugPrint('🔒 ${isActive ? "激活" : "停用"}虚拟围栏: $fenceId');
      
      // TODO: 实现真实的API调用
      final url = Uri.parse('$_baseUrl/virtual-fences/$fenceId/toggle');
      
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_getAuthToken()}',
        },
        body: json.encode({
          'is_active': isActive,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('请求超时');
        },
      );

      debugPrint('🔒 API响应状态: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        debugPrint('🔒 ✅ 虚拟围栏状态更新成功');
        return true;
      } else {
        debugPrint('🔒 ❌ HTTP错误: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('🔒 ❌ 更新围栏状态异常: $e');
      return false;
    }
  }

  /// 获取认证令牌（预留）
  /// TODO: 实现真实的认证逻辑
  String _getAuthToken() {
    // 这里应该从安全存储中获取用户的认证令牌
    // 目前返回模拟令牌
    return 'mock_auth_token_12345';
  }

  /// 模拟API调用（开发阶段使用）
  Future<void> _simulateApiCall() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  /// 测试API连接
  Future<bool> testConnection() async {
    try {
      debugPrint('🔒 测试虚拟围栏API连接...');
      
      final url = Uri.parse('$_baseUrl/health');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('连接超时');
        },
      );

      debugPrint('🔒 API连接测试结果: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        debugPrint('🔒 ✅ API连接正常');
        return true;
      } else {
        debugPrint('🔒 ❌ API连接异常: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('🔒 ❌ API连接测试失败: $e');
      return false;
    }
  }
}
