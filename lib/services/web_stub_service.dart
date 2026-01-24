/// Web stub service - provides a dummy interface for web platform
class DatabaseService {


  static Future<void> initialize() async {
    print('⚠️ Web platform: database service stub loaded (no persistence)');
  }

  static dynamic get instance {
    throw UnsupportedError(
      'Database not available on web platform. '
      'Use a backend service (Firebase, REST API, etc.) for persistent storage.',
    );
  }

  static Future<void> dispose() async {
    // Cleanup for web stub
  }
}
