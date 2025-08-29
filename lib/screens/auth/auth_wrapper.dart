import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_talk/services/auth/auth_repository.dart';
import 'package:pet_talk/screens/auth/login_screen.dart';
import 'package:pet_talk/screens/navigation/pet_talk_navigation.dart';

// Auth state provider
final authStateProvider = FutureProvider<bool>((ref) async {
  return await AuthRepository.instance.isAuthenticated();
});

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (isAuthenticated) {
        if (isAuthenticated) {
          return const PetTalkNavigation();
        } else {
          return const LoginScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => const LoginScreen(),
    );
  }
}