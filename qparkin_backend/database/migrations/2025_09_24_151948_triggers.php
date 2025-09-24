<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Nonaktifkan foreign key check sementara
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');

        // Drop semua trigger terlebih dahulu
        $this->dropTriggers();

        /*
        |--------------------------------------------------------------------------
        | TRIGGERS BOOKING (7)
        |--------------------------------------------------------------------------
        */
        DB::unprepared("
            CREATE TRIGGER trg_booking_after_insert AFTER INSERT ON booking
            FOR EACH ROW
            BEGIN
                UPDATE Parkiran 
                SET kapasitas = kapasitas - 1
                WHERE id_parkiran = (
                    SELECT id_parkiran FROM Transaksi_Parkir WHERE id_transaksi = NEW.id_transaksi
                );
            END
        ");

        DB::unprepared("
            CREATE TRIGGER trg_booking_after_update AFTER UPDATE ON booking
            FOR EACH ROW
            BEGIN
                IF OLD.status = 'aktif' AND (NEW.status = 'selesai' OR NEW.status='expired') THEN
                    UPDATE Parkiran 
                    SET kapasitas = kapasitas + 1
                    WHERE id_parkiran = (
                        SELECT id_parkiran FROM Transaksi_Parkir WHERE id_transaksi = NEW.id_transaksi
                    );
                END IF;
            END
        ");

        DB::unprepared("
            CREATE TRIGGER trg_booking_after_update_expired_poin AFTER UPDATE ON booking
            FOR EACH ROW
            BEGIN
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
        ");

        DB::unprepared("
            CREATE TRIGGER trg_booking_after_update_notif AFTER UPDATE ON booking
            FOR EACH ROW
            BEGIN
                IF NEW.status = 'expired' AND OLD.status <> 'expired' THEN
                    SET @id_user := (SELECT id_user FROM transaksi_parkir WHERE id_transaksi = NEW.id_transaksi);
                    INSERT INTO notifikasi (id_user, pesan, waktu_kirim, status)
                    VALUES (@id_user, CONCAT('Booking #', NEW.id_transaksi, ' sudah expired.'), NOW(), 'belum');
                END IF;
            END
        ");

        DB::unprepared("
            CREATE TRIGGER trg_booking_after_update_penalty AFTER UPDATE ON booking
            FOR EACH ROW
            BEGIN
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
        ");

        DB::unprepared("
            CREATE TRIGGER trg_booking_before_insert BEFORE INSERT ON booking
            FOR EACH ROW
            BEGIN
                SET @kapasitas := (
                    SELECT kapasitas FROM Parkiran P 
                    JOIN Transaksi_Parkir T ON P.id_parkiran = T.id_parkiran 
                    WHERE T.id_transaksi = NEW.id_transaksi
                );
                IF @kapasitas <= 0 THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tidak ada slot tersedia untuk booking ini';
                END IF;
            END
        ");

        DB::unprepared("
            CREATE TRIGGER trg_booking_before_insert_unique BEFORE INSERT ON booking
            FOR EACH ROW
            BEGIN
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
        ");

        /*
        |--------------------------------------------------------------------------
        | TRIGGERS KENDARAAN (2)
        |--------------------------------------------------------------------------
        */
        DB::unprepared("
            CREATE TRIGGER trg_kendaraan_after_delete AFTER DELETE ON kendaraan
            FOR EACH ROW
            BEGIN
                INSERT INTO Notifikasi (id_user, pesan, waktu_kirim)
                VALUES (OLD.id_user, CONCAT('Kendaraan dengan plat ', OLD.plat, ' dihapus.'), NOW());
            END
        ");

        DB::unprepared("
            CREATE TRIGGER trg_kendaraan_after_insert AFTER INSERT ON kendaraan
            FOR EACH ROW
            BEGIN
                INSERT INTO Notifikasi (id_user, pesan, waktu_kirim)
                VALUES (NEW.id_user, CONCAT('Kendaraan dengan plat ', NEW.plat, ' berhasil ditambahkan.'), NOW());
            END
        ");

        /*
        |--------------------------------------------------------------------------
        | TRIGGERS MALL (2)
        |--------------------------------------------------------------------------
        */
        DB::unprepared("
            CREATE TRIGGER trg_mall_after_delete AFTER DELETE ON mall
            FOR EACH ROW
            BEGIN
                DELETE FROM Parkiran WHERE id_mall = OLD.id_mall;
                DELETE FROM Tarif_Parkir WHERE id_mall = OLD.id_mall;
            END
        ");

        DB::unprepared("
            CREATE TRIGGER trg_mall_after_insert AFTER INSERT ON mall
            FOR EACH ROW
            BEGIN
                INSERT INTO Notifikasi (id_user, pesan, waktu_kirim)
                SELECT id_user, CONCAT('Mall baru ditambahkan: ', NEW.nama_mall), NOW()
                FROM Super_Admin;
            END
        ");

        /*
        |--------------------------------------------------------------------------
        | TRIGGERS PARKIRAN (4)
        |--------------------------------------------------------------------------
        */
        DB::unprepared("
            CREATE TRIGGER trg_parkiran_after_update AFTER UPDATE ON parkiran
            FOR EACH ROW
            BEGIN
                IF OLD.status = 'Tersedia' AND NEW.status = 'Ditutup' THEN
                    INSERT INTO Notifikasi (id_user, pesan, waktu_kirim)
                    SELECT U.id_user, CONCAT('Parkiran di mall ', M.nama_mall, ' ditutup'), NOW()
                    FROM Admin_Mall AM
                    JOIN User U ON AM.id_user = U.id_user
                    JOIN Mall M ON AM.id_mall = M.id_mall
                    WHERE AM.id_mall = NEW.id_mall;
                END IF;
            END
        ");

        DB::unprepared("
            CREATE TRIGGER trg_parkiran_after_update_full_notify AFTER UPDATE ON parkiran
            FOR EACH ROW
            BEGIN
                IF NEW.kapasitas = 0 AND OLD.kapasitas > 0 THEN
                    INSERT INTO notifikasi (id_user, pesan, waktu_kirim, status)
                    SELECT AM.id_user,
                           CONCAT('Parkiran di mall ', M.nama_mall, ' sudah penuh.'),
                           NOW(), 'belum'
                    FROM admin_mall AM
                    JOIN mall M ON M.id_mall = NEW.id_mall;
                END IF;
            END
        ");

        DB::unprepared("
            CREATE TRIGGER trg_parkiran_before_insert BEFORE INSERT ON parkiran
            FOR EACH ROW
            BEGIN
                IF NEW.kapasitas < 0 THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Kapasitas parkiran tidak boleh negatif';
                END IF;
            END
        ");

        DB::unprepared("
            CREATE TRIGGER trg_parkiran_before_update BEFORE UPDATE ON parkiran
            FOR EACH ROW
            BEGIN
                SET @kapasitas_mall := (SELECT kapasitas FROM mall WHERE id_mall = NEW.id_mall);
                IF NEW.kapasitas > @kapasitas_mall THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Kapasitas parkiran melebihi kapasitas mall';
                END IF;
            END
        ");

        /*
        |--------------------------------------------------------------------------
        | TRIGGERS PEMBAYARAN (6)
        |--------------------------------------------------------------------------
        */
        DB::unprepared("
            CREATE TRIGGER trg_booking_pembayaran_after_update_poin_bonus AFTER UPDATE ON pembayaran
            FOR EACH ROW
            BEGIN
                IF NEW.status = 'berhasil' AND OLD.status <> 'berhasil' 
                   AND NEW.metode <> 'poin'
                   AND EXISTS (SELECT 1 FROM booking WHERE id_transaksi = NEW.id_transaksi) THEN

                    SET @id_user := (SELECT id_user FROM transaksi_parkir WHERE id_transaksi = NEW.id_transaksi);
                    SET @poin := FLOOR(NEW.nominal / 1000) * 10;

                    INSERT INTO riwayat_poin (id_user, id_transaksi, poin, perubahan, keterangan, waktu)
                    VALUES (@id_user, NEW.id_transaksi, @poin, 'tambah', 'Bonus poin dari pembayaran booking', NOW());
                END IF;
            END
        ");

        DB::unprepared("
            CREATE TRIGGER trg_pembayaran_after_update AFTER UPDATE ON pembayaran
            FOR EACH ROW
            BEGIN
                IF NEW.status = 'berhasil' AND OLD.status <> 'berhasil' AND NEW.metode <> 'poin' THEN
                    SET @user_id := (SELECT id_user FROM transaksi_parkir WHERE id_transaksi = NEW.id_transaksi);
                    SET @poin := FLOOR(NEW.nominal / 1000) * 10;

                    INSERT INTO riwayat_poin (id_user, id_transaksi, poin, perubahan, keterangan, waktu)
                    VALUES (@user_id, NEW.id_transaksi, @poin, 'tambah', 'Bonus poin dari pembayaran parkir', NOW());

                    INSERT INTO notifikasi (id_user, pesan, waktu_kirim, status)
                    VALUES (@user_id, CONCAT('Pembayaran berhasil untuk transaksi ', NEW.id_transaksi, '. Nominal: Rp', NEW.nominal), NOW(), 'belum');
                END IF;
            END
        ");

        DB::unprepared("
            CREATE TRIGGER trg_pembayaran_after_update_double_poin AFTER UPDATE ON pembayaran
            FOR EACH ROW
            BEGIN
                IF NEW.status = 'berhasil' AND OLD.status <> 'berhasil'
                   AND NEW.metode <> 'poin'
                   AND DAYOFWEEK(NOW()) IN (1,7) THEN
                    SET @id_user := (SELECT id_user FROM transaksi_parkir WHERE id_transaksi = NEW.id_transaksi);
                    SET @extra_poin := FLOOR(NEW.nominal / 1000) * 10;

                    INSERT INTO riwayat_poin (id_user, id_transaksi, poin, perubahan, keterangan, waktu)
                    VALUES (@id_user, NEW.id_transaksi, @extra_poin, 'tambah', 'Promo Double Poin Weekend', NOW());
                END IF;
            END
        ");

        DB::unprepared("
            CREATE TRIGGER trg_pembayaran_after_update_notif AFTER UPDATE ON pembayaran
            FOR EACH ROW
            BEGIN
                IF NEW.status = 'gagal' AND OLD.status <> 'gagal' THEN
                    SET @id_user := (SELECT id_user FROM transaksi_parkir WHERE id_transaksi = NEW.id_transaksi);
                    INSERT INTO notifikasi (id_user, pesan, waktu_kirim, status)
                    VALUES (@id_user, CONCAT('Pembayaran transaksi #', NEW.id_transaksi, ' gagal. Silakan coba lagi.'), NOW(), 'belum');
                END IF;
            END
        ");

        DB::unprepared("
            CREATE TRIGGER trg_pembayaran_after_update_poin AFTER UPDATE ON pembayaran
            FOR EACH ROW
            BEGIN
                IF NEW.status = 'berhasil' AND OLD.status <> 'berhasil' AND NEW.metode = 'poin' THEN
                    SET @id_user := (SELECT id_user FROM transaksi_parkir WHERE id_transaksi = NEW.id_transaksi);
                    SET @poin_dipotong := FLOOR(NEW.nominal / 10);

                    INSERT INTO riwayat_poin (id_user, id_transaksi, poin, perubahan, keterangan, waktu)
                    VALUES (@id_user, NEW.id_transaksi, @poin_dipotong, 'kurang', 'Penukaran biaya parkir dengan poin', NOW());
                END IF;
            END
        ");

        DB::unprepared("
            CREATE TRIGGER trg_pembayaran_before_insert BEFORE INSERT ON pembayaran
            FOR EACH ROW
            BEGIN
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
        ");

        /*
        |--------------------------------------------------------------------------
        | TRIGGERS RIWAYAT GERBANG (1)
        |--------------------------------------------------------------------------
        */
        DB::unprepared("
            CREATE TRIGGER trg_riwayatgerbang_after_insert AFTER INSERT ON riwayat_gerbang
            FOR EACH ROW
            BEGIN
                SET @id_mall := (SELECT id_mall FROM gerbang WHERE id_gerbang = NEW.id_gerbang);
                INSERT INTO notifikasi (id_user, pesan, waktu_kirim, status)
                SELECT AM.id_user,
                       CONCAT('Gerbang ', G.nama_gerbang, ' mall #', @id_mall, ' berubah menjadi ', NEW.status_sesudah),
                       NOW(), 'belum'
                FROM admin_mall AM
                JOIN gerbang G ON G.id_gerbang = NEW.id_gerbang
                WHERE AM.id_mall = @id_mall;
            END
        ");

        /*
        |--------------------------------------------------------------------------
        | TRIGGERS RIWAYAT POIN (2)
        |--------------------------------------------------------------------------
        */
        DB::unprepared("
            CREATE TRIGGER trg_riwayatpoin_after_insert AFTER INSERT ON riwayat_poin
            FOR EACH ROW
            BEGIN
                IF NEW.perubahan = 'tambah' THEN
                    UPDATE user SET saldo_poin = saldo_poin + NEW.poin WHERE id_user = NEW.id_user;
                ELSEIF NEW.perubahan = 'kurang' THEN
                    UPDATE user SET saldo_poin = saldo_poin - NEW.poin WHERE id_user = NEW.id_user;
                END IF;
            END
        ");

        DB::unprepared("
            CREATE TRIGGER trg_riwayatpoin_after_insert_notif AFTER INSERT ON riwayat_poin
            FOR EACH ROW
            BEGIN
                DECLARE vPesan TEXT;
                IF NEW.perubahan = 'tambah' THEN
                    SET vPesan = CONCAT('Anda mendapat tambahan poin: ', NEW.poin, ' (', NEW.keterangan, ')');
                ELSEIF NEW.perubahan = 'kurang' THEN
                    SET vPesan = CONCAT('Poin Anda berkurang: ', NEW.poin, ' (', NEW.keterangan, ')');
                END IF;
                INSERT INTO notifikasi (id_user, pesan, waktu_kirim, status)
                VALUES (NEW.id_user, vPesan, NOW(), 'belum');
            END
        ");

        /*
        |--------------------------------------------------------------------------
        | TRIGGERS TARIF PARKIR (2)
        |--------------------------------------------------------------------------
        */
        DB::unprepared("
            CREATE TRIGGER trg_tarif_after_update_notify AFTER UPDATE ON tarif_parkir
            FOR EACH ROW
            BEGIN
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
        ");

        DB::unprepared("
            CREATE TRIGGER trg_tarif_before_insert BEFORE INSERT ON tarif_parkir
            FOR EACH ROW
            BEGIN
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
        ");

        /*
        |--------------------------------------------------------------------------
        | TRIGGERS TRANSAKSI PARKIR (6)
        |--------------------------------------------------------------------------
        */
        DB::unprepared("
            CREATE TRIGGER trg_transaksi_after_insert AFTER INSERT ON transaksi_parkir
            FOR EACH ROW
            BEGIN
                UPDATE Parkiran SET kapasitas = kapasitas - 1 WHERE id_parkiran = NEW.id_parkiran;
            END
        ");

        DB::unprepared("
            CREATE TRIGGER trg_transaksi_after_insert_gerbang AFTER INSERT ON transaksi_parkir
            FOR EACH ROW
            BEGIN
                DECLARE v_id_gerbang INT;
                SET v_id_gerbang := (SELECT id_gerbang FROM pembayaran WHERE id_transaksi = NEW.id_transaksi LIMIT 1);
                IF v_id_gerbang IS NOT NULL THEN
                    INSERT INTO riwayat_gerbang (id_gerbang, aksi, status_sebelum, status_sesudah)
                    VALUES (v_id_gerbang, 'terbuka', 'tertutup', 'terbuka');
                END IF;
            END
        ");

        DB::unprepared("
            CREATE TRIGGER trg_transaksi_after_update AFTER UPDATE ON transaksi_parkir
            FOR EACH ROW
            BEGIN
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
        ");

        DB::unprepared("
            CREATE TRIGGER trg_transaksi_after_update_notif AFTER UPDATE ON transaksi_parkir
            FOR EACH ROW
            BEGIN
                IF NEW.waktu_keluar IS NOT NULL AND OLD.waktu_keluar IS NULL THEN
                    INSERT INTO notifikasi (id_user, pesan, waktu_kirim, status)
                    VALUES (
                        NEW.id_user,
                        CONCAT('Transaksi parkir #', NEW.id_transaksi, ' selesai. Total biaya: Rp', NEW.biaya),
                        NOW(), 'belum'
                    );
                END IF;
            END
        ");

        DB::unprepared("
            CREATE TRIGGER trg_transaksi_before_insert_unique BEFORE INSERT ON transaksi_parkir
            FOR EACH ROW
            BEGIN
                IF EXISTS (
                    SELECT 1 FROM transaksi_parkir
                    WHERE id_kendaraan = NEW.id_kendaraan AND waktu_keluar IS NULL
                ) THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Kendaraan ini masih memiliki transaksi aktif';
                END IF;
            END
        ");

        DB::unprepared("
            CREATE TRIGGER trg_transaksi_before_update_keluar BEFORE UPDATE ON transaksi_parkir
            FOR EACH ROW
            BEGIN
                IF NEW.waktu_keluar IS NOT NULL AND OLD.waktu_keluar IS NULL THEN
                    IF NOT EXISTS (
                        SELECT 1 FROM pembayaran WHERE id_transaksi = NEW.id_transaksi AND status = 'berhasil'
                    ) THEN
                        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tidak bisa keluar sebelum pembayaran berhasil';
                    END IF;
                END IF;
            END
        ");

        /*
        |--------------------------------------------------------------------------
        | TRIGGERS USER (2)
        |--------------------------------------------------------------------------
        */
        DB::unprepared("
            CREATE TRIGGER trg_user_after_insert AFTER INSERT ON user
            FOR EACH ROW
            BEGIN
                INSERT INTO notifikasi (id_user, pesan, waktu_kirim, status)
                VALUES (NEW.id_user, CONCAT('Selamat datang, ', NEW.name, '! Akun Anda berhasil dibuat.'), NOW(), 'belum');
            END
        ");

        DB::unprepared("
            CREATE TRIGGER trg_user_before_update BEFORE UPDATE ON user
            FOR EACH ROW
            BEGIN
                IF NEW.saldo_poin < 0 THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo poin tidak boleh negatif';
                END IF;
            END
        ");

        // Aktifkan kembali foreign key check
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        $this->dropTriggers();
    }

    /**
     * Drop semua trigger
     */
    private function dropTriggers(): void
    {
        $triggers = [
            'trg_booking_after_insert',
            'trg_booking_after_update',
            'trg_booking_after_update_expired_poin',
            'trg_booking_after_update_notif',
            'trg_booking_after_update_penalty',
            'trg_booking_before_insert',
            'trg_booking_before_insert_unique',
            'trg_kendaraan_after_delete',
            'trg_kendaraan_after_insert',
            'trg_mall_after_delete',
            'trg_mall_after_insert',
            'trg_parkiran_after_update',
            'trg_parkiran_after_update_full_notify',
            'trg_parkiran_before_insert',
            'trg_parkiran_before_update',
            'trg_booking_pembayaran_after_update_poin_bonus',
            'trg_pembayaran_after_update',
            'trg_pembayaran_after_update_double_poin',
            'trg_pembayaran_after_update_notif',
            'trg_pembayaran_after_update_poin',
            'trg_pembayaran_before_insert',
            'trg_riwayatgerbang_after_insert',
            'trg_riwayatpoin_after_insert',
            'trg_riwayatpoin_after_insert_notif',
            'trg_tarif_after_update_notify',
            'trg_tarif_before_insert',
            'trg_transaksi_after_insert',
            'trg_transaksi_after_insert_gerbang',
            'trg_transaksi_after_update',
            'trg_transaksi_after_update_notif',
            'trg_transaksi_before_insert_unique',
            'trg_transaksi_before_update_keluar',
            'trg_user_after_insert',
            'trg_user_before_update',
        ];

        foreach ($triggers as $trigger) {
            DB::unprepared("DROP TRIGGER IF EXISTS {$trigger};");
        }
    }
};
