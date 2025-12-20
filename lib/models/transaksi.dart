class Transaksi {
  final int? id;
  final double pendapatan;
  final double keuntungan;
  final double pengeluaran;
  final String deskripsi;
  final DateTime tanggal;
  final String? kategori; // Kategori pengeluaran
  final List<Map<String, dynamic>>? items; // Detail produk yang dibeli
  final String? paymentMethod; // Metode pembayaran
  final double? cashGiven; // Uang yang diberikan (untuk tunai)
  final double? change; // Kembalian

  Transaksi({
    this.id,
    required this.pendapatan,
    required this.keuntungan,
    required this.pengeluaran,
    required this.deskripsi,
    required this.tanggal,
    this.kategori,
    this.items,
    this.paymentMethod,
    this.cashGiven,
    this.change,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>>? items;
    if (json['items'] != null) {
      items = List<Map<String, dynamic>>.from(json['items']);
    }

    return Transaksi(
      id: json['id'],
      pendapatan: double.parse(json['pendapatan']?.toString() ?? '0'),
      keuntungan: double.parse(json['keuntungan']?.toString() ?? '0'),
      pengeluaran: double.parse(json['pengeluaran']?.toString() ?? '0'),
      deskripsi: json['deskripsi'] ?? '',
      tanggal: DateTime.parse(json['tanggal']),
      kategori: json['kategori'],
      items: items,
      paymentMethod: json['paymentMethod'],
      cashGiven: json['cashGiven'] != null
          ? double.parse(json['cashGiven'].toString())
          : null,
      change: json['change'] != null
          ? double.parse(json['change'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pendapatan': pendapatan,
      'keuntungan': keuntungan,
      'pengeluaran': pengeluaran,
      'deskripsi': deskripsi,
      'kategori': kategori,
      'items': items,
      'paymentMethod': paymentMethod,
      'cashGiven': cashGiven,
      'change': change,
    };
  }
}
