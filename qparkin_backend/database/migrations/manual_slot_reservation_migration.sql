-- ============================================================================
-- SLOT RESERVATION SYSTEM - MANUAL MIGRATION SCRIPT
-- ============================================================================
-- Version: 1.0.0
-- Date: 2025-12-05
-- Description: Manual SQL migration untuk Slot Reservation System
-- 
-- IMPORTANT: Backup database sebelum menjalankan script ini!
-- mysqldump -u username -p qparkin > backup_before_slot_migration.sql
-- ============================================================================

-- ============================================================================
-- STEP 1: Create parking_floors table
-- ============================================================================

CREATE TABLE IF NOT EXISTS `parking_floors` (
  `id_floor` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_parkiran` bigint(20) UNSIGNED NOT NULL,
  `floor_name` varchar(50) NOT NULL,
  `floor_number` int(11) NOT NULL,
  `total_slots` int(11) NOT NULL DEFAULT 0,
  `available_slots` int(11) NOT NULL DEFAULT 0,
  `status` enum('active','inactive','maintenance') NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id_floor`),
  KEY `parking_floors_id_parkiran_index` (`id_parkiran`),
  KEY `parking_floors_status_index` (`status`),
  CONSTRAINT `parking_floors_id_parkiran_foreign` 
    FOREIGN KEY (`id_parkiran`) 
    REFERENCES `parkiran` (`id_parkiran`) 
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- STEP 2: Create parking_slots table
-- ============================================================================

CREATE TABLE IF NOT EXISTS `parking_slots` (
  `id_slot` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_floor` bigint(20) UNSIGNED NOT NULL,
  `slot_code` varchar(20) NOT NULL,
  `jenis_kendaraan` enum('Roda Dua','Roda Tiga','Roda Empat','Lebih dari Enam') NOT NULL,
  `status` enum('available','occupied','reserved','maintenance') NOT NULL DEFAULT 'available',
  `position_x` int(11) DEFAULT NULL,
  `position_y` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id_slot`),
  UNIQUE KEY `parking_slots_slot_code_unique` (`slot_code`),
  KEY `parking_slots_id_floor_index` (`id_floor`),
  KEY `parking_slots_status_index` (`status`),
  KEY `parking_slots_jenis_kendaraan_index` (`jenis_kendaraan`),
  KEY `parking_slots_id_floor_status_index` (`id_floor`,`status`),
  CONSTRAINT `parking_slots_id_floor_foreign` 
    FOREIGN KEY (`id_floor`) 
    REFERENCES `parking_floors` (`id_floor`) 
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- STEP 3: Create slot_reservations table
-- ============================================================================

CREATE TABLE IF NOT EXISTS `slot_reservations` (
  `id_reservation` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `reservation_id` varchar(36) NOT NULL,
  `id_slot` bigint(20) UNSIGNED NOT NULL,
  `id_user` bigint(20) UNSIGNED NOT NULL,
  `id_kendaraan` bigint(20) UNSIGNED NOT NULL,
  `id_floor` bigint(20) UNSIGNED NOT NULL,
  `status` enum('active','confirmed','expired','cancelled') NOT NULL DEFAULT 'active',
  `reserved_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NOT NULL,
  `confirmed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id_reservation`),
  UNIQUE KEY `slot_reservations_reservation_id_unique` (`reservation_id`),
  KEY `slot_reservations_reservation_id_index` (`reservation_id`),
  KEY `slot_reservations_id_user_index` (`id_user`),
  KEY `slot_reservations_id_slot_index` (`id_slot`),
  KEY `slot_reservations_status_index` (`status`),
  KEY `slot_reservations_expires_at_index` (`expires_at`),
  CONSTRAINT `slot_reservations_id_slot_foreign` 
    FOREIGN KEY (`id_slot`) 
    REFERENCES `parking_slots` (`id_slot`) 
    ON DELETE CASCADE,
  CONSTRAINT `slot_reservations_id_user_foreign` 
    FOREIGN KEY (`id_user`) 
    REFERENCES `user` (`id_user`) 
    ON DELETE CASCADE,
  CONSTRAINT `slot_reservations_id_kendaraan_foreign` 
    FOREIGN KEY (`id_kendaraan`) 
    REFERENCES `kendaraan` (`id_kendaraan`) 
    ON DELETE CASCADE,
  CONSTRAINT `slot_reservations_id_floor_foreign` 
    FOREIGN KEY (`id_floor`) 
    REFERENCES `parking_floors` (`id_floor`) 
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- STEP 4: Add columns to booking table
-- ============================================================================

-- Check if columns don't exist before adding
SET @dbname = DATABASE();
SET @tablename = 'booking';
SET @columnname1 = 'id_slot';
SET @columnname2 = 'reservation_id';

SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_SCHEMA = @dbname
   AND TABLE_NAME = @tablename
   AND COLUMN_NAME = @columnname1) = 0,
  'ALTER TABLE booking ADD COLUMN id_slot bigint(20) UNSIGNED NULL AFTER id_transaksi',
  'SELECT "Column id_slot already exists" AS message'
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_SCHEMA = @dbname
   AND TABLE_NAME = @tablename
   AND COLUMN_NAME = @columnname2) = 0,
  'ALTER TABLE booking ADD COLUMN reservation_id varchar(36) NULL AFTER id_slot',
  'SELECT "Column reservation_id already exists" AS message'
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Add foreign key constraint for id_slot
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
   WHERE TABLE_SCHEMA = @dbname
   AND TABLE_NAME = @tablename
   AND CONSTRAINT_NAME = 'booking_id_slot_foreign') = 0,
  'ALTER TABLE booking ADD CONSTRAINT booking_id_slot_foreign FOREIGN KEY (id_slot) REFERENCES parking_slots(id_slot) ON DELETE SET NULL',
  'SELECT "Foreign key booking_id_slot_foreign already exists" AS message'
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Add indexes
ALTER TABLE booking ADD INDEX IF NOT EXISTS booking_id_slot_index (id_slot);
ALTER TABLE booking ADD INDEX IF NOT EXISTS booking_reservation_id_index (reservation_id);

-- ============================================================================
-- STEP 5: Add column to transaksi_parkir table
-- ============================================================================

SET @tablename = 'transaksi_parkir';
SET @columnname = 'id_slot';

SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_SCHEMA = @dbname
   AND TABLE_NAME = @tablename
   AND COLUMN_NAME = @columnname) = 0,
  'ALTER TABLE transaksi_parkir ADD COLUMN id_slot bigint(20) UNSIGNED NULL AFTER id_parkiran',
  'SELECT "Column id_slot already exists in transaksi_parkir" AS message'
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Add foreign key constraint
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
   WHERE TABLE_SCHEMA = @dbname
   AND TABLE_NAME = @tablename
   AND CONSTRAINT_NAME = 'transaksi_parkir_id_slot_foreign') = 0,
  'ALTER TABLE transaksi_parkir ADD CONSTRAINT transaksi_parkir_id_slot_foreign FOREIGN KEY (id_slot) REFERENCES parking_slots(id_slot) ON DELETE SET NULL',
  'SELECT "Foreign key transaksi_parkir_id_slot_foreign already exists" AS message'
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Add index
ALTER TABLE transaksi_parkir ADD INDEX IF NOT EXISTS transaksi_parkir_id_slot_index (id_slot);

-- ============================================================================
-- STEP 6: Add feature flag to mall table
-- ============================================================================

SET @tablename = 'mall';
SET @columnname = 'has_slot_reservation_enabled';

SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_SCHEMA = @dbname
   AND TABLE_NAME = @tablename
   AND COLUMN_NAME = @columnname) = 0,
  'ALTER TABLE mall ADD COLUMN has_slot_reservation_enabled tinyint(1) NOT NULL DEFAULT 0 AFTER alamat_gmaps',
  'SELECT "Column has_slot_reservation_enabled already exists" AS message'
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Add index
ALTER TABLE mall ADD INDEX IF NOT EXISTS mall_has_slot_reservation_enabled_index (has_slot_reservation_enabled);

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check if all tables exist
SELECT 
    'parking_floors' AS table_name,
    IF(COUNT(*) > 0, 'EXISTS', 'NOT EXISTS') AS status
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'parking_floors'
UNION ALL
SELECT 
    'parking_slots',
    IF(COUNT(*) > 0, 'EXISTS', 'NOT EXISTS')
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'parking_slots'
UNION ALL
SELECT 
    'slot_reservations',
    IF(COUNT(*) > 0, 'EXISTS', 'NOT EXISTS')
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'slot_reservations';

-- Check if columns added to existing tables
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
AND (
    (TABLE_NAME = 'booking' AND COLUMN_NAME IN ('id_slot', 'reservation_id'))
    OR (TABLE_NAME = 'transaksi_parkir' AND COLUMN_NAME = 'id_slot')
    OR (TABLE_NAME = 'mall' AND COLUMN_NAME = 'has_slot_reservation_enabled')
)
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- ============================================================================
-- ROLLBACK SCRIPT (USE WITH CAUTION!)
-- ============================================================================
-- Uncomment lines below to rollback changes

/*
-- Drop foreign keys first
ALTER TABLE booking DROP FOREIGN KEY IF EXISTS booking_id_slot_foreign;
ALTER TABLE transaksi_parkir DROP FOREIGN KEY IF EXISTS transaksi_parkir_id_slot_foreign;

-- Drop indexes
ALTER TABLE booking DROP INDEX IF EXISTS booking_id_slot_index;
ALTER TABLE booking DROP INDEX IF EXISTS booking_reservation_id_index;
ALTER TABLE transaksi_parkir DROP INDEX IF EXISTS transaksi_parkir_id_slot_index;
ALTER TABLE mall DROP INDEX IF EXISTS mall_has_slot_reservation_enabled_index;

-- Drop columns from existing tables
ALTER TABLE booking DROP COLUMN IF EXISTS id_slot;
ALTER TABLE booking DROP COLUMN IF EXISTS reservation_id;
ALTER TABLE transaksi_parkir DROP COLUMN IF EXISTS id_slot;
ALTER TABLE mall DROP COLUMN IF EXISTS has_slot_reservation_enabled;

-- Drop new tables (in reverse order due to foreign keys)
DROP TABLE IF EXISTS slot_reservations;
DROP TABLE IF EXISTS parking_slots;
DROP TABLE IF EXISTS parking_floors;
*/

-- ============================================================================
-- END OF MIGRATION SCRIPT
-- ============================================================================
