import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/summary.dart';
import '../models/transaksi.dart';
import '../models/produk.dart';
import '../models/product.dart';
import '../models/settings.dart';
import '../services/api_service.dart';
import '../offline/local_db_helper.dart';

class PosProvider with ChangeNotifier {
  Summary? _summary;
  List<Transaksi> _transaksi = [];
  List<Produk> _produk = [];
  Set<int> _favoriteIds = {};
  AppSettings _settings = AppSettings();
  bool _isLoading = false;
  Timer? _timer;

  Summary? get summary => _summary;
  List<Transaksi> get transaksi => _transaksi;
  List<Produk> get produk => _produk;
  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;

  final ApiService _apiService = ApiService();

  PosProvider() {
    _startAutoRefresh();
    _loadSettings();
    loadTransaksi();
    loadProduk();
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

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = prefs.getString('favorite_produk_ids') ?? '[]';
      final List<dynamic> list = json.decode(s);
      _favoriteIds = list.map((e) => (e as int)).toSet();
    } catch (e) {
      _favoriteIds = {};
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'favorite_produk_ids',
        json.encode(_favoriteIds.toList()),
      );
    } catch (e) {
      // ignore
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'app_settings_json',
        json.encode(_settings.toJson()),
      );
    } catch (e) {
      // ignore
    }
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(minutes: 5), (_) {
      loadSummary();
      loadTransaksi();
      loadProduk();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> loadSummary() async {
    _isLoading = true;
    notifyListeners();
    try {
      _summary = await _apiService.getSummary();
    } catch (e) {
      // Handle error - maybe show snackbar in UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTransaksi() async {
    print('Loading transaksi');
    try {
      _transaksi = await _apiService.getTransaksi();
      print('Loaded ${_transaksi.length} transaksi from server');
      // Merge with local dirty records
      final localDirty = await LocalDbHelper().getDirtyTransaksi();
      print('Local dirty: ${localDirty.length}');
      for (final t in localDirty) {
        if (!_transaksi.any((serverT) => serverT.id == t.id)) {
          _transaksi.add(t);
        }
      }
      notifyListeners();
    } catch (e) {
      print('Failed to load from server, loading local: $e');
      // Offline fallback
      _transaksi = await LocalDbHelper().getAllTransaksi();
      print('Loaded ${_transaksi.length} from local');
      notifyListeners();
    }
  }

  Future<void> addTransaksi(Transaksi transaksi) async {
    print('Adding transaksi: ${transaksi.toJson()}');
    final isOnline =
        await Connectivity().checkConnectivity() != ConnectivityResult.none;
    print('Is online: $isOnline');
    if (isOnline) {
      try {
        await _apiService.addTransaksi(transaksi);
        await loadSummary();
        await loadTransaksi();
      } catch (e) {
        print('Failed to add online, saving locally: $e');
        // If online but failed, save locally
        final localId = await LocalDbHelper().insertTransaksi(transaksi);
        final localTransaksi = transaksi.copyWith(localId: localId);
        _transaksi.add(localTransaksi);
        notifyListeners();
      }
    } else {
      print('Offline, saving locally');
      // Offline, save locally
      final localId = await LocalDbHelper().insertTransaksi(transaksi);
      final localTransaksi = transaksi.copyWith(localId: localId);
      _transaksi.add(localTransaksi);
      notifyListeners();
    }
  }

  Future<void> loadProduk() async {
    try {
      _produk = await _apiService.getProduk();
      // load favorites and apply
      await _loadFavorites();
      for (var p in _produk) {
        if (p.id != null && _favoriteIds.contains(p.id)) {
          p.favorite = true;
        } else {
          p.favorite = false;
        }
      }
      notifyListeners();
    } catch (e) {
      print('Failed to load produk from server, loading from local: $e');
      // Offline fallback - load from local database
      final localProducts = await LocalDbHelper().getAllProducts();
      _produk = localProducts
          .where((p) => p.deleted != 1)
          .map(
            (p) => Produk(
              id: p.serverId,
              nama: p.nama,
              harga: p.harga,
              stok: p.stok,
              deskripsi: p.deskripsi ?? '',
              gambar: p.gambar ?? '',
              favorite: false, // Will be set below
            ),
          )
          .toList();

      // Load favorites and apply
      await _loadFavorites();
      for (var p in _produk) {
        if (p.id != null && _favoriteIds.contains(p.id)) {
          p.favorite = true;
        } else {
          p.favorite = false;
        }
      }
      notifyListeners();
    }
  }

  Future<void> addProduk(Produk produk) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // Offline mode - save locally
        final product = Product(
          nama: produk.nama,
          harga: produk.harga,
          stok: produk.stok,
          deskripsi: produk.deskripsi,
          gambar: produk.gambar,
        );
        final localId = await LocalDbHelper().insertProduct(product);
        final produkWithLocalId = Produk(
          id: localId,
          nama: produk.nama,
          harga: produk.harga,
          stok: produk.stok,
          deskripsi: produk.deskripsi,
          gambar: produk.gambar,
          favorite: produk.favorite,
        );
        _produk.add(produkWithLocalId);
        notifyListeners();
        return;
      }

      // Online mode - save to server
      await _apiService.addProduk(produk);
      await loadProduk();
    } catch (e) {
      print('Error adding product: $e');
      // Fallback to local storage if server fails
      try {
        final product = Product(
          nama: produk.nama,
          harga: produk.harga,
          stok: produk.stok,
          deskripsi: produk.deskripsi,
          gambar: produk.gambar,
        );
        final localId = await LocalDbHelper().insertProduct(product);
        final produkWithLocalId = Produk(
          id: localId,
          nama: produk.nama,
          harga: produk.harga,
          stok: produk.stok,
          deskripsi: produk.deskripsi,
          gambar: produk.gambar,
          favorite: produk.favorite,
        );
        _produk.add(produkWithLocalId);
        notifyListeners();
      } catch (localError) {
        print('Error saving locally: $localError');
      }
    }
  }

  Future<void> updateProduk(int id, Produk produk) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // Offline mode - update locally
        final product = Product(
          serverId: id,
          nama: produk.nama,
          harga: produk.harga,
          stok: produk.stok,
          deskripsi: produk.deskripsi,
          gambar: produk.gambar,
        );
        await LocalDbHelper().updateProduct(product);

        // Update in local list
        final index = _produk.indexWhere((p) => p.id == id);
        if (index != -1) {
          _produk[index] = produk;
          notifyListeners();
        }
        return;
      }

      // Online mode - update on server
      await _apiService.updateProduk(id, produk);
      await loadProduk();
    } catch (e) {
      print('Error updating product: $e');
      // Fallback to local update if server fails
      try {
        final product = Product(
          serverId: id,
          nama: produk.nama,
          harga: produk.harga,
          stok: produk.stok,
          deskripsi: produk.deskripsi,
          gambar: produk.gambar,
        );
        await LocalDbHelper().updateProduct(product);

        // Update in local list
        final index = _produk.indexWhere((p) => p.id == id);
        if (index != -1) {
          _produk[index] = produk;
          notifyListeners();
        }
      } catch (localError) {
        print('Error updating locally: $localError');
      }
    }
  }

  Future<void> updateStok(int id, int jumlah) async {
    try {
      await _apiService.updateStok(id, jumlah);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteProduk(int id) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // Offline mode - mark as deleted locally
        final product = Product(serverId: id, nama: '', harga: 0, stok: 0);
        await LocalDbHelper().markDeleted(product);

        // Remove from local list
        _produk.removeWhere((p) => p.id == id);
        // remove from favorites if present
        if (_favoriteIds.contains(id)) {
          _favoriteIds.remove(id);
          await _saveFavorites();
        }
        notifyListeners();
        return;
      }

      // Online mode - delete from server
      await _apiService.deleteProduk(id);
      // remove from favorites if present
      if (_favoriteIds.contains(id)) {
        _favoriteIds.remove(id);
        await _saveFavorites();
      }
      await loadProduk();
    } catch (e) {
      print('Error deleting product: $e');
      // Fallback to local delete if server fails
      try {
        final product = Product(serverId: id, nama: '', harga: 0, stok: 0);
        await LocalDbHelper().markDeleted(product);

        // Remove from local list
        _produk.removeWhere((p) => p.id == id);
        // remove from favorites if present
        if (_favoriteIds.contains(id)) {
          _favoriteIds.remove(id);
          await _saveFavorites();
        }
        notifyListeners();
      } catch (localError) {
        print('Error deleting locally: $localError');
      }
    }
  }

  // Favorite management
  List<Produk> get favoriteProduk => _produk
      .where((p) => p.id != null && _favoriteIds.contains(p.id))
      .toList();

  Future<void> toggleFavorite(int id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    await _saveFavorites();
    // update in-memory
    for (var p in _produk) {
      if (p.id == id) p.favorite = _favoriteIds.contains(id);
    }
    notifyListeners();
  }

  void updateSettings(AppSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
    _saveSettings();
  }

  bool verifyPin(String pin) {
    return _settings.pinCode == pin;
  }
}
