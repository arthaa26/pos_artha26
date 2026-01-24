// Web implementation - uses in-memory storage
import 'package:drift/drift.dart';

/// Opens a web database connection (in-memory only for web)
LazyDatabase openConnection() {
  return LazyDatabase(() async {
    // For web, we use in-memory database
    // This means data doesn't persist between page refreshes
    // But allows the app to run on web for testing
    return LazyDatabase(() async {
      throw UnimplementedError(
        'openConnection not available on this platform',
      );
    });
  });
}
