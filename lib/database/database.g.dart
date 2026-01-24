// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TblProdukTable extends TblProduk
    with TableInfo<$TblProdukTable, Produk> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TblProdukTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama = GeneratedColumn<String>(
    'nama',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deskripsiMeta = const VerificationMeta(
    'deskripsi',
  );
  @override
  late final GeneratedColumn<String> deskripsi = GeneratedColumn<String>(
    'deskripsi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hargaMeta = const VerificationMeta('harga');
  @override
  late final GeneratedColumn<double> harga = GeneratedColumn<double>(
    'harga',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hargaBeliMeta = const VerificationMeta(
    'hargaBeli',
  );
  @override
  late final GeneratedColumn<double> hargaBeli = GeneratedColumn<double>(
    'harga_beli',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stokMeta = const VerificationMeta('stok');
  @override
  late final GeneratedColumn<int> stok = GeneratedColumn<int>(
    'stok',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kategoriMeta = const VerificationMeta(
    'kategori',
  );
  @override
  late final GeneratedColumn<String> kategori = GeneratedColumn<String>(
    'kategori',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gambarMeta = const VerificationMeta('gambar');
  @override
  late final GeneratedColumn<String> gambar = GeneratedColumn<String>(
    'gambar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _satuanMeta = const VerificationMeta('satuan');
  @override
  late final GeneratedColumn<String> satuan = GeneratedColumn<String>(
    'satuan',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant('pcs'),
  );
  static const VerificationMeta _aktifMeta = const VerificationMeta('aktif');
  @override
  late final GeneratedColumn<bool> aktif = GeneratedColumn<bool>(
    'aktif',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("aktif" IN (0, 1))',
    ),
    defaultValue: Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nama,
    deskripsi,
    harga,
    hargaBeli,
    stok,
    kategori,
    gambar,
    barcode,
    satuan,
    aktif,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tbl_produk';
  @override
  VerificationContext validateIntegrity(
    Insertable<Produk> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nama')) {
      context.handle(
        _namaMeta,
        nama.isAcceptableOrUnknown(data['nama']!, _namaMeta),
      );
    } else if (isInserting) {
      context.missing(_namaMeta);
    }
    if (data.containsKey('deskripsi')) {
      context.handle(
        _deskripsiMeta,
        deskripsi.isAcceptableOrUnknown(data['deskripsi']!, _deskripsiMeta),
      );
    }
    if (data.containsKey('harga')) {
      context.handle(
        _hargaMeta,
        harga.isAcceptableOrUnknown(data['harga']!, _hargaMeta),
      );
    } else if (isInserting) {
      context.missing(_hargaMeta);
    }
    if (data.containsKey('harga_beli')) {
      context.handle(
        _hargaBeliMeta,
        hargaBeli.isAcceptableOrUnknown(data['harga_beli']!, _hargaBeliMeta),
      );
    }
    if (data.containsKey('stok')) {
      context.handle(
        _stokMeta,
        stok.isAcceptableOrUnknown(data['stok']!, _stokMeta),
      );
    } else if (isInserting) {
      context.missing(_stokMeta);
    }
    if (data.containsKey('kategori')) {
      context.handle(
        _kategoriMeta,
        kategori.isAcceptableOrUnknown(data['kategori']!, _kategoriMeta),
      );
    }
    if (data.containsKey('gambar')) {
      context.handle(
        _gambarMeta,
        gambar.isAcceptableOrUnknown(data['gambar']!, _gambarMeta),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('satuan')) {
      context.handle(
        _satuanMeta,
        satuan.isAcceptableOrUnknown(data['satuan']!, _satuanMeta),
      );
    }
    if (data.containsKey('aktif')) {
      context.handle(
        _aktifMeta,
        aktif.isAcceptableOrUnknown(data['aktif']!, _aktifMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Produk map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Produk(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama'],
      )!,
      deskripsi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deskripsi'],
      ),
      harga: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}harga'],
      )!,
      hargaBeli: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}harga_beli'],
      ),
      stok: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stok'],
      )!,
      kategori: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kategori'],
      ),
      gambar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gambar'],
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      satuan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}satuan'],
      )!,
      aktif: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}aktif'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TblProdukTable createAlias(String alias) {
    return $TblProdukTable(attachedDatabase, alias);
  }
}

class Produk extends DataClass implements Insertable<Produk> {
  final int id;
  final String nama;
  final String? deskripsi;
  final double harga;
  final double? hargaBeli;
  final int stok;
  final String? kategori;
  final String? gambar;
  final String? barcode;
  final String satuan;
  final bool aktif;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Produk({
    required this.id,
    required this.nama,
    this.deskripsi,
    required this.harga,
    this.hargaBeli,
    required this.stok,
    this.kategori,
    this.gambar,
    this.barcode,
    required this.satuan,
    required this.aktif,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nama'] = Variable<String>(nama);
    if (!nullToAbsent || deskripsi != null) {
      map['deskripsi'] = Variable<String>(deskripsi);
    }
    map['harga'] = Variable<double>(harga);
    if (!nullToAbsent || hargaBeli != null) {
      map['harga_beli'] = Variable<double>(hargaBeli);
    }
    map['stok'] = Variable<int>(stok);
    if (!nullToAbsent || kategori != null) {
      map['kategori'] = Variable<String>(kategori);
    }
    if (!nullToAbsent || gambar != null) {
      map['gambar'] = Variable<String>(gambar);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['satuan'] = Variable<String>(satuan);
    map['aktif'] = Variable<bool>(aktif);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TblProdukCompanion toCompanion(bool nullToAbsent) {
    return TblProdukCompanion(
      id: Value(id),
      nama: Value(nama),
      deskripsi: deskripsi == null && nullToAbsent
          ? const Value.absent()
          : Value(deskripsi),
      harga: Value(harga),
      hargaBeli: hargaBeli == null && nullToAbsent
          ? const Value.absent()
          : Value(hargaBeli),
      stok: Value(stok),
      kategori: kategori == null && nullToAbsent
          ? const Value.absent()
          : Value(kategori),
      gambar: gambar == null && nullToAbsent
          ? const Value.absent()
          : Value(gambar),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      satuan: Value(satuan),
      aktif: Value(aktif),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Produk.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Produk(
      id: serializer.fromJson<int>(json['id']),
      nama: serializer.fromJson<String>(json['nama']),
      deskripsi: serializer.fromJson<String?>(json['deskripsi']),
      harga: serializer.fromJson<double>(json['harga']),
      hargaBeli: serializer.fromJson<double?>(json['hargaBeli']),
      stok: serializer.fromJson<int>(json['stok']),
      kategori: serializer.fromJson<String?>(json['kategori']),
      gambar: serializer.fromJson<String?>(json['gambar']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      satuan: serializer.fromJson<String>(json['satuan']),
      aktif: serializer.fromJson<bool>(json['aktif']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nama': serializer.toJson<String>(nama),
      'deskripsi': serializer.toJson<String?>(deskripsi),
      'harga': serializer.toJson<double>(harga),
      'hargaBeli': serializer.toJson<double?>(hargaBeli),
      'stok': serializer.toJson<int>(stok),
      'kategori': serializer.toJson<String?>(kategori),
      'gambar': serializer.toJson<String?>(gambar),
      'barcode': serializer.toJson<String?>(barcode),
      'satuan': serializer.toJson<String>(satuan),
      'aktif': serializer.toJson<bool>(aktif),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Produk copyWith({
    int? id,
    String? nama,
    Value<String?> deskripsi = const Value.absent(),
    double? harga,
    Value<double?> hargaBeli = const Value.absent(),
    int? stok,
    Value<String?> kategori = const Value.absent(),
    Value<String?> gambar = const Value.absent(),
    Value<String?> barcode = const Value.absent(),
    String? satuan,
    bool? aktif,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Produk(
    id: id ?? this.id,
    nama: nama ?? this.nama,
    deskripsi: deskripsi.present ? deskripsi.value : this.deskripsi,
    harga: harga ?? this.harga,
    hargaBeli: hargaBeli.present ? hargaBeli.value : this.hargaBeli,
    stok: stok ?? this.stok,
    kategori: kategori.present ? kategori.value : this.kategori,
    gambar: gambar.present ? gambar.value : this.gambar,
    barcode: barcode.present ? barcode.value : this.barcode,
    satuan: satuan ?? this.satuan,
    aktif: aktif ?? this.aktif,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Produk copyWithCompanion(TblProdukCompanion data) {
    return Produk(
      id: data.id.present ? data.id.value : this.id,
      nama: data.nama.present ? data.nama.value : this.nama,
      deskripsi: data.deskripsi.present ? data.deskripsi.value : this.deskripsi,
      harga: data.harga.present ? data.harga.value : this.harga,
      hargaBeli: data.hargaBeli.present ? data.hargaBeli.value : this.hargaBeli,
      stok: data.stok.present ? data.stok.value : this.stok,
      kategori: data.kategori.present ? data.kategori.value : this.kategori,
      gambar: data.gambar.present ? data.gambar.value : this.gambar,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      satuan: data.satuan.present ? data.satuan.value : this.satuan,
      aktif: data.aktif.present ? data.aktif.value : this.aktif,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Produk(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('deskripsi: $deskripsi, ')
          ..write('harga: $harga, ')
          ..write('hargaBeli: $hargaBeli, ')
          ..write('stok: $stok, ')
          ..write('kategori: $kategori, ')
          ..write('gambar: $gambar, ')
          ..write('barcode: $barcode, ')
          ..write('satuan: $satuan, ')
          ..write('aktif: $aktif, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nama,
    deskripsi,
    harga,
    hargaBeli,
    stok,
    kategori,
    gambar,
    barcode,
    satuan,
    aktif,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Produk &&
          other.id == this.id &&
          other.nama == this.nama &&
          other.deskripsi == this.deskripsi &&
          other.harga == this.harga &&
          other.hargaBeli == this.hargaBeli &&
          other.stok == this.stok &&
          other.kategori == this.kategori &&
          other.gambar == this.gambar &&
          other.barcode == this.barcode &&
          other.satuan == this.satuan &&
          other.aktif == this.aktif &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TblProdukCompanion extends UpdateCompanion<Produk> {
  final Value<int> id;
  final Value<String> nama;
  final Value<String?> deskripsi;
  final Value<double> harga;
  final Value<double?> hargaBeli;
  final Value<int> stok;
  final Value<String?> kategori;
  final Value<String?> gambar;
  final Value<String?> barcode;
  final Value<String> satuan;
  final Value<bool> aktif;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TblProdukCompanion({
    this.id = const Value.absent(),
    this.nama = const Value.absent(),
    this.deskripsi = const Value.absent(),
    this.harga = const Value.absent(),
    this.hargaBeli = const Value.absent(),
    this.stok = const Value.absent(),
    this.kategori = const Value.absent(),
    this.gambar = const Value.absent(),
    this.barcode = const Value.absent(),
    this.satuan = const Value.absent(),
    this.aktif = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TblProdukCompanion.insert({
    this.id = const Value.absent(),
    required String nama,
    this.deskripsi = const Value.absent(),
    required double harga,
    this.hargaBeli = const Value.absent(),
    required int stok,
    this.kategori = const Value.absent(),
    this.gambar = const Value.absent(),
    this.barcode = const Value.absent(),
    this.satuan = const Value.absent(),
    this.aktif = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : nama = Value(nama),
       harga = Value(harga),
       stok = Value(stok);
  static Insertable<Produk> custom({
    Expression<int>? id,
    Expression<String>? nama,
    Expression<String>? deskripsi,
    Expression<double>? harga,
    Expression<double>? hargaBeli,
    Expression<int>? stok,
    Expression<String>? kategori,
    Expression<String>? gambar,
    Expression<String>? barcode,
    Expression<String>? satuan,
    Expression<bool>? aktif,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nama != null) 'nama': nama,
      if (deskripsi != null) 'deskripsi': deskripsi,
      if (harga != null) 'harga': harga,
      if (hargaBeli != null) 'harga_beli': hargaBeli,
      if (stok != null) 'stok': stok,
      if (kategori != null) 'kategori': kategori,
      if (gambar != null) 'gambar': gambar,
      if (barcode != null) 'barcode': barcode,
      if (satuan != null) 'satuan': satuan,
      if (aktif != null) 'aktif': aktif,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TblProdukCompanion copyWith({
    Value<int>? id,
    Value<String>? nama,
    Value<String?>? deskripsi,
    Value<double>? harga,
    Value<double?>? hargaBeli,
    Value<int>? stok,
    Value<String?>? kategori,
    Value<String?>? gambar,
    Value<String?>? barcode,
    Value<String>? satuan,
    Value<bool>? aktif,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return TblProdukCompanion(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      deskripsi: deskripsi ?? this.deskripsi,
      harga: harga ?? this.harga,
      hargaBeli: hargaBeli ?? this.hargaBeli,
      stok: stok ?? this.stok,
      kategori: kategori ?? this.kategori,
      gambar: gambar ?? this.gambar,
      barcode: barcode ?? this.barcode,
      satuan: satuan ?? this.satuan,
      aktif: aktif ?? this.aktif,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (deskripsi.present) {
      map['deskripsi'] = Variable<String>(deskripsi.value);
    }
    if (harga.present) {
      map['harga'] = Variable<double>(harga.value);
    }
    if (hargaBeli.present) {
      map['harga_beli'] = Variable<double>(hargaBeli.value);
    }
    if (stok.present) {
      map['stok'] = Variable<int>(stok.value);
    }
    if (kategori.present) {
      map['kategori'] = Variable<String>(kategori.value);
    }
    if (gambar.present) {
      map['gambar'] = Variable<String>(gambar.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (satuan.present) {
      map['satuan'] = Variable<String>(satuan.value);
    }
    if (aktif.present) {
      map['aktif'] = Variable<bool>(aktif.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TblProdukCompanion(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('deskripsi: $deskripsi, ')
          ..write('harga: $harga, ')
          ..write('hargaBeli: $hargaBeli, ')
          ..write('stok: $stok, ')
          ..write('kategori: $kategori, ')
          ..write('gambar: $gambar, ')
          ..write('barcode: $barcode, ')
          ..write('satuan: $satuan, ')
          ..write('aktif: $aktif, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TblTransaksiTable extends TblTransaksi
    with TableInfo<$TblTransaksiTable, Transaksi> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TblTransaksiTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nomorTransaksiMeta = const VerificationMeta(
    'nomorTransaksi',
  );
  @override
  late final GeneratedColumn<String> nomorTransaksi = GeneratedColumn<String>(
    'nomor_transaksi',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _tanggalMeta = const VerificationMeta(
    'tanggal',
  );
  @override
  late final GeneratedColumn<DateTime> tanggal = GeneratedColumn<DateTime>(
    'tanggal',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bayarMeta = const VerificationMeta('bayar');
  @override
  late final GeneratedColumn<double> bayar = GeneratedColumn<double>(
    'bayar',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kembalianMeta = const VerificationMeta(
    'kembalian',
  );
  @override
  late final GeneratedColumn<double> kembalian = GeneratedColumn<double>(
    'kembalian',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metodeMeta = const VerificationMeta('metode');
  @override
  late final GeneratedColumn<String> metode = GeneratedColumn<String>(
    'metode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant('cash'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant('selesai'),
  );
  static const VerificationMeta _catatanMeta = const VerificationMeta(
    'catatan',
  );
  @override
  late final GeneratedColumn<String> catatan = GeneratedColumn<String>(
    'catatan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nomorTransaksi,
    tanggal,
    total,
    bayar,
    kembalian,
    metode,
    status,
    catatan,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tbl_transaksi';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaksi> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nomor_transaksi')) {
      context.handle(
        _nomorTransaksiMeta,
        nomorTransaksi.isAcceptableOrUnknown(
          data['nomor_transaksi']!,
          _nomorTransaksiMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nomorTransaksiMeta);
    }
    if (data.containsKey('tanggal')) {
      context.handle(
        _tanggalMeta,
        tanggal.isAcceptableOrUnknown(data['tanggal']!, _tanggalMeta),
      );
    } else if (isInserting) {
      context.missing(_tanggalMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('bayar')) {
      context.handle(
        _bayarMeta,
        bayar.isAcceptableOrUnknown(data['bayar']!, _bayarMeta),
      );
    } else if (isInserting) {
      context.missing(_bayarMeta);
    }
    if (data.containsKey('kembalian')) {
      context.handle(
        _kembalianMeta,
        kembalian.isAcceptableOrUnknown(data['kembalian']!, _kembalianMeta),
      );
    }
    if (data.containsKey('metode')) {
      context.handle(
        _metodeMeta,
        metode.isAcceptableOrUnknown(data['metode']!, _metodeMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('catatan')) {
      context.handle(
        _catatanMeta,
        catatan.isAcceptableOrUnknown(data['catatan']!, _catatanMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaksi map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaksi(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nomorTransaksi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nomor_transaksi'],
      )!,
      tanggal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tanggal'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
      bayar: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bayar'],
      )!,
      kembalian: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kembalian'],
      ),
      metode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metode'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      catatan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catatan'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TblTransaksiTable createAlias(String alias) {
    return $TblTransaksiTable(attachedDatabase, alias);
  }
}

class Transaksi extends DataClass implements Insertable<Transaksi> {
  final int id;
  final String nomorTransaksi;
  final DateTime tanggal;
  final double total;
  final double bayar;
  final double? kembalian;
  final String metode;
  final String status;
  final String? catatan;
  final DateTime createdAt;
  const Transaksi({
    required this.id,
    required this.nomorTransaksi,
    required this.tanggal,
    required this.total,
    required this.bayar,
    this.kembalian,
    required this.metode,
    required this.status,
    this.catatan,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nomor_transaksi'] = Variable<String>(nomorTransaksi);
    map['tanggal'] = Variable<DateTime>(tanggal);
    map['total'] = Variable<double>(total);
    map['bayar'] = Variable<double>(bayar);
    if (!nullToAbsent || kembalian != null) {
      map['kembalian'] = Variable<double>(kembalian);
    }
    map['metode'] = Variable<String>(metode);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || catatan != null) {
      map['catatan'] = Variable<String>(catatan);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TblTransaksiCompanion toCompanion(bool nullToAbsent) {
    return TblTransaksiCompanion(
      id: Value(id),
      nomorTransaksi: Value(nomorTransaksi),
      tanggal: Value(tanggal),
      total: Value(total),
      bayar: Value(bayar),
      kembalian: kembalian == null && nullToAbsent
          ? const Value.absent()
          : Value(kembalian),
      metode: Value(metode),
      status: Value(status),
      catatan: catatan == null && nullToAbsent
          ? const Value.absent()
          : Value(catatan),
      createdAt: Value(createdAt),
    );
  }

  factory Transaksi.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaksi(
      id: serializer.fromJson<int>(json['id']),
      nomorTransaksi: serializer.fromJson<String>(json['nomorTransaksi']),
      tanggal: serializer.fromJson<DateTime>(json['tanggal']),
      total: serializer.fromJson<double>(json['total']),
      bayar: serializer.fromJson<double>(json['bayar']),
      kembalian: serializer.fromJson<double?>(json['kembalian']),
      metode: serializer.fromJson<String>(json['metode']),
      status: serializer.fromJson<String>(json['status']),
      catatan: serializer.fromJson<String?>(json['catatan']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nomorTransaksi': serializer.toJson<String>(nomorTransaksi),
      'tanggal': serializer.toJson<DateTime>(tanggal),
      'total': serializer.toJson<double>(total),
      'bayar': serializer.toJson<double>(bayar),
      'kembalian': serializer.toJson<double?>(kembalian),
      'metode': serializer.toJson<String>(metode),
      'status': serializer.toJson<String>(status),
      'catatan': serializer.toJson<String?>(catatan),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Transaksi copyWith({
    int? id,
    String? nomorTransaksi,
    DateTime? tanggal,
    double? total,
    double? bayar,
    Value<double?> kembalian = const Value.absent(),
    String? metode,
    String? status,
    Value<String?> catatan = const Value.absent(),
    DateTime? createdAt,
  }) => Transaksi(
    id: id ?? this.id,
    nomorTransaksi: nomorTransaksi ?? this.nomorTransaksi,
    tanggal: tanggal ?? this.tanggal,
    total: total ?? this.total,
    bayar: bayar ?? this.bayar,
    kembalian: kembalian.present ? kembalian.value : this.kembalian,
    metode: metode ?? this.metode,
    status: status ?? this.status,
    catatan: catatan.present ? catatan.value : this.catatan,
    createdAt: createdAt ?? this.createdAt,
  );
  Transaksi copyWithCompanion(TblTransaksiCompanion data) {
    return Transaksi(
      id: data.id.present ? data.id.value : this.id,
      nomorTransaksi: data.nomorTransaksi.present
          ? data.nomorTransaksi.value
          : this.nomorTransaksi,
      tanggal: data.tanggal.present ? data.tanggal.value : this.tanggal,
      total: data.total.present ? data.total.value : this.total,
      bayar: data.bayar.present ? data.bayar.value : this.bayar,
      kembalian: data.kembalian.present ? data.kembalian.value : this.kembalian,
      metode: data.metode.present ? data.metode.value : this.metode,
      status: data.status.present ? data.status.value : this.status,
      catatan: data.catatan.present ? data.catatan.value : this.catatan,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaksi(')
          ..write('id: $id, ')
          ..write('nomorTransaksi: $nomorTransaksi, ')
          ..write('tanggal: $tanggal, ')
          ..write('total: $total, ')
          ..write('bayar: $bayar, ')
          ..write('kembalian: $kembalian, ')
          ..write('metode: $metode, ')
          ..write('status: $status, ')
          ..write('catatan: $catatan, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nomorTransaksi,
    tanggal,
    total,
    bayar,
    kembalian,
    metode,
    status,
    catatan,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaksi &&
          other.id == this.id &&
          other.nomorTransaksi == this.nomorTransaksi &&
          other.tanggal == this.tanggal &&
          other.total == this.total &&
          other.bayar == this.bayar &&
          other.kembalian == this.kembalian &&
          other.metode == this.metode &&
          other.status == this.status &&
          other.catatan == this.catatan &&
          other.createdAt == this.createdAt);
}

class TblTransaksiCompanion extends UpdateCompanion<Transaksi> {
  final Value<int> id;
  final Value<String> nomorTransaksi;
  final Value<DateTime> tanggal;
  final Value<double> total;
  final Value<double> bayar;
  final Value<double?> kembalian;
  final Value<String> metode;
  final Value<String> status;
  final Value<String?> catatan;
  final Value<DateTime> createdAt;
  const TblTransaksiCompanion({
    this.id = const Value.absent(),
    this.nomorTransaksi = const Value.absent(),
    this.tanggal = const Value.absent(),
    this.total = const Value.absent(),
    this.bayar = const Value.absent(),
    this.kembalian = const Value.absent(),
    this.metode = const Value.absent(),
    this.status = const Value.absent(),
    this.catatan = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TblTransaksiCompanion.insert({
    this.id = const Value.absent(),
    required String nomorTransaksi,
    required DateTime tanggal,
    required double total,
    required double bayar,
    this.kembalian = const Value.absent(),
    this.metode = const Value.absent(),
    this.status = const Value.absent(),
    this.catatan = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : nomorTransaksi = Value(nomorTransaksi),
       tanggal = Value(tanggal),
       total = Value(total),
       bayar = Value(bayar);
  static Insertable<Transaksi> custom({
    Expression<int>? id,
    Expression<String>? nomorTransaksi,
    Expression<DateTime>? tanggal,
    Expression<double>? total,
    Expression<double>? bayar,
    Expression<double>? kembalian,
    Expression<String>? metode,
    Expression<String>? status,
    Expression<String>? catatan,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nomorTransaksi != null) 'nomor_transaksi': nomorTransaksi,
      if (tanggal != null) 'tanggal': tanggal,
      if (total != null) 'total': total,
      if (bayar != null) 'bayar': bayar,
      if (kembalian != null) 'kembalian': kembalian,
      if (metode != null) 'metode': metode,
      if (status != null) 'status': status,
      if (catatan != null) 'catatan': catatan,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TblTransaksiCompanion copyWith({
    Value<int>? id,
    Value<String>? nomorTransaksi,
    Value<DateTime>? tanggal,
    Value<double>? total,
    Value<double>? bayar,
    Value<double?>? kembalian,
    Value<String>? metode,
    Value<String>? status,
    Value<String?>? catatan,
    Value<DateTime>? createdAt,
  }) {
    return TblTransaksiCompanion(
      id: id ?? this.id,
      nomorTransaksi: nomorTransaksi ?? this.nomorTransaksi,
      tanggal: tanggal ?? this.tanggal,
      total: total ?? this.total,
      bayar: bayar ?? this.bayar,
      kembalian: kembalian ?? this.kembalian,
      metode: metode ?? this.metode,
      status: status ?? this.status,
      catatan: catatan ?? this.catatan,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nomorTransaksi.present) {
      map['nomor_transaksi'] = Variable<String>(nomorTransaksi.value);
    }
    if (tanggal.present) {
      map['tanggal'] = Variable<DateTime>(tanggal.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (bayar.present) {
      map['bayar'] = Variable<double>(bayar.value);
    }
    if (kembalian.present) {
      map['kembalian'] = Variable<double>(kembalian.value);
    }
    if (metode.present) {
      map['metode'] = Variable<String>(metode.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (catatan.present) {
      map['catatan'] = Variable<String>(catatan.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TblTransaksiCompanion(')
          ..write('id: $id, ')
          ..write('nomorTransaksi: $nomorTransaksi, ')
          ..write('tanggal: $tanggal, ')
          ..write('total: $total, ')
          ..write('bayar: $bayar, ')
          ..write('kembalian: $kembalian, ')
          ..write('metode: $metode, ')
          ..write('status: $status, ')
          ..write('catatan: $catatan, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TblDetailTransaksiTable extends TblDetailTransaksi
    with TableInfo<$TblDetailTransaksiTable, DetailTransaksi> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TblDetailTransaksiTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _transaksiIdMeta = const VerificationMeta(
    'transaksiId',
  );
  @override
  late final GeneratedColumn<int> transaksiId = GeneratedColumn<int>(
    'transaksi_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tbl_transaksi (id)',
    ),
  );
  static const VerificationMeta _produkIdMeta = const VerificationMeta(
    'produkId',
  );
  @override
  late final GeneratedColumn<int> produkId = GeneratedColumn<int>(
    'produk_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tbl_produk (id)',
    ),
  );
  static const VerificationMeta _jumlahMeta = const VerificationMeta('jumlah');
  @override
  late final GeneratedColumn<int> jumlah = GeneratedColumn<int>(
    'jumlah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hargaSatuanMeta = const VerificationMeta(
    'hargaSatuan',
  );
  @override
  late final GeneratedColumn<double> hargaSatuan = GeneratedColumn<double>(
    'harga_satuan',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _catatanMeta = const VerificationMeta(
    'catatan',
  );
  @override
  late final GeneratedColumn<String> catatan = GeneratedColumn<String>(
    'catatan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transaksiId,
    produkId,
    jumlah,
    hargaSatuan,
    subtotal,
    catatan,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tbl_detail_transaksi';
  @override
  VerificationContext validateIntegrity(
    Insertable<DetailTransaksi> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaksi_id')) {
      context.handle(
        _transaksiIdMeta,
        transaksiId.isAcceptableOrUnknown(
          data['transaksi_id']!,
          _transaksiIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transaksiIdMeta);
    }
    if (data.containsKey('produk_id')) {
      context.handle(
        _produkIdMeta,
        produkId.isAcceptableOrUnknown(data['produk_id']!, _produkIdMeta),
      );
    } else if (isInserting) {
      context.missing(_produkIdMeta);
    }
    if (data.containsKey('jumlah')) {
      context.handle(
        _jumlahMeta,
        jumlah.isAcceptableOrUnknown(data['jumlah']!, _jumlahMeta),
      );
    } else if (isInserting) {
      context.missing(_jumlahMeta);
    }
    if (data.containsKey('harga_satuan')) {
      context.handle(
        _hargaSatuanMeta,
        hargaSatuan.isAcceptableOrUnknown(
          data['harga_satuan']!,
          _hargaSatuanMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hargaSatuanMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('catatan')) {
      context.handle(
        _catatanMeta,
        catatan.isAcceptableOrUnknown(data['catatan']!, _catatanMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DetailTransaksi map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DetailTransaksi(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      transaksiId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaksi_id'],
      )!,
      produkId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}produk_id'],
      )!,
      jumlah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jumlah'],
      )!,
      hargaSatuan: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}harga_satuan'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      catatan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catatan'],
      ),
    );
  }

  @override
  $TblDetailTransaksiTable createAlias(String alias) {
    return $TblDetailTransaksiTable(attachedDatabase, alias);
  }
}

class DetailTransaksi extends DataClass implements Insertable<DetailTransaksi> {
  final int id;
  final int transaksiId;
  final int produkId;
  final int jumlah;
  final double hargaSatuan;
  final double subtotal;
  final String? catatan;
  const DetailTransaksi({
    required this.id,
    required this.transaksiId,
    required this.produkId,
    required this.jumlah,
    required this.hargaSatuan,
    required this.subtotal,
    this.catatan,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaksi_id'] = Variable<int>(transaksiId);
    map['produk_id'] = Variable<int>(produkId);
    map['jumlah'] = Variable<int>(jumlah);
    map['harga_satuan'] = Variable<double>(hargaSatuan);
    map['subtotal'] = Variable<double>(subtotal);
    if (!nullToAbsent || catatan != null) {
      map['catatan'] = Variable<String>(catatan);
    }
    return map;
  }

  TblDetailTransaksiCompanion toCompanion(bool nullToAbsent) {
    return TblDetailTransaksiCompanion(
      id: Value(id),
      transaksiId: Value(transaksiId),
      produkId: Value(produkId),
      jumlah: Value(jumlah),
      hargaSatuan: Value(hargaSatuan),
      subtotal: Value(subtotal),
      catatan: catatan == null && nullToAbsent
          ? const Value.absent()
          : Value(catatan),
    );
  }

  factory DetailTransaksi.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DetailTransaksi(
      id: serializer.fromJson<int>(json['id']),
      transaksiId: serializer.fromJson<int>(json['transaksiId']),
      produkId: serializer.fromJson<int>(json['produkId']),
      jumlah: serializer.fromJson<int>(json['jumlah']),
      hargaSatuan: serializer.fromJson<double>(json['hargaSatuan']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      catatan: serializer.fromJson<String?>(json['catatan']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transaksiId': serializer.toJson<int>(transaksiId),
      'produkId': serializer.toJson<int>(produkId),
      'jumlah': serializer.toJson<int>(jumlah),
      'hargaSatuan': serializer.toJson<double>(hargaSatuan),
      'subtotal': serializer.toJson<double>(subtotal),
      'catatan': serializer.toJson<String?>(catatan),
    };
  }

  DetailTransaksi copyWith({
    int? id,
    int? transaksiId,
    int? produkId,
    int? jumlah,
    double? hargaSatuan,
    double? subtotal,
    Value<String?> catatan = const Value.absent(),
  }) => DetailTransaksi(
    id: id ?? this.id,
    transaksiId: transaksiId ?? this.transaksiId,
    produkId: produkId ?? this.produkId,
    jumlah: jumlah ?? this.jumlah,
    hargaSatuan: hargaSatuan ?? this.hargaSatuan,
    subtotal: subtotal ?? this.subtotal,
    catatan: catatan.present ? catatan.value : this.catatan,
  );
  DetailTransaksi copyWithCompanion(TblDetailTransaksiCompanion data) {
    return DetailTransaksi(
      id: data.id.present ? data.id.value : this.id,
      transaksiId: data.transaksiId.present
          ? data.transaksiId.value
          : this.transaksiId,
      produkId: data.produkId.present ? data.produkId.value : this.produkId,
      jumlah: data.jumlah.present ? data.jumlah.value : this.jumlah,
      hargaSatuan: data.hargaSatuan.present
          ? data.hargaSatuan.value
          : this.hargaSatuan,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      catatan: data.catatan.present ? data.catatan.value : this.catatan,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DetailTransaksi(')
          ..write('id: $id, ')
          ..write('transaksiId: $transaksiId, ')
          ..write('produkId: $produkId, ')
          ..write('jumlah: $jumlah, ')
          ..write('hargaSatuan: $hargaSatuan, ')
          ..write('subtotal: $subtotal, ')
          ..write('catatan: $catatan')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transaksiId,
    produkId,
    jumlah,
    hargaSatuan,
    subtotal,
    catatan,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DetailTransaksi &&
          other.id == this.id &&
          other.transaksiId == this.transaksiId &&
          other.produkId == this.produkId &&
          other.jumlah == this.jumlah &&
          other.hargaSatuan == this.hargaSatuan &&
          other.subtotal == this.subtotal &&
          other.catatan == this.catatan);
}

class TblDetailTransaksiCompanion extends UpdateCompanion<DetailTransaksi> {
  final Value<int> id;
  final Value<int> transaksiId;
  final Value<int> produkId;
  final Value<int> jumlah;
  final Value<double> hargaSatuan;
  final Value<double> subtotal;
  final Value<String?> catatan;
  const TblDetailTransaksiCompanion({
    this.id = const Value.absent(),
    this.transaksiId = const Value.absent(),
    this.produkId = const Value.absent(),
    this.jumlah = const Value.absent(),
    this.hargaSatuan = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.catatan = const Value.absent(),
  });
  TblDetailTransaksiCompanion.insert({
    this.id = const Value.absent(),
    required int transaksiId,
    required int produkId,
    required int jumlah,
    required double hargaSatuan,
    required double subtotal,
    this.catatan = const Value.absent(),
  }) : transaksiId = Value(transaksiId),
       produkId = Value(produkId),
       jumlah = Value(jumlah),
       hargaSatuan = Value(hargaSatuan),
       subtotal = Value(subtotal);
  static Insertable<DetailTransaksi> custom({
    Expression<int>? id,
    Expression<int>? transaksiId,
    Expression<int>? produkId,
    Expression<int>? jumlah,
    Expression<double>? hargaSatuan,
    Expression<double>? subtotal,
    Expression<String>? catatan,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transaksiId != null) 'transaksi_id': transaksiId,
      if (produkId != null) 'produk_id': produkId,
      if (jumlah != null) 'jumlah': jumlah,
      if (hargaSatuan != null) 'harga_satuan': hargaSatuan,
      if (subtotal != null) 'subtotal': subtotal,
      if (catatan != null) 'catatan': catatan,
    });
  }

  TblDetailTransaksiCompanion copyWith({
    Value<int>? id,
    Value<int>? transaksiId,
    Value<int>? produkId,
    Value<int>? jumlah,
    Value<double>? hargaSatuan,
    Value<double>? subtotal,
    Value<String?>? catatan,
  }) {
    return TblDetailTransaksiCompanion(
      id: id ?? this.id,
      transaksiId: transaksiId ?? this.transaksiId,
      produkId: produkId ?? this.produkId,
      jumlah: jumlah ?? this.jumlah,
      hargaSatuan: hargaSatuan ?? this.hargaSatuan,
      subtotal: subtotal ?? this.subtotal,
      catatan: catatan ?? this.catatan,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transaksiId.present) {
      map['transaksi_id'] = Variable<int>(transaksiId.value);
    }
    if (produkId.present) {
      map['produk_id'] = Variable<int>(produkId.value);
    }
    if (jumlah.present) {
      map['jumlah'] = Variable<int>(jumlah.value);
    }
    if (hargaSatuan.present) {
      map['harga_satuan'] = Variable<double>(hargaSatuan.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (catatan.present) {
      map['catatan'] = Variable<String>(catatan.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TblDetailTransaksiCompanion(')
          ..write('id: $id, ')
          ..write('transaksiId: $transaksiId, ')
          ..write('produkId: $produkId, ')
          ..write('jumlah: $jumlah, ')
          ..write('hargaSatuan: $hargaSatuan, ')
          ..write('subtotal: $subtotal, ')
          ..write('catatan: $catatan')
          ..write(')'))
        .toString();
  }
}

class $TblKategoriTable extends TblKategori
    with TableInfo<$TblKategoriTable, Kategori> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TblKategoriTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama = GeneratedColumn<String>(
    'nama',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _deskripsiMeta = const VerificationMeta(
    'deskripsi',
  );
  @override
  late final GeneratedColumn<String> deskripsi = GeneratedColumn<String>(
    'deskripsi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, nama, deskripsi, icon, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tbl_kategori';
  @override
  VerificationContext validateIntegrity(
    Insertable<Kategori> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nama')) {
      context.handle(
        _namaMeta,
        nama.isAcceptableOrUnknown(data['nama']!, _namaMeta),
      );
    } else if (isInserting) {
      context.missing(_namaMeta);
    }
    if (data.containsKey('deskripsi')) {
      context.handle(
        _deskripsiMeta,
        deskripsi.isAcceptableOrUnknown(data['deskripsi']!, _deskripsiMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Kategori map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Kategori(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama'],
      )!,
      deskripsi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deskripsi'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TblKategoriTable createAlias(String alias) {
    return $TblKategoriTable(attachedDatabase, alias);
  }
}

class Kategori extends DataClass implements Insertable<Kategori> {
  final int id;
  final String nama;
  final String? deskripsi;
  final String? icon;
  final DateTime createdAt;
  const Kategori({
    required this.id,
    required this.nama,
    this.deskripsi,
    this.icon,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nama'] = Variable<String>(nama);
    if (!nullToAbsent || deskripsi != null) {
      map['deskripsi'] = Variable<String>(deskripsi);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TblKategoriCompanion toCompanion(bool nullToAbsent) {
    return TblKategoriCompanion(
      id: Value(id),
      nama: Value(nama),
      deskripsi: deskripsi == null && nullToAbsent
          ? const Value.absent()
          : Value(deskripsi),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      createdAt: Value(createdAt),
    );
  }

  factory Kategori.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Kategori(
      id: serializer.fromJson<int>(json['id']),
      nama: serializer.fromJson<String>(json['nama']),
      deskripsi: serializer.fromJson<String?>(json['deskripsi']),
      icon: serializer.fromJson<String?>(json['icon']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nama': serializer.toJson<String>(nama),
      'deskripsi': serializer.toJson<String?>(deskripsi),
      'icon': serializer.toJson<String?>(icon),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Kategori copyWith({
    int? id,
    String? nama,
    Value<String?> deskripsi = const Value.absent(),
    Value<String?> icon = const Value.absent(),
    DateTime? createdAt,
  }) => Kategori(
    id: id ?? this.id,
    nama: nama ?? this.nama,
    deskripsi: deskripsi.present ? deskripsi.value : this.deskripsi,
    icon: icon.present ? icon.value : this.icon,
    createdAt: createdAt ?? this.createdAt,
  );
  Kategori copyWithCompanion(TblKategoriCompanion data) {
    return Kategori(
      id: data.id.present ? data.id.value : this.id,
      nama: data.nama.present ? data.nama.value : this.nama,
      deskripsi: data.deskripsi.present ? data.deskripsi.value : this.deskripsi,
      icon: data.icon.present ? data.icon.value : this.icon,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Kategori(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('deskripsi: $deskripsi, ')
          ..write('icon: $icon, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nama, deskripsi, icon, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Kategori &&
          other.id == this.id &&
          other.nama == this.nama &&
          other.deskripsi == this.deskripsi &&
          other.icon == this.icon &&
          other.createdAt == this.createdAt);
}

class TblKategoriCompanion extends UpdateCompanion<Kategori> {
  final Value<int> id;
  final Value<String> nama;
  final Value<String?> deskripsi;
  final Value<String?> icon;
  final Value<DateTime> createdAt;
  const TblKategoriCompanion({
    this.id = const Value.absent(),
    this.nama = const Value.absent(),
    this.deskripsi = const Value.absent(),
    this.icon = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TblKategoriCompanion.insert({
    this.id = const Value.absent(),
    required String nama,
    this.deskripsi = const Value.absent(),
    this.icon = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : nama = Value(nama);
  static Insertable<Kategori> custom({
    Expression<int>? id,
    Expression<String>? nama,
    Expression<String>? deskripsi,
    Expression<String>? icon,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nama != null) 'nama': nama,
      if (deskripsi != null) 'deskripsi': deskripsi,
      if (icon != null) 'icon': icon,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TblKategoriCompanion copyWith({
    Value<int>? id,
    Value<String>? nama,
    Value<String?>? deskripsi,
    Value<String?>? icon,
    Value<DateTime>? createdAt,
  }) {
    return TblKategoriCompanion(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      deskripsi: deskripsi ?? this.deskripsi,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (deskripsi.present) {
      map['deskripsi'] = Variable<String>(deskripsi.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TblKategoriCompanion(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('deskripsi: $deskripsi, ')
          ..write('icon: $icon, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TblPengeluaranTable extends TblPengeluaran
    with TableInfo<$TblPengeluaranTable, Pengeluaran> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TblPengeluaranTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _kategoriMeta = const VerificationMeta(
    'kategori',
  );
  @override
  late final GeneratedColumn<String> kategori = GeneratedColumn<String>(
    'kategori',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jumlahMeta = const VerificationMeta('jumlah');
  @override
  late final GeneratedColumn<double> jumlah = GeneratedColumn<double>(
    'jumlah',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tanggalMeta = const VerificationMeta(
    'tanggal',
  );
  @override
  late final GeneratedColumn<DateTime> tanggal = GeneratedColumn<DateTime>(
    'tanggal',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _catatanMeta = const VerificationMeta(
    'catatan',
  );
  @override
  late final GeneratedColumn<String> catatan = GeneratedColumn<String>(
    'catatan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _buktiMeta = const VerificationMeta('bukti');
  @override
  late final GeneratedColumn<String> bukti = GeneratedColumn<String>(
    'bukti',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kategori,
    jumlah,
    tanggal,
    catatan,
    bukti,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tbl_pengeluaran';
  @override
  VerificationContext validateIntegrity(
    Insertable<Pengeluaran> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kategori')) {
      context.handle(
        _kategoriMeta,
        kategori.isAcceptableOrUnknown(data['kategori']!, _kategoriMeta),
      );
    } else if (isInserting) {
      context.missing(_kategoriMeta);
    }
    if (data.containsKey('jumlah')) {
      context.handle(
        _jumlahMeta,
        jumlah.isAcceptableOrUnknown(data['jumlah']!, _jumlahMeta),
      );
    } else if (isInserting) {
      context.missing(_jumlahMeta);
    }
    if (data.containsKey('tanggal')) {
      context.handle(
        _tanggalMeta,
        tanggal.isAcceptableOrUnknown(data['tanggal']!, _tanggalMeta),
      );
    } else if (isInserting) {
      context.missing(_tanggalMeta);
    }
    if (data.containsKey('catatan')) {
      context.handle(
        _catatanMeta,
        catatan.isAcceptableOrUnknown(data['catatan']!, _catatanMeta),
      );
    }
    if (data.containsKey('bukti')) {
      context.handle(
        _buktiMeta,
        bukti.isAcceptableOrUnknown(data['bukti']!, _buktiMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pengeluaran map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pengeluaran(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kategori: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kategori'],
      )!,
      jumlah: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}jumlah'],
      )!,
      tanggal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tanggal'],
      )!,
      catatan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catatan'],
      ),
      bukti: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bukti'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TblPengeluaranTable createAlias(String alias) {
    return $TblPengeluaranTable(attachedDatabase, alias);
  }
}

class Pengeluaran extends DataClass implements Insertable<Pengeluaran> {
  final int id;
  final String kategori;
  final double jumlah;
  final DateTime tanggal;
  final String? catatan;
  final String? bukti;
  final DateTime createdAt;
  const Pengeluaran({
    required this.id,
    required this.kategori,
    required this.jumlah,
    required this.tanggal,
    this.catatan,
    this.bukti,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kategori'] = Variable<String>(kategori);
    map['jumlah'] = Variable<double>(jumlah);
    map['tanggal'] = Variable<DateTime>(tanggal);
    if (!nullToAbsent || catatan != null) {
      map['catatan'] = Variable<String>(catatan);
    }
    if (!nullToAbsent || bukti != null) {
      map['bukti'] = Variable<String>(bukti);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TblPengeluaranCompanion toCompanion(bool nullToAbsent) {
    return TblPengeluaranCompanion(
      id: Value(id),
      kategori: Value(kategori),
      jumlah: Value(jumlah),
      tanggal: Value(tanggal),
      catatan: catatan == null && nullToAbsent
          ? const Value.absent()
          : Value(catatan),
      bukti: bukti == null && nullToAbsent
          ? const Value.absent()
          : Value(bukti),
      createdAt: Value(createdAt),
    );
  }

  factory Pengeluaran.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pengeluaran(
      id: serializer.fromJson<int>(json['id']),
      kategori: serializer.fromJson<String>(json['kategori']),
      jumlah: serializer.fromJson<double>(json['jumlah']),
      tanggal: serializer.fromJson<DateTime>(json['tanggal']),
      catatan: serializer.fromJson<String?>(json['catatan']),
      bukti: serializer.fromJson<String?>(json['bukti']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kategori': serializer.toJson<String>(kategori),
      'jumlah': serializer.toJson<double>(jumlah),
      'tanggal': serializer.toJson<DateTime>(tanggal),
      'catatan': serializer.toJson<String?>(catatan),
      'bukti': serializer.toJson<String?>(bukti),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Pengeluaran copyWith({
    int? id,
    String? kategori,
    double? jumlah,
    DateTime? tanggal,
    Value<String?> catatan = const Value.absent(),
    Value<String?> bukti = const Value.absent(),
    DateTime? createdAt,
  }) => Pengeluaran(
    id: id ?? this.id,
    kategori: kategori ?? this.kategori,
    jumlah: jumlah ?? this.jumlah,
    tanggal: tanggal ?? this.tanggal,
    catatan: catatan.present ? catatan.value : this.catatan,
    bukti: bukti.present ? bukti.value : this.bukti,
    createdAt: createdAt ?? this.createdAt,
  );
  Pengeluaran copyWithCompanion(TblPengeluaranCompanion data) {
    return Pengeluaran(
      id: data.id.present ? data.id.value : this.id,
      kategori: data.kategori.present ? data.kategori.value : this.kategori,
      jumlah: data.jumlah.present ? data.jumlah.value : this.jumlah,
      tanggal: data.tanggal.present ? data.tanggal.value : this.tanggal,
      catatan: data.catatan.present ? data.catatan.value : this.catatan,
      bukti: data.bukti.present ? data.bukti.value : this.bukti,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pengeluaran(')
          ..write('id: $id, ')
          ..write('kategori: $kategori, ')
          ..write('jumlah: $jumlah, ')
          ..write('tanggal: $tanggal, ')
          ..write('catatan: $catatan, ')
          ..write('bukti: $bukti, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, kategori, jumlah, tanggal, catatan, bukti, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pengeluaran &&
          other.id == this.id &&
          other.kategori == this.kategori &&
          other.jumlah == this.jumlah &&
          other.tanggal == this.tanggal &&
          other.catatan == this.catatan &&
          other.bukti == this.bukti &&
          other.createdAt == this.createdAt);
}

class TblPengeluaranCompanion extends UpdateCompanion<Pengeluaran> {
  final Value<int> id;
  final Value<String> kategori;
  final Value<double> jumlah;
  final Value<DateTime> tanggal;
  final Value<String?> catatan;
  final Value<String?> bukti;
  final Value<DateTime> createdAt;
  const TblPengeluaranCompanion({
    this.id = const Value.absent(),
    this.kategori = const Value.absent(),
    this.jumlah = const Value.absent(),
    this.tanggal = const Value.absent(),
    this.catatan = const Value.absent(),
    this.bukti = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TblPengeluaranCompanion.insert({
    this.id = const Value.absent(),
    required String kategori,
    required double jumlah,
    required DateTime tanggal,
    this.catatan = const Value.absent(),
    this.bukti = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : kategori = Value(kategori),
       jumlah = Value(jumlah),
       tanggal = Value(tanggal);
  static Insertable<Pengeluaran> custom({
    Expression<int>? id,
    Expression<String>? kategori,
    Expression<double>? jumlah,
    Expression<DateTime>? tanggal,
    Expression<String>? catatan,
    Expression<String>? bukti,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kategori != null) 'kategori': kategori,
      if (jumlah != null) 'jumlah': jumlah,
      if (tanggal != null) 'tanggal': tanggal,
      if (catatan != null) 'catatan': catatan,
      if (bukti != null) 'bukti': bukti,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TblPengeluaranCompanion copyWith({
    Value<int>? id,
    Value<String>? kategori,
    Value<double>? jumlah,
    Value<DateTime>? tanggal,
    Value<String?>? catatan,
    Value<String?>? bukti,
    Value<DateTime>? createdAt,
  }) {
    return TblPengeluaranCompanion(
      id: id ?? this.id,
      kategori: kategori ?? this.kategori,
      jumlah: jumlah ?? this.jumlah,
      tanggal: tanggal ?? this.tanggal,
      catatan: catatan ?? this.catatan,
      bukti: bukti ?? this.bukti,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kategori.present) {
      map['kategori'] = Variable<String>(kategori.value);
    }
    if (jumlah.present) {
      map['jumlah'] = Variable<double>(jumlah.value);
    }
    if (tanggal.present) {
      map['tanggal'] = Variable<DateTime>(tanggal.value);
    }
    if (catatan.present) {
      map['catatan'] = Variable<String>(catatan.value);
    }
    if (bukti.present) {
      map['bukti'] = Variable<String>(bukti.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TblPengeluaranCompanion(')
          ..write('id: $id, ')
          ..write('kategori: $kategori, ')
          ..write('jumlah: $jumlah, ')
          ..write('tanggal: $tanggal, ')
          ..write('catatan: $catatan, ')
          ..write('bukti: $bukti, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TblLaporanTable extends TblLaporan
    with TableInfo<$TblLaporanTable, Laporan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TblLaporanTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tipeMeta = const VerificationMeta('tipe');
  @override
  late final GeneratedColumn<String> tipe = GeneratedColumn<String>(
    'tipe',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tanggalMeta = const VerificationMeta(
    'tanggal',
  );
  @override
  late final GeneratedColumn<DateTime> tanggal = GeneratedColumn<DateTime>(
    'tanggal',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalPenjualanMeta = const VerificationMeta(
    'totalPenjualan',
  );
  @override
  late final GeneratedColumn<double> totalPenjualan = GeneratedColumn<double>(
    'total_penjualan',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalPengeluaranMeta = const VerificationMeta(
    'totalPengeluaran',
  );
  @override
  late final GeneratedColumn<double> totalPengeluaran = GeneratedColumn<double>(
    'total_pengeluaran',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalKeuntunganMeta = const VerificationMeta(
    'totalKeuntungan',
  );
  @override
  late final GeneratedColumn<double> totalKeuntungan = GeneratedColumn<double>(
    'total_keuntungan',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jumlahTransaksiMeta = const VerificationMeta(
    'jumlahTransaksi',
  );
  @override
  late final GeneratedColumn<int> jumlahTransaksi = GeneratedColumn<int>(
    'jumlah_transaksi',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _catatanMeta = const VerificationMeta(
    'catatan',
  );
  @override
  late final GeneratedColumn<String> catatan = GeneratedColumn<String>(
    'catatan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tipe,
    tanggal,
    totalPenjualan,
    totalPengeluaran,
    totalKeuntungan,
    jumlahTransaksi,
    catatan,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tbl_laporan';
  @override
  VerificationContext validateIntegrity(
    Insertable<Laporan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tipe')) {
      context.handle(
        _tipeMeta,
        tipe.isAcceptableOrUnknown(data['tipe']!, _tipeMeta),
      );
    } else if (isInserting) {
      context.missing(_tipeMeta);
    }
    if (data.containsKey('tanggal')) {
      context.handle(
        _tanggalMeta,
        tanggal.isAcceptableOrUnknown(data['tanggal']!, _tanggalMeta),
      );
    } else if (isInserting) {
      context.missing(_tanggalMeta);
    }
    if (data.containsKey('total_penjualan')) {
      context.handle(
        _totalPenjualanMeta,
        totalPenjualan.isAcceptableOrUnknown(
          data['total_penjualan']!,
          _totalPenjualanMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalPenjualanMeta);
    }
    if (data.containsKey('total_pengeluaran')) {
      context.handle(
        _totalPengeluaranMeta,
        totalPengeluaran.isAcceptableOrUnknown(
          data['total_pengeluaran']!,
          _totalPengeluaranMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalPengeluaranMeta);
    }
    if (data.containsKey('total_keuntungan')) {
      context.handle(
        _totalKeuntunganMeta,
        totalKeuntungan.isAcceptableOrUnknown(
          data['total_keuntungan']!,
          _totalKeuntunganMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalKeuntunganMeta);
    }
    if (data.containsKey('jumlah_transaksi')) {
      context.handle(
        _jumlahTransaksiMeta,
        jumlahTransaksi.isAcceptableOrUnknown(
          data['jumlah_transaksi']!,
          _jumlahTransaksiMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_jumlahTransaksiMeta);
    }
    if (data.containsKey('catatan')) {
      context.handle(
        _catatanMeta,
        catatan.isAcceptableOrUnknown(data['catatan']!, _catatanMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Laporan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Laporan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tipe: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipe'],
      )!,
      tanggal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tanggal'],
      )!,
      totalPenjualan: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_penjualan'],
      )!,
      totalPengeluaran: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_pengeluaran'],
      )!,
      totalKeuntungan: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_keuntungan'],
      )!,
      jumlahTransaksi: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jumlah_transaksi'],
      )!,
      catatan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catatan'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TblLaporanTable createAlias(String alias) {
    return $TblLaporanTable(attachedDatabase, alias);
  }
}

class Laporan extends DataClass implements Insertable<Laporan> {
  final int id;
  final String tipe;
  final DateTime tanggal;
  final double totalPenjualan;
  final double totalPengeluaran;
  final double totalKeuntungan;
  final int jumlahTransaksi;
  final String? catatan;
  final DateTime createdAt;
  const Laporan({
    required this.id,
    required this.tipe,
    required this.tanggal,
    required this.totalPenjualan,
    required this.totalPengeluaran,
    required this.totalKeuntungan,
    required this.jumlahTransaksi,
    this.catatan,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tipe'] = Variable<String>(tipe);
    map['tanggal'] = Variable<DateTime>(tanggal);
    map['total_penjualan'] = Variable<double>(totalPenjualan);
    map['total_pengeluaran'] = Variable<double>(totalPengeluaran);
    map['total_keuntungan'] = Variable<double>(totalKeuntungan);
    map['jumlah_transaksi'] = Variable<int>(jumlahTransaksi);
    if (!nullToAbsent || catatan != null) {
      map['catatan'] = Variable<String>(catatan);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TblLaporanCompanion toCompanion(bool nullToAbsent) {
    return TblLaporanCompanion(
      id: Value(id),
      tipe: Value(tipe),
      tanggal: Value(tanggal),
      totalPenjualan: Value(totalPenjualan),
      totalPengeluaran: Value(totalPengeluaran),
      totalKeuntungan: Value(totalKeuntungan),
      jumlahTransaksi: Value(jumlahTransaksi),
      catatan: catatan == null && nullToAbsent
          ? const Value.absent()
          : Value(catatan),
      createdAt: Value(createdAt),
    );
  }

  factory Laporan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Laporan(
      id: serializer.fromJson<int>(json['id']),
      tipe: serializer.fromJson<String>(json['tipe']),
      tanggal: serializer.fromJson<DateTime>(json['tanggal']),
      totalPenjualan: serializer.fromJson<double>(json['totalPenjualan']),
      totalPengeluaran: serializer.fromJson<double>(json['totalPengeluaran']),
      totalKeuntungan: serializer.fromJson<double>(json['totalKeuntungan']),
      jumlahTransaksi: serializer.fromJson<int>(json['jumlahTransaksi']),
      catatan: serializer.fromJson<String?>(json['catatan']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tipe': serializer.toJson<String>(tipe),
      'tanggal': serializer.toJson<DateTime>(tanggal),
      'totalPenjualan': serializer.toJson<double>(totalPenjualan),
      'totalPengeluaran': serializer.toJson<double>(totalPengeluaran),
      'totalKeuntungan': serializer.toJson<double>(totalKeuntungan),
      'jumlahTransaksi': serializer.toJson<int>(jumlahTransaksi),
      'catatan': serializer.toJson<String?>(catatan),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Laporan copyWith({
    int? id,
    String? tipe,
    DateTime? tanggal,
    double? totalPenjualan,
    double? totalPengeluaran,
    double? totalKeuntungan,
    int? jumlahTransaksi,
    Value<String?> catatan = const Value.absent(),
    DateTime? createdAt,
  }) => Laporan(
    id: id ?? this.id,
    tipe: tipe ?? this.tipe,
    tanggal: tanggal ?? this.tanggal,
    totalPenjualan: totalPenjualan ?? this.totalPenjualan,
    totalPengeluaran: totalPengeluaran ?? this.totalPengeluaran,
    totalKeuntungan: totalKeuntungan ?? this.totalKeuntungan,
    jumlahTransaksi: jumlahTransaksi ?? this.jumlahTransaksi,
    catatan: catatan.present ? catatan.value : this.catatan,
    createdAt: createdAt ?? this.createdAt,
  );
  Laporan copyWithCompanion(TblLaporanCompanion data) {
    return Laporan(
      id: data.id.present ? data.id.value : this.id,
      tipe: data.tipe.present ? data.tipe.value : this.tipe,
      tanggal: data.tanggal.present ? data.tanggal.value : this.tanggal,
      totalPenjualan: data.totalPenjualan.present
          ? data.totalPenjualan.value
          : this.totalPenjualan,
      totalPengeluaran: data.totalPengeluaran.present
          ? data.totalPengeluaran.value
          : this.totalPengeluaran,
      totalKeuntungan: data.totalKeuntungan.present
          ? data.totalKeuntungan.value
          : this.totalKeuntungan,
      jumlahTransaksi: data.jumlahTransaksi.present
          ? data.jumlahTransaksi.value
          : this.jumlahTransaksi,
      catatan: data.catatan.present ? data.catatan.value : this.catatan,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Laporan(')
          ..write('id: $id, ')
          ..write('tipe: $tipe, ')
          ..write('tanggal: $tanggal, ')
          ..write('totalPenjualan: $totalPenjualan, ')
          ..write('totalPengeluaran: $totalPengeluaran, ')
          ..write('totalKeuntungan: $totalKeuntungan, ')
          ..write('jumlahTransaksi: $jumlahTransaksi, ')
          ..write('catatan: $catatan, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tipe,
    tanggal,
    totalPenjualan,
    totalPengeluaran,
    totalKeuntungan,
    jumlahTransaksi,
    catatan,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Laporan &&
          other.id == this.id &&
          other.tipe == this.tipe &&
          other.tanggal == this.tanggal &&
          other.totalPenjualan == this.totalPenjualan &&
          other.totalPengeluaran == this.totalPengeluaran &&
          other.totalKeuntungan == this.totalKeuntungan &&
          other.jumlahTransaksi == this.jumlahTransaksi &&
          other.catatan == this.catatan &&
          other.createdAt == this.createdAt);
}

class TblLaporanCompanion extends UpdateCompanion<Laporan> {
  final Value<int> id;
  final Value<String> tipe;
  final Value<DateTime> tanggal;
  final Value<double> totalPenjualan;
  final Value<double> totalPengeluaran;
  final Value<double> totalKeuntungan;
  final Value<int> jumlahTransaksi;
  final Value<String?> catatan;
  final Value<DateTime> createdAt;
  const TblLaporanCompanion({
    this.id = const Value.absent(),
    this.tipe = const Value.absent(),
    this.tanggal = const Value.absent(),
    this.totalPenjualan = const Value.absent(),
    this.totalPengeluaran = const Value.absent(),
    this.totalKeuntungan = const Value.absent(),
    this.jumlahTransaksi = const Value.absent(),
    this.catatan = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TblLaporanCompanion.insert({
    this.id = const Value.absent(),
    required String tipe,
    required DateTime tanggal,
    required double totalPenjualan,
    required double totalPengeluaran,
    required double totalKeuntungan,
    required int jumlahTransaksi,
    this.catatan = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : tipe = Value(tipe),
       tanggal = Value(tanggal),
       totalPenjualan = Value(totalPenjualan),
       totalPengeluaran = Value(totalPengeluaran),
       totalKeuntungan = Value(totalKeuntungan),
       jumlahTransaksi = Value(jumlahTransaksi);
  static Insertable<Laporan> custom({
    Expression<int>? id,
    Expression<String>? tipe,
    Expression<DateTime>? tanggal,
    Expression<double>? totalPenjualan,
    Expression<double>? totalPengeluaran,
    Expression<double>? totalKeuntungan,
    Expression<int>? jumlahTransaksi,
    Expression<String>? catatan,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tipe != null) 'tipe': tipe,
      if (tanggal != null) 'tanggal': tanggal,
      if (totalPenjualan != null) 'total_penjualan': totalPenjualan,
      if (totalPengeluaran != null) 'total_pengeluaran': totalPengeluaran,
      if (totalKeuntungan != null) 'total_keuntungan': totalKeuntungan,
      if (jumlahTransaksi != null) 'jumlah_transaksi': jumlahTransaksi,
      if (catatan != null) 'catatan': catatan,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TblLaporanCompanion copyWith({
    Value<int>? id,
    Value<String>? tipe,
    Value<DateTime>? tanggal,
    Value<double>? totalPenjualan,
    Value<double>? totalPengeluaran,
    Value<double>? totalKeuntungan,
    Value<int>? jumlahTransaksi,
    Value<String?>? catatan,
    Value<DateTime>? createdAt,
  }) {
    return TblLaporanCompanion(
      id: id ?? this.id,
      tipe: tipe ?? this.tipe,
      tanggal: tanggal ?? this.tanggal,
      totalPenjualan: totalPenjualan ?? this.totalPenjualan,
      totalPengeluaran: totalPengeluaran ?? this.totalPengeluaran,
      totalKeuntungan: totalKeuntungan ?? this.totalKeuntungan,
      jumlahTransaksi: jumlahTransaksi ?? this.jumlahTransaksi,
      catatan: catatan ?? this.catatan,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tipe.present) {
      map['tipe'] = Variable<String>(tipe.value);
    }
    if (tanggal.present) {
      map['tanggal'] = Variable<DateTime>(tanggal.value);
    }
    if (totalPenjualan.present) {
      map['total_penjualan'] = Variable<double>(totalPenjualan.value);
    }
    if (totalPengeluaran.present) {
      map['total_pengeluaran'] = Variable<double>(totalPengeluaran.value);
    }
    if (totalKeuntungan.present) {
      map['total_keuntungan'] = Variable<double>(totalKeuntungan.value);
    }
    if (jumlahTransaksi.present) {
      map['jumlah_transaksi'] = Variable<int>(jumlahTransaksi.value);
    }
    if (catatan.present) {
      map['catatan'] = Variable<String>(catatan.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TblLaporanCompanion(')
          ..write('id: $id, ')
          ..write('tipe: $tipe, ')
          ..write('tanggal: $tanggal, ')
          ..write('totalPenjualan: $totalPenjualan, ')
          ..write('totalPengeluaran: $totalPengeluaran, ')
          ..write('totalKeuntungan: $totalKeuntungan, ')
          ..write('jumlahTransaksi: $jumlahTransaksi, ')
          ..write('catatan: $catatan, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$PosDatabase extends GeneratedDatabase {
  _$PosDatabase(QueryExecutor e) : super(e);
  $PosDatabaseManager get managers => $PosDatabaseManager(this);
  late final $TblProdukTable tblProduk = $TblProdukTable(this);
  late final $TblTransaksiTable tblTransaksi = $TblTransaksiTable(this);
  late final $TblDetailTransaksiTable tblDetailTransaksi =
      $TblDetailTransaksiTable(this);
  late final $TblKategoriTable tblKategori = $TblKategoriTable(this);
  late final $TblPengeluaranTable tblPengeluaran = $TblPengeluaranTable(this);
  late final $TblLaporanTable tblLaporan = $TblLaporanTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tblProduk,
    tblTransaksi,
    tblDetailTransaksi,
    tblKategori,
    tblPengeluaran,
    tblLaporan,
  ];
}

typedef $$TblProdukTableCreateCompanionBuilder =
    TblProdukCompanion Function({
      Value<int> id,
      required String nama,
      Value<String?> deskripsi,
      required double harga,
      Value<double?> hargaBeli,
      required int stok,
      Value<String?> kategori,
      Value<String?> gambar,
      Value<String?> barcode,
      Value<String> satuan,
      Value<bool> aktif,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$TblProdukTableUpdateCompanionBuilder =
    TblProdukCompanion Function({
      Value<int> id,
      Value<String> nama,
      Value<String?> deskripsi,
      Value<double> harga,
      Value<double?> hargaBeli,
      Value<int> stok,
      Value<String?> kategori,
      Value<String?> gambar,
      Value<String?> barcode,
      Value<String> satuan,
      Value<bool> aktif,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$TblProdukTableReferences
    extends BaseReferences<_$PosDatabase, $TblProdukTable, Produk> {
  $$TblProdukTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TblDetailTransaksiTable, List<DetailTransaksi>>
  _tblDetailTransaksiRefsTable(_$PosDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.tblDetailTransaksi,
        aliasName: $_aliasNameGenerator(
          db.tblProduk.id,
          db.tblDetailTransaksi.produkId,
        ),
      );

  $$TblDetailTransaksiTableProcessedTableManager get tblDetailTransaksiRefs {
    final manager = $$TblDetailTransaksiTableTableManager(
      $_db,
      $_db.tblDetailTransaksi,
    ).filter((f) => f.produkId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tblDetailTransaksiRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TblProdukTableFilterComposer
    extends Composer<_$PosDatabase, $TblProdukTable> {
  $$TblProdukTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deskripsi => $composableBuilder(
    column: $table.deskripsi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get harga => $composableBuilder(
    column: $table.harga,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hargaBeli => $composableBuilder(
    column: $table.hargaBeli,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stok => $composableBuilder(
    column: $table.stok,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kategori => $composableBuilder(
    column: $table.kategori,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gambar => $composableBuilder(
    column: $table.gambar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get satuan => $composableBuilder(
    column: $table.satuan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get aktif => $composableBuilder(
    column: $table.aktif,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tblDetailTransaksiRefs(
    Expression<bool> Function($$TblDetailTransaksiTableFilterComposer f) f,
  ) {
    final $$TblDetailTransaksiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tblDetailTransaksi,
      getReferencedColumn: (t) => t.produkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TblDetailTransaksiTableFilterComposer(
            $db: $db,
            $table: $db.tblDetailTransaksi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TblProdukTableOrderingComposer
    extends Composer<_$PosDatabase, $TblProdukTable> {
  $$TblProdukTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deskripsi => $composableBuilder(
    column: $table.deskripsi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get harga => $composableBuilder(
    column: $table.harga,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hargaBeli => $composableBuilder(
    column: $table.hargaBeli,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stok => $composableBuilder(
    column: $table.stok,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kategori => $composableBuilder(
    column: $table.kategori,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gambar => $composableBuilder(
    column: $table.gambar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get satuan => $composableBuilder(
    column: $table.satuan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get aktif => $composableBuilder(
    column: $table.aktif,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TblProdukTableAnnotationComposer
    extends Composer<_$PosDatabase, $TblProdukTable> {
  $$TblProdukTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<String> get deskripsi =>
      $composableBuilder(column: $table.deskripsi, builder: (column) => column);

  GeneratedColumn<double> get harga =>
      $composableBuilder(column: $table.harga, builder: (column) => column);

  GeneratedColumn<double> get hargaBeli =>
      $composableBuilder(column: $table.hargaBeli, builder: (column) => column);

  GeneratedColumn<int> get stok =>
      $composableBuilder(column: $table.stok, builder: (column) => column);

  GeneratedColumn<String> get kategori =>
      $composableBuilder(column: $table.kategori, builder: (column) => column);

  GeneratedColumn<String> get gambar =>
      $composableBuilder(column: $table.gambar, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get satuan =>
      $composableBuilder(column: $table.satuan, builder: (column) => column);

  GeneratedColumn<bool> get aktif =>
      $composableBuilder(column: $table.aktif, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> tblDetailTransaksiRefs<T extends Object>(
    Expression<T> Function($$TblDetailTransaksiTableAnnotationComposer a) f,
  ) {
    final $$TblDetailTransaksiTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.tblDetailTransaksi,
          getReferencedColumn: (t) => t.produkId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TblDetailTransaksiTableAnnotationComposer(
                $db: $db,
                $table: $db.tblDetailTransaksi,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TblProdukTableTableManager
    extends
        RootTableManager<
          _$PosDatabase,
          $TblProdukTable,
          Produk,
          $$TblProdukTableFilterComposer,
          $$TblProdukTableOrderingComposer,
          $$TblProdukTableAnnotationComposer,
          $$TblProdukTableCreateCompanionBuilder,
          $$TblProdukTableUpdateCompanionBuilder,
          (Produk, $$TblProdukTableReferences),
          Produk,
          PrefetchHooks Function({bool tblDetailTransaksiRefs})
        > {
  $$TblProdukTableTableManager(_$PosDatabase db, $TblProdukTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TblProdukTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TblProdukTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TblProdukTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nama = const Value.absent(),
                Value<String?> deskripsi = const Value.absent(),
                Value<double> harga = const Value.absent(),
                Value<double?> hargaBeli = const Value.absent(),
                Value<int> stok = const Value.absent(),
                Value<String?> kategori = const Value.absent(),
                Value<String?> gambar = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String> satuan = const Value.absent(),
                Value<bool> aktif = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TblProdukCompanion(
                id: id,
                nama: nama,
                deskripsi: deskripsi,
                harga: harga,
                hargaBeli: hargaBeli,
                stok: stok,
                kategori: kategori,
                gambar: gambar,
                barcode: barcode,
                satuan: satuan,
                aktif: aktif,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nama,
                Value<String?> deskripsi = const Value.absent(),
                required double harga,
                Value<double?> hargaBeli = const Value.absent(),
                required int stok,
                Value<String?> kategori = const Value.absent(),
                Value<String?> gambar = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String> satuan = const Value.absent(),
                Value<bool> aktif = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TblProdukCompanion.insert(
                id: id,
                nama: nama,
                deskripsi: deskripsi,
                harga: harga,
                hargaBeli: hargaBeli,
                stok: stok,
                kategori: kategori,
                gambar: gambar,
                barcode: barcode,
                satuan: satuan,
                aktif: aktif,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TblProdukTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tblDetailTransaksiRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (tblDetailTransaksiRefs) db.tblDetailTransaksi,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tblDetailTransaksiRefs)
                    await $_getPrefetchedData<
                      Produk,
                      $TblProdukTable,
                      DetailTransaksi
                    >(
                      currentTable: table,
                      referencedTable: $$TblProdukTableReferences
                          ._tblDetailTransaksiRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TblProdukTableReferences(
                            db,
                            table,
                            p0,
                          ).tblDetailTransaksiRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.produkId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TblProdukTableProcessedTableManager =
    ProcessedTableManager<
      _$PosDatabase,
      $TblProdukTable,
      Produk,
      $$TblProdukTableFilterComposer,
      $$TblProdukTableOrderingComposer,
      $$TblProdukTableAnnotationComposer,
      $$TblProdukTableCreateCompanionBuilder,
      $$TblProdukTableUpdateCompanionBuilder,
      (Produk, $$TblProdukTableReferences),
      Produk,
      PrefetchHooks Function({bool tblDetailTransaksiRefs})
    >;
typedef $$TblTransaksiTableCreateCompanionBuilder =
    TblTransaksiCompanion Function({
      Value<int> id,
      required String nomorTransaksi,
      required DateTime tanggal,
      required double total,
      required double bayar,
      Value<double?> kembalian,
      Value<String> metode,
      Value<String> status,
      Value<String?> catatan,
      Value<DateTime> createdAt,
    });
typedef $$TblTransaksiTableUpdateCompanionBuilder =
    TblTransaksiCompanion Function({
      Value<int> id,
      Value<String> nomorTransaksi,
      Value<DateTime> tanggal,
      Value<double> total,
      Value<double> bayar,
      Value<double?> kembalian,
      Value<String> metode,
      Value<String> status,
      Value<String?> catatan,
      Value<DateTime> createdAt,
    });

final class $$TblTransaksiTableReferences
    extends BaseReferences<_$PosDatabase, $TblTransaksiTable, Transaksi> {
  $$TblTransaksiTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TblDetailTransaksiTable, List<DetailTransaksi>>
  _tblDetailTransaksiRefsTable(_$PosDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.tblDetailTransaksi,
        aliasName: $_aliasNameGenerator(
          db.tblTransaksi.id,
          db.tblDetailTransaksi.transaksiId,
        ),
      );

  $$TblDetailTransaksiTableProcessedTableManager get tblDetailTransaksiRefs {
    final manager = $$TblDetailTransaksiTableTableManager(
      $_db,
      $_db.tblDetailTransaksi,
    ).filter((f) => f.transaksiId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tblDetailTransaksiRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TblTransaksiTableFilterComposer
    extends Composer<_$PosDatabase, $TblTransaksiTable> {
  $$TblTransaksiTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nomorTransaksi => $composableBuilder(
    column: $table.nomorTransaksi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tanggal => $composableBuilder(
    column: $table.tanggal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bayar => $composableBuilder(
    column: $table.bayar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kembalian => $composableBuilder(
    column: $table.kembalian,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metode => $composableBuilder(
    column: $table.metode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tblDetailTransaksiRefs(
    Expression<bool> Function($$TblDetailTransaksiTableFilterComposer f) f,
  ) {
    final $$TblDetailTransaksiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tblDetailTransaksi,
      getReferencedColumn: (t) => t.transaksiId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TblDetailTransaksiTableFilterComposer(
            $db: $db,
            $table: $db.tblDetailTransaksi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TblTransaksiTableOrderingComposer
    extends Composer<_$PosDatabase, $TblTransaksiTable> {
  $$TblTransaksiTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nomorTransaksi => $composableBuilder(
    column: $table.nomorTransaksi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tanggal => $composableBuilder(
    column: $table.tanggal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bayar => $composableBuilder(
    column: $table.bayar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kembalian => $composableBuilder(
    column: $table.kembalian,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metode => $composableBuilder(
    column: $table.metode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TblTransaksiTableAnnotationComposer
    extends Composer<_$PosDatabase, $TblTransaksiTable> {
  $$TblTransaksiTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nomorTransaksi => $composableBuilder(
    column: $table.nomorTransaksi,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get tanggal =>
      $composableBuilder(column: $table.tanggal, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<double> get bayar =>
      $composableBuilder(column: $table.bayar, builder: (column) => column);

  GeneratedColumn<double> get kembalian =>
      $composableBuilder(column: $table.kembalian, builder: (column) => column);

  GeneratedColumn<String> get metode =>
      $composableBuilder(column: $table.metode, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get catatan =>
      $composableBuilder(column: $table.catatan, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> tblDetailTransaksiRefs<T extends Object>(
    Expression<T> Function($$TblDetailTransaksiTableAnnotationComposer a) f,
  ) {
    final $$TblDetailTransaksiTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.tblDetailTransaksi,
          getReferencedColumn: (t) => t.transaksiId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TblDetailTransaksiTableAnnotationComposer(
                $db: $db,
                $table: $db.tblDetailTransaksi,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TblTransaksiTableTableManager
    extends
        RootTableManager<
          _$PosDatabase,
          $TblTransaksiTable,
          Transaksi,
          $$TblTransaksiTableFilterComposer,
          $$TblTransaksiTableOrderingComposer,
          $$TblTransaksiTableAnnotationComposer,
          $$TblTransaksiTableCreateCompanionBuilder,
          $$TblTransaksiTableUpdateCompanionBuilder,
          (Transaksi, $$TblTransaksiTableReferences),
          Transaksi,
          PrefetchHooks Function({bool tblDetailTransaksiRefs})
        > {
  $$TblTransaksiTableTableManager(_$PosDatabase db, $TblTransaksiTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TblTransaksiTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TblTransaksiTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TblTransaksiTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nomorTransaksi = const Value.absent(),
                Value<DateTime> tanggal = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<double> bayar = const Value.absent(),
                Value<double?> kembalian = const Value.absent(),
                Value<String> metode = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> catatan = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TblTransaksiCompanion(
                id: id,
                nomorTransaksi: nomorTransaksi,
                tanggal: tanggal,
                total: total,
                bayar: bayar,
                kembalian: kembalian,
                metode: metode,
                status: status,
                catatan: catatan,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nomorTransaksi,
                required DateTime tanggal,
                required double total,
                required double bayar,
                Value<double?> kembalian = const Value.absent(),
                Value<String> metode = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> catatan = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TblTransaksiCompanion.insert(
                id: id,
                nomorTransaksi: nomorTransaksi,
                tanggal: tanggal,
                total: total,
                bayar: bayar,
                kembalian: kembalian,
                metode: metode,
                status: status,
                catatan: catatan,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TblTransaksiTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tblDetailTransaksiRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (tblDetailTransaksiRefs) db.tblDetailTransaksi,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tblDetailTransaksiRefs)
                    await $_getPrefetchedData<
                      Transaksi,
                      $TblTransaksiTable,
                      DetailTransaksi
                    >(
                      currentTable: table,
                      referencedTable: $$TblTransaksiTableReferences
                          ._tblDetailTransaksiRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TblTransaksiTableReferences(
                            db,
                            table,
                            p0,
                          ).tblDetailTransaksiRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.transaksiId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TblTransaksiTableProcessedTableManager =
    ProcessedTableManager<
      _$PosDatabase,
      $TblTransaksiTable,
      Transaksi,
      $$TblTransaksiTableFilterComposer,
      $$TblTransaksiTableOrderingComposer,
      $$TblTransaksiTableAnnotationComposer,
      $$TblTransaksiTableCreateCompanionBuilder,
      $$TblTransaksiTableUpdateCompanionBuilder,
      (Transaksi, $$TblTransaksiTableReferences),
      Transaksi,
      PrefetchHooks Function({bool tblDetailTransaksiRefs})
    >;
typedef $$TblDetailTransaksiTableCreateCompanionBuilder =
    TblDetailTransaksiCompanion Function({
      Value<int> id,
      required int transaksiId,
      required int produkId,
      required int jumlah,
      required double hargaSatuan,
      required double subtotal,
      Value<String?> catatan,
    });
typedef $$TblDetailTransaksiTableUpdateCompanionBuilder =
    TblDetailTransaksiCompanion Function({
      Value<int> id,
      Value<int> transaksiId,
      Value<int> produkId,
      Value<int> jumlah,
      Value<double> hargaSatuan,
      Value<double> subtotal,
      Value<String?> catatan,
    });

final class $$TblDetailTransaksiTableReferences
    extends
        BaseReferences<
          _$PosDatabase,
          $TblDetailTransaksiTable,
          DetailTransaksi
        > {
  $$TblDetailTransaksiTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TblTransaksiTable _transaksiIdTable(_$PosDatabase db) =>
      db.tblTransaksi.createAlias(
        $_aliasNameGenerator(
          db.tblDetailTransaksi.transaksiId,
          db.tblTransaksi.id,
        ),
      );

  $$TblTransaksiTableProcessedTableManager get transaksiId {
    final $_column = $_itemColumn<int>('transaksi_id')!;

    final manager = $$TblTransaksiTableTableManager(
      $_db,
      $_db.tblTransaksi,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transaksiIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TblProdukTable _produkIdTable(_$PosDatabase db) =>
      db.tblProduk.createAlias(
        $_aliasNameGenerator(db.tblDetailTransaksi.produkId, db.tblProduk.id),
      );

  $$TblProdukTableProcessedTableManager get produkId {
    final $_column = $_itemColumn<int>('produk_id')!;

    final manager = $$TblProdukTableTableManager(
      $_db,
      $_db.tblProduk,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_produkIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TblDetailTransaksiTableFilterComposer
    extends Composer<_$PosDatabase, $TblDetailTransaksiTable> {
  $$TblDetailTransaksiTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jumlah => $composableBuilder(
    column: $table.jumlah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hargaSatuan => $composableBuilder(
    column: $table.hargaSatuan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnFilters(column),
  );

  $$TblTransaksiTableFilterComposer get transaksiId {
    final $$TblTransaksiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transaksiId,
      referencedTable: $db.tblTransaksi,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TblTransaksiTableFilterComposer(
            $db: $db,
            $table: $db.tblTransaksi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TblProdukTableFilterComposer get produkId {
    final $$TblProdukTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produkId,
      referencedTable: $db.tblProduk,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TblProdukTableFilterComposer(
            $db: $db,
            $table: $db.tblProduk,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TblDetailTransaksiTableOrderingComposer
    extends Composer<_$PosDatabase, $TblDetailTransaksiTable> {
  $$TblDetailTransaksiTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jumlah => $composableBuilder(
    column: $table.jumlah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hargaSatuan => $composableBuilder(
    column: $table.hargaSatuan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnOrderings(column),
  );

  $$TblTransaksiTableOrderingComposer get transaksiId {
    final $$TblTransaksiTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transaksiId,
      referencedTable: $db.tblTransaksi,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TblTransaksiTableOrderingComposer(
            $db: $db,
            $table: $db.tblTransaksi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TblProdukTableOrderingComposer get produkId {
    final $$TblProdukTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produkId,
      referencedTable: $db.tblProduk,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TblProdukTableOrderingComposer(
            $db: $db,
            $table: $db.tblProduk,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TblDetailTransaksiTableAnnotationComposer
    extends Composer<_$PosDatabase, $TblDetailTransaksiTable> {
  $$TblDetailTransaksiTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get jumlah =>
      $composableBuilder(column: $table.jumlah, builder: (column) => column);

  GeneratedColumn<double> get hargaSatuan => $composableBuilder(
    column: $table.hargaSatuan,
    builder: (column) => column,
  );

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<String> get catatan =>
      $composableBuilder(column: $table.catatan, builder: (column) => column);

  $$TblTransaksiTableAnnotationComposer get transaksiId {
    final $$TblTransaksiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transaksiId,
      referencedTable: $db.tblTransaksi,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TblTransaksiTableAnnotationComposer(
            $db: $db,
            $table: $db.tblTransaksi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TblProdukTableAnnotationComposer get produkId {
    final $$TblProdukTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produkId,
      referencedTable: $db.tblProduk,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TblProdukTableAnnotationComposer(
            $db: $db,
            $table: $db.tblProduk,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TblDetailTransaksiTableTableManager
    extends
        RootTableManager<
          _$PosDatabase,
          $TblDetailTransaksiTable,
          DetailTransaksi,
          $$TblDetailTransaksiTableFilterComposer,
          $$TblDetailTransaksiTableOrderingComposer,
          $$TblDetailTransaksiTableAnnotationComposer,
          $$TblDetailTransaksiTableCreateCompanionBuilder,
          $$TblDetailTransaksiTableUpdateCompanionBuilder,
          (DetailTransaksi, $$TblDetailTransaksiTableReferences),
          DetailTransaksi,
          PrefetchHooks Function({bool transaksiId, bool produkId})
        > {
  $$TblDetailTransaksiTableTableManager(
    _$PosDatabase db,
    $TblDetailTransaksiTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TblDetailTransaksiTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TblDetailTransaksiTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TblDetailTransaksiTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> transaksiId = const Value.absent(),
                Value<int> produkId = const Value.absent(),
                Value<int> jumlah = const Value.absent(),
                Value<double> hargaSatuan = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<String?> catatan = const Value.absent(),
              }) => TblDetailTransaksiCompanion(
                id: id,
                transaksiId: transaksiId,
                produkId: produkId,
                jumlah: jumlah,
                hargaSatuan: hargaSatuan,
                subtotal: subtotal,
                catatan: catatan,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int transaksiId,
                required int produkId,
                required int jumlah,
                required double hargaSatuan,
                required double subtotal,
                Value<String?> catatan = const Value.absent(),
              }) => TblDetailTransaksiCompanion.insert(
                id: id,
                transaksiId: transaksiId,
                produkId: produkId,
                jumlah: jumlah,
                hargaSatuan: hargaSatuan,
                subtotal: subtotal,
                catatan: catatan,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TblDetailTransaksiTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transaksiId = false, produkId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (transaksiId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.transaksiId,
                                referencedTable:
                                    $$TblDetailTransaksiTableReferences
                                        ._transaksiIdTable(db),
                                referencedColumn:
                                    $$TblDetailTransaksiTableReferences
                                        ._transaksiIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (produkId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.produkId,
                                referencedTable:
                                    $$TblDetailTransaksiTableReferences
                                        ._produkIdTable(db),
                                referencedColumn:
                                    $$TblDetailTransaksiTableReferences
                                        ._produkIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TblDetailTransaksiTableProcessedTableManager =
    ProcessedTableManager<
      _$PosDatabase,
      $TblDetailTransaksiTable,
      DetailTransaksi,
      $$TblDetailTransaksiTableFilterComposer,
      $$TblDetailTransaksiTableOrderingComposer,
      $$TblDetailTransaksiTableAnnotationComposer,
      $$TblDetailTransaksiTableCreateCompanionBuilder,
      $$TblDetailTransaksiTableUpdateCompanionBuilder,
      (DetailTransaksi, $$TblDetailTransaksiTableReferences),
      DetailTransaksi,
      PrefetchHooks Function({bool transaksiId, bool produkId})
    >;
typedef $$TblKategoriTableCreateCompanionBuilder =
    TblKategoriCompanion Function({
      Value<int> id,
      required String nama,
      Value<String?> deskripsi,
      Value<String?> icon,
      Value<DateTime> createdAt,
    });
typedef $$TblKategoriTableUpdateCompanionBuilder =
    TblKategoriCompanion Function({
      Value<int> id,
      Value<String> nama,
      Value<String?> deskripsi,
      Value<String?> icon,
      Value<DateTime> createdAt,
    });

class $$TblKategoriTableFilterComposer
    extends Composer<_$PosDatabase, $TblKategoriTable> {
  $$TblKategoriTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deskripsi => $composableBuilder(
    column: $table.deskripsi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TblKategoriTableOrderingComposer
    extends Composer<_$PosDatabase, $TblKategoriTable> {
  $$TblKategoriTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deskripsi => $composableBuilder(
    column: $table.deskripsi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TblKategoriTableAnnotationComposer
    extends Composer<_$PosDatabase, $TblKategoriTable> {
  $$TblKategoriTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<String> get deskripsi =>
      $composableBuilder(column: $table.deskripsi, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TblKategoriTableTableManager
    extends
        RootTableManager<
          _$PosDatabase,
          $TblKategoriTable,
          Kategori,
          $$TblKategoriTableFilterComposer,
          $$TblKategoriTableOrderingComposer,
          $$TblKategoriTableAnnotationComposer,
          $$TblKategoriTableCreateCompanionBuilder,
          $$TblKategoriTableUpdateCompanionBuilder,
          (
            Kategori,
            BaseReferences<_$PosDatabase, $TblKategoriTable, Kategori>,
          ),
          Kategori,
          PrefetchHooks Function()
        > {
  $$TblKategoriTableTableManager(_$PosDatabase db, $TblKategoriTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TblKategoriTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TblKategoriTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TblKategoriTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nama = const Value.absent(),
                Value<String?> deskripsi = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TblKategoriCompanion(
                id: id,
                nama: nama,
                deskripsi: deskripsi,
                icon: icon,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nama,
                Value<String?> deskripsi = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TblKategoriCompanion.insert(
                id: id,
                nama: nama,
                deskripsi: deskripsi,
                icon: icon,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TblKategoriTableProcessedTableManager =
    ProcessedTableManager<
      _$PosDatabase,
      $TblKategoriTable,
      Kategori,
      $$TblKategoriTableFilterComposer,
      $$TblKategoriTableOrderingComposer,
      $$TblKategoriTableAnnotationComposer,
      $$TblKategoriTableCreateCompanionBuilder,
      $$TblKategoriTableUpdateCompanionBuilder,
      (Kategori, BaseReferences<_$PosDatabase, $TblKategoriTable, Kategori>),
      Kategori,
      PrefetchHooks Function()
    >;
typedef $$TblPengeluaranTableCreateCompanionBuilder =
    TblPengeluaranCompanion Function({
      Value<int> id,
      required String kategori,
      required double jumlah,
      required DateTime tanggal,
      Value<String?> catatan,
      Value<String?> bukti,
      Value<DateTime> createdAt,
    });
typedef $$TblPengeluaranTableUpdateCompanionBuilder =
    TblPengeluaranCompanion Function({
      Value<int> id,
      Value<String> kategori,
      Value<double> jumlah,
      Value<DateTime> tanggal,
      Value<String?> catatan,
      Value<String?> bukti,
      Value<DateTime> createdAt,
    });

class $$TblPengeluaranTableFilterComposer
    extends Composer<_$PosDatabase, $TblPengeluaranTable> {
  $$TblPengeluaranTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kategori => $composableBuilder(
    column: $table.kategori,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get jumlah => $composableBuilder(
    column: $table.jumlah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tanggal => $composableBuilder(
    column: $table.tanggal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bukti => $composableBuilder(
    column: $table.bukti,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TblPengeluaranTableOrderingComposer
    extends Composer<_$PosDatabase, $TblPengeluaranTable> {
  $$TblPengeluaranTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kategori => $composableBuilder(
    column: $table.kategori,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get jumlah => $composableBuilder(
    column: $table.jumlah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tanggal => $composableBuilder(
    column: $table.tanggal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bukti => $composableBuilder(
    column: $table.bukti,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TblPengeluaranTableAnnotationComposer
    extends Composer<_$PosDatabase, $TblPengeluaranTable> {
  $$TblPengeluaranTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kategori =>
      $composableBuilder(column: $table.kategori, builder: (column) => column);

  GeneratedColumn<double> get jumlah =>
      $composableBuilder(column: $table.jumlah, builder: (column) => column);

  GeneratedColumn<DateTime> get tanggal =>
      $composableBuilder(column: $table.tanggal, builder: (column) => column);

  GeneratedColumn<String> get catatan =>
      $composableBuilder(column: $table.catatan, builder: (column) => column);

  GeneratedColumn<String> get bukti =>
      $composableBuilder(column: $table.bukti, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TblPengeluaranTableTableManager
    extends
        RootTableManager<
          _$PosDatabase,
          $TblPengeluaranTable,
          Pengeluaran,
          $$TblPengeluaranTableFilterComposer,
          $$TblPengeluaranTableOrderingComposer,
          $$TblPengeluaranTableAnnotationComposer,
          $$TblPengeluaranTableCreateCompanionBuilder,
          $$TblPengeluaranTableUpdateCompanionBuilder,
          (
            Pengeluaran,
            BaseReferences<_$PosDatabase, $TblPengeluaranTable, Pengeluaran>,
          ),
          Pengeluaran,
          PrefetchHooks Function()
        > {
  $$TblPengeluaranTableTableManager(
    _$PosDatabase db,
    $TblPengeluaranTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TblPengeluaranTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TblPengeluaranTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TblPengeluaranTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kategori = const Value.absent(),
                Value<double> jumlah = const Value.absent(),
                Value<DateTime> tanggal = const Value.absent(),
                Value<String?> catatan = const Value.absent(),
                Value<String?> bukti = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TblPengeluaranCompanion(
                id: id,
                kategori: kategori,
                jumlah: jumlah,
                tanggal: tanggal,
                catatan: catatan,
                bukti: bukti,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kategori,
                required double jumlah,
                required DateTime tanggal,
                Value<String?> catatan = const Value.absent(),
                Value<String?> bukti = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TblPengeluaranCompanion.insert(
                id: id,
                kategori: kategori,
                jumlah: jumlah,
                tanggal: tanggal,
                catatan: catatan,
                bukti: bukti,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TblPengeluaranTableProcessedTableManager =
    ProcessedTableManager<
      _$PosDatabase,
      $TblPengeluaranTable,
      Pengeluaran,
      $$TblPengeluaranTableFilterComposer,
      $$TblPengeluaranTableOrderingComposer,
      $$TblPengeluaranTableAnnotationComposer,
      $$TblPengeluaranTableCreateCompanionBuilder,
      $$TblPengeluaranTableUpdateCompanionBuilder,
      (
        Pengeluaran,
        BaseReferences<_$PosDatabase, $TblPengeluaranTable, Pengeluaran>,
      ),
      Pengeluaran,
      PrefetchHooks Function()
    >;
typedef $$TblLaporanTableCreateCompanionBuilder =
    TblLaporanCompanion Function({
      Value<int> id,
      required String tipe,
      required DateTime tanggal,
      required double totalPenjualan,
      required double totalPengeluaran,
      required double totalKeuntungan,
      required int jumlahTransaksi,
      Value<String?> catatan,
      Value<DateTime> createdAt,
    });
typedef $$TblLaporanTableUpdateCompanionBuilder =
    TblLaporanCompanion Function({
      Value<int> id,
      Value<String> tipe,
      Value<DateTime> tanggal,
      Value<double> totalPenjualan,
      Value<double> totalPengeluaran,
      Value<double> totalKeuntungan,
      Value<int> jumlahTransaksi,
      Value<String?> catatan,
      Value<DateTime> createdAt,
    });

class $$TblLaporanTableFilterComposer
    extends Composer<_$PosDatabase, $TblLaporanTable> {
  $$TblLaporanTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipe => $composableBuilder(
    column: $table.tipe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tanggal => $composableBuilder(
    column: $table.tanggal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalPenjualan => $composableBuilder(
    column: $table.totalPenjualan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalPengeluaran => $composableBuilder(
    column: $table.totalPengeluaran,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalKeuntungan => $composableBuilder(
    column: $table.totalKeuntungan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jumlahTransaksi => $composableBuilder(
    column: $table.jumlahTransaksi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TblLaporanTableOrderingComposer
    extends Composer<_$PosDatabase, $TblLaporanTable> {
  $$TblLaporanTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipe => $composableBuilder(
    column: $table.tipe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tanggal => $composableBuilder(
    column: $table.tanggal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalPenjualan => $composableBuilder(
    column: $table.totalPenjualan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalPengeluaran => $composableBuilder(
    column: $table.totalPengeluaran,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalKeuntungan => $composableBuilder(
    column: $table.totalKeuntungan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jumlahTransaksi => $composableBuilder(
    column: $table.jumlahTransaksi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TblLaporanTableAnnotationComposer
    extends Composer<_$PosDatabase, $TblLaporanTable> {
  $$TblLaporanTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipe =>
      $composableBuilder(column: $table.tipe, builder: (column) => column);

  GeneratedColumn<DateTime> get tanggal =>
      $composableBuilder(column: $table.tanggal, builder: (column) => column);

  GeneratedColumn<double> get totalPenjualan => $composableBuilder(
    column: $table.totalPenjualan,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalPengeluaran => $composableBuilder(
    column: $table.totalPengeluaran,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalKeuntungan => $composableBuilder(
    column: $table.totalKeuntungan,
    builder: (column) => column,
  );

  GeneratedColumn<int> get jumlahTransaksi => $composableBuilder(
    column: $table.jumlahTransaksi,
    builder: (column) => column,
  );

  GeneratedColumn<String> get catatan =>
      $composableBuilder(column: $table.catatan, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TblLaporanTableTableManager
    extends
        RootTableManager<
          _$PosDatabase,
          $TblLaporanTable,
          Laporan,
          $$TblLaporanTableFilterComposer,
          $$TblLaporanTableOrderingComposer,
          $$TblLaporanTableAnnotationComposer,
          $$TblLaporanTableCreateCompanionBuilder,
          $$TblLaporanTableUpdateCompanionBuilder,
          (Laporan, BaseReferences<_$PosDatabase, $TblLaporanTable, Laporan>),
          Laporan,
          PrefetchHooks Function()
        > {
  $$TblLaporanTableTableManager(_$PosDatabase db, $TblLaporanTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TblLaporanTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TblLaporanTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TblLaporanTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> tipe = const Value.absent(),
                Value<DateTime> tanggal = const Value.absent(),
                Value<double> totalPenjualan = const Value.absent(),
                Value<double> totalPengeluaran = const Value.absent(),
                Value<double> totalKeuntungan = const Value.absent(),
                Value<int> jumlahTransaksi = const Value.absent(),
                Value<String?> catatan = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TblLaporanCompanion(
                id: id,
                tipe: tipe,
                tanggal: tanggal,
                totalPenjualan: totalPenjualan,
                totalPengeluaran: totalPengeluaran,
                totalKeuntungan: totalKeuntungan,
                jumlahTransaksi: jumlahTransaksi,
                catatan: catatan,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String tipe,
                required DateTime tanggal,
                required double totalPenjualan,
                required double totalPengeluaran,
                required double totalKeuntungan,
                required int jumlahTransaksi,
                Value<String?> catatan = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TblLaporanCompanion.insert(
                id: id,
                tipe: tipe,
                tanggal: tanggal,
                totalPenjualan: totalPenjualan,
                totalPengeluaran: totalPengeluaran,
                totalKeuntungan: totalKeuntungan,
                jumlahTransaksi: jumlahTransaksi,
                catatan: catatan,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TblLaporanTableProcessedTableManager =
    ProcessedTableManager<
      _$PosDatabase,
      $TblLaporanTable,
      Laporan,
      $$TblLaporanTableFilterComposer,
      $$TblLaporanTableOrderingComposer,
      $$TblLaporanTableAnnotationComposer,
      $$TblLaporanTableCreateCompanionBuilder,
      $$TblLaporanTableUpdateCompanionBuilder,
      (Laporan, BaseReferences<_$PosDatabase, $TblLaporanTable, Laporan>),
      Laporan,
      PrefetchHooks Function()
    >;

class $PosDatabaseManager {
  final _$PosDatabase _db;
  $PosDatabaseManager(this._db);
  $$TblProdukTableTableManager get tblProduk =>
      $$TblProdukTableTableManager(_db, _db.tblProduk);
  $$TblTransaksiTableTableManager get tblTransaksi =>
      $$TblTransaksiTableTableManager(_db, _db.tblTransaksi);
  $$TblDetailTransaksiTableTableManager get tblDetailTransaksi =>
      $$TblDetailTransaksiTableTableManager(_db, _db.tblDetailTransaksi);
  $$TblKategoriTableTableManager get tblKategori =>
      $$TblKategoriTableTableManager(_db, _db.tblKategori);
  $$TblPengeluaranTableTableManager get tblPengeluaran =>
      $$TblPengeluaranTableTableManager(_db, _db.tblPengeluaran);
  $$TblLaporanTableTableManager get tblLaporan =>
      $$TblLaporanTableTableManager(_db, _db.tblLaporan);
}
