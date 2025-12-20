import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import '../../models/produk.dart';
import '../../providers/pos_provider.dart';
import '../../services/network_config.dart';

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
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() {
          _imageFile = image;
        });
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
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${getBaseUrl()}/upload'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('gambar', image.path),
      );

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        return jsonResponse['url'];
      } else {
        return null;
      }
    } catch (e) {
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
            Tab(icon: Icon(Icons.favorite, size: 20), text: 'Favorit'),
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

                // Favorit (only favorites from the filtered list)
                Builder(
                  builder: (context) {
                    final favs = _filteredAndSortedProduk
                        .where((p) => p.favorite)
                        .toList();
                    if (favs.isEmpty) {
                      return const Center(
                        child: Text('Belum ada produk favorit'),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: favs.length,
                      itemBuilder: (context, index) {
                        final p = favs[index];
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

  List<Produk> get _filteredAndSortedProduk {
    final produkList = context.watch<PosProvider>().produk;
    List<Produk> filtered = produkList.where((produk) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final matchesSearch =
            produk.nama.toLowerCase().contains(_searchQuery) ||
            produk.deskripsi.toLowerCase().contains(_searchQuery);
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
    final Map<String, List<Produk>> categorizedProducts = {
      'food': [],
      'drinks': [],
      'snacks': [],
    };

    // Group products by category
    for (final produk in _filteredAndSortedProduk) {
      final kategori = produk.kategori ?? 'food'; // Default to food if null
      if (categorizedProducts.containsKey(kategori)) {
        categorizedProducts[kategori]!.add(produk);
      } else {
        categorizedProducts['food']!.add(produk); // Fallback
      }
    }

    final List<Widget> widgets = [];

    // Create ExpansionTile for each category (always show all categories)
    final categoryOrder = ['food', 'drinks', 'snacks'];
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

  String _getKategoriDisplayName(String kategori) {
    switch (kategori) {
      case 'food':
        return 'Makanan';
      case 'drinks':
        return 'Minuman';
      case 'snacks':
        return 'Cemilan';
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

  Widget _buildProductItem(Produk p) {
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
                child: p.gambar.isNotEmpty
                    ? Image.network(p.gambar, fit: BoxFit.cover)
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
                      // Favorite icon
                      IconButton(
                        onPressed: () async {
                          if (p.id == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Simpan produk terlebih dahulu sebelum menandai favorit',
                                ),
                              ),
                            );
                            return;
                          }
                          await context.read<PosProvider>().toggleFavorite(
                            p.id!,
                          );
                        },
                        icon: Icon(
                          p.favorite ? Icons.favorite : Icons.favorite_border,
                          color: p.favorite ? Colors.red : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.deskripsi,
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
                        await context.read<PosProvider>().deleteProduk(p.id!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Produk berhasil dihapus'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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

  void _showProdukDialog(BuildContext context, {Produk? produk}) {
    final isEditing = produk != null;
    final formKey = GlobalKey<FormState>();

    final namaController = TextEditingController(text: produk?.nama ?? '');
    final hargaController = TextEditingController(
      text: produk?.harga.toString() ?? '',
    );
    final stokController = TextEditingController(
      text: produk?.stok.toString() ?? '',
    );
    final deskripsiController = TextEditingController(
      text: produk?.deskripsi ?? '',
    );
    String? selectedKategori = produk?.kategori ?? 'food';
    final List<String> kategoriOptions = ['food', 'drinks', 'snacks'];
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          bool favState = produk?.favorite ?? false;
          return AlertDialog(
            title: Text(isEditing ? 'Edit Produk' : 'Tambah Produk'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image picker section
                    GestureDetector(
                      onTap: () async {
                        await _pickImage();
                        setState(() {});
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_imageFile!.path),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : produk?.gambar.isNotEmpty == true
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  produk!.gambar,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.add_photo_alternate,
                                size: 40,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name field
                    TextFormField(
                      controller: namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Produk',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Nama produk harus diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Price field
                    TextFormField(
                      controller: hargaController,
                      decoration: const InputDecoration(
                        labelText: 'Harga',
                        border: OutlineInputBorder(),
                        prefixText: 'Rp ',
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
                    const SizedBox(height: 12),

                    // Stock field
                    TextFormField(
                      controller: stokController,
                      decoration: const InputDecoration(
                        labelText: 'Stok',
                        border: OutlineInputBorder(),
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
                    const SizedBox(height: 12),

                    // Description field
                    TextFormField(
                      controller: deskripsiController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),

                    // Category field
                    DropdownButtonFormField<String>(
                      initialValue: selectedKategori,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
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
                    const SizedBox(height: 12),
                    // Favorite toggle (only shows while editing or for convenience)
                    SwitchListTile(
                      title: const Text('Tambah ke favorit'),
                      value: favState,
                      onChanged: (v) {
                        setState(() => favState = v);
                      },
                    ),
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
                  if (!formKey.currentState!.validate()) return;

                  try {
                    String? imageUrl = produk?.gambar ?? '';

                    // Upload image if selected
                    if (_imageFile != null) {
                      imageUrl = await _uploadImage(_imageFile!);
                      if (imageUrl == null) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Gagal upload gambar')),
                        );
                        return;
                      }
                    }

                    final newProduk = Produk(
                      id: produk?.id,
                      nama: namaController.text,
                      harga: double.parse(hargaController.text),
                      stok: int.parse(stokController.text),
                      deskripsi: deskripsiController.text,
                      kategori: selectedKategori,
                      gambar: imageUrl,
                    );

                    if (isEditing) {
                      // ignore: use_build_context_synchronously
                      await context.read<PosProvider>().updateProduk(
                        produk.id!,
                        newProduk,
                      );
                      // set favorite state
                      if (favState != (produk.favorite)) {
                        await context.read<PosProvider>().toggleFavorite(
                          produk.id!,
                        );
                      }
                    } else {
                      // ignore: use_build_context_synchronously
                      await context.read<PosProvider>().addProduk(newProduk);
                    }

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
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(
                      // ignore: use_build_context_synchronously
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
