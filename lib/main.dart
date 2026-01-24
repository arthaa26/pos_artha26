import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io' show File if (kIsWeb) 'dart:html';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/register_page.dart';
import 'screens/kasir/kasir_page.dart';
import 'screens/produk/produk_page.dart';
import 'screens/pengeluaran/pengeluaran_page.dart';
import 'screens/laporan/laporan_page.dart';
import 'screens/riwayat/riwayat_page.dart';
import 'screens/pengaturan/pengaturan_page.dart';
import 'screens/pengaturan/keamanan_page.dart';
import 'screens/settings/printer_settings_page.dart';
import 'screens/struk/struk_page.dart';
import 'screens/pengaturan/edit_profile_page.dart';
import 'screens/web_unsupported_page.dart';
import 'providers/pos_provider.dart';
import 'services/database_service.dart';
import 'services/local_api_service.dart';
import 'services/file_permission_service.dart';

/// Helper function to load image from file path, with fallback for web
Widget loadImageFromPath(String? path, {double? height, double? width, BoxFit fit = BoxFit.cover}) {
  if (path == null || path.isEmpty) {
    return Image.asset('assets/placeholder.png', height: height, width: width, fit: fit);
  }
  
  if (kIsWeb) {
    // Web: use network or asset image
    return Image.asset('assets/placeholder.png', height: height, width: width, fit: fit);
  }
  
  // Native: use file image
  try {
    return Image.file(File(path), height: height, width: width, fit: fit);
  } catch (_) {
    return Image.asset('assets/placeholder.png', height: height, width: width, fit: fit);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);

  // Check if running on web
  if (kIsWeb) {
    if (kDebugMode) print('⚠️ Running on web platform - not fully supported');
    runApp(const MyApp());
    return;
  }

  // Request storage permissions for real device
  if (kDebugMode) print('🔐 Requesting storage permissions...');
  final fileService = FilePermissionService();
  final permissionGranted = await fileService.requestStoragePermissions();
  if (kDebugMode) {
    print(permissionGranted
        ? '✅ Storage permissions granted'
        : '⚠️ Storage permissions denied');
  }

  // Initialize Drift database (native only)
  try {
    if (kDebugMode) print('🔄 Starting database initialization...');
    await DatabaseService.initialize();
    if (kDebugMode) print('✅ Database initialized successfully');

    if (kDebugMode) print('🔄 Initializing API Service...');
    final dbInstance = DatabaseService.instance;
    if (kDebugMode) print('✅ Database instance obtained');
    
    LocalApiService().initialize(dbInstance);
    if (kDebugMode) print('✅ API Service initialized successfully');
    
    // Test database connectivity
    try {
      final testData = await LocalApiService().getProduk();
      if (kDebugMode) print('✅ Database test: Found ${testData.length} products');
    } catch (testError) {
      if (kDebugMode) print('⚠️ Database test failed (may be empty): $testError');
    }
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('❌ Database initialization failed: $e');
      print('Stack trace: $stackTrace');
    }
  }

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => PosProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Show unsupported message on web
    if (kIsWeb) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
        home: const WebUnsupportedPage(),
      );
    }

    // Normal app for native platforms
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const DashboardPage(),
        '/kasir': (context) => const KasirPage(),
        '/produk': (context) => const ProdukPage(),
        '/laporan': (context) => const LaporanPage(),
        '/riwayat': (context) => const RiwayatPage(),
        '/printer-settings': (context) => const PrinterSettingsPage(),
        '/settings': (context) => const PengaturanPage(),
        '/keamanan': (context) => const KeamananPage(),
        '/struk': (context) => const StrukPage(),
        '/edit_profile': (context) => const EditProfilePage(),
      },
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PosProvider>().loadSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Consumer<PosProvider>(
          builder: (context, provider, child) {
            final path = provider.settings.storeLogoPath;
            if (path.isNotEmpty) {
              try {
                return loadImageFromPath(path, height: 36);
              } catch (_) {
                return Text(
                  provider.settings.storeName,
                  style: const TextStyle(fontSize: 16),
                );
              }
            }
            return Text(
              provider.settings.storeName,
              style: const TextStyle(fontSize: 16),
            );
          },
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(child: Text("V.0.1")),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.blue[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Consumer<PosProvider>(
                builder: (context, provider, child) {
                  final settings = provider.settings;
                  return Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: settings.storeLogoPath.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: loadImageFromPath(settings.storeLogoPath, fit: BoxFit.cover),
                              )
                            : Icon(
                                Icons.store,
                                size: 30,
                                color: Colors.blue[700],
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              settings.storeName.isNotEmpty
                                  ? settings.storeName
                                  : 'POS Artha26',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Point of Sale System',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.blue),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                // Already on dashboard, no navigation needed
              },
            ),
            ListTile(
              leading: const Icon(Icons.point_of_sale, color: Colors.blue),
              title: const Text('Kasir'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.pushNamed(context, '/kasir');
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2, color: Colors.blue),
              title: const Text('Produk'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.pushNamed(context, '/produk');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.blue),
              title: const Text('Laporan'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.pushNamed(context, '/laporan');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.blue),
              title: const Text('Riwayat'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.pushNamed(context, '/riwayat');
              },
            ),
            ListTile(
              leading: const Icon(Icons.print, color: Colors.blue),
              title: const Text('🖨️ Printer'),
              subtitle: const Text('Kelola Printer'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.pushNamed(context, '/printer-settings');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text('Pengaturan'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.security, color: Colors.grey),
              title: const Text('Keamanan'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.pushNamed(context, '/keamanan');
              },
            ),
          ],
        ),
      ),
      // LayoutBuilder mendeteksi perubahan ukuran layar secara real-time
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Tentukan apakah ini tablet atau bukan (breakpoint 600px)
          bool isTablet = constraints.maxWidth > 600;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 32.0 : 16.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Section Profil Toko ---
                Consumer<PosProvider>(
                  builder: (context, provider, child) {
                    final settings = provider.settings;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[600]!, Colors.blue[400]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.3),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Logo Toko
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: settings.storeLogoPath.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: loadImageFromPath(settings.storeLogoPath, fit: BoxFit.cover),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.store,
                                      size: 40,
                                      color: Colors.blue,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          // Informasi Toko
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  settings.storeName.isNotEmpty
                                      ? settings.storeName
                                      : 'TOKO ARTHA26',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (settings.storeAddress.isNotEmpty)
                                  Text(
                                    settings.storeAddress,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const SizedBox(height: 8),
                                // Menu Cepat
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildQuickActionButton(
                                      "Kasir",
                                      Icons.point_of_sale,
                                      () => Navigator.pushNamed(
                                        context,
                                        '/kasir',
                                      ),
                                    ),
                                    _buildQuickActionButton(
                                      "Produk",
                                      Icons.inventory_2,
                                      () => Navigator.pushNamed(
                                        context,
                                        '/produk',
                                      ),
                                    ),
                                    _buildQuickActionButton(
                                      "Edit Profil",
                                      Icons.edit,
                                      () => Navigator.pushNamed(
                                        context,
                                        '/edit_profile',
                                      ),
                                    ),
                                    _buildQuickActionButton(
                                      "Laporan",
                                      Icons.bar_chart,
                                      () => Navigator.pushNamed(
                                        context,
                                        '/laporan',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // --- Section Laporan Pendapatan ---
                _buildHeaderSection("Laporan Pendapatan Hari Ini"),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  // Jika tablet 4 kolom, jika HP 2 kolom
                  crossAxisCount: isTablet ? 4 : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: isTablet ? 2.0 : 1.5,
                  children: [
                    _buildSummaryCard(
                      "Pendapatan",
                      "Rp ${context.watch<PosProvider>().summary?.totalPendapatan.toStringAsFixed(0) ?? "0"}",
                      Colors.grey[300]!,
                    ),
                    _buildSummaryCard(
                      "Keuntungan",
                      "Rp ${context.watch<PosProvider>().summary?.totalKeuntungan.toStringAsFixed(0) ?? "0"}",
                      Colors.grey[300]!,
                    ),
                    _buildSummaryCard(
                      "Transaksi",
                      context
                              .watch<PosProvider>()
                              .summary
                              ?.totalTransaksi
                              .toString() ??
                          "0",
                      Colors.grey[300]!,
                    ),
                    _buildSummaryCard(
                      "Pengeluaran",
                      "Rp ${context.watch<PosProvider>().summary?.totalPengeluaran.toStringAsFixed(0) ?? "0"}",
                      Colors.grey[300]!,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // --- Section Menu Utama ---
                const Text(
                  "Menu Utama",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  // Grid 3 kolom (3 kotak per baris)
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildMenuButton("Kasir", Icons.point_of_sale),
                    _buildMenuButton("Produk", Icons.inventory_2),
                    _buildMenuButton("Pengeluaran", Icons.outbox),
                    _buildMenuButton("Laporan", Icons.bar_chart),
                    _buildMenuButton("Riwayat", Icons.history),
                    _buildMenuButton("Struk", Icons.receipt),
                    _buildMenuButton("Keamanan", Icons.security),
                    _buildMenuButton("Pengaturan", Icons.settings),
                  ],
                ),

                const SizedBox(height: 30),

                // --- Section Produk Pilihan ---
                const Text(
                  "Produk Terbaru",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),
                Consumer<PosProvider>(
                  builder: (context, provider, child) {
                    final allProducts = provider.produk;
                    // Show first 4 products
                    final topProducts = allProducts.take(4).toList();
                    if (topProducts.isEmpty) {
                      return Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Center(
                          child: Text(
                            "Belum ada produk",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }
                    return SizedBox(
                      height: 140,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: topProducts.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemBuilder: (context, index) {
                          final p = topProducts[index];
                          return Container(
                            width: 140,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: (p.gambar ?? '').isNotEmpty
                                        ? loadImageFromPath(p.gambar, width: double.infinity, fit: BoxFit.cover)
                                        : Container(color: Colors.grey[200]),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  p.nama,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Rp ${NumberFormat('#,###', 'id_ID').format(p.harga.toInt())}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget Helper untuk Header Section
  Widget _buildHeaderSection(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        IconButton(
          onPressed: () {
            context.read<PosProvider>().loadSummary();
          },
          icon: const Icon(Icons.refresh),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  // Widget untuk Kartu Laporan (Atas)
  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
    );
  }

  // Widget untuk Tombol Menu (Tengah)
  Widget _buildMenuButton(String label, IconData icon) {
    return GestureDetector(
      onTap: () {
        switch (label) {
          case 'Kasir':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const KasirPage()),
            );
            break;
          case 'Produk':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProdukPage()),
            );
            break;
          case 'Pengeluaran':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PengeluaranPage()),
            );
            break;
          case 'Laporan':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LaporanPage()),
            );
            break;
          case 'Riwayat':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RiwayatPage()),
            );
            break;
          case 'Struk':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StrukPage()),
            );
            break;
          case 'Keamanan':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const KeamananPage()),
            );
            break;
          case 'Pengaturan':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PengaturanPage()),
            );
            break;
        }
      },
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 32, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.blue[700]),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
