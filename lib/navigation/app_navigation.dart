// 🔵 PetTalk 应用导航 - 完全匹配旧Android项目的PetTalkNavigation.kt
// 严格按照旧项目PetTalkNavigation.kt逐行复刻导航配置

import 'package:go_router/go_router.dart';
import 'package:pet_talk/screens/auth/login_screen.dart';
import 'package:pet_talk/screens/auth/register_screen.dart';
import 'package:pet_talk/screens/navigation/pet_talk_navigation.dart';
import 'package:pet_talk/screens/community/community_screen.dart';
import 'package:pet_talk/screens/profile/profile_screen.dart';
import 'package:pet_talk/screens/ai/coming_soon_screen.dart';
import 'package:pet_talk/screens/ai/ai_function_select_screen.dart';
import 'package:pet_talk/screens/ai/ai_chat_screen.dart';
import 'package:pet_talk/screens/collar/collar_detail_screen.dart';
import 'package:pet_talk/screens/health/health_information_screen.dart';
import 'package:pet_talk/screens/health/health_data_screen.dart';
import 'package:pet_talk/screens/health/health_calendar_screen.dart';
import 'package:pet_talk/screens/profile/adding_pets_screen.dart';
import 'package:pet_talk/screens/profile/feedback_screen.dart';
import 'package:pet_talk/screens/profile/about_us_screen.dart';
import 'package:pet_talk/screens/profile/system_alert_screen.dart';
import 'package:pet_talk/screens/profile/first_aid_screen.dart';
import 'package:pet_talk/screens/profile/profile_edit_screen.dart';
import 'package:pet_talk/models/ai_models.dart';

/// 应用导航配置 
class AppNavigation {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      // ==================== 认证路由 - 匹配旧项目 ====================
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // ==================== 主要功能路由 - 匹配旧项目 ====================
      GoRoute(
        path: '/home', 
        builder: (context, state) => const PetTalkNavigation(),
      ),
      GoRoute(
        path: '/community',
        builder: (context, state) => const CommunityScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      // ==================== Profile 相关 - 对齐旧项目 ====================
      GoRoute(
        path: '/adding_pets',
        builder: (context, state) => const AddingPetsScreen(),
      ),
      GoRoute(
        path: '/feedback',
        builder: (context, state) => const FeedbackScreen(),
      ),
      GoRoute(
        path: '/about_us',
        builder: (context, state) => const AboutUsScreen(),
      ),
      GoRoute(
        path: '/system_alert',
        builder: (context, state) => const SystemAlertScreen(),
      ),
      GoRoute(
        path: '/first_aid',
        builder: (context, state) => const FirstAidScreen(),
      ),
      GoRoute(
        path: '/profile_edit',
        builder: (context, state) => const ProfileEditScreen(),
      ),
      
      // ==================== AI功能路由 - 匹配旧项目 ====================
      GoRoute(
        path: '/ai_function_select',
        builder: (context, state) => const AIFunctionSelectScreen(),
      ),
      GoRoute(
        path: '/ai_chat/:function',
        builder: (context, state) {
          final id = state.pathParameters['function'] ?? 'health';
          final item = AIFunctions.functions.firstWhere(
            (f) => f.id == id,
            orElse: () => AIFunctions.functions.first,
          );
          return AIChatScreen(function: item);
        },
      ),
      GoRoute(
        path: '/coming_soon/:feature',
        builder: (context, state) {
          final id = state.pathParameters['feature'] ?? 'camera';
          final item = AIFunctions.functions.firstWhere(
            (f) => f.id == id,
            orElse: () => AIFunctions.functions.last,
          );
          return ComingSoonScreen(function: item);
        },
      ),
      
      // ==================== 项圈相关路由 - 匹配旧项目 ====================
      GoRoute(
        path: '/collar_detail/:collarId',
        builder: (context, state) {
          final collarId = state.pathParameters['collarId'] ?? '';
          return CollarDetailScreen(collarId: collarId);
        },
      ),
      
      // ==================== 健康相关路由 - 匹配旧项目 ====================
      GoRoute(
        path: '/health_information',
        builder: (context, state) => const HealthInformationScreen(),
      ),
      GoRoute(
        path: '/health_data', 
        builder: (context, state) => const HealthDataScreen(),
      ),
      GoRoute(
        path: '/health_calendar',
        builder: (context, state) => const HealthCalendarScreen(),
      ),
    ],
  );
}