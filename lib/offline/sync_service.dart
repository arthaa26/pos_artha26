import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/product.dart';
import 'local_db_helper.dart';

class SyncService {
  final String baseUrl; // e.g. http://127.0.0.1:3000
  final LocalDbHelper _db = LocalDbHelper();

  SyncService({required this.baseUrl});

  Future<bool> isOnline() async {
    final conn = await Connectivity().checkConnectivity();
    return conn != ConnectivityResult.none;
  }

  Future<void> syncAll() async {
    if (!await isOnline()) return;

    // 1) Push local dirty records
    final dirty = await _db.getDirtyProducts();
    for (final p in dirty) {
      try {
        if (p.deleted == 1) {
          // deleted locally
          if (p.serverId != null) {
            final resp = await http.delete(
              Uri.parse('$baseUrl/api/produk/${p.serverId}'),
            );
            if (resp.statusCode == 200) {
              // remove local
              if (p.localId != null) await _db.deleteLocal(p.localId!);
            }
          } else {
            // never existed on server, just remove local
            if (p.localId != null) await _db.deleteLocal(p.localId!);
          }
          continue;
        }

        if (p.serverId == null) {
          // create on server
          final body = {
            'nama': p.nama,
            'harga': p.harga,
            'stok': p.stok,
            'deskripsi': p.deskripsi,
            'gambar': p.gambar,
          };
          final resp = await http.post(
            Uri.parse('$baseUrl/api/produk'),
            body: json.encode(body),
            headers: {'Content-Type': 'application/json'},
          );
          if (resp.statusCode == 200) {
            final data = json.decode(resp.body);
            final int serverId = data['id'];
            if (p.localId != null)
              await _db.markClean(p.localId!, serverId: serverId);
          }
        } else {
          // update on server
          final body = {
            'nama': p.nama,
            'harga': p.harga,
            'stok': p.stok,
            'deskripsi': p.deskripsi,
            'gambar': p.gambar,
          };
          final resp = await http.put(
            Uri.parse('$baseUrl/api/produk/${p.serverId}'),
            body: json.encode(body),
            headers: {'Content-Type': 'application/json'},
          );
          if (resp.statusCode == 200) {
            if (p.localId != null) await _db.markClean(p.localId!);
          }
        }
      } catch (e) {
        // ignore - will retry later
        print('Sync error for product ${p.localId ?? p.serverId}: $e');
      }
    }

    // 2) Pull from server and merge
    try {
      final resp = await http.get(Uri.parse('$baseUrl/api/produk'));
      if (resp.statusCode == 200) {
        final List<dynamic> list = json.decode(resp.body);
        for (final item in list) {
          final p = Product.fromServerJson(item as Map<String, dynamic>);
          await _db.upsertFromServer(p);
        }
      }
    } catch (e) {
      print('Pull sync error: $e');
    }
  }
}
