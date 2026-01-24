import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/receipt_template.dart';

/// Service untuk mengelola dan merender template receipt
class ReceiptTemplateService {
  static final ReceiptTemplateService _instance =
      ReceiptTemplateService._internal();

  factory ReceiptTemplateService() {
    return _instance;
  }

  ReceiptTemplateService._internal();

  final List<ReceiptTemplate> _templates = [];
  ReceiptTemplate? _activeTemplate;

  /// Initialize dengan template default
  void initialize() {
    _templates.clear();
    _templates.addAll([
      ReceiptTemplate.defaultTemplate58(),
      ReceiptTemplate.defaultTemplate80(),
      ReceiptTemplate.simpleTemplate(),
      ReceiptTemplate.compactTemplate(),
    ]);

    _activeTemplate = _templates.firstWhere(
      (t) => t.isActive,
      orElse: () => _templates.first,
    );
  }

  /// Render receipt dengan template yang aktif
  String renderReceipt({
    required String storeName,
    required String storeAddress,
    required String storePhone,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double ppnRate,
    required double ppnAmount,
    required double grandTotal,
    required double cashGiven,
    required double change,
    required String transactionNumber,
    required DateTime transactionTime,
    required String cashierName,
  }) {
    final template = _activeTemplate ?? _templates.first;
    return _renderTemplate(
      template: template,
      storeName: storeName,
      storeAddress: storeAddress,
      storePhone: storePhone,
      items: items,
      subtotal: subtotal,
      ppnRate: ppnRate,
      ppnAmount: ppnAmount,
      grandTotal: grandTotal,
      cashGiven: cashGiven,
      change: change,
      transactionNumber: transactionNumber,
      transactionTime: transactionTime,
      cashierName: cashierName,
    );
  }

  /// Render dengan template spesifik
  String renderWithTemplate({
    required ReceiptTemplate template,
    required String storeName,
    required String storeAddress,
    required String storePhone,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double ppnRate,
    required double ppnAmount,
    required double grandTotal,
    required double cashGiven,
    required double change,
    required String transactionNumber,
    required DateTime transactionTime,
    required String cashierName,
  }) {
    return _renderTemplate(
      template: template,
      storeName: storeName,
      storeAddress: storeAddress,
      storePhone: storePhone,
      items: items,
      subtotal: subtotal,
      ppnRate: ppnRate,
      ppnAmount: ppnAmount,
      grandTotal: grandTotal,
      cashGiven: cashGiven,
      change: change,
      transactionNumber: transactionNumber,
      transactionTime: transactionTime,
      cashierName: cashierName,
    );
  }

  /// Internal render logic
  String _renderTemplate({
    required ReceiptTemplate template,
    required String storeName,
    required String storeAddress,
    required String storePhone,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double ppnRate,
    required double ppnAmount,
    required double grandTotal,
    required double cashGiven,
    required double change,
    required String transactionNumber,
    required DateTime transactionTime,
    required String cashierName,
  }) {
    final formatter = NumberFormat('#,###', 'id_ID');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
    final maxWidth = template.paperWidth;

    // Helper functions
    String formatCurrency(double amount) {
      return 'Rp ${formatter.format(amount.toInt())}';
    }

    String centerText(String text) {
      if (text.isEmpty) return '';
      final cleanText =
          text.length > maxWidth ? text.substring(0, maxWidth) : text;
      final totalPadding = maxWidth - cleanText.length;
      final leftPadding = totalPadding ~/ 2;
      final rightPadding = totalPadding - leftPadding;
      return '${' ' * leftPadding}$cleanText${' ' * rightPadding}';
    }

    String rowFormat(String label, String value) {
      final maxLabel = maxWidth - value.length - 1;
      var cleanLabel = label;
      if (cleanLabel.length > maxLabel) {
        cleanLabel = cleanLabel.substring(0, maxLabel);
      }
      final spaces = maxWidth - cleanLabel.length - value.length;
      return '$cleanLabel${' ' * spaces.clamp(1, 999)}$value';
    }

    // Replace variables
    String replaceVariables(String text) {
      var result = text;

      // Logo marker - ganti dengan [LOGO] untuk dicetak
      result = result.replaceAll(TemplateVariables.logoMarker, '[LOGO]');

      // Basic variables
      result = result.replaceAll(TemplateVariables.storeName, storeName);
      result = result.replaceAll(TemplateVariables.storeAddress, storeAddress);
      result = result.replaceAll(TemplateVariables.storePhone, storePhone);
      result = result.replaceAll(
        TemplateVariables.transactionNumber,
        transactionNumber,
      );
      result = result.replaceAll(
        TemplateVariables.transactionDateTime,
        dateFormat.format(transactionTime),
      );
      result = result.replaceAll(TemplateVariables.cashierName, cashierName);

      // Summary variables
      result = result.replaceAll(
        TemplateVariables.subtotal,
        formatCurrency(subtotal),
      );
      result = result.replaceAll(
        TemplateVariables.ppnAmount,
        formatCurrency(ppnAmount),
      );
      result = result.replaceAll(
        TemplateVariables.ppnPercent,
        '${(ppnRate * 100).toStringAsFixed(0)}%',
      );
      result = result.replaceAll(
        TemplateVariables.total,
        formatCurrency(grandTotal),
      );
      result = result.replaceAll(
        TemplateVariables.paid,
        formatCurrency(cashGiven),
      );
      result = result.replaceAll(
        TemplateVariables.change,
        formatCurrency(change),
      );

      // Auto-formatted rows
      if (result.contains(TemplateVariables.subtotalRow)) {
        result = result.replaceAll(
          TemplateVariables.subtotalRow,
          rowFormat('Subtotal', formatCurrency(subtotal)),
        );
      }

      if (result.contains(TemplateVariables.ppnRow)) {
        final ppnLabel = 'PPN (${(ppnRate * 100).toStringAsFixed(0)}%)';
        result = result.replaceAll(
          TemplateVariables.ppnRow,
          ppnAmount > 0 ? rowFormat(ppnLabel, formatCurrency(ppnAmount)) : '',
        );
      }

      if (result.contains(TemplateVariables.totalRow)) {
        result = result.replaceAll(
          TemplateVariables.totalRow,
          rowFormat('TOTAL', formatCurrency(grandTotal)),
        );
      }

      if (result.contains(TemplateVariables.paidRow)) {
        result = result.replaceAll(
          TemplateVariables.paidRow,
          rowFormat('Dibayar', formatCurrency(cashGiven)),
        );
      }

      if (result.contains(TemplateVariables.changeRow)) {
        result = result.replaceAll(
          TemplateVariables.changeRow,
          rowFormat('Kembalian', formatCurrency(change)),
        );
      }

      // Formatting
      result = result.replaceAll(
        TemplateVariables.divider,
        '-' * maxWidth,
      );
      result = result.replaceAll(
        TemplateVariables.doubleEquals,
        '=' * maxWidth,
      );

      return result;
    }

    // Build receipt
    final buffer = StringBuffer();

    // Header
    String header = template.headerTemplate;
    header = replaceVariables(header);

    // Apply alignment to header
    if (header.contains(TemplateVariables.centerAlign)) {
      final lines = header.split('\n');
      final processedLines = lines.map((line) {
        if (line.contains(TemplateVariables.centerAlign)) {
          final cleanLine =
              line.replaceAll(TemplateVariables.centerAlign, '').trim();
          return centerText(cleanLine);
        }
        return line;
      }).toList();
      header = processedLines.join('\n');
    }
    header = header.replaceAll(TemplateVariables.centerAlign, '');
    buffer.write(header);

    // Items
    for (final item in items) {
      final nama = item['nama'] as String? ?? 'Item';
      final qty = item['jumlah'] as int? ?? 1;
      final harga = item['hargaSatuan'] as double? ?? 0;
      final total = item['subtotal'] as double? ?? 0;

      String itemLine = template.itemTemplate;
      itemLine = itemLine.replaceAll(TemplateVariables.itemName, nama);
      itemLine = itemLine.replaceAll(TemplateVariables.itemQty, qty.toString());
      itemLine = itemLine.replaceAll(
        TemplateVariables.itemPrice,
        formatCurrency(harga),
      );
      itemLine = itemLine.replaceAll(
        TemplateVariables.itemTotal,
        formatCurrency(total),
      );

      // Handle padding in item template (e.g., {itemName:12})
      itemLine = _applyItemFormatting(itemLine, maxWidth, nama, qty, harga, total, formatter);

      buffer.writeln(itemLine);
    }

    // Footer
    String footer = template.footerTemplate;
    footer = replaceVariables(footer);

    // Apply alignment to footer
    if (footer.contains(TemplateVariables.centerAlign)) {
      final lines = footer.split('\n');
      final processedLines = lines.map((line) {
        if (line.contains(TemplateVariables.centerAlign)) {
          final cleanLine =
              line.replaceAll(TemplateVariables.centerAlign, '').trim();
          return centerText(cleanLine);
        }
        return line;
      }).toList();
      footer = processedLines.join('\n');
    }
    footer = footer.replaceAll(TemplateVariables.centerAlign, '');

    buffer.write(footer);

    return buffer.toString();
  }

  /// Apply item formatting dengan width specification (e.g., {itemName:12})
  String _applyItemFormatting(
    String template,
    int maxWidth,
    String name,
    int qty,
    double price,
    double total,
    NumberFormat formatter,
  ) {
    // Match patterns like {itemName:12} or {itemQty:>4}
    final pattern = RegExp(r'\{(\w+):([><]?)(\d+)\}');
    return template.replaceAllMapped(pattern, (match) {
      final variable = match.group(1);
      final align = match.group(2); // '>' for right, '<' for left, '' for left
      final width = int.tryParse(match.group(3) ?? '0') ?? 0;

      String value;
      switch (variable) {
        case 'itemName':
          value = name;
          break;
        case 'itemQty':
          value = qty.toString();
          break;
        case 'itemPrice':
          value = 'Rp ${formatter.format(price.toInt())}';
          break;
        case 'itemTotal':
          value = 'Rp ${formatter.format(total.toInt())}';
          break;
        default:
          value = '';
      }

      // Apply alignment
      if (align == '>') {
        // Right align
        return value.padLeft(width);
      } else {
        // Left align (default)
        return value.padRight(width);
      }
    });
  }

  // Template management methods
  List<ReceiptTemplate> getAllTemplates() => List.from(_templates);

  ReceiptTemplate? getActiveTemplate() => _activeTemplate;

  void setActiveTemplate(String templateId) {
    try {
      _activeTemplate = _templates.firstWhere((t) => t.id == templateId);
      // Update isActive flag
      for (var i = 0; i < _templates.length; i++) {
        _templates[i] = _templates[i].copyWith(
          isActive: _templates[i].id == templateId,
        );
      }
    } catch (e) {
      if (kDebugMode) print('Template not found: $templateId');
    }
  }

  void addTemplate(ReceiptTemplate template) {
    // Check if already exists
    final index = _templates.indexWhere((t) => t.id == template.id);
    if (index >= 0) {
      _templates[index] = template;
    } else {
      _templates.add(template);
    }
  }

  void deleteTemplate(String templateId) {
    _templates.removeWhere((t) => t.id == templateId);
  }

  void updateTemplate(ReceiptTemplate template) {
    final index = _templates.indexWhere((t) => t.id == template.id);
    if (index >= 0) {
      _templates[index] = template;
    }
  }
}
