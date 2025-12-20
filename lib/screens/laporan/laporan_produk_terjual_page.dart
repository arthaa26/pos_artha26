import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/pos_provider.dart';

class LaporanProdukTerjualPage extends StatelessWidget {
  const LaporanProdukTerjualPage({super.key});

  @override
  Widget build(BuildContext context) {
    final transaksi = context.watch<PosProvider>().transaksi;

    // Hitung produk terjual dari deskripsi transaksi
    Map<String, int> produkTerjual = {};
    for (var t in transaksi) {
      // Parse deskripsi seperti "Penjualan: Produk A x2, Produk B x1 - Tunai"
      final desc = t.deskripsi;
      if (desc.startsWith('Penjualan:')) {
        final items = desc.split(' - ')[0].replaceFirst('Penjualan: ', '');
        final itemList = items.split(', ');
        for (var item in itemList) {
          final parts = item.split(' x');
          if (parts.length == 2) {
            final nama = parts[0];
            final qty = int.tryParse(parts[1]) ?? 0;
            produkTerjual[nama] = (produkTerjual[nama] ?? 0) + qty;
          }
        }
      }
    }

    final sortedProduk = produkTerjual.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Produk Terjual'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Produk Terlaris',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (sortedProduk.isNotEmpty) ...[
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: sortedProduk.first.value.toDouble() + 5,
                    barGroups: sortedProduk.take(5).map((entry) {
                      return BarChartGroupData(
                        x: sortedProduk.indexOf(entry),
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.toDouble(),
                            color: Colors.blue,
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
                                sortedProduk[value.toInt()].key,
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
                    final entry = sortedProduk[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(entry.key),
                        trailing: Text(
                          '${entry.value} terjual',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              const Center(child: Text('Belum ada data penjualan')),
            ],
          ],
        ),
      ),
    );
  }
}
