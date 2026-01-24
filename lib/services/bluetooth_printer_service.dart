import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/printer_config.dart';

/// ESC/POS Command Helper - Standar printer thermal
class EscPosCommands {
  // Control codes
  static const List<int> initialize = [0x1B, 0x40]; // ESC @ - Reset
  static const List<int> lineFeed = [0x0A]; // LF
  static const List<int> carriageReturn = [0x0D]; // CR
  static const List<int> formFeed = [0x0C]; // FF
  static const List<int> bell = [0x07]; // BEL

  // Text alignment
  static const List<int> alignLeft = [0x1B, 0x61, 0x00];
  static const List<int> alignCenter = [0x1B, 0x61, 0x01];
  static const List<int> alignRight = [0x1B, 0x61, 0x02];

  // Font/Style
  static const List<int> fontNormal = [0x1B, 0x4D, 0x00];
  static const List<int> fontBold = [0x1B, 0x45, 0x01];
  static const List<int> fontBoldOff = [0x1B, 0x45, 0x00];
  static const List<int> doubleHeight = [0x1B, 0x21, 0x10];
  static const List<int> doubleWidth = [0x1B, 0x21, 0x20];
  static const List<int> normalSize = [0x1B, 0x21, 0x00];

  // Cut paper
  static const List<int> partialCut = [0x1B, 0x69];
  static const List<int> fullCut = [0x1B, 0x6D];

  // Drawer kick
  static const List<int> drawerKick = [0x1B, 0x70, 0x00];

  // QR Code (if supported)
  static List<int> qrCode(String data) {
    // Format: ESC * a,nL,nH,d1...dn
    final bytes = <int>[];
    bytes.addAll([0x1B, 0x2A]); // ESC *
    // QR Code specific implementation would go here
    return bytes;
  }

  /// Create bytes from text with proper encoding
  static List<int> textToBytes(String text) {
    return text.codeUnits.cast<int>();
  }

  /// Feed n lines
  static List<int> feedLines(int lines) {
    final bytes = <int>[];
    for (int i = 0; i < lines; i++) {
      bytes.addAll(lineFeed);
    }
    return bytes;
  }

  /// Horizontal line
  static List<int> horizontalLine({String char = '-', int length = 40}) {
    final bytes = <int>[];
    bytes.addAll(textToBytes(char * length));
    bytes.addAll(lineFeed);
    return bytes;
  }
}

/// Unified Printer Service untuk Bluetooth, Network, dan USB
class BluetoothPrinterService {
  static final BluetoothPrinterService _instance =
      BluetoothPrinterService._internal();

  factory BluetoothPrinterService() {
    return _instance;
  }

  BluetoothPrinterService._internal();

  BluetoothDevice? _connectedDevice;
  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;
  final _connectionStateController = StreamController<bool>.broadcast();
  final _devicesFoundController =
      StreamController<List<BluetoothDevice>>.broadcast();
  final List<BluetoothDevice> _discoveredDevices = [];

  bool _isConnected = false;
  String? _connectedDeviceName;
  String? _connectedAddress;

  // Network printer
  Socket? _networkSocket;
  String? _currentNetworkIp;
  int _currentNetworkPort = 9100;

  // Cache for characteristics (untuk BLE)
  BluetoothCharacteristic? _writeCharacteristic;

  // Platform channel untuk Android
  static const platform = MethodChannel('com.example.pos_artha26/bluetooth');

  bool get isConnected => _isConnected;
  String? get connectedDeviceName => _connectedDeviceName;
  String? get connectedAddress => _connectedAddress;
  Stream<bool> get connectionStateStream => _connectionStateController.stream;
  Stream<List<BluetoothDevice>> get devicesStream =>
      _devicesFoundController.stream;

  /// Scan Bluetooth devices - SIMPLIFIED untuk fokus pada bonded devices
  Future<List<Map<String, String>>> getAvailableDevices() async {
    try {
      if (kDebugMode) print('📱 [BT] Getting available Bluetooth devices...');
      _discoveredDevices.clear();
      final result = <Map<String, String>>[];

      // 1. Try to get bonded devices from Android platform (most reliable!)
      if (kDebugMode)
        print('   [BT] Step 1: Get bonded devices from Android...');
      try {
        if (kDebugMode)
          print('   📞 Calling platform.invokeMethod with timeout...');

        // Call with timeout to prevent freezing
        final bondedDevices = await platform
            .invokeMethod<List>('getBondedDevices')
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                if (kDebugMode)
                  print('   ⚠️ Platform call timed out after 10 seconds');
                return null;
              },
            );

        if (bondedDevices != null && bondedDevices.isNotEmpty) {
          if (kDebugMode)
            print('   ✅ Found ${bondedDevices.length} bonded devices');

          for (var device in bondedDevices) {
            try {
              final deviceMap = Map<String, dynamic>.from(device as Map);
              final name = deviceMap['name'] as String? ?? 'Unknown';
              final address = deviceMap['address'] as String? ?? '';

              if (name.isNotEmpty && address.isNotEmpty) {
                result.add({'name': name, 'address': address});
                if (kDebugMode) print('      ✅ $name ($address)');
              }
            } catch (e) {
              if (kDebugMode) print('      ⚠️ Error parsing device: $e');
            }
          }
        } else {
          if (kDebugMode)
            print('   ℹ️ No bonded devices found or null response');
        }
      } catch (e) {
        if (kDebugMode)
          print('   ⚠️ Platform method error: $e (${e.runtimeType})');
      }

      // 2. Load connected devices as fallback
      if (kDebugMode) print('   [BT] Step 2: Get connected devices...');
      try {
        final connectedDevices = FlutterBluePlus.connectedDevices;
        if (kDebugMode)
          print('   Found ${connectedDevices.length} connected devices');

        for (var device in connectedDevices) {
          final address = device.remoteId.str;
          // Avoid duplicates
          if (!result.any((d) => d['address'] == address)) {
            final name = device.advName.isNotEmpty
                ? device.advName
                : device.platformName;
            if (name.isNotEmpty && address.isNotEmpty) {
              result.add({'name': name, 'address': address});
              if (kDebugMode) print('      ✅ $name ($address)');
            }
          }
        }
      } catch (e) {
        if (kDebugMode) print('   ⚠️ Error getting connected: $e');
      }

      if (kDebugMode) {
        print('✅ [BT] Total devices: ${result.length}');
        for (var d in result) {
          print('   📱 ${d['name']} | ${d['address']}');
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) print('❌ [BT] Error: $e');
      return [];
    }
  }

  /// Connect ke device
  Future<bool> connect({required String address, String? deviceName}) async {
    try {
      if (kDebugMode)
        print('🔌 [Connect] Connecting to: $address ($deviceName)');

      // Stop scan
      try {
        await FlutterBluePlus.stopScan();
      } catch (e) {
        if (kDebugMode) print('⚠️ Stop scan: $e');
      }

      // Disconnect previous
      if (_isConnected && _connectedDevice != null) {
        try {
          if (kDebugMode) print('   Disconnecting from previous device...');
          await disconnect();
        } catch (e) {
          if (kDebugMode) print('⚠️ Disconnect prev: $e');
        }
      }

      // Find device dari bonded/discovered devices
      BluetoothDevice? targetDevice;

      // 1. Cari di discovered devices
      try {
        targetDevice = _discoveredDevices.firstWhere(
          (d) => d.remoteId.str == address,
        );
        if (kDebugMode) print('   ✅ Found device in discovered list');
      } catch (e) {
        if (kDebugMode)
          print('   ⚠️ Device not in discovered list, trying connected...');

        // 2. Cari di connected devices
        try {
          targetDevice = FlutterBluePlus.connectedDevices.firstWhere(
            (d) => d.remoteId.str == address,
          );
          if (kDebugMode) print('   ✅ Found device in connected list');
        } catch (e2) {
          // 3. Jika tidak ada, buat device baru dari address saja
          if (kDebugMode)
            print('   ⚠️ Device not found, creating from address...');
          targetDevice = BluetoothDevice(remoteId: DeviceIdentifier(address));
        }
      }

      if (kDebugMode) {
        final displayName = targetDevice.advName.isNotEmpty
            ? targetDevice.advName
            : targetDevice.platformName;
        print('   Device: $displayName');
      }

      // Listen connection state
      _connectionSubscription?.cancel();
      _connectionSubscription = targetDevice.connectionState.listen((state) {
        if (kDebugMode) print('   📡 Connection state changed: $state');
        if (state == BluetoothConnectionState.connected) {
          _isConnected = true;
          _connectedDevice = targetDevice;
          _connectedDeviceName = deviceName ?? targetDevice!.advName;
          _connectedAddress = address;
          _writeCharacteristic =
              null; // Reset characteristic cache on new connection
          _connectionStateController.add(true);
          if (kDebugMode) print('   ✅ State listener: Connected!');
        } else if (state == BluetoothConnectionState.disconnected) {
          _isConnected = false;
          _connectedDevice = null;
          _connectedDeviceName = null;
          _connectedAddress = null;
          _writeCharacteristic = null;
          _connectionStateController.add(false);
          if (kDebugMode) print('   ⚠️ State listener: Disconnected');
        }
      });

      // Connect with timeout
      if (kDebugMode) print('   🔗 Calling device.connect()...');
      try {
        await targetDevice.connect(timeout: const Duration(seconds: 15));
        if (kDebugMode) print('   ✅ connect() completed');
      } catch (e) {
        if (kDebugMode) print('   ⚠️ connect() error: $e');
      }

      // Wait a bit and check status
      await Future.delayed(const Duration(seconds: 1));

      final isConnected = targetDevice.isConnected;
      if (kDebugMode) print('   Checking isConnected: $isConnected');

      if (isConnected) {
        _isConnected = true;
        _connectedDevice = targetDevice;
        _connectedDeviceName = deviceName ?? targetDevice.advName;
        _connectedAddress = address;
        _writeCharacteristic = null; // Reset on successful connection
        _connectionStateController.add(true);
        if (kDebugMode)
          print('✅ [Connect] Successfully connected to $deviceName!');
        return true;
      } else {
        _isConnected = false;
        _connectedDevice = null;
        _connectionStateController.add(false);
        if (kDebugMode)
          print('❌ [Connect] Connection failed - device not connected');
        return false;
      }
    } catch (e) {
      if (kDebugMode) print('❌ [Connect] Fatal error: $e');
      _isConnected = false;
      _connectedDevice = null;
      _connectionStateController.add(false);
      return false;
    }
  }

  /// Keep printer connected - call this periodically or from UI
  Future<bool> maintainConnection() async {
    if (_connectedDevice == null || _connectedAddress == null) {
      if (kDebugMode) print('🔌 [Maintain] No printer configured');
      return false;
    }

    if (kDebugMode)
      print('🔌 [Maintain] Checking connection to $_connectedAddress...');

    // Check if still connected
    final isActuallyConnected = _connectedDevice!.isConnected;
    if (kDebugMode)
      print(
        '   Current state: isConnected=$isActuallyConnected, _isConnected=$_isConnected',
      );

    if (isActuallyConnected) {
      // Already connected, just update state if needed
      if (!_isConnected) {
        if (kDebugMode) print('   Syncing state...');
        _isConnected = true;
        _connectionStateController.add(true);
      }
      if (kDebugMode) print('   ✅ Still connected!');
      return true;
    } else {
      // Disconnected, try to reconnect
      if (kDebugMode) print('   ⚠️ Lost connection, attempting reconnect...');
      _isConnected = false;
      _connectionStateController.add(false);
      _writeCharacteristic = null;

      // Try reconnect
      final reconnectSuccess = await connect(
        address: _connectedAddress!,
        deviceName: _connectedDeviceName,
      );

      if (reconnectSuccess) {
        if (kDebugMode) print('   ✅ Reconnection successful!');
        return true;
      } else {
        if (kDebugMode) print('   ❌ Reconnection failed');
        return false;
      }
    }
  }

  /// Verify connection state - fixes out-of-sync state
  Future<bool> verifyConnection() async {
    if (kDebugMode) print('🔍 [Verify] Checking connection state...');

    if (_connectedDevice == null) {
      if (kDebugMode) print('   ❌ _connectedDevice is null');
      return false;
    }

    final isActuallyConnected = _connectedDevice!.isConnected;
    if (kDebugMode) print('   Device.isConnected: $isActuallyConnected');
    if (kDebugMode) print('   Our flag _isConnected: $_isConnected');

    if (isActuallyConnected != _isConnected) {
      if (kDebugMode) print('   ⚠️ STATE MISMATCH! Fixing...');
      _isConnected = isActuallyConnected;
      _connectionStateController.add(isActuallyConnected);
    }

    return isActuallyConnected;
  }

  /// Disconnect
  Future<void> disconnect() async {
    try {
      if (kDebugMode) print('🔌 Disconnecting...');
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
      }
      _isConnected = false;
      _connectedDevice = null;
      _connectedDeviceName = null;
      _connectedAddress = null;
      _connectionStateController.add(false);
      if (kDebugMode) print('✅ Disconnected');
    } catch (e) {
      if (kDebugMode) print('❌ Disconnect error: $e');
      _isConnected = false;
      _connectionStateController.add(false);
    }
  }

  /// Write bytes to printer with chunking support
  Future<bool> writeBytes(List<int> bytes) async {
    if (kDebugMode) print('📤 [Write] START - Writing ${bytes.length} bytes');
    if (kDebugMode) print('   _isConnected: $_isConnected');
    if (kDebugMode) print('   _connectedDevice: $_connectedDevice');
    if (kDebugMode) print('   _connectedDeviceName: $_connectedDeviceName');
    if (kDebugMode) print('   _connectedAddress: $_connectedAddress');

    if (!_isConnected || _connectedDevice == null) {
      if (kDebugMode)
        print(
          '❌ [Write] NOT CONNECTED - isConnected=$_isConnected, hasDevice=${_connectedDevice != null}',
        );
      return false;
    }

    try {
      // Re-verify device is actually still connected (in case state changed)
      final actuallyConnected = _connectedDevice!.isConnected;
      if (kDebugMode)
        print('   Device.isConnected (re-verified): $actuallyConnected');

      if (!actuallyConnected) {
        if (kDebugMode)
          print('❌ [Write] Device was connected but isConnected=false now');
        _isConnected = false; // Update state
        return false;
      }

      if (kDebugMode)
        print(
          '📤 [Write] Writing ${bytes.length} bytes to ${_connectedDevice!.advName}...',
        );

      // Try with cached characteristic first
      if (_writeCharacteristic != null) {
        try {
          if (kDebugMode) print('   Trying cached characteristic...');
          return await _writeCharacteristicWithChunking(
            _writeCharacteristic!,
            bytes,
          );
        } catch (e) {
          if (kDebugMode)
            print(
              '⚠️ [Write] Cached characteristic failed: $e, rediscovering...',
            );
          _writeCharacteristic = null; // Reset cache
        }
      }

      // Discover services and find writable characteristic
      try {
        if (kDebugMode) print('   Discovering services (attempt 1/3)...');

        // Give device time to be ready after connection
        await Future.delayed(const Duration(milliseconds: 500));

        var services = await _connectedDevice!.discoverServices();

        // If no services found, retry up to 3 times
        int attempts = 1;
        while (services.isEmpty && attempts < 3) {
          attempts++;
          if (kDebugMode)
            print('   ⚠️ No services found, retrying (attempt $attempts/3)...');
          await Future.delayed(const Duration(milliseconds: 800));
          services = await _connectedDevice!.discoverServices();
        }

        if (kDebugMode) {
          print('   ✅ Found ${services.length} services');
          if (services.isEmpty) {
            print('   ❌ CRITICAL: No services discovered after 3 attempts!');
            return false;
          }
          // List ALL characteristics for debugging
          print('   📋 ALL CHARACTERISTICS FOUND:');
          for (var service in services) {
            print('      Service: ${service.uuid}');
            for (var char in service.characteristics) {
              print('         - ${char.uuid}');
              print(
                '            read: ${char.properties.read}, write: ${char.properties.write}',
              );
              print(
                '            notify: ${char.properties.notify}, indicate: ${char.properties.indicate}',
              );
              print(
                '            writeNoResp: ${char.properties.writeWithoutResponse}',
              );
            }
          }
        }

        // Try to find BEST writable characteristic for printer
        // Priority: Custom UUID (100) > Custom Service (50) > Notify (25) > WriteNoResp (10) > Write (5)
        bool foundWritable = false;
        BluetoothCharacteristic? bestCharacteristic;
        int bestScore = -1;

        if (kDebugMode) print('🔍 SCORING ALL WRITABLE CHARACTERISTICS:');

        for (var service in services) {
          final serviceUuid = service.uuid.toString().toLowerCase();
          final isStandardService =
              serviceUuid == '1800' || serviceUuid == '1801';

          for (var characteristic in service.characteristics) {
            final canWrite =
                characteristic.properties.write ||
                characteristic.properties.writeWithoutResponse;

            if (!canWrite) continue;

            final charUuid = characteristic.uuid.toString().toLowerCase();

            // Check if it's a standard Bluetooth UUID (abbreviated format)
            // Standard UUIDs: 2a00, 2a01, 2af0, etc. (short form)
            // Custom UUIDs: full UUID with all 36 characters
            final isStandardUuid =
                charUuid.length <= 6 || // Short form like "2a00"
                RegExp(
                  r'^0000[0-9a-f]{4}-0000-1000-8000-00805f9b34fb$',
                ).hasMatch(charUuid);

            // Calculate score for this characteristic
            int score = 0;
            List<String> scoreReason = [];

            if (!isStandardUuid) {
              score += 100;
              scoreReason.add('Custom UUID (+100)');
            } else {
              scoreReason.add('Standard UUID (+0)');
            }

            if (!isStandardService) {
              score += 50;
              scoreReason.add('Custom Service (+50)');
            } else {
              scoreReason.add('Standard Service (+0)');
            }

            if (characteristic.properties.notify) {
              score += 25;
              scoreReason.add('Has Notify (+25)');
            }

            if (characteristic.properties.indicate) {
              score += 25;
              scoreReason.add('Has Indicate (+25)');
            }

            if (characteristic.properties.writeWithoutResponse) {
              score += 10;
              scoreReason.add('WriteNoResp (+10)');
            }

            if (characteristic.properties.write) {
              score += 5;
              scoreReason.add('Write (+5)');
            }

            if (kDebugMode) {
              print('   ${characteristic.uuid}');
              print('      Score: $score');
              for (var reason in scoreReason) {
                print('      → $reason');
              }
              if (score > bestScore) {
                print('      ✅ BEST SO FAR');
              }
            }

            if (score > bestScore) {
              bestScore = score;
              bestCharacteristic = characteristic;
              foundWritable = true;
            }
          }
        }

        if (kDebugMode) {
          print('✅ FINAL SELECTION:');
          print('   Characteristic: ${bestCharacteristic?.uuid}');
          print('   Score: $bestScore');
        }

        if (foundWritable && bestCharacteristic != null) {
          _writeCharacteristic = bestCharacteristic;
          if (kDebugMode) {
            print('✅ SELECTED CHARACTERISTIC: ${_writeCharacteristic!.uuid}');
            print(
              '   write: ${_writeCharacteristic!.properties.write}, writeWithoutResponse: ${_writeCharacteristic!.properties.writeWithoutResponse}',
            );
            print(
              '   notify: ${_writeCharacteristic!.properties.notify}, indicate: ${_writeCharacteristic!.properties.indicate}',
            );
          }

          // Try to write with best characteristic found
          try {
            if (kDebugMode) print('   Writing ${bytes.length} bytes...');
            final success = await _writeCharacteristicWithChunking(
              _writeCharacteristic!,
              bytes,
            );
            if (success) {
              return true;
            } else {
              if (kDebugMode) print('⚠️ [Write] Writing returned false');
              _writeCharacteristic = null;
              return false;
            }
          } catch (e) {
            if (kDebugMode)
              print('⚠️ [Write] Write failed: $e (${e.runtimeType})');
            _writeCharacteristic = null;
            return false;
          }
        }

        // No writable characteristic found
        if (!foundWritable) {
          if (kDebugMode) {
            print('❌ [Write] NO writable characteristic found at all!');
            print('   Services found: ${services.length}');
            for (var service in services) {
              print(
                '      ${service.uuid}: ${service.characteristics.length} chars',
              );
              for (var char in service.characteristics) {
                print(
                  '         ${char.uuid}: write=${char.properties.write}, writeNoResp=${char.properties.writeWithoutResponse}',
                );
              }
            }
          }
          return false;
        }

        if (kDebugMode) {
          print('❌ [Write] Selected characteristic but failed to write');
        }
      } catch (e) {
        if (kDebugMode)
          print('⚠️ [Write] Service discovery error: $e (${e.runtimeType})');
        return false;
      }

      // Should not reach here
      if (kDebugMode) print('❌ [Write] Unexpected: fell through all checks');
      return false;
    } catch (e) {
      if (kDebugMode) print('❌ [Write] Fatal error: $e');
      return false;
    }
  }

  /// Helper method to write data with chunking for large payloads
  Future<bool> _writeCharacteristicWithChunking(
    BluetoothCharacteristic characteristic,
    List<int> bytes,
  ) async {
    const int maxChunkSize = 237; // Safe size for most BLE devices

    if (bytes.length <= maxChunkSize) {
      // Small enough to send in one chunk
      if (kDebugMode)
        print(
          '📝 [Chunk] Writing single packet: ${bytes.length} bytes to ${characteristic.uuid}',
        );

      try {
        // Check if we can write without response (faster)
        if (characteristic.properties.writeWithoutResponse) {
          if (kDebugMode) print('   Using write WITHOUT response (faster)');
          await characteristic.write(bytes, withoutResponse: true);
          if (kDebugMode) print('   ✅ Write without response completed');
        } else if (characteristic.properties.write) {
          if (kDebugMode) print('   Using write WITH response');
          await characteristic.write(bytes);
          if (kDebugMode) print('   ✅ Write with response completed');
        } else {
          if (kDebugMode)
            print(
              '   ❌ Characteristic does not support write or writeWithoutResponse',
            );
          return false;
        }

        if (kDebugMode)
          print('✅ [Write] Successfully written ${bytes.length} bytes');
        return true;
      } catch (e) {
        if (kDebugMode)
          print('   ❌ Write failed with error: $e (${e.runtimeType})');
        return false;
      }
    }

    // Need to chunk the data
    if (kDebugMode)
      print('   📦 Data exceeds ${maxChunkSize}b, chunking into pieces...');

    int totalChunks = (bytes.length / maxChunkSize).ceil();
    if (kDebugMode) print('   📦 Total chunks to send: $totalChunks');

    int successfulChunks = 0;

    for (int i = 0; i < bytes.length; i += maxChunkSize) {
      int end = (i + maxChunkSize).clamp(0, bytes.length);
      List<int> chunk = bytes.sublist(i, end);
      int chunkNum = (i ~/ maxChunkSize) + 1;

      if (kDebugMode)
        print('   📦 Chunk $chunkNum/$totalChunks: ${chunk.length} bytes');

      try {
        // Check write capabilities and write
        bool writeSuccess = false;

        if (characteristic.properties.writeWithoutResponse) {
          if (kDebugMode) print('      → Using write WITHOUT response');
          await characteristic.write(chunk, withoutResponse: true);
          writeSuccess = true;
          if (kDebugMode) print('      ✅ Write without response sent');
        } else if (characteristic.properties.write) {
          if (kDebugMode) print('      → Using write WITH response');
          await characteristic.write(chunk);
          writeSuccess = true;
          if (kDebugMode) print('      ✅ Write with response confirmed');
        } else {
          if (kDebugMode)
            print('      ❌ Characteristic does not support write methods');
          return false;
        }

        if (writeSuccess) {
          successfulChunks++;
          // Add delay between chunks to prevent buffer overflow
          if (chunkNum < totalChunks) {
            await Future.delayed(const Duration(milliseconds: 100));
          }
        }
      } catch (e) {
        if (kDebugMode)
          print('      ❌ Chunk $chunkNum failed: $e (${e.runtimeType})');
        return false;
      }
    }

    if (successfulChunks == totalChunks) {
      if (kDebugMode)
        print(
          '✅ [Write] All $totalChunks chunks written successfully (total: ${bytes.length} bytes)',
        );
      return true;
    } else {
      if (kDebugMode)
        print('❌ [Write] Only $successfulChunks/$totalChunks chunks succeeded');
      return false;
    }
  }

  /// Print text
  Future<bool> printText({required String content}) async {
    if (!_isConnected) {
      if (kDebugMode) print('❌ Not connected');
      return false;
    }

    try {
      if (kDebugMode) print('🖨️ Printing text...');
      final bytes = _encodeText(content);
      return await writeBytes(bytes);
    } catch (e) {
      if (kDebugMode) print('❌ Print error: $e');
      return false;
    }
  }

  /// Print thermal receipt with ESC/POS protocol
  /// Implements proper initialization and byte stream mapping
  Future<bool> printThermalReceipt({required String content}) async {
    if (!_isConnected) {
      if (kDebugMode) print('❌ [Print] Not connected');
      return false;
    }

    try {
      if (kDebugMode) print('🖨️ [Print] Starting thermal print process...');

      // Ensure connection is still active
      if (kDebugMode) print('   Verifying connection...');
      final connected = await verifyConnection();
      if (!connected) {
        if (kDebugMode)
          print('   ⚠️ Connection lost, attempting to maintain...');
        final maintained = await maintainConnection();
        if (!maintained) {
          if (kDebugMode) print('❌ [Print] Could not maintain connection');
          return false;
        }
      }

      // Build complete ESC/POS byte stream
      List<int> bytes = [];

      // STEP 1: Initialize printer (ESC @ = 0x1B 0x40)
      if (kDebugMode) print('   📝 Adding ESC/POS initialization...');
      bytes.addAll(EscPosCommands.initialize);
      bytes.addAll(EscPosCommands.feedLines(1)); // Line feed after init

      // STEP 2: Format receipt content
      if (kDebugMode) print('   📝 Formatting receipt content...');
      final formatter = ThermalReceiptFormatter();
      formatter.reset();
      formatter.setAlignment(1); // Center alignment
      formatter.text(content);
      formatter.feedPaper(3); // Feed 3 lines at end

      // STEP 3: Combine init + formatted content
      bytes.addAll(formatter.bytes);

      if (kDebugMode) {
        print('   📊 Total bytes to send: ${bytes.length}');
        print(
          '      - Initialization: ${EscPosCommands.initialize.length} bytes',
        );
        print('      - Content: ${formatter.bytes.length} bytes');
      }

      // STEP 4: Send complete byte stream to printer
      // (writeBytes handles chunking automatically for large payloads)
      final success = await writeBytes(bytes);

      if (success) {
        if (kDebugMode)
          print('✅ [Print] Receipt printed successfully with ESC/POS protocol');
      } else {
        if (kDebugMode) print('❌ [Print] writeBytes returned false');
      }
      return success;
    } catch (e) {
      if (kDebugMode) print('❌ [Print] Receipt error: $e');
      return false;
    }
  }

  /// Feed paper using ESC/POS line feed command
  Future<void> feedPaper({int lines = 3}) async {
    if (!_isConnected) return;
    try {
      List<int> bytes = [];
      bytes.addAll(EscPosCommands.feedLines(lines));
      await writeBytes(bytes);
      if (kDebugMode) print('📄 Paper fed ($lines lines) via ESC/POS');
    } catch (e) {
      if (kDebugMode) print('❌ Feed error: $e');
    }
  }

  /// Test print
  Future<bool> testPrint() async {
    if (!_isConnected) {
      if (kDebugMode) print('❌ Not connected');
      return false;
    }

    try {
      String testContent =
          '''
═════════════════════════════════════
           TEST PRINT
═════════════════════════════════════
POS ARTHA SYSTEM

${DateTime.now()}

✅ KONEKSI BERHASIL!

═════════════════════════════════════
''';

      return await printThermalReceipt(content: testContent);
    } catch (e) {
      if (kDebugMode) print('❌ Test print error: $e');
      return false;
    }
  }

  /// Encode text
  List<int> _encodeText(String text) {
    final formatter = ThermalReceiptFormatter();
    formatter.text(text);
    return formatter.bytes;
  }

  /// Cleanup
  void dispose() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _connectionStateController.close();
    _devicesFoundController.close();
  }

  // ============================================================
  // NETWORK PRINTER METHODS
  // ============================================================

  /// Connect to network printer via IP address
  Future<bool> connectNetworkPrinter({
    required String ipAddress,
    required int port,
  }) async {
    try {
      if (kDebugMode)
        print('🌐 Connecting to network printer: $ipAddress:$port');

      // Disconnect previous connections
      if (_isConnected && _networkSocket != null) {
        try {
          await disconnectNetworkPrinter();
        } catch (e) {
          if (kDebugMode) print('⚠️ Disconnect prev: $e');
        }
      }

      _networkSocket = await Socket.connect(
        ipAddress,
        port,
        timeout: const Duration(seconds: 10),
      );

      _isConnected = true;
      _currentNetworkIp = ipAddress;
      _currentNetworkPort = port;
      _connectionStateController.add(true);

      if (kDebugMode) print('✅ Connected to network printer!');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Network connect error: $e');
      _isConnected = false;
      _connectionStateController.add(false);
      return false;
    }
  }

  /// Disconnect network printer
  Future<void> disconnectNetworkPrinter() async {
    try {
      if (kDebugMode) print('🌐 Disconnecting network printer...');
      await _networkSocket?.close();
      _networkSocket = null;
      _isConnected = false;
      _currentNetworkIp = null;
      _connectionStateController.add(false);
      if (kDebugMode) print('✅ Network printer disconnected');
    } catch (e) {
      if (kDebugMode) print('❌ Disconnect error: $e');
    }
  }

  /// Write bytes to network printer
  Future<bool> writeNetworkBytes(List<int> bytes) async {
    if (!_isConnected || _networkSocket == null) {
      if (kDebugMode) print('❌ Network printer not connected');
      return false;
    }

    try {
      if (kDebugMode) print('📤 Writing ${bytes.length} bytes to network...');
      _networkSocket!.add(bytes);
      await _networkSocket!.flush();
      if (kDebugMode) print('✅ Written to network printer');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Network write error: $e');
      _isConnected = false;
      _connectionStateController.add(false);
      return false;
    }
  }

  /// Test network printer connection
  Future<bool> testNetworkPrint(PaperSize paperSize) async {
    if (!_isConnected) {
      if (kDebugMode) print('❌ Network printer not connected');
      return false;
    }

    try {
      String testContent =
          '''
${'═' * 32}
       TEST PRINT
${'═' * 32}
POS ARTHA SYSTEM

${DateTime.now()}

Paper: ${paperSize.displayName}
IP: $_currentNetworkIp:$_currentNetworkPort

✅ KONEKSI BERHASIL!

${'═' * 32}
''';

      return await printNetworkThermalReceipt(
        content: testContent,
        paperSize: paperSize,
      );
    } catch (e) {
      if (kDebugMode) print('❌ Test print error: $e');
      return false;
    }
  }

  /// Print thermal receipt to network printer with ESC/POS protocol
  Future<bool> printNetworkThermalReceipt({
    required String content,
    required PaperSize paperSize,
  }) async {
    if (!_isConnected) {
      if (kDebugMode) print('❌ Network printer not connected');
      return false;
    }

    try {
      if (kDebugMode) print('🖨️ [Network] Printing with ESC/POS protocol...');

      // Build complete ESC/POS byte stream
      List<int> bytes = [];

      // Initialize printer
      bytes.addAll(EscPosCommands.initialize);
      bytes.addAll(EscPosCommands.feedLines(1));

      // Format content
      final formatter = ThermalReceiptFormatter(paperSize: paperSize);
      formatter.reset();
      formatter.setAlignment(1);
      formatter.text(content);
      formatter.feedPaper(3);

      // Combine
      bytes.addAll(formatter.bytes);

      if (kDebugMode) {
        print('   📊 Total bytes: ${bytes.length}');
      }

      return await writeNetworkBytes(bytes);
    } catch (e) {
      if (kDebugMode) print('❌ Network print error: $e');
      return false;
    }
  }

  // ============================================================
  // USB PRINTER METHODS (placeholder)
  // ============================================================

  /// Connect to USB printer
  Future<bool> connectUsbPrinter() async {
    try {
      if (kDebugMode) print('🔌 USB printer support coming soon');
      _isConnected = true;
      _connectionStateController.add(true);
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ USB error: $e');
      return false;
    }
  }

  /// Disconnect USB printer
  Future<void> disconnectUsbPrinter() async {
    try {
      _isConnected = false;
      _connectionStateController.add(false);
    } catch (e) {
      if (kDebugMode) print('❌ USB disconnect error: $e');
    }
  }

  /// Test USB printer
  Future<bool> testUsbPrint(PaperSize paperSize) async {
    try {
      String testContent =
          '''
${'═' * 32}
       TEST PRINT (USB)
${'═' * 32}
POS ARTHA SYSTEM

${DateTime.now()}

Paper: ${paperSize.displayName}

✅ KONEKSI BERHASIL!

${'═' * 32}
''';

      return await printUsbThermalReceipt(
        content: testContent,
        paperSize: paperSize,
      );
    } catch (e) {
      if (kDebugMode) print('❌ USB test error: $e');
      return false;
    }
  }

  /// Print to USB printer
  Future<bool> printUsbThermalReceipt({
    required String content,
    required PaperSize paperSize,
  }) async {
    try {
      final formatter = ThermalReceiptFormatter(paperSize: paperSize);
      formatter.reset();
      formatter.setAlignment(1);
      formatter.text(content);
      formatter.feedPaper(3);
      return true; // placeholder
    } catch (e) {
      if (kDebugMode) print('❌ USB print error: $e');
      return false;
    }
  }
}

/// ESC/POS Formatter
class ThermalReceiptFormatter {
  final List<int> _bytes = [];
  final PaperSize paperSize;

  List<int> get bytes => _bytes;

  ThermalReceiptFormatter({this.paperSize = PaperSize.mm58});

  void reset() {
    _addBytes([0x1B, 0x40]);
  }

  void setAlignment(int alignment) {
    _addBytes([0x1B, 0x61, alignment]);
  }

  void setSize(int width, int height) {
    _addBytes([0x1D, 0x21, (height << 4) | width]);
  }

  void setBold() {
    _addBytes([0x1B, 0x45, 1]);
  }

  void resetBold() {
    _addBytes([0x1B, 0x45, 0]);
  }

  void text(String text) {
    _addBytes(text.codeUnits);
    newLine();
  }

  void newLine() {
    _addBytes([0x0A]);
  }

  void feedPaper(int lines) {
    for (int i = 0; i < lines; i++) {
      newLine();
    }
  }

  void _addBytes(List<int> bytes) {
    _bytes.addAll(bytes);
  }
}
