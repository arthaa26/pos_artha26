import 'package:flutter/material.dart';
import 'laporan_produk_terjual_page.dart';
import 'laporan_stok_produk_page.dart';
import 'laporan_pengeluaran_page.dart';
import 'laporan_kasir_page.dart';
import 'laporan_metode_pembayaran_page.dart';
import 'laporan_transaksi_page.dart';
import 'export_data_page.dart';

class LaporanPage extends StatelessWidget {
  const LaporanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Laporan'),
        backgroundColor: Colors.grey[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildReportCard(
              context,
              'Produk Terjual',
              Icons.shopping_cart,
              Colors.blue,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LaporanProdukTerjualPage(),
                ),
              ),
            ),
            _buildReportCard(
              context,
              'Stok Produk',
              Icons.inventory,
              Colors.green,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LaporanStokProdukPage(),
                ),
              ),
            ),
            _buildReportCard(
              context,
              'Pengeluaran',
              Icons.money_off,
              Colors.red,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LaporanPengeluaranPage(),
                ),
              ),
            ),
            _buildReportCard(
              context,
              'Kasir',
              Icons.point_of_sale,
              Colors.orange,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LaporanKasirPage()),
              ),
            ),
            _buildReportCard(
              context,
              'Metode Pembayaran',
              Icons.payment,
              Colors.purple,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LaporanMetodePembayaranPage(),
                ),
              ),
            ),
            _buildReportCard(
              context,
              'Laporan Transaksi',
              Icons.receipt_long,
              Colors.cyan,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LaporanTransaksiPage()),
              ),
            ),
            _buildReportCard(
              context,
              'Export Data',
              Icons.download,
              Colors.teal,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExportDataPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
