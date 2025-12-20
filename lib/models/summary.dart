class Summary {
  final double totalPendapatan;
  final double totalKeuntungan;
  final int totalTransaksi;
  final double totalPengeluaran;

  Summary({
    required this.totalPendapatan,
    required this.totalKeuntungan,
    required this.totalTransaksi,
    required this.totalPengeluaran,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalPendapatan: double.parse(
        json['total_pendapatan']?.toString() ?? '0',
      ),
      totalKeuntungan: double.parse(
        json['total_keuntungan']?.toString() ?? '0',
      ),
      totalTransaksi: json['total_transaksi'] ?? 0,
      totalPengeluaran: double.parse(
        json['total_pengeluaran']?.toString() ?? '0',
      ),
    );
  }
}
