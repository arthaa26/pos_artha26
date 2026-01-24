import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/summary.dart' as summary_model;
import '../models/settings.dart';
import '../services/local_api_service.dart';
// import '../database/database.dart' as drift_db if (kIsWeb) 'dart:async';

class PosProvider with ChangeNotifier {
  summary_model.Summary? _summary;
  List<dynamic> _transaksi = [];
  List<dynamic> _produk = [];
  List<dynamic> _pengeluaran = [];
  AppSettings _settings = AppSettings();
  bool _isLoading = false;
  Timer? _timer;

  summary_model.Summary? get summary => _summary;
  List<dynamic> get transaksi => _transaksi;
  List<dynamic> get produk => _produk;
  List<dynamic> get pengeluaran => _pengeluaran;
  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;

  final LocalApiService _apiService = localApiService;

  PosProvider() {
    _startAutoRefresh();
    _loadSettings();
    if (!kIsWeb) {
      loadTransaksi();
      loadProduk();
      loadPengeluaran();
    }
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = prefs.getString('app_settings_json');
      if (s != null && s.isNotEmpty) {
        final map = json.decode(s) as Map<String, dynamic>;
        _settings = AppSettings.fromJson(map);
        notifyListeners();
      }
    } catch (e) {
      // ignore, use defaults
    }
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(Duration(seconds: 30), (_) async {
      await loadSummary();
    });
  }

  void _stopAutoRefresh() {
    _timer?.cancel();
  }

  Future<void> loadSummary() async {
    try {
      if (kDebugMode) print('📊 Loading daily summary...');
      final summaryData = await _apiService.getSummary();

      _summary = summary_model.Summary(
        totalPendapatan: (summaryData['totalPenjualan'] ?? 0).toDouble(),
        totalPengeluaran: (summaryData['totalPengeluaran'] ?? 0).toDouble(),
        totalKeuntungan: (summaryData['totalKeuntungan'] ?? 0).toDouble(),
        totalTransaksi: summaryData['jumlahTransaksi'] ?? 0,
      );
      if (kDebugMode) print('✅ Summary loaded');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ Failed to load summary: $e');
      _summary = null;
      notifyListeners();
    }
  }

  Future<void> loadTransaksi() async {
    try {
      if (kDebugMode) print('🧾 Loading transactions...');
      _transaksi = await _apiService.getTransaksi();
      if (kDebugMode) print('✅ Loaded ${_transaksi.length} transactions');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ Failed to load transaksi: $e');
      _transaksi = [];
      notifyListeners();
    }
  }

  Future<void> loadProduk() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (kDebugMode) print('📦 Loading products from Drift database...');
      _produk = await _apiService.getProduk();
      if (kDebugMode) print('✅ Loaded ${_produk.length} products');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ Failed to load produk: $e');
      _produk = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPengeluaran() async {
    try {
      if (kDebugMode) print('💸 Loading pengeluaran...');
      _pengeluaran = await _apiService.getPengeluaran();
      if (kDebugMode) print('✅ Loaded ${_pengeluaran.length} pengeluaran');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ Failed to load pengeluaran: $e');
      _pengeluaran = [];
      notifyListeners();
    }
  }

  Future<void> addProduk(dynamic produk) async {
    try {
      if (kDebugMode) print('➕ Adding product: ${produk.nama}');
      await _apiService.addProduk(
        nama: produk.nama,
        harga: produk.harga,
        hargaBeli: produk.hargaBeli ?? 0,
        stok: produk.stok,
        kategori: produk.kategori ?? 'Lainnya',
        deskripsi: produk.deskripsi,
        gambar: produk.gambar,
        barcode: produk.barcode,
      );
      await loadProduk();
      if (kDebugMode) print('✅ Product added successfully');
    } catch (e) {
      if (kDebugMode) print('❌ Failed to add product: $e');
      throw Exception('Failed to add product: $e');
    }
  }

  Future<void> updateProduk(int id, dynamic produk) async {
    try {
      if (kDebugMode) print('✏️ Updating product ID: $id');
      await _apiService.updateProduk(
        id: id,
        nama: produk.nama,
        harga: produk.harga,
        hargaBeli: produk.hargaBeli ?? 0,
        stok: produk.stok,
        kategori: produk.kategori ?? 'Lainnya',
        deskripsi: produk.deskripsi,
        gambar: produk.gambar,
        barcode: produk.barcode,
      );
      await loadProduk();
      if (kDebugMode) print('✅ Product updated successfully');
    } catch (e) {
      if (kDebugMode) print('❌ Failed to update product: $e');
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduk(int id) async {
    try {
      if (kDebugMode) print('🗑️ Deleting product ID: $id');
      await _apiService.deleteProduk(id);
      await loadProduk();
      if (kDebugMode) print('✅ Product deleted successfully');
    } catch (e) {
      if (kDebugMode) print('❌ Failed to delete product: $e');
      throw Exception('Failed to delete product: $e');
    }
  }

  Future<void> addTransaksi(dynamic transaksi) async {
    try {
      if (kDebugMode) print('➕ Adding transaction');
      // Transaction is already added through the database
      await loadTransaksi();
      await loadSummary();
      if (kDebugMode) print('✅ Transaction recorded successfully');
    } catch (e) {
      if (kDebugMode) print('❌ Failed to add transaction: $e');
      throw Exception('Failed to add transaction: $e');
    }
  }

  Future<void> addPengeluaran({
    required String kategori,
    required double jumlah,
    required DateTime tanggal,
    String? catatan,
  }) async {
    try {
      if (kDebugMode) print('➕ Adding expense: $kategori');
      await _apiService.addPengeluaran(
        kategori: kategori,
        jumlah: jumlah,
        tanggal: tanggal,
        catatan: catatan,
      );
      await loadPengeluaran();
      if (kDebugMode) print('✅ Expense added successfully');
    } catch (e) {
      if (kDebugMode) print('❌ Failed to add expense: $e');
      throw Exception('Failed to add expense: $e');
    }
  }

  Future<void> updatePengeluaran({
    required int id,
    required String kategori,
    required double jumlah,
    required DateTime tanggal,
    String? catatan,
  }) async {
    try {
      if (kDebugMode) print('✏️ Updating expense ID: $id');
      await _apiService.updatePengeluaran(
        id: id,
        kategori: kategori,
        jumlah: jumlah,
        tanggal: tanggal,
        catatan: catatan,
      );
      await loadPengeluaran();
      if (kDebugMode) print('✅ Expense updated successfully');
    } catch (e) {
      if (kDebugMode) print('❌ Failed to update expense: $e');
      throw Exception('Failed to update expense: $e');
    }
  }

  Future<void> deletePengeluaran(int id) async {
    try {
      if (kDebugMode) print('🗑️ Deleting expense ID: $id');
      await _apiService.deletePengeluaran(id);
      await loadPengeluaran();
      if (kDebugMode) print('✅ Expense deleted successfully');
    } catch (e) {
      if (kDebugMode) print('❌ Failed to delete expense: $e');
      throw Exception('Failed to delete expense: $e');
    }
  }

  bool verifyPin(String pin) {
    return pin == _settings.pinCode;
  }

  Future<void> updateSettings(AppSettings settings) async {
    try {
      _settings = settings;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'app_settings_json',
        json.encode(settings.toJson()),
      );
      if (kDebugMode) print('✅ Settings updated');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ Failed to update settings: $e');
    }
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    super.dispose();
  }
}
