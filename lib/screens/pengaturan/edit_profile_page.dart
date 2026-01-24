import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/pos_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ppnController = TextEditingController();
  final TextEditingController _hppController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedLogo;

  @override
  void initState() {
    super.initState();
    final settings = context.read<PosProvider>().settings;
    _nameController.text = settings.storeName;
    _addressController.text = settings.storeAddress;
    _phoneController.text = settings.storePhone;
    _ppnController.text = (settings.ppnRate * 100).toStringAsFixed(1);
    _hppController.text = (settings.hppMargin * 100).toStringAsFixed(1);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _ppnController.dispose();
    _hppController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _pickedLogo = picked);
  }

  void _save() {
    final provider = context.read<PosProvider>();
    final ppnValue = double.tryParse(_ppnController.text) ?? 10;
    final hppValue = double.tryParse(_hppController.text) ?? 0;

    final newSettings = provider.settings.copyWith(
      storeName: _nameController.text,
      storeAddress: _addressController.text,
      storePhone: _phoneController.text,
      storeLogoPath: _pickedLogo?.path ?? provider.settings.storeLogoPath,
      ppnRate: ppnValue / 100,
      hppMargin: hppValue / 100,
    );
    provider.updateSettings(newSettings);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profil toko disimpan')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<PosProvider>().settings;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil Toko'),
        backgroundColor: Colors.grey[300],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Logo Toko',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _pickedLogo != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(
                            File(_pickedLogo!.path),
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
                      : const Icon(Icons.store, size: 44, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _pickLogo,
                  child: const Text('Ganti Logo'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Toko',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Alamat Toko',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'No. Telepon Toko',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Pengaturan Transaksi',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ppnController,
                    decoration: const InputDecoration(
                      labelText: 'PPN (%)',
                      border: OutlineInputBorder(),
                      suffix: Text('%'),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _hppController,
                    decoration: const InputDecoration(
                      labelText: 'HPP/Margin (%)',
                      border: OutlineInputBorder(),
                      suffix: Text('%'),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Simpan Profil'),
            ),
          ],
        ),
      ),
    );
  }
}
