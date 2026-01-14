import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/product.dart';
import '../models/transaksi.dart';

class LocalDbHelper {
  static final LocalDbHelper _instance = LocalDbHelper._internal();
  factory LocalDbHelper() => _instance;
  LocalDbHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'pos_artha26_local.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE products (
          local_id INTEGER PRIMARY KEY AUTOINCREMENT,
          server_id INTEGER,
          nama TEXT NOT NULL,
          harga REAL NOT NULL,
          stok INTEGER DEFAULT 0,
          deskripsi TEXT,
          gambar TEXT,
          dirty INTEGER DEFAULT 1,
          deleted INTEGER DEFAULT 0
        )
      ''');
        await db.execute('''
        CREATE TABLE transaksi (
          local_id INTEGER PRIMARY KEY AUTOINCREMENT,
          server_id INTEGER,
          pendapatan REAL NOT NULL,
          keuntungan REAL NOT NULL,
          pengeluaran REAL NOT NULL,
          deskripsi TEXT,
          tanggal TEXT NOT NULL,
          items TEXT, -- JSON string
          paymentMethod TEXT,
          cashGiven REAL,
          change REAL,
          dirty INTEGER DEFAULT 1
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
          CREATE TABLE transaksi (
            local_id INTEGER PRIMARY KEY AUTOINCREMENT,
            server_id INTEGER,
            pendapatan REAL NOT NULL,
            keuntungan REAL NOT NULL,
            pengeluaran REAL NOT NULL,
            deskripsi TEXT,
            tanggal TEXT NOT NULL,
            items TEXT, -- JSON string
            paymentMethod TEXT,
            cashGiven REAL,
            change REAL,
            dirty INTEGER DEFAULT 1
          )
        ''');
        }
      },
    );
  }

  Future<int> insertProduct(Product p) async {
    final database = await db;
    final id = await database.insert('products', p.toMap());
    return id;
  }

  Future<int> updateProduct(Product p) async {
    final database = await db;
    p.dirty = 1;
    return await database.update(
      'products',
      p.toMap(),
      where: 'local_id = ?',
      whereArgs: [p.localId],
    );
  }

  Future<int> markDeleted(Product p) async {
    final database = await db;
    return await database.update(
      'products',
      {'deleted': 1, 'dirty': 1},
      where: 'local_id = ?',
      whereArgs: [p.localId],
    );
  }

  Future<int> deleteLocal(int localId) async {
    final database = await db;
    return await database.delete(
      'products',
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  Future<List<Product>> getAllProducts() async {
    final database = await db;
    final rows = await database.query('products', orderBy: 'local_id DESC');
    return rows.map((r) => Product.fromMap(r)).toList();
  }

  Future<List<Product>> getDirtyProducts() async {
    final database = await db;
    final rows = await database.query('products', where: 'dirty = 1');
    return rows.map((r) => Product.fromMap(r)).toList();
  }

  Future<void> markClean(int localId, {int? serverId}) async {
    final database = await db;
    final Map<String, Object?> values = {'dirty': 0, 'deleted': 0};
    if (serverId != null) values['server_id'] = serverId;
    await database.update(
      'products',
      values,
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  Future<Product?> findByServerId(int serverId) async {
    final database = await db;
    final rows = await database.query(
      'products',
      where: 'server_id = ?',
      whereArgs: [serverId],
    );
    if (rows.isEmpty) return null;
    return Product.fromMap(rows.first);
  }

  Future<void> upsertFromServer(Product p) async {
    final database = await db;
    if (p.serverId != null) {
      final existing = await findByServerId(p.serverId!);
      if (existing != null) {
        // update existing
        await database.update(
          'products',
          {
            'nama': p.nama,
            'harga': p.harga,
            'stok': p.stok,
            'deskripsi': p.deskripsi,
            'gambar': p.gambar,
            'dirty': 0,
            'deleted': 0,
          },
          where: 'server_id = ?',
          whereArgs: [p.serverId],
        );
        return;
      }
    }
    // insert new
    await database.insert('products', {
      'server_id': p.serverId,
      'nama': p.nama,
      'harga': p.harga,
      'stok': p.stok,
      'deskripsi': p.deskripsi,
      'gambar': p.gambar,
      'dirty': 0,
      'deleted': 0,
    });
  }

  // Transaksi methods
  Future<int> insertTransaksi(Transaksi t) async {
    final database = await db;
    final map = t.toJson();
    map['items'] = json.encode(t.items ?? []);
    map['dirty'] = 1;
    map.remove('id'); // Use local_id
    final id = await database.insert('transaksi', map);
    return id;
  }

  Future<List<Transaksi>> getDirtyTransaksi() async {
    final database = await db;
    final rows = await database.query(
      'transaksi',
      where: 'dirty = ?',
      whereArgs: [1],
    );
    return rows.map((row) {
      final map = Map<String, dynamic>.from(row);
      map['items'] = json.decode(map['items'] ?? '[]');
      map['local_id'] = map['local_id'];
      return Transaksi.fromJson(map);
    }).toList();
  }

  Future<void> markTransaksiSynced(int localId, int serverId) async {
    final database = await db;
    await database.update(
      'transaksi',
      {'dirty': 0, 'server_id': serverId},
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  Future<List<Transaksi>> getAllTransaksi() async {
    final database = await db;
    final rows = await database.query('transaksi');
    return rows.map((row) {
      final map = Map<String, dynamic>.from(row);
      map['items'] = json.decode(map['items'] ?? '[]');
      map['local_id'] = map['local_id'];
      return Transaksi.fromJson(map);
    }).toList();
  }
}
