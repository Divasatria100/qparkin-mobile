-- Add 'pending_payment' status to booking table enum
-- Run this SQL directly in your MySQL database

ALTER TABLE booking 
MODIFY COLUMN status ENUM('aktif', 'selesai', 'expired', 'pending_payment') 
DEFAULT 'aktif';

-- Verify the change
SHOW COLUMNS FROM booking LIKE 'status';
