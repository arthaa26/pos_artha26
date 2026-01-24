import 'package:flutter/foundation.dart';

/// Mock printer service untuk testing di emulator
/// Real printer service bisa di-implement nanti
abstract class PrinterService {
  static final PrinterService _instance = _MockPrinterService();

  factory PrinterService() {
    return _instance;
  }

  /// Get singleton instance
  static PrinterService getInstance() {
    return _instance;
  }

  Future<bool> connect({required String printerAddress});
  Future<void> disconnect();
  Future<bool> printReceipt({required String content});
  Future<bool> printImage({required List<int> imageBytes});
  Future<void> feedPaper({int lines = 3});
  bool get isConnected;
}

/// Mock implementation untuk emulator/testing
class _MockPrinterService implements PrinterService {
  bool _connected = false;

  @override
  bool get isConnected => _connected;

  @override
  Future<bool> connect({required String printerAddress}) async {
    try {
      if (kDebugMode) print('🖨️ [MOCK] Connecting to printer: $printerAddress');
      await Future.delayed(const Duration(milliseconds: 500));
      _connected = true;
      if (kDebugMode) print('✅ [MOCK] Printer connected: $printerAddress');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ [MOCK] Failed to connect: $e');
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    if (kDebugMode) print('🔌 [MOCK] Disconnecting printer...');
    _connected = false;
    if (kDebugMode) print('✅ [MOCK] Printer disconnected');
  }

  @override
  Future<bool> printReceipt({required String content}) async {
    if (!_connected) {
      if (kDebugMode) print('❌ [MOCK] Printer not connected');
      return false;
    }

    try {
      if (kDebugMode) {
        print('🖨️ [MOCK] Printing receipt:');
        print('═' * 40);
        print(content);
        print('═' * 40);
      }
      await Future.delayed(const Duration(milliseconds: 800));
      if (kDebugMode) print('✅ [MOCK] Receipt printed successfully');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ [MOCK] Print error: $e');
      return false;
    }
  }

  @override
  Future<bool> printImage({required List<int> imageBytes}) async {
    if (!_connected) {
      if (kDebugMode) print('❌ [MOCK] Printer not connected');
      return false;
    }

    try {
      if (kDebugMode) {
        print('🖨️ [MOCK] Printing image (${imageBytes.length} bytes)');
      }
      await Future.delayed(const Duration(milliseconds: 500));
      if (kDebugMode) print('✅ [MOCK] Image printed successfully');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ [MOCK] Image print error: $e');
      return false;
    }
  }

  @override
  Future<void> feedPaper({int lines = 3}) async {
    if (!_connected) {
      if (kDebugMode) print('⚠️ [MOCK] Printer not connected, skipping feed');
      return;
    }

    try {
      if (kDebugMode) print('📄 [MOCK] Feeding paper ($lines lines)');
      await Future.delayed(const Duration(milliseconds: 300));
      if (kDebugMode) print('✅ [MOCK] Paper fed');
    } catch (e) {
      if (kDebugMode) print('❌ [MOCK] Feed error: $e');
    }
  }
}

/// Real printer service (untuk production)
class EscPosPrinterService implements PrinterService {

  bool _connected = false;

  @override
  bool get isConnected => _connected;

  @override
  Future<bool> connect({required String printerAddress}) async {
    try {
      if (kDebugMode) print('🖨️ Connecting to printer: $printerAddress');
      // Implementation untuk real printer akan di-add nanti
      _connected = true;
      if (kDebugMode) print('✅ Printer connected');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Connection failed: $e');
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
    if (kDebugMode) print('🔌 Printer disconnected');
  }

  @override
  Future<bool> printReceipt({required String content}) async {
    if (!_connected) return false;
    // Real implementation
    if (kDebugMode) print('🖨️ Printing: $content');
    return true;
  }

  @override
  Future<bool> printImage({required List<int> imageBytes}) async {
    if (!_connected) return false;
    // Real implementation
    if (kDebugMode) print('🖨️ Printing image (${imageBytes.length} bytes)');
    return true;
  }

  @override
  Future<void> feedPaper({int lines = 3}) async {
    if (!_connected) return;
    // Real implementation
    if (kDebugMode) print('📄 Feeding paper ($lines lines)');
  }
}
