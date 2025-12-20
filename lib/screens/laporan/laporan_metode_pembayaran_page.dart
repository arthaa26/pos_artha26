import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/pos_provider.dart';

class LaporanMetodePembayaranPage extends StatelessWidget {
  const LaporanMetodePembayaranPage({super.key});

  @override
  Widget build(BuildContext context) {
    final transaksi = context.watch<PosProvider>().transaksi;

    // Count payment methods
    Map<String, int> metodeCount = {};
    Map<String, double> metodeTotal = {};

    for (var t in transaksi) {
      // Extract payment method from description
      final desc = t.deskripsi;
      final parts = desc.split(' - ');
      if (parts.length > 1) {
        final metode = parts.last;
        metodeCount[metode] = (metodeCount[metode] ?? 0) + 1;
        metodeTotal[metode] = (metodeTotal[metode] ?? 0) + t.pendapatan;
      }
    }

    final sortedMetode = metodeCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Metode Pembayaran'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribusi Metode Pembayaran',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (sortedMetode.isNotEmpty) ...[
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: sortedMetode.map((entry) {
                      final colors = [
                        Colors.blue,
                        Colors.green,
                        Colors.red,
                        Colors.orange,
                        Colors.purple,
                      ];
                      final color =
                          colors[sortedMetode.indexOf(entry) % colors.length];
                      return PieChartSectionData(
                        value: entry.value.toDouble(),
                        title: '${entry.key}\n${entry.value}',
                        color: color,
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: sortedMetode.length,
                  itemBuilder: (context, index) {
                    final entry = sortedMetode[index];
                    final total = metodeTotal[entry.key] ?? 0;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(entry.key),
                        subtitle: Text('${entry.value} transaksi'),
                        trailing: Text(
                          'Rp ${total.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              const Center(child: Text('Belum ada data pembayaran')),
            ],
          ],
        ),
      ),
    );
  }
}
