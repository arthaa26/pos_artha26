import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io' if (kIsWeb) 'dart:html';
import 'package:permission_handler/permission_handler.dart'
    if (kIsWeb) 'dart:async';
import 'package:path_provider/path_provider.dart' if (kIsWeb) 'dart:async';
import 'package:device_info_plus/device_info_plus.dart' if (kIsWeb) 'dart:async';
import '../../providers/pos_provider.dart';
import '../../database/database.dart' if (kIsWeb) 'dart:async' as drift_db;
// import '../../services/file_permission_service.dart';

class ProdukPage extends StatefulWidget {
  const ProdukPage({super.key});

  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  XFile? _imageFile;

  // Search, Filter, Sort states
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'nama'; // nama, harga, stok
  bool _sortAscending = true;
  String _filterCategory = 'semua'; // semua, tersedia, habis

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PosProvider>().loadProduk();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  Future<void> _pickImage() async {
    try {
      // Request permissions for different Android versions
      PermissionStatus permissionStatus;

      if (Platform.isAndroid) {
        // For Android 13+ (API 33+), use READ_MEDIA_IMAGES
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        
        if (androidInfo.version.sdkInt >= 33) {
          // Android 13+: Use READ_MEDIA_IMAGES
          if (await Permission.photos.isGranted == false) {
            permissionStatus = await Permission.photos.request();
          } else {
            permissionStatus = PermissionStatus.granted;
          }
        } else {
          // Android 6-12: Use READ_EXTERNAL_STORAGE
          if (await Permission.storage.isGranted == false) {
            permissionStatus = await Permission.storage.request();
          } else {
            permissionStatus = PermissionStatus.granted;
          }
        }
      } else if (Platform.isIOS) {
        // For iOS
        permissionStatus = await Permission.photos.request();
      } else {
        permissionStatus = PermissionStatus.granted;
      }

      if (permissionStatus.isGranted) {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80, // Compress image to reduce size
        );
        if (image != null && mounted) {
          setState(() {
            _imageFile = image;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Izin akses galeri diperlukan untuk memilih gambar. Pergi ke Settings > Apps > POS Artha26 > Permissions',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $e')));
      }
    }
  }

  Future<String?> _uploadImage(XFile image) async {
    try {
      if (kDebugMode) print('📸 Starting image upload...');

      // Get app documents directory
      final Directory? appDir = await getApplicationDocumentsDirectory();
      
      if (appDir == null) {
        if (kDebugMode) print('❌ Cannot access app documents directory');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak dapat mengakses folder dokumentasi'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return null;
      }

      // Create filename with timestamp
      final String fileName = 'produk_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String fullPath = '${appDir.path}/$fileName';

      if (kDebugMode) print('📁 Target path: $fullPath');

      // Check if source file exists
      final sourceFile = File(image.path);
      if (!await sourceFile.exists()) {
        if (kDebugMode) print('❌ Source image file not found: ${image.path}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File gambar tidak ditemukan'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return null;
      }

      // Copy image file to app directory
      try {
        final File savedImage = await sourceFile.copy(fullPath);
        if (kDebugMode) print('✅ Image saved to: ${savedImage.path}');
        return savedImage.path;
      } catch (copyError) {
        if (kDebugMode) print('❌ Error copying file: $copyError');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan gambar: $copyError'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) print('❌ Image handling error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error menyimpan gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Produk',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        backgroundColor: Colors.grey[300],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () => context.read<PosProvider>().loadProduk(),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16, top: 20),
            child: Text(
              'V.0.1',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black54,
          indicator: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          tabs: const [
            Tab(icon: Icon(Icons.inventory_2, size: 20), text: 'Produk'),
            Tab(icon: Icon(Icons.trending_up, size: 20), text: 'Populer'),
          ],
        ),
      ),
      body: Column(
        children: [
          // --- Search Bar & Filter Section ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Cari produk...',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _buildActionIcon(Icons.filter_list, onTap: _showFilterDialog),
                const SizedBox(width: 10),
                _buildActionIcon(Icons.sort, onTap: _showSortDialog),
              ],
            ),
          ),

          // --- Product / Favorite Tabs ---
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Produk (all, filtered & sorted)
                _filteredAndSortedProduk.isEmpty
                    ? const Center(
                        child: Text('Tidak ada produk yang sesuai filter'),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: _buildCategorizedProductList(),
                      ),

                // Popular Products (top 5 by stok)
                Builder(
                  builder: (context) {
                    final popular = _filteredAndSortedProduk.take(5).toList();
                    if (popular.isEmpty) {
                      return const Center(child: Text('Belum ada produk'));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: popular.length,
                      itemBuilder: (context, index) {
                        final p = popular[index];
                        return _buildProductItem(p);
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          // --- Bottom Button ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _showProdukDialog(context),
                child: const Text('Tambah produk'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: Colors.black54),
      ),
    );
  }

  List<dynamic> get _filteredAndSortedProduk {
    final produkList = context.watch<PosProvider>().produk;
    List<dynamic> filtered = produkList.where((produk) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final matchesSearch =
            produk.nama.toLowerCase().contains(_searchQuery) ||
            (produk.deskripsi?.toLowerCase().contains(_searchQuery) ?? false);
        if (!matchesSearch) return false;
      }

      // Category filter
      switch (_filterCategory) {
        case 'tersedia':
          return produk.stok > 0;
        case 'habis':
          return produk.stok == 0;
        default:
          return true;
      }
    }).toList();

    // Sort
    filtered.sort((a, b) {
      int compareResult;
      switch (_sortBy) {
        case 'harga':
          compareResult = a.harga.compareTo(b.harga);
          break;
        case 'stok':
          compareResult = a.stok.compareTo(b.stok);
          break;
        default: // nama
          compareResult = a.nama.compareTo(b.nama);
      }
      return _sortAscending ? compareResult : -compareResult;
    });

    return filtered;
  }

  List<Widget> _buildCategorizedProductList() {
    final Map<String, List<drift_db.Produk>> categorizedProducts = {
      'Makanan': [],
      'Minuman': [],
      'Cemilan': [],
      'Lainnya': [],
    };

    // Group products by category - normalize kategori names
    for (final produk in _filteredAndSortedProduk) {
      final kategori =
          produk.kategori ?? 'Makanan'; // Default to Makanan if null
      String normalizedKategori;

      // Normalize old kategori names to new format
      switch (kategori) {
        case 'food':
          normalizedKategori = 'Makanan';
          break;
        case 'drinks':
          normalizedKategori = 'Minuman';
          break;
        case 'snacks':
          normalizedKategori = 'Cemilan';
          break;
        default:
          normalizedKategori = kategori;
      }

      if (categorizedProducts.containsKey(normalizedKategori)) {
        categorizedProducts[normalizedKategori]!.add(produk);
      } else {
        categorizedProducts['Lainnya']!.add(produk); // Fallback to Lainnya
      }
    }

    final List<Widget> widgets = [];

    // Create ExpansionTile for each category (always show all categories)
    final categoryOrder = [
      'Makanan',
      'Minuman',
      'Cemilan',
      'Lainnya',
    ];
    for (final kategori in categoryOrder) {
      final produkList = categorizedProducts[kategori]!;
      final kategoriName = _getKategoriDisplayName(kategori);
      widgets.add(
        ExpansionTile(
          title: Text(
            kategoriName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          initiallyExpanded: true, // Expand all by default
          children: produkList.isEmpty
              ? [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Belum ada produk di kategori ini',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ]
              : produkList.map((produk) => _buildProductItem(produk)).toList(),
        ),
      );
    }

    return widgets;
  }

  Widget _buildProductImage(String imagePath) {
    try {
      if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
        // Network image
        return Image.network(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.broken_image, color: Colors.grey);
          },
        );
      } else {
        // Local file
        final file = File(imagePath);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.broken_image, color: Colors.grey);
            },
          );
        } else {
          return const Icon(Icons.image_not_supported, color: Colors.grey);
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error loading image: $e');
      return const Icon(Icons.image_not_supported, color: Colors.grey);
    }
  }

  String _getKategoriDisplayName(String kategori) {
    switch (kategori) {
      case 'Makanan':
      case 'food':
        return 'Makanan';
      case 'Minuman':
      case 'drinks':
        return 'Minuman';
      case 'Cemilan':
      case 'snacks':
        return 'Cemilan';
      case 'Lainnya':
        return 'Lainnya';
      default:
        return kategori;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Semua Produk'),
                value: 'semua',
                groupValue: _filterCategory,
                onChanged: (value) {
                  setState(() => _filterCategory = value!);
                },
              ),
              RadioListTile<String>(
                title: const Text('Tersedia (Stok > 0)'),
                value: 'tersedia',
                groupValue: _filterCategory,
                onChanged: (value) {
                  setState(() => _filterCategory = value!);
                },
              ),
              RadioListTile<String>(
                title: const Text('Habis (Stok = 0)'),
                value: 'habis',
                groupValue: _filterCategory,
                onChanged: (value) {
                  setState(() => _filterCategory = value!);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                this.setState(() {}); // Trigger rebuild
              },
              child: const Text('Terapkan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Urutkan Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Nama'),
                value: 'nama',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() => _sortBy = value!);
                },
              ),
              RadioListTile<String>(
                title: const Text('Harga'),
                value: 'harga',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() => _sortBy = value!);
                },
              ),
              RadioListTile<String>(
                title: const Text('Stok'),
                value: 'stok',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() => _sortBy = value!);
                },
              ),
              const Divider(),
              CheckboxListTile(
                title: const Text('Urutkan Naik'),
                value: _sortAscending,
                onChanged: (value) {
                  setState(() => _sortAscending = value!);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                this.setState(() {}); // Trigger rebuild
              },
              child: const Text('Terapkan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(drift_db.Produk p) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey[100],
                child: (p.gambar ?? '').isNotEmpty
                    ? _buildProductImage(p.gambar!)
                    : const Icon(Icons.image, size: 40, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.nama,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      // Delete icon
                      IconButton(
                        onPressed: () async {
                          try {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Hapus Produk'),
                                content: const Text(
                                  'Yakin ingin menghapus produk ini?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Batal'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              try {
                                // ignore: use_build_context_synchronously
                                await context.read<PosProvider>().deleteProduk(
                                  p.id,
                                );
                                if (mounted) {
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Produk berhasil dihapus'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Gagal: $e')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.deskripsi ?? 'Tanpa deskripsi',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rp ${NumberFormat('#,###', 'id_ID').format(p.harga)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: p.stok > 0 ? Colors.green[50] : Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          p.stok > 0 ? 'Stok ${p.stok}' : 'Habis',
                          style: TextStyle(
                            color: p.stok > 0
                                ? Colors.green[800]
                                : Colors.red[800],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            Column(
              children: [
                IconButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Hapus Produk'),
                        content: const Text(
                          'Apakah Anda yakin ingin menghapus produk ini?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Hapus'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      try {
                        // ignore: use_build_context_synchronously
                        await context.read<PosProvider>().deleteProduk(p.id);
                        if (mounted) {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Produk berhasil dihapus'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      }
                    }
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
                IconButton(
                  onPressed: () => _showProdukDialog(context, produk: p),
                  icon: const Icon(Icons.edit, color: Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProdukDialog(BuildContext context, {drift_db.Produk? produk}) {
    final isEditing = produk != null;
    final formKey = GlobalKey<FormState>();

    final namaController = TextEditingController(text: produk?.nama ?? '');
    final hargaController = TextEditingController(
      text: produk?.harga.toString() ?? '',
    );
    final hargaModalController = TextEditingController(
      text: produk?.hargaBeli?.toString() ?? '',
    );
    final stokController = TextEditingController(
      text: produk?.stok.toString() ?? '',
    );
    final stokMinimalController = TextEditingController(text: '');
    final deskripsiController = TextEditingController(
      text: produk?.deskripsi ?? '',
    );
    String? selectedKategori = produk?.kategori ?? 'Makanan';
    final List<String> kategoriOptions = [
      'Makanan',
      'Minuman',
      'Cemilan',
      'Lainnya',
    ];
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isEditing ? 'Edit Produk' : 'Tambah Produk'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image picker section - with better styling
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          await _pickImage();
                          setState(() {});
                        },
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue[300]!,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _imageFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(_imageFile!.path),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : (produk?.gambar ?? '').isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(produk!.gambar ?? ''),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 48,
                                      color: Colors.blue[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Pilih Foto',
                                      style: TextStyle(
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Name field
                    TextFormField(
                      controller: namaController,
                      decoration: InputDecoration(
                        labelText: 'Nama Produk',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.shopping_bag),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Nama produk harus diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Price field
                    TextFormField(
                      controller: hargaController,
                      decoration: InputDecoration(
                        labelText: 'Harga Jual',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.attach_money),
                        filled: true,
                        fillColor: Colors.grey[50],
                        hintText: '10000',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Harga harus diisi';
                        }
                        if (int.tryParse(value!) == null) {
                          return 'Harga harus berupa angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Harga Modal field
                    TextFormField(
                      controller: hargaModalController,
                      decoration: InputDecoration(
                        labelText: 'Harga Modal (Opsional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.point_of_sale),
                        filled: true,
                        fillColor: Colors.grey[50],
                        hintText: '5000',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Stock field
                    TextFormField(
                      controller: stokController,
                      decoration: InputDecoration(
                        labelText: 'Stok',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.inventory),
                        filled: true,
                        fillColor: Colors.grey[50],
                        hintText: '10',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Stok harus diisi';
                        }
                        if (int.tryParse(value!) == null) {
                          return 'Stok harus berupa angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Stok Minimal field
                    TextFormField(
                      controller: stokMinimalController,
                      decoration: InputDecoration(
                        labelText: 'Stok Minimal (Opsional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.warning_amber),
                        filled: true,
                        fillColor: Colors.grey[50],
                        hintText: '5',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Description field
                    TextFormField(
                      controller: deskripsiController,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi (Opsional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.description),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Category field
                    DropdownButtonFormField<String>(
                      initialValue: selectedKategori,
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.category),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: kategoriOptions
                          .map(
                            (kategori) => DropdownMenuItem(
                              value: kategori,
                              child: Text(_getKategoriDisplayName(kategori)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => selectedKategori = value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kategori harus dipilih';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) {
                    if (kDebugMode) print('❌ Form validation failed');
                    return;
                  }

                  try {
                    if (kDebugMode) print('🔄 Starting product save...');
                    
                    String? imageUrl = produk?.gambar ?? '';

                    // Upload image if selected
                    if (_imageFile != null) {
                      if (kDebugMode) print('📸 Uploading image...');
                      imageUrl = await _uploadImage(_imageFile!);
                      if (imageUrl == null) {
                        if (kDebugMode) print('❌ Image upload failed');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gagal upload gambar - cek permission dan storage'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                        return;
                      }
                      if (kDebugMode) print('✅ Image uploaded to: $imageUrl');
                    }

                    // Parse form values with validation
                    if (kDebugMode) print('📝 Parsing form values...');
                    
                    final nama = namaController.text.trim();
                    if (nama.isEmpty) {
                      throw ArgumentError('Nama produk tidak boleh kosong');
                    }

                    final hargaStr = hargaController.text.trim();
                    if (hargaStr.isEmpty) {
                      throw ArgumentError('Harga tidak boleh kosong');
                    }
                    
                    final harga = int.tryParse(hargaStr);
                    if (harga == null || harga <= 0) {
                      throw ArgumentError('Harga harus angka positif');
                    }

                    final hargaBeli = hargaModalController.text.isNotEmpty
                        ? int.tryParse(hargaModalController.text) ?? 0
                        : 0;
                    if (hargaBeli < 0) {
                      throw ArgumentError('Harga beli tidak boleh negatif');
                    }

                    final stokStr = stokController.text.trim();
                    if (stokStr.isEmpty) {
                      throw ArgumentError('Stok tidak boleh kosong');
                    }
                    
                    final stok = int.tryParse(stokStr);
                    if (stok == null || stok < 0) {
                      throw ArgumentError('Stok harus angka positif');
                    }

                    final deskripsi = deskripsiController.text.trim();

                    if (kDebugMode) {
                      print('📦 Product data:');
                      print('   Nama: $nama');
                      print('   Harga: $harga');
                      print('   Kategori: $selectedKategori');
                      print('   Stok: $stok');
                    }

                    // Create Produk object
                    final newProduk = drift_db.Produk(
                      id: isEditing ? produk.id : 0,
                      nama: nama,
                      harga: harga.toDouble(),
                      hargaBeli: hargaBeli.toDouble(),
                      stok: stok,
                      kategori: selectedKategori ?? 'Lainnya',
                      deskripsi: deskripsi.isEmpty ? null : deskripsi,
                      gambar: imageUrl.isEmpty ? null : imageUrl,
                      barcode: produk?.barcode,
                      aktif: produk?.aktif ?? true,
                      satuan: produk?.satuan ?? 'pcs',
                      createdAt: produk?.createdAt ?? DateTime.now(),
                      updatedAt: DateTime.now(),
                    );

                    // Save to database
                    if (isEditing) {
                      if (kDebugMode) print('✏️ Updating product...');
                      // ignore: use_build_context_synchronously
                      await context.read<PosProvider>().updateProduk(
                        produk.id,
                        newProduk,
                      );
                      if (kDebugMode) print('✅ Product updated');
                    } else {
                      if (kDebugMode) print('➕ Adding new product...');
                      // ignore: use_build_context_synchronously
                      await context.read<PosProvider>().addProduk(newProduk);
                      if (kDebugMode) print('✅ Product added');
                    }

                    if (mounted) {
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                      _imageFile = null; // Reset image

                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing
                                ? 'Produk berhasil diupdate'
                                : 'Produk berhasil ditambahkan',
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  } on ArgumentError catch (e) {
                    if (kDebugMode) print('❌ Validation error: $e');
                    if (mounted) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Validasi error: ${e.message}'),
                          backgroundColor: Colors.orange,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  } catch (e, st) {
                    if (kDebugMode) {
                      print('❌ Error saving product: $e');
                      print('Stack: $st');
                    }
                    if (mounted) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Gagal menyimpan: $e'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                },
                child: Text(isEditing ? 'Update' : 'Tambah'),
              ),
            ],
          );
        },
      ),
    );
  }
}
