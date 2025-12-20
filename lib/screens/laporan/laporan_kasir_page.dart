import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/pos_provider.dart';

class LaporanKasirPage extends StatelessWidget {
  const LaporanKasirPage({super.key});

  @override
  Widget build(BuildContext context) {
    final transaksi = context.watch<PosProvider>().transaksi;

    // Group by date
    Map<String, List<double>> dataPerTanggal = {};
    for (var t in transaksi) {
      final date = t.tanggal.toString().substring(0, 10);
      if (!dataPerTanggal.containsKey(date)) {
        dataPerTanggal[date] = [
          0,
          0,
          0,
        ]; // [pendapatan, keuntungan, pengeluaran]
      }
      dataPerTanggal[date]![0] += t.pendapatan;
      dataPerTanggal[date]![1] += t.keuntungan;
      dataPerTanggal[date]![2] += t.pengeluaran;
    }

    final sortedDates = dataPerTanggal.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Kasir'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performa Harian',
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
                            dataPerTanggal[entry.value]![0],
                          );
                        }).toList(),
                        isCurved: true,
                        color: Colors.blue,
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
                  itemCount: sortedDates.length,
                  itemBuilder: (context, index) {
                    final date = sortedDates[index];
                    final data = dataPerTanggal[date]!;
                    return Card(
                      child: ExpansionTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text('Tanggal: $date'),
                        subtitle: Text(
                          'Pendapatan: Rp ${data[0].toStringAsFixed(0)}',
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Keuntungan: Rp ${data[1].toStringAsFixed(0)}',
                                ),
                                Text(
                                  'Pengeluaran: Rp ${data[2].toStringAsFixed(0)}',
                                ),
                                Text(
                                  'Jumlah Transaksi: ${transaksi.where((t) => t.tanggal.toString().substring(0, 10) == date).length}',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              const Center(child: Text('Belum ada data transaksi')),
            ],
          ],
        ),
      ),
    );
  }
}
