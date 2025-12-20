import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../providers/pos_provider.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _profitMarginController = TextEditingController();
  final TextEditingController _ppnController = TextEditingController();
  final TextEditingController _storeNameController = TextEditingController();

  final TextEditingController _oldPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _logoFile;

  bool _showPinDialog = true;

  @override
  void initState() {
    super.initState();
    final settings = context.read<PosProvider>().settings;
    _profitMarginController.text = (settings.profitMargin * 100).toString();
    _ppnController.text = (settings.ppnRate * 100).toString();
    _storeNameController.text = settings.storeName;
  }

  @override
  void dispose() {
    _pinController.dispose();
    _profitMarginController.dispose();
    _ppnController.dispose();
    _storeNameController.dispose();
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _changePin() {
    final oldPin = _oldPinController.text;
    final newPin = _newPinController.text;
    final confirm = _confirmPinController.text;
    final provider = context.read<PosProvider>();
    if (!provider.verifyPin(oldPin)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('PIN lama salah')));
      return;
    }
    if (newPin.length < 4 || newPin != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi PIN tidak cocok atau terlalu pendek'),
        ),
      );
      return;
    }
    final settings = provider.settings.copyWith(pinCode: newPin);
    provider.updateSettings(settings);
    _oldPinController.clear();
    _newPinController.clear();
    _confirmPinController.clear();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('PIN berhasil diubah')));
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

  void _saveSettings() {
    final settings = context.read<PosProvider>().settings;
    final newSettings = settings.copyWith(
      storeName: _storeNameController.text.isNotEmpty
          ? _storeNameController.text
          : settings.storeName,
      profitMargin: double.tryParse(_profitMarginController.text) ?? 20.0 / 100,
      ppnRate: double.tryParse(_ppnController.text) ?? 10.0 / 100,
      storeLogoPath: _logoFile?.path ?? settings.storeLogoPath,
    );
    context.read<PosProvider>().updateSettings(newSettings);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Pengaturan disimpan!')));
  }

  Future<void> _pickLogo() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _logoFile = picked;
      });
    }
  }

  Widget _buildLogoSelector() {
    final settings = context.watch<PosProvider>().settings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _logoFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(
                        File(_logoFile!.path),
                        fit: BoxFit.cover,
                      ),
                    )
                  : settings.storeLogoPath.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(
                        File(settings.storeLogoPath),
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.store, size: 40, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _pickLogo,
              child: const Text('Pilih Logo'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showPinDialog) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pengaturan'),
          backgroundColor: Colors.grey[300],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Masukkan PIN untuk akses pengaturan',
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
        title: const Text('Pengaturan'),
        backgroundColor: Colors.grey[300],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Informasi Toko', [
              _buildTextField('Nama Toko', _storeNameController),
              const SizedBox(height: 16),
              _buildLogoSelector(),
            ]),
            _buildSection('Keuntungan & Pajak', [
              _buildTextField(
                'Margin Keuntungan (%)',
                _profitMarginController,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                'PPN (%)',
                _ppnController,
                keyboardType: TextInputType.number,
              ),
            ]),
            _buildSection('Ganti PIN', [
              _buildTextField(
                'PIN Lama',
                _oldPinController,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                'PIN Baru',
                _newPinController,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                'Konfirmasi PIN Baru',
                _confirmPinController,
                keyboardType: TextInputType.number,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: _changePin,
                  child: const Text('Ubah PIN'),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                child: const Text('Simpan Pengaturan'),
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
