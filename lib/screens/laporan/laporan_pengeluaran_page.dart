import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/local_api_service.dart';
import '../../database/database.dart' as drift_db;
import '../../widgets/data_table_widget.dart';
import '../../services/export_service.dart';

class LaporanPengeluaranPage extends StatefulWidget {
  const LaporanPengeluaranPage({super.key});

  @override
  State<LaporanPengeluaranPage> createState() => _LaporanPengeluaranPageState();
}

class _LaporanPengeluaranPageState extends State<LaporanPengeluaranPage> {
  final _currencyFormat = NumberFormat('#,###', 'id_ID');
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'id_ID');
  final _exportService = ExportService();
  late Future<List<drift_db.Pengeluaran>> _pengeluaranFuture;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _pengeluaranFuture = localApiService.getAllPengeluaran();
  }

  Map<String, dynamic> _calculateExpensesByCategory(List<drift_db.Pengeluaran> pengeluaran) {
    final expensesByCategory = <String, double>{};
    double totalExpense = 0;

    for (var p in pengeluaran) {
      final category = p.kategori;
      final amount = p.jumlah;
      expensesByCategory[category] = (expensesByCategory[category] ?? 0) + amount;
      totalExpense += amount;
    }

    final sorted = expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'data': Map.fromEntries(sorted),
      'total': totalExpense,
      'count': pengeluaran.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Pengeluaran'),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder<List<drift_db.Pengeluaran>>(
        future: _pengeluaranFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal memuat data: ${snapshot.error}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada data pengeluaran',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final pengeluaran = snapshot.data!;
          final result = _calculateExpensesByCategory(pengeluaran);
          final byCategory = (result['data'] as Map).entries.toList();
          final totalExpense = result['total'] as double;

          // All expenses table
          final allHeaders = ['Tanggal', 'Kategori', 'Catatan', 'Jumlah'];
          final allRows = pengeluaran.map((p) => [
            _dateFormat.format(p.tanggal),
            p.kategori,
            p.catatan ?? '-',
            'Rp ${_currencyFormat.format(p.jumlah.toInt())}',
          ]).toList();

          // By category table
          final categoryHeaders = ['Kategori', 'Total Pengeluaran', 'Persentase'];
          final categoryRows = byCategory.map((entry) {
            final percentage = ((entry.value / totalExpense) * 100).toStringAsFixed(1);
            return [
              entry.key,
              'Rp ${_currencyFormat.format(entry.value)}',
              '$percentage%',
            ];
          }).toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.red.shade50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Laporan Pengeluaran',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Summary
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _buildStatCard('Total Pengeluaran', 'Rp ${_currencyFormat.format(totalExpense.toInt())}', Colors.red),
                          _buildStatCard('Jumlah Transaksi', pengeluaran.length.toString(), Colors.orange),
                          _buildStatCard('Kategori', byCategory.length.toString(), Colors.blue),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Export buttons
                      Wrap(
                        spacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isExporting ? null : () => _exportToExcel(allHeaders, pengeluaran),
                            icon: const Icon(Icons.file_download),
                            label: const Text('Export Excel'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _isExporting ? null : () => _exportToPdf(allHeaders, pengeluaran),
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
                // By Category Table
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pengeluaran berdasarkan Kategori',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DataTableWidget(
                        columnHeaders: categoryHeaders,
                        rows: categoryRows,
                        columnWidths: const [150, 150, 100],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // All Expenses Table
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detail Semua Pengeluaran',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DataTableWidget(
                        columnHeaders: allHeaders,
                        rows: allRows,
                        columnWidths: const [140, 120, 200, 140],
                      ),
                    ],
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
                  fontSize: 16, fontWeight: FontWeight.bold, color: color),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Future<void> _exportToExcel(List<String> headers, List<drift_db.Pengeluaran> pengeluaran) async {
    setState(() => _isExporting = true);
    try {
      final data = pengeluaran.map((p) => [
        p.tanggal.toString(),
        p.kategori,
        p.catatan ?? '-',
        p.jumlah.toInt(),
      ]).toList();

      final path = await _exportService.exportToExcel(
        fileName: 'Laporan_Pengeluaran_${DateTime.now().millisecondsSinceEpoch}',
        sheetName: 'Pengeluaran',
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

  Future<void> _exportToPdf(List<String> headers, List<drift_db.Pengeluaran> pengeluaran) async {
    setState(() => _isExporting = true);
    try {
      final data = pengeluaran.map((p) => [
        _dateFormat.format(p.tanggal),
        p.kategori,
        p.catatan ?? '-',
        'Rp ${_currencyFormat.format(p.jumlah.toInt())}',
      ]).toList();

      final path = await _exportService.exportToPdf(
        fileName: 'Laporan_Pengeluaran_${DateTime.now().millisecondsSinceEpoch}',
        title: 'LAPORAN PENGELUARAN',
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
