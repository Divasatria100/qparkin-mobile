-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 25 Sep 2025 pada 18.52
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `qparkin`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `admin_mall`
--

CREATE TABLE `admin_mall` (
  `id_user` bigint(20) UNSIGNED NOT NULL,
  `id_mall` bigint(20) UNSIGNED DEFAULT NULL,
  `hak_akses` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `booking`
--

CREATE TABLE `booking` (
  `id_transaksi` bigint(20) UNSIGNED NOT NULL,
  `waktu_mulai` datetime DEFAULT NULL,
  `waktu_selesai` datetime DEFAULT NULL,
  `durasi_booking` int(11) DEFAULT NULL,
  `status` enum('aktif','selesai','expired') NOT NULL DEFAULT 'aktif',
  `dibooking_pada` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Trigger `booking`
--
DELIMITER $$
CREATE TRIGGER `trg_booking_after_insert` AFTER INSERT ON `booking` FOR EACH ROW BEGIN
                UPDATE Parkiran 
                SET kapasitas = kapasitas - 1
                WHERE id_parkiran = (
                    SELECT id_parkiran FROM Transaksi_Parkir WHERE id_transaksi = NEW.id_transaksi
                );
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_booking_after_update` AFTER UPDATE ON `booking` FOR EACH ROW BEGIN
                IF OLD.status = 'aktif' AND (NEW.status = 'selesai' OR NEW.status='expired') THEN
                    UPDATE Parkiran 
                    SET kapasitas = kapasitas + 1
                    WHERE id_parkiran = (
                        SELECT id_parkiran FROM Transaksi_Parkir WHERE id_transaksi = NEW.id_transaksi
                    );
                END IF;
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_booking_after_update_expired_poin` AFTER UPDATE ON `booking` FOR EACH ROW BEGIN
                IF NEW.status = 'expired' AND OLD.status <> 'expired' THEN
                    IF EXISTS (
                        SELECT 1 FROM pembayaran 
                        WHERE id_transaksi = NEW.id_transaksi 
                          AND metode = 'poin' 
                          AND status = 'berhasil'
                    ) THEN
                        SET @id_user := (SELECT id_user FROM transaksi_parkir WHERE id_transaksi = NEW.id_transaksi);
                        SET @nominal := (SELECT nominal FROM pembayaran WHERE id_transaksi = NEW.id_transaksi AND status = 'berhasil' LIMIT 1);
                        SET @poin_dipotong := FLOOR(@nominal / 10);

                        INSERT INTO riwayat_poin (id_user, id_transaksi, poin, perubahan, keterangan, waktu)
                        VALUES (@id_user, NEW.id_transaksi, @poin_dipotong, 'kurang', 'Pembayaran penalty booking dengan poin', NOW());
                    END IF;
                END IF;
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_booking_after_update_notif` AFTER UPDATE ON `booking` FOR EACH ROW BEGIN
                IF NEW.status = 'expired' AND OLD.status <> 'expired' THEN
                    SET @id_user := (SELECT id_user FROM transaksi_parkir WHERE id_transaksi = NEW.id_transaksi);
                    INSERT INTO notifikasi (id_user, pesan, waktu_kirim, status)
                    VALUES (@id_user, CONCAT('Booking #', NEW.id_transaksi, ' sudah expired.'), NOW(), 'belum');
                END IF;
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_booking_after_update_penalty` AFTER UPDATE ON `booking` FOR EACH ROW BEGIN
                IF NEW.status = 'expired' AND OLD.status <> 'expired' THEN
                    SET @jenis_kendaraan := (
                        SELECT jenis FROM kendaraan K
                        JOIN transaksi_parkir T ON K.id_kendaraan = T.id_kendaraan
                        WHERE T.id_transaksi = NEW.id_transaksi LIMIT 1
                    );

                    SET @tarif_perjam := (
                        SELECT tarif_parkir_per_jam
                        FROM tarif_parkir
                        WHERE id_mall = (SELECT id_mall FROM transaksi_parkir WHERE id_transaksi = NEW.id_transaksi)
                          AND jenis_kendaraan = @jenis_kendaraan
                        LIMIT 1
                    );

                    UPDATE transaksi_parkir
                    SET penalty = penalty + @tarif_perjam
                    WHERE id_transaksi = NEW.id_transaksi;
                END IF;
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_booking_before_insert` BEFORE INSERT ON `booking` FOR EACH ROW BEGIN
                SET @kapasitas := (
                    SELECT kapasitas FROM Parkiran P 
                    JOIN Transaksi_Parkir T ON P.id_parkiran = T.id_parkiran 
                    WHERE T.id_transaksi = NEW.id_transaksi
                );
                IF @kapasitas <= 0 THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tidak ada slot tersedia untuk booking ini';
                END IF;
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_booking_before_insert_unique` BEFORE INSERT ON `booking` FOR EACH ROW BEGIN
                IF EXISTS (
                    SELECT 1
                    FROM booking B
                    JOIN transaksi_parkir T ON B.id_transaksi = T.id_transaksi
                    WHERE T.id_kendaraan = (SELECT id_kendaraan FROM transaksi_parkir WHERE id_transaksi = NEW.id_transaksi LIMIT 1)
                      AND B.status = 'aktif'
                ) THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Kendaraan ini sudah memiliki booking aktif.';
                END IF;
            END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `customer`
--

CREATE TABLE `customer` (
  `id_user` bigint(20) UNSIGNED NOT NULL,
  `no_hp` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `gerbang`
--

CREATE TABLE `gerbang` (
  `id_gerbang` bigint(20) UNSIGNED NOT NULL,
  `id_mall` bigint(20) UNSIGNED NOT NULL,
  `nama_gerbang` varchar(255) NOT NULL,
  `lokasi` varchar(255) DEFAULT NULL,
  `dibuat_pada` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `kendaraan`
--

CREATE TABLE `kendaraan` (
  `id_kendaraan` bigint(20) UNSIGNED NOT NULL,
  `id_user` bigint(20) UNSIGNED DEFAULT NULL,
  `plat` varchar(20) DEFAULT NULL,
  `jenis` enum('Roda Dua','Roda Tiga','Roda Empat','Lebih dari Enam') DEFAULT NULL,
  `merk` varchar(50) DEFAULT NULL,
  `tipe` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Trigger `kendaraan`
--
DELIMITER $$
CREATE TRIGGER `trg_kendaraan_after_delete` AFTER DELETE ON `kendaraan` FOR EACH ROW BEGIN
                INSERT INTO Notifikasi (id_user, pesan, waktu_kirim)
                VALUES (OLD.id_user, CONCAT('Kendaraan dengan plat ', OLD.plat, ' dihapus.'), NOW());
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_kendaraan_after_insert` AFTER INSERT ON `kendaraan` FOR EACH ROW BEGIN
                INSERT INTO Notifikasi (id_user, pesan, waktu_kirim)
                VALUES (NEW.id_user, CONCAT('Kendaraan dengan plat ', NEW.plat, ' berhasil ditambahkan.'), NOW());
            END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `mall`
--

CREATE TABLE `mall` (
  `id_mall` bigint(20) UNSIGNED NOT NULL,
  `nama_mall` varchar(100) DEFAULT NULL,
  `lokasi` varchar(255) DEFAULT NULL,
  `kapasitas` int(11) DEFAULT NULL,
  `alamat_gmaps` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Trigger `mall`
--
DELIMITER $$
CREATE TRIGGER `trg_mall_after_delete` AFTER DELETE ON `mall` FOR EACH ROW BEGIN
                DELETE FROM Parkiran WHERE id_mall = OLD.id_mall;
                DELETE FROM Tarif_Parkir WHERE id_mall = OLD.id_mall;
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_mall_after_insert` AFTER INSERT ON `mall` FOR EACH ROW BEGIN
                INSERT INTO Notifikasi (id_user, pesan, waktu_kirim)
                SELECT id_user, CONCAT('Mall baru ditambahkan: ', NEW.nama_mall), NOW()
                FROM Super_Admin;
            END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2025_09_24_145803_create_personal_access_tokens_table', 1),
(5, '2025_09_24_145843_create_oauth_auth_codes_table', 1),
(6, '2025_09_24_145844_create_oauth_access_tokens_table', 1),
(7, '2025_09_24_145845_create_oauth_refresh_tokens_table', 1),
(8, '2025_09_24_145846_create_oauth_clients_table', 1),
(9, '2025_09_24_145847_create_oauth_device_codes_table', 1),
(10, '2025_09_24_151026_mall', 1),
(11, '2025_09_24_151056_admin_mall', 1),
(12, '2025_09_24_151122_super_admin', 1),
(13, '2025_09_24_151620_customer', 1),
(14, '2025_09_24_151624_kendaraan', 1),
(15, '2025_09_24_151629_tarif_parkir', 1),
(16, '2025_09_24_151634_parkiran', 1),
(17, '2025_09_24_151640_gerbang', 1),
(18, '2025_09_24_151644_transaksi_parkir', 1),
(19, '2025_09_24_151647_booking', 1),
(20, '2025_09_24_151653_pembayaran', 1),
(21, '2025_09_24_151659_riwayat_poin', 1),
(22, '2025_09_24_151708_notifikasi', 1),
(23, '2025_09_24_151714_riwayat_gerbang', 1),
(24, '2025_09_24_151948_triggers', 1);

-- --------------------------------------------------------

--
-- Struktur dari tabel `notifikasi`
--

CREATE TABLE `notifikasi` (
  `id_notifikasi` bigint(20) UNSIGNED NOT NULL,
  `id_user` bigint(20) UNSIGNED DEFAULT NULL,
  `pesan` text DEFAULT NULL,
  `waktu_kirim` datetime DEFAULT NULL,
  `status` enum('terbaca','belum') NOT NULL DEFAULT 'belum'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `notifikasi`
--

INSERT INTO `notifikasi` (`id_notifikasi`, `id_user`, `pesan`, `waktu_kirim`, `status`) VALUES
(1, 1, 'Selamat datang, qparkin! Akun Anda berhasil dibuat.', '2025-09-25 13:09:26', 'belum');

-- --------------------------------------------------------

--
-- Struktur dari tabel `oauth_access_tokens`
--

CREATE TABLE `oauth_access_tokens` (
  `id` char(80) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `client_id` char(36) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `scopes` text DEFAULT NULL,
  `revoked` tinyint(1) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `oauth_auth_codes`
--

CREATE TABLE `oauth_auth_codes` (
  `id` char(80) NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `client_id` char(36) NOT NULL,
  `scopes` text DEFAULT NULL,
  `revoked` tinyint(1) NOT NULL,
  `expires_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `oauth_clients`
--

CREATE TABLE `oauth_clients` (
  `id` char(36) NOT NULL,
  `owner_type` varchar(255) DEFAULT NULL,
  `owner_id` bigint(20) UNSIGNED DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `secret` varchar(255) DEFAULT NULL,
  `provider` varchar(255) DEFAULT NULL,
  `redirect_uris` text NOT NULL,
  `grant_types` text NOT NULL,
  `revoked` tinyint(1) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `oauth_device_codes`
--

CREATE TABLE `oauth_device_codes` (
  `id` char(80) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `client_id` char(36) NOT NULL,
  `user_code` char(8) NOT NULL,
  `scopes` text NOT NULL,
  `revoked` tinyint(1) NOT NULL,
  `user_approved_at` datetime DEFAULT NULL,
  `last_polled_at` datetime DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `oauth_refresh_tokens`
--

CREATE TABLE `oauth_refresh_tokens` (
  `id` char(80) NOT NULL,
  `access_token_id` char(80) NOT NULL,
  `revoked` tinyint(1) NOT NULL,
  `expires_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `parkiran`
--

CREATE TABLE `parkiran` (
  `id_parkiran` bigint(20) UNSIGNED NOT NULL,
  `id_mall` bigint(20) UNSIGNED DEFAULT NULL,
  `jenis_kendaraan` enum('Roda Dua','Roda Tiga','Roda Empat','Lebih dari Enam') DEFAULT NULL,
  `kapasitas` int(11) DEFAULT NULL,
  `status` enum('Tersedia','Ditutup') NOT NULL DEFAULT 'Tersedia'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Trigger `parkiran`
--
DELIMITER $$
CREATE TRIGGER `trg_parkiran_after_update` AFTER UPDATE ON `parkiran` FOR EACH ROW BEGIN
                IF OLD.status = 'Tersedia' AND NEW.status = 'Ditutup' THEN
                    INSERT INTO Notifikasi (id_user, pesan, waktu_kirim)
                    SELECT U.id_user, CONCAT('Parkiran di mall ', M.nama_mall, ' ditutup'), NOW()
                    FROM Admin_Mall AM
                    JOIN User U ON AM.id_user = U.id_user
                    JOIN Mall M ON AM.id_mall = M.id_mall
                    WHERE AM.id_mall = NEW.id_mall;
                END IF;
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_parkiran_after_update_full_notify` AFTER UPDATE ON `parkiran` FOR EACH ROW BEGIN
                IF NEW.kapasitas = 0 AND OLD.kapasitas > 0 THEN
                    INSERT INTO notifikasi (id_user, pesan, waktu_kirim, status)
                    SELECT AM.id_user,
                           CONCAT('Parkiran di mall ', M.nama_mall, ' sudah penuh.'),
                           NOW(), 'belum'
                    FROM admin_mall AM
                    JOIN mall M ON M.id_mall = NEW.id_mall;
                END IF;
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_parkiran_before_insert` BEFORE INSERT ON `parkiran` FOR EACH ROW BEGIN
                IF NEW.kapasitas < 0 THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Kapasitas parkiran tidak boleh negatif';
                END IF;
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_parkiran_before_update` BEFORE UPDATE ON `parkiran` FOR EACH ROW BEGIN
                SET @kapasitas_mall := (SELECT kapasitas FROM mall WHERE id_mall = NEW.id_mall);
                IF NEW.kapasitas > @kapasitas_mall THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Kapasitas parkiran melebihi kapasitas mall';
                END IF;
            END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `pembayaran`
--

CREATE TABLE `pembayaran` (
  `id_pembayaran` bigint(20) UNSIGNED NOT NULL,
  `id_transaksi` bigint(20) UNSIGNED DEFAULT NULL,
  `id_gerbang` bigint(20) UNSIGNED NOT NULL,
  `metode` enum('qris','tapcash','poin') DEFAULT NULL,
  `nominal` decimal(10,2) DEFAULT NULL,
  `status` enum('pending','berhasil','gagal') NOT NULL DEFAULT 'pending',
  `waktu_bayar` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Trigger `pembayaran`
--
DELIMITER $$
CREATE TRIGGER `trg_booking_pembayaran_after_update_poin_bonus` AFTER UPDATE ON `pembayaran` FOR EACH ROW BEGIN
                IF NEW.status = 'berhasil' AND OLD.status <> 'berhasil' 
                   AND NEW.metode <> 'poin'
                   AND EXISTS (SELECT 1 FROM booking WHERE id_transaksi = NEW.id_transaksi) THEN

                    SET @id_user := (SELECT id_user FROM transaksi_parkir WHERE id_transaksi = NEW.id_transaksi);
                    SET @poin := FLOOR(NEW.nominal / 1000) * 10;

                    INSERT INTO riwayat_poin (id_user, id_transaksi, poin, perubahan, keterangan, waktu)
                    VALUES (@id_user, NEW.id_transaksi, @poin, 'tambah', 'Bonus poin dari pembayaran booking', NOW());
                END IF;
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_pembayaran_after_update` AFTER UPDATE ON `pembayaran` FOR EACH ROW BEGIN
                IF NEW.status = 'berhasil' AND OLD.status <> 'berhasil' AND NEW.metode <> 'poin' THEN
                    SET @user_id := (SELECT id_user FROM transaksi_parkir WHERE id_transaksi = NEW.id_transaksi);
                    SET @poin := FLOOR(NEW.nominal / 1000) * 10;

                    INSERT INTO riwayat_poin (id_user, id_transaksi, poin, perubahan, keterangan, waktu)
                    VALUES (@user_id, NEW.id_transaksi, @poin, 'tambah', 'Bonus poin dari pembayaran parkir', NOW());

                    INSERT INTO notifikasi (id_user, pesan, waktu_kirim, status)
                    VALUES (@user_id, CONCAT('Pembayaran berhasil untuk transaksi ', NEW.id_transaksi, '. Nominal: Rp', NEW.nominal), NOW(), 'belum');
                END IF;
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_pembayaran_after_update_double_poin` AFTER UPDATE ON `pembayaran` FOR EACH ROW BEGIN
                IF NEW.status = 'berhasil' AND OLD.status <> 'berhasil'
                   AND NEW.metode <> 'poin'
                   AND DAYOFWEEK(NOW()) IN (1,7) THEN
                    SET @id_user := (SELECT id_user FROM transaksi_parkir WHERE id_transaksi = NEW.id_transaksi);
                    SET @extra_poin := FLOOR(NEW.nominal / 1000) * 10;

                    INSERT INTO riwayat_poin (id_user, id_transaksi, poin, perubahan, keterangan, waktu)
                    VALUES (@id_user, NEW.id_transaksi, @extra_poin, 'tambah', 'Promo Double Poin Weekend', NOW());
                END IF;
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_pembayaran_after_update_notif` AFTER UPDATE ON `pembayaran` FOR EACH ROW BEGIN
                IF NEW.status = 'gagal' AND OLD.status <> 'gagal' THEN
                    SET @id_user := (SELECT id_user FROM transaksi_parkir WHERE id_transaksi = NEW.id_transaksi);
                    INSERT INTO notifikasi (id_user, pesan, waktu_kirim, status)
                    VALUES (@id_user, CONCAT('Pembayaran transaksi #', NEW.id_transaksi, ' gagal. Silakan coba lagi.'), NOW(), 'belum');
                END IF;
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_pembayaran_after_update_poin` AFTER UPDATE ON `pembayaran` FOR EACH ROW BEGIN
                IF NEW.status = 'berhasil' AND OLD.status <> 'berhasil' AND NEW.metode = 'poin' THEN
                    SET @id_user := (SELECT id_user FROM transaksi_parkir WHERE id_transaksi = NEW.id_transaksi);
                    SET @poin_dipotong := FLOOR(NEW.nominal / 10);

                    INSERT INTO riwayat_poin (id_user, id_transaksi, poin, perubahan, keterangan, waktu)
                    VALUES (@id_user, NEW.id_transaksi, @poin_dipotong, 'kurang', 'Penukaran biaya parkir dengan poin', NOW());
                END IF;
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_pembayaran_before_insert` BEFORE INSERT ON `pembayaran` FOR EACH ROW BEGIN
                IF NEW.nominal <= 0 THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nominal pembayaran harus lebih besar dari 0';
                END IF;

                IF NEW.metode = 'poin' THEN
                    SET @id_user := (SELECT id_user FROM transaksi_parkir WHERE id_transaksi = NEW.id_transaksi);
                    SET @saldo := (SELECT saldo_poin FROM user WHERE id_user = @id_user);
                    IF @saldo < NEW.nominal THEN
                        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo poin tidak mencukupi untuk pembayaran ini';
                    END IF;
                END IF;
            END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` text NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `riwayat_gerbang`
--

CREATE TABLE `riwayat_gerbang` (
  `id_riwayat_gerbang` bigint(20) UNSIGNED NOT NULL,
  `id_gerbang` bigint(20) UNSIGNED NOT NULL,
  `aksi` enum('terbuka','tertutup') NOT NULL DEFAULT 'tertutup',
  `status_sebelum` enum('terbuka','tertutup') NOT NULL DEFAULT 'tertutup',
  `status_sesudah` enum('terbuka','tertutup') NOT NULL DEFAULT 'tertutup',
  `dibuat_pada` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Trigger `riwayat_gerbang`
--
DELIMITER $$
CREATE TRIGGER `trg_riwayatgerbang_after_insert` AFTER INSERT ON `riwayat_gerbang` FOR EACH ROW BEGIN
                SET @id_mall := (SELECT id_mall FROM gerbang WHERE id_gerbang = NEW.id_gerbang);
                INSERT INTO notifikasi (id_user, pesan, waktu_kirim, status)
                SELECT AM.id_user,
                       CONCAT('Gerbang ', G.nama_gerbang, ' mall #', @id_mall, ' berubah menjadi ', NEW.status_sesudah),
                       NOW(), 'belum'
                FROM admin_mall AM
                JOIN gerbang G ON G.id_gerbang = NEW.id_gerbang
                WHERE AM.id_mall = @id_mall;
            END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `riwayat_poin`
--

CREATE TABLE `riwayat_poin` (
  `id_poin` bigint(20) UNSIGNED NOT NULL,
  `id_user` bigint(20) UNSIGNED DEFAULT NULL,
  `id_transaksi` bigint(20) UNSIGNED DEFAULT NULL,
  `poin` int(11) NOT NULL,
  `perubahan` enum('tambah','kurang') DEFAULT NULL,
  `keterangan` varchar(255) DEFAULT NULL,
  `waktu` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Trigger `riwayat_poin`
--
DELIMITER $$
CREATE TRIGGER `trg_riwayatpoin_after_insert` AFTER INSERT ON `riwayat_poin` FOR EACH ROW BEGIN
                IF NEW.perubahan = 'tambah' THEN
                    UPDATE user SET saldo_poin = saldo_poin + NEW.poin WHERE id_user = NEW.id_user;
                ELSEIF NEW.perubahan = 'kurang' THEN
                    UPDATE user SET saldo_poin = saldo_poin - NEW.poin WHERE id_user = NEW.id_user;
                END IF;
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_riwayatpoin_after_insert_notif` AFTER INSERT ON `riwayat_poin` FOR EACH ROW BEGIN
                DECLARE vPesan TEXT;
                IF NEW.perubahan = 'tambah' THEN
                    SET vPesan = CONCAT('Anda mendapat tambahan poin: ', NEW.poin, ' (', NEW.keterangan, ')');
                ELSEIF NEW.perubahan = 'kurang' THEN
                    SET vPesan = CONCAT('Poin Anda berkurang: ', NEW.poin, ' (', NEW.keterangan, ')');
                END IF;
                INSERT INTO notifikasi (id_user, pesan, waktu_kirim, status)
                VALUES (NEW.id_user, vPesan, NOW(), 'belum');
            END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `super_admin`
--

CREATE TABLE `super_admin` (
  `id_user` bigint(20) UNSIGNED NOT NULL,
  `hak_akses` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `super_admin`
--

INSERT INTO `super_admin` (`id_user`, `hak_akses`) VALUES
(1, 'developer');

-- --------------------------------------------------------

--
-- Struktur dari tabel `tarif_parkir`
--

CREATE TABLE `tarif_parkir` (
  `id_tarif` bigint(20) UNSIGNED NOT NULL,
  `id_mall` bigint(20) UNSIGNED DEFAULT NULL,
  `jenis_kendaraan` enum('Roda Dua','Roda Tiga','Roda Empat','Lebih dari Enam') DEFAULT NULL,
  `satu_jam_pertama` decimal(10,2) DEFAULT NULL,
  `tarif_parkir_per_jam` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Trigger `tarif_parkir`
--
DELIMITER $$
CREATE TRIGGER `trg_tarif_after_update_notify` AFTER UPDATE ON `tarif_parkir` FOR EACH ROW BEGIN
                IF OLD.satu_jam_pertama <> NEW.satu_jam_pertama 
                   OR OLD.tarif_parkir_per_jam <> NEW.tarif_parkir_per_jam THEN
                    INSERT INTO notifikasi (id_user, pesan, waktu_kirim, status)
                    SELECT AM.id_user,
                           CONCAT('Tarif parkir mall #', NEW.id_mall, ' untuk kendaraan ', NEW.jenis_kendaraan, ' diperbarui.'),
                           NOW(), 'belum'
                    FROM admin_mall AM
                    WHERE AM.id_mall = NEW.id_mall;
                END IF;
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_tarif_before_insert` BEFORE INSERT ON `tarif_parkir` FOR EACH ROW BEGIN
                IF EXISTS (
                    SELECT 1 FROM tarif_parkir
                    WHERE id_mall = NEW.id_mall AND jenis_kendaraan = NEW.jenis_kendaraan
                ) THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tarif untuk jenis kendaraan ini sudah ada di mall terkait';
                END IF;

                IF NEW.satu_jam_pertama < 0 OR NEW.tarif_parkir_per_jam < 0 THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tarif tidak boleh bernilai negatif';
                END IF;
            END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `transaksi_parkir`
--

CREATE TABLE `transaksi_parkir` (
  `id_transaksi` bigint(20) UNSIGNED NOT NULL,
  `id_user` bigint(20) UNSIGNED DEFAULT NULL,
  `id_kendaraan` bigint(20) UNSIGNED DEFAULT NULL,
  `id_mall` bigint(20) UNSIGNED DEFAULT NULL,
  `id_parkiran` bigint(20) UNSIGNED DEFAULT NULL,
  `jenis_transaksi` enum('umum','booking') DEFAULT NULL,
  `waktu_masuk` datetime DEFAULT NULL,
  `waktu_keluar` datetime DEFAULT NULL,
  `durasi` int(11) DEFAULT NULL,
  `biaya` decimal(10,2) DEFAULT NULL,
  `penalty` decimal(10,2) NOT NULL DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Trigger `transaksi_parkir`
--
DELIMITER $$
CREATE TRIGGER `trg_transaksi_after_insert` AFTER INSERT ON `transaksi_parkir` FOR EACH ROW BEGIN
                UPDATE Parkiran SET kapasitas = kapasitas - 1 WHERE id_parkiran = NEW.id_parkiran;
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_transaksi_after_insert_gerbang` AFTER INSERT ON `transaksi_parkir` FOR EACH ROW BEGIN
                DECLARE v_id_gerbang INT;
                SET v_id_gerbang := (SELECT id_gerbang FROM pembayaran WHERE id_transaksi = NEW.id_transaksi LIMIT 1);
                IF v_id_gerbang IS NOT NULL THEN
                    INSERT INTO riwayat_gerbang (id_gerbang, aksi, status_sebelum, status_sesudah)
                    VALUES (v_id_gerbang, 'terbuka', 'tertutup', 'terbuka');
                END IF;
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_transaksi_after_update` AFTER UPDATE ON `transaksi_parkir` FOR EACH ROW BEGIN
                IF NEW.waktu_keluar IS NOT NULL AND OLD.waktu_keluar IS NULL THEN
                    SET @durasi := TIMESTAMPDIFF(HOUR, NEW.waktu_masuk, NEW.waktu_keluar);
                    UPDATE transaksi_parkir SET durasi = @durasi WHERE id_transaksi = NEW.id_transaksi;

                    SET @jenis_kendaraan := (SELECT jenis FROM kendaraan WHERE id_kendaraan = NEW.id_kendaraan LIMIT 1);
                    SET @tarif_awal := (SELECT satu_jam_pertama FROM tarif_parkir WHERE id_mall = NEW.id_mall AND jenis_kendaraan = @jenis_kendaraan LIMIT 1);
                    SET @tarif_perjam := (SELECT tarif_parkir_per_jam FROM tarif_parkir WHERE id_mall = NEW.id_mall AND jenis_kendaraan = @jenis_kendaraan LIMIT 1);

                    IF @durasi <= 1 THEN
                        SET @biaya := @tarif_awal;
                    ELSE
                        SET @biaya := @tarif_awal + (@durasi - 1) * @tarif_perjam;
                    END IF;

                    UPDATE transaksi_parkir SET biaya = @biaya WHERE id_transaksi = NEW.id_transaksi;
                    UPDATE parkiran SET kapasitas = kapasitas + 1 WHERE id_parkiran = NEW.id_parkiran;
                END IF;
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_transaksi_after_update_notif` AFTER UPDATE ON `transaksi_parkir` FOR EACH ROW BEGIN
                IF NEW.waktu_keluar IS NOT NULL AND OLD.waktu_keluar IS NULL THEN
                    INSERT INTO notifikasi (id_user, pesan, waktu_kirim, status)
                    VALUES (
                        NEW.id_user,
                        CONCAT('Transaksi parkir #', NEW.id_transaksi, ' selesai. Total biaya: Rp', NEW.biaya),
                        NOW(), 'belum'
                    );
                END IF;
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_transaksi_before_insert_unique` BEFORE INSERT ON `transaksi_parkir` FOR EACH ROW BEGIN
                IF EXISTS (
                    SELECT 1 FROM transaksi_parkir
                    WHERE id_kendaraan = NEW.id_kendaraan AND waktu_keluar IS NULL
                ) THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Kendaraan ini masih memiliki transaksi aktif';
                END IF;
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_transaksi_before_update_keluar` BEFORE UPDATE ON `transaksi_parkir` FOR EACH ROW BEGIN
                IF NEW.waktu_keluar IS NOT NULL AND OLD.waktu_keluar IS NULL THEN
                    IF NOT EXISTS (
                        SELECT 1 FROM pembayaran WHERE id_transaksi = NEW.id_transaksi AND status = 'berhasil'
                    ) THEN
                        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tidak bisa keluar sebelum pembayaran berhasil';
                    END IF;
                END IF;
            END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `user`
--

CREATE TABLE `user` (
  `id_user` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `no_hp` varchar(20) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `provider` varchar(255) DEFAULT NULL,
  `provider_id` varchar(255) DEFAULT NULL,
  `role` enum('customer','admin_mall','super_admin') NOT NULL DEFAULT 'customer',
  `saldo_poin` int(11) NOT NULL DEFAULT 0,
  `status` enum('aktif','non-aktif') NOT NULL DEFAULT 'aktif',
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `user`
--

INSERT INTO `user` (`id_user`, `name`, `no_hp`, `email`, `email_verified_at`, `password`, `provider`, `provider_id`, `role`, `saldo_poin`, `status`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'qparkin', NULL, NULL, NULL, '$2y$10$O.DkqvyLWbPzWpWQTWKko./hjUib7gdCHntOfEy4JvzuFppXcuQYu', NULL, NULL, 'super_admin', 999999, 'aktif', NULL, '2025-09-24 23:09:26', '2025-09-24 23:09:26');

--
-- Trigger `user`
--
DELIMITER $$
CREATE TRIGGER `trg_user_after_insert` AFTER INSERT ON `user` FOR EACH ROW BEGIN
                INSERT INTO notifikasi (id_user, pesan, waktu_kirim, status)
                VALUES (NEW.id_user, CONCAT('Selamat datang, ', NEW.name, '! Akun Anda berhasil dibuat.'), NOW(), 'belum');
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_user_before_update` BEFORE UPDATE ON `user` FOR EACH ROW BEGIN
                IF NEW.saldo_poin < 0 THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo poin tidak boleh negatif';
                END IF;
            END
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `admin_mall`
--
ALTER TABLE `admin_mall`
  ADD PRIMARY KEY (`id_user`),
  ADD KEY `admin_mall_id_mall_foreign` (`id_mall`);

--
-- Indeks untuk tabel `booking`
--
ALTER TABLE `booking`
  ADD PRIMARY KEY (`id_transaksi`);

--
-- Indeks untuk tabel `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`);

--
-- Indeks untuk tabel `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`);

--
-- Indeks untuk tabel `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`id_user`);

--
-- Indeks untuk tabel `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indeks untuk tabel `gerbang`
--
ALTER TABLE `gerbang`
  ADD PRIMARY KEY (`id_gerbang`),
  ADD KEY `gerbang_id_mall_foreign` (`id_mall`);

--
-- Indeks untuk tabel `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indeks untuk tabel `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `kendaraan`
--
ALTER TABLE `kendaraan`
  ADD PRIMARY KEY (`id_kendaraan`),
  ADD UNIQUE KEY `kendaraan_plat_unique` (`plat`),
  ADD KEY `kendaraan_id_user_foreign` (`id_user`);

--
-- Indeks untuk tabel `mall`
--
ALTER TABLE `mall`
  ADD PRIMARY KEY (`id_mall`);

--
-- Indeks untuk tabel `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `notifikasi`
--
ALTER TABLE `notifikasi`
  ADD PRIMARY KEY (`id_notifikasi`),
  ADD KEY `notifikasi_id_user_foreign` (`id_user`);

--
-- Indeks untuk tabel `oauth_access_tokens`
--
ALTER TABLE `oauth_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD KEY `oauth_access_tokens_user_id_index` (`user_id`);

--
-- Indeks untuk tabel `oauth_auth_codes`
--
ALTER TABLE `oauth_auth_codes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `oauth_auth_codes_user_id_index` (`user_id`);

--
-- Indeks untuk tabel `oauth_clients`
--
ALTER TABLE `oauth_clients`
  ADD PRIMARY KEY (`id`),
  ADD KEY `oauth_clients_owner_type_owner_id_index` (`owner_type`,`owner_id`);

--
-- Indeks untuk tabel `oauth_device_codes`
--
ALTER TABLE `oauth_device_codes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `oauth_device_codes_user_code_unique` (`user_code`),
  ADD KEY `oauth_device_codes_user_id_index` (`user_id`),
  ADD KEY `oauth_device_codes_client_id_index` (`client_id`);

--
-- Indeks untuk tabel `oauth_refresh_tokens`
--
ALTER TABLE `oauth_refresh_tokens`
  ADD PRIMARY KEY (`id`),
  ADD KEY `oauth_refresh_tokens_access_token_id_index` (`access_token_id`);

--
-- Indeks untuk tabel `parkiran`
--
ALTER TABLE `parkiran`
  ADD PRIMARY KEY (`id_parkiran`),
  ADD KEY `parkiran_id_mall_foreign` (`id_mall`);

--
-- Indeks untuk tabel `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indeks untuk tabel `pembayaran`
--
ALTER TABLE `pembayaran`
  ADD PRIMARY KEY (`id_pembayaran`),
  ADD KEY `pembayaran_id_transaksi_foreign` (`id_transaksi`),
  ADD KEY `pembayaran_id_gerbang_foreign` (`id_gerbang`);

--
-- Indeks untuk tabel `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  ADD KEY `personal_access_tokens_expires_at_index` (`expires_at`);

--
-- Indeks untuk tabel `riwayat_gerbang`
--
ALTER TABLE `riwayat_gerbang`
  ADD PRIMARY KEY (`id_riwayat_gerbang`),
  ADD KEY `riwayat_gerbang_id_gerbang_foreign` (`id_gerbang`);

--
-- Indeks untuk tabel `riwayat_poin`
--
ALTER TABLE `riwayat_poin`
  ADD PRIMARY KEY (`id_poin`),
  ADD KEY `riwayat_poin_id_user_foreign` (`id_user`),
  ADD KEY `riwayat_poin_id_transaksi_foreign` (`id_transaksi`);

--
-- Indeks untuk tabel `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indeks untuk tabel `super_admin`
--
ALTER TABLE `super_admin`
  ADD PRIMARY KEY (`id_user`);

--
-- Indeks untuk tabel `tarif_parkir`
--
ALTER TABLE `tarif_parkir`
  ADD PRIMARY KEY (`id_tarif`),
  ADD KEY `tarif_parkir_id_mall_foreign` (`id_mall`);

--
-- Indeks untuk tabel `transaksi_parkir`
--
ALTER TABLE `transaksi_parkir`
  ADD PRIMARY KEY (`id_transaksi`),
  ADD KEY `transaksi_parkir_id_user_foreign` (`id_user`),
  ADD KEY `transaksi_parkir_id_kendaraan_foreign` (`id_kendaraan`),
  ADD KEY `transaksi_parkir_id_mall_foreign` (`id_mall`),
  ADD KEY `transaksi_parkir_id_parkiran_foreign` (`id_parkiran`);

--
-- Indeks untuk tabel `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id_user`),
  ADD UNIQUE KEY `user_no_hp_unique` (`no_hp`),
  ADD UNIQUE KEY `user_email_unique` (`email`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `gerbang`
--
ALTER TABLE `gerbang`
  MODIFY `id_gerbang` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `kendaraan`
--
ALTER TABLE `kendaraan`
  MODIFY `id_kendaraan` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `mall`
--
ALTER TABLE `mall`
  MODIFY `id_mall` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT untuk tabel `notifikasi`
--
ALTER TABLE `notifikasi`
  MODIFY `id_notifikasi` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `parkiran`
--
ALTER TABLE `parkiran`
  MODIFY `id_parkiran` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `pembayaran`
--
ALTER TABLE `pembayaran`
  MODIFY `id_pembayaran` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `riwayat_gerbang`
--
ALTER TABLE `riwayat_gerbang`
  MODIFY `id_riwayat_gerbang` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `riwayat_poin`
--
ALTER TABLE `riwayat_poin`
  MODIFY `id_poin` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `tarif_parkir`
--
ALTER TABLE `tarif_parkir`
  MODIFY `id_tarif` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `transaksi_parkir`
--
ALTER TABLE `transaksi_parkir`
  MODIFY `id_transaksi` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `user`
--
ALTER TABLE `user`
  MODIFY `id_user` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `admin_mall`
--
ALTER TABLE `admin_mall`
  ADD CONSTRAINT `admin_mall_id_mall_foreign` FOREIGN KEY (`id_mall`) REFERENCES `mall` (`id_mall`),
  ADD CONSTRAINT `admin_mall_id_user_foreign` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`);

--
-- Ketidakleluasaan untuk tabel `booking`
--
ALTER TABLE `booking`
  ADD CONSTRAINT `booking_id_transaksi_foreign` FOREIGN KEY (`id_transaksi`) REFERENCES `transaksi_parkir` (`id_transaksi`);

--
-- Ketidakleluasaan untuk tabel `customer`
--
ALTER TABLE `customer`
  ADD CONSTRAINT `customer_id_user_foreign` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`);

--
-- Ketidakleluasaan untuk tabel `gerbang`
--
ALTER TABLE `gerbang`
  ADD CONSTRAINT `gerbang_id_mall_foreign` FOREIGN KEY (`id_mall`) REFERENCES `mall` (`id_mall`);

--
-- Ketidakleluasaan untuk tabel `kendaraan`
--
ALTER TABLE `kendaraan`
  ADD CONSTRAINT `kendaraan_id_user_foreign` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`);

--
-- Ketidakleluasaan untuk tabel `notifikasi`
--
ALTER TABLE `notifikasi`
  ADD CONSTRAINT `notifikasi_id_user_foreign` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`);

--
-- Ketidakleluasaan untuk tabel `parkiran`
--
ALTER TABLE `parkiran`
  ADD CONSTRAINT `parkiran_id_mall_foreign` FOREIGN KEY (`id_mall`) REFERENCES `mall` (`id_mall`);

--
-- Ketidakleluasaan untuk tabel `pembayaran`
--
ALTER TABLE `pembayaran`
  ADD CONSTRAINT `pembayaran_id_gerbang_foreign` FOREIGN KEY (`id_gerbang`) REFERENCES `gerbang` (`id_gerbang`),
  ADD CONSTRAINT `pembayaran_id_transaksi_foreign` FOREIGN KEY (`id_transaksi`) REFERENCES `transaksi_parkir` (`id_transaksi`);

--
-- Ketidakleluasaan untuk tabel `riwayat_gerbang`
--
ALTER TABLE `riwayat_gerbang`
  ADD CONSTRAINT `riwayat_gerbang_id_gerbang_foreign` FOREIGN KEY (`id_gerbang`) REFERENCES `gerbang` (`id_gerbang`);

--
-- Ketidakleluasaan untuk tabel `riwayat_poin`
--
ALTER TABLE `riwayat_poin`
  ADD CONSTRAINT `riwayat_poin_id_transaksi_foreign` FOREIGN KEY (`id_transaksi`) REFERENCES `transaksi_parkir` (`id_transaksi`),
  ADD CONSTRAINT `riwayat_poin_id_user_foreign` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`);

--
-- Ketidakleluasaan untuk tabel `super_admin`
--
ALTER TABLE `super_admin`
  ADD CONSTRAINT `super_admin_id_user_foreign` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`);

--
-- Ketidakleluasaan untuk tabel `tarif_parkir`
--
ALTER TABLE `tarif_parkir`
  ADD CONSTRAINT `tarif_parkir_id_mall_foreign` FOREIGN KEY (`id_mall`) REFERENCES `mall` (`id_mall`);

--
-- Ketidakleluasaan untuk tabel `transaksi_parkir`
--
ALTER TABLE `transaksi_parkir`
  ADD CONSTRAINT `transaksi_parkir_id_kendaraan_foreign` FOREIGN KEY (`id_kendaraan`) REFERENCES `kendaraan` (`id_kendaraan`),
  ADD CONSTRAINT `transaksi_parkir_id_mall_foreign` FOREIGN KEY (`id_mall`) REFERENCES `mall` (`id_mall`),
  ADD CONSTRAINT `transaksi_parkir_id_parkiran_foreign` FOREIGN KEY (`id_parkiran`) REFERENCES `parkiran` (`id_parkiran`),
  ADD CONSTRAINT `transaksi_parkir_id_user_foreign` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
