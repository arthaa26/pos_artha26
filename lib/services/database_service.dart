import 'package:flutter/foundation.dart';

// Deferred import - only loads the native database module when explicitly requested
import 'package:pos_artha26/database/database.dart' deferred as db_module;

class DatabaseService {
  static dynamic _instance;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) {
      if (kDebugMode) print('ℹ️ Database already initialized, skipping...');
      return;
    }
    if (kIsWeb) {
      if (kDebugMode) print('⚠️ Web platform detected - database not available');
      _initialized = true;
      return;
    }

    try {
      if (kDebugMode) print('📚 Loading database module...');
      // Load native database on native platforms
      await db_module.loadLibrary();
      if (kDebugMode) print('✅ Database module loaded');

      if (kDebugMode) print('🔧 Creating PosDatabase instance...');
      _instance = db_module.PosDatabase();
      if (kDebugMode) print('✅ PosDatabase instance created');

      // Ensure sample data exists
      if (kDebugMode) print('🔍 Checking database contents...');
      await _instance.ensureSampleData();

      _initialized = true;
      if (kDebugMode) print('✅ Database service fully initialized');
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Failed to initialize database: $e');
        print('Stack: $stackTrace');
      }
      rethrow;
    }
  }

  static dynamic get instance {
    if (!_initialized) {
      throw StateError(
        'DatabaseService not initialized. Call DatabaseService.initialize() first.',
      );
    }
    if (_instance == null) {
      throw UnsupportedError(
        'Database not available on web platform. Use a backend service instead.',
      );
    }
    return _instance;
  }

  static Future<void> dispose() async {
    if (_initialized && _instance != null) {
      try {
        if (kDebugMode) print('🔄 Closing database...');
        await _instance.close();
        if (kDebugMode) print('✅ Database closed');
      } catch (e) {
        if (kDebugMode) print('⚠️ Error closing database: $e');
      }
      _initialized = false;
      _instance = null;
    }
  }
}
