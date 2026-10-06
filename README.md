# ☕ Documentation Database - Kedai Kopi Mbah Buyut

Repositori ini berisi rancangan skema database relational (SQL) untuk **Sistem Pemesanan Digital & Aplikasi Kasir Berbasis Web** di Kedai Kopi Mbah Buyut. Sistem ini dirancang untuk mengintegrasikan pemesanan mandiri via QR Code, operasional kasir, fitur loyalitas pelanggan berbasis koin, serta laporan penjualan harian.

---

## 🚀 Fitur Utama Sistem

* **Multi-User Access Control:** Pemisahan hak akses unik untuk 3 peran (Admin, Kasir, dan Pelanggan).
* **Self-Service QR Code Order:** Pelanggan dapat memesan langsung dari meja tanpa antre, memilih varian menu, dan menambahkan catatan pesanan.
* **Sistem Kasir (POS):** Kemudahan bagi kasir untuk memproses transaksi langsung (manual) serta konfirmasi/penolakan pesanan masuk dari pelanggan.
* **Program Loyalitas Koin:** Perolehan koin otomatis saat bertransaksi dan opsi penukaran koin menjadi potongan harga saat checkout.
* **Fleksibilitas Pembayaran:** Mendukung metode pembayaran Tunai (*Cash*) dan Non-Tunai (*QRIS/E-Wallet*) beserta pencatatan bukti transaksi.
* **Manajemen Operasional:** Pengaturan jam operasional toko serta statistik laporan penjualan.

---

## 🗄️ Penjelasan Struktur Tabel Database

Database `kedai_kopi_mbah_buyut` terdiri dari 8 tabel utama yang saling terhubung:

### 1. Manajemen Pengguna
* **`roles`**: Menyimpan daftar peran pengguna dalam sistem (`Admin`, `Kasir`, `Pelanggan`).
* **`users`**: Menyimpan profil data pengguna (nama, email, telepon, kata sandi, dan saldo koin loyalitas).

### 2. Master Data Menu
* **`categories`**: Menyimpan pengelompokan jenis menu (misal: *Coffee, Non-Coffee, Snack, Main Course*).
* **`menus`**: Menyimpan data utama produk mencakup nama menu, deskripsi, harga dasar, gambar, dan status ketersediaan.
* **`menu_variants`**: Menyimpan opsi tambahan produk (seperti ukuran, variasi rasa, level gula, atau ekstra shot) beserta penyesuaian harganya.

### 3. Operasional & Transaksi
* **`operating_hours`**: Menyimpan jadwal jam buka dan jam tutup kedai per hari untuk membatasi akses pemesanan digital secara otomatis.
* **`orders`**: Tabel utama mencatat data transaksi pemesanan (kode transaksi, nomor meja, jenis pesanan *dine-in/takeaway*, status pesanan, total bayar, serta penggunaan koin diskon).
* **`order_details`**: Tabel rincian item pesanan yang mencatat item menu, varian yang dipilih, jumlah (*qty*), serta subtotal harga.

### 4. Pembayaran & Loyalitas
* **`payment_methods`**: Menyimpan opsi metode pembayaran yang tersedia (`Tunai`, `QRIS`, `Transfer Bank`).
* **`payments`**: Mencatat proses pelunasan transaksi, jumlah bayar, kembalian, status pembayaran, serta penyimpanan file bukti pembayaran non-tunai.
* **`coin_logs`**: Mencatat riwayat masuk (*earned*) dan keluar (*redeemed*) saldo koin milik pelanggan sebagai transparansi sistem loyalitas.

---

## 🛠️ Cara Penggunaan

1. Pastikan server database **MySQL / MariaDB** sudah aktif.
2. Buat database baru atau langsung jalankan script SQL yang tersedia:
   ```bash
   mysql -u root -p < schema.sql


---------------------------
Made by: Gemini
