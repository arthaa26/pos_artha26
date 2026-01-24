import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/pos_provider.dart';
import '../../widgets/data_table_widget.dart';
import '../../services/export_service.dart';

class LaporanTransaksiPage extends StatefulWidget {
  const LaporanTransaksiPage({super.key});

  @override
  State<LaporanTransaksiPage> createState() => _LaporanTransaksiPageState();
}

class _LaporanTransaksiPageState extends State<LaporanTransaksiPage> {
  final _currencyFormat = NumberFormat('#,###', 'id_ID');
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'id_ID');
  final _exportService = ExportService();
  String _searchQuery = '';
  DateTime? _selectedDate;
  bool _isExporting = false;

  List _filterTransactions(List transaksi) {
    List filtered = transaksi;

    if (_selectedDate != null) {
      final selectedDateOnly = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
      filtered = filtered.where((t) {
        final tDateOnly = DateTime(t.tanggal.year, t.tanggal.month, t.tanggal.day);
        return tDateOnly == selectedDateOnly;
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) {
        final nomorTransaksi = t.nomorTransaksi.toLowerCase();
        final metode = t.metode.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return nomorTransaksi.contains(query) || metode.contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Transaksi'),
        backgroundColor: Colors.blue,
      ),
      body: Consumer<PosProvider>(
        builder: (context, provider, _) {
          if (provider.transaksi.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada data transaksi',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final filtered = _filterTransactions(provider.transaksi);

          // Prepare table data
          final headers = ['No Transaksi', 'Tanggal', 'Metode', 'Total', 'Dibayar', 'Kembalian'];
          final rows = filtered.map((t) => [
            t.nomorTransaksi,
            _dateFormat.format(t.tanggal),
            t.metode,
            'Rp ${_currencyFormat.format(t.total)}',
            'Rp ${_currencyFormat.format(t.bayar)}',
            'Rp ${_currencyFormat.format(t.kembalian ?? 0)}',
          ]).toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header & Filter
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.shade50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Laporan Transaksi',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Search
                      TextField(
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari nomor transaksi atau metode...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Date filter & Export buttons
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate ?? DateTime.now(),
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() => _selectedDate = date);
                              }
                            },
                            icon: const Icon(Icons.calendar_today),
                            label: Text(_selectedDate != null
                                ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                                : 'Pilih Tanggal'),
                          ),
                          if (_selectedDate != null)
                            OutlinedButton.icon(
                              onPressed: () => setState(() => _selectedDate = null),
                              icon: const Icon(Icons.clear),
                              label: const Text('Hapus Filter'),
                            ),
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
                      const SizedBox(height: 8),
                      Text(
                        'Total: ${filtered.length} transaksi',
                        style: Theme.of(context).textTheme.bodySmall,
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
                    columnWidths: const [120, 140, 100, 120, 120, 120],
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

  Future<void> _exportToExcel(List<String> headers, List filtered) async {
    setState(() => _isExporting = true);
    try {
      final data = filtered.map((t) => [
        t.nomorTransaksi,
        t.tanggal.toString(),
        t.metode,
        t.total,
        t.bayar,
        t.kembalian ?? 0,
      ]).toList();

      final path = await _exportService.exportToExcel(
        fileName: 'Laporan_Transaksi_${DateTime.now().millisecondsSinceEpoch}',
        sheetName: 'Transaksi',
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
      final data = filtered.map((t) => [
        t.nomorTransaksi as String,
        _dateFormat.format(t.tanggal),
        t.metode as String,
        'Rp ${_currencyFormat.format(t.total)}',
        'Rp ${_currencyFormat.format(t.bayar)}',
        'Rp ${_currencyFormat.format(t.kembalian ?? 0)}',
      ]).toList();

      final path = await _exportService.exportToPdf(
        fileName: 'Laporan_Transaksi_${DateTime.now().millisecondsSinceEpoch}',
        title: 'LAPORAN TRANSAKSI',
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
