import 'dart:convert';
import 'package:http/http.dart' as http;
import 'network_config.dart' as networkConfig;
import '../models/summary.dart';
import '../models/transaksi.dart';
import '../models/produk.dart';

class ApiService {
  static String get baseUrl =>
      '${networkConfig.getBaseUrl()}/api'; // Ganti dengan IP server jika perlu

  Future<Summary> getSummary() async {
    final response = await http.get(Uri.parse('$baseUrl/summary'));
    if (response.statusCode == 200) {
      return Summary.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load summary');
    }
  }

  Future<List<Transaksi>> getTransaksi() async {
    final response = await http.get(Uri.parse('$baseUrl/transaksi'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Transaksi.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load transaksi');
    }
  }

  Future<void> addTransaksi(Transaksi transaksi) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transaksi'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(transaksi.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add transaksi');
    }
  }

  Future<List<Produk>> getProduk() async {
    final response = await http.get(Uri.parse('$baseUrl/produk'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Produk> produkList = data
          .map((json) => Produk.fromJson(json))
          .toList();
      // Fix old localhost URLs
      for (var produk in produkList) {
        if (produk.gambar.startsWith('http://localhost')) {
          produk.gambar = produk.gambar.replaceAll(
            'http://localhost:3000',
            networkConfig.getBaseUrl(),
          );
        }
      }
      return produkList;
    } else {
      throw Exception('Failed to load produk');
    }
  }

  Future<void> addProduk(Produk produk) async {
    final response = await http.post(
      Uri.parse('$baseUrl/produk'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(produk.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add produk');
    }
  }

  Future<void> updateProduk(int id, Produk produk) async {
    final response = await http.put(
      Uri.parse('$baseUrl/produk/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(produk.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update produk');
    }
  }

  Future<void> updateStok(int id, int jumlah) async {
    final response = await http.put(
      Uri.parse('$baseUrl/produk/$id/stok'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'jumlah': jumlah}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update stok');
    }
  }

  Future<void> deleteProduk(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/produk/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete produk');
    }
  }
}
