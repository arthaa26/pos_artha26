import 'package:flutter/foundation.dart';
import 'package:pos_artha26/models/thermal_receipt.dart';
import 'bluetooth_printer_service.dart';

/// Unified print manager service - handles all print operations
/// Supports both Bluetooth thermal and network printing
class PrintManagerService {
  static final PrintManagerService _instance = PrintManagerService._internal();

  final BluetoothPrinterService _bluetoothPrinter = BluetoothPrinterService();

  PrintManagerService._internal();

  factory PrintManagerService() {
    return _instance;
  }

  static PrintManagerService get instance => _instance;

  /// Print thermal receipt from transaction
  /// Automatically detects printer type and format (58mm or 80mm)
  Future<bool> printThermalReceipt({
    required ThermalReceipt receipt,
    bool is58mm = true,
    String? printerType,
  }) async {
    if (kDebugMode) {
      print(
        '🖨️ [PrintManager] Starting print: is58mm=$is58mm, type=$printerType',
      );
    }

    try {
      // Generate ESC/POS bytes for thermal printer
      final bytes = receipt.toEscPosBytes(is58mm: is58mm);

      if (kDebugMode) {
        print('📄 [PrintManager] Receipt formatted: ${bytes.length} bytes');
        print('📋 [PrintManager] Receipt preview:');
        print(receipt.toThermalText(is58mm: is58mm));
      }

      // Send to Bluetooth printer
      final success = await _bluetoothPrinter.printThermalReceipt(
        content: receipt.toThermalText(is58mm: is58mm),
      );

      if (success) {
        if (kDebugMode) print('✅ [PrintManager] Print SUCCESS');
        return true;
      } else {
        if (kDebugMode) print('❌ [PrintManager] Print FAILED');
        return false;
      }
    } catch (e) {
      if (kDebugMode) print('❌ [PrintManager] Print error: $e');
      return false;
    }
  }

  /// Check if printer is ready
  bool isPrinterReady() {
    return _bluetoothPrinter.isConnected;
  }

  /// Get printer connection status
  String getPrinterStatus() {
    if (_bluetoothPrinter.isConnected) {
      return 'Connected: ${_bluetoothPrinter.connectedDeviceName}';
    }
    return 'Not Connected';
  }

  /// Get printer stream for UI updates
  Stream<bool> get printerConnectionStream =>
      _bluetoothPrinter.connectionStateStream;
}
