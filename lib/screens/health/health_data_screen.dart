import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_talk/theme/app_colors.dart';


// Health Metric Model
class HealthMetric {
  final String id;
  final String title;
  final String description;
  final double value;
  final double maxValue;
  final String unit;
  final HealthMetricType type;
  final DateTime lastUpdated;

  const HealthMetric({
    required this.id,
    required this.title,
    required this.description,
    required this.value,
    required this.maxValue,
    required this.unit,
    required this.type,
    required this.lastUpdated,
  });

  double get percentage => (value / maxValue).clamp(0.0, 1.0);
  
  HealthStatus get status {
    final percent = percentage;
    if (percent >= 0.8) return HealthStatus.excellent;
    if (percent >= 0.6) return HealthStatus.good;
    if (percent >= 0.4) return HealthStatus.fair;
    return HealthStatus.poor;
  }
}

enum HealthMetricType {
  activity,
  sleep,
  exercise,
  behavior,
  warning
}

enum HealthStatus {
  excellent,
  good,
  fair,
  poor
}

extension HealthStatusExtension on HealthStatus {
  Color get color {
    switch (this) {
      case HealthStatus.excellent:
        return AppColors.success;
      case HealthStatus.good:
        return Colors.lightGreen;
      case HealthStatus.fair:
        return AppColors.warning;
      case HealthStatus.poor:
        return AppColors.error;
    }
  }

  String get text {
    switch (this) {
      case HealthStatus.excellent:
        return 'Excellent';
      case HealthStatus.good:
        return 'Good';
      case HealthStatus.fair:
        return 'Fair';
      case HealthStatus.poor:
        return 'Needs Attention';
    }
  }

  IconData get icon {
    switch (this) {
      case HealthStatus.excellent:
        return Icons.sentiment_very_satisfied;
      case HealthStatus.good:
        return Icons.sentiment_satisfied;
      case HealthStatus.fair:
        return Icons.sentiment_neutral;
      case HealthStatus.poor:
        return Icons.sentiment_dissatisfied;
    }
  }
}

extension HealthMetricTypeExtension on HealthMetricType {
  IconData get icon {
    switch (this) {
      case HealthMetricType.activity:
        return Icons.directions_run;
      case HealthMetricType.sleep:
        return Icons.bedtime;
      case HealthMetricType.exercise:
        return Icons.fitness_center;
      case HealthMetricType.behavior:
        return Icons.pets;
      case HealthMetricType.warning:
        return Icons.warning;
    }
  }

  Color get color {
    switch (this) {
      case HealthMetricType.activity:
        return Colors.blue;
      case HealthMetricType.sleep:
        return Colors.purple;
      case HealthMetricType.exercise:
        return Colors.orange;
      case HealthMetricType.behavior:
        return Colors.green;
      case HealthMetricType.warning:
        return Colors.red;
    }
  }
}

class HealthDataScreen extends ConsumerStatefulWidget {
  const HealthDataScreen({super.key});

  @override
  ConsumerState<HealthDataScreen> createState() => _HealthDataScreenState();
}

class _HealthDataScreenState extends ConsumerState<HealthDataScreen> {
  // Sample health metrics
  final List<HealthMetric> _healthMetrics = [
    HealthMetric(
      id: '1',
      title: 'Daily Activity Index',
      description: 'Today\'s activity has reached the target!',
      value: 85,
      maxValue: 100,
      unit: '%',
      type: HealthMetricType.activity,
      lastUpdated: DateTime.now(),
    ),
    HealthMetric(
      id: '2',
      title: 'High-intensity Exercise',
      description: 'There\'s more high-intensity exercise today!',
      value: 42,
      maxValue: 60,
      unit: 'minutes',
      type: HealthMetricType.exercise,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    HealthMetric(
      id: '3',
      title: 'Deep Sleep Quality',
      description: 'Today\'s deep sleep is too short.',
      value: 4.5,
      maxValue: 8,
      unit: 'hours',
      type: HealthMetricType.sleep,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    HealthMetric(
      id: '4',
      title: 'Morning Activity',
      description: 'Pets are overly active in the morning.',
      value: 90,
      maxValue: 100,
      unit: '%',
      type: HealthMetricType.behavior,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    HealthMetric(
      id: '5',
      title: 'Scratch Abnormal Warning',
      description: 'The number of scratches is increasing.',
      value: 25,
      maxValue: 10,
      unit: 'times',
      type: HealthMetricType.warning,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    HealthMetric(
      id: '6',
      title: 'Exercise-to-rest Ratio',
      description: 'It\'s not good to have a few days off.',
      value: 3.2,
      maxValue: 5,
      unit: 'ratio',
      type: HealthMetricType.exercise,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Health Data',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Health Overview Card
            _buildHealthOverviewCard(),
            const SizedBox(height: 16),
            
            // Health Metrics List
            _buildHealthMetricsList(),
            const SizedBox(height: 16),
            
            // Health Trends Card
            _buildHealthTrendsCard(),
            const SizedBox(height: 16),
            
            // Quick Actions
            _buildQuickActionsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthOverviewCard() {
    final excellentCount = _healthMetrics.where((m) => m.status == HealthStatus.excellent).length;
    final goodCount = _healthMetrics.where((m) => m.status == HealthStatus.good).length;
    final fairCount = _healthMetrics.where((m) => m.status == HealthStatus.fair).length;
    final poorCount = _healthMetrics.where((m) => m.status == HealthStatus.poor).length;
    
    final totalMetrics = _healthMetrics.length;
    final overallScore = ((excellentCount * 4 + goodCount * 3 + fairCount * 2 + poorCount * 1) / (totalMetrics * 4) * 100).round();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'Overall Health Score',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Circular progress indicator
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: overallScore / 100,
                          strokeWidth: 8,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$overallScore',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Score',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Status breakdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatusCount('Excellent', excellentCount, HealthStatus.excellent.color),
                  _buildStatusCount('Good', goodCount, HealthStatus.good.color),
                  _buildStatusCount('Fair', fairCount, HealthStatus.fair.color),
                  _buildStatusCount('Poor', poorCount, HealthStatus.poor.color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCount(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthMetricsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Metrics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        
        ..._healthMetrics.map((metric) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: _buildHealthMetricCard(metric),
        )).toList(),
      ],
    );
  }

  Widget _buildHealthMetricCard(HealthMetric metric) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: metric.type.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    metric.type.icon,
                    color: metric.type.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        metric.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Updated ${_getTimeAgo(metric.lastUpdated)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: metric.status.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        metric.status.icon,
                        size: 16,
                        color: metric.status.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        metric.status.text,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: metric.status.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Progress bar
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: metric.percentage,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(metric.status.color),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${metric.value.toStringAsFixed(metric.value % 1 == 0 ? 0 : 1)} ${metric.unit}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: metric.status.color,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              metric.description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthTrendsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.trending_up,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Health Trends',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Mock trend chart placeholder
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.show_chart,
                      size: 40,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Health trends chart will be displayed here',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Weekly summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTrendSummary('This Week', '+12%', AppColors.success, Icons.trending_up),
                _buildTrendSummary('Last Month', '+8%', AppColors.success, Icons.trending_up),
                _buildTrendSummary('Sleep Quality', '-5%', AppColors.warning, Icons.trending_down),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendSummary(String label, String change, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          change,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    'Export Data',
                    Icons.file_download,
                    AppColors.info,
                    _exportHealthData,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    'Set Goals',
                    Icons.flag,
                    AppColors.warning,
                    _setHealthGoals,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    'View History',
                    Icons.history,
                    AppColors.primary,
                    _viewHealthHistory,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    'Share Report',
                    Icons.share,
                    AppColors.success,
                    _shareHealthReport,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _refreshData() {
    // Simulate data refresh
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Health data refreshed'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _exportHealthData() {
    _showFeatureDialog('Export Health Data');
  }

  void _setHealthGoals() {
    _showFeatureDialog('Set Health Goals');
  }

  void _viewHealthHistory() {
    _showFeatureDialog('View Health History');
  }

  void _shareHealthReport() {
    _showFeatureDialog('Share Health Report');
  }

  void _showFeatureDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction,
              size: 60,
              color: AppColors.info,
            ),
            SizedBox(height: 16),
            Text(
              'Feature Coming Soon',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'This feature will be available in a future update.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}