// Common data models and utilities

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? errorCode;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errorCode,
  });

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error(String message, {String? errorCode}) {
    return ApiResponse(
      success: false,
      message: message,
      errorCode: errorCode,
    );
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      message: json['message'],
      errorCode: json['errorCode'],
    );
  }

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return {
      'success': success,
      'data': data != null ? toJsonT(data as T) : null,
      'message': message,
      'errorCode': errorCode,
    };
  }
}

enum LoadingState {
  idle,
  loading,
  success,
  error;

  bool get isLoading => this == LoadingState.loading;
  bool get isSuccess => this == LoadingState.success;
  bool get isError => this == LoadingState.error;
  bool get isIdle => this == LoadingState.idle;
}

class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  const Result._({
    this.data,
    this.error,
    required this.isSuccess,
  });

  factory Result.success(T data) {
    return Result._(
      data: data,
      isSuccess: true,
    );
  }

  factory Result.error(String error) {
    return Result._(
      error: error,
      isSuccess: false,
    );
  }

  bool get isError => !isSuccess;

  R when<R>({
    required R Function(T data) success,
    required R Function(String error) error,
  }) {
    if (isSuccess && data != null) {
      return success(data!);
    } else {
      return error(this.error ?? 'Unknown error');
    }
  }

  T? get dataOrNull => isSuccess ? data : null;
  String? get errorOrNull => isError ? error : null;
}

enum PetEmotion {
  happy,
  hungry,
  playful,
  anxious,
  sleepy;

  String get displayName {
    switch (this) {
      case PetEmotion.happy:
        return '开心';
      case PetEmotion.hungry:
        return '饥饿';
      case PetEmotion.playful:
        return '顽皮';
      case PetEmotion.anxious:
        return '焦虑';
      case PetEmotion.sleepy:
        return '困倦';
    }
  }

  String get emoji {
    switch (this) {
      case PetEmotion.happy:
        return '😊';
      case PetEmotion.hungry:
        return '🍖';
      case PetEmotion.playful:
        return '🎾';
      case PetEmotion.anxious:
        return '😰';
      case PetEmotion.sleepy:
        return '😴';
    }
  }
}

class TranslationRequest {
  final String audioPath;
  final String? userId;
  final String? petType;
  final int timestamp;

  const TranslationRequest({
    required this.audioPath,
    this.userId,
    this.petType,
    required this.timestamp,
  });

  factory TranslationRequest.fromJson(Map<String, dynamic> json) {
    return TranslationRequest(
      audioPath: json['audioPath'] ?? '',
      userId: json['userId'],
      petType: json['petType'],
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audioPath': audioPath,
      'userId': userId,
      'petType': petType,
      'timestamp': timestamp,
    };
  }
}

class TranslationResponse {
  final bool success;
  final String translatedText;
  final double confidence;
  final PetEmotion detectedEmotion;
  final int processingTime;
  final String? errorMessage;

  const TranslationResponse({
    required this.success,
    required this.translatedText,
    required this.confidence,
    required this.detectedEmotion,
    required this.processingTime,
    this.errorMessage,
  });

  factory TranslationResponse.fromJson(Map<String, dynamic> json) {
    return TranslationResponse(
      success: json['success'] ?? false,
      translatedText: json['translatedText'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      detectedEmotion: PetEmotion.values.firstWhere(
        (e) => e.name == json['detectedEmotion'],
        orElse: () => PetEmotion.happy,
      ),
      processingTime: json['processingTime'] ?? 0,
      errorMessage: json['errorMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'translatedText': translatedText,
      'confidence': confidence,
      'detectedEmotion': detectedEmotion.name,
      'processingTime': processingTime,
      'errorMessage': errorMessage,
    };
  }
}

class TranslationHistory {
  final String id;
  final String originalAudioPath;
  final String translatedText;
  final int timestamp;
  final String? petType;
  final double confidence;
  final PetEmotion detectedEmotion;

  const TranslationHistory({
    required this.id,
    required this.originalAudioPath,
    required this.translatedText,
    required this.timestamp,
    this.petType,
    required this.confidence,
    required this.detectedEmotion,
  });

  factory TranslationHistory.fromJson(Map<String, dynamic> json) {
    return TranslationHistory(
      id: json['id'] ?? '',
      originalAudioPath: json['originalAudioPath'] ?? '',
      translatedText: json['translatedText'] ?? '',
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      petType: json['petType'],
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      detectedEmotion: PetEmotion.values.firstWhere(
        (e) => e.name == json['detectedEmotion'],
        orElse: () => PetEmotion.happy,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalAudioPath': originalAudioPath,
      'translatedText': translatedText,
      'timestamp': timestamp,
      'petType': petType,
      'confidence': confidence,
      'detectedEmotion': detectedEmotion.name,
    };
  }
}