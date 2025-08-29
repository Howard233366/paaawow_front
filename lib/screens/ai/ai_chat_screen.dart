import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_talk/theme/app_colors.dart';
import 'package:pet_talk/models/ai_models.dart';
import 'package:pet_talk/models/common_models.dart';
import 'package:pet_talk/services/ai/gpt_repository.dart';

// Providers for chat state
final chatMessagesProvider = StateProvider<List<AIMessage>>((ref) => []);
final isLoadingProvider = StateProvider<bool>((ref) => false);
final errorMessageProvider = StateProvider<String?>((ref) => null);

class AIChatScreen extends ConsumerStatefulWidget {
  final AIFunctionItem function;

  const AIChatScreen({
    super.key,
    required this.function,
  });

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 避免在构建阶段修改Riverpod的Provider：延迟到首帧之后
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addWelcomeMessage();
      _checkServiceHealth();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkServiceHealth() async {
    // 可选的健康检查，影响顶部提示
    final result = await GPTRepository.instance.gptHealthCheck();
    result.when(
      success: (_) {
        // 忽略成功提示，页面仅在异常时提示
      },
      error: (err) {
        ref.read(errorMessageProvider.notifier).state = 'AI服务暂不可用：$err';
      },
    );
  }

  void _addWelcomeMessage() {
    final welcomeMessage = _getWelcomeMessage();
    if (welcomeMessage.isNotEmpty) {
      final message = AIMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: welcomeMessage,
        isUser: false,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      
      ref.read(chatMessagesProvider.notifier).state = [message];
    }
  }

  String _getWelcomeMessage() {
    switch (widget.function.id) {
      case 'health':
        return '你好！我是你的AI健康专家。我可以帮助你了解宠物的健康状况，提供专业的健康建议。请告诉我你的问题吧！';
      case 'tarot':
        return '欢迎来到宠物塔罗预测！我可以通过塔罗牌为你的宠物占卜运势，解读它们的能量状态。让我们开始这段神奇的旅程吧！';
      case 'emotion':
        return '你好！我是宠物情绪翻译专家。我可以帮助你理解宠物的各种行为和情绪，让你更好地与它们沟通。';
      default:
        return '你好！我是你的AI助手。有什么可以帮助你的吗？';
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Clear input
    _messageController.clear();

    // Add user message
    final userMessage = AIMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      isUser: true,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    final currentMessages = ref.read(chatMessagesProvider);
    ref.read(chatMessagesProvider.notifier).state = [...currentMessages, userMessage];

    // Set loading state
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(errorMessageProvider.notifier).state = null;

    // Scroll to bottom
    _scrollToBottom();

    try {
      // Call appropriate GPT function based on AI function type
      Result<String> result;
      
      switch (widget.function.id) {
        case 'health':
          result = await GPTRepository.instance.petGeneralChat(message: message);
          break;
        case 'train':
          result = await GPTRepository.instance.petTrainingAdvice(message: message);
          break;
        case 'emotion':
          result = await GPTRepository.instance.dogLanguageTranslation(dogSound: message);
          break;
        case 'tarot':
          result = await GPTRepository.instance.petGeneralChat(message: '请为我的宠物做一次塔罗占卜：$message');
          break;
        default:
          result = await GPTRepository.instance.petGeneralChat(message: message);
      }

      result.when(
        success: (response) {
          final aiMessage = AIMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            content: response,
            isUser: false,
            timestamp: DateTime.now().millisecondsSinceEpoch,
          );

          final updatedMessages = ref.read(chatMessagesProvider);
          ref.read(chatMessagesProvider.notifier).state = [...updatedMessages, aiMessage];
          _scrollToBottom();
        },
        error: (error) {
          ref.read(errorMessageProvider.notifier).state = error;
        },
      );
    } catch (e) {
      ref.read(errorMessageProvider.notifier).state = '发送消息失败，请重试';
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final errorMessage = ref.watch(errorMessageProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.function.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Error message
          if (errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: AppColors.error.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.error, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(errorMessageProvider.notifier).state = null;
                    },
                    child: const Text('关闭'),
                  ),
                ],
              ),
            ),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && isLoading) {
                  return _buildLoadingMessage();
                }

                final message = messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: _getInputHint(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    onPressed: isLoading ? null : _sendMessage,
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(AIMessage message) {
    final isUser = message.isUser;
    final time = DateTime.fromMillisecondsSinceEpoch(message.timestamp);
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 16,
              child: Icon(
                _getAvatarIcon(),
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              backgroundColor: AppColors.secondary,
              radius: 16,
              child: Icon(
                Icons.person,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            radius: 16,
            child: Icon(
              _getAvatarIcon(),
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '正在思考...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAvatarIcon() {
    switch (widget.function.id) {
      case 'health':
        return Icons.health_and_safety;
      case 'train':
        return Icons.school;
      case 'tarot':
        return Icons.auto_awesome;
      case 'emotion':
        return Icons.sentiment_satisfied;
      default:
        return Icons.smart_toy;
    }
  }

  String _getInputHint() {
    switch (widget.function.id) {
      case 'health':
        return '请描述宠物的健康问题...';
      case 'train':
        return '请描述需要训练的行为...';
      case 'tarot':
        return '请描述你想要占卜的问题...';
      case 'emotion':
        return '请描述宠物的行为表现...';
      default:
        return '请输入你的问题...';
    }
  }
}