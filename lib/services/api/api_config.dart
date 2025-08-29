// API configuration constants

class ApiConfig {
  // 生产后端基础地址（与旧项目一致，不带 /api 前缀）
  static const String baseUrl = 'http://129.211.172.21:3000/';
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int readTimeout = 30000; // 30 seconds - 匹配旧项目
  static const int sendTimeout = 30000; // 30 seconds
  static const int writeTimeout = 30000; // 30 seconds - 匹配旧项目
  
  // API endpoints
  static const String authLogin = 'auth/login';
  static const String authLoginWithCode = 'auth/login-with-code';
  static const String authRegister = 'auth/register';
  static const String authRegisterCode = 'auth/register-code';
  static const String authSendCode = 'auth/send-code';
  static const String authMe = 'auth/me';
  static const String authProfile = 'auth/profile';
  static const String authResetPassword = 'auth/reset-password';
  static const String authRefreshToken = 'auth/refresh-token';
  
  // GPT endpoints
  static const String gptChat = 'gpt/chat';
  static const String gptTraining = 'gpt/training';
  static const String gptTranslate = 'gpt/translate';
  static const String gptCustom = 'gpt/custom';
  static const String healthCheck = 'health';
  
  // Health endpoints
  static const String healthMood = 'v1/pet/health-mood';
  
  // Headers
  static const String contentType = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearerPrefix = 'Bearer ';
  
  // Response keys
  static const String successKey = 'success';
  static const String dataKey = 'data';
  static const String messageKey = 'message';
  static const String errorKey = 'error';

  // AMap (Gaode) configuration
  // 注意：amapWebKey需要使用高德开放平台的 Web服务 key（与SDK key不同）
  // 请在打包前替换为你自己的有效Key
  static const String amapWebKey = '6a49f6231381cca4a29c5952f717dcb6';
  static const String amapAppName = 'PetTalk';
}