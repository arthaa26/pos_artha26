import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/settings.dart';
import '../../providers/pos_provider.dart';

class KeamananPage extends StatefulWidget {
  const KeamananPage({super.key});

  @override
  State<KeamananPage> createState() => _KeamananPageState();
}

class _KeamananPageState extends State<KeamananPage> {
  final TextEditingController _pinController = TextEditingController();
  bool _showPinDialog = true;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _verifyPin() {
    final pin = _pinController.text;
    if (context.read<PosProvider>().verifyPin(pin)) {
      setState(() {
        _showPinDialog = false;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('PIN salah!')));
    }
  }

  Widget _buildSwitch(String label, String property) {
    return Consumer<PosProvider>(
      builder: (context, provider, child) {
        bool value = _getSettingValue(provider.settings, property);
        return SwitchListTile(
          title: Text(label),
          value: value,
          onChanged: (newValue) {
            _updateSetting(property, newValue);
          },
        );
      },
    );
  }

  bool _getSettingValue(AppSettings settings, String property) {
    switch (property) {
      case 'requirePinForProducts':
        return settings.requirePinForProducts;
      case 'requirePinForCategories':
        return settings.requirePinForCategories;
      case 'requirePinForExpenses':
        return settings.requirePinForExpenses;
      case 'requirePinForTransactions':
        return settings.requirePinForTransactions;
      case 'showProducts':
        return settings.showProducts;
      case 'showCategories':
        return settings.showCategories;
      case 'showExpenses':
        return settings.showExpenses;
      case 'showTransactions':
        return settings.showTransactions;
      case 'showReports':
        return settings.showReports;
      case 'showHistory':
        return settings.showHistory;
      case 'showCashier':
        return settings.showCashier;
      default:
        return false;
    }
  }

  void _updateSetting(String property, bool value) {
    final provider = context.read<PosProvider>();
    final settings = provider.settings;
    AppSettings newSettings;

    switch (property) {
      case 'requirePinForProducts':
        newSettings = settings.copyWith(requirePinForProducts: value);
        break;
      case 'requirePinForCategories':
        newSettings = settings.copyWith(requirePinForCategories: value);
        break;
      case 'requirePinForExpenses':
        newSettings = settings.copyWith(requirePinForExpenses: value);
        break;
      case 'requirePinForTransactions':
        newSettings = settings.copyWith(requirePinForTransactions: value);
        break;
      case 'showProducts':
        newSettings = settings.copyWith(showProducts: value);
        break;
      case 'showCategories':
        newSettings = settings.copyWith(showCategories: value);
        break;
      case 'showExpenses':
        newSettings = settings.copyWith(showExpenses: value);
        break;
      case 'showTransactions':
        newSettings = settings.copyWith(showTransactions: value);
        break;
      case 'showReports':
        newSettings = settings.copyWith(showReports: value);
        break;
      case 'showHistory':
        newSettings = settings.copyWith(showHistory: value);
        break;
      case 'showCashier':
        newSettings = settings.copyWith(showCashier: value);
        break;
      default:
        return;
    }

    provider.updateSettings(newSettings);
  }

  Widget _buildHideAllSwitch() {
    return Consumer<PosProvider>(
      builder: (context, provider, child) {
        final settings = provider.settings;
        final allHidden =
            !(settings.showProducts ||
                settings.showCategories ||
                settings.showExpenses ||
                settings.showTransactions ||
                settings.showReports ||
                settings.showHistory ||
                settings.showCashier);
        return SwitchListTile(
          title: const Text('Hide Semua Fitur'),
          value: allHidden,
          onChanged: (v) {
            final provider = context.read<PosProvider>();
            final s = provider.settings.copyWith(
              showProducts: !v,
              showCategories: !v,
              showExpenses: !v,
              showTransactions: !v,
              showReports: !v,
              showHistory: !v,
              showCashier: !v,
            );
            provider.updateSettings(s);
          },
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showPinDialog) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Keamanan'),
          backgroundColor: Colors.grey[300],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Masukkan PIN untuk akses keamanan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24),
                  decoration: const InputDecoration(
                    hintText: 'Masukkan PIN',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _verifyPin,
                  child: const Text('Masuk'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keamanan'),
        backgroundColor: Colors.grey[300],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Keamanan PIN', [
              _buildSwitch('Produk', 'requirePinForProducts'),
              _buildSwitch('Kategori', 'requirePinForCategories'),
              _buildSwitch('Pengeluaran', 'requirePinForExpenses'),
              _buildSwitch('Transaksi', 'requirePinForTransactions'),
            ]),
            _buildSection('Visibilitas Fitur', [
              _buildHideAllSwitch(),
              _buildSwitch('Tampilkan Produk', 'showProducts'),
              _buildSwitch('Tampilkan Kategori', 'showCategories'),
              _buildSwitch('Tampilkan Pengeluaran', 'showExpenses'),
              _buildSwitch('Tampilkan Transaksi', 'showTransactions'),
              _buildSwitch('Tampilkan Laporan', 'showReports'),
              _buildSwitch('Tampilkan Riwayat', 'showHistory'),
              _buildSwitch('Tampilkan Kasir', 'showCashier'),
            ]),
          ],
        ),
      ),
    );
  }
}
