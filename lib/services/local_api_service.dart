import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../database/database.dart' if (kIsWeb) 'dart:async';
// import './database_service.dart';

class LocalApiService {
  static final LocalApiService _instance = LocalApiService._internal();
  late final dynamic _dbService;

  factory LocalApiService() {
    return _instance;
  }

  LocalApiService._internal();

  void initialize(dynamic dbService) {
    _dbService = dbService;
  }

  // ============ PRODUK (PRODUCTS) ============

  Future<List<dynamic>> getProduk() async {
    try {
      if (kIsWeb) {
        throw UnsupportedError('Database not available on web');
      }
      if (kDebugMode) print('📦 Getting all products from local database...');
      
      if (_dbService == null) {
        throw StateError('Database service not initialized');
      }
      
      if (kDebugMode) print('🔄 Calling _dbService.getAllProduk()...');
      final produk = await _dbService.getAllProduk();
      
      if (kDebugMode) print('✅ Loaded ${produk.length} products from database');
      
      if (produk.isEmpty && kDebugMode) {
        print('⚠️ WARNING: Database returned 0 products');
      }
      
      return produk;
    } catch (e) {
      if (kDebugMode) print('❌ Error getProduk: $e');
      throw Exception('Failed to load produk: $e');
    }
  }

  Future<dynamic> getProdukById(int id) async {
    try {
      if (kIsWeb) {
        throw UnsupportedError('Database not available on web');
      }
      if (kDebugMode) print('📦 Getting product ID: $id');
      final produk = await _dbService.getProdukById(id);
      return produk;
    } catch (e) {
      if (kDebugMode) print('❌ Error getProdukById: $e');
      return null;
    }
  }

  Future<List<dynamic>> getProdukByCategory(String kategori) async {
    try {
      if (kIsWeb) {
        throw UnsupportedError('Database not available on web');
      }
      if (kDebugMode) print('📦 Getting products by category: $kategori');
      final produk = await _dbService.getProdukByCategory(kategori);
      return produk;
    } catch (e) {
      if (kDebugMode) print('❌ Error getProdukByCategory: $e');
      throw Exception('Failed to load produk: $e');
    }
  }

  Future<int> addProduk({
    required String nama,
    required double harga,
    required double hargaBeli,
    required int stok,
    required String kategori,
    String? deskripsi,
    String? gambar,
    String? barcode,
    String satuan = 'pcs',
  }) async {
    try {
      if (kDebugMode) print('➕ Adding product: $nama');
      final id = await _dbService.addProduk(
        nama: nama,
        harga: harga,
        hargaBeli: hargaBeli,
        stok: stok,
        kategori: kategori,
        deskripsi: deskripsi,
        gambar: gambar,
        barcode: barcode,
        satuan: satuan,
      );
      if (kDebugMode) print('✅ Product added with ID: $id');
      return id;
    } catch (e) {
      if (kDebugMode) print('❌ Error addProduk: $e');
      throw Exception('Failed to add produk: $e');
    }
  }

  Future<bool> updateProduk({
    required int id,
    required String nama,
    required double harga,
    required double hargaBeli,
    required int stok,
    required String kategori,
    String? deskripsi,
    String? gambar,
    String? barcode,
    String satuan = 'pcs',
  }) async {
    try {
      if (kDebugMode) print('✏️ Updating product ID: $id');
      final success = await _dbService.updateProduk(
        id: id,
        nama: nama,
        harga: harga,
        hargaBeli: hargaBeli,
        stok: stok,
        kategori: kategori,
        deskripsi: deskripsi,
        gambar: gambar,
        barcode: barcode,
        satuan: satuan,
      );
      if (kDebugMode) print('✅ Product updated');
      return success;
    } catch (e) {
      if (kDebugMode) print('❌ Error updateProduk: $e');
      return false;
    }
  }

  Future<int> deleteProduk(int id) async {
    try {
      if (kDebugMode) print('🗑️ Deleting product ID: $id');
      final count = await _dbService.deleteProduk(id);
      if (kDebugMode) print('✅ Product deleted');
      return count;
    } catch (e) {
      if (kDebugMode) print('❌ Error deleteProduk: $e');
      return 0;
    }
  }

  // ============ TRANSAKSI (TRANSACTIONS) ============

  Future<List<Transaksi>> getTransaksi() async {
    try {
      if (kDebugMode) print('🧾 Getting all transactions...');
      final transaksi = await _dbService.getAllTransaksi();
      if (kDebugMode) print('✅ Loaded ${transaksi.length} transactions');
      return transaksi;
    } catch (e) {
      if (kDebugMode) print('❌ Error getTransaksi: $e');
      throw Exception('Failed to load transaksi: $e');
    }
  }

  Future<List<Transaksi>> getTransaksiByDate(DateTime tanggal) async {
    try {
      if (kDebugMode)
        print(
          '🧾 Getting transactions for ${DateFormat('dd-MM-yyyy').format(tanggal)}',
        );
      final transaksi = await _dbService.getTransaksiByDate(tanggal);
      return transaksi;
    } catch (e) {
      if (kDebugMode) print('❌ Error getTransaksiByDate: $e');
      throw Exception('Failed to load transaksi: $e');
    }
  }

  Future<List<DetailTransaksi>> getDetailTransaksi(int transaksiId) async {
    try {
      if (kDebugMode) print('🧾 Getting transaction details for ID: $transaksiId');
      final details = await _dbService.getDetailTransaksi(transaksiId);
      if (kDebugMode) print('✅ Loaded ${details.length} transaction items');
      return details;
    } catch (e) {
      if (kDebugMode) print('❌ Error getDetailTransaksi: $e');
      throw Exception('Failed to load detail transaksi: $e');
    }
  }

  Future<void> addTransaksi({
    required String nomorTransaksi,
    required List<Map<String, dynamic>> items,
    required double total,
    required double bayar,
    double? kembalian,
    String metode = 'cash',
    String? catatan,
  }) async {
    try {
      if (kDebugMode) print('➕ Adding transaction: $nomorTransaksi');

      // Add transaction header
      final transaksiId = await _dbService.addTransaksi(
        nomorTransaksi: nomorTransaksi,
        tanggal: DateTime.now(),
        total: total,
        bayar: bayar,
        kembalian: kembalian,
        metode: metode,
        status: 'selesai',
        catatan: catatan,
      );

      // Add transaction details
      for (final item in items) {
        await _dbService.addDetailTransaksi(
          transaksiId: transaksiId,
          produkId: item['produkId'],
          jumlah: item['jumlah'],
          hargaSatuan: item['hargaSatuan'],
          subtotal: item['subtotal'],
          catatan: item['nama'], // Store product name in catatan
        );

        // Update product stock
        final produk = await _dbService.getProdukById(item['produkId']);
        if (produk != null) {
          final newStock = produk.stok - (item['jumlah'] as int? ?? 1);
          await _dbService.updateProduk(
            id: produk.id,
            nama: produk.nama,
            harga: produk.harga,
            hargaBeli: produk.hargaBeli ?? 0,
            stok: newStock,
            kategori: produk.kategori ?? 'Lainnya',
            deskripsi: produk.deskripsi,
            gambar: produk.gambar,
            barcode: produk.barcode,
          );
        }
      }

      if (kDebugMode) print('✅ Transaction added successfully');
    } catch (e) {
      if (kDebugMode) print('❌ Error addTransaksi: $e');
      throw Exception('Failed to add transaksi: $e');
    }
  }

  // ============ PENGELUARAN (EXPENSES) ============

  Future<List<Pengeluaran>> getAllPengeluaran() async {
    try {
      if (kDebugMode) print('💸 Getting all expenses...');
      final pengeluaran = await _dbService.getAllPengeluaran();
      if (kDebugMode) print('✅ Loaded ${pengeluaran.length} expenses');
      return pengeluaran;
    } catch (e) {
      if (kDebugMode) print('❌ Error getAllPengeluaran: $e');
      throw Exception('Failed to load pengeluaran: $e');
    }
  }

  Future<List<Pengeluaran>> getPengeluaranByDate(DateTime tanggal) async {
    try {
      if (kDebugMode)
        print(
          '💸 Getting expenses for ${DateFormat('dd-MM-yyyy').format(tanggal)}',
        );
      final pengeluaran = await _dbService.getPengeluaranByDate(tanggal);
      return pengeluaran;
    } catch (e) {
      if (kDebugMode) print('❌ Error getPengeluaranByDate: $e');
      throw Exception('Failed to load pengeluaran: $e');
    }
  }

  Future<int> addPengeluaran({
    required String kategori,
    required double jumlah,
    required DateTime tanggal,
    String? catatan,
    String? bukti,
  }) async {
    try {
      if (kDebugMode) print('➕ Adding expense: $kategori - Rp $jumlah');
      final id = await _dbService.addPengeluaran(
        kategori: kategori,
        jumlah: jumlah,
        tanggal: tanggal,
        catatan: catatan,
        bukti: bukti,
      );
      if (kDebugMode) print('✅ Expense added');
      return id;
    } catch (e) {
      if (kDebugMode) print('❌ Error addPengeluaran: $e');
      throw Exception('Failed to add pengeluaran: $e');
    }
  }

  Future<void> updatePengeluaran({
    required int id,
    required String kategori,
    required double jumlah,
    required DateTime tanggal,
    String? catatan,
    String? bukti,
  }) async {
    try {
      if (kDebugMode) print('✏️ Updating expense ID: $id');
      await _dbService.updatePengeluaran(
        id: id,
        kategori: kategori,
        jumlah: jumlah,
        tanggal: tanggal,
        catatan: catatan,
        bukti: bukti,
      );
      if (kDebugMode) print('✅ Expense updated');
    } catch (e) {
      if (kDebugMode) print('❌ Error updatePengeluaran: $e');
      throw Exception('Failed to update pengeluaran: $e');
    }
  }

  Future<void> deletePengeluaran(int id) async {
    try {
      if (kDebugMode) print('🗑️ Deleting expense ID: $id');
      await _dbService.deletePengeluaran(id);
      if (kDebugMode) print('✅ Expense deleted');
    } catch (e) {
      if (kDebugMode) print('❌ Error deletePengeluaran: $e');
      throw Exception('Failed to delete pengeluaran: $e');
    }
  }

  Future<List<dynamic>> getPengeluaran() async {
    try {
      if (kDebugMode) print('💸 Getting all expenses...');
      final pengeluaran = await _dbService.getAllPengeluaran();
      if (kDebugMode) print('✅ Loaded ${pengeluaran.length} expenses');
      return pengeluaran;
    } catch (e) {
      if (kDebugMode) print('❌ Error getPengeluaran: $e');
      throw Exception('Failed to load pengeluaran: $e');
    }
  }

  // ============ SUMMARY ============

  Future<Map<String, dynamic>> getSummary() async {
    try {
      if (kDebugMode) print('📊 Getting daily summary...');
      final summary = await _dbService.getDailySummary(DateTime.now());
      if (kDebugMode) print('✅ Summary loaded');
      return summary;
    } catch (e) {
      if (kDebugMode) print('❌ Error getSummary: $e');
      throw Exception('Failed to load summary: $e');
    }
  }
}

final localApiService = LocalApiService();
