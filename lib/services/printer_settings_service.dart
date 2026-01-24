import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/printer_config.dart';

/// Service untuk manage printer configuration
class PrinterSettingsService {
  static final PrinterSettingsService _instance =
      PrinterSettingsService._internal();
  static const String _key = 'printer_configs';
  static const String _defaultKey = 'default_printer_id';

  late SharedPreferences _prefs;
  List<PrinterConfig> _configs = [];
  String? _defaultPrinterId;

  factory PrinterSettingsService() {
    return _instance;
  }

  PrinterSettingsService._internal();

  /// Initialize service (call this on app startup)
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadConfigs();
      if (kDebugMode) print('✅ PrinterSettingsService initialized');
    } catch (e) {
      if (kDebugMode) print('❌ Init error: $e');
    }
  }

  /// Load all configs from storage
  void _loadConfigs() {
    try {
      final jsonString = _prefs.getString(_key);
      if (jsonString != null && jsonString.isNotEmpty) {
        final jsonList = jsonDecode(jsonString) as List;
        _configs = jsonList
            .map((item) => PrinterConfig.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      _defaultPrinterId = _prefs.getString(_defaultKey);
      if (kDebugMode) print('📋 Loaded ${_configs.length} printer configs');
    } catch (e) {
      if (kDebugMode) print('❌ Load error: $e');
      _configs = [];
    }
  }

  /// Save all configs to storage
  Future<void> _saveConfigs() async {
    try {
      final jsonList = _configs.map((c) => c.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _prefs.setString(_key, jsonString);
      if (kDebugMode) print('✅ Saved ${_configs.length} printer configs');
    } catch (e) {
      if (kDebugMode) print('❌ Save error: $e');
    }
  }

  /// Add new printer config
  Future<void> addPrinter(PrinterConfig config) async {
    try {
      _configs.add(config);
      if (config.isDefault) {
        _defaultPrinterId = config.id;
        await _prefs.setString(_defaultKey, config.id);
      }
      await _saveConfigs();
      if (kDebugMode) print('✅ Added printer: ${config.name}');
    } catch (e) {
      if (kDebugMode) print('❌ Add error: $e');
    }
  }

  /// Update printer config
  Future<void> updatePrinter(PrinterConfig config) async {
    try {
      final index = _configs.indexWhere((c) => c.id == config.id);
      if (index != -1) {
        _configs[index] = config;
        if (config.isDefault) {
          _defaultPrinterId = config.id;
          await _prefs.setString(_defaultKey, config.id);
        }
        await _saveConfigs();
        if (kDebugMode) print('✅ Updated printer: ${config.name}');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Update error: $e');
    }
  }

  /// Delete printer config
  Future<void> deletePrinter(String printerId) async {
    try {
      _configs.removeWhere((c) => c.id == printerId);
      if (_defaultPrinterId == printerId) {
        _defaultPrinterId = null;
        await _prefs.remove(_defaultKey);
      }
      await _saveConfigs();
      if (kDebugMode) print('✅ Deleted printer: $printerId');
    } catch (e) {
      if (kDebugMode) print('❌ Delete error: $e');
    }
  }

  /// Get all printers
  List<PrinterConfig> getAllPrinters() => List.from(_configs);

  /// Get printer by ID
  PrinterConfig? getPrinterById(String id) {
    try {
      return _configs.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get default printer
  PrinterConfig? getDefaultPrinter() {
    if (_defaultPrinterId != null) {
      return getPrinterById(_defaultPrinterId!);
    }
    return _configs.isNotEmpty ? _configs.first : null;
  }

  /// Set default printer
  Future<void> setDefaultPrinter(String printerId) async {
    try {
      _defaultPrinterId = printerId;
      await _prefs.setString(_defaultKey, printerId);
      // Update all configs
      _configs = _configs.map((c) {
        return c.copyWith(isDefault: c.id == printerId);
      }).toList();
      await _saveConfigs();
      if (kDebugMode) print('✅ Set default printer: $printerId');
    } catch (e) {
      if (kDebugMode) print('❌ Set default error: $e');
    }
  }

  /// Get printers by type
  List<PrinterConfig> getPrintersByType(PrinterType type) {
    return _configs.where((c) => c.type == type).toList();
  }

  /// Update last used time
  Future<void> updateLastUsed(String printerId) async {
    try {
      final config = getPrinterById(printerId);
      if (config != null) {
        await updatePrinter(config.copyWith(lastUsed: DateTime.now()));
      }
    } catch (e) {
      if (kDebugMode) print('❌ Update last used error: $e');
    }
  }

  /// Clear all printers
  Future<void> clearAll() async {
    try {
      _configs.clear();
      _defaultPrinterId = null;
      await _prefs.remove(_key);
      await _prefs.remove(_defaultKey);
      if (kDebugMode) print('✅ Cleared all printer configs');
    } catch (e) {
      if (kDebugMode) print('❌ Clear error: $e');
    }
  }

  /// Get printer count
  int get printerCount => _configs.length;

  /// Check if has printers
  bool get hasPrinters => _configs.isNotEmpty;
}
