import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Utility untuk handle file operations dan permissions di real device
class FilePermissionService {
  static final FilePermissionService _instance = FilePermissionService._internal();

  factory FilePermissionService() {
    return _instance;
  }

  FilePermissionService._internal();

  /// Check dan request storage permissions
  Future<bool> requestStoragePermissions() async {
    if (kIsWeb) return true;
    
    try {
      // Android 13+ uses scoped storage, no need for WRITE permission
      // Just request READ for accessing documents
      final status = await Permission.storage.request();
      
      if (status.isDenied) {
        debugPrint('⚠️ Storage permission denied');
        return false;
      }
      
      if (status.isPermanentlyDenied) {
        debugPrint('❌ Storage permission permanently denied, open app settings');
        return false;
      }
      
      debugPrint('✅ Storage permission granted');
      return true;
    } catch (e) {
      debugPrint('❌ Error requesting permissions: $e');
      return false;
    }
  }

  /// Get app documents directory safely
  Future<Directory?> getAppDocumentsDirectory() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      debugPrint('📁 App directory: ${dir.path}');
      return dir;
    } catch (e) {
      debugPrint('❌ Error getting app directory: $e');
      return null;
    }
  }

  /// Get app downloads directory safely
  Future<Directory?> getDownloadsDirectory() async {
    try {
      final dir = await getDownloadsDirectory();
      if (dir == null) {
        debugPrint('⚠️ Downloads directory not available');
        return null;
      }
      
      // Ensure directory exists
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      
      debugPrint('📁 Downloads directory: ${dir.path}');
      return dir;
    } catch (e) {
      debugPrint('❌ Error getting downloads directory: $e');
      return null;
    }
  }

  /// Copy file safely with error handling
  Future<String?> copyFileSafely(String sourcePath, String targetPath) async {
    try {
      if (sourcePath.isEmpty) {
        debugPrint('⚠️ Source path is empty');
        return null;
      }

      final sourceFile = File(sourcePath);
      
      // Check if source exists
      if (!await sourceFile.exists()) {
        debugPrint('❌ Source file not found: $sourcePath');
        return null;
      }

      // Check if target directory exists
      final targetDir = File(targetPath).parent;
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
        debugPrint('✅ Created target directory: ${targetDir.path}');
      }

      // Copy file
      final savedFile = await sourceFile.copy(targetPath);
      debugPrint('✅ File copied to: ${savedFile.path}');
      return savedFile.path;
    } catch (e) {
      debugPrint('❌ Error copying file: $e');
      return null;
    }
  }

  /// Save bytes to file safely
  Future<String?> saveBytesToFile(List<int> bytes, String fileName) async {
    try {
      final appDir = await getAppDocumentsDirectory();
      if (appDir == null) {
        debugPrint('❌ Cannot get app directory');
        return null;
      }

      final filePath = '${appDir.path}/$fileName';
      final file = File(filePath);
      
      await file.writeAsBytes(bytes);
      debugPrint('✅ File saved: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('❌ Error saving file: $e');
      return null;
    }
  }

  /// Check if file exists
  Future<bool> fileExists(String filePath) async {
    try {
      return await File(filePath).exists();
    } catch (e) {
      debugPrint('❌ Error checking file: $e');
      return false;
    }
  }

  /// Delete file safely
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('✅ File deleted: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error deleting file: $e');
      return false;
    }
  }
}
