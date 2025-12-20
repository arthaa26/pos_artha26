import 'dart:io';

String getBaseUrl() {
  try {
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
  } catch (_) {}
  return 'http://localhost:3000';
}
