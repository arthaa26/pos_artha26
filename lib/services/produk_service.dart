import 'package:flutter/foundation.dart';
import 'file_permission_service.dart';

/// Enhanced Produk Service dengan error handling yang comprehensive
class ProdukService {
  static final ProdukService _instance = ProdukService._internal();
  final _fileService = FilePermissionService();

  factory ProdukService() {
    return _instance;
  }

  ProdukService._internal();

  /// Add product dengan validation dan error handling
  Future<bool> addProduk({
    required String nama,
    required double harga,
    required double hargaBeli,
    required int stok,
    required String kategori,
    String? deskripsi,
    String? gambar,
    String? barcode,
    String satuan = 'pcs',
    required dynamic dbService,
  }) async {
    try {
      if (nama.isEmpty) {
        throw ArgumentError('Nama produk tidak boleh kosong');
      }

      if (harga <= 0) {
        throw ArgumentError('Harga harus lebih besar dari 0');
      }

      if (stok < 0) {
        throw ArgumentError('Stok tidak boleh negatif');
      }

      if (kDebugMode) {
        print('➕ Adding product: $nama');
        print('   Harga: $harga, Stok: $stok');
      }

      // Validate gambar path if provided
      String? validatedGambar;
      if (gambar != null && gambar.isNotEmpty) {
        final exists = await _fileService.fileExists(gambar);
        if (exists) {
          validatedGambar = gambar;
        } else {
          if (kDebugMode) print('⚠️ Gambar file not found, skipping: $gambar');
          validatedGambar = null;
        }
      }

      // Call database
      final id = await dbService.addProduk(
        nama: nama,
        harga: harga,
        hargaBeli: hargaBeli,
        stok: stok,
        kategori: kategori,
        deskripsi: deskripsi,
        gambar: validatedGambar,
        barcode: barcode,
        satuan: satuan,
      );

      if (kDebugMode) print('✅ Produk added with ID: $id');
      return true;
    } catch (e, st) {
      if (kDebugMode) {
        print('❌ Error adding produk: $e');
        print('Stack: $st');
      }
      rethrow;
    }
  }

  /// Update product dengan validation dan error handling
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
    required dynamic dbService,
  }) async {
    try {
      if (id <= 0) {
        throw ArgumentError('ID produk tidak valid');
      }

      if (nama.isEmpty) {
        throw ArgumentError('Nama produk tidak boleh kosong');
      }

      if (harga <= 0) {
        throw ArgumentError('Harga harus lebih besar dari 0');
      }

      if (stok < 0) {
        throw ArgumentError('Stok tidak boleh negatif');
      }

      if (kDebugMode) {
        print('✏️ Updating produk ID: $id');
        print('   Nama: $nama, Harga: $harga, Stok: $stok');
      }

      // Validate gambar path if provided
      String? validatedGambar;
      if (gambar != null && gambar.isNotEmpty) {
        final exists = await _fileService.fileExists(gambar);
        if (exists) {
          validatedGambar = gambar;
        } else {
          if (kDebugMode) print('⚠️ Gambar file not found, skipping: $gambar');
          validatedGambar = null;
        }
      }

      // Call database
      final success = await dbService.updateProduk(
        id: id,
        nama: nama,
        harga: harga,
        hargaBeli: hargaBeli,
        stok: stok,
        kategori: kategori,
        deskripsi: deskripsi,
        gambar: validatedGambar,
        barcode: barcode,
        satuan: satuan,
      );

      if (kDebugMode) print('✅ Produk updated');
      return success;
    } catch (e, st) {
      if (kDebugMode) {
        print('❌ Error updating produk: $e');
        print('Stack: $st');
      }
      rethrow;
    }
  }

  /// Delete product dengan error handling
  Future<bool> deleteProduk({
    required int id,
    required dynamic dbService,
  }) async {
    try {
      if (id <= 0) {
        throw ArgumentError('ID produk tidak valid');
      }

      if (kDebugMode) print('🗑️ Deleting produk ID: $id');

      await dbService.deleteProduk(id);

      if (kDebugMode) print('✅ Produk deleted');
      return true;
    } catch (e, st) {
      if (kDebugMode) {
        print('❌ Error deleting produk: $e');
        print('Stack: $st');
      }
      rethrow;
    }
  }

  /// Get all products dengan error handling
  Future<List<dynamic>> getAllProduk({required dynamic dbService}) async {
    try {
      if (kDebugMode) print('📦 Fetching all products');

      final produk = await dbService.getAllProduk();

      if (kDebugMode) print('✅ Loaded ${produk.length} products');
      return produk;
    } catch (e, st) {
      if (kDebugMode) {
        print('❌ Error fetching products: $e');
        print('Stack: $st');
      }
      return [];
    }
  }

  /// Validate image file untuk produk
  Future<String?> validateAndSaveImage(String imagePath) async {
    try {
      if (imagePath.isEmpty) {
        return null;
      }

      // Check if file exists
      final exists = await _fileService.fileExists(imagePath);
      if (!exists) {
        if (kDebugMode) print('❌ Image file not found: $imagePath');
        return null;
      }

      // Return the path if valid
      if (kDebugMode) print('✅ Image validated: $imagePath');
      return imagePath;
    } catch (e) {
      if (kDebugMode) print('❌ Error validating image: $e');
      return null;
    }
  }
}
