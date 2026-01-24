import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/pos_provider.dart';
import '../../database/database.dart' as drift_db;

class PengeluaranPage extends StatefulWidget {
  const PengeluaranPage({super.key});

  @override
  State<PengeluaranPage> createState() => _PengeluaranPageState();
}

class _PengeluaranPageState extends State<PengeluaranPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _kategoriController;
  late TextEditingController _jumlahController;
  late TextEditingController _catatanController;
  DateTime _selectedDate = DateTime.now();
  drift_db.Pengeluaran? _editingItem;
  bool _isLoading = false;

  final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
  final _dateFormat = DateFormat('dd/MM/yyyy', 'id_ID');

  @override
  void initState() {
    super.initState();
    _kategoriController = TextEditingController();
    _jumlahController = TextEditingController();
    _catatanController = TextEditingController();
    _loadPengeluaran();
  }

  void _loadPengeluaran() {
    // Data dimuat dari PosProvider
  }

  @override
  void dispose() {
    _kategoriController.dispose();
    _jumlahController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _kategoriController.clear();
    _jumlahController.clear();
    _catatanController.clear();
    _selectedDate = DateTime.now();
    _editingItem = null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _savePengeluaran() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final jumlah = double.parse(_jumlahController.text);
      final provider = Provider.of<PosProvider>(context, listen: false);

      if (_editingItem == null) {
        // Create new
        await provider.addPengeluaran(
          kategori: _kategoriController.text,
          jumlah: jumlah,
          tanggal: _selectedDate,
          catatan: _catatanController.text.isEmpty ? null : _catatanController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pengeluaran berhasil ditambahkan')),
          );
        }
      } else {
        // Update existing
        await provider.updatePengeluaran(
          id: _editingItem!.id,
          kategori: _kategoriController.text,
          jumlah: jumlah,
          tanggal: _selectedDate,
          catatan: _catatanController.text.isEmpty ? null : _catatanController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pengeluaran berhasil diubah')),
          );
        }
      }

      if (mounted) {
        _resetForm();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePengeluaran(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Yakin ingin menghapus pengeluaran ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final provider = Provider.of<PosProvider>(context, listen: false);
        await provider.deletePengeluaran(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pengeluaran berhasil dihapus')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _showFormDialog({drift_db.Pengeluaran? pengeluaran}) {
    _resetForm();
    if (pengeluaran != null) {
      _editingItem = pengeluaran;
      _kategoriController.text = pengeluaran.kategori;
      _jumlahController.text = pengeluaran.jumlah.toString();
      _catatanController.text = pengeluaran.catatan ?? '';
      _selectedDate = pengeluaran.tanggal;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pengeluaran == null ? 'Tambah Pengeluaran' : 'Edit Pengeluaran',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kategoriController,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  hintText: 'e.g., Sewa, Gaji, Utilitas',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Kategori tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _jumlahController,
                decoration: InputDecoration(
                  labelText: 'Jumlah',
                  hintText: '0',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Jumlah tidak boleh kosong';
                  if (double.tryParse(value!) == null) return 'Jumlah harus berupa angka';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tanggal: ${_dateFormat.format(_selectedDate)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _selectDate(context),
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Ubah'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _catatanController,
                decoration: InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  hintText: 'Deskripsi pengeluaran',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _savePengeluaran,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengeluaran'),
        backgroundColor: Colors.teal,
      ),
      body: Consumer<PosProvider>(
        builder: (context, provider, _) {
          final pengeluaran = provider.pengeluaran;

          if (pengeluaran.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada pengeluaran',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final totalPengeluaran = pengeluaran.fold<double>(
            0,
            (sum, p) => sum + p.jumlah,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Pengeluaran',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currencyFormat.format(totalPengeluaran),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pengeluaran.length,
                itemBuilder: (context, index) {
                  final item = pengeluaran[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red.withOpacity(0.2),
                        child: Icon(
                          _getIconForKategori(item.kategori),
                          color: Colors.red,
                        ),
                      ),
                      title: Text(item.kategori),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            _dateFormat.format(item.tanggal),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          if (item.catatan != null && item.catatan!.isNotEmpty)
                            Text(
                              item.catatan!,
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currencyFormat.format(item.jumlah),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                iconSize: 18,
                                onPressed: () => _showFormDialog(pengeluaran: item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                iconSize: 18,
                                color: Colors.red,
                                onPressed: () => _deletePengeluaran(item.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        tooltip: 'Tambah Pengeluaran',
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getIconForKategori(String kategori) {
    final lower = kategori.toLowerCase();
    if (lower.contains('sewa')) return Icons.home;
    if (lower.contains('gaji')) return Icons.person;
    if (lower.contains('listrik') || lower.contains('utilitas')) return Icons.flash_on;
    if (lower.contains('internet')) return Icons.wifi;
    if (lower.contains('transport')) return Icons.directions_car;
    return Icons.receipt;
  }
}
