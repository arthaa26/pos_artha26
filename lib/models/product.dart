import 'dart:convert';

class Product {
  int? localId; // local primary key
  int? serverId; // id on server (produk.id)
  String nama;
  double harga;
  int stok;
  String? deskripsi;
  String? gambar; // local path or server URL
  String? kategori; // Makanan, Minuman, Cemilan, Lainnya
  double? hargaModal; // cost price
  int? stokMinimal; // minimum stock
  int dirty; // 1 = needs sync
  int deleted; // 1 = deleted locally, pending remote delete

  Product({
    this.localId,
    this.serverId,
    required this.nama,
    required this.harga,
    required this.stok,
    this.deskripsi,
    this.gambar,
    this.kategori,
    this.hargaModal,
    this.stokMinimal,
    this.dirty = 1,
    this.deleted = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'local_id': localId,
      'server_id': serverId,
      'nama': nama,
      'harga': harga,
      'stok': stok,
      'deskripsi': deskripsi,
      'gambar': gambar,
      'kategori': kategori,
      'harga_modal': hargaModal,
      'stok_minimal': stokMinimal,
      'dirty': dirty,
      'deleted': deleted,
    };
  }

  factory Product.fromMap(Map<String, dynamic> m) {
    return Product(
      localId: m['local_id'] as int?,
      serverId: m['server_id'] as int?,
      nama: m['nama'] as String? ?? '',
      harga: (m['harga'] as num?)?.toDouble() ?? 0.0,
      stok: (m['stok'] as int?) ?? 0,
      deskripsi: m['deskripsi'] as String?,
      gambar: m['gambar'] as String?,
      kategori: m['kategori'] as String?,
      hargaModal: (m['harga_modal'] as num?)?.toDouble(),
      stokMinimal: m['stok_minimal'] as int?,
      dirty: m['dirty'] as int? ?? 0,
      deleted: m['deleted'] as int? ?? 0,
    );
  }

  factory Product.fromServerJson(Map<String, dynamic> json) {
    return Product(
      serverId: (json['id'] as num?)?.toInt(),
      nama: json['nama'] as String? ?? '',
      harga: (json['harga'] as num?)?.toDouble() ?? 0.0,
      stok: (json['stok'] as num?)?.toInt() ?? 0,
      deskripsi: json['deskripsi'] as String?,
      gambar: json['gambar'] as String?,
      kategori: json['kategori'] as String?,
      hargaModal: (json['harga_modal'] as num?)?.toDouble(),
      stokMinimal: (json['stok_minimal'] as num?)?.toInt(),
      dirty: 0,
      deleted: 0,
    );
  }

  String toJson() => json.encode(toMap());
}
