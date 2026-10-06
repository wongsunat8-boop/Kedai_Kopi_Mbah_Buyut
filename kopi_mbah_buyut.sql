-- ========================================================
-- DATABASE STRUCTURE: KEDAI KOPI MBAH BUYUT
-- ========================================================

CREATE DATABASE IF NOT EXISTS kedai_kopi_mbah_buyut;
USE kedai_kopi_mbah_buyut;

-- --------------------------------------------------------
-- 1. ENTITAS MANAJEMEN PENGGUNA & HAK AKSES (ROLES & USERS)
-- --------------------------------------------------------

CREATE TABLE roles (
    id_role INT AUTO_INCREMENT PRIMARY KEY,
    nama_role VARCHAR(20) NOT NULL UNIQUE -- 'Admin', 'Kasir', 'Pelanggan'
);

INSERT INTO roles (nama_role) VALUES ('Admin'), ('Kasir'), ('Pelanggan');

CREATE TABLE users (
    id_user INT AUTO_INCREMENT PRIMARY KEY,
    id_role INT NOT NULL,
    nama_lengkap VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NULL,
    nomor_telepon VARCHAR(15) NULL,
    password VARCHAR(255) NULL, -- Nullable untuk pelanggan anonim/QR
    saldo_coin INT DEFAULT 0, -- Fitur loyalitas pelanggan berbasis coin
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_role) REFERENCES roles(id_role) ON DELETE CASCADE
);

-- --------------------------------------------------------
-- 2. ENTITAS MASTER DATA MENU & VARIAN
-- --------------------------------------------------------

CREATE TABLE categories (
    id_kategori INT AUTO_INCREMENT PRIMARY KEY,
    nama_kategori VARCHAR(50) NOT NULL,
    deskripsi TEXT NULL
);

CREATE TABLE menus (
    id_menu INT AUTO_INCREMENT PRIMARY KEY,
    id_kategori INT NOT NULL,
    nama_menu VARCHAR(100) NOT NULL,
    deskripsi TEXT NULL,
    harga_dasar DECIMAL(10,2) NOT NULL,
    gambar VARCHAR(255) NULL,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_kategori) REFERENCES categories(id_kategori) ON DELETE CASCADE
);

CREATE TABLE menu_variants (
    id_varian INT AUTO_INCREMENT PRIMARY KEY,
    id_menu INT NOT NULL,
    nama_varian VARCHAR(50) NOT NULL, -- Contoh: Hot/Ice, Less Sugar, Extra Shot, Size L
    tambahan_harga DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (id_menu) REFERENCES menus(id_menu) ON DELETE CASCADE
);

-- --------------------------------------------------------
-- 3. ENTITAS PENGATURAN OPERASIONAL (ADMIN)
-- --------------------------------------------------------

CREATE TABLE operating_hours (
    id_jam_operasional INT AUTO_INCREMENT PRIMARY KEY,
    hari ENUM('Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu') NOT NULL,
    jam_buka TIME NOT NULL,
    jam_tutup TIME NOT NULL,
    is_open BOOLEAN DEFAULT TRUE
);

-- --------------------------------------------------------
-- 4. ENTITAS PEMESANAN & TRANSAKSI (ORDERS & DETAILS)
-- --------------------------------------------------------

CREATE TABLE orders (
    id_pesanan INT AUTO_INCREMENT PRIMARY KEY,
    kode_transaksi VARCHAR(50) NOT NULL UNIQUE,
    id_user_pelanggan INT NULL, -- NULL jika pelanggan tidak login/anonim
    id_user_kasir INT NULL, -- NULL jika dipesan mandiri via QR
    nomor_meja VARCHAR(10) NULL,
    jenis_pesanan ENUM('Dine-In', 'Takeaway') NOT NULL DEFAULT 'Dine-In',
    status_pesanan ENUM('Menunggu Konfirmasi', 'Diproses', 'Selesai', 'Ditolak') DEFAULT 'Menunggu Konfirmasi',
    total_harga DECIMAL(10,2) NOT NULL,
    potongan_coin DECIMAL(10,2) DEFAULT 0.00, -- Penukaran koin potongan harga
    total_bayar DECIMAL(10,2) NOT NULL,
    coin_diperoleh INT DEFAULT 0,
    catatan_pesanan TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_user_pelanggan) REFERENCES users(id_user) ON DELETE SET NULL,
    FOREIGN KEY (id_user_kasir) REFERENCES users(id_user) ON DELETE SET NULL
);

CREATE TABLE order_details (
    id_detail_pesanan INT AUTO_INCREMENT PRIMARY KEY,
    id_pesanan INT NOT NULL,
    id_menu INT NOT NULL,
    id_varian INT NULL,
    jumlah INT NOT NULL,
    harga_satuan DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_pesanan) REFERENCES orders(id_pesanan) ON DELETE CASCADE,
    FOREIGN KEY (id_menu) REFERENCES menus(id_menu) ON DELETE CASCADE,
    FOREIGN KEY (id_varian) REFERENCES menu_variants(id_varian) ON DELETE SET NULL
);

-- --------------------------------------------------------
-- 5. ENTITAS PEMBAYARAN & INTEGRASI NON-TUNAI
-- --------------------------------------------------------

CREATE TABLE payment_methods (
    id_metode INT AUTO_INCREMENT PRIMARY KEY,
    nama_metode VARCHAR(50) NOT NULL, -- Contoh: 'Tunai', 'QRIS', 'Transfer Bank', 'E-Wallet'
    is_active BOOLEAN DEFAULT TRUE
);

INSERT INTO payment_methods (nama_metode) VALUES ('Tunai'), ('QRIS'), ('Transfer Bank');

CREATE TABLE payments (
    id_pembayaran INT AUTO_INCREMENT PRIMARY KEY,
    id_pesanan INT NOT NULL UNIQUE,
    id_metode INT NOT NULL,
    status_pembayaran ENUM('Pending', 'Lunas', 'Gagal') DEFAULT 'Pending',
    jumlah_bayar DECIMAL(10,2) NOT NULL,
    kembalian DECIMAL(10,2) DEFAULT 0.00,
    bukti_pembayaran VARCHAR(255) NULL, -- URL/Gambar bukti pembayaran non-tunai
    waktu_pembayaran TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pesanan) REFERENCES orders(id_pesanan) ON DELETE CASCADE,
    FOREIGN KEY (id_metode) REFERENCES payment_methods(id_metode) ON DELETE CASCADE
);

-- --------------------------------------------------------
-- 6. ENTITAS RIWAYAT TRANSVER KOIN (LOYALITAS)
-- --------------------------------------------------------

CREATE TABLE coin_logs (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_user INT NOT NULL,
    id_pesanan INT NULL,
    jumlah_coin INT NOT NULL,
    jenis_transaksi ENUM('In', 'Out') NOT NULL, -- 'In' saat dapat koin, 'Out' saat tukar diskon
    keterangan VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE,
    FOREIGN KEY (id_pesanan) REFERENCES orders(id_pesanan) ON DELETE SET NULL
);