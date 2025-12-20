import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/pos_provider.dart';

class LaporanStokProdukPage extends StatelessWidget {
  const LaporanStokProdukPage({super.key});

  @override
  Widget build(BuildContext context) {
    final produk = context.watch<PosProvider>().produk;

    // Sort produk by stok
    final sortedProduk = produk.toList()
      ..sort((a, b) => b.stok.compareTo(a.stok));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Stok Produk'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stok Produk',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (sortedProduk.isNotEmpty) ...[
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: sortedProduk.first.stok.toDouble() + 10,
                    barGroups: sortedProduk.take(5).map((p) {
                      return BarChartGroupData(
                        x: sortedProduk.indexOf(p),
                        barRods: [
                          BarChartRodData(
                            toY: p.stok.toDouble(),
                            color: p.stok < 10 ? Colors.red : Colors.green,
                          ),
                        ],
                      );
                    }).toList(),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() < sortedProduk.length) {
                              return Text(
                                sortedProduk[value.toInt()].nama,
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
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: sortedProduk.length,
                  itemBuilder: (context, index) {
                    final p = sortedProduk[index];
                    return Card(
                      child: ListTile(
                        leading: p.stok < 10
                            ? const Icon(Icons.warning, color: Colors.red)
                            : const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                        title: Text(p.nama),
                        subtitle: Text(
                          'Harga: Rp ${p.harga.toStringAsFixed(0)}',
                        ),
                        trailing: Text(
                          'Stok: ${p.stok}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: p.stok < 10 ? Colors.red : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              const Center(child: Text('Belum ada data produk')),
            ],
          ],
        ),
      ),
    );
  }
}
