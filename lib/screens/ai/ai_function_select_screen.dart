import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_talk/theme/app_colors.dart';
import 'package:pet_talk/models/ai_models.dart';
import 'package:pet_talk/screens/ai/ai_chat_screen.dart';
import 'package:pet_talk/screens/ai/coming_soon_screen.dart';
import 'package:pet_talk/screens/pet_finder/pet_finder_screen.dart';

// Provider for selected AI function
final selectedAIFunctionProvider = StateProvider<AIFunctionItem?>((ref) => null);

class AIFunctionSelectScreen extends ConsumerWidget {
  const AIFunctionSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFunction = ref.watch(selectedAIFunctionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'AI Assistant',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // AI function grid (3x2)
            SizedBox(
              height: 220, //这个越大越小
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: AIFunctions.functions.length,
                itemBuilder: (context, index) {
                  final function = AIFunctions.functions[index];
                  final isSelected = selectedFunction?.id == function.id;
                  
                  return _buildAIFunctionIcon(
                    context,
                    ref,
                    function,
                    isSelected,
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Function detail section
            Expanded(
              child: selectedFunction != null
                  ? _buildAIFunctionDetail(context, selectedFunction)
                  : _buildDefaultPrompt(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIFunctionIcon(
    BuildContext context,
    WidgetRef ref,
    AIFunctionItem function,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedAIFunctionProvider.notifier).state = function;
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              function.iconPath,
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  _getIconForFunction(function.id),
                  size: 32,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              function.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIFunctionDetail(BuildContext context, AIFunctionItem function) {
    return Column(
      children: [
        // Function image
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                function.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _getIconForFunction(function.id),
                      size: 80,
                      color: AppColors.primary,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Function title
        Text(
          function.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 12),
        
        // Function description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            function.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        const Spacer(),
        
        // GO button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              _navigateToFunction(context, function);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: function.isComingSoon 
                  ? AppColors.textSecondary 
                  : AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              function.isComingSoon ? 'COMING SOON' : 'GO',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Select an AI Function',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the icons above to view function details',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForFunction(String functionId) {
    switch (functionId) {
      case 'train':
        return Icons.school;
      case 'health':
        return Icons.health_and_safety;
      case 'find':
        return Icons.location_searching;
      case 'tarot':
        return Icons.auto_awesome;
      case 'emotion':
        return Icons.sentiment_satisfied;
      case 'camera':
        return Icons.camera_alt;
      default:
        return Icons.smart_toy;
    }
  }

  void _navigateToFunction(BuildContext context, AIFunctionItem function) {
    if (function.isComingSoon) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ComingSoonScreen(function: function),
        ),
      );
    } else {
      switch (function.targetScreen) {
        case 'virtual_fence':
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const PetFinderScreen(),
            ),
          );
          break;
        case 'ai_chat':
        default:
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AIChatScreen(function: function),
            ),
          );
          break;
      }
    }
  }
}