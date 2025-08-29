import 'package:flutter/material.dart';

class FeatureInfo {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  FeatureInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class FirstAidScreen extends StatelessWidget {
  const FirstAidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      FeatureInfo(
        title: "GPS TRACKING & SAFE ZONE ALERT",
        description: "Precise 7ft Tracking with GPS + 4G + Bluetooth + Wi-Fi\nCustom Safe Zones with Instant Escape Alerts",
        icon: Icons.gps_fixed,
        color: const Color(0xFF2196F3),
      ),
      FeatureInfo(
        title: "EMOTION VISUALIZER",
        description: "We analyze your pet's behavior, sounds, and images to identify emotions in real time. Currently, we detect 6 emotions in dogs—sadness, fatigue, hunger, loneliness, happiness, and anger—and 3 in cats: happy, sad, and hunger.",
        icon: Icons.psychology,
        color: const Color(0xFF4CAF50),
      ),
      FeatureInfo(
        title: "AI HEALTH GUARDIAN",
        description: "PaaaWoW's built-in motion sensor records your pet's every move, from resting to running to scratching, and translates that data into easy-to-understand health metrics. Powered by advanced AI technology, it also provides pets with personalized exercise routines, diet plans and health guidance.",
        icon: Icons.health_and_safety,
        color: const Color(0xFFFF5722),
      ),
      FeatureInfo(
        title: "ADVANCED TRAINING ASSISTANT",
        description: "Smart Training, Tailored for Your Pet\nLet AI + Experts guide every step\nPaaaWoW uses AI to create personalized training plans based on your pet's breed, age, and health.\nCourses are developed with professional trainers and supported by PaaaWoW AI, which offers real-time guidance tailored to your pet's behavior, emotional state, and learning progress.",
        icon: Icons.school,
        color: const Color(0xFF9C27B0),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'First Aid',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "PaaaWoW Features",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 20),
            
            ...features.map((feature) => _buildFeatureCard(feature)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(FeatureInfo feature) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    feature.icon,
                    size: 28,
                    color: feature.color,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: feature.color,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Text(
                feature.description,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


