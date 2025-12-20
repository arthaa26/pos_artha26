import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/summary.dart';
import '../models/transaksi.dart';
import '../models/produk.dart';
import '../models/settings.dart';
import '../services/api_service.dart';

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
    try {
      _transaksi = await _apiService.getTransaksi();
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> addTransaksi(Transaksi transaksi) async {
    try {
      await _apiService.addTransaksi(transaksi);
      await loadSummary();
      await loadTransaksi();
    } catch (e) {
      // Handle error
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
      // Handle error
    }
  }

  Future<void> addProduk(Produk produk) async {
    try {
      await _apiService.addProduk(produk);
      await loadProduk();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateProduk(int id, Produk produk) async {
    try {
      await _apiService.updateProduk(id, produk);
      await loadProduk();
    } catch (e) {
      // Handle error
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
      await _apiService.deleteProduk(id);
      // remove from favorites if present
      if (_favoriteIds.contains(id)) {
        _favoriteIds.remove(id);
        await _saveFavorites();
      }
      await loadProduk();
    } catch (e) {
      // Handle error
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
