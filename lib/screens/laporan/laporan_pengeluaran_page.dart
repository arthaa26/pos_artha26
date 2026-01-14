import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/pos_provider.dart';

class LaporanPengeluaranPage extends StatefulWidget {
  const LaporanPengeluaranPage({super.key});

  @override
  State<LaporanPengeluaranPage> createState() => _LaporanPengeluaranPageState();
}

class _LaporanPengeluaranPageState extends State<LaporanPengeluaranPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PosProvider>();
      if (provider.transaksi.isEmpty) {
        provider.loadTransaksi();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final transaksi = context.watch<PosProvider>().transaksi;

    // Filter transaksi pengeluaran
    final pengeluaran = transaksi.where((t) => t.pengeluaran > 0).toList();

    // Group by date
    Map<String, double> pengeluaranPerTanggal = {};
    for (var t in pengeluaran) {
      final date = t.tanggal.toString().substring(0, 10);
      pengeluaranPerTanggal[date] =
          (pengeluaranPerTanggal[date] ?? 0) + t.pengeluaran;
    }

    final sortedDates = pengeluaranPerTanggal.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Pengeluaran'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pengeluaran Harian',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (sortedDates.isNotEmpty) ...[
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() < sortedDates.length) {
                              return Text(
                                sortedDates[value.toInt()].substring(5),
                                style: const TextStyle(fontSize: 10),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: sortedDates.asMap().entries.map((entry) {
                          return FlSpot(
                            entry.key.toDouble(),
                            pengeluaranPerTanggal[entry.value]!,
                          );
                        }).toList(),
                        isCurved: true,
                        color: Colors.red,
                        barWidth: 3,
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: pengeluaran.length,
                  itemBuilder: (context, index) {
                    final t = pengeluaran[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.money_off, color: Colors.red),
                        title: Text(t.deskripsi),
                        subtitle: Text(t.tanggal.toString().substring(0, 16)),
                        trailing: Text(
                          'Rp ${t.pengeluaran.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              const Center(child: Text('Belum ada data pengeluaran')),
            ],
          ],
        ),
      ),
    );
  }
}
