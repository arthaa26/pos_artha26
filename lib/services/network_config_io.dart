import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getBaseUrl() async {
  try {
    if (Platform.isAndroid) {
      // Try to get saved IP address first
      final prefs = await SharedPreferences.getInstance();
      final savedIp = prefs.getString('server_ip');
      if (savedIp != null && savedIp.isNotEmpty) {
        print('Using saved server IP: $savedIp');
        return 'http://$savedIp:3000';
      }

      // Try multiple addresses for Android emulator/device
      // Primary: 10.0.2.2 (standard Android emulator gateway to host)
      // Fallback: 192.168.1.12 (local network IP)
      return 'http://10.0.2.2:3000';
    }
  } catch (e) {
    print('Error in getBaseUrl: $e');
  }

  // Fallback for iOS, Web, or physical devices with local server
  return 'http://localhost:3000';
}

// Function to set custom server IP for debugging/setup
Future<void> setServerIp(String ip) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('server_ip', ip);
  print('✅ Saved server IP: $ip');
}

// Clear saved server IP and use default
Future<void> clearServerIp() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('server_ip');
  print('✅ Cleared saved server IP, using default');
}

// Get current server IP for display
Future<String> getCurrentServerIp() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('server_ip');
    if (saved != null && saved.isNotEmpty) {
      return saved;
    }
  } catch (e) {
    print('Error getting current server IP: $e');
  }

  if (Platform.isAndroid) {
    return '10.0.2.2:3000';
  }
  return 'localhost:3000';
}
