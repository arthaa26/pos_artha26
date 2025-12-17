import 'package:flutter/material.dart';

void main() {
  runApp(const PosArthaApp());
}

class PosArthaApp extends StatelessWidget {
  const PosArthaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PosHomePage(),
    );
  }
}

class PosHomePage extends StatelessWidget {
  const PosHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('POS Artha 26 - Kasir')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.shopping_cart_checkout, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text('Belum ada transaksi.', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Fungsi tambah barang akan diletakkan di sini
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
