import 'package:flutter/material.dart';
import 'package:pet_talk/theme/app_colors.dart';
import 'package:intl/intl.dart';

class SystemMessage {
  final String title;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  SystemMessage({
    required this.title,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });
}

class SystemAlertScreen extends StatefulWidget {
  const SystemAlertScreen({super.key});

  @override
  State<SystemAlertScreen> createState() => _SystemAlertScreenState();
}

class _SystemAlertScreenState extends State<SystemAlertScreen> {
  final List<SystemMessage> systemMessages = [
    SystemMessage(
      title: "Health Alert",
      content: "Your pet's activity level has decreased significantly today. Consider scheduling a vet visit.",
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    SystemMessage(
      title: "Collar Update",
      content: "PaaaWoW collar firmware update v2.1.3 is now available. New features include enhanced GPS accuracy.",
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    SystemMessage(
      title: "Vaccination Reminder",
      content: "It's time for your pet's annual vaccination. Book an appointment with your veterinarian.",
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
    ),
    SystemMessage(
      title: "Training Tip",
      content: "New AI training module available: 'Advanced Leash Training'. Start your personalized program now!",
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      isRead: false,
    ),
    SystemMessage(
      title: "Safety Alert",
      content: "Your pet left the designated safe zone at 3:45 PM. Current location: Central Park East Gate.",
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
      isRead: true,
    ),
    SystemMessage(
      title: "System Maintenance",
      content: "Scheduled maintenance on PaaaWoW servers will occur on Sunday 2:00-4:00 AM EST. Some features may be temporarily unavailable.",
      timestamp: DateTime.now().subtract(const Duration(days: 10)),
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'System Alert',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              _markAllAsRead();
            },
            icon: Icon(
              Icons.done_all,
              color: AppColors.primary,
            ),
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: systemMessages.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final message = systemMessages[index];
          return _buildSystemMessageCard(message);
        },
      ),
    );
  }

  Widget _buildSystemMessageCard(SystemMessage message) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');
    
    return Card(
      elevation: message.isRead ? 1 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: message.isRead ? Colors.white : AppColors.primary.withOpacity(0.02),
      child: InkWell(
        onTap: () {
          _showMessageDetails(message);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Status indicator
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: message.isRead ? Colors.grey[300] : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Title
                  Expanded(
                    child: Text(
                      message.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: message.isRead ? FontWeight.w500 : FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  
                  // Timestamp
                  Text(
                    _getTimeAgo(message.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Content preview
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  message.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Full timestamp
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  dateFormat.format(message.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(timestamp);
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (int i = 0; i < systemMessages.length; i++) {
        systemMessages[i] = SystemMessage(
          title: systemMessages[i].title,
          content: systemMessages[i].content,
          timestamp: systemMessages[i].timestamp,
          isRead: true,
        );
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All messages marked as read'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showMessageDetails(SystemMessage message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            message.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.content,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  DateFormat('MMMM dd, yyyy at HH:mm').format(message.timestamp),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}


