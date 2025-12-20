class Produk {
  final int? id;
  final String nama;
  final double harga;
  final int stok;
  final String deskripsi;
  final String? kategori; // Kategori produk
  String gambar; // Changed to non-final for mutability
  bool favorite; // local favorite flag

  Produk({
    this.id,
    required this.nama,
    required this.harga,
    required this.stok,
    required this.deskripsi,
    this.kategori,
    required this.gambar,
    this.favorite = false,
  });

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      id: json['id'],
      nama: json['nama'] ?? '',
      harga: double.parse(json['harga']?.toString() ?? '0'),
      stok: int.parse(json['stok']?.toString() ?? '0'),
      deskripsi: json['deskripsi'] ?? '',
      kategori: json['kategori'],
      gambar: json['gambar'] ?? '',
      favorite: json['favorite'] == true || json['favorite'] == 'true'
          ? true
          : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'harga': harga,
      'stok': stok,
      'deskripsi': deskripsi,
      'kategori': kategori,
      'gambar': gambar,
      'favorite': favorite,
    };
  }
}
