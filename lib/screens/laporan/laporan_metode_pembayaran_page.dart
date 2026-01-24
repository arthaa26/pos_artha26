import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/pos_provider.dart';
import '../../widgets/data_table_widget.dart';
import '../../services/export_service.dart';

class LaporanMetodePembayaranPage extends StatefulWidget {
  const LaporanMetodePembayaranPage({super.key});

  @override
  State<LaporanMetodePembayaranPage> createState() =>
      _LaporanMetodePembayaranPageState();
}

class _LaporanMetodePembayaranPageState
    extends State<LaporanMetodePembayaranPage> {
  final _currencyFormat = NumberFormat('#,###', 'id_ID');
  final _exportService = ExportService();
  bool _isExporting = false;

  Map<String, dynamic> _calculatePaymentMethods(List transaksi) {
    final paymentMethods = <String, dynamic>{};
    double totalAmount = 0;
    int transactionCount = 0;

    for (var t in transaksi) {
      final method = t.metode;
      final total = (t.total as double).toInt();
      if (paymentMethods[method] == null) {
        paymentMethods[method] = {'total': 0, 'count': 0};
      }
      paymentMethods[method]['total'] = (paymentMethods[method]['total'] as int) + total;
      paymentMethods[method]['count'] = (paymentMethods[method]['count'] as int) + 1;
      totalAmount += t.total as double;
      transactionCount++;
    }

    final sorted = paymentMethods.entries.toList()
      ..sort((a, b) => (b.value['total'] as int).compareTo(a.value['total'] as int));

    return {
      'data': Map.fromEntries(sorted),
      'total': totalAmount,
      'transactionCount': transactionCount,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Metode Pembayaran'),
        backgroundColor: Colors.purple,
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

          final result = _calculatePaymentMethods(provider.transaksi);
          final paymentMethods = (result['data'] as Map).entries.toList();
          final totalAmount = result['total'] as double;

          // Prepare table data
          final headers = ['Metode Pembayaran', 'Jumlah Transaksi', 'Total Penerimaan', 'Persentase'];
          final rows = paymentMethods.map((entry) {
            final count = entry.value['count'] as int;
            final total = entry.value['total'] as int;
            final percentage = ((total / totalAmount) * 100).toStringAsFixed(1);
            return [
              entry.key,
              count.toString(),
              'Rp ${_currencyFormat.format(total)}',
              '$percentage%',
            ];
          }).toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.purple.shade50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Laporan Metode Pembayaran',
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
                          _buildStatCard('Total Transaksi', result['transactionCount'].toString(), Colors.blue),
                          _buildStatCard('Total Penerimaan', 'Rp ${_currencyFormat.format(totalAmount)}', Colors.green),
                          _buildStatCard('Metode Pembayaran', paymentMethods.length.toString(), Colors.purple),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Export buttons
                      Wrap(
                        spacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isExporting ? null : () => _exportToExcel(headers, paymentMethods, totalAmount),
                            icon: const Icon(Icons.file_download),
                            label: const Text('Export Excel'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _isExporting ? null : () => _exportToPdf(headers, paymentMethods, totalAmount),
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
                    columnWidths: const [150, 120, 150, 100],
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

  Future<void> _exportToExcel(List<String> headers, List paymentMethods, double totalAmount) async {
    setState(() => _isExporting = true);
    try {
      final data = paymentMethods.map((entry) {
        final count = entry.value['count'] as int;
        final total = entry.value['total'] as int;
        final percentage = ((total / totalAmount) * 100).toStringAsFixed(1);
        return [
          entry.key,
          count,
          total,
          double.parse(percentage),
        ];
      }).toList();

      final path = await _exportService.exportToExcel(
        fileName: 'Laporan_Metode_Pembayaran_${DateTime.now().millisecondsSinceEpoch}',
        sheetName: 'Pembayaran',
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

  Future<void> _exportToPdf(List<String> headers, List paymentMethods, double totalAmount) async {
    setState(() => _isExporting = true);
    try {
      final data = paymentMethods.map((entry) {
        final count = entry.value['count'] as int;
        final total = entry.value['total'] as int;
        final percentage = ((total / totalAmount) * 100).toStringAsFixed(1);
        return [
          entry.key,
          count.toString(),
          'Rp ${_currencyFormat.format(total)}',
          '$percentage%',
        ] as List<String>;
      }).toList();

      final path = await _exportService.exportToPdf(
        fileName: 'Laporan_Metode_Pembayaran_${DateTime.now().millisecondsSinceEpoch}',
        title: 'LAPORAN METODE PEMBAYARAN',
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
