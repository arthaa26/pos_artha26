import 'package:flutter/material.dart';
import 'pengaturan_page.dart';

// Wrapper to keep backwards compatibility for routes/imports named SettingsPage
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const PengaturanPage();
}
