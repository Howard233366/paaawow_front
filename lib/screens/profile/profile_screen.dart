// 🔵 PetTalk Profile屏幕 - 完全匹配旧Android项目ProfileScreen.kt
// 严格按照旧项目ProfileScreen.kt逐行复刻

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_talk/models/screen_routes.dart';
import 'package:pet_talk/services/auth/auth_repository.dart';
import 'package:pet_talk/services/auth/google_auth_service.dart';
import 'package:pet_talk/services/auth/apple_auth_service.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showPhotoDialog = false;
  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  
                  // ME Title with PaaaWow Font (smaller)
                  const Text(
                    "ME",
                    style: TextStyle(
                      fontFamily: 'PaaaWow',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Avatar Section
                  _buildAvatarSection(),
                  
                  const SizedBox(height: 20),
                  
                  // User Info Section
                  _buildUserInfoSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Menu Items
                  _buildProfileMenuSection(),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Show photo dialog
          if (_showPhotoDialog) _buildPhotoSelectionDialog(),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Stack(
      children: [
        // Avatar
        GestureDetector(
          onTap: () {
            setState(() {
              _showPhotoDialog = true;
            });
          },
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                width: 3,
              ),
            ),
            child: ClipOval(
              child: _avatarImage != null
                  ? Image.file(
                      _avatarImage!,
                      fit: BoxFit.cover,
                    )
                  : const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey,
                    ),
            ),
          ),
        ),
        
        // Edit icon at bottom right
        Positioned(
          bottom: 8,
          right: 8,
          child: GestureDetector(
            onTap: () {
              context.push('/profile/edit');
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
              child: Image.asset(
                'assets/images/profile/edit.png',
                width: 16,
                height: 16,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.edit,
                    size: 16,
                    color: Colors.grey,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoSection() {
    return Column(
      children: [
        // Name
        const Text(
          "John Doe",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Location
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on,
              size: 16,
              color: Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              "New York, USA",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Personal signature
        const Text(
          "Love my pets, love life! 🐕🐱",
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF666666),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProfileMenuSection() {
    final menuItems = [
      ProfileMenuItem(
        title: "System alert",
        iconPath: "assets/images/profile/system-alert.png",
        onTap: () => context.push(AppRoutes.systemAlert),
      ),
      ProfileMenuItem(
        title: "Adding pets", 
        iconPath: "assets/images/profile/adding-pets.png",
        onTap: () => context.push(AppRoutes.addingPets),
      ),
      ProfileMenuItem(
        title: "Feedback",
        iconPath: "assets/images/profile/feedback.png", 
        onTap: () => context.push(AppRoutes.feedback),
      ),
      ProfileMenuItem(
        title: "About us",
        iconPath: "assets/images/profile/about-us.png",
        onTap: () => context.push(AppRoutes.aboutUs),
      ),
      ProfileMenuItem(
        title: "First aid",
        iconPath: "assets/images/profile/first-aid.png",
        onTap: () => context.push(AppRoutes.firstAid),
      ),
      ProfileMenuItem(
        title: "Logout",
        iconPath: "assets/images/profile/logout.png",
        onTap: _handleLogout,
        isLogout: true,
      ),
    ];

    return Column(
      children: menuItems.map((item) => _buildProfileMenuItemCard(item)).toList(),
    );
  }

  Widget _buildProfileMenuItemCard(ProfileMenuItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Icon
                Image.asset(
                  item.iconPath,
                  width: 24,
                  height: 24,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.settings,
                      size: 24,
                      color: Colors.grey,
                    );
                  },
                ),
                
                const SizedBox(width: 16),
                
                // Title
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: item.isLogout ? Colors.red : Colors.black,
                    ),
                  ),
                ),
                
                // Arrow
                const Icon(
                  Icons.keyboard_arrow_right,
                  size: 20,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Photo Selection Dialog
  Widget _buildPhotoSelectionDialog() {
    return Container(
      color: Colors.black.withOpacity(0.5), // 添加半透明黑色遮罩背景
      child: Dialog(
        backgroundColor: Colors.transparent, // 让Dialog背景透明
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            const Text(
              "Select Photo",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Camera option
            InkWell(
              onTap: () {
                _pickImage(ImageSource.camera);
                setState(() {
                  _showPhotoDialog = false;
                });
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 24,
                      color: Color(0xFF2196F3),
                    ),
                    SizedBox(width: 16),
                    Text(
                      "Take Photo",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const Divider(
              height: 32,
              color: Color(0xFFE0E0E0),
            ),
            
            // Gallery option
            InkWell(
              onTap: () {
                _pickImage(ImageSource.gallery);
                setState(() {
                  _showPhotoDialog = false;
                });
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.photo_library,
                      size: 24,
                      color: Color(0xFF4CAF50),
                    ),
                    SizedBox(width: 16),
                    Text(
                      "Choose from Gallery",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Cancel button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showPhotoDialog = false;
                  });
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _avatarImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ===== 退出登录处理 =====
  Future<void> _handleLogout() async {
    // 显示确认对话框
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('退出登录'),
          content: const Text('确定要退出登录吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('退出'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    // 显示加载提示
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔄 正在退出登录...'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    try {
      // 调用各种登录服务的退出方法
      debugPrint('🔵 开始退出登录流程');
      
      // 退出Google登录
      try {
        await GoogleAuthService().signOut();
        debugPrint('🔵 Google登录已退出');
      } catch (e) {
        debugPrint('🔵 Google退出失败: $e');
      }

      // 退出Apple登录
      try {
        await AppleAuthService().signOut();
        debugPrint('🍎 Apple登录已退出');
      } catch (e) {
        debugPrint('🍎 Apple退出失败: $e');
      }

      // 调用AuthRepository的退出方法
      try {
        final result = await AuthRepository.instance.logout();
        if (result.isSuccess) {
          debugPrint('🔵 AuthRepository退出成功');
        } else {
          debugPrint('🔵 AuthRepository退出失败: ${result.error}');
        }
      } catch (e) {
        debugPrint('🔵 AuthRepository退出异常: $e');
      }

      if (mounted) {
        // 清除SnackBar
        ScaffoldMessenger.of(context).clearSnackBars();
        
        // 显示退出成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 退出登录成功'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // 延迟后跳转到登录页面
        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (mounted && context.mounted) {
          // 清除所有页面栈，跳转到登录页面
          context.go('/login');
        }
      }
    } catch (e) {
      debugPrint('🔵 退出登录异常: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 退出登录失败: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class ProfileMenuItem {
  final String title;
  final String iconPath;
  final VoidCallback onTap;
  final bool isLogout;

  ProfileMenuItem({
    required this.title,
    required this.iconPath,
    required this.onTap,
    this.isLogout = false,
  });
}