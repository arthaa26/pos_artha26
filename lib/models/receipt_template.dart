/// Model untuk menyimpan template struk yang dapat dikustomisasi pengguna
class ReceiptTemplate {
  final String id; // unique identifier
  final String name; // nama template
  final String headerTemplate; // bagian header
  final String itemTemplate; // format item/produk
  final String footerTemplate; // bagian footer
  final int paperWidth; // 58mm atau 80mm
  final bool isActive; // template aktif atau tidak

  ReceiptTemplate({
    required this.id,
    required this.name,
    required this.headerTemplate,
    required this.itemTemplate,
    required this.footerTemplate,
    this.paperWidth = 58,
    this.isActive = false,
  });

  /// Konversi ke JSON untuk disimpan ke database
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'headerTemplate': headerTemplate,
      'itemTemplate': itemTemplate,
      'footerTemplate': footerTemplate,
      'paperWidth': paperWidth,
      'isActive': isActive,
    };
  }

  /// Buat dari JSON
  factory ReceiptTemplate.fromJson(Map<String, dynamic> json) {
    return ReceiptTemplate(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Template',
      headerTemplate: json['headerTemplate'] as String? ?? '',
      itemTemplate: json['itemTemplate'] as String? ?? '',
      footerTemplate: json['footerTemplate'] as String? ?? '',
      paperWidth: json['paperWidth'] as int? ?? 58,
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  /// Copy dengan perubahan
  ReceiptTemplate copyWith({
    String? id,
    String? name,
    String? headerTemplate,
    String? itemTemplate,
    String? footerTemplate,
    int? paperWidth,
    bool? isActive,
  }) {
    return ReceiptTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      headerTemplate: headerTemplate ?? this.headerTemplate,
      itemTemplate: itemTemplate ?? this.itemTemplate,
      footerTemplate: footerTemplate ?? this.footerTemplate,
      paperWidth: paperWidth ?? this.paperWidth,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Default template untuk 58mm
  static ReceiptTemplate defaultTemplate58() {
    return ReceiptTemplate(
      id: 'default_58',
      name: 'Default 58mm',
      headerTemplate: '''
{centerAlign}
{storeName}
{storeAddress}
{storePhone}
{divider}
No: {transactionNumber}
{transactionDateTime}
Kasir: {cashierName}
{divider}
''',
      itemTemplate: '''
{itemName:14} {itemQty:>3} {itemTotal:>9}
''',
      footerTemplate: '''
{divider}
{subtotalRow}
{ppnRow}
{divider}
{totalRow}
{divider}
{paidRow}
{changeRow}
{divider}
{centerAlign}TERIMA KASIH
{centerAlign}atas pembelian Anda
{centerAlign}
{centerAlign}Senin - Minggu: 08:00 - 20:00
{centerAlign}Powered by POS Artha
''',
      paperWidth: 58,
      isActive: true,
    );
  }

  /// Default template untuk 80mm
  static ReceiptTemplate defaultTemplate80() {
    return ReceiptTemplate(
      id: 'default_80',
      name: 'Default 80mm',
      headerTemplate: '''
{centerAlign}
{storeName}
{storeAddress}
{storePhone}
{divider}
No: {transactionNumber}
{transactionDateTime}
Kasir: {cashierName}
{divider}
''',
      itemTemplate: '''
{itemName:16} {itemQty:>3} {itemPrice:>9} {itemTotal:>10}
''',
      footerTemplate: '''
{divider}
{subtotalRow}
{ppnRow}
{divider}
{totalRow}
{divider}
{paidRow}
{changeRow}
{divider}
{centerAlign}TERIMA KASIH
{centerAlign}atas pembelian Anda
{centerAlign}
{centerAlign}Senin - Minggu: 08:00 - 20:00
{centerAlign}Powered by POS Artha
''',
      paperWidth: 80,
      isActive: false,
    );
  }

  /// Template sederhana
  static ReceiptTemplate simpleTemplate() {
    return ReceiptTemplate(
      id: 'simple',
      name: 'Simple',
      headerTemplate: '''
{centerAlign}{storeName}
{centerAlign}{storePhone}
{divider}
{transactionNumber} {transactionDateTime}
''',
      itemTemplate: '''
{itemName} x{itemQty} = {itemTotal}
''',
      footerTemplate: '''
{divider}
Subtotal: {subtotal}
{ppnRow}
TOTAL: {total}
{divider}
Terima Kasih!
''',
      paperWidth: 58,
    );
  }

  /// Template compact (minimalis)
  static ReceiptTemplate compactTemplate() {
    return ReceiptTemplate(
      id: 'compact',
      name: 'Compact',
      headerTemplate: '''
{storeName}
{divider}
#{transactionNumber}
{transactionDateTime}
''',
      itemTemplate: '''
{itemName}{itemQty} {itemTotal}
''',
      footerTemplate: '''
{divider}
Total: {total}
Bayar: {paid}
Kembali: {change}
{divider}
''',
      paperWidth: 58,
    );
  }
}

class TemplateVariables {
  static const String storeName = '{storeName}';
  static const String storeAddress = '{storeAddress}';
  static const String storePhone = '{storePhone}';
  static const String logoMarker = '{logoMarker}'; // Marker untuk logo
  static const String transactionNumber = '{transactionNumber}';
  static const String transactionDateTime = '{transactionDateTime}';
  static const String cashierName = '{cashierName}';

  // Item variables
  static const String itemName = '{itemName}';
  static const String itemQty = '{itemQty}';
  static const String itemPrice = '{itemPrice}';
  static const String itemTotal = '{itemTotal}';

  // Summary variables
  static const String subtotal = '{subtotal}';
  static const String ppnAmount = '{ppnAmount}';
  static const String ppnPercent = '{ppnPercent}';
  static const String total = '{total}';
  static const String paid = '{paid}';
  static const String change = '{change}';

  // Row templates
  static const String subtotalRow = '{subtotalRow}'; // auto-generated
  static const String ppnRow = '{ppnRow}'; // auto-generated
  static const String totalRow = '{totalRow}'; // auto-generated
  static const String paidRow = '{paidRow}'; // auto-generated
  static const String changeRow = '{changeRow}'; // auto-generated

  // Formatting
  static const String divider = '{divider}';
  static const String doubleEquals = '{doubleEquals}';
  static const String centerAlign = '{centerAlign}';
  static const String leftAlign = '{leftAlign}';
  static const String rightAlign = '{rightAlign}';

  static List<String> getAllVariables() {
    return [
      storeName,
      storeAddress,
      storePhone,
      logoMarker,
      transactionNumber,
      transactionDateTime,
      cashierName,
      itemName,
      itemQty,
      itemPrice,
      itemTotal,
      subtotal,
      ppnAmount,
      ppnPercent,
      total,
      paid,
      change,
      subtotalRow,
      ppnRow,
      totalRow,
      paidRow,
      changeRow,
      divider,
      doubleEquals,
      centerAlign,
      leftAlign,
      rightAlign,
    ];
  }

  static String getDescription(String variable) {
    switch (variable) {
      case storeName:
        return 'Nama Toko';
      case storeAddress:
        return 'Alamat Toko';
      case storePhone:
        return 'Nomor Telepon';
      case logoMarker:
        return 'Marker untuk Logo Toko';
      case transactionNumber:
        return 'Nomor Transaksi';
      case transactionDateTime:
        return 'Tanggal & Waktu Transaksi';
      case cashierName:
        return 'Nama Kasir';
      case itemName:
        return 'Nama Item/Produk';
      case itemQty:
        return 'Jumlah Item';
      case itemPrice:
        return 'Harga Satuan';
      case itemTotal:
        return 'Total Harga Item';
      case subtotal:
        return 'Subtotal';
      case ppnAmount:
        return 'Jumlah PPN';
      case ppnPercent:
        return 'Persentase PPN';
      case total:
        return 'Total Akhir';
      case paid:
        return 'Jumlah Dibayar';
      case change:
        return 'Kembalian';
      case subtotalRow:
        return 'Baris Subtotal (auto-format)';
      case ppnRow:
        return 'Baris PPN (auto-format)';
      case totalRow:
        return 'Baris Total (auto-format)';
      case paidRow:
        return 'Baris Dibayar (auto-format)';
      case changeRow:
        return 'Baris Kembalian (auto-format)';
      case divider:
        return 'Garis Pembatas (-)';
      case doubleEquals:
        return 'Garis Pembatas (=)';
      case centerAlign:
        return 'Rata Tengah';
      case leftAlign:
        return 'Rata Kiri';
      case rightAlign:
        return 'Rata Kanan';
      default:
        return variable;
    }
  }
}
