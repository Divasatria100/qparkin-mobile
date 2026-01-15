-- Add biaya_estimasi column to booking table
-- This column stores the estimated cost calculated from tarif parkir

ALTER TABLE `booking` 
ADD COLUMN `biaya_estimasi` DECIMAL(10,2) NOT NULL DEFAULT 0 AFTER `durasi_booking`;

-- Update existing bookings with default value (optional)
-- UPDATE `booking` SET `biaya_estimasi` = 10000 WHERE `biaya_estimasi` = 0;
