-- ============================================================================
-- SIMPLE VEHICLE SCHEMA - MINIMAL FOR PARKING MALL
-- QParkin Mobile App Integration
-- ============================================================================

-- Struktur tabel kendaraan setelah migration
-- Hanya menampilkan struktur final, TANPA triggers/stored procedures

-- Expected columns after migration:
-- id_kendaraan    - BIGINT UNSIGNED (PK)
-- id_user         - BIGINT UNSIGNED (FK)
-- plat            - VARCHAR(20) UNIQUE
-- jenis           - ENUM('Roda Dua', 'Roda Tiga', 'Roda Empat', 'Lebih dari Enam')
-- merk            - VARCHAR(50)
-- tipe            - VARCHAR(50)
-- warna           - VARCHAR(50) NULL (NEW)
-- foto_path       - VARCHAR(255) NULL (NEW)
-- is_active       - BOOLEAN DEFAULT FALSE (NEW)
-- created_at      - TIMESTAMP NULL (NEW)
-- updated_at      - TIMESTAMP NULL (NEW)
-- last_used_at    - TIMESTAMP NULL (NEW) - Updated by parking system only

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

-- Index untuk query berdasarkan user dan status aktif
-- CREATE INDEX idx_user_active ON kendaraan (id_user, is_active);

-- Index untuk pencarian plat nomor
-- CREATE INDEX idx_plat ON kendaraan (plat);

-- ============================================================================
-- SAMPLE QUERIES
-- ============================================================================

-- Get user vehicles
-- SELECT * FROM kendaraan WHERE id_user = ? ORDER BY is_active DESC, created_at DESC;

-- Get active vehicle
-- SELECT * FROM kendaraan WHERE id_user = ? AND is_active = TRUE LIMIT 1;

-- Check plate uniqueness
-- SELECT COUNT(*) FROM kendaraan WHERE plat = ?;

-- Update last used (called by parking system only)
-- UPDATE kendaraan SET last_used_at = NOW() WHERE id_kendaraan = ?;

-- ============================================================================
-- BUSINESS RULES (Handled in Application Layer)
-- ============================================================================

-- 1. Only one active vehicle per user (handled in Controller)
-- 2. Plate number must be unique (handled by database constraint)
-- 3. last_used_at only updated by parking system (not in API endpoints)
-- 4. Photo storage in storage/app/public/vehicles/
-- 5. Soft validation in Controller, hard validation in database

-- ============================================================================
-- MAINTENANCE
-- ============================================================================

-- Clean up orphaned photos
-- SELECT foto_path FROM kendaraan WHERE foto_path IS NOT NULL;

-- Find vehicles never used for parking
-- SELECT * FROM kendaraan WHERE last_used_at IS NULL;

-- Find users with multiple active vehicles (data integrity check)
-- SELECT id_user, COUNT(*) as active_count 
-- FROM kendaraan 
-- WHERE is_active = TRUE 
-- GROUP BY id_user 
-- HAVING active_count > 1;

-- ============================================================================
-- END OF SIMPLE SCHEMA
-- ============================================================================
