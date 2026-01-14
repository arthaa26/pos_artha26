import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import '../../models/produk.dart';
import '../../models/transaksi.dart';
import '../../providers/pos_provider.dart';

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
                    final produk = item['produk'] as Produk;
                    final quantity = item['quantity'] as int;
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
                                  'Rp ${produk.harga.toStringAsFixed(0)} x $quantity',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Rp ${subtotal.toStringAsFixed(0)}',
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
                    'Rp ${total.toStringAsFixed(0)}',
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
            child: const Text('Batal'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              showPaymentDialog();
            },
            child: const Text('Lanjut ke Pembayaran'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
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
                    'Rp ${total.toStringAsFixed(0)}',
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
            child: const Text('Batal'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
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
            child: const Text('Proses Pembayaran'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
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
      child: Text('Rp ${amount.toStringAsFixed(0)}'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black,
        minimumSize: const Size(70, 32),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  void processPayment(double cashGiven, double change) {
    // Show payment summary
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pembayaran Berhasil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Transaksi berhasil diproses!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:'),
                      Text('Rp ${total.toStringAsFixed(0)}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dibayar:'),
                      Text('Rp ${cashGiven.toStringAsFixed(0)}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Kembalian:'),
                      Text(
                        'Rp ${change.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              finalizeTransaction(cashGiven, change);
            },
            child: const Text('Cetak Struk'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> finalizeTransaction(double cashGiven, double change) async {
    double pendapatan = total;
    double keuntungan = total * 0.2; // Asumsi margin 20%
    double pengeluaran = 0;
    String deskripsi =
        'Penjualan: ${cart.map((item) => '${item['produk'].nama} x${item['quantity']}').join(', ')}';

    // Simpan detail produk untuk riwayat
    List<Map<String, dynamic>> transactionItems = cart.map((item) {
      final produk = item['produk'] as Produk;
      return {
        'nama': produk.nama,
        'harga': produk.harga,
        'quantity': item['quantity'],
        'total': produk.harga * (item['quantity'] as int),
      };
    }).toList();

    final transaksi = Transaksi(
      pendapatan: pendapatan,
      keuntungan: keuntungan,
      pengeluaran: pengeluaran,
      deskripsi: deskripsi,
      tanggal: DateTime.now(),
      items: transactionItems,
      paymentMethod: 'Tunai',
      cashGiven: cashGiven,
      change: change,
    );

    try {
      await context.read<PosProvider>().addTransaksi(transaksi);

      // Kurangi stok untuk setiap item di cart
      for (var item in cart) {
        await context.read<PosProvider>().updateStok(
          item['produk'].id!,
          item['quantity'],
        );
      }

      // Show receipt and print
      await _printReceipt(cashGiven, change);

      // Clear cart after payment
      setState(() {
        cart.clear();
        total = 0;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil! Data tersimpan di riwayat.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _printReceipt(double cashGiven, double change) async {
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
                    'ID: TRX${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
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
                        'Rp ${harga.toStringAsFixed(0)}',
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'Rp ${totalHarga.toStringAsFixed(0)}',
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
                    'Rp ${(total * settings.ppnRate).toStringAsFixed(0)}',
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
                    'Rp ${total.toStringAsFixed(0)}',
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
                    'Rp ${(total * 1.1).toStringAsFixed(0)}',
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
                    'Rp ${cashGiven.toStringAsFixed(0)}',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Kembalian', style: pw.TextStyle(fontSize: 12)),
                  pw.Text(
                    'Rp ${change.toStringAsFixed(0)}',
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

    Navigator.of(context).pop(); // Close dialog
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

  Widget _buildProductGrid(List<Produk> produk) {
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
                        if (p.gambar.isNotEmpty)
                          Expanded(
                            child: Image.network(p.gambar, fit: BoxFit.cover),
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
                            child: item['produk'].gambar.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item['produk'].gambar,
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
                                'Rp ${item['produk'].harga.toStringAsFixed(0)} x ${item['quantity']}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                'Subtotal: Rp ${(item['produk'].harga * item['quantity']).toStringAsFixed(0)}',
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
                        'Rp ${total.toStringAsFixed(0)}',
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
                  'Rp ${totalHarga.toStringAsFixed(0)}',
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
                'Rp ${(total * settings.ppnRate).toStringAsFixed(0)}',
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
              const Text('Tunai', style: const TextStyle(fontSize: 12)),
            ],
          ),
          const Divider(),
          // Subtotal, Diskon, Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(fontSize: 12)),
              Text(
                'Rp ${total.toStringAsFixed(0)}',
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
                'Rp ${(total * 1.1).toStringAsFixed(0)}',
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
