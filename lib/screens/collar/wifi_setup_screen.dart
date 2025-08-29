import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_talk/theme/app_colors.dart';
import 'package:permission_handler/permission_handler.dart';

class WiFiSetupScreen extends ConsumerStatefulWidget {
  const WiFiSetupScreen({super.key});

  @override
  ConsumerState<WiFiSetupScreen> createState() => _WiFiSetupScreenState();
}

class _WiFiSetupScreenState extends ConsumerState<WiFiSetupScreen> {
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConnecting = false;
  bool _isScanning = false;
  List<WiFiNetwork> _networks = [];
  WiFiNetwork? _selectedNetwork;
  bool _showPermissionDialog = false;
  bool _showConnectingDialog = false;
  bool _showSuccessDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestWifiPermissions();
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'WiFi Setup',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isScanning ? null : _scanWiFiNetworks,
            icon: Icon(
              Icons.refresh,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 扫描状态卡片
              Container(
                margin: const EdgeInsets.all(16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: _isScanning 
                      ? const Color(0xFFE3F2FD) 
                      : const Color(0xFFF5F5F5),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        if (_isScanning)
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          Icon(
                            Icons.wifi,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        
                        const SizedBox(width: 12),
                        
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isScanning 
                                    ? 'Scanning WiFi networks...' 
                                    : 'WiFi Networks',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              if (!_isScanning && _networks.isNotEmpty)
                                Text(
                                  'Found ${_networks.length} network(s)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        
                        if (!_isScanning)
                          IconButton(
                            onPressed: _scanWiFiNetworks,
                            icon: Icon(
                              Icons.refresh,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // 网络列表
              Expanded(
                child: _networks.isNotEmpty
                    ? _buildNetworkList()
                    : _buildEmptyState(),
              ),
              
              // 连接按钮和密码输入
              if (_selectedNetwork != null) _buildConnectionPanel(),
            ],
          ),
          
          // 权限对话框
          if (_showPermissionDialog) _buildPermissionDialog(),
          
          // 连接中对话框
          if (_showConnectingDialog) _buildConnectingDialog(),
          
          // 成功对话框
          if (_showSuccessDialog) _buildSuccessDialog(),
        ],
      ),
    );
  }

  Widget _buildNetworkList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Available Networks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _networks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final network = _networks[index];
              return _buildNetworkItem(network);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkItem(WiFiNetwork network) {
    final isSelected = _selectedNetwork?.ssid == network.ssid;
    
    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
      child: InkWell(
        onTap: () => _selectNetwork(network),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // WiFi图标
              Icon(
                network.isSecured ? Icons.wifi_lock : Icons.wifi,
                color: isSelected ? AppColors.primary : Colors.grey[600],
                size: 24,
              ),
              
              const SizedBox(width: 16),
              
              // 网络信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      network.ssid,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? AppColors.primary : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      network.isSecured ? 'Secured' : 'Open',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 信号强度
              Column(
                children: [
                  Icon(
                    _getSignalIcon(network.signalStrength),
                    color: _getSignalColor(network.signalStrength),
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${network.signalStrength}%',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              if (isSelected)
                const SizedBox(width: 8),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_isScanning) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Scanning for WiFi networks...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No WiFi networks found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check if WiFi is enabled on your device',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _scanWiFiNetworks,
            icon: const Icon(Icons.refresh),
            label: const Text('Scan Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connect to ${_selectedNetwork!.ssid}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          
          if (_selectedNetwork!.isSecured) ...[
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter WiFi password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isConnecting ? null : _connectToWiFi,
              icon: _isConnecting 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.wifi),
              label: Text(
                _isConnecting ? 'Connecting...' : 'Connect',
              ),
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
    );
  }

  IconData _getSignalIcon(int strength) {
    if (strength > 75) return Icons.signal_wifi_4_bar;
    if (strength > 50) return Icons.signal_wifi_4_bar;
    if (strength > 25) return Icons.signal_wifi_4_bar;
    return Icons.signal_wifi_4_bar;
  }

  Color _getSignalColor(int strength) {
    if (strength > 75) return const Color(0xFF4CAF50);
    if (strength > 50) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  void _selectNetwork(WiFiNetwork network) {
    setState(() {
      _selectedNetwork = network;
      _passwordController.clear();
    });
  }

  Future<void> _requestWifiPermissions() async {
    final permissions = [
      Permission.location,
      Permission.nearbyWifiDevices,
    ];

    Map<Permission, PermissionStatus> statuses = await permissions.request();
    
    final hasPermissions = statuses.values.every((status) => 
        status == PermissionStatus.granted || 
        status == PermissionStatus.limited);

    if (hasPermissions) {
      _scanWiFiNetworks();
    } else {
      setState(() {
        _showPermissionDialog = true;
      });
    }
  }

  Future<void> _scanWiFiNetworks() async {
    if (_isScanning) return;
    
    setState(() {
      _isScanning = true;
      _networks.clear();
      _selectedNetwork = null;
    });

    // 模拟WiFi扫描过程
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _networks = [
          const WiFiNetwork(
            ssid: 'Home-WiFi-5G',
            signalStrength: 85,
            isSecured: true,
          ),
          const WiFiNetwork(
            ssid: 'TP-LINK_8A2F',
            signalStrength: 72,
            isSecured: true,
          ),
          const WiFiNetwork(
            ssid: 'Guest-Network',
            signalStrength: 45,
            isSecured: false,
          ),
          const WiFiNetwork(
            ssid: 'ChinaNet-Mobile',
            signalStrength: 30,
            isSecured: true,
          ),
          const WiFiNetwork(
            ssid: 'Office-WiFi',
            signalStrength: 68,
            isSecured: true,
          ),
        ];
        _isScanning = false;
      });
    }
  }

  Future<void> _connectToWiFi() async {
    if (_selectedNetwork == null) return;
    
    if (_selectedNetwork!.isSecured && _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the WiFi password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isConnecting = true;
      _showConnectingDialog = true;
    });

    // 模拟连接过程
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isConnecting = false;
      _showConnectingDialog = false;
      _showSuccessDialog = true;
    });
  }

  Widget _buildPermissionDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off,
              size: 48,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            const Text(
              'WiFi Permission Required',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'To scan and connect to WiFi networks, please grant location permissions.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _showPermissionDialog = false;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _showPermissionDialog = false;
                      });
                      await _requestWifiPermissions();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Grant Permission'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectingDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Connecting to WiFi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_selectedNetwork != null)
              Text(
                'Connecting to ${_selectedNetwork!.ssid}...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              size: 48,
              color: Color(0xFF4CAF50),
            ),
            const SizedBox(height: 16),
            const Text(
              'Connection Successful',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_selectedNetwork != null)
              Text(
                'Smart collar successfully connected to "${_selectedNetwork!.ssid}"',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showSuccessDialog = false;
                  });
                  Navigator.pop(context, true); // Return success
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WiFiNetwork {
  final String ssid;
  final int signalStrength;
  final bool isSecured;

  const WiFiNetwork({
    required this.ssid,
    required this.signalStrength,
    required this.isSecured,
  });
}