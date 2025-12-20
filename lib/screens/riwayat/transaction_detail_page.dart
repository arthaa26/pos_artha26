import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import '../../models/transaksi.dart';
import '../../providers/pos_provider.dart';

class TransactionDetailPage extends StatefulWidget {
  final Transaksi transaksi;

  const TransactionDetailPage({super.key, required this.transaksi});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PosProvider>();
    final settings = provider.settings;
    final transaksi = widget.transaksi;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        backgroundColor: Colors.grey[300],
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printReceipt(settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID Transaksi: TRX${transaksi.tanggal.millisecondsSinceEpoch.toString().substring(8)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tanggal: ${transaksi.tanggal.toString().substring(0, 19)}',
                    ),
                    const Text('Kasir: Admin'),
                    if (transaksi.paymentMethod != null) ...[
                      const SizedBox(height: 8),
                      Text('Metode Pembayaran: ${transaksi.paymentMethod}'),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Produk yang dibeli
            const Text(
              'Produk yang Dibeli:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (transaksi.items != null && transaksi.items!.isNotEmpty)
              ...transaksi.items!.map(
                (item) => Card(
                  child: ListTile(
                    title: Text(item['nama'] ?? 'Produk'),
                    subtitle: Text('Qty: ${item['quantity'] ?? 1}'),
                    trailing: Text(
                      'Rp ${(item['total'] ?? 0).toStringAsFixed(0)}',
                    ),
                  ),
                ),
              )
            else
              Card(
                child: ListTile(
                  title: Text(transaksi.deskripsi),
                  subtitle: const Text('Detail produk tidak tersedia'),
                ),
              ),

            const SizedBox(height: 16),

            // Ringkasan
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:'),
                        Text('Rp ${transaksi.pendapatan.toStringAsFixed(0)}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PPN (${(settings.ppnRate * 100).toStringAsFixed(0)}%):',
                        ),
                        Text(
                          'Rp ${(transaksi.pendapatan * settings.ppnRate).toStringAsFixed(0)}',
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Rp ${(transaksi.pendapatan * 1.1).toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (transaksi.cashGiven != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Dibayar:'),
                          Text('Rp ${transaksi.cashGiven!.toStringAsFixed(0)}'),
                        ],
                      ),
                    ],
                    if (transaksi.change != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Kembalian:'),
                          Text('Rp ${transaksi.change!.toStringAsFixed(0)}'),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Preview Struk
            const Text(
              'Preview Struk:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  if (settings.storeLogoPath.isNotEmpty)
                    SizedBox(
                      height: 50,
                      child: Image.file(
                        File(settings.storeLogoPath),
                        height: 50,
                      ),
                    )
                  else
                    const Text(
                      'LOGO',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Nama Toko
                  Text(
                    settings.storeName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Alamat
                  Text(
                    settings.storeAddress,
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // ID Transaksi, Tanggal, Kasir
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID: TRX${transaksi.tanggal.millisecondsSinceEpoch.toString().substring(8)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Tanggal: ${transaksi.tanggal.toString().substring(0, 19)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Text(
                        'Kasir: Admin',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const Divider(),
                  // Produk
                  if (transaksi.items != null && transaksi.items!.isNotEmpty)
                    ...transaksi.items!.map(
                      (item) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item['nama'] ?? 'Produk'} x${item['quantity'] ?? 1}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          Text(
                            'Rp ${(item['total'] ?? 0).toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  else
                    Text(
                      transaksi.deskripsi,
                      style: const TextStyle(fontSize: 12),
                    ),
                  const Divider(),
                  // PPN, Status, Metode
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PPN (10%)',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Rp ${(transaksi.pendapatan * 0.1).toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Status', style: const TextStyle(fontSize: 12)),
                      Text('Lunas', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  if (transaksi.paymentMethod != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Metode',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          transaksi.paymentMethod!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  const Divider(),
                  // Subtotal, Diskon, Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotal',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Rp ${transaksi.pendapatan.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Diskon', style: const TextStyle(fontSize: 12)),
                      Text('Rp 0', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rp ${(transaksi.pendapatan * 1.1).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  // Dibayar, Kembalian
                  if (transaksi.cashGiven != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Dibayar',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Rp ${transaksi.cashGiven!.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                  if (transaksi.change != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Kembalian',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Rp ${transaksi.change!.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Terima Kasih dan Jam Operasional
                  Text(
                    settings.receiptFooter.isNotEmpty
                        ? settings.receiptFooter
                        : 'Terima Kasih',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    settings.receiptHeader.isNotEmpty
                        ? settings.receiptHeader
                        : 'Jam Operasional: 08:00 - 20:00',
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _printReceipt(dynamic settings) async {
    final transaksi = widget.transaksi;
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              // Logo
              if (settings.storeLogoPath.isNotEmpty)
                pw.Container(
                  height: 50,
                  child: pw.Image(
                    pw.MemoryImage(
                      File(settings.storeLogoPath).readAsBytesSync(),
                    ),
                  ),
                )
              else
                pw.Text(
                  'LOGO',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              pw.SizedBox(height: 8),
              // Nama Toko
              pw.Text(
                settings.storeName,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              // Alamat
              pw.Text(
                settings.storeAddress,
                style: pw.TextStyle(fontSize: 12),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 16),
              // ID Transaksi, Tanggal, Kasir
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'ID: TRX${transaksi.tanggal.millisecondsSinceEpoch.toString().substring(8)}',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                  pw.Text(
                    'Tanggal: ${transaksi.tanggal.toString().substring(0, 19)}',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                  pw.Text('Kasir: Admin', style: pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.Divider(),
              // Produk
              if (transaksi.items != null && transaksi.items!.isNotEmpty)
                ...transaksi.items!.map(
                  (item) => pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        '${item['nama'] ?? 'Produk'} x${item['quantity'] ?? 1}',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                      pw.Text(
                        'Rp ${(item['total'] ?? 0).toStringAsFixed(0)}',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                )
              else
                pw.Text(transaksi.deskripsi, style: pw.TextStyle(fontSize: 12)),
              pw.Divider(),
              // PPN, Status, Metode
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'PPN (${(settings.ppnRate * 100).toStringAsFixed(0)}%)',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                  pw.Text(
                    'Rp ${(transaksi.pendapatan * settings.ppnRate).toStringAsFixed(0)}',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Status', style: pw.TextStyle(fontSize: 12)),
                  pw.Text('Lunas', style: pw.TextStyle(fontSize: 12)),
                ],
              ),
              if (transaksi.paymentMethod != null)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Metode', style: pw.TextStyle(fontSize: 12)),
                    pw.Text(
                      transaksi.paymentMethod!,
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              pw.Divider(),
              // Subtotal, Diskon, Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal', style: pw.TextStyle(fontSize: 12)),
                  pw.Text(
                    'Rp ${transaksi.pendapatan.toStringAsFixed(0)}',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Diskon', style: pw.TextStyle(fontSize: 12)),
                  pw.Text('Rp 0', style: pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Rp ${(transaksi.pendapatan * 1.1).toStringAsFixed(0)}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.Divider(),
              // Dibayar, Kembalian
              if (transaksi.cashGiven != null) ...[
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Dibayar', style: pw.TextStyle(fontSize: 12)),
                    pw.Text(
                      'Rp ${transaksi.cashGiven!.toStringAsFixed(0)}',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
              if (transaksi.change != null) ...[
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Kembalian', style: pw.TextStyle(fontSize: 12)),
                    pw.Text(
                      'Rp ${transaksi.change!.toStringAsFixed(0)}',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
              pw.SizedBox(height: 16),
              // Terima Kasih dan Jam Operasional
              pw.Text(
                settings.receiptFooter.isNotEmpty
                    ? settings.receiptFooter
                    : 'Terima Kasih',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                settings.receiptHeader.isNotEmpty
                    ? settings.receiptHeader
                    : 'Jam Operasional: 08:00 - 20:00',
                style: pw.TextStyle(fontSize: 10),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
