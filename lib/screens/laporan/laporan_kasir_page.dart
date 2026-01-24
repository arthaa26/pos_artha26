import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/pos_provider.dart';
import '../../widgets/data_table_widget.dart';
import '../../services/export_service.dart';

class LaporanKasirPage extends StatefulWidget {
  const LaporanKasirPage({super.key});

  @override
  State<LaporanKasirPage> createState() => _LaporanKasirPageState();
}

class _LaporanKasirPageState extends State<LaporanKasirPage> {
  final _currencyFormat = NumberFormat('#,###', 'id_ID');
  final _dateFormat = DateFormat('dd/MM/yyyy', 'id_ID');
  final _exportService = ExportService();
  bool _isExporting = false;

  Map<String, dynamic> _calculateDailySales(List transaksi) {
    final dailySales = <String, Map<String, dynamic>>{};
    double totalRevenue = 0;

    for (var t in transaksi) {
      final dateKey = _dateFormat.format(t.tanggal);
      final total = (t.total as double).toInt();

      if (dailySales.containsKey(dateKey)) {
        dailySales[dateKey]!['revenue'] = (dailySales[dateKey]!['revenue'] as int) + total;
        dailySales[dateKey]!['count'] = (dailySales[dateKey]!['count'] as int) + 1;
      } else {
        dailySales[dateKey] = {
          'revenue': total,
          'count': 1,
        };
      }
      totalRevenue += t.total as double;
    }

    final sorted = dailySales.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return {
      'data': Map.fromEntries(sorted),
      'totalRevenue': totalRevenue,
      'days': sorted.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Kasir Harian'),
        backgroundColor: Colors.orange,
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

          final result = _calculateDailySales(provider.transaksi);
          final dailySales = (result['data'] as Map).entries.toList();
          final totalRevenue = result['totalRevenue'] as double;
          final days = result['days'] as int;

          // Prepare table data
          final headers = ['Tanggal', 'Jumlah Transaksi', 'Total Penerimaan', 'Rata-rata'];
          final rows = dailySales.map((entry) {
            final count = entry.value['count'] as int;
            final revenue = entry.value['revenue'] as int;
            final average = (revenue / count).toStringAsFixed(0);
            return [
              entry.key,
              count.toString(),
              'Rp ${_currencyFormat.format(revenue)}',
              'Rp ${_currencyFormat.format(int.parse(average))}',
            ];
          }).toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.orange.shade50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Laporan Kasir Harian',
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
                          _buildStatCard('Hari Aktif', days.toString(), Colors.blue),
                          _buildStatCard('Total Transaksi', provider.transaksi.length.toString(), Colors.orange),
                          _buildStatCard('Total Penerimaan', 'Rp ${_currencyFormat.format(totalRevenue)}', Colors.green),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Export buttons
                      Wrap(
                        spacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isExporting ? null : () => _exportToExcel(headers, dailySales),
                            icon: const Icon(Icons.file_download),
                            label: const Text('Export Excel'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _isExporting ? null : () => _exportToPdf(headers, dailySales),
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
                    columnWidths: const [120, 130, 150, 150],
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

  Future<void> _exportToExcel(List<String> headers, List dailySales) async {
    setState(() => _isExporting = true);
    try {
      final data = dailySales.map((entry) {
        final count = entry.value['count'] as int;
        final revenue = entry.value['revenue'] as int;
        final average = revenue ~/ count;
        return [
          entry.key,
          count,
          revenue,
          average,
        ];
      }).toList();

      final path = await _exportService.exportToExcel(
        fileName: 'Laporan_Kasir_Harian_${DateTime.now().millisecondsSinceEpoch}',
        sheetName: 'Kasir',
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

  Future<void> _exportToPdf(List<String> headers, List dailySales) async {
    setState(() => _isExporting = true);
    try {
      final data = dailySales.map((entry) {
        final count = entry.value['count'] as int;
        final revenue = entry.value['revenue'] as int;
        final average = revenue ~/ count;
        return [
          entry.key,
          count.toString(),
          'Rp ${_currencyFormat.format(revenue)}',
          'Rp ${_currencyFormat.format(average)}',
        ] as List<String>;
      }).toList();

      final path = await _exportService.exportToPdf(
        fileName: 'Laporan_Kasir_Harian_${DateTime.now().millisecondsSinceEpoch}',
        title: 'LAPORAN KASIR HARIAN',
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
