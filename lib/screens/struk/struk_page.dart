import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../providers/pos_provider.dart';
import '../../widgets/receipt_preview_widget.dart';

class StrukPage extends StatefulWidget {
  const StrukPage({super.key});

  @override
  State<StrukPage> createState() => _StrukPageState();
}

class _StrukPageState extends State<StrukPage> {
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _storeAddressController = TextEditingController();
  final TextEditingController _thankYouMessageController =
      TextEditingController();
  final TextEditingController _operatingHoursController =
      TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _logoFile;

  @override
  void initState() {
    super.initState();
    final provider = context.read<PosProvider>();
    _storeNameController.text = provider.settings.storeName;
    _storeAddressController.text = provider.settings.storeAddress;
    _thankYouMessageController.text = provider.settings.receiptFooter.isNotEmpty
        ? provider.settings.receiptFooter
        : 'Terima Kasih';
    _operatingHoursController.text = provider.settings.receiptHeader.isNotEmpty
        ? provider.settings.receiptHeader
        : 'Senin - Minggu: 08:00 - 20:00';
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeAddressController.dispose();
    _thankYouMessageController.dispose();
    _operatingHoursController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _logoFile = pickedFile;
      });
    }
  }

  void _saveSettings() {
    final provider = context.read<PosProvider>();
    final newSettings = provider.settings.copyWith(
      storeName: _storeNameController.text,
      storeAddress: _storeAddressController.text,
      receiptHeader: _operatingHoursController.text,
      receiptFooter: _thankYouMessageController.text,
      storeLogoPath: _logoFile?.path ?? provider.settings.storeLogoPath,
    );
    provider.updateSettings(newSettings);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Pengaturan struk disimpan')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Struk'),
        backgroundColor: Colors.grey[300],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pengaturan Struk',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildLogoSection(),
            const SizedBox(height: 20),
            _buildTextField('Nama Toko', _storeNameController),
            const SizedBox(height: 16),
            _buildTextField('Alamat Toko', _storeAddressController),
            const SizedBox(height: 16),
            _buildTextField('Ucapan Terima Kasih', _thankYouMessageController),
            const SizedBox(height: 16),
            _buildTextField('Jam Operasional', _operatingHoursController),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Simpan Pengaturan',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Preview Struk',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildReceiptPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Logo Toko',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
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
                  ? Image.file(File(_logoFile!.path), fit: BoxFit.cover)
                  : context
                        .watch<PosProvider>()
                        .settings
                        .storeLogoPath
                        .isNotEmpty
                  ? Image.file(
                      File(context.watch<PosProvider>().settings.storeLogoPath),
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image, size: 40, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _pickLogo,
              child: const Text('Pilih Logo'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildReceiptPreview() {
    final provider = context.watch<PosProvider>();
    final settings = provider.settings;

    // Sample items for preview
    final sampleItems = [
      {
        'nama': 'Kopi',
        'jumlah': 1,
        'hargaSatuan': 25000.0,
        'subtotal': 25000.0,
      },
    ];

    return ReceiptPreviewWidget(
      storeName: _storeNameController.text.isNotEmpty
          ? _storeNameController.text
          : 'Nama Toko',
      storeAddress: _storeAddressController.text.isNotEmpty
          ? _storeAddressController.text
          : 'Alamat Toko',
      storePhone: provider.settings.storePhone,
      storeLogoPath: _logoFile?.path ?? provider.settings.storeLogoPath,
      items: sampleItems,
      subtotal: 25000.0,
      ppnRate: settings.ppnRate,
      cashGiven: 30000.0,
      change: 2500.0,
      transactionNumber: 'TRX001',
      transactionTime: DateTime.now(),
      thankYouMessage: _thankYouMessageController.text.isNotEmpty
          ? _thankYouMessageController.text
          : 'Terima Kasih',
      operatingHours: _operatingHoursController.text.isNotEmpty
          ? _operatingHoursController.text
          : 'Senin - Minggu: 08:00 - 20:00',
    );
  }
}
