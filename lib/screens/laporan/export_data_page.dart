import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/pos_provider.dart';

class ExportDataPage extends StatefulWidget {
  const ExportDataPage({super.key});

  @override
  State<ExportDataPage> createState() => _ExportDataPageState();
}

class _ExportDataPageState extends State<ExportDataPage> {
  bool _isExporting = false;

  Future<void> _exportToExcel() async {
    setState(() => _isExporting = true);

    try {
      final summary = context.read<PosProvider>().summary;
      final transaksi = context.read<PosProvider>().transaksi;
      final produk = context.read<PosProvider>().produk;

      var excel = Excel.createExcel();

      // Define styles
      var headerStyle = CellStyle(
        bold: true,
        fontSize: 14,
      );

      var titleStyle = CellStyle(
        bold: true,
        fontSize: 16,
      );

      var dataStyle = CellStyle();

      var numberStyle = CellStyle();

      // Sheet 1: Summary
      Sheet summarySheet = excel['Ringkasan'];
      summarySheet.cell(CellIndex.indexByString("A1")).value = TextCellValue(
        "Laporan POS Artha26",
      );
      summarySheet.cell(CellIndex.indexByString("A1")).cellStyle = titleStyle;

      summarySheet.cell(CellIndex.indexByString("A3")).value = TextCellValue(
        "Tanggal Export",
      );
      summarySheet.cell(CellIndex.indexByString("B3")).value = TextCellValue(
        DateTime.now().toString().substring(0, 19),
      );

      summarySheet.cell(CellIndex.indexByString("A5")).value = TextCellValue(
        "RINGKASAN",
      );
      summarySheet.cell(CellIndex.indexByString("A5")).cellStyle = headerStyle;

      summarySheet.cell(CellIndex.indexByString("A6")).value = TextCellValue(
        "Total Pendapatan",
      );
      summarySheet.cell(CellIndex.indexByString("A6")).cellStyle = dataStyle;
      summarySheet.cell(CellIndex.indexByString("B6")).value = IntCellValue(
        (summary?.totalPendapatan ?? 0).toInt(),
      );
      summarySheet.cell(CellIndex.indexByString("B6")).cellStyle = numberStyle;

      summarySheet.cell(CellIndex.indexByString("A7")).value = TextCellValue(
        "Total Keuntungan",
      );
      summarySheet.cell(CellIndex.indexByString("A7")).cellStyle = dataStyle;
      summarySheet.cell(CellIndex.indexByString("B7")).value = IntCellValue(
        (summary?.totalKeuntungan ?? 0).toInt(),
      );
      summarySheet.cell(CellIndex.indexByString("B7")).cellStyle = numberStyle;

      summarySheet.cell(CellIndex.indexByString("A8")).value = TextCellValue(
        "Total Transaksi",
      );
      summarySheet.cell(CellIndex.indexByString("A8")).cellStyle = dataStyle;
      summarySheet.cell(CellIndex.indexByString("B8")).value = IntCellValue(
        summary?.totalTransaksi ?? 0,
      );
      summarySheet.cell(CellIndex.indexByString("B8")).cellStyle = numberStyle;

      summarySheet.cell(CellIndex.indexByString("A9")).value = TextCellValue(
        "Total Pengeluaran",
      );
      summarySheet.cell(CellIndex.indexByString("A9")).cellStyle = dataStyle;
      summarySheet.cell(CellIndex.indexByString("B9")).value = IntCellValue(
        (summary?.totalPengeluaran ?? 0).toInt(),
      );
      summarySheet.cell(CellIndex.indexByString("B9")).cellStyle = numberStyle;

      // Sheet 2: Transactions
      Sheet transaksiSheet = excel['Transaksi'];
      transaksiSheet.cell(CellIndex.indexByString("A1")).value = TextCellValue(
        "RIWAYAT TRANSAKSI",
      );
      transaksiSheet.cell(CellIndex.indexByString("A1")).cellStyle = titleStyle;

      transaksiSheet.cell(CellIndex.indexByString("A2")).value = TextCellValue(
        "Tanggal",
      );
      transaksiSheet.cell(CellIndex.indexByString("A2")).cellStyle =
          headerStyle;
      transaksiSheet.cell(CellIndex.indexByString("B2")).value = TextCellValue(
        "Deskripsi",
      );
      transaksiSheet.cell(CellIndex.indexByString("B2")).cellStyle =
          headerStyle;
      transaksiSheet.cell(CellIndex.indexByString("C2")).value = TextCellValue(
        "Pendapatan",
      );
      transaksiSheet.cell(CellIndex.indexByString("C2")).cellStyle =
          headerStyle;
      transaksiSheet.cell(CellIndex.indexByString("D2")).value = TextCellValue(
        "Keuntungan",
      );
      transaksiSheet.cell(CellIndex.indexByString("D2")).cellStyle =
          headerStyle;
      transaksiSheet.cell(CellIndex.indexByString("E2")).value = TextCellValue(
        "Pengeluaran",
      );
      transaksiSheet.cell(CellIndex.indexByString("E2")).cellStyle =
          headerStyle;

      for (int i = 0; i < transaksi.length; i++) {
        final t = transaksi[i];
        transaksiSheet.cell(CellIndex.indexByString("A${3 + i}")).value =
            TextCellValue(t.tanggal.toString().substring(0, 19));
        transaksiSheet.cell(CellIndex.indexByString("A${3 + i}")).cellStyle =
            dataStyle;
        transaksiSheet.cell(CellIndex.indexByString("B${3 + i}")).value =
            TextCellValue(t.deskripsi);
        transaksiSheet.cell(CellIndex.indexByString("B${3 + i}")).cellStyle =
            dataStyle;
        transaksiSheet.cell(CellIndex.indexByString("C${3 + i}")).value =
            IntCellValue(t.pendapatan.toInt());
        transaksiSheet.cell(CellIndex.indexByString("C${3 + i}")).cellStyle =
            numberStyle;
        transaksiSheet.cell(CellIndex.indexByString("D${3 + i}")).value =
            IntCellValue(t.keuntungan.toInt());
        transaksiSheet.cell(CellIndex.indexByString("D${3 + i}")).cellStyle =
            numberStyle;
        transaksiSheet.cell(CellIndex.indexByString("E${3 + i}")).value =
            IntCellValue(t.pengeluaran.toInt());
        transaksiSheet.cell(CellIndex.indexByString("E${3 + i}")).cellStyle =
            numberStyle;
      }

      // Sheet 3: Products
      Sheet produkSheet = excel['Produk'];
      produkSheet.cell(CellIndex.indexByString("A1")).value = TextCellValue(
        "DAFTAR PRODUK",
      );
      produkSheet.cell(CellIndex.indexByString("A1")).cellStyle = titleStyle;

      produkSheet.cell(CellIndex.indexByString("A2")).value = TextCellValue(
        "Nama",
      );
      produkSheet.cell(CellIndex.indexByString("A2")).cellStyle = headerStyle;
      produkSheet.cell(CellIndex.indexByString("B2")).value = TextCellValue(
        "Harga",
      );
      produkSheet.cell(CellIndex.indexByString("B2")).cellStyle = headerStyle;
      produkSheet.cell(CellIndex.indexByString("C2")).value = TextCellValue(
        "Stok",
      );
      produkSheet.cell(CellIndex.indexByString("C2")).cellStyle = headerStyle;
      produkSheet.cell(CellIndex.indexByString("D2")).value = TextCellValue(
        "Deskripsi",
      );
      produkSheet.cell(CellIndex.indexByString("D2")).cellStyle = headerStyle;

      for (int i = 0; i < produk.length; i++) {
        final p = produk[i];
        produkSheet.cell(CellIndex.indexByString("A${3 + i}")).value =
            TextCellValue(p.nama);
        produkSheet.cell(CellIndex.indexByString("A${3 + i}")).cellStyle =
            dataStyle;
        produkSheet.cell(CellIndex.indexByString("B${3 + i}")).value =
            IntCellValue(p.harga.toInt());
        produkSheet.cell(CellIndex.indexByString("B${3 + i}")).cellStyle =
            numberStyle;
        produkSheet.cell(CellIndex.indexByString("C${3 + i}")).value =
            IntCellValue(p.stok);
        produkSheet.cell(CellIndex.indexByString("C${3 + i}")).cellStyle =
            numberStyle;
        produkSheet.cell(CellIndex.indexByString("D${3 + i}")).value =
            TextCellValue(p.deskripsi);
        produkSheet.cell(CellIndex.indexByString("D${3 + i}")).cellStyle =
            dataStyle;
      }

      // Request storage permission
      var status = await Permission.storage.request();
      if (status.isGranted) {
        // Use temporary directory for simplicity
        final directory = await getTemporaryDirectory();
        final fileName =
            'laporan_pos_${DateTime.now().toString().substring(0, 10)}.xlsx';
        final file = File('${directory.path}/$fileName');

        await file.writeAsBytes(excel.encode()!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Laporan berhasil diekspor ke: ${file.path}')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Izin penyimpanan diperlukan untuk export'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error export: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data Transaksi'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.download, size: 80, color: Colors.teal),
            const SizedBox(height: 16),
            const Text(
              'Export Data ke Excel',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'File Excel akan berisi 3 sheet:\n- Ringkasan\n- Transaksi\n- Produk',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isExporting ? null : _exportToExcel,
              icon: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: Text(_isExporting ? 'Mengekspor...' : 'Export ke Excel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
