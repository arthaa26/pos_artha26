import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pos_provider.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Consumer<PosProvider>(
          builder: (context, provider, _) {
            final settings = provider.settings;
            return Column(
              children: [
                // Toko Info
                Container(
                  color: Colors.blue[50],
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Toko',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSettingCard(
                        icon: Icons.store,
                        label: 'Nama Toko',
                        value: settings.storeName,
                        onTap: () {
                          Navigator.pushNamed(context, '/edit_profile');
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildSettingCard(
                        icon: Icons.location_on,
                        label: 'Alamat',
                        value: settings.storeAddress,
                        onTap: () {
                          Navigator.pushNamed(context, '/edit_profile');
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildSettingCard(
                        icon: Icons.phone,
                        label: 'No. Telepon',
                        value: settings.storePhone,
                        onTap: () {
                          Navigator.pushNamed(context, '/edit_profile');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Pengaturan Transaksi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pengaturan Transaksi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSettingCard(
                              icon: Icons.percent,
                              label: 'PPN',
                              value:
                                  '${(settings.ppnRate * 100).toStringAsFixed(1)}%',
                              onTap: () {
                                Navigator.pushNamed(context, '/edit_profile');
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSettingCard(
                              icon: Icons.trending_up,
                              label: 'HPP/Margin',
                              value:
                                  '${(settings.hppMargin * 100).toStringAsFixed(1)}%',
                              onTap: () {
                                Navigator.pushNamed(context, '/edit_profile');
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Database Settings
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Database',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.backup),
                            title: const Text('Backup Database'),
                            subtitle: const Text('Unduh backup database Anda'),
                            trailing: const Icon(Icons.download),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Fitur backup sedang dikembangkan',
                                  ),
                                ),
                              );
                            },
                          ),
                          const Divider(),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.refresh),
                            title: const Text('Refresh Data'),
                            subtitle: const Text('Muat ulang semua data'),
                            trailing: const Icon(Icons.sync),
                            onTap: () {
                              provider.loadProduk();
                              provider.loadTransaksi();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Data berhasil dimuat ulang'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Notifikasi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notifikasi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.notifications),
                        title: const Text('Notifikasi Stok'),
                        subtitle: const Text('Aktifkan notifikasi stok rendah'),
                        trailing: Switch(
                          value: true,
                          onChanged: (value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  value
                                      ? 'Notifikasi stok diaktifkan'
                                      : 'Notifikasi stok dinonaktifkan',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.notifications_active),
                        title: const Text('Notifikasi Transaksi'),
                        subtitle: const Text(
                          'Aktifkan notifikasi untuk setiap transaksi',
                        ),
                        trailing: Switch(
                          value: false,
                          onChanged: (value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  value
                                      ? 'Notifikasi transaksi diaktifkan'
                                      : 'Notifikasi transaksi dinonaktifkan',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tentang
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tentang',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.info),
                        title: const Text('Versi Aplikasi'),
                        trailing: const Text(
                          'v1.0.0',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.person),
                        title: const Text('Pengembang'),
                        trailing: const Text(
                          'Artha26',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        trailing: const Icon(Icons.edit, size: 18, color: Colors.blue),
        onTap: onTap,
      ),
    );
  }
}
