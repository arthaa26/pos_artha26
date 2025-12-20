import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/product.dart';

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
      version: 1,
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
}
