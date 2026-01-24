import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'database_native.dart' if (kIsWeb) 'dart:async';

part 'database.g.dart';

// ============ TABLES ============

@DataClassName('Produk')
class TblProduk extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nama => text()();
  TextColumn get deskripsi => text().nullable()();
  RealColumn get harga => real()();
  RealColumn get hargaBeli => real().nullable()();
  IntColumn get stok => integer()();
  TextColumn get kategori => text().nullable()();
  TextColumn get gambar => text().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get satuan => text().withDefault(Constant('pcs'))();
  BoolColumn get aktif => boolean().withDefault(Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Transaksi')
class TblTransaksi extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nomorTransaksi => text().unique()();
  DateTimeColumn get tanggal => dateTime()();
  RealColumn get total => real()();
  RealColumn get bayar => real()();
  RealColumn get kembalian => real().nullable()();
  TextColumn get metode =>
      text().withDefault(Constant('cash'))(); // cash, card, e-wallet
  TextColumn get status =>
      text().withDefault(Constant('selesai'))(); // selesai, pending, batal
  TextColumn get catatan => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('DetailTransaksi')
class TblDetailTransaksi extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transaksiId => integer().references(TblTransaksi, #id)();
  IntColumn get produkId => integer().references(TblProduk, #id)();
  IntColumn get jumlah => integer()();
  RealColumn get hargaSatuan => real()();
  RealColumn get subtotal => real()();
  TextColumn get catatan => text().nullable()();
}

@DataClassName('Kategori')
class TblKategori extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nama => text().unique()();
  TextColumn get deskripsi => text().nullable()();
  TextColumn get icon => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Pengeluaran')
class TblPengeluaran extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kategori => text()();
  RealColumn get jumlah => real()();
  DateTimeColumn get tanggal => dateTime()();
  TextColumn get catatan => text().nullable()();
  TextColumn get bukti => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Laporan')
class TblLaporan extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tipe => text()(); // harian, bulanan, tahunan
  DateTimeColumn get tanggal => dateTime()();
  RealColumn get totalPenjualan => real()();
  RealColumn get totalPengeluaran => real()();
  RealColumn get totalKeuntungan => real()();
  IntColumn get jumlahTransaksi => integer()();
  TextColumn get catatan => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ============ DATABASE ============

@DriftDatabase(
  tables: [
    TblProduk,
    TblTransaksi,
    TblDetailTransaksi,
    TblKategori,
    TblPengeluaran,
    TblLaporan,
  ],
)
class PosDatabase extends _$PosDatabase {
  PosDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Initialize sample data if database is empty
  Future<void> ensureSampleData() async {
    try {
      final existingProducts = await getAllProduk();
      
      if (existingProducts.isNotEmpty) {
        if (kDebugMode) print('✅ Database already has ${existingProducts.length} products');
        return;
      }

      if (kDebugMode) print('🔄 Database is empty, adding sample data...');

      // Sample categories
      await into(tblKategori).insert(
        TblKategoriCompanion(
          nama: const Value('Electronics'),
          deskripsi: const Value('Elektronik'),
          icon: const Value('📱'),
        ),
      );
      await into(tblKategori).insert(
        TblKategoriCompanion(
          nama: const Value('Groceries'),
          deskripsi: const Value('Makanan & Minuman'),
          icon: const Value('🛒'),
        ),
      );
      await into(tblKategori).insert(
        TblKategoriCompanion(
          nama: const Value('Other'),
          deskripsi: const Value('Lainnya'),
          icon: const Value('📦'),
        ),
      );

      // Sample products
      await into(tblProduk).insert(
        TblProdukCompanion(
          nama: const Value('Laptop'),
          deskripsi: const Value('Laptop untuk kerja'),
          harga: const Value(8000000.0),
          hargaBeli: const Value(6000000.0),
          stok: const Value(5),
          kategori: const Value('Electronics'),
          satuan: const Value('unit'),
        ),
      );
      await into(tblProduk).insert(
        TblProdukCompanion(
          nama: const Value('Mouse'),
          deskripsi: const Value('Mouse wireless'),
          harga: const Value(150000.0),
          hargaBeli: const Value(100000.0),
          stok: const Value(20),
          kategori: const Value('Electronics'),
          satuan: const Value('pcs'),
        ),
      );
      await into(tblProduk).insert(
        TblProdukCompanion(
          nama: const Value('Kopi'),
          deskripsi: const Value('Kopi arabika premium'),
          harga: const Value(25000.0),
          hargaBeli: const Value(15000.0),
          stok: const Value(50),
          kategori: const Value('Groceries'),
          satuan: const Value('pack'),
        ),
      );

      if (kDebugMode) print('✅ Sample data added successfully');
    } catch (e) {
      if (kDebugMode) print('❌ Error adding sample data: $e');
    }
  }

  // Produk DAO Methods
  Future<List<Produk>> getAllProduk() {
    return select(tblProduk).get();
  }

  Future<Produk?> getProdukById(int id) {
    return (select(tblProduk)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<Produk>> getProdukByCategory(String kategori) {
    return (select(tblProduk)..where((t) => t.kategori.equals(kategori))).get();
  }

  Future<int> insertProduk(Insertable<Produk> produk) {
    return into(tblProduk).insert(produk);
  }

  /// High-level API for adding products with parameters
  Future<int> addProduk({
    required String nama,
    required double harga,
    required double hargaBeli,
    required int stok,
    required String kategori,
    String? deskripsi,
    String? gambar,
    String? barcode,
    String satuan = 'pcs',
  }) async {
    final companion = TblProdukCompanion(
      nama: Value(nama),
      harga: Value(harga),
      hargaBeli: Value(hargaBeli),
      stok: Value(stok),
      kategori: Value(kategori),
      deskripsi: deskripsi != null ? Value(deskripsi) : const Value.absent(),
      gambar: gambar != null ? Value(gambar) : const Value.absent(),
      barcode: barcode != null ? Value(barcode) : const Value.absent(),
      satuan: Value(satuan),
    );
    return insertProduk(companion);
  }

  /// High-level API for updating products
  Future<bool> updateProduk({
    required int id,
    required String nama,
    required double harga,
    required double hargaBeli,
    required int stok,
    required String kategori,
    String? deskripsi,
    String? gambar,
    String? barcode,
    String satuan = 'pcs',
  }) async {
    final companion = TblProdukCompanion(
      id: Value(id),
      nama: Value(nama),
      harga: Value(harga),
      hargaBeli: Value(hargaBeli),
      stok: Value(stok),
      kategori: Value(kategori),
      deskripsi: deskripsi != null ? Value(deskripsi) : const Value.absent(),
      gambar: gambar != null ? Value(gambar) : const Value.absent(),
      barcode: barcode != null ? Value(barcode) : const Value.absent(),
      satuan: Value(satuan),
      updatedAt: Value(DateTime.now()),
    );
    return update(tblProduk).replace(companion);
  }

  Future<bool> updateProdukLowLevel(Insertable<Produk> produk) {
    return update(tblProduk).replace(produk);
  }

  Future<int> deleteProduk(int id) {
    return (delete(tblProduk)..where((t) => t.id.equals(id))).go();
  }

  // Transaksi DAO Methods
  Future<List<Transaksi>> getAllTransaksi() {
    return (select(tblTransaksi)..orderBy([
          (t) => OrderingTerm(expression: t.tanggal, mode: OrderingMode.desc),
        ]))
        .get();
  }

  Future<Transaksi?> getTransaksiById(int id) {
    return (select(
      tblTransaksi,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<Transaksi>> getTransaksiByDate(DateTime tanggal) {
    final startOfDay = DateTime(tanggal.year, tanggal.month, tanggal.day);
    final endOfDay = DateTime(
      tanggal.year,
      tanggal.month,
      tanggal.day,
      23,
      59,
      59,
    );
    return (select(tblTransaksi)..where(
          (t) =>
              t.tanggal.isBiggerOrEqualValue(startOfDay) &
              t.tanggal.isSmallerOrEqualValue(endOfDay),
        ))
        .get();
  }

  Future<int> insertTransaksi(Insertable<Transaksi> transaksi) {
    return into(tblTransaksi).insert(transaksi);
  }

  /// High-level API for adding transactions
  Future<int> addTransaksi({
    required String nomorTransaksi,
    required DateTime tanggal,
    required double total,
    required double bayar,
    double? kembalian,
    String metode = 'cash',
    String status = 'selesai',
    String? catatan,
  }) async {
    final companion = TblTransaksiCompanion(
      nomorTransaksi: Value(nomorTransaksi),
      tanggal: Value(tanggal),
      total: Value(total),
      bayar: Value(bayar),
      kembalian: kembalian != null ? Value(kembalian) : const Value.absent(),
      metode: Value(metode),
      status: Value(status),
      catatan: catatan != null ? Value(catatan) : const Value.absent(),
    );
    return insertTransaksi(companion);
  }

  Future<bool> updateTransaksi(Insertable<Transaksi> transaksi) {
    return update(tblTransaksi).replace(transaksi);
  }

  // Detail Transaksi DAO Methods
  Future<List<DetailTransaksi>> getDetailTransaksi(int transaksiId) {
    return (select(
      tblDetailTransaksi,
    )..where((dt) => dt.transaksiId.equals(transaksiId))).get();
  }

  Future<int> insertDetailTransaksi(Insertable<DetailTransaksi> detail) {
    return into(tblDetailTransaksi).insert(detail);
  }

  /// High-level API for adding transaction details
  Future<int> addDetailTransaksi({
    required int transaksiId,
    required int produkId,
    required int jumlah,
    required double hargaSatuan,
    required double subtotal,
    String? catatan,
  }) async {
    final companion = TblDetailTransaksiCompanion(
      transaksiId: Value(transaksiId),
      produkId: Value(produkId),
      jumlah: Value(jumlah),
      hargaSatuan: Value(hargaSatuan),
      subtotal: Value(subtotal),
      catatan: catatan != null ? Value(catatan) : const Value.absent(),
    );
    return insertDetailTransaksi(companion);
  }

  // Kategori DAO Methods
  Future<List<Kategori>> getAllKategori() {
    return select(tblKategori).get();
  }

  Future<int> insertKategori(Insertable<Kategori> kategori) {
    return into(tblKategori).insert(kategori);
  }

  // Pengeluaran DAO Methods
  Future<List<Pengeluaran>> getAllPengeluaran() {
    return (select(tblPengeluaran)..orderBy([
          (p) => OrderingTerm(expression: p.tanggal, mode: OrderingMode.desc),
        ]))
        .get();
  }

  Future<List<Pengeluaran>> getPengeluaranByDate(DateTime tanggal) {
    final startOfDay = DateTime(tanggal.year, tanggal.month, tanggal.day);
    final endOfDay = DateTime(
      tanggal.year,
      tanggal.month,
      tanggal.day,
      23,
      59,
      59,
    );
    return (select(tblPengeluaran)..where(
          (p) =>
              p.tanggal.isBiggerOrEqualValue(startOfDay) &
              p.tanggal.isSmallerOrEqualValue(endOfDay),
        ))
        .get();
  }

  Future<int> insertPengeluaran(Insertable<Pengeluaran> pengeluaran) {
    return into(tblPengeluaran).insert(pengeluaran);
  }

  // Summary Methods
  Future<Map<String, dynamic>> getDailySummary(DateTime tanggal) async {
    final transaksi = await getTransaksiByDate(tanggal);
    final pengeluaran = await getPengeluaranByDate(tanggal);

    double totalPenjualan = transaksi.fold(0, (sum, t) => sum + t.total);
    double totalPengeluaran = pengeluaran.fold(0, (sum, p) => sum + p.jumlah);
    double totalKeuntungan = totalPenjualan - totalPengeluaran;

    return {
      'totalPenjualan': totalPenjualan,
      'totalPengeluaran': totalPengeluaran,
      'totalKeuntungan': totalKeuntungan,
      'jumlahTransaksi': transaksi.length,
    };
  }
}

LazyDatabase _openConnection() {
  if (kIsWeb) {
    throw UnsupportedError('Database not available on web platform');
  }
  // On native platforms, return native database connection
  return openNativeConnection();
}
