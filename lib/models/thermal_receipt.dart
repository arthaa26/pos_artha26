// Model untuk menyiapkan data receipt untuk printer thermal
import 'package:intl/intl.dart';

class ThermalReceipt {
  final String storeName;
  final String storeAddress;
  final String storePhone;
  final String? storeLogoPath; // Path ke logo toko (opsional)
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double ppnRate;
  final double ppnAmount;
  final double grandTotal;
  final double cashGiven;
  final double change;
  final String transactionNumber;
  final DateTime transactionTime;
  final String cashierName;

  ThermalReceipt({
    required this.storeName,
    required this.storeAddress,
    required this.storePhone,
    this.storeLogoPath,
    required this.items,
    required this.subtotal,
    required this.ppnRate,
    required this.ppnAmount,
    required this.grandTotal,
    required this.cashGiven,
    required this.change,
    required this.transactionNumber,
    required this.transactionTime,
    required this.cashierName,
  });

  /// Generate thermal receipt text (58mm width = ~32 chars)
  /// Format untuk printer ESC/POS 58mm thermal
  String toThermalText({bool is58mm = true}) {
    final formatter = NumberFormat('#,###', 'id_ID');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

    final buffer = StringBuffer();
    final maxWidth = is58mm ? 32 : 40;
    final dividerChar = '-';

    String centerText(String text) {
      if (text.isEmpty) return '';
      final cleanText = text.length > maxWidth
          ? text.substring(0, maxWidth)
          : text;
      final totalPadding = maxWidth - cleanText.length;
      final leftPadding = totalPadding ~/ 2;
      final rightPadding = totalPadding - leftPadding;
      return '${' ' * leftPadding}$cleanText${' ' * rightPadding}';
    }

    // Left-aligned row with right value
    String rowFormat(String text, String value) {
      final maxLabel = maxWidth - value.length - 1;
      var cleanText = text;
      if (cleanText.length > maxLabel) {
        cleanText = cleanText.substring(0, maxLabel);
      }
      final spaces = maxWidth - cleanText.length - value.length;
      return '$cleanText${' ' * spaces.clamp(1, 999)}$value';
    }

    // Logo section - tidak ditampilkan di thermal printer
    // Printer thermal memerlukan konversi image ke bitmap format
    // Untuk sekarang, logo hanya ditampilkan di UI preview
    // if (storeLogoPath != null && storeLogoPath!.isNotEmpty) {
    //   buffer.writeln('[LOGO]'); // Marker untuk logo
    //   buffer.writeln(dividerChar * maxWidth);
    // }

    // Header - Store Info (all centered)
    buffer.writeln(centerText(storeName));
    if (storeAddress.isNotEmpty) {
      buffer.writeln(centerText(storeAddress));
    }
    if (storePhone.isNotEmpty) {
      buffer.writeln(centerText(storePhone));
    }
    buffer.writeln(dividerChar * maxWidth);

    // Transaction info (centered)
    buffer.writeln(centerText('No: $transactionNumber'));
    final dateStr = dateFormat.format(transactionTime);
    buffer.writeln(centerText(dateStr));
    buffer.writeln(centerText('Kasir: $cashierName'));
    buffer.writeln(dividerChar * maxWidth);

    // Items header - sesuai tampilan preview
    buffer.writeln('Item       Qty    Total');
    buffer.writeln(dividerChar * maxWidth);

    // Items
    for (final item in items) {
      final nama = item['nama'] as String;
      final qty = item['jumlah'] as int;
      final total = item['subtotal'] as double;
      final totalStr = 'Rp ${formatter.format(total.toInt())}';

      if (is58mm) {
        // Format untuk 58mm printer (32 char width)
        // Mirip dengan preview: Item | Qty | Total
        var namaShort = nama;
        if (namaShort.length > 14) {
          namaShort = namaShort.substring(0, 13);
        }
        namaShort = namaShort.padRight(14);
        
        final qtyStr = qty.toString().padLeft(4);
        // Spacing untuk total di kanan
        final spaceBefore = maxWidth - 14 - 4 - totalStr.length;
        final line = '$namaShort$qtyStr${' ' * spaceBefore.clamp(1, 999)}$totalStr';
        buffer.writeln(line.length > maxWidth ? line.substring(0, maxWidth) : line);
      } else {
        // Format untuk 80mm
        final namaShort = nama.length > 14
            ? nama.substring(0, 13)
            : nama.padRight(14);
        final qtyStr = qty.toString().padLeft(3);
        final harga = item['hargaSatuan'] as double;
        final hargaStr = 'Rp ${formatter.format(harga.toInt())}';
        buffer.write('$namaShort$qtyStr ');
        buffer.write(hargaStr.padLeft(9));
        buffer.writeln(' ${totalStr.padLeft(9)}');
      }
    }

    buffer.writeln(dividerChar * maxWidth);

    // Summary section - sesuai preview
    buffer.writeln(
      rowFormat('Subtotal', 'Rp ${formatter.format(subtotal.toInt())}'),
    );

    // PPN
    if (ppnAmount > 0) {
      final ppnPercent = (ppnRate * 100).toStringAsFixed(0);
      buffer.writeln(
        rowFormat(
          'PPN ($ppnPercent%)',
          'Rp ${formatter.format(ppnAmount.toInt())}',
        ),
      );
    }

    buffer.writeln(dividerChar * maxWidth);

    // Grand Total (emphasized) - sesuai preview
    buffer.writeln(
      rowFormat('TOTAL', 'Rp ${formatter.format(grandTotal.toInt())}'),
    );

    buffer.writeln(dividerChar * maxWidth);

    // Payment info - sesuai preview
    buffer.writeln(
      rowFormat('Dibayar', 'Rp ${formatter.format(cashGiven.toInt())}'),
    );
    buffer.writeln(
      rowFormat('Kembalian', 'Rp ${formatter.format(change.toInt())}'),
    );

    buffer.writeln(dividerChar * maxWidth);

    // Footer - all centered - sesuai preview
    buffer.writeln(centerText('TERIMA KASIH'));
    buffer.writeln(centerText('atas pembelian Anda'));
    buffer.writeln('');
    buffer.writeln(centerText('Senin - Minggu: 08:00 - 20:00'));
    buffer.writeln(centerText('Powered by POS Artha'));

    return buffer.toString();
  }

  /// Generate ESC/POS command sequence untuk thermal printer 58mm
  List<int> toEscPosBytes({bool is58mm = true}) {
    const escChar = '\x1B';
    const gsChar = '\x1D';

    final buffer = StringBuffer();

    // Initialize printer
    buffer.write('$escChar@');

    // Set text size - normal for 58mm
    buffer.write('$escChar!0'); // Normal size

    // Center align
    buffer.write('$escChar a1');

    // Print receipt text
    buffer.write(toThermalText(is58mm: is58mm));

    // Feed paper and cut
    buffer.write('\n\n\n\n');
    buffer.write('$gsChar V A\n'); // Cut paper

    return buffer.toString().codeUnits;
  }
}
