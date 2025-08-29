// 寻宠功能后端API服务
// 负责与后端通信，获取宠物位置信息、提交导航请求等

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pet_talk/widgets/standard_baidu_map_widget.dart';
import 'package:pet_talk/models/pet_finder_models.dart';

/// 寻宠API服务
class PetFinderApiService {
  // TODO: 替换为实际的后端API地址
  static const String _baseUrl = 'https://api.pettalk.com/v1';
  
  static final PetFinderApiService _instance = PetFinderApiService._internal();
  factory PetFinderApiService() => _instance;
  PetFinderApiService._internal();

  /// 获取宠物实时位置信息
  /// [petId] 宠物ID
  /// 返回宠物位置数据，如果获取失败则返回模拟数据
  Future<PetLocationData?> getPetLocation(String petId) async {
    try {
      debugPrint('🐕 获取宠物位置信息: $petId');
      
      // TODO: 实现真实的API调用
      final url = Uri.parse('$_baseUrl/pets/$petId/location');
      
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

      debugPrint('🐕 API响应状态: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return PetLocationData.fromJson(data['data']);
        } else {
          debugPrint('🐕 API返回错误: ${data['message']}');
          return _getMockPetLocation(petId);
        }
      } else {
        debugPrint('🐕 HTTP错误: ${response.statusCode}');
        return _getMockPetLocation(petId);
      }
    } catch (e) {
      debugPrint('🐕 获取宠物位置失败: $e');
      // 网络错误时返回模拟数据
      return _getMockPetLocation(petId);
    }
  }

  /// 获取用户当前宠物列表
  /// 返回用户拥有的所有宠物的位置信息
  Future<List<PetLocationData>> getUserPets() async {
    try {
      debugPrint('🐕 获取用户宠物列表');
      
      // TODO: 实现真实的API调用
      final url = Uri.parse('$_baseUrl/user/pets');
      
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

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final petsData = data['data'] as List;
          return petsData.map((petData) => PetLocationData.fromJson(petData)).toList();
        } else {
          debugPrint('🐕 API返回错误: ${data['message']}');
          return _getMockPetsList();
        }
      } else {
        debugPrint('🐕 HTTP错误: ${response.statusCode}');
        return _getMockPetsList();
      }
    } catch (e) {
      debugPrint('🐕 获取宠物列表失败: $e');
      return _getMockPetsList();
    }
  }

  /// 提交导航请求
  /// [petId] 宠物ID
  /// [userLocation] 用户当前位置
  /// [routeType] 导航类型 (walking/driving/cycling)
  Future<bool> submitNavigationRequest({
    required String petId,
    required StandardLatLng userLocation,
    required String routeType,
  }) async {
    try {
      debugPrint('🧭 提交导航请求: $petId, 类型: $routeType');
      
      // TODO: 实现真实的API调用
      final url = Uri.parse('$_baseUrl/pets/$petId/navigate');
      
      final requestBody = {
        'petId': petId,
        'userLocation': {
          'latitude': userLocation.latitude,
          'longitude': userLocation.longitude,
        },
        'routeType': routeType,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_getAuthToken()}',
        },
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('请求超时');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        debugPrint('🧭 导航请求失败: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('🧭 导航请求异常: $e');
      return false;
    }
  }

  /// 更新宠物位置历史记录
  /// [petId] 宠物ID
  /// [startTime] 开始时间
  /// [endTime] 结束时间
  Future<List<PetLocationData>> getPetLocationHistory({
    required String petId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      debugPrint('🐕 获取宠物位置历史: $petId');
      
      // TODO: 实现真实的API调用
      final url = Uri.parse('$_baseUrl/pets/$petId/location/history').replace(
        queryParameters: {
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
        },
      );
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_getAuthToken()}',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('请求超时');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final historyData = data['data'] as List;
          return historyData.map((locationData) => PetLocationData.fromJson(locationData)).toList();
        }
      }
      
      // 返回空列表表示没有历史数据
      return [];
    } catch (e) {
      debugPrint('🐕 获取位置历史失败: $e');
      return [];
    }
  }

  /// 获取认证Token
  /// TODO: 实现真实的token获取逻辑
  String _getAuthToken() {
    // 这里应该从本地存储或状态管理中获取用户的认证token
    return 'mock_auth_token_12345';
  }

  /// 生成模拟宠物位置数据
  PetLocationData _getMockPetLocation(String petId) {
    debugPrint('🐕 使用模拟宠物数据: $petId');
    
    // 模拟不同的宠物位置
    final mockLocations = [
      const StandardLatLng(39.9042, 116.4074), // 北京天安门
      const StandardLatLng(39.9163, 116.3972), // 北京西单
      const StandardLatLng(39.9289, 116.3883), // 北京什刹海
    ];
    
    final locationIndex = petId.hashCode % mockLocations.length;
    final location = mockLocations[locationIndex];
    
    return PetLocationData(
      id: petId,
      name: 'Mr.Mittens',
      imageUrl: 'assets/images/profile/adding-pets.png',
      location: location,
      address: '北京市东城区天安门广场',
      lastUpdated: DateTime.now().subtract(Duration(minutes: (petId.hashCode % 10) + 1)),
      batteryLevel: 75 + (petId.hashCode % 25), // 75-100%
      isOnline: true,
    );
  }

  /// 生成模拟宠物列表
  List<PetLocationData> _getMockPetsList() {
    debugPrint('🐕 使用模拟宠物列表');
    
    return [
      PetLocationData(
        id: 'pet_001',
        name: 'Mr.Mittens',
        imageUrl: 'assets/images/profile/adding-pets.png',
        location: const StandardLatLng(39.9042, 116.4074),
        address: '北京市东城区天安门广场',
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 5)),
        batteryLevel: 85,
        isOnline: true,
      ),
      PetLocationData(
        id: 'pet_002', 
        name: 'Fluffy',
        imageUrl: 'assets/images/profile/adding-pets.png',
        location: const StandardLatLng(39.9163, 116.3972),
        address: '北京市西城区西单商业区',
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 12)),
        batteryLevel: 65,
        isOnline: true,
      ),
    ];
  }
}

/// API响应状态枚举
enum ApiResponseStatus {
  success,
  failure,
  timeout,
  networkError,
}

/// 统一API响应模型
class ApiResponse<T> {
  final ApiResponseStatus status;
  final T? data;
  final String? message;
  final int? statusCode;

  const ApiResponse({
    required this.status,
    this.data,
    this.message,
    this.statusCode,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse(
      status: ApiResponseStatus.success,
      data: data,
    );
  }

  factory ApiResponse.failure(String message, {int? statusCode}) {
    return ApiResponse(
      status: ApiResponseStatus.failure,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.timeout() {
    return const ApiResponse(
      status: ApiResponseStatus.timeout,
      message: '请求超时',
    );
  }

  factory ApiResponse.networkError(String message) {
    return ApiResponse(
      status: ApiResponseStatus.networkError,
      message: message,
    );
  }

  bool get isSuccess => status == ApiResponseStatus.success;
  bool get isFailure => status != ApiResponseStatus.success;
}
