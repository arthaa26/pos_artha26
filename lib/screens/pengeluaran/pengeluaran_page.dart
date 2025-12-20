import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/transaksi.dart';
import '../../providers/pos_provider.dart';

class PengeluaranPage extends StatefulWidget {
  const PengeluaranPage({super.key});

  @override
  State<PengeluaranPage> createState() => _PengeluaranPageState();
}

class _PengeluaranPageState extends State<PengeluaranPage> {
  final _formKey = GlobalKey<FormState>();
  final _pengeluaranController = TextEditingController();
  final _deskripsiController = TextEditingController();
  String? _selectedKategori;

  final List<String> _kategoriOptions = ['Makanan', 'Minuman', 'Cemilan'];

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final recent = context
        .watch<PosProvider>()
        .transaksi
        .where((t) => t.pengeluaran > 0)
        .toList()
        .reversed
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengeluaran'),
        backgroundColor: Colors.grey[300],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tambah Pengeluaran',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _pengeluaranController,
                        decoration: InputDecoration(
                          labelText: 'Jumlah Pengeluaran',
                          prefixText: 'Rp ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Jumlah harus diisi'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _deskripsiController,
                        decoration: InputDecoration(
                          labelText: 'Deskripsi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Deskripsi harus diisi'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedKategori,
                        decoration: InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: _kategoriOptions
                            .map(
                              (kategori) => DropdownMenuItem(
                                value: kategori,
                                child: Text(kategori),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedKategori = value),
                        validator: (value) =>
                            value == null ? 'Kategori harus dipilih' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _submit,
                              icon: const Icon(Icons.save),
                              label: const Text('Simpan Pengeluaran'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: _clearForm,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Bersihkan'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Riwayat Pengeluaran Terakhir',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (recent.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline),
                      SizedBox(width: 8),
                      Expanded(child: Text('Belum ada pengeluaran')),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recent.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final t = recent[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red[100],
                        child: const Icon(
                          Icons.arrow_upward,
                          color: Colors.red,
                        ),
                      ),
                      title: Text(
                        t.deskripsi,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        DateFormat('dd MMM yyyy – HH:mm').format(t.tanggal),
                      ),
                      trailing: Text(
                        currency.format(t.pengeluaran),
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final transaksi = Transaksi(
        pendapatan: 0,
        keuntungan: 0,
        pengeluaran: double.parse(_pengeluaranController.text),
        deskripsi: _deskripsiController.text,
        kategori: _selectedKategori,
        tanggal: DateTime.now(),
      );
      context.read<PosProvider>().addTransaksi(transaksi);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pengeluaran ditambahkan')));
      _clearForm();
    }
  }

  void _clearForm() {
    _pengeluaranController.clear();
    _deskripsiController.clear();
    setState(() => _selectedKategori = null);
  }

  @override
  void dispose() {
    _pengeluaranController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }
}
