import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import '../../models/transaksi.dart';
import '../../providers/pos_provider.dart';

class LaporanTransaksiPage extends StatefulWidget {
  const LaporanTransaksiPage({super.key});

  @override
  State<LaporanTransaksiPage> createState() => _LaporanTransaksiPageState();
}

class _LaporanTransaksiPageState extends State<LaporanTransaksiPage> {
  String _selectedPeriod = 'Harian';
  DateTime _selectedDate = DateTime.now();
  bool _isExporting = false;

  List<Transaksi> get _filteredTransactions {
    final allTransactions = context.watch<PosProvider>().transaksi;
    final dateFormat = DateFormat('yyyy-MM-dd');

    return allTransactions.where((t) {
      final transactionDate = dateFormat.format(t.tanggal);
      final selectedDateStr = dateFormat.format(_selectedDate);

      switch (_selectedPeriod) {
        case 'Harian':
          return transactionDate == selectedDateStr;
        case 'Bulanan':
          final transactionMonth = DateFormat('yyyy-MM').format(t.tanggal);
          final selectedMonth = DateFormat('yyyy-MM').format(_selectedDate);
          return transactionMonth == selectedMonth;
        case 'Tahunan':
          final transactionYear = t.tanggal.year;
          final selectedYear = _selectedDate.year;
          return transactionYear == selectedYear;
        default:
          return true;
      }
    }).toList();
  }

  Future<void> _exportToExcel() async {
    setState(() => _isExporting = true);

    try {
      final transactions = _filteredTransactions;

      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Laporan Transaksi'];

      // Header
      sheetObject.cell(CellIndex.indexByString("A1")).value = TextCellValue(
        "Laporan Transaksi POS Artha26",
      );
      sheetObject.cell(CellIndex.indexByString("A2")).value = TextCellValue(
        "Periode: $_selectedPeriod",
      );
      sheetObject.cell(CellIndex.indexByString("A3")).value = TextCellValue(
        "Tanggal Export: ${DateTime.now().toString().substring(0, 19)}",
      );

      // Summary
      double totalPendapatan = transactions.fold(
        0,
        (sum, t) => sum + t.pendapatan,
      );
      double totalKeuntungan = transactions.fold(
        0,
        (sum, t) => sum + t.keuntungan,
      );
      double totalPengeluaran = transactions.fold(
        0,
        (sum, t) => sum + t.pengeluaran,
      );

      sheetObject.cell(CellIndex.indexByString("A5")).value = TextCellValue(
        "RINGKASAN PERIODE",
      );
      sheetObject.cell(CellIndex.indexByString("A6")).value = TextCellValue(
        "Total Pendapatan",
      );
      sheetObject.cell(CellIndex.indexByString("B6")).value = DoubleCellValue(
        totalPendapatan,
      );
      sheetObject.cell(CellIndex.indexByString("A7")).value = TextCellValue(
        "Total Keuntungan",
      );
      sheetObject.cell(CellIndex.indexByString("B7")).value = DoubleCellValue(
        totalKeuntungan,
      );
      sheetObject.cell(CellIndex.indexByString("A8")).value = TextCellValue(
        "Total Pengeluaran",
      );
      sheetObject.cell(CellIndex.indexByString("B8")).value = DoubleCellValue(
        totalPengeluaran,
      );
      sheetObject.cell(CellIndex.indexByString("A9")).value = TextCellValue(
        "Jumlah Transaksi",
      );
      sheetObject.cell(CellIndex.indexByString("B9")).value = IntCellValue(
        transactions.length,
      );

      // Transactions header
      sheetObject.cell(CellIndex.indexByString("A11")).value = TextCellValue(
        "DETAIL TRANSAKSI",
      );
      sheetObject.cell(CellIndex.indexByString("A12")).value = TextCellValue(
        "Tanggal",
      );
      sheetObject.cell(CellIndex.indexByString("B12")).value = TextCellValue(
        "Waktu",
      );
      sheetObject.cell(CellIndex.indexByString("C12")).value = TextCellValue(
        "Deskripsi",
      );
      sheetObject.cell(CellIndex.indexByString("D12")).value = TextCellValue(
        "Pendapatan",
      );
      sheetObject.cell(CellIndex.indexByString("E12")).value = TextCellValue(
        "Keuntungan",
      );
      sheetObject.cell(CellIndex.indexByString("F12")).value = TextCellValue(
        "Pengeluaran",
      );

      // Transactions data
      for (int i = 0; i < transactions.length; i++) {
        final t = transactions[i];
        sheetObject.cell(CellIndex.indexByString("A${13 + i}")).value =
            TextCellValue(DateFormat('yyyy-MM-dd').format(t.tanggal));
        sheetObject.cell(CellIndex.indexByString("B${13 + i}")).value =
            TextCellValue(DateFormat('HH:mm:ss').format(t.tanggal));
        sheetObject.cell(CellIndex.indexByString("C${13 + i}")).value =
            TextCellValue(t.deskripsi);
        sheetObject.cell(CellIndex.indexByString("D${13 + i}")).value =
            DoubleCellValue(t.pendapatan);
        sheetObject.cell(CellIndex.indexByString("E${13 + i}")).value =
            DoubleCellValue(t.keuntungan);
        sheetObject.cell(CellIndex.indexByString("F${13 + i}")).value =
            DoubleCellValue(t.pengeluaran);
      }

      // Request storage permission
      var status = await Permission.storage.request();
      if (status.isGranted) {
        final directory = await getExternalStorageDirectory();
        final periodSuffix = _selectedPeriod.toLowerCase();
        final dateSuffix = _selectedPeriod == 'Harian'
            ? DateFormat('yyyy-MM-dd').format(_selectedDate)
            : _selectedPeriod == 'Bulanan'
            ? DateFormat('yyyy-MM').format(_selectedDate)
            : DateFormat('yyyy').format(_selectedDate);
        final fileName = 'laporan_transaksi_${periodSuffix}_$dateSuffix.xlsx';
        final file = File('${directory!.path}/$fileName');

        await file.writeAsBytes(excel.encode()!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Laporan berhasil diekspor ke: $fileName')),
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

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _filteredTransactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Transaksi'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter Periode',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Periode: '),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _selectedPeriod,
                          items: ['Harian', 'Bulanan', 'Tahunan'].map((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedPeriod = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          _selectedPeriod == 'Tahunan'
                              ? 'Tahun: '
                              : 'Tanggal: ',
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _selectDate,
                          child: Text(
                            _selectedPeriod == 'Tahunan'
                                ? DateFormat('yyyy').format(_selectedDate)
                                : _selectedPeriod == 'Bulanan'
                                ? DateFormat('MMMM yyyy').format(_selectedDate)
                                : DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(_selectedDate),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isExporting ? null : _exportToExcel,
                      icon: _isExporting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download),
                      label: Text(
                        _isExporting ? 'Mengekspor...' : 'Download Laporan',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan $_selectedPeriod',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Jumlah Transaksi: ${filteredTransactions.length}'),
                    Text(
                      'Total Pendapatan: Rp ${filteredTransactions.fold(0.0, (sum, t) => sum + t.pendapatan).toStringAsFixed(0)}',
                    ),
                    Text(
                      'Total Keuntungan: Rp ${filteredTransactions.fold(0.0, (sum, t) => sum + t.keuntungan).toStringAsFixed(0)}',
                    ),
                    Text(
                      'Total Pengeluaran: Rp ${filteredTransactions.fold(0.0, (sum, t) => sum + t.pengeluaran).toStringAsFixed(0)}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Transaction List
            Expanded(
              child: filteredTransactions.isEmpty
                  ? const Center(
                      child: Text('Tidak ada transaksi untuk periode ini'),
                    )
                  : ListView.builder(
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final t = filteredTransactions[index];
                        return Card(
                          child: ListTile(
                            title: Text(t.deskripsi),
                            subtitle: Text(
                              '${DateFormat('dd/MM/yyyy HH:mm').format(t.tanggal)}\n'
                              'Pendapatan: Rp ${t.pendapatan.toStringAsFixed(0)}, '
                              'Keuntungan: Rp ${t.keuntungan.toStringAsFixed(0)}, '
                              'Pengeluaran: Rp ${t.pengeluaran.toStringAsFixed(0)}',
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
