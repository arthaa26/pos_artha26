import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getBaseUrl() async {
  try {
    if (Platform.isAndroid) {
      // Try to get saved IP address first
      final prefs = await SharedPreferences.getInstance();
      final savedIp = prefs.getString('server_ip');
      if (savedIp != null && savedIp.isNotEmpty) {
        return 'http://$savedIp:3000';
      }

      // For Android emulator, use 10.0.2.2 to access host PC
      return 'http://10.0.2.2:3000';
    }
  } catch (_) {}
  return 'http://localhost:3000';
}

// Function to save server IP
Future<void> saveServerIp(String ip) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('server_ip', ip);
}
