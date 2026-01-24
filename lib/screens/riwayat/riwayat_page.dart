import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../providers/pos_provider.dart';
import '../../services/local_api_service.dart';
import '../../services/print_manager_service.dart';
import '../../models/thermal_receipt.dart';
import '../../widgets/receipt_preview_widget.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  @override
  void initState() {
    super.initState();
    // Initialize locale data for Indonesia
    initializeDateFormatting('id_ID', null);
    // Load transactions when page loads
    Future.microtask(() {
      context.read<PosProvider>().loadTransaksi();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        backgroundColor: Colors.grey[300],
        elevation: 0,
      ),
      body: Consumer<PosProvider>(
        builder: (context, provider, _) {
          final transaksi = provider.transaksi;

          if (transaksi.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => provider.loadTransaksi(),
              child: Center(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada transaksi',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Sort transaksi by date (newest first)
          final sortedTransaksi = List.from(transaksi)
            ..sort((a, b) => b.tanggal.compareTo(a.tanggal));

          return RefreshIndicator(
            onRefresh: () => provider.loadTransaksi(),
            child: ListView.builder(
              itemCount: sortedTransaksi.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final t = sortedTransaksi[index];
                final formatter = DateFormat('dd/MM/yyyy HH:mm', 'id_ID');
                final rupiahFormat = NumberFormat('#,###', 'id_ID');

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.shopping_cart_checkout,
                        color: Colors.blue[700],
                      ),
                    ),
                    title: Text(
                      'TRX #${t.nomorTransaksi}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          formatter.format(t.tanggal),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (t.metode != null)
                          Text(
                            'Pembayaran: ${t.metode}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rp ${rupiahFormat.format(t.total.toInt())}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dibayar: Rp ${rupiahFormat.format(t.bayar.toInt())}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransactionDetailPage(transaksi: t),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Detail Transaction Page
class TransactionDetailPage extends StatefulWidget {
  final dynamic transaksi;

  const TransactionDetailPage({super.key, required this.transaksi});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  late Future<List<Map<String, dynamic>>> _detailFuture;

  @override
  void initState() {
    super.initState();
    // Initialize locale data for Indonesia
    initializeDateFormatting('id_ID', null);
    _detailFuture = _fetchDetailTransaksi();
  }

  Future<List<Map<String, dynamic>>> _fetchDetailTransaksi() async {
    try {
      final details = await localApiService.getDetailTransaksi(
        widget.transaksi.id,
      );
      if (kDebugMode) print('✅ Loaded ${details.length} detail transaksi');

      // Convert DetailTransaksi to Map for easier access
      final enrichedDetails = <Map<String, dynamic>>[];
      for (final detail in details) {
        if (kDebugMode)
          print(
            '📦 Detail: produkId=${detail.produkId}, catatan="${detail.catatan}"',
          );

        // Try to get product name from catatan first, then from produkId if not found
        String productName = detail.catatan ?? '';
        if (productName.isEmpty || productName == 'null') {
          if (kDebugMode)
            print('⚠️ Catatan empty or null, fetching from produkId...');
          // Fallback: fetch product name from database
          final produk = await localApiService.getProdukById(detail.produkId);
          productName =
              produk?.nama ?? 'Produk ID: ${detail.produkId} (Terhapus)';
          if (kDebugMode) print('✅ Got product name: $productName');
        } else {
          if (kDebugMode)
            print('✅ Got product name from catatan: $productName');
        }

        enrichedDetails.add({
          'id': detail.id,
          'transaksiId': detail.transaksiId,
          'produkId': detail.produkId,
          'namaProduk': productName,
          'jumlah': detail.jumlah,
          'hargaSatuan': detail.hargaSatuan,
          'subtotal': detail.subtotal,
          'diskon': (detail.hargaSatuan * detail.jumlah) - detail.subtotal,
          'total': detail.subtotal,
        });
      }

      return enrichedDetails;
    } catch (e) {
      if (kDebugMode) print('❌ Error loading detail transaksi: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm', 'id_ID');
    final rupiahFormat = NumberFormat('#,###', 'id_ID');

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail TRX #${widget.transaksi.nomorTransaksi}'),
        backgroundColor: Colors.grey[300],
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _showPrintOptions(
              context,
              widget.transaksi,
              _detailFuture,
              formatter,
              rupiahFormat,
            ),
            tooltip: 'Print Struk',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nomor Transaksi',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          widget.transaksi.nomorTransaksi,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tanggal',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          formatter.format(widget.transaksi.tanggal),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (widget.transaksi.metode != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Metode Pembayaran',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            widget.transaksi.metode,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    if (widget.transaksi.metode != null)
                      const SizedBox(height: 12),
                    if (widget.transaksi.catatan != null &&
                        widget.transaksi.catatan!.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Catatan',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Expanded(
                            child: Text(
                              widget.transaksi.catatan!,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Items Header
            const Text(
              'Detail Item',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            // Items List
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _detailFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada item'));
                }

                final items = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item['namaProduk'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  'x${item['jumlah']}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Harga Satuan:',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'Rp ${rupiahFormat.format((item['hargaSatuan'] as num).toInt())}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Diskon:',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'Rp ${rupiahFormat.format((item['diskon'] as num).toInt())}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Rp ${rupiahFormat.format((item['total'] as num).toInt())}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // Summary
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:'),
                        Text(
                          'Rp ${rupiahFormat.format(widget.transaksi.total.toInt())}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Dibayar:'),
                        Text(
                          'Rp ${rupiahFormat.format(widget.transaksi.bayar.toInt())}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Kembalian:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Rp ${rupiahFormat.format((widget.transaksi.bayar - widget.transaksi.total).toInt())}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _printReceipt(
    BuildContext context,
    dynamic transaksi,
    Future<List<Map<String, dynamic>>> detailFuture,
    DateFormat formatter,
    NumberFormat rupiahFormat,
  ) async {
    try {
      final details = await detailFuture;
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Text(
                  'POS ARTHA26',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Divider(),
                pw.SizedBox(height: 4),
                // Transaction Info
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'No. Transaksi:',
                      style: pw.TextStyle(fontSize: 11),
                    ),
                    pw.Text(
                      transaksi.nomorTransaksi,
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Tanggal:', style: pw.TextStyle(fontSize: 11)),
                    pw.Text(
                      formatter.format(transaksi.tanggal),
                      style: pw.TextStyle(fontSize: 11),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Metode:', style: pw.TextStyle(fontSize: 11)),
                    pw.Text(
                      transaksi.metode ?? 'Tunai',
                      style: pw.TextStyle(fontSize: 11),
                    ),
                  ],
                ),
                pw.Divider(),
                pw.SizedBox(height: 4),
                // Items Header
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        'Produk',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text(
                        'Qty',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'Harga',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'Total',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
                pw.Divider(),
                // Items
                ...details.map((item) {
                  return pw.Column(
                    children: [
                      pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 3,
                            child: pw.Text(
                              item['namaProduk'] as String,
                              style: pw.TextStyle(fontSize: 9),
                              maxLines: 2,
                            ),
                          ),
                          pw.Expanded(
                            flex: 1,
                            child: pw.Text(
                              '${item['jumlah']}',
                              style: pw.TextStyle(fontSize: 9),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                              'Rp ${(item['hargaSatuan'] as num).toInt()}',
                              style: pw.TextStyle(fontSize: 9),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                              'Rp ${(item['total'] as num).toInt()}',
                              style: pw.TextStyle(fontSize: 9),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 2),
                    ],
                  );
                }),
                pw.Divider(),
                pw.SizedBox(height: 4),
                // Summary
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total:',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Rp ${transaksi.total.toInt()}',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Dibayar:', style: pw.TextStyle(fontSize: 11)),
                    pw.Text(
                      'Rp ${transaksi.bayar.toInt()}',
                      style: pw.TextStyle(fontSize: 11),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Kembalian:',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Rp ${(transaksi.bayar - transaksi.total).toInt()}',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.Divider(),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Terima kasih telah berbelanja!',
                  style: pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            );
          },
        ),
      );

      // Print or preview
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  /// Show print options dialog
  void _showPrintOptions(
    BuildContext context,
    dynamic transaksi,
    Future<List<Map<String, dynamic>>> detailFuture,
    DateFormat formatter,
    NumberFormat rupiahFormat,
  ) {
    final provider = context.read<PosProvider>();
    final settings = provider.settings;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Preview & Cetak Struk'),
        content: FutureBuilder<List<Map<String, dynamic>>>(
          future: detailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('Tidak ada item');
            }

            final details = snapshot.data!;

            // Transform items to match ReceiptPreviewWidget format
            final receiptItems = details.map((item) {
              return {
                'nama': item['namaProduk'] as String,
                'jumlah': item['jumlah'] as int,
                'hargaSatuan': item['hargaSatuan'] as double,
                'subtotal': item['subtotal'] as double,
              };
            }).toList();

            final change = transaksi.bayar - transaksi.total;

            return SingleChildScrollView(
              child: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ReceiptPreviewWidget(
                      storeName: settings.storeName,
                      storeAddress: settings.storeAddress,
                      storePhone: settings.storePhone,
                      storeLogoPath: settings.storeLogoPath,
                      items: receiptItems,
                      subtotal: transaksi.total - (transaksi.total * settings.ppnRate),
                      ppnRate: settings.ppnRate,
                      cashGiven: transaksi.bayar,
                      change: change,
                      transactionNumber: transaksi.nomorTransaksi,
                      transactionTime: transaksi.tanggal,
                      thankYouMessage: settings.receiptFooter,
                      operatingHours: settings.receiptHeader,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _printThermalReceipt(context, transaksi, detailFuture);
            },
            child: const Text('🖨️ Thermal Printer (58mm)'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _printReceipt(
                context,
                transaksi,
                detailFuture,
                formatter,
                rupiahFormat,
              );
            },
            child: const Text('📄 PDF'),
          ),
        ],
      ),
    );
  }

  /// Print to thermal printer (58mm)
  Future<void> _printThermalReceipt(
    BuildContext context,
    dynamic transaksi,
    Future<List<Map<String, dynamic>>> detailFuture,
  ) async {
    try {
      if (kDebugMode) print('🖨️ [Riwayat] Starting thermal print...');

      final details = await detailFuture;
      final printManager = PrintManagerService();

      if (!printManager.isPrinterReady()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Printer tidak terhubung'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Build receipt items
      final itemsList = <Map<String, dynamic>>[];
      for (final detail in details) {
        itemsList.add({
          'nama': detail['namaProduk'] ?? detail['catatan'] ?? 'Item',
          'jumlah': detail['jumlah'] as int,
          'hargaSatuan': detail['hargaSatuan'] as double,
          'subtotal': detail['total'] as double,
        });
      }

      // Calculate totals
      double subtotal = 0;
      for (final detail in details) {
        subtotal += (detail['total'] as num).toDouble();
      }
      final ppnAmount = (subtotal * 0.1).toDouble();
      final grandTotal = subtotal + ppnAmount;

      // Create thermal receipt
      final receipt = ThermalReceipt(
        storeName: 'TOKO ARTHA26',
        storeAddress: 'Jl. Contoh No. 123',
        storePhone: '08123456789',
        items: itemsList,
        subtotal: subtotal,
        ppnRate: 0.1,
        ppnAmount: ppnAmount,
        grandTotal: grandTotal,
        cashGiven: (transaksi.bayar as num).toDouble(),
        change: ((transaksi.bayar as num) - subtotal - ppnAmount).toDouble(),
        transactionNumber: transaksi.nomorTransaksi,
        transactionTime: transaksi.tanggal,
        cashierName: 'Admin',
      );

      // Print
      final success = await printManager.printThermalReceipt(
        receipt: receipt,
        is58mm: true,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Struk berhasil dicetak!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Gagal mencetak struk'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ [Riwayat] Print error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
