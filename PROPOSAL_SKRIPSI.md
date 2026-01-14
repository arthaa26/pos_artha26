# PROPOSAL SKRIPSI

## PENGEMBANGAN APLIKASI POINT OF SALE (POS) BERBASIS MOBILE DENGAN FITUR OFFLINE UNTUK KEDAI SIOMAY NENEK PANCI

### Disusun Oleh:
[Nama Lengkap Mahasiswa]  
[NIM]  
[Program Studi]  
[Universitas]  

### Dosen Pembimbing:
[Dr. Nama Dosen Pembimbing]  

### Tanggal Pengajuan:
12 Januari 2026  

---

## BAB I: PENDAHULUAN

### 1.1 Latar Belakang

Perkembangan teknologi informasi telah membawa perubahan signifikan dalam dunia bisnis, termasuk pada usaha mikro, kecil, dan menengah (UMKM). Kedai Siomay Nenek Panci sebagai salah satu UMKM di bidang kuliner tradisional menghadapi tantangan dalam pengelolaan operasional sehari-hari. Sistem penjualan manual yang masih digunakan seringkali menyebabkan kesulitan dalam pencatatan transaksi, pengelolaan stok produk, dan pelaporan keuangan.

Dalam era digital saat ini, implementasi sistem Point of Sale (POS) berbasis mobile menjadi solusi efektif untuk meningkatkan efisiensi operasional bisnis kuliner. Aplikasi POS modern tidak hanya memfasilitasi transaksi penjualan tetapi juga harus mampu beroperasi dalam kondisi offline, yang sangat penting untuk bisnis kuliner yang sering beroperasi di lokasi dengan koneksi internet terbatas.

Berdasarkan observasi awal, Kedai Siomay Nenek Panci mengalami beberapa masalah operasional:
- Pencatatan transaksi manual yang rentan kesalahan
- Kesulitan monitoring stok produk secara real-time
- Keterbatasan akses data saat koneksi internet tidak stabil
- Kurangnya sistem pelaporan yang akurat dan cepat

Oleh karena itu, pengembangan aplikasi POS berbasis mobile dengan fitur offline menjadi sangat relevan untuk mengatasi permasalahan tersebut dan meningkatkan produktivitas bisnis Kedai Siomay Nenek Panci.

### 1.2 Rumusan Masalah

Berdasarkan latar belakang di atas, rumusan masalah dalam penelitian ini adalah:

1. Bagaimana merancang sistem POS yang dapat beroperasi secara offline dan online?
2. Bagaimana mengimplementasikan penyimpanan data lokal menggunakan database SQLite?
3. Bagaimana mengintegrasikan fitur sinkronisasi data antara mode offline dan online?
4. Bagaimana mengembangkan antarmuka pengguna yang user-friendly untuk operasional kedai siomay?
5. Bagaimana menguji kehandalan aplikasi dalam kondisi offline dan online?

### 1.3 Tujuan Penelitian

Tujuan utama dari penelitian ini adalah:

1. Mengembangkan aplikasi POS berbasis mobile dengan fitur offline untuk Kedai Siomay Nenek Panci
2. Mengimplementasikan sistem penyimpanan data lokal menggunakan SQLite
3. Merancang mekanisme sinkronisasi data yang efisien antara mode offline dan online
4. Menguji performa dan kehandalan aplikasi dalam berbagai kondisi jaringan

### 1.4 Manfaat Penelitian

Manfaat yang diharapkan dari penelitian ini adalah:

1. **Manfaat Praktis untuk Kedai Siomay Nenek Panci:**
   - Meningkatkan efisiensi operasional penjualan
   - Mengurangi kesalahan dalam pencatatan transaksi
   - Memungkinkan operasional bisnis tanpa tergantung koneksi internet
   - Mempercepat proses pelaporan dan analisis penjualan

2. **Manfaat Akademis:**
   - Menambah khasanah pengetahuan tentang pengembangan aplikasi mobile offline-first
   - Memberikan contoh implementasi praktis teknologi Flutter dan SQLite
   - Berkontribusi pada pengembangan solusi teknologi untuk UMKM

3. **Manfaat Sosial:**
   - Mendukung digitalisasi UMKM di Indonesia
   - Meningkatkan daya saing bisnis kuliner tradisional

### 1.5 Ruang Lingkup Penelitian

Ruang lingkup penelitian ini meliputi:

1. Pengembangan aplikasi mobile menggunakan framework Flutter
2. Implementasi fitur offline menggunakan SQLite database
3. Pengembangan backend server menggunakan Node.js dan Express
4. Integrasi dengan sistem autentikasi dan manajemen produk
5. Pengujian aplikasi pada perangkat Android
6. Implementasi di Kedai Siomay Nenek Panci sebagai studi kasus

### 1.6 Metodologi Penelitian

Penelitian ini menggunakan metode pengembangan perangkat lunak dengan pendekatan:

1. **Metode Pengembangan:** Agile Development dengan model prototyping
2. **Bahasa Pemrograman:** Dart (Flutter) untuk frontend, JavaScript (Node.js) untuk backend
3. **Database:** SQLite untuk penyimpanan lokal, MySQL untuk server
4. **Tools:** Android Studio, VS Code, Postman untuk testing API

---

## BAB II: TINJAUAN PUSTAKA

### 2.1 Kajian Teori

#### 2.1.1 Sistem Point of Sale (POS)
Sistem POS adalah perangkat lunak yang digunakan untuk memproses transaksi penjualan ritel. Sistem POS modern terintegrasi dengan berbagai fitur seperti manajemen inventori, pelaporan, dan analitik penjualan.

#### 2.1.2 Aplikasi Offline-First
Konsep offline-first mengutamakan kemampuan aplikasi untuk beroperasi tanpa koneksi internet. Data disimpan secara lokal dan disinkronisasi ketika koneksi tersedia.

#### 2.1.3 Framework Flutter
Flutter adalah framework UI open-source dari Google untuk membangun aplikasi native yang dapat berjalan di Android dan iOS dari satu basis kode.

#### 2.1.4 SQLite Database
SQLite adalah database relasional embedded yang tidak memerlukan server terpisah. Cocok untuk aplikasi mobile yang membutuhkan penyimpanan lokal.

### 2.2 Kajian Empiris

Beberapa penelitian terkait yang telah dilakukan:

1. **Pengembangan Aplikasi POS untuk UMKM** (2022) - Fokus pada implementasi fitur dasar POS
2. **Offline Capability in Mobile Applications** (2023) - Studi tentang strategi offline-first development
3. **Flutter Framework for Business Applications** (2024) - Analisis penggunaan Flutter dalam konteks bisnis

### 2.3 Kerangka Teori

Kerangka teori penelitian ini meliputi:
- Teori Sistem Informasi
- Konsep Offline-First Architecture
- Model Pengembangan Aplikasi Mobile
- Teori User Experience Design

---

## BAB III: METODOLOGI PENELITIAN

### 3.1 Metode Pengembangan

Penelitian ini menggunakan metode pengembangan perangkat lunak dengan pendekatan Agile, khususnya model Scrum yang terdiri dari:

1. **Planning:** Analisis kebutuhan dan perancangan sistem
2. **Development:** Implementasi fitur-fitur aplikasi
3. **Testing:** Pengujian fungsionalitas dan performa
4. **Deployment:** Implementasi di lingkungan produksi

### 3.2 Teknik Pengumpulan Data

1. **Observasi:** Pengamatan langsung operasional Kedai Siomay Nenek Panci
2. **Wawancara:** Pengumpulan kebutuhan dari pemilik dan karyawan kedai
3. **Studi Literatur:** Kajian pustaka tentang teknologi terkait
4. **Testing:** Pengujian aplikasi dalam berbagai skenario

### 3.3 Alat dan Bahan

1. **Hardware:**
   - Komputer dengan spesifikasi minimal
   - Smartphone Android untuk testing
   - Server untuk backend (opsional)

2. **Software:**
   - Flutter SDK
   - Android Studio
   - VS Code
   - Node.js
   - MySQL Server
   - Git untuk version control

### 3.4 Analisis dan Perancangan Sistem

#### 3.4.1 Analisis Kebutuhan

Fitur-fitur yang akan dikembangkan:
- Manajemen produk (tambah, edit, hapus)
- Proses transaksi penjualan
- Manajemen stok
- Pelaporan penjualan
- Sistem favorit produk
- Mode offline/online

#### 3.4.2 Perancangan Database

**Database Lokal (SQLite):**
- Tabel products: menyimpan data produk
- Tabel transactions: menyimpan data transaksi
- Tabel settings: menyimpan konfigurasi aplikasi

**Database Server (MySQL):**
- Struktur mirip dengan database lokal
- Tambahan tabel users untuk autentikasi

#### 3.4.3 Perancangan Antarmuka

Antarmuka aplikasi dirancang dengan prinsip:
- User-friendly dan intuitif
- Responsive design
- Konsistensi visual
- Navigasi yang mudah

### 3.5 Implementasi

Implementasi dilakukan dalam beberapa tahap:

1. **Setup Project:** Inisialisasi project Flutter dan backend
2. **Database Development:** Pembuatan schema database
3. **API Development:** Pengembangan REST API
4. **Frontend Development:** Implementasi UI dan logika aplikasi
5. **Offline Functionality:** Implementasi fitur offline dan sinkronisasi
6. **Testing:** Pengujian menyeluruh aplikasi

### 3.6 Pengujian

Pengujian dilakukan dengan metode:

1. **Unit Testing:** Pengujian komponen individual
2. **Integration Testing:** Pengujian integrasi antar komponen
3. **User Acceptance Testing:** Pengujian oleh pengguna akhir
4. **Performance Testing:** Pengujian performa dalam kondisi offline/online

---

## BAB IV: JADWAL PENELITIAN

| No | Kegiatan | Bulan 1 | Bulan 2 | Bulan 3 | Bulan 4 | Bulan 5 | Bulan 6 |
|----|----------|---------|---------|---------|---------|---------|---------|
| 1 | Analisis Kebutuhan | ✓ | | | | | |
| 2 | Perancangan Sistem | ✓ | ✓ | | | | |
| 3 | Implementasi Backend | | ✓ | ✓ | | | |
| 4 | Implementasi Frontend | | | ✓ | ✓ | | |
| 5 | Implementasi Offline | | | | ✓ | ✓ | |
| 6 | Testing & Debugging | | | | | ✓ | ✓ |
| 7 | Deployment & Dokumentasi | | | | | | ✓ |

---

## BAB V: DAFTAR PUSTAKA

1. Flutter Documentation. (2024). *Build apps for any screen*. Diakses dari https://flutter.dev/
2. SQLite Documentation. (2024). *SQLite Home Page*. Diakses dari https://www.sqlite.org/
3. Sommerville, I. (2016). *Software Engineering* (10th ed.). Pearson.
4. Pressman, R. S. (2014). *Software Engineering: A Practitioner's Approach* (8th ed.). McGraw-Hill.
5. Nielsen, J. (1994). *Usability Engineering*. Morgan Kaufmann.
6. Research papers on offline-first mobile applications (2022-2024)

---

## LAMPIRAN

### Lampiran 1: Spesifikasi Teknis Aplikasi

**Frontend:**
- Framework: Flutter 3.x
- Bahasa: Dart
- State Management: Provider
- UI Components: Material Design

**Backend:**
- Runtime: Node.js 18.x
- Framework: Express.js
- Database: MySQL 8.x
- Authentication: JWT

**Database Lokal:**
- SQLite 3.x
- Schema: Relational dengan foreign key constraints

### Lampiran 2: Use Case Diagram

[Use Case Diagram akan disisipkan di sini]

### Lampiran 3: Entity Relationship Diagram

[ERD akan disisipkan di sini]

---

*Proposal ini disusun sebagai dokumen awal untuk pengembangan aplikasi POS offline untuk Kedai Siomay Nenek Panci. Dokumen ini akan diperbaharui sesuai dengan perkembangan penelitian.*