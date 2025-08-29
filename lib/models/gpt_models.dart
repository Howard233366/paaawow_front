// 🔵 PetTalk GPT数据模型 - 完全匹配旧Android项目
// 严格按照旧项目GPT相关数据模型逐行复刻

/// 宠物聊天请求 - 匹配旧项目PetChatRequest
class PetChatRequest {
  final String userMessage;
  final String petName;
  final String petBreed;
  final String petAge;
  final List<String> recentEmotions;
  final List<String> recentBehaviors;

  const PetChatRequest({
    required this.userMessage,
    this.petName = '宠物',
    this.petBreed = '狗狗',
    this.petAge = '2岁',
    this.recentEmotions = const [],
    this.recentBehaviors = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'user_message': userMessage, 
      'pet_name': petName, 
      'pet_breed': petBreed, 
      'pet_age': petAge,
      'recent_emotions': recentEmotions,
      'recent_behaviors': recentBehaviors,
    };
  }
}

/// 宠物训练请求 - 匹配旧项目PetTrainingRequest
class PetTrainingRequest {
  final String userMessage;
  final String petName;
  final String petBreed;
  final String petAge;
  final List<String> behaviorIssues;

  const PetTrainingRequest({
    required this.userMessage,
    this.petName = '宠物',
    this.petBreed = '狗狗',
    this.petAge = '2岁',
    this.behaviorIssues = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'user_message': userMessage,
      'pet_name': petName,
      'pet_breed': petBreed,
      'pet_age': petAge,
      'behavior_issues': behaviorIssues,
    };
  }
}

/// 狗语翻译请求 - 匹配旧项目DogTranslationRequest
class DogTranslationRequest {
  final String dogSound;
  final String context;
  final String petName;
  final String petBreed;

  const DogTranslationRequest({
    required this.dogSound,
    this.context = '',
    this.petName = '宠物',
    this.petBreed = '狗狗',
  });

  Map<String, dynamic> toJson() {
    return {
      'dog_sound': dogSound,
      'context': context,
      'pet_name': petName,
      'pet_breed': petBreed,
    };
  }
}

/// 自定义聊天请求 - 匹配旧项目CustomChatRequest
class CustomChatRequest {
  final String message;
  final List<ChatMessage> conversationHistory;

  const CustomChatRequest({
    required this.message,
    this.conversationHistory = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'conversation_history': conversationHistory.map((m) => m.toJson()).toList(),
    };
  }
}

/// 聊天消息 - 匹配旧项目ChatMessage
class ChatMessage {
  final String role;
  final String content;
  final int timestamp;

  const ChatMessage({
    required this.role,
    required this.content,
    int? timestamp,
  }) : timestamp = timestamp ?? 0;

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      'timestamp': timestamp,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] ?? '',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] ?? 0,
    );
  }
}

/// GPT响应 - 匹配旧项目GPTResponse
class GPTResponse {
  final bool success;
  final String message;
  final String aiResponse;
  final String requestId;

  const GPTResponse({
    required this.success,
    required this.message,
    this.aiResponse = '',
    this.requestId = '',
  });

  factory GPTResponse.fromJson(Map<String, dynamic> json) {
    return GPTResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      aiResponse: json['ai_response'] ?? json['response'] ?? '',
      requestId: json['request_id'] ?? '',
    );
  }
}