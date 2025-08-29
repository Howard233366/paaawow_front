// 🔵 PetTalk GPT存储库 - 完全匹配旧Android项目GPTRepository.kt
// 严格按照旧项目GPTRepository.kt逐行复刻

import 'dart:developer' as developer;
import 'package:pet_talk/services/api/api_service.dart';
import 'package:pet_talk/models/gpt_models.dart';
import 'package:pet_talk/models/common_models.dart';

/// GPT存储库 - 匹配旧项目GPTRepository
class GPTRepository {
  static const String _tag = 'GPTRepository';
  
  // 单例模式 - 匹配旧项目getInstance
  static GPTRepository? _instance;
  static GPTRepository get instance => _instance ??= GPTRepository._();
  
  final ApiService _apiService = ApiService();
  
  GPTRepository._();

  /// 宠物一般聊天 - 匹配旧项目petGeneralChat
  Future<Result<String>> petGeneralChat({
    required String message,
    String petName = '宠物',
    String petBreed = '狗狗', 
    String petAge = '2岁',
    List<String> recentEmotions = const [],
    List<String> recentBehaviors = const [],
  }) async {
    try {
      final request = PetChatRequest(
        userMessage: message,
        petName: petName,
        petBreed: petBreed,
        petAge: petAge,
        recentEmotions: recentEmotions,
        recentBehaviors: recentBehaviors,
      );

      final result = await _apiService.petGeneralChat(request.toJson());
      
      if (result.isSuccess) {
        final responseData = result.data!;
        final aiResponse = responseData['ai_response'] ?? responseData['response'] ?? '';
        return Result.success(aiResponse.toString());
      } else {
        return Result.error(result.error ?? '宠物聊天失败');
      }
    } catch (e) {
      developer.log('Pet general chat error: $e', name: _tag);
      return Result.error('宠物聊天失败: ${e.toString()}');
    }
  }

  /// 宠物训练建议 - 匹配旧项目petTrainingAdvice
  Future<Result<String>> petTrainingAdvice({
    required String message,
    String petName = '宠物',
    String petBreed = '狗狗',
    String petAge = '2岁', 
    List<String> behaviorIssues = const [],
  }) async {
    try {
      final request = PetTrainingRequest(
        userMessage: message,
        petName: petName,
        petBreed: petBreed,
        petAge: petAge,
        behaviorIssues: behaviorIssues,
      );

      final result = await _apiService.petTrainingAdvice(request.toJson());
      
      if (result.isSuccess) {
        final responseData = result.data!;
        final aiResponse = responseData['ai_response'] ?? responseData['response'] ?? '';
        return Result.success(aiResponse.toString());
      } else {
        return Result.error(result.error ?? '训练建议失败');
      }
    } catch (e) {
      developer.log('Pet training advice error: $e', name: _tag);
      return Result.error('训练建议失败: ${e.toString()}');
    }
  }

  /// 狗语翻译 - 匹配旧项目dogLanguageTranslation
  Future<Result<String>> dogLanguageTranslation({
    required String dogSound,
    String context = '',
    String petName = '宠物',
    String petBreed = '狗狗',
  }) async {
    try {
      final request = DogTranslationRequest(
        dogSound: dogSound,
        context: context,
        petName: petName,
        petBreed: petBreed,
      );

      final result = await _apiService.dogLanguageTranslation(request.toJson());
      
      if (result.isSuccess) {
        final responseData = result.data!;
        final aiResponse = responseData['ai_response'] ?? responseData['response'] ?? '';
        return Result.success(aiResponse.toString());
      } else {
        return Result.error(result.error ?? '狗语翻译失败');
      }
    } catch (e) {
      developer.log('Dog language translation error: $e', name: _tag);
      return Result.error('狗语翻译失败: ${e.toString()}');
    }
  }

  /// 自定义聊天 - 匹配旧项目customChat
  Future<Result<String>> customChat({
    required String message,
    List<ChatMessage> conversationHistory = const [],
  }) async {
    try {
      final request = CustomChatRequest(
        message: message,
        conversationHistory: conversationHistory,
      );

      final result = await _apiService.petGeneralChat(request.toJson());
      
      if (result.isSuccess) {
        final responseData = result.data!;
        final aiResponse = responseData['ai_response'] ?? responseData['response'] ?? '';
        return Result.success(aiResponse.toString());
      } else {
        return Result.error(result.error ?? '自定义聊天失败');
      }
    } catch (e) {
      developer.log('Custom chat error: $e', name: _tag);
      return Result.error('自定义聊天失败: ${e.toString()}');
    }
  }

  /// GPT服务健康检查 - 对齐旧项目healthCheck
  Future<Result<String>> gptHealthCheck() async {
    try {
      final result = await _apiService.gptHealthCheck();
      if (result.isSuccess && result.data != null) {
        final health = result.data!;
        final status = health.version != null && health.version!.isNotEmpty
            ? 'version=${health.version}'
            : 'healthy';
        return Result.success(status);
      } else {
        return Result.error(result.error ?? '服务不可用');
      }
    } catch (e) {
      developer.log('GPT health check error: $e', name: _tag);
      return Result.error('服务不可用: ${e.toString()}');
    }
  }
}