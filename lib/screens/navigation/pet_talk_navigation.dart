import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pet_talk/screens/home/home_screen.dart';
import 'package:pet_talk/screens/community/community_screen.dart';
import 'package:pet_talk/screens/ai/ai_function_select_screen.dart';
import 'package:pet_talk/screens/profile/profile_screen.dart';
import 'package:pet_talk/screens/shop/shop_screen.dart';
import 'package:pet_talk/theme/app_colors.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

// AI功能枚举 - 严格匹配旧项目AIFunction
enum AIFunction {
  findPet,
  trainPet,
  healthExpert,
  emotionDisplay,
  tarotPrediction,
}

// AI浮动按钮数据 - 严格匹配旧项目AIFloatingButton
class AIFloatingButton {
  final AIFunction function;
  final String title;
  
  const AIFloatingButton(this.function, this.title);
}

// 底部导航项数据 - 严格匹配旧项目BottomNavItem
class BottomNavItem {
  final String title;
  final IconData icon;
  final int index;
  
  const BottomNavItem({
    required this.title,
    required this.icon,
    required this.index,
  });
}

class PetTalkNavigation extends ConsumerStatefulWidget {
  const PetTalkNavigation({super.key});

  @override
  ConsumerState<PetTalkNavigation> createState() => _PetTalkNavigationState();
}

class _PetTalkNavigationState extends ConsumerState<PetTalkNavigation>
    with TickerProviderStateMixin {
  bool _showFloatingButtons = false;
  bool _isAIButtonPressed = false;

  // 严格匹配旧项目的底部导航项定义
  final List<BottomNavItem?> _bottomNavItems = [
    const BottomNavItem(title: "Pet", icon: Icons.pets, index: 0),
    const BottomNavItem(title: "Community", icon: Icons.group, index: 1),
    null, // 中央AI按键位置
    const BottomNavItem(title: "Shop", icon: Icons.shopping_cart, index: 2),
    const BottomNavItem(title: "Profile", icon: Icons.person, index: 3),
  ];

  // 严格匹配旧项目的AI浮动按钮定义
  final List<AIFloatingButton> _aiFloatingButtons = [
    const AIFloatingButton(AIFunction.findPet, "Find Pet"),
    const AIFloatingButton(AIFunction.trainPet, "Train Pet"),
    const AIFloatingButton(AIFunction.healthExpert, "Health Expert"),
    const AIFloatingButton(AIFunction.emotionDisplay, "Emotion Display"),
    const AIFloatingButton(AIFunction.tarotPrediction, "Tarot Reading"),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [
          HomeScreen(),           // Pet (index: 0)
          CommunityScreen(),      // Community (index: 1)
          ShopScreen(),           // Shop (index: 2) 
          ProfileScreen(),        // Profile (index: 3)
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationWithAI(currentIndex),
      floatingActionButton: _showFloatingButtons ? _buildAIFloatingButtons() : null,
    );
  }

  /// 底部导航栏 - 严格匹配旧项目BottomNavigationWithAI
  Widget _buildBottomNavigationWithAI(int currentIndex) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (int i = 0; i < _bottomNavItems.length; i++)
              if (_bottomNavItems[i] == null)
                // 中央AI按键 - 严格匹配旧项目AIButton
                Expanded(child: _buildAIButton())
              else
                // 普通导航项 - 严格匹配旧项目BottomNavItemButton
                Expanded(
                  child: _buildBottomNavItemButton(
                    _bottomNavItems[i]!,
                    currentIndex,
                  ),
                ),
          ],
        ),
      ),
    );
  }

  /// 底部导航项按钮 - 严格匹配旧项目BottomNavItemButton
  Widget _buildBottomNavItemButton(BottomNavItem item, int currentIndex) {
    final isSelected = currentIndex == item.index;
    
    return GestureDetector(
      onTap: () {
        // 特殊处理商城按钮：直接打开外部浏览器 - 严格匹配旧项目逻辑
        if (item.title == "Shop") {
          _launchURL("https://paaawow.com");
        } else if (currentIndex != item.index) {
          ref.read(navigationIndexProvider.notifier).state = item.index;
        }
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          item.icon,
          color: isSelected ? Colors.white : Colors.grey,
          size: 24,
        ),
      ),
    );
  }

  /// AI按钮 - 严格匹配旧项目AIButton
  Widget _buildAIButton() {
    final scale = _isAIButtonPressed ? 0.9 : 1.0;
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isAIButtonPressed = true),
      onTapUp: (_) => setState(() => _isAIButtonPressed = false),
      onTapCancel: () => setState(() => _isAIButtonPressed = false),
      onTap: () {
        // 直接跳转到AI功能选择页面 - 严格匹配旧项目逻辑
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AIFunctionSelectScreen()),
        );
      },
      onLongPress: () {
        // 长按进入AI功能选择 - 严格匹配旧项目逻辑
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AIFunctionSelectScreen()),
        );
        setState(() => _showFloatingButtons = false);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(
            scale: scale,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "AI",
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// AI浮动按钮组 - 严格匹配旧项目AIFloatingButtons
  Widget _buildAIFloatingButtons() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // 背景遮罩
          GestureDetector(
            onTap: () => setState(() => _showFloatingButtons = false),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),
          // 浮动按钮列表
          Positioned(
            bottom: 150,
            left: 0,
            right: 0,
            child: Column(
              children: [
                for (final button in _aiFloatingButtons)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: _buildAIFloatingButtonItem(button),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// AI浮动按钮项 - 严格匹配旧项目AIFloatingButtonItem
  Widget _buildAIFloatingButtonItem(AIFloatingButton button) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        height: 48,
        child: Card(
          elevation: 4,
          color: AppColors.primary.withValues(alpha: 0.1),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AIFunctionSelectScreen()),
              );
              setState(() => _showFloatingButtons = false);
            },
            child: Center(
              child: Text(
                button.title,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 启动URL - 匹配旧项目Shop按钮功能
  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}