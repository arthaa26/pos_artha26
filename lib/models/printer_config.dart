/// Model untuk konfigurasi printer
class PrinterConfig {
  final String id; // unique identifier
  final String name;
  final PrinterType type;
  final String? bluetoothAddress; // untuk Bluetooth
  final String? networkIp; // untuk Network (Jaringan)
  final int? networkPort; // untuk Network
  final PaperSize paperSize;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? lastUsed;

  PrinterConfig({
    required this.id,
    required this.name,
    required this.type,
    this.bluetoothAddress,
    this.networkIp,
    this.networkPort = 9100, // default port untuk network printer
    this.paperSize = PaperSize.mm58,
    this.isDefault = false,
    DateTime? createdAt,
    this.lastUsed,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert to JSON untuk SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'bluetoothAddress': bluetoothAddress,
      'networkIp': networkIp,
      'networkPort': networkPort,
      'paperSize': paperSize.name,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory PrinterConfig.fromJson(Map<String, dynamic> json) {
    return PrinterConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      type: PrinterType.values.byName(json['type'] as String),
      bluetoothAddress: json['bluetoothAddress'] as String?,
      networkIp: json['networkIp'] as String?,
      networkPort: json['networkPort'] as int? ?? 9100,
      paperSize: PaperSize.values.byName(
        json['paperSize'] as String? ?? 'mm58',
      ),
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsed: json['lastUsed'] != null
          ? DateTime.parse(json['lastUsed'] as String)
          : null,
    );
  }

  /// Copy with
  PrinterConfig copyWith({
    String? id,
    String? name,
    PrinterType? type,
    String? bluetoothAddress,
    String? networkIp,
    int? networkPort,
    PaperSize? paperSize,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? lastUsed,
  }) {
    return PrinterConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      bluetoothAddress: bluetoothAddress ?? this.bluetoothAddress,
      networkIp: networkIp ?? this.networkIp,
      networkPort: networkPort ?? this.networkPort,
      paperSize: paperSize ?? this.paperSize,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }
}

/// Enum untuk jenis printer
enum PrinterType {
  bluetooth('Bluetooth'),
  network('Jaringan (Network)'),
  usb('USB');

  final String displayName;
  const PrinterType(this.displayName);
}

/// Enum untuk ukuran kertas
enum PaperSize {
  mm58('58mm', 58),
  mm80('80mm', 80);

  final String displayName;
  final int widthMm;
  const PaperSize(this.displayName, this.widthMm);
}
