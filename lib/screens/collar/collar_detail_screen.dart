import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_talk/theme/app_colors.dart';
import 'package:pet_talk/models/bluetooth_models.dart';
import 'package:pet_talk/services/bluetooth/bluetooth_manager.dart';

class CollarDetailScreen extends ConsumerStatefulWidget {
  final String collarId;

  const CollarDetailScreen({
    super.key,
    required this.collarId,
  });

  @override
  ConsumerState<CollarDetailScreen> createState() => _CollarDetailScreenState();
}

class _CollarDetailScreenState extends ConsumerState<CollarDetailScreen> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    // Initialize bluetooth if needed
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final bluetoothManager = ref.read(bluetoothManagerProvider.notifier);
      if (!bluetoothManager.isEnabled) {
        await bluetoothManager.initialize();
      }
      if (mounted && ref.read(collarDataProvider) == null) {
        // 确保至少有一次数据渲染，避免一直Loading
        bluetoothManager
          ..stopScan()
          ..startScan(timeout: const Duration(seconds: 1));
      }
    });
  }

  Future<void> _refreshCollarData() async {
    setState(() {
      _isRefreshing = true;
    });

    final bluetoothManager = ref.read(bluetoothManagerProvider.notifier);
    
    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 2));
    
    if (bluetoothManager.connectionState == BluetoothConnectionState.connected) {
      // Send command to refresh hardware info
      await bluetoothManager.sendPacket(BluetoothPacket.deviceInfoGet());
    }

    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(bluetoothConnectionStateProvider);
    final collarData = ref.watch(collarDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Collar Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          // Connection status indicator
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getConnectionColor(connectionState).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getConnectionIcon(connectionState),
                  size: 16,
                  color: _getConnectionColor(connectionState),
                ),
                const SizedBox(width: 4),
                Text(
                  _getConnectionText(connectionState),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getConnectionColor(connectionState),
                  ),
                ),
              ],
            ),
          ),
          
      // Refresh button（仅连接时可用）
      IconButton(
        onPressed: (_isRefreshing || connectionState != BluetoothConnectionState.connected)
            ? null
            : _refreshCollarData,
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
            : Icon(
                Icons.refresh,
                color: connectionState == BluetoothConnectionState.connected
                    ? Colors.white
                    : Colors.white70,
              ),
          ),
        ],
      ),
      body: collarData == null
          ? _buildLoadingState(connectionState)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Battery Status（优先显示，与旧项目一致）
                  _buildBatteryStatusCard(collarData, connectionState),
                  const SizedBox(height: 16),
                  
                  // Collar Gems（进度条占位样式）
                  _buildGemsBarCard(collarData),
                  const SizedBox(height: 16),
                  
                  // Network Status（图标+上下文）
                  _buildNetworkStatusCard(collarData),
                  const SizedBox(height: 16),
                  
                  // Power Mode（两种模式的pill按钮）
                  _buildPowerModePills(collarData),
                  const SizedBox(height: 16),

                  // In Safe Zone pill
                  _buildSafeZonePill(collarData.isInSafeZone),
                  const SizedBox(height: 16),
                  
                  // WiFi Networks（标题+Manage + 列表/空态）
                  _buildWiFiNetworksCard(collarData),
                  const SizedBox(height: 16),

                  // System Information Card
                  _buildSystemInfoCard(collarData),
                  const SizedBox(height: 16),
                  
                  // Connection Management
                  if (connectionState != BluetoothConnectionState.connected)
                    _buildConnectionCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingState(BluetoothConnectionState state) {
    final String text = () {
      switch (state) {
        case BluetoothConnectionState.connected:
          return 'Loading collar data...';
        case BluetoothConnectionState.connecting:
          return 'Connecting to collar...';
        case BluetoothConnectionState.disconnected:
          return 'Collar not connected';
        case BluetoothConnectionState.disconnecting:
          return 'Disconnecting...';
        case BluetoothConnectionState.error:
          return 'Connection error';
      }
    }();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryStatusCard(PetCollar collar, BluetoothConnectionState state) {
    final batteryColor = _getBatteryColor(collar.batteryLevel);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getBatteryIcon(collar.batteryLevel), color: batteryColor, size: 24),
                const SizedBox(width: 12),
                const Text('Battery Status', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Battery level progress + large text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: collar.batteryLevel == -1 ? null : collar.batteryLevel / 100,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(batteryColor),
                      minHeight: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  collar.batteryLevel == -1 ? '—' : '${collar.batteryLevel}%',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: batteryColor),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              collar.batteryLevel == -1
                  ? 'Please wait'
                  : _getBatteryStatusText(collar.batteryLevel),
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGemsBarCard(PetCollar collar) {
    final connected = collar.gems.where((g) => g.isConnected).length;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Collar Gems', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary)),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: connected / 4,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 14,
              ),
            ),
            const SizedBox(height: 16),
            Text('$connected/4 Gems Connected', style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildGemIndicator(int position, CollarGem gem) {
    final isActive = gem.isConnected && gem.isRecognized;
    
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.grey.shade300,
            shape: BoxShape.circle,
            border: Border.all(
              color: gem.isConnected ? AppColors.success : AppColors.error,
              width: 2,
            ),
          ),
          child: Icon(
            _getGemIcon(gem.type),
            color: isActive ? Colors.white : Colors.grey,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pos ${position + 1}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          gem.type.displayName,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkStatusCard(PetCollar collar) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.network_check,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Network Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNetworkStatusItem(
                  Icons.bluetooth,
                  'Bluetooth',
                  collar.bluetoothConnected,
                ),
                _buildNetworkStatusItem(
                  Icons.wifi,
                  'WiFi',
                  collar.wifiConnected,
                ),
                _buildNetworkStatusItem(
                  Icons.shield,
                  'Safe Zone',
                  collar.isInSafeZone,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWiFiManagementCard(PetCollar collar) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.wifi, color: AppColors.primary, size: 24),
                SizedBox(width: 12),
                Text(
                  'WiFi Management',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  collar.connectedWifiNetworks.isNotEmpty
                      ? 'Connected: ${collar.connectedWifiNetworks.where((e) => e.isConnected).length} network(s)'
                      : 'No WiFi configured',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('WiFi management coming soon')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Manage', style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkStatusItem(IconData icon, String label, bool isConnected) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isConnected ? AppColors.success : AppColors.error,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          isConnected ? 'Connected' : 'Disconnected',
          style: TextStyle(
            fontSize: 10,
            color: isConnected ? AppColors.success : AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildPowerModePills(PetCollar collar) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Power Mode', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            
            Row(
              children: [
                _buildModePill(
                  label: 'Performance Mode',
                  selected: collar.powerMode == PowerMode.performance,
                  onTap: () => _changePowerMode(PowerMode.performance),
                ),
                const SizedBox(width: 12),
                _buildModePill(
                  label: 'Battery Saver Mode',
                  selected: collar.powerMode == PowerMode.battery,
                  onTap: () => _changePowerMode(PowerMode.battery),
                  outlined: true,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Full functionality with higher power consumption',
              style: TextStyle(color: AppColors.textSecondary),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildModePill({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected && !outlined ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: outlined ? Border.all(color: AppColors.primary, width: 2) : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: outlined ? Colors.black : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSafeZonePill(bool inSafeZone) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: inSafeZone ? const Color(0xFFE8FFF3) : const Color(0xFFFFEDED),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: inSafeZone ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(inSafeZone ? 'In Safe Zone' : 'Out of Safe Zone', style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildWiFiNetworksCard(PetCollar collar) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('WiFi Networks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                Text('Manage', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 12),
            if (collar.connectedWifiNetworks.isEmpty)
              const Text('No WiFi networks configured', style: TextStyle(color: AppColors.textSecondary))
            else
              Column(
                children: collar.connectedWifiNetworks
                    .map((n) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.wifi, color: AppColors.primary),
                          title: Text(n.ssid),
                          trailing: n.isConnected ? const Text('Connected', style: TextStyle(color: AppColors.success)) : null,
                        ))
                    .toList(),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildSafeZoneCard(PetCollar collar) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: collar.isInSafeZone ? AppColors.success : AppColors.warning,
                shape: BoxShape.circle,
              ),
              child: Icon(
                collar.isInSafeZone ? Icons.shield : Icons.warning,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collar.isInSafeZone ? 'In Safe Zone' : 'Outside Safe Zone',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: collar.isInSafeZone ? AppColors.success : AppColors.warning,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    collar.isInSafeZone 
                        ? 'Your pet is within the designated safe area'
                        : 'Your pet has left the safe zone. Check location.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
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

  Widget _buildSystemInfoCard(PetCollar collar) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                  'System Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildInfoRow('Device Name', collar.name),
            _buildInfoRow('Firmware Version', collar.firmwareVersion),
            _buildInfoRow('Device ID', collar.id),
            _buildInfoRow('Pet ID', collar.petId),
            _buildInfoRow('Steps Today', '${collar.steps}'),
            _buildInfoRow('Heart Rate', '${collar.heartRate} BPM'),
            _buildInfoRow('Last Sync', DateTime.fromMillisecondsSinceEpoch(collar.lastSyncTime).toString().substring(0, 19)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.bluetooth_disabled,
              size: 60,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Collar Not Connected',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please connect to your pet\'s collar to view live data',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const BluetoothScanScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Connect to Collar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Color _getConnectionColor(BluetoothConnectionState state) {
    switch (state) {
      case BluetoothConnectionState.connected:
        return AppColors.success;
      case BluetoothConnectionState.connecting:
        return AppColors.warning;
      case BluetoothConnectionState.disconnecting:
        return AppColors.warning;
      case BluetoothConnectionState.disconnected:
      case BluetoothConnectionState.error:
        return AppColors.error;
    }
  }

  IconData _getConnectionIcon(BluetoothConnectionState state) {
    switch (state) {
      case BluetoothConnectionState.connected:
        return Icons.bluetooth_connected;
      case BluetoothConnectionState.connecting:
        return Icons.bluetooth_searching;
      case BluetoothConnectionState.disconnecting:
        return Icons.bluetooth_searching;
      case BluetoothConnectionState.disconnected:
      case BluetoothConnectionState.error:
        return Icons.bluetooth_disabled;
    }
  }

  String _getConnectionText(BluetoothConnectionState state) {
    switch (state) {
      case BluetoothConnectionState.connected:
        return 'Connected';
      case BluetoothConnectionState.connecting:
        return 'Connecting';
      case BluetoothConnectionState.disconnected:
        return 'Disconnected';
      case BluetoothConnectionState.disconnecting:
        return 'Disconnecting';
      case BluetoothConnectionState.error:
        return 'Error';
    }
  }

  Color _getBatteryColor(int level) {
    if (level > 50) return AppColors.success;
    if (level > 20) return AppColors.warning;
    return AppColors.error;
  }

  IconData _getBatteryIcon(int level) {
    if (level > 80) return Icons.battery_full;
    if (level > 60) return Icons.battery_6_bar;
    if (level > 40) return Icons.battery_4_bar;
    if (level > 20) return Icons.battery_2_bar;
    return Icons.battery_1_bar;
  }

  String _getBatteryStatusText(int level) {
    if (level > 50) return 'Battery level is good';
    if (level > 20) return 'Battery level is low, consider charging';
    return 'Battery level is critical, please charge immediately';
  }

  IconData _getGemIcon(GemType type) {
    switch (type) {
      case GemType.barometer:
        return Icons.speed;
      case GemType.accelerometer:
        return Icons.track_changes;
      case GemType.gyroscope:
        return Icons.rotate_right;
      case GemType.magnetometer:
        return Icons.compass_calibration;
      case GemType.none:
        return Icons.help_outline;
    }
  }

  String _getPowerModeDescription(PowerMode mode) {
    switch (mode) {
      case PowerMode.energySaving:
        return 'Maximum battery life, reduced features';
      case PowerMode.balanced:
        return 'Balance between battery and performance';
      case PowerMode.performance:
        return 'Full features, higher battery consumption';
      case PowerMode.battery:
        return 'Battery saving mode';
    }
  }

  Future<void> _changePowerMode(PowerMode mode) async {
    final bluetoothManager = ref.read(bluetoothManagerProvider.notifier);
    
    if (bluetoothManager.connectionState == BluetoothConnectionState.connected) {
      final success = await bluetoothManager.sendPacket(
        BluetoothPacket(
          command: BluetoothCommand.modelSet,
          subCommand: 0, // SET
          data: Uint8List.fromList([mode.index]),
        ),
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Power mode changed to ${mode.displayName}'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to change power mode'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

// Bluetooth Scan Screen
class BluetoothScanScreen extends ConsumerStatefulWidget {
  const BluetoothScanScreen({super.key});

  @override
  ConsumerState<BluetoothScanScreen> createState() => _BluetoothScanScreenState();
}

class _BluetoothScanScreenState extends ConsumerState<BluetoothScanScreen> {
  @override
  void initState() {
    super.initState();
    // Start scanning when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bluetoothManager = ref.read(bluetoothManagerProvider.notifier);
      bluetoothManager.startScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothManagerState = ref.watch(bluetoothManagerProvider);
    final discoveredDevices = ref.watch(bluetoothDiscoveredDevicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to Collar'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          if (bluetoothManagerState.isScanning)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            IconButton(
              onPressed: () => ref.read(bluetoothManagerProvider.notifier).startScan(),
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: Column(
        children: [
          // Scanning status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: bluetoothManagerState.isScanning 
                ? AppColors.info.withOpacity(0.1)
                : AppColors.background,
            child: Text(
              bluetoothManagerState.isScanning 
                  ? 'Scanning for pet collars...'
                  : 'Found ${discoveredDevices.length} device(s)',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Device list
          Expanded(
            child: discoveredDevices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bluetooth_searching,
                          size: 80,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          bluetoothManagerState.isScanning 
                              ? 'Searching for devices...'
                              : 'No devices found',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (!bluetoothManagerState.isScanning) ...[
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.read(bluetoothManagerProvider.notifier).startScan(),
                            child: const Text('Start Scan'),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: discoveredDevices.length,
                    itemBuilder: (context, index) {
                      final device = discoveredDevices[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(
                            Icons.bluetooth,
                            color: AppColors.primary,
                          ),
                          title: Text(
                            device.name.isEmpty ? 'Unknown Device' : device.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ID: ${device.id}'),
                              Text('Signal: ${device.rssi} dBm'),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => _connectToDevice(device),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            child: const Text(
                              'Connect',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _connectToDevice(MockBluetoothDevice device) async {
    final bluetoothManager = ref.read(bluetoothManagerProvider.notifier);
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Connecting to collar...'),
          ],
        ),
      ),
    );

    try {
      final success = await bluetoothManager.connectToDevice(device);
      
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connected to ${device.name}'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop(); // Go back to collar detail
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to connect to device'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Stop scanning when leaving screen
    final bluetoothManager = ref.read(bluetoothManagerProvider.notifier);
    bluetoothManager.stopScan();
    super.dispose();
  }
}