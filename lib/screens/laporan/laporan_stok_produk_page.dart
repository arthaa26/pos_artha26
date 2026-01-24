import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/pos_provider.dart';
import '../../widgets/data_table_widget.dart';
import '../../services/export_service.dart';

class LaporanStokProdukPage extends StatefulWidget {
  const LaporanStokProdukPage({super.key});

  @override
  State<LaporanStokProdukPage> createState() => _LaporanStokProdukPageState();
}

class _LaporanStokProdukPageState extends State<LaporanStokProdukPage> {
  final _currencyFormat = NumberFormat('#,###', 'id_ID');
  final _exportService = ExportService();
  String _searchQuery = '';
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Stok Produk'),
        backgroundColor: Colors.green,
      ),
      body: Consumer<PosProvider>(
        builder: (context, provider, _) {
          if (provider.produk.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada data produk',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // Filter berdasarkan search query
          final filtered = provider.produk.where((p) {
            final query = _searchQuery.toLowerCase();
            return p.nama.toLowerCase().contains(query) ||
                p.kategori.toLowerCase().contains(query);
          }).toList();

          // Prepare table data
          final headers = ['Nama Produk', 'Kategori', 'Stok', 'Harga Satuan', 'Harga Beli'];
          final rows = filtered.map((p) => [
            p.nama,
            p.kategori ?? 'Uncategorized',
            p.stok.toString(),
            'Rp ${_currencyFormat.format(p.harga)}',
            'Rp ${_currencyFormat.format(p.hargaBeli ?? 0)}',
          ]).toList();

          // Calculate summary
          final totalStok = filtered.fold<int>(0, (sum, p) => sum + (p.stok as int));
          final lowStockItems = filtered.where((p) => p.stok <= 5).length;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header & Filter
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.green.shade50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Laporan Stok Produk',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Summary stats
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _buildStatCard('Total Produk', filtered.length.toString(), Colors.blue),
                          _buildStatCard('Total Stok', totalStok.toString(), Colors.green),
                          _buildStatCard('Stok Rendah (≤5)', lowStockItems.toString(), Colors.orange),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Search
                      TextField(
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari nama produk atau kategori...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Export buttons
                      Wrap(
                        spacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isExporting ? null : () => _exportToExcel(headers, filtered),
                            icon: const Icon(Icons.file_download),
                            label: const Text('Export Excel'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _isExporting ? null : () => _exportToPdf(headers, filtered),
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Export PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Table
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DataTableWidget(
                    columnHeaders: headers,
                    rows: rows,
                    columnWidths: const [140, 110, 80, 140, 140],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 11)),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Future<void> _exportToExcel(List<String> headers, List filtered) async {
    setState(() => _isExporting = true);
    try {
      final data = filtered.map((p) => [
        p.nama,
        p.kategori,
        p.stok,
        p.harga,
        p.hargaBeli ?? 0,
      ]).toList();

      final path = await _exportService.exportToExcel(
        fileName: 'Laporan_Stok_Produk_${DateTime.now().millisecondsSinceEpoch}',
        sheetName: 'Stok',
        headers: headers,
        data: data,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File disimpan: $path')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportToPdf(List<String> headers, List filtered) async {
    setState(() => _isExporting = true);
    try {
      final data = filtered.map((p) => [
        p.nama as String,
        p.kategori as String,
        (p.stok as int).toString(),
        'Rp ${_currencyFormat.format(p.harga)}',
        'Rp ${_currencyFormat.format(p.hargaBeli ?? 0)}',
      ]).toList();

      final path = await _exportService.exportToPdf(
        fileName: 'Laporan_Stok_Produk_${DateTime.now().millisecondsSinceEpoch}',
        title: 'LAPORAN STOK PRODUK',
        headers: headers,
        data: data,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File disimpan: $path')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }
}
