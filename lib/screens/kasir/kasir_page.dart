import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'dart:io' if (kIsWeb) 'dart:html';
import '../../database/database.dart' if (kIsWeb) 'dart:async';
import '../../providers/pos_provider.dart';
import '../../services/local_api_service.dart';
import '../../services/bluetooth_printer_service.dart';
import '../../services/print_manager_service.dart';
import '../../models/thermal_receipt.dart';
import '../../widgets/printer_connection_dialog.dart';
import '../../widgets/receipt_preview_widget.dart';

class KasirPage extends StatefulWidget {
  const KasirPage({super.key});

  @override
  State<KasirPage> createState() => _KasirPageState();
}

class _KasirPageState extends State<KasirPage> {
  List<Map<String, dynamic>> cart = [];
  double total = 0;
  String _selectedKategori = 'Semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PosProvider>().loadProduk();
    });
  }

  void addToCart(Produk produk) {
    setState(() {
      final existing = cart.firstWhere(
        (item) => item['produk'].id == produk.id,
        orElse: () => {},
      );
      if (existing.isNotEmpty) {
        existing['quantity'] += 1;
      } else {
        cart.add({'produk': produk, 'quantity': 1});
      }
      calculateTotal();
    });
  }

  void removeFromCart(int index) {
    setState(() {
      if (cart[index]['quantity'] > 1) {
        cart[index]['quantity'] -= 1;
      } else {
        cart.removeAt(index);
      }
      calculateTotal();
    });
  }

  void increaseQuantity(int index) {
    setState(() {
      cart[index]['quantity'] += 1;
      calculateTotal();
    });
  }

  void calculateTotal() {
    total = cart.fold(
      0,
      (sum, item) => sum + (item['produk'].harga * item['quantity']),
    );
  }

  void checkout() async {
    if (cart.isEmpty) return;

    // Step 1: Konfirmasi Pesanan
    showOrderConfirmationDialog();
  }

  void showOrderConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pesanan'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detail Pesanan:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: cart.length,
                  itemBuilder: (context, index) {
                    final item = cart[index];
                    final produk = item['produk'] as Produk?;
                    final quantity = item['quantity'] as int?;
                    if (produk == null || quantity == null)
                      return const SizedBox.shrink();
                    final subtotal = produk.harga * quantity;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  produk.nama,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Rp ${NumberFormat('#,###', 'id_ID').format(produk.harga.toInt())} x $quantity',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Rp ${NumberFormat('#,###', 'id_ID').format(subtotal.toInt())}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Rp ${NumberFormat('#,###', 'id_ID').format(total.toInt())}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              showPaymentDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Lanjut ke Pembayaran'),
          ),
        ],
      ),
    );
  }

  void showPaymentDialog() {
    final TextEditingController cashController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pembayaran Tunai'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan jumlah uang yang diberikan customer:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total yang harus dibayar:',
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Rp ${NumberFormat('#,###', 'id_ID').format(total.toInt())}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cashController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Uang Customer (Rp)',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              // Quick amount buttons
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildQuickAmountButton(
                    cashController,
                    total,
                  ), // Exact amount
                  _buildQuickAmountButton(
                    cashController,
                    (total / 1000).ceil() * 1000,
                  ), // Round up to nearest thousand
                  _buildQuickAmountButton(
                    cashController,
                    ((total / 10000).ceil() * 10000),
                  ), // Round up to nearest ten thousand
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final cash =
                  double.tryParse(
                    cashController.text
                        .replaceAll('Rp ', '')
                        .replaceAll(',', ''),
                  ) ??
                  0;
              if (cash < total) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Uang yang diberikan kurang dari total pembayaran',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              final change = cash - total;
              Navigator.of(context).pop();
              processPayment(cash, change);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Proses Pembayaran'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountButton(
    TextEditingController controller,
    double amount,
  ) {
    return ElevatedButton(
      onPressed: () {
        controller.text = amount.toStringAsFixed(0);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black,
        minimumSize: const Size(70, 32),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: Text(
        'Rp ${NumberFormat('#,###', 'id_ID').format(amount.toInt())}',
      ),
    );
  }

  void processPayment(double cashGiven, double change) {
    final provider = context.read<PosProvider>();
    final settings = provider.settings;
    
    // Generate transaction number
    final now = DateTime.now();
    final nomorTransaksi =
        'TRX${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';

    // Prepare receipt items
    final receiptItems = cart.map((item) {
      final produk = item['produk'] as Produk;
      final quantity = item['quantity'] as int;
      final diskon = (item['diskon'] as double?) ?? 0;
      final subtotal = (produk.harga * quantity) - diskon;

      return {
        'nama': produk.nama,
        'jumlah': quantity,
        'hargaSatuan': produk.harga,
        'subtotal': subtotal,
      };
    }).toList();

    // Show payment summary with receipt preview
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pembayaran Berhasil'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Transaksi berhasil diproses!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Receipt Preview
                ReceiptPreviewWidget(
                  storeName: settings.storeName,
                  storeAddress: settings.storeAddress,
                  storePhone: settings.storePhone,
                  storeLogoPath: settings.storeLogoPath,
                  items: receiptItems,
                  subtotal: total,
                  ppnRate: settings.ppnRate,
                  cashGiven: cashGiven,
                  change: change,
                  transactionNumber: nomorTransaksi,
                  transactionTime: DateTime.now(),
                  thankYouMessage: settings.receiptFooter,
                  operatingHours: settings.receiptHeader,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showPrintMethodDialog(cashGiven, change);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            child: const Text('Cetak Struk'),
          ),
        ],
      ),
    );
  }

  void _showPrintMethodDialog(double cashGiven, double change) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Metode Cetak'),
        content: const Text('Pilih cara mencetak struk:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              finalizeTransaction(cashGiven, change, printMethod: 'pdf');
            },
            child: const Text('📄 PDF'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              finalizeTransaction(cashGiven, change, printMethod: 'thermal');
            },
            child: const Text('🖨️ Thermal Printer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  Future<void> finalizeTransaction(
    double cashGiven,
    double change, {
    String printMethod = 'pdf',
  }) async {
    try {
      // Generate transaction number
      final now = DateTime.now();
      final nomorTransaksi =
          'TRX${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';

      // Prepare items data for transaction
      final items = cart.map((item) {
        final produk = item['produk'] as Produk;
        final quantity = item['quantity'] as int;
        final diskon = (item['diskon'] as double?) ?? 0;
        final subtotal = (produk.harga * quantity) - diskon;

        return {
          'produkId': produk.id,
          'nama': produk.nama,
          'jumlah': quantity,
          'hargaSatuan': produk.harga,
          'diskon': diskon,
          'subtotal': subtotal,
        };
      }).toList();

      // Save transaction to database
      await localApiService.addTransaksi(
        nomorTransaksi: nomorTransaksi,
        items: items,
        total: total,
        bayar: cashGiven,
        kembalian: change,
        metode: 'Tunai', // Default to cash
        catatan: null,
      );

      // Reload transactions in provider
      if (mounted) {
        await context.read<PosProvider>().loadTransaksi();
      }

      // Show receipt and print based on method
      if (mounted) {
        if (printMethod == 'thermal') {
          await _printThermal(cashGiven, change, nomorTransaksi);
        } else {
          await _printReceipt(cashGiven, change, nomorTransaksi);
        }
      }

      // Clear cart after payment
      if (mounted) {
        setState(() {
          cart.clear();
          total = 0;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Transaksi berhasil! Struk dicetak via ${printMethod == 'thermal' ? 'Thermal Printer' : 'PDF'}.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _printThermal(
    double cashGiven,
    double change,
    String nomorTransaksi,
  ) async {
    try {
      final provider = context.read<PosProvider>();
      final settings = provider.settings;

      if (kDebugMode) print('🖨️ [Kasir] Starting thermal print process...');

      // Create thermal receipt data
      final receiptItems = cart.map((item) {
        final produk = item['produk'] as Produk;
        final quantity = item['quantity'] as int;
        final diskon = (item['diskon'] as double?) ?? 0;
        final subtotal = (produk.harga * quantity) - diskon;

        return {
          'nama': produk.nama,
          'jumlah': quantity,
          'hargaSatuan': produk.harga,
          'subtotal': subtotal,
        };
      }).toList();

      // Calculate PPN
      final ppnAmount = total * settings.ppnRate;
      final grandTotal = total + ppnAmount;

      final receipt = ThermalReceipt(
        storeName: settings.storeName,
        storeAddress: settings.storeAddress,
        storePhone: settings.storePhone,
        storeLogoPath: settings.storeLogoPath.isNotEmpty ? settings.storeLogoPath : null,
        items: receiptItems,
        subtotal: total,
        ppnRate: settings.ppnRate,
        ppnAmount: ppnAmount,
        grandTotal: grandTotal,
        cashGiven: cashGiven,
        change: change,
        transactionNumber: nomorTransaksi,
        transactionTime: DateTime.now(),
        cashierName: 'Admin',
      );

      if (kDebugMode) {
        print('   Receipt generated');
        print('   Items: ${receiptItems.length}');
        print('   Total: $total');
      }

      // Use unified print manager service
      final printManager = PrintManagerService();

      if (kDebugMode) print('   Verifying printer connection...');

      // Check if connected to Bluetooth printer
      if (printManager.isPrinterReady()) {
        if (kDebugMode) print('   ✅ Printer connected, sending data...');

        // Print via unified manager
        final success = await printManager.printThermalReceipt(
          receipt: receipt,
          is58mm: true, // Use 58mm format
        );

        if (success) {
          if (kDebugMode) print('✅ [Kasir] Print SUCCESS');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Struk berhasil dicetak!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          if (kDebugMode) print('❌ [Kasir] Print FAILED');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Gagal cetak - lihat logs untuk detail error'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      } else {
        if (kDebugMode) print('❌ [Kasir] Printer NOT connected');

        // Show dialog to connect printer
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Printer Tidak Terhubung'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Printer Bluetooth tidak terhubung. Silakan hubungkan ke printer Bluetooth di menu 🖨️ Printer terlebih dahulu.',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Info:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const Text(
                          'Silakan hubungkan printer Bluetooth dari menu Printer',
                          style: TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => const PrinterConnectionDialog(),
                    );
                  },
                  child: const Text('Hubungkan Printer'),
                ),
              ],
            ),
          );
        }
      }

      // Also print receipt text to console for debugging
      if (kDebugMode) {
        print('=== THERMAL RECEIPT TEXT ===');
        print(receipt.toThermalText());
        print('============================');
      }

      if (mounted) {
        Navigator.of(context).pop(); // Close dialog if any
      }
    } catch (e) {
      if (kDebugMode) print('❌ [Kasir] Thermal print error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error mencetak: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _printReceipt(
    double cashGiven,
    double change,
    String nomorTransaksi,
  ) async {
    final provider = context.read<PosProvider>();
    final settings = provider.settings;
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              // Logo
              if (settings.storeLogoPath.isNotEmpty)
                pw.Container(
                  height: 50,
                  child: pw.Image(
                    pw.MemoryImage(
                      File(settings.storeLogoPath).readAsBytesSync(),
                    ),
                  ),
                )
              else
                pw.Text(
                  'LOGO',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              pw.SizedBox(height: 8),
              // Nama Toko
              pw.Text(
                settings.storeName,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              // Alamat
              pw.Text(
                settings.storeAddress,
                style: pw.TextStyle(fontSize: 12),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 16),
              // ID Transaksi, Tanggal, Kasir
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'ID: $nomorTransaksi',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                  pw.Text(
                    'Tanggal: ${DateTime.now().toString().substring(0, 19)}',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                  pw.Text('Kasir: Admin', style: pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.Divider(),
              // Produk Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text(
                      'Item',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      'Qty',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'Harga',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'Total',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
              pw.Divider(),
              // Produk Items
              ...cart.map((item) {
                final produk = item['produk'] as Produk?;
                final quantity = item['quantity'] as int? ?? 1;
                final nama = produk?.nama ?? 'Produk Tidak Ditemukan';
                final harga = produk?.harga ?? 0.0;
                final totalHarga = harga * quantity;

                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      flex: 4,
                      child: pw.Text(nama, style: pw.TextStyle(fontSize: 12)),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text(
                        quantity.toString(),
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'Rp ${NumberFormat('#,###', 'id_ID').format(harga.toInt())}',
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'Rp ${NumberFormat('#,###', 'id_ID').format(totalHarga.toInt())}',
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                );
              }),
              pw.Divider(),
              // PPN, Status, Metode
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'PPN (${(settings.ppnRate * 100).toStringAsFixed(0)}%)',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                  pw.Text(
                    'Rp ${NumberFormat('#,###', 'id_ID').format((total * settings.ppnRate).toInt())}',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Status', style: pw.TextStyle(fontSize: 12)),
                  pw.Text('Lunas', style: pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Metode', style: pw.TextStyle(fontSize: 12)),
                  pw.Text('Tunai', style: pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.Divider(),
              // Subtotal, Diskon, Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal', style: pw.TextStyle(fontSize: 12)),
                  pw.Text(
                    'Rp ${NumberFormat('#,###', 'id_ID').format(total.toInt())}',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Diskon', style: pw.TextStyle(fontSize: 12)),
                  pw.Text('Rp 0', style: pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Rp ${NumberFormat('#,###', 'id_ID').format((total * 1.1).toInt())}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.Divider(),
              // Dibayar, Kembalian
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Dibayar', style: pw.TextStyle(fontSize: 12)),
                  pw.Text(
                    'Rp ${NumberFormat('#,###', 'id_ID').format(cashGiven.toInt())}',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Kembalian', style: pw.TextStyle(fontSize: 12)),
                  pw.Text(
                    'Rp ${NumberFormat('#,###', 'id_ID').format(change.toInt())}',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              // Terima Kasih dan Jam Operasional
              pw.Text(
                settings.receiptFooter.isNotEmpty
                    ? settings.receiptFooter
                    : 'Terima Kasih',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                settings.receiptHeader.isNotEmpty
                    ? settings.receiptHeader
                    : 'Jam Operasional: 08:00 - 20:00',
                style: pw.TextStyle(fontSize: 10),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );

    if (mounted) {
      Navigator.of(context).pop(); // Close dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    final produk = context.watch<PosProvider>().produk;
    // Sort produk by name
    produk.sort((a, b) => a.nama.compareTo(b.nama));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir'),
        backgroundColor: Colors.grey[300],
        actions: [
          // Printer connection status button
          StreamBuilder<bool>(
            stream: BluetoothPrinterService().connectionStateStream,
            initialData: BluetoothPrinterService().isConnected,
            builder: (context, snapshot) {
              final isConnected =
                  snapshot.data ?? BluetoothPrinterService().isConnected;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => const PrinterConnectionDialog(),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isConnected
                            ? Colors.green[100]
                            : Colors.orange[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.print,
                            color: isConnected ? Colors.green : Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isConnected
                                ? '🖨️ Terhubung'
                                : '🖨️ Belum Terhubung',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isConnected ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            // Tablet/Desktop layout
            return Row(
              children: [
                Expanded(flex: 2, child: _buildProductGrid(produk)),
                Expanded(flex: 1, child: _buildCartPanel()),
              ],
            );
          } else {
            // Mobile layout
            return Column(
              children: [
                Expanded(flex: 3, child: _buildProductGrid(produk)),
                Expanded(flex: 1, child: _buildCartPanel()),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildProductGrid(List<dynamic> produk) {
    final filteredProduk = _selectedKategori == 'Semua'
        ? produk
        : produk.where((p) => p.kategori == _selectedKategori).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Text(
                'Produk',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              DropdownButton<String>(
                value: _selectedKategori,
                items: ['Semua', 'Makanan', 'Minuman', 'Cemilan']
                    .map(
                      (kategori) => DropdownMenuItem(
                        value: kategori,
                        child: Text(kategori),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedKategori = value!),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: filteredProduk.length,
            itemBuilder: (context, index) {
              final p = filteredProduk[index];
              final cartItem = cart.firstWhere(
                (item) => item['produk'].id == p.id,
                orElse: () => <String, dynamic>{},
              );
              final isInCart = cartItem.isNotEmpty;
              final quantity = isInCart ? cartItem['quantity'] : 0;

              return Card(
                elevation: 4,
                child: InkWell(
                  onTap: () => addToCart(p),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if ((p.gambar ?? '').isNotEmpty)
                          Expanded(
                            child: Image.file(
                              File(p.gambar ?? ''),
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          const Expanded(child: Icon(Icons.image, size: 50)),
                        const SizedBox(height: 8),
                        Text(
                          p.nama,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (p.kategori != null) ...[
                          Text(
                            p.kategori!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                        Text('Rp ${p.harga}'),
                        Text('Stok: ${p.stok}'),
                        if (isInCart) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 16),
                                  onPressed: () {
                                    final cartIndex = cart.indexWhere(
                                      (item) => item['produk'].id == p.id,
                                    );
                                    if (cartIndex != -1) {
                                      removeFromCart(cartIndex);
                                    }
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 24,
                                    minHeight: 24,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    '$quantity',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 16),
                                  onPressed: () {
                                    final cartIndex = cart.indexWhere(
                                      (item) => item['produk'].id == p.id,
                                    );
                                    if (cartIndex != -1) {
                                      increaseQuantity(cartIndex);
                                    }
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 24,
                                    minHeight: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCartPanel() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[100],
      child: Column(
        children: [
          // Header dengan indikator langkah
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart, color: Colors.blue, size: 18),
                SizedBox(width: 6),
                Text(
                  'Keranjang Belanja',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Step indicator - smaller
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStepIndicator('1. Pilih', cart.isNotEmpty),
              _buildStepConnector(cart.isNotEmpty),
              _buildStepIndicator('2. Konfirmasi', false),
              _buildStepConnector(false),
              _buildStepIndicator('3. Bayar', false),
            ],
          ),
          const SizedBox(height: 8),

          Expanded(
            child: cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Keranjang masih kosong\nPilih produk dari menu di sebelah kiri',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: (item['produk'].gambar?.isNotEmpty ?? false)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(item['produk'].gambar!),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.image, color: Colors.blue),
                          ),
                          title: Text(
                            item['produk'].nama,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rp ${NumberFormat('#,###', 'id_ID').format(item['produk'].harga.toInt())} x ${item['quantity']}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                'Subtotal: Rp ${NumberFormat('#,###', 'id_ID').format((item['produk'].harga * item['quantity']).toInt())}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Minus button
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.remove,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                  onPressed: () => removeFromCart(index),
                                  tooltip: 'Kurangi jumlah',
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                              // Quantity display
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '${item['quantity']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              // Plus button
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                  onPressed: () => increaseQuantity(index),
                                  tooltip: 'Tambah jumlah',
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          if (cart.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Rp ${NumberFormat('#,###', 'id_ID').format(total.toInt())}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => setState(() => cart.clear()),
                          icon: const Icon(Icons.clear, size: 16),
                          label: const Text(
                            'Clear',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[100],
                            foregroundColor: Colors.red[700],
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: checkout,
                          icon: const Icon(Icons.payment, size: 16),
                          label: const Text(
                            'Konfirmasi',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepIndicator(String title, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey[600],
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Container(
      width: 20,
      height: 2,
      color: isActive ? Colors.green : Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class ReceiptWidget extends StatelessWidget {
  final List<Map<String, dynamic>> cart;
  final double total;
  final double cashGiven;
  final double change;

  const ReceiptWidget({
    super.key,
    required this.cart,
    required this.total,
    required this.cashGiven,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PosProvider>();
    final settings = provider.settings;

    return Container(
      width: 300,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          if (settings.storeLogoPath.isNotEmpty)
            SizedBox(
              height: 50,
              child: Image.file(File(settings.storeLogoPath), height: 50),
            )
          else
            const Text(
              'LOGO',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 8),
          // Nama Toko
          Text(
            settings.storeName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          // Alamat
          Text(
            settings.storeAddress,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // ID Transaksi, Tanggal, Kasir
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ID: TRX${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                'Tanggal: ${DateTime.now().toString().substring(0, 19)}',
                style: const TextStyle(fontSize: 12),
              ),
              const Text('Kasir: Admin', style: TextStyle(fontSize: 12)),
            ],
          ),
          const Divider(),
          // Produk
          ...cart.map((item) {
            final produk = item['produk'] as Produk?;
            final quantity = item['quantity'] as int? ?? 1;
            final nama = produk?.nama ?? 'Produk Tidak Ditemukan';
            final harga = produk?.harga ?? 0.0;
            final totalHarga = harga * quantity;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '$nama x$quantity',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Text(
                  'Rp ${NumberFormat('#,###', 'id_ID').format(totalHarga.toInt())}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }),
          const Divider(),
          // PPN, Status, Metode
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PPN (${(settings.ppnRate * 100).toStringAsFixed(0)}%)',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                'Rp ${NumberFormat('#,###', 'id_ID').format((total * settings.ppnRate).toInt())}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Status', style: TextStyle(fontSize: 12)),
              Text('Lunas', style: TextStyle(fontSize: 12)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Metode', style: TextStyle(fontSize: 12)),
              const Text('Tunai', style: TextStyle(fontSize: 12)),
            ],
          ),
          const Divider(),
          // Subtotal, Diskon, Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(fontSize: 12)),
              Text(
                'Rp ${NumberFormat('#,###', 'id_ID').format(total.toInt())}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Diskon', style: TextStyle(fontSize: 12)),
              Text('Rp 0', style: TextStyle(fontSize: 12)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                'Rp ${NumberFormat('#,###', 'id_ID').format((total * 1.1).toInt())}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(),
          // Dibayar, Kembalian
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Dibayar', style: TextStyle(fontSize: 12)),
              Text(
                'Rp ${cashGiven.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Kembalian', style: TextStyle(fontSize: 12)),
              Text(
                'Rp ${change.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Terima Kasih dan Jam Operasional
          Text(
            settings.receiptFooter.isNotEmpty
                ? settings.receiptFooter
                : 'Terima Kasih',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            settings.receiptHeader.isNotEmpty
                ? settings.receiptHeader
                : 'Jam Operasional: 08:00 - 20:00',
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
