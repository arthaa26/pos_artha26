class Transaksi {
  final int? id;
  final int? localId; // For local storage
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
    this.localId,
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
      localId: json['local_id'],
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
      'id': id,
      'local_id': localId,
      'pendapatan': pendapatan,
      'keuntungan': keuntungan,
      'pengeluaran': pengeluaran,
      'deskripsi': deskripsi,
      'tanggal': tanggal.toIso8601String(),
      'kategori': kategori,
      'items': items,
      'paymentMethod': paymentMethod,
      'cashGiven': cashGiven,
      'change': change,
    };
  }

  Transaksi copyWith({
    int? id,
    int? localId,
    double? pendapatan,
    double? keuntungan,
    double? pengeluaran,
    String? deskripsi,
    DateTime? tanggal,
    String? kategori,
    List<Map<String, dynamic>>? items,
    String? paymentMethod,
    double? cashGiven,
    double? change,
  }) {
    return Transaksi(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      pendapatan: pendapatan ?? this.pendapatan,
      keuntungan: keuntungan ?? this.keuntungan,
      pengeluaran: pengeluaran ?? this.pengeluaran,
      deskripsi: deskripsi ?? this.deskripsi,
      tanggal: tanggal ?? this.tanggal,
      kategori: kategori ?? this.kategori,
      items: items ?? this.items,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cashGiven: cashGiven ?? this.cashGiven,
      change: change ?? this.change,
    );
  }
}
