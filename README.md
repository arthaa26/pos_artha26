# POS Artha26

Aplikasi Point of Sale (POS) untuk mengelola toko dengan fitur lengkap CRUD untuk produk dan transaksi.

## Fitur

- **Dashboard**: Ringkasan pendapatan, keuntungan, transaksi, dan pengeluaran harian
- **Kasir**: Tambah produk ke keranjang, hitung total, checkout dengan berbagai metode pembayaran
- **Produk**: Kelola produk (tambah, edit, hapus, upload gambar, filter, sort)
- **Pengeluaran**: Catat pengeluaran
- **Laporan**: Lihat ringkasan dan riwayat transaksi, export ke Excel
- **Riwayat**: Lihat semua transaksi
- **Pengaturan**: Konfigurasi nama toko dan tema

## Struktur Proyek

```
pos_artha26/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── produk.dart
│   │   ├── summary.dart
│   │   └── transaksi.dart
│   ├── providers/
│   │   └── pos_provider.dart
│   ├── screens/
│   │   ├── kasir_page.dart
│   │   ├── laporan_page.dart
│   │   ├── pengaturan_page.dart
│   │   ├── pengeluaran_page.dart
│   │   ├── produk_page.dart
│   │   ├── register_page.dart
│   │   ├── riwayat_page.dart
│   │   └── splash_screen.dart
│   └── services/
│       ├── api_service.dart
│       ├── network_config.dart
│       ├── network_config_io.dart
│       └── network_config_web.dart
├── backend/
│   ├── config/
│   │   └── .env
│   ├── init.sql
│   ├── package.json
│   ├── server.js
│   └── uploads/
└── README.md
```

## Setup Backend

1. Pastikan Node.js terinstall
2. Install dependencies: `npm install`
3. Setup database MySQL (gunakan Laragon atau XAMPP)
4. Buat database `pos_artha26` atau sesuaikan di `.env`
5. Jalankan server: `npm start`

## Setup Flutter

1. Pastikan Flutter SDK terinstall
2. Install dependencies: `flutter pub get`
3. Jalankan app: `flutter run`

## Konfigurasi Database

- Default menggunakan MySQL di localhost:3306
- Username: root, Password: (kosong)
- Database: pos_artha26
- Sesuaikan di `backend/config/.env` jika berbeda

## Troubleshooting

### Produk tidak tampil
- Pastikan MySQL running (start Laragon/XAMPP).
- Check console Flutter untuk error "Error loading produk".
- Gunakan tombol refresh di halaman produk.
- Jika error koneksi, cek network config di `lib/services/network_config.dart`.

### Backend tidak start
- Pastikan MySQL running sebelum `npm start`.
- Jika port 3000 conflict, ubah PORT di `backend/config/.env`.

1. Pastikan Node.js terinstall
2. Install dependencies: `npm install`
3. Setup database MySQL (gunakan Laragon atau XAMPP)
4. Buat database `pos_artha26` atau sesuaikan di `.env`
5. Jalankan server: `npm start`

## Setup Flutter

1. Pastikan Flutter SDK terinstall
2. Install dependencies: `flutter pub get`
3. Jalankan app: `flutter run`

## Konfigurasi Database

- Default menggunakan MySQL di localhost:3306
- Username: root, Password: (kosong)
- Database: pos_artha26
- Sesuaikan di `backend/.env` jika berbeda

## API Endpoints

- `GET /api/summary` - Ringkasan harian
- `GET /api/transaksi` - Daftar transaksi
- `POST /api/transaksi` - Tambah transaksi
- `GET /api/produk` - Daftar produk
- `POST /api/produk` - Tambah produk
- `PUT /api/produk/:id` - Update produk
- `DELETE /api/produk/:id` - Hapus produk
- `PUT /api/produk/:id/stok` - Update stok
- `POST /upload` - Upload gambar
- `POST /register` - Registrasi user
- `POST /login` - Login
- `POST /google-login` - Login Google

## Teknologi

- **Frontend**: Flutter
- **Backend**: Node.js + Express
- **Database**: MySQL
- **Upload**: Multer
- **Auth**: bcrypt, Google OAuth
