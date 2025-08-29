// 本地虚拟围栏存储服务（SharedPreferences 持久化）

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pet_talk/models/virtual_fence_models.dart';

class VirtualFenceLocalStore {
  static const String _storageKey = 'virtual_fences_v1';

  Future<SharedPreferences> _prefs() async => SharedPreferences.getInstance();

  Future<List<VirtualFence>> loadFences() async {
    final prefs = await _prefs();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final List<dynamic> list = json.decode(jsonString);
      return list
          .whereType<Map<String, dynamic>>()
          .map((e) => VirtualFence.fromJson(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveFences(List<VirtualFence> fences) async {
    final prefs = await _prefs();
    final list = fences.map((f) => f.toJson()).toList();
    return prefs.setString(_storageKey, json.encode(list));
  }

  Future<void> addFence(VirtualFence fence) async {
    final fences = await loadFences();
    
    // 🔧 修复重复问题：检查是否已存在相同ID的围栏
    final existingIndex = fences.indexWhere((f) => f.id == fence.id);
    if (existingIndex >= 0) {
      // 如果已存在，更新而不是添加
      fences[existingIndex] = fence;
      print('🔄 [STORE] 更新已存在的围栏: ${fence.id}');
    } else {
      // 如果不存在，添加新围栏
      fences.add(fence);
      print('🔄 [STORE] 添加新围栏: ${fence.id}');
    }
    
    await saveFences(fences);
    print('🔄 [STORE] 当前本地围栏总数: ${fences.length}');
  }

  Future<void> deleteFence(String fenceId) async {
    final fences = await loadFences();
    fences.removeWhere((f) => f.id == fenceId);
    await saveFences(fences);
  }

  Future<void> updateFence(VirtualFence updated) async {
    final fences = await loadFences();
    final index = fences.indexWhere((f) => f.id == updated.id);
    if (index >= 0) {
      fences[index] = updated;
      await saveFences(fences);
    }
  }
}


