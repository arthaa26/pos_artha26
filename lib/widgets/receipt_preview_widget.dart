import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class ReceiptPreviewWidget extends StatelessWidget {
  final String storeName;
  final String storeAddress;
  final String storePhone;
  final String storeLogoPath;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double ppnRate;
  final double cashGiven;
  final double change;
  final String transactionNumber;
  final DateTime transactionTime;
  final String? thankYouMessage;
  final String? operatingHours;

  const ReceiptPreviewWidget({
    super.key,
    required this.storeName,
    required this.storeAddress,
    required this.storePhone,
    required this.storeLogoPath,
    required this.items,
    required this.subtotal,
    required this.ppnRate,
    required this.cashGiven,
    required this.change,
    required this.transactionNumber,
    required this.transactionTime,
    this.thankYouMessage,
    this.operatingHours,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'id_ID');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
    final ppnAmount = subtotal * ppnRate;
    final grandTotal = subtotal + ppnAmount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo - Centered
          SizedBox(
            height: 60,
            width: double.infinity,
            child: _buildLogoWidget(),
          ),
          const SizedBox(height: 8),

          // Nama Toko - Centered
          Text(
            storeName.isNotEmpty ? storeName : 'Nama Toko',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          // Alamat - Centered
          Text(
            storeAddress.isNotEmpty ? storeAddress : 'Alamat Toko',
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),

          // Telepon - Centered
          if (storePhone.isNotEmpty)
            Text(
              storePhone,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),

          const SizedBox(height: 8),
          const Divider(),

          // ID Transaksi, Tanggal, Kasir - Centered
          Text(
            'No: $transactionNumber',
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          Text(
            dateFormat.format(transactionTime),
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          Text(
            'Kasir: Admin',
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),
          const Divider(),

          // Produk Header
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  'Item',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Qty',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Harga',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Total',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const Divider(),

          // Produk Items
          ...items.map((item) {
            final nama = item['nama'] as String? ?? 'Produk';
            final qty = item['jumlah'] as int? ?? 1;
            final harga = item['hargaSatuan'] as double? ?? 0.0;
            final total = item['subtotal'] as double? ?? 0.0;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 4,
                  child: Text(nama, style: const TextStyle(fontSize: 12)),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    qty.toString(),
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Rp ${formatter.format(harga.toInt())}',
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Rp ${formatter.format(total.toInt())}',
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            );
          }),

          const Divider(),

          // Summary - Right Aligned
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(fontSize: 12)),
              Text(
                'Rp ${formatter.format(subtotal.toInt())}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),

          if (ppnAmount > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PPN (${(ppnRate * 100).toStringAsFixed(0)}%)',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Rp ${formatter.format(ppnAmount.toInt())}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],

          const SizedBox(height: 4),
          const Divider(),

          // Total - Bold
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                'Rp ${formatter.format(grandTotal.toInt())}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const Divider(),

          // Payment Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Dibayar', style: TextStyle(fontSize: 12)),
              Text(
                'Rp ${formatter.format(cashGiven.toInt())}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Kembalian', style: TextStyle(fontSize: 12)),
              Text(
                'Rp ${formatter.format(change.toInt())}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),

          // Terima Kasih - Centered
          Text(
            thankYouMessage ?? 'TERIMA KASIH',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // Jam Operasional - Centered
          if (operatingHours != null && operatingHours!.isNotEmpty)
            Text(
              operatingHours!,
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),

          const SizedBox(height: 4),

          // Powered by POS Artha - Centered
          const Text(
            'Powered by POS Artha',
            style: TextStyle(fontSize: 10, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoWidget() {
    try {
      if (storeLogoPath.isNotEmpty) {
        final file = File(storeLogoPath);
        if (file.existsSync()) {
          return Image.file(
            file,
            height: 60,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildLogoPlaceholder();
            },
          );
        }
      }
    } catch (e) {
      // Fall through to placeholder
    }
    return _buildLogoPlaceholder();
  }

  Widget _buildLogoPlaceholder() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'LOGO',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
