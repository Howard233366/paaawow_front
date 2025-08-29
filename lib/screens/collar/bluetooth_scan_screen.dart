import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_talk/theme/app_colors.dart';
import 'package:pet_talk/services/bluetooth/bluetooth_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothScanScreen extends ConsumerStatefulWidget {
  const BluetoothScanScreen({super.key});

  @override
  ConsumerState<BluetoothScanScreen> createState() => _BluetoothScanScreenState();
}

class _BluetoothScanScreenState extends ConsumerState<BluetoothScanScreen> {
  bool _showPermissionDialog = false;
  bool _showConnectingDialog = false;
  MockBluetoothDevice? _connectingDevice;
  bool _showSuccessDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeBluetooth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothManager = ref.watch(bluetoothManagerProvider);
    final discoveredDevices = ref.watch(bluetoothDiscoveredDevicesProvider);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Search Collar Devices',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 搜索状态卡片
              Container(
                margin: const EdgeInsets.all(16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: bluetoothManager.isScanning 
                      ? const Color(0xFFE3F2FD) 
                      : const Color(0xFFF5F5F5),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        if (bluetoothManager.isScanning)
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          Icon(
                            Icons.bluetooth,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        
                        const SizedBox(width: 12),
                        
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bluetoothManager.isScanning 
                                    ? 'Searching for collar devices...' 
                                    : 'Bluetooth Search',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              if (!bluetoothManager.isScanning && discoveredDevices.isNotEmpty)
                                Text(
                                  'Found ${discoveredDevices.length} device(s)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        
                        if (!bluetoothManager.isScanning)
                          IconButton(
                            onPressed: _startScan,
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
              
              // 设备列表
              Expanded(
                child: discoveredDevices.isNotEmpty
                    ? _buildDeviceList(discoveredDevices)
                    : _buildEmptyState(),
              ),
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

  Widget _buildDeviceList(List<MockBluetoothDevice> devices) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Available Devices',
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
            itemCount: devices.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final device = devices[index];
              return _buildDeviceItem(device);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceItem(MockBluetoothDevice device) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _connectToDevice(device),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 设备图标
              Icon(
                Icons.pets,
                color: AppColors.primary,
                size: 32,
              ),
              
              const SizedBox(width: 16),
              
              // 设备信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      device.id,
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
                    _getSignalIcon(device.rssi),
                    color: _getSignalColor(device.rssi),
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${device.rssi}dBm',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final bluetoothManager = ref.watch(bluetoothManagerProvider);
    
    if (bluetoothManager.isScanning) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Scanning for devices...',
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
            Icons.bluetooth_searching,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No collar devices found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please ensure the collar is powered on and in pairing mode',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _startScan,
            icon: const Icon(Icons.refresh),
            label: const Text('Search Again'),
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

  IconData _getSignalIcon(int rssi) {
    if (rssi > -50) return Icons.signal_cellular_4_bar;
    if (rssi > -60) return Icons.signal_cellular_alt;
    if (rssi > -70) return Icons.signal_cellular_alt;
    return Icons.signal_cellular_null;
  }

  Color _getSignalColor(int rssi) {
    if (rssi > -50) return const Color(0xFF4CAF50);
    if (rssi > -60) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  Future<void> _initializeBluetooth() async {
    final bluetoothManager = ref.read(bluetoothManagerProvider.notifier);
    
    // 请求蓝牙权限
    final hasPermissions = await _requestBluetoothPermissions();
    if (!hasPermissions) {
      setState(() {
        _showPermissionDialog = true;
      });
      return;
    }
    
    // 初始化蓝牙
    final initialized = await bluetoothManager.initialize();
    if (initialized) {
      _startScan();
    }
  }

  Future<bool> _requestBluetoothPermissions() async {
    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ];

    Map<Permission, PermissionStatus> statuses = await permissions.request();
    
    return statuses.values.every((status) => 
        status == PermissionStatus.granted || 
        status == PermissionStatus.limited);
  }

  void _startScan() {
    final bluetoothManager = ref.read(bluetoothManagerProvider.notifier);
    bluetoothManager.startScan(timeout: const Duration(seconds: 10));
  }

  Future<void> _connectToDevice(MockBluetoothDevice device) async {
    setState(() {
      _connectingDevice = device;
      _showConnectingDialog = true;
    });

    final bluetoothManager = ref.read(bluetoothManagerProvider.notifier);
    final success = await bluetoothManager.connectToDevice(device);
    
    setState(() {
      _showConnectingDialog = false;
    });

    if (success) {
      setState(() {
        _showSuccessDialog = true;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to connect to device'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
              Icons.bluetooth_disabled,
              size: 48,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            const Text(
              'Bluetooth Permission Required',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'To search and connect collar devices, please grant Bluetooth and location permissions.',
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
                      await _initializeBluetooth();
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
              'Connecting',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_connectingDevice != null)
              Text(
                _connectingDevice!.name,
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
            const Text(
              'Collar device connected successfully! Now you can proceed with WiFi setup.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
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