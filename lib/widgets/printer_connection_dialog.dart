import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/bluetooth_printer_service.dart';

class PrinterConnectionDialog extends StatefulWidget {
  const PrinterConnectionDialog({super.key});

  @override
  State<PrinterConnectionDialog> createState() =>
      _PrinterConnectionDialogState();
}

class _PrinterConnectionDialogState extends State<PrinterConnectionDialog> {
  late BluetoothPrinterService _printerService;
  List<Map<String, String>> _devices = [];
  bool _isLoading = false;
  bool _isConnected = false;
  String? _selectedAddress;
  String? _connectedDevice;
  bool _bluetoothEnabled = false;
  final TextEditingController _macAddressController = TextEditingController();
  bool _showManualInput = false;
  dynamic _scanSubscription;

  @override
  void initState() {
    super.initState();
    _printerService = BluetoothPrinterService();
    _checkConnectionStatus();

    // Request permissions and load devices
    _requestBluetoothPermissionsAndLoad();

    // Listen untuk real-time device updates
    _setupDeviceListener();
  }

  /// Request Bluetooth permissions dan load devices
  Future<void> _requestBluetoothPermissionsAndLoad() async {
    if (kDebugMode) print('🔐 [Dialog] Requesting Bluetooth permissions...');

    try {
      // Request Bluetooth Scan permission (Android 12+)
      final scanStatus = await Permission.bluetooth.request();
      if (kDebugMode) print('   Bluetooth: $scanStatus');

      // Request Bluetooth Connect permission (Android 12+)
      final connectStatus = await Permission.bluetoothConnect.request();
      if (kDebugMode) print('   Bluetooth Connect: $connectStatus');

      // Request Bluetooth Scan permission (Android 12+)
      final scanAdvStatus = await Permission.bluetoothScan.request();
      if (kDebugMode) print('   Bluetooth Scan: $scanAdvStatus');

      // Request location permission (sometimes needed for BLE scan)
      final locStatus = await Permission.locationWhenInUse.request();
      if (kDebugMode) print('   Location: $locStatus');

      if (kDebugMode) print('✅ [Dialog] Permission request completed');

      // Now load devices
      _loadDevices();
    } catch (e) {
      if (kDebugMode) print('❌ [Dialog] Permission error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error requesting permissions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _setupDeviceListener() {
    // Listen ke stream devices dari printer service
    _printerService.devicesStream.listen((devices) {
      if (mounted) {
        setState(() {
          _devices = devices
              .map(
                (device) => {
                  'name': device.advName.isNotEmpty
                      ? device.advName
                      : 'Unknown',
                  'address': device.remoteId.str,
                },
              )
              .toList();
        });
      }
    });

    // Listen ke connection state changes
    _printerService.connectionStateStream.listen((isConnected) {
      if (mounted) {
        _checkConnectionStatus();
      }
    });
  }

  Future<void> _checkConnectionStatus() async {
    setState(() {
      _isConnected = _printerService.isConnected;
      _connectedDevice = _printerService.connectedDeviceName;
    });
  }

  Future<void> _loadDevices() async {
    if (kDebugMode) print('🔍 [Dialog] Loading devices...');
    setState(() => _isLoading = true);

    try {
      // 1. Check Bluetooth state
      if (kDebugMode) print('   Checking Bluetooth state...');
      final isAvailable = await FlutterBluePlus.isAvailable;
      final isOn = await FlutterBluePlus.isOn;

      if (kDebugMode) {
        print('   Available: $isAvailable, Is ON: $isOn');
      }

      if (!isOn) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '❌ Bluetooth belum diaktifkan! Silakan aktifkan di pengaturan Android.',
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // 2. Get devices with timeout
      if (kDebugMode) print('   Calling service.getAvailableDevices()...');
      List<Map<String, String>> devices = [];
      try {
        devices = await _printerService.getAvailableDevices().timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            if (kDebugMode)
              print('⚠️ getAvailableDevices timed out after 15 seconds');
            return [];
          },
        );
      } catch (e) {
        if (kDebugMode) print('⚠️ getAvailableDevices error: $e');
        devices = [];
      }

      if (mounted) {
        setState(() {
          _devices = devices;
          _isLoading = false;
          _bluetoothEnabled = true;
          if (kDebugMode) print('✅ [Dialog] Loaded ${devices.length} devices');

          if (devices.isEmpty) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '❌ Tidak ada printer ditemukan. Pastikan sudah dipair di Bluetooth settings!',
                    ),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 4),
                  ),
                );
              }
            });
          }
        });
      }
    } catch (e) {
      if (kDebugMode) print('❌ [Dialog] Error loading devices: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _connectToPrinter(String address, String deviceName) async {
    if (kDebugMode) print('🔌 Attempting to connect to $deviceName ($address)');

    setState(() => _isLoading = true);

    try {
      final success = await _printerService.connect(
        address: address,
        deviceName: deviceName,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          if (kDebugMode) print('✅ Successfully connected to $deviceName');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Berhasil terhubung ke $deviceName!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          _checkConnectionStatus();
        } else {
          if (kDebugMode) print('❌ Failed to connect to $deviceName');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Gagal menghubungkan ke $deviceName'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ Connection exception: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _testPrint() async {
    if (kDebugMode) print('🖨️ Starting test print...');

    setState(() => _isLoading = true);

    try {
      final success = await _printerService.testPrint();

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          if (kDebugMode) print('✅ Test print successful');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Test print berhasil!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          if (kDebugMode) print('❌ Test print failed');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Test print gagal'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ Test print exception: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _disconnect() async {
    if (kDebugMode) print('🔌 Disconnecting printer...');

    await _printerService.disconnect();
    _checkConnectionStatus();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Printer disconnected'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.print, size: 28, color: Colors.blue),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Koneksi Printer Bluetooth',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Connection Status
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isConnected ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isConnected ? Colors.green : Colors.red,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isConnected ? Icons.check_circle : Icons.cancel,
                      color: _isConnected ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isConnected
                                ? 'Terhubung: $_connectedDevice'
                                : 'Tidak terhubung',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isConnected ? Colors.green : Colors.red,
                            ),
                          ),
                          Text(
                            _isConnected
                                ? 'Printer siap digunakan'
                                : 'Pilih printer dari daftar',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Available Devices
              const Text(
                'Printer Tersedia:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (!_bluetoothEnabled)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.bluetooth_disabled,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Bluetooth tidak diaktifkan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Silakan aktifkan Bluetooth di pengaturan Android',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else if (_devices.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.devices_other, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        const Text('Tidak ada printer yang ditemukan'),
                        const SizedBox(height: 8),
                        Text(
                          'Pastikan printer Bluetooth sudah dipasangkan di setting Android',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            setState(() => _showManualInput = true);
                          },
                          child: const Text('📝 Input MAC Address Manual'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    final deviceName = device['name'] ?? 'Unknown';
                    final deviceAddress = device['address'] ?? '';
                    final isSelected = _selectedAddress == deviceAddress;
                    final isConnectedDevice =
                        _isConnected && _connectedDevice == deviceName;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        selected: isSelected || isConnectedDevice,
                        selectedTileColor: Colors.blue[50],
                        leading: Icon(
                          Icons.print,
                          color: isConnectedDevice ? Colors.green : Colors.grey,
                        ),
                        title: Text(
                          deviceName,
                          style: TextStyle(
                            fontWeight: isConnectedDevice
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isConnectedDevice
                                ? Colors.green
                                : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          deviceAddress,
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: isConnectedDevice
                            ? const Chip(
                                label: Text('Connected'),
                                backgroundColor: Colors.green,
                                labelStyle: TextStyle(color: Colors.white),
                              )
                            : null,
                        onTap: _isLoading
                            ? null
                            : () {
                                if (kDebugMode) {
                                  print(
                                    '👆 Tapped device: $deviceName ($deviceAddress)',
                                  );
                                }
                                setState(
                                  () => _selectedAddress = deviceAddress,
                                );
                                _connectToPrinter(deviceAddress, deviceName);
                              },
                      ),
                    );
                  },
                ),

              // Manual MAC Address Input
              if (_showManualInput || _devices.isEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📝 Input MAC Address Manual',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _macAddressController,
                        decoration: InputDecoration(
                          hintText: 'Contoh: 5A:4A:DB:69:2B:9D',
                          prefixIcon: const Icon(Icons.bluetooth),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        maxLength: 17,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lihat MAC address di Bluetooth settings Android (Connected devices)',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() => _showManualInput = false);
                                _macAddressController.clear();
                              },
                              child: const Text('Batal'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _macAddressController.text.isEmpty
                                  ? null
                                  : () {
                                      final macAddress = _macAddressController
                                          .text
                                          .trim()
                                          .toUpperCase();
                                      // Validate MAC address format
                                      if (!RegExp(
                                        r'^([0-9A-F]{2}[:]){5}([0-9A-F]{2})$',
                                      ).hasMatch(macAddress)) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              '❌ Format MAC address salah. Gunakan format: AA:BB:CC:DD:EE:FF',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      setState(() {
                                        _selectedAddress = macAddress;
                                        _showManualInput = false;
                                      });
                                      _connectToPrinter(
                                        macAddress,
                                        'Manual Device',
                                      );
                                      _macAddressController.clear();
                                    },
                              icon: const Icon(Icons.check),
                              label: const Text('Hubungkan'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _loadDevices,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_isConnected)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _disconnect,
                        icon: const Icon(Icons.bluetooth_disabled),
                        label: const Text('Disconnect'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : (_selectedAddress != null
                                  ? () {
                                      final device = _devices.firstWhere(
                                        (d) => d['address'] == _selectedAddress,
                                        orElse: () => {'name': 'Unknown'},
                                      );
                                      _connectToPrinter(
                                        _selectedAddress!,
                                        device['name'] ?? 'Unknown',
                                      );
                                    }
                                  : null),
                        icon: const Icon(Icons.link),
                        label: const Text('Connect'),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Test Print Button
              if (_isConnected)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testPrint,
                    icon: const Icon(Icons.print),
                    label: const Text('Test Print'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

              // Info
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💡 Tips:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Pastikan printer Bluetooth menyala\n'
                      '• Printer harus sudah dipasangkan di Android Settings\n'
                      '• Jika tidak muncul, refresh dan coba ulang\n'
                      '• Gunakan Test Print untuk memastikan koneksi',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _macAddressController.dispose();
    _scanSubscription?.cancel();
    super.dispose();
  }
}
