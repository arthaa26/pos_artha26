# Flowchart Sistem POS Artha26

Berikut adalah flowchart yang menggambarkan alur kerja sistem Point of Sale (POS) Artha26.

> **Catatan**: Diagram di bawah menggunakan syntax Mermaid yang didukung langsung oleh GitHub untuk rendering visual. Jika tidak terlihat, pastikan browser Anda mendukung Mermaid atau gunakan ekstensi yang sesuai.

## Diagram Alur Sistem Utama

```mermaid
graph TD
    A[User Membuka Aplikasi] --> B[Splash Screen]
    B --> C{Cek Login Status}

    C -->|Belum Login| D[Halaman Register/Login]
    C -->|Sudah Login| E[Dashboard]

    D --> F[Proses Login/Register]
    F -->|Berhasil| E
    F -->|Gagal| D

    E --> G[Menu Kasir]
    E --> H[Menu Produk]
    E --> I[Menu Laporan]
    E --> J[Menu Riwayat]
    E --> K[Menu Pengaturan]

    G --> L[Scan/Tambah Produk]
    L --> M[Hitung Total]
    M --> N[Pilih Metode Pembayaran]
    N --> O[Proses Pembayaran]
    O --> P[Print Struk]
    P --> E

    H --> Q[Tambah Produk Baru]
    H --> R[Edit Produk]
    H --> S[Hapus Produk]
    H --> T[Update Stok]
    Q --> E
    R --> E
    S --> E
    T --> E

    I --> U[Laporan Transaksi]
    I --> V[Laporan Produk Terjual]
    I --> W[Laporan Pengeluaran]
    I --> X[Laporan Metode Pembayaran]
    I --> Y[Laporan Kasir]
    U --> E
    V --> E
    W --> E
    X --> E
    Y --> E

    J --> Z[Tampil Riwayat Transaksi]
    Z --> AA[Filter/Cari Riwayat]
    AA --> E

    K --> BB[Edit Profil]
    K --> CC[Keamanan]
    K --> DD[Pengaturan Aplikasi]
    BB --> E
    CC --> E
    DD --> E
```

### Alternatif ASCII Art (jika Mermaid tidak terender):

```
User Membuka Aplikasi
         |
    Splash Screen
         |
    Cek Login Status
    /            \
Belum Login     Sudah Login
    |               |
Register/Login --> Dashboard
    ^               |
    |               |
 Gagal Login        |
                    |
          +---------+---------+
          |         |         |
       Kasir    Produk   Laporan
          |         |         |
     Tambah --> Edit --> Laporan
    Produk    Produk   Transaksi
         |         |         |
    Hitung --> Update --> dll.
    Total     Stok
         |
   Pilih Pembayaran
         |
   Proses Pembayaran
         |
    Print Struk
         |
    Kembali ke Dashboard
```

## Diagram Arsitektur Sistem

```mermaid
graph TB
    subgraph "Frontend (Flutter)"
        A[Mobile App]
        A1[Auth Screens]
        A2[Dashboard]
        A3[Kasir]
        A4[Produk Management]
        A5[Laporan]
        A6[Riwayat]
        A7[Pengaturan]
    end

    subgraph "Backend (Node.js)"
        B[Express Server]
        B1[Auth API]
        B2[Transaksi API]
        B3[Produk API]
        B4[Laporan API]
        B5[File Upload API]
    end

    subgraph "Database (MySQL)"
        C[(pos_artha26)]
        C1[users table]
        C2[transaksi table]
        C3[produk table]
    end

    subgraph "External Services"
        D[Google OAuth]
        E[Local Storage]
        F[Printer Service]
    end

    A --> B
    B --> C
    B --> D
    A --> E
    A --> F

    B1 --> C1
    B2 --> C2
    B3 --> C3
    B4 --> C2
    B4 --> C3
```

### Alternatif ASCII Art Arsitektur:

```
+-------------------+     +-------------------+     +-------------------+
|   Frontend        |     |   Backend         |     |   Database        |
|   (Flutter)       | --> |   (Node.js)       | --> |   (MySQL)         |
|                   |     |                   |     |                   |
| - Auth Screens    |     | - Express Server  |     | - users table     |
| - Dashboard       |     | - Auth API        |     | - transaksi table |
| - Kasir           |     | - Transaksi API   |     | - produk table    |
| - Produk Mgmt     |     | - Produk API      |     |                   |
| - Laporan         |     | - Laporan API     |     +-------------------+
| - Riwayat         |     | - File Upload API |             ^
| - Pengaturan      |     +-------------------+             |
+-------------------+             |                        |
                                 |                        |
                    +------------+------------------------+
                    |            |
                    v            v
         +-------------------+  +-------------------+
         |  Google OAuth     |  |  Local Storage    |
         +-------------------+  +-------------------+
                    |
                    v
         +-------------------+
         |  Printer Service  |
         +-------------------+
```

## Diagram Alur Transaksi

```mermaid
sequenceDiagram
    participant U as User
    participant A as App (Flutter)
    participant S as Server (Node.js)
    participant DB as Database (MySQL)

    U->>A: Pilih produk
    A->>A: Hitung total
    U->>A: Pilih metode pembayaran
    A->>S: Kirim data transaksi
    S->>DB: Insert transaksi
    DB-->>S: Konfirmasi
    S-->>A: Response berhasil
    A->>A: Print struk
    A->>U: Tampilkan struk

    Note over A,S: Jika offline
    A->>A: Simpan ke local DB
    A->>S: Sync saat online
```

### Alternatif ASCII Art Transaksi:

```
User --> App: Pilih produk
App --> App: Hitung total
User --> App: Pilih metode pembayaran
App --> Server: Kirim data transaksi
Server --> Database: Insert transaksi
Database --> Server: Konfirmasi
Server --> App: Response berhasil
App --> App: Print struk
App --> User: Tampilkan struk

Catatan: Jika offline, simpan ke local DB dan sync saat online
```

## Diagram Alur Produk Management

```mermaid
stateDiagram-v2
    [*] --> ProdukList
    ProdukList --> TambahProduk : Klik Tambah
    ProdukList --> EditProduk : Klik Edit
    ProdukList --> HapusProduk : Klik Hapus

    TambahProduk --> UploadGambar
    UploadGambar --> SimpanProduk
    SimpanProduk --> ProdukList : Berhasil

    EditProduk --> UpdateProduk
    UpdateProduk --> ProdukList : Berhasil

    HapusProduk --> KonfirmasiHapus
    KonfirmasiHapus --> ProdukList : Dihapus

    ProdukList --> [*] : Logout
```

### Alternatif ASCII Art Produk Management:

```
[*] --> ProdukList
ProdukList --> TambahProduk : Klik Tambah
ProdukList --> EditProduk : Klik Edit
ProdukList --> HapusProduk : Klik Hapus

TambahProduk --> UploadGambar
UploadGambar --> SimpanProduk
SimpanProduk --> ProdukList : Berhasil

EditProduk --> UpdateProduk
UpdateProduk --> ProdukList : Berhasil

HapusProduk --> KonfirmasiHapus
KonfirmasiHapus --> ProdukList : Dihapus

ProdukList --> [*] : Logout
```

## Penjelasan Flowchart

### Sistem Utama:
1. **Splash Screen**: Halaman pembuka aplikasi
2. **Authentication**: Login/Register untuk akses sistem
3. **Dashboard**: Menu utama dengan navigasi ke berbagai fitur
4. **Kasir**: Proses transaksi penjualan
5. **Produk**: Manajemen inventori produk
6. **Laporan**: Berbagai jenis laporan bisnis
7. **Riwayat**: Riwayat transaksi
8. **Pengaturan**: Konfigurasi aplikasi dan profil

### Arsitektur:
- **Frontend**: Aplikasi mobile Flutter
- **Backend**: Server API Node.js dengan Express
- **Database**: MySQL untuk penyimpanan data
- **Services**: Integrasi dengan Google OAuth, storage lokal, dan printer

### Alur Khusus:
- **Transaksi**: Dari pemilihan produk hingga pembayaran dan struk
- **Produk**: CRUD operations untuk manajemen produk

Flowchart ini memberikan gambaran komprehensif tentang bagaimana sistem POS Artha26 bekerja dari perspektif user dan teknis.

> **Tips untuk GitHub**: Jika diagram Mermaid tidak muncul, Anda bisa:
> 1. Menggunakan browser yang mendukung Mermaid
> 2. Menginstall ekstensi browser seperti "Mermaid Preview"
> 3. Menggunakan alternatif ASCII art yang disediakan di atas