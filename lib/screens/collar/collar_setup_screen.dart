import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_talk/theme/app_colors.dart';
import 'package:pet_talk/screens/collar/bluetooth_scan_screen.dart';
import 'package:pet_talk/screens/collar/wifi_setup_screen.dart';

class CollarSetupScreen extends ConsumerStatefulWidget {
  const CollarSetupScreen({super.key});

  @override
  ConsumerState<CollarSetupScreen> createState() => _CollarSetupScreenState();
}

class _CollarSetupScreenState extends ConsumerState<CollarSetupScreen> {
  int _currentStep = 0;
  bool _bluetoothConnected = false;
  bool _wifiConfigured = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Collar Setup',
          style: TextStyle(
            fontFamily: 'PaaaWow',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(),
            const SizedBox(height: 30),
            
            // Content based on current step
            Expanded(
              child: _buildStepContent(),
            ),
            
            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStepIndicator(0, 'Bluetooth', _bluetoothConnected),
          Expanded(
            child: Container(
              height: 2,
              color: _currentStep > 0 ? AppColors.primary : Colors.grey[300],
            ),
          ),
          _buildStepIndicator(1, 'WiFi Setup', _wifiConfigured),
          Expanded(
            child: Container(
              height: 2,
              color: _currentStep > 1 ? AppColors.primary : Colors.grey[300],
            ),
          ),
          _buildStepIndicator(2, 'Complete', _currentStep >= 2),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String title, bool completed) {
    final isActive = _currentStep == step;
    final color = completed ? AppColors.primary : 
                 isActive ? AppColors.primary : Colors.grey[400];

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: completed || isActive ? AppColors.primary : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            completed ? Icons.check : Icons.circle,
            color: completed || isActive ? Colors.white : Colors.grey[600],
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBluetoothStep();
      case 1:
        return _buildWiFiStep();
      case 2:
        return _buildCompletionStep();
      default:
        return _buildBluetoothStep();
    }
  }

  Widget _buildBluetoothStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.bluetooth,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 20),
              const Text(
                'Connect Smart Collar',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PaaaWow',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please ensure the smart collar is powered on\nTap the button below to start searching for devices',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _scanForDevices,
                  icon: const Icon(Icons.search),
                  label: const Text('搜索设备'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWiFiStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.wifi,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 20),
              const Text(
                'WiFi配网',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PaaaWow',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '为智能项圈配置WiFi网络\n确保项圈能正常联网使用',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _configureWiFi,
                  icon: const Icon(Icons.settings_ethernet),
                  label: const Text('配置WiFi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.check_circle,
                size: 80,
                color: AppColors.success,
              ),
              const SizedBox(height: 20),
              const Text(
                '设置完成！',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PaaaWow',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '智能项圈已成功连接\n现在可以开始使用所有AI功能',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _completeSetup,
                  icon: const Icon(Icons.home),
                  label: const Text('开始使用'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: _previousStep,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('上一步'),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 16),
        if (_currentStep < 2)
          Expanded(
            child: ElevatedButton(
              onPressed: _canProceed() ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('下一步'),
            ),
          ),
      ],
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _bluetoothConnected;
      case 1:
        return _wifiConfigured;
      default:
        return true;
    }
  }

  void _scanForDevices() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BluetoothScanScreen(),
      ),
    ).then((connected) {
      if (connected == true) {
        setState(() {
          _bluetoothConnected = true;
        });
      }
    });
  }

  void _configureWiFi() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WiFiSetupScreen(),
      ),
    ).then((configured) {
      if (configured == true) {
        setState(() {
          _wifiConfigured = true;
        });
      }
    });
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _nextStep() {
    if (_currentStep < 2 && _canProceed()) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _completeSetup() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}