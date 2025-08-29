import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_talk/theme/app_colors.dart';
import 'package:pet_talk/models/pet_models.dart';
import 'package:intl/intl.dart';

class HealthInformationScreen extends ConsumerStatefulWidget {
  const HealthInformationScreen({super.key});

  @override
  ConsumerState<HealthInformationScreen> createState() => _HealthInformationScreenState();
}

class _HealthInformationScreenState extends ConsumerState<HealthInformationScreen> {
  // Sample pet information
  late PetInfo _petInfo;

  @override
  void initState() {
    super.initState();
    _initializePetInfo();
  }

  void _initializePetInfo() {
    _petInfo = const PetInfo(
      id: '1',
      type: PetType.dog,
      name: 'Buddy',
      breed: 'Golden Retriever',
      gender: PetGender.male,
      birthday: 'Feb 06, 2021',
      sterilizationDate: 'Feb 19, 2024',
      profile: 'A friendly and energetic golden retriever who loves playing fetch and swimming.',
      color: 'Golden',
      weight: 28.5,
      height: '68.2',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Basic Information',
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
            onPressed: _showEditDialog,
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Pet Profile Card
            _buildPetProfileCard(),
            const SizedBox(height: 16),
            
            // Basic Information Card
            _buildBasicInformationCard(),
            const SizedBox(height: 16),
            
            // Physical Characteristics Card
            _buildPhysicalCharacteristicsCard(),
            const SizedBox(height: 16),
            
            // Health Status Card
            _buildHealthStatusCard(),
            const SizedBox(height: 16),
            
            // Emergency Contact Card
            _buildEmergencyContactCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildPetProfileCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [AppColors.primary.withOpacity(0.8), AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Pet avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.pets,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Pet name
              Text(
                _petInfo.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Pet breed and type
              Text(
                '${_petInfo.breed} • ${_petInfo.type.displayName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Quick stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickStat('Age', _calculateAge(_petInfo.birthday)),
                  _buildQuickStat('Weight', '${_petInfo.weight} kg'),
                  _buildQuickStat('Gender', _petInfo.gender.displayName),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInformationCard() {
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
                  Icons.info,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Basic Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildInfoRow('Pet ID', _petInfo.id),
            _buildInfoRow('Name', _petInfo.name),
            _buildInfoRow('Type', _petInfo.type.displayName),
            _buildInfoRow('Breed', _petInfo.breed),
            _buildInfoRow('Gender', _petInfo.gender.displayName),
            _buildInfoRow('Birthday', _petInfo.birthday),
            _buildInfoRow('Age', _calculateAge(_petInfo.birthday)),
            if (_petInfo.sterilizationDate?.isNotEmpty == true)
              _buildInfoRow('Sterilization Date', _petInfo.sterilizationDate!),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalCharacteristicsCard() {
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
                  Icons.straighten,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Physical Characteristics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildPhysicalStat(
                    'Weight',
                    '${_petInfo.weight} kg',
                    Icons.monitor_weight,
                    _getWeightStatus(_petInfo.weight),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPhysicalStat(
                    'Height',
                    '${_petInfo.height} cm',
                    Icons.height,
                    'Normal',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _buildInfoRow('Color', _petInfo.color),
            if (_petInfo.profile.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Description:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _petInfo.profile,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalStat(String label, String value, IconData icon, String status) {
    final statusColor = _getStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: statusColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStatusCard() {
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
                  Icons.health_and_safety,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Health Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Health indicators
            Row(
              children: [
                Expanded(
                  child: _buildHealthIndicator(
                    'Vaccinated',
                    true,
                    Icons.vaccines,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHealthIndicator(
                    'Sterilized',
                    _petInfo.sterilizationDate?.isNotEmpty == true,
                    Icons.healing,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHealthIndicator(
                    'Microchipped',
                    true,
                    Icons.memory,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Medical conditions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'No known medical conditions',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthIndicator(String label, bool isActive, IconData icon) {
    final color = isActive ? AppColors.success : AppColors.textSecondary;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
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
          const SizedBox(height: 4),
          Icon(
            isActive ? Icons.check : Icons.close,
            color: color,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactCard() {
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
                  Icons.emergency,
                  color: AppColors.error,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Emergency Contact',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildContactInfo(
              'Veterinarian',
              'Dr. Sarah Johnson',
              '+1 (555) 123-4567',
              Icons.local_hospital,
            ),
            const SizedBox(height: 12),
            _buildContactInfo(
              '24/7 Emergency Clinic',
              'Pet Emergency Center',
              '+1 (555) 911-PETS',
              Icons.medical_services,
            ),
            
            const SizedBox(height: 16),
            
            // Emergency button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _callEmergency,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Emergency Call',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(String type, String name, String phone, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _makePhoneCall(phone),
            icon: const Icon(Icons.phone, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateAge(String birthday) {
    try {
      // Parse birthday (format: "Feb 06, 2021")
      final parsedDate = DateFormat('MMM dd, yyyy').parse(birthday);
      final now = DateTime.now();
      final age = now.year - parsedDate.year;
      final months = now.month - parsedDate.month;
      
      if (age > 1) {
        return '$age years old';
      } else if (age == 1) {
        return months >= 0 ? '1 year old' : '${12 + months} months old';
      } else {
        return '${now.month - parsedDate.month + (now.year - parsedDate.year) * 12} months old';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getWeightStatus(double weight) {
    // Simple weight classification for dogs (this would be more sophisticated in real app)
    if (weight < 10) return 'Light';
    if (weight < 25) return 'Normal';
    if (weight < 35) return 'Heavy';
    return 'Overweight';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
      case 'light':
        return AppColors.success;
      case 'heavy':
        return AppColors.warning;
      case 'overweight':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Pet Information'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit,
              size: 60,
              color: AppColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              'Feature Coming Soon',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'The ability to edit pet information will be available in a future update.',
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

  void _makePhoneCall(String phoneNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Make Phone Call'),
        content: Text('Would you like to call $phoneNumber?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // In a real app, this would use url_launcher to make the call
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calling $phoneNumber...'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _callEmergency() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Call'),
        content: const Text('Are you sure you want to call the emergency veterinarian?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _makePhoneCall('+1 (555) 911-PETS');
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Emergency Call'),
          ),
        ],
      ),
    );
  }
}