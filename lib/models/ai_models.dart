// AI function related data models

enum AIFunction {
  chat,
  findPet,
  trainPet,
  healthExpert,
  emotionDisplay,
  tarotPrediction;

  String get displayName {
    switch (this) {
      case AIFunction.chat:
        return 'Chat'; // 对话
      case AIFunction.findPet:
        return 'Find Pet'; // AI寻宠
      case AIFunction.trainPet:
        return 'Train Pet'; // AI训宠
      case AIFunction.healthExpert:
        return 'Health Expert'; // AI健康专家
      case AIFunction.emotionDisplay:
        return 'Emotion Display'; // 情绪显化
      case AIFunction.tarotPrediction:
        return 'Tarot Prediction'; // 塔罗预测
    }
  }
}

class AIFunctionItem {
  final String id;
  final String name;
  final String title;
  final String iconPath;
  final String imagePath;
  final String description;
  final String targetScreen;
  final bool isComingSoon;

  const AIFunctionItem({
    required this.id,
    required this.name,
    required this.title,
    required this.iconPath,
    required this.imagePath,
    required this.description,
    required this.targetScreen,
    this.isComingSoon = false,
  });

  factory AIFunctionItem.fromJson(Map<String, dynamic> json) {
    return AIFunctionItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      iconPath: json['iconPath'] ?? '',
      imagePath: json['imagePath'] ?? '',
      description: json['description'] ?? '',
      targetScreen: json['targetScreen'] ?? '',
      isComingSoon: json['isComingSoon'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'iconPath': iconPath,
      'imagePath': imagePath,
      'description': description,
      'targetScreen': targetScreen,
      'isComingSoon': isComingSoon,
    };
  }
}

class AIFunctions {
  static const List<AIFunctionItem> functions = [
    AIFunctionItem(
      id: 'train',
      name: 'Training', // 训宠
      title: 'PET TRAINING ASSISTANT',
      iconPath: 'assets/images/AI_function/TRAIN.png',
      imagePath: 'assets/images/AI_function/training.png',
      description: 'A personal training assistant based on its breed, intelligence, abilities, and the present mood.',
      targetScreen: 'coming_soon',
      isComingSoon: true,
    ),
    AIFunctionItem(
      id: 'health',
      name: 'Health', // 健康监测
      title: 'HEALTH ASSISTANT',
      iconPath: 'assets/images/AI_function/HEAL.png',
      imagePath: 'assets/images/AI_function/health.png',
      description: 'The health assistant offers end-to-end services, from early detection to recovery tracking.',
      targetScreen: 'ai_chat',
      isComingSoon: false,
    ),
    AIFunctionItem(
      id: 'find',
      name: 'Find Pet', // 寻宠
      title: 'PET FINDER & VIRTUAL FENCE',
      iconPath: 'assets/images/AI_function/MA.png',
      imagePath: 'assets/images/AI_function/map.png',
      description: 'Combining multi-source positioning methods: GPS, 4G and its behavior analysis. AND you can set Virtual fences.',
      targetScreen: 'virtual_fence',
      isComingSoon: false,
    ),
    AIFunctionItem(
      id: 'tarot',
      name: 'Tarot', // 塔罗
      title: 'PET TAROT GUIDE',
      iconPath: 'assets/images/AI_function/TAR.png',
      imagePath: 'assets/images/AI_function/tarot.png',
      description: 'Discovering spiritual insights through pet tarot reading. The energy is from the GEMs.',
      targetScreen: 'ai_chat',
      isComingSoon: false,
    ),
    AIFunctionItem(
      id: 'emotion',
      name: 'Emotion', // 情绪
      title: 'PET TALK TRANSLATOR',
      iconPath: 'assets/images/AI_function/EMO.png',
      imagePath: 'assets/images/AI_function/emotion.png',
      description: 'Translating what it has said to you, and then you can care for it better.',
      targetScreen: 'ai_chat',
      isComingSoon: false,
    ),
    AIFunctionItem(
      id: 'camera',
      name: 'Camera', // 拍照
      title: 'AR EMOTION CAMERA',
      iconPath: 'assets/images/AI_function/CAM.png',
      imagePath: 'assets/images/AI_function/camera.png',
      description: 'The camera knows your pet\'s emotion, and show it on your phone.',
      targetScreen: 'coming_soon',
      isComingSoon: true,
    ),
  ];
}

class AIConversation {
  final String id;
  final String userId;
  final List<AIMessage> messages;
  final AIFunction function;
  final int timestamp;
  final bool isActive;

  const AIConversation({
    required this.id,
    required this.userId,
    required this.messages,
    required this.function,
    required this.timestamp,
    this.isActive = true,
  });

  factory AIConversation.fromJson(Map<String, dynamic> json) {
    return AIConversation(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => AIMessage.fromJson(e))
              .toList() ??
          [],
      function: AIFunction.values.firstWhere(
        (e) => e.name == json['function'],
        orElse: () => AIFunction.chat,
      ),
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'messages': messages.map((e) => e.toJson()).toList(),
      'function': function.name,
      'timestamp': timestamp,
      'isActive': isActive,
    };
  }
}

class AIMessage {
  final String id;
  final String content;
  final bool isUser;
  final int timestamp;
  final String? audioPath;
  final List<String> imageUrls;

  const AIMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.audioPath,
    this.imageUrls = const [],
  });

  factory AIMessage.fromJson(Map<String, dynamic> json) {
    return AIMessage(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      audioPath: json['audioPath'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp,
      'audioPath': audioPath,
      'imageUrls': imageUrls,
    };
  }
}

class AIFloatingButton {
  final AIFunction function;
  final String title;
  final String? iconRes;
  final bool isEnabled;

  const AIFloatingButton({
    required this.function,
    required this.title,
    this.iconRes,
    this.isEnabled = true,
  });

  factory AIFloatingButton.fromJson(Map<String, dynamic> json) {
    return AIFloatingButton(
      function: AIFunction.values.firstWhere(
        (e) => e.name == json['function'],
        orElse: () => AIFunction.chat,
      ),
      title: json['title'] ?? '',
      iconRes: json['iconRes'],
      isEnabled: json['isEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'function': function.name,
      'title': title,
      'iconRes': iconRes,
      'isEnabled': isEnabled,
    };
  }
}