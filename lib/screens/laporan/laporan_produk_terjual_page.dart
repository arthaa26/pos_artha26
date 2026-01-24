import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/pos_provider.dart';
import '../../services/local_api_service.dart';
import '../../widgets/data_table_widget.dart';
import '../../services/export_service.dart';

class LaporanProdukTerjualPage extends StatefulWidget {
  const LaporanProdukTerjualPage({super.key});

  @override
  State<LaporanProdukTerjualPage> createState() =>
      _LaporanProdukTerjualPageState();
}

class _LaporanProdukTerjualPageState extends State<LaporanProdukTerjualPage> {
  final _currencyFormat = NumberFormat('#,###', 'id_ID');
  final _exportService = ExportService();
  bool _isExporting = false;

  Future<Map<String, dynamic>> _calculateProductSales() async {
    final transaksi = context.read<PosProvider>().transaksi;
    final apiService = LocalApiService();
    final productSales = <String, Map<String, dynamic>>{};

    for (var t in transaksi) {
      try {
        final details = await apiService.getDetailTransaksi(t.id);
        for (var detail in details) {
          // Get product name from catatan or from database
          String productName = detail.catatan ?? 'Produk Tidak Diketahui';
          
          final quantity = detail.jumlah;
          final subtotal = detail.subtotal;

          if (productSales.containsKey(productName)) {
            productSales[productName]!['quantity'] = (productSales[productName]!['quantity'] as int) + quantity;
            productSales[productName]!['total'] = (productSales[productName]!['total'] as double) + subtotal;
          } else {
            productSales[productName] = {
              'quantity': quantity,
              'total': subtotal,
            };
          }
        }
      } catch (e) {
        if (kDebugMode) print('❌ Error loading transaction details: $e');
      }
    }

    final sorted = productSales.entries.toList()
      ..sort((a, b) => (b.value['quantity'] as int).compareTo(a.value['quantity'] as int));

    return {'data': Map.fromEntries(sorted), 'total': productSales.length};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Produk Terjual'),
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

          return FutureBuilder<Map<String, dynamic>>(
            future: _calculateProductSales(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal memuat data',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              final salesData = snapshot.data!;
              final products = (salesData['data'] as Map).entries.toList();

              // Prepare table data
              final headers = ['Produk', 'Jumlah', 'Total Penjualan'];
              final rows = products.map((entry) => [
                entry.key,
                entry.value['quantity'].toString(),
                'Rp ${_currencyFormat.format(entry.value['total'])}',
              ]).toList();

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.blue.shade50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Laporan Produk Terjual',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total produk: ${products.length}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          // Export buttons
                          Wrap(
                            spacing: 8,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _isExporting ? null : () => _exportToExcel(headers, products),
                                icon: const Icon(Icons.file_download),
                                label: const Text('Export Excel'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _isExporting ? null : () => _exportToPdf(headers, products),
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
                        columnWidths: const [200, 100, 150],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _exportToExcel(List<String> headers, List<MapEntry> products) async {
    setState(() => _isExporting = true);
    try {
      final data = products.map((entry) => [
        entry.key,
        entry.value['quantity'],
        entry.value['total'],
      ]).toList();

      final path = await _exportService.exportToExcel(
        fileName: 'Laporan_Produk_Terjual_${DateTime.now().millisecondsSinceEpoch}',
        sheetName: 'Produk',
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

  Future<void> _exportToPdf(List<String> headers, List<MapEntry> products) async {
    setState(() => _isExporting = true);
    try {
      final data = products.map((entry) => [
        entry.key as String,
        (entry.value['quantity'] as int).toString(),
        'Rp ${_currencyFormat.format(entry.value['total'])}',
      ]).toList();

      final path = await _exportService.exportToPdf(
        fileName: 'Laporan_Produk_Terjual_${DateTime.now().millisecondsSinceEpoch}',
        title: 'LAPORAN PRODUK TERJUAL',
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
