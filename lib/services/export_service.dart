import 'package:pdf/pdf.dart' as pdf_lib;
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

/// Service untuk export data ke PDF dan CSV
/// Excel export memerlukan setup khusus, jadi kami gunakan CSV sebagai alternatif
class ExportService {
  static final ExportService _instance = ExportService._internal();

  factory ExportService() {
    return _instance;
  }

  ExportService._internal();

  /// Export ke CSV (compatible dengan Excel)
  Future<String> exportToExcel({
    required String fileName,
    required String sheetName,
    required List<String> headers,
    required List<List<dynamic>> data,
  }) async {
    // Gunakan CSV format yang bisa dibuka dengan Excel
    try {
      final buffer = StringBuffer();
      
      // Header
      buffer.writeln(headers.map((h) => '"$h"').join(','));
      
      // Data
      for (final row in data) {
        buffer.writeln(row.map((cell) => '"$cell"').join(','));
      }

      // Save to file
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName.csv');
      await file.writeAsString(buffer.toString());

      return file.path;
    } catch (e) {
      throw Exception('Error exporting to CSV: $e');
    }
  }

  /// Export ke PDF
  Future<String> exportToPdf({
    required String fileName,
    required String title,
    required List<String> headers,
    required List<List<dynamic>> data,
    String? subtitle,
  }) async {
    try {
      final pdf = pw.Document();
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

      // Convert dynamic data to string for PDF
      final stringData = data.map((row) {
        return row.map((cell) => cell?.toString() ?? '').toList();
      }).toList();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: pdf_lib.PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(16),
          header: (context) => pw.Column(
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                pw.SizedBox(height: 4),
                pw.Text(
                  subtitle,
                  style: pw.TextStyle(fontSize: 11),
                ),
              ],
              pw.SizedBox(height: 4),
              pw.Text(
                'Tanggal: ${dateFormat.format(DateTime.now())}',
                style: pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 12),
            ],
          ),
          footer: (context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 12),
            child: pw.Text(
              'Halaman ${context.pageNumber} dari ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 9),
            ),
          ),
          build: (context) => [
            pw.TableHelper.fromTextArray(
              headers: headers,
              data: stringData,
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: pdf_lib.PdfColors.white,
              ),
              headerDecoration: pw.BoxDecoration(
                color: pdf_lib.PdfColors.grey700,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
              ),
              cellHeight: 25,
              cellAlignment: pw.Alignment.centerLeft,
              rowDecoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    color: pdf_lib.PdfColors.grey300,
                    width: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

      // Save to file
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName.pdf');
      await file.writeAsBytes(await pdf.save());

      return file.path;
    } catch (e) {
      throw Exception('Error exporting to PDF: $e');
    }
  }

  /// Export ke CSV
  Future<String> exportToCsv({
    required String fileName,
    required List<String> headers,
    required List<List<dynamic>> data,
  }) async {
    try {
      final buffer = StringBuffer();
      
      // Header
      buffer.writeln(headers.map((h) => '"$h"').join(','));
      
      // Data
      for (final row in data) {
        final csvRow = row.map((cell) {
          final cellStr = cell?.toString() ?? '';
          final escaped = cellStr.replaceAll('"', '""');
          return '"$escaped"';
        }).join(',');
        buffer.writeln(csvRow);
      }

      // Save to file
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName.csv');
      await file.writeAsString(buffer.toString());

      return file.path;
    } catch (e) {
      throw Exception('Error exporting to CSV: $e');
    }
  }
}
