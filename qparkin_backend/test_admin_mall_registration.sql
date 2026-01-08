-- ========================================
-- SQL Testing Script for Admin Mall Registration Fix
-- ========================================

-- 1. Check if migration columns exist
DESCRIBE user;

-- 2. Check pending applications
SELECT 
    id_user,
    name,
    email,
    role,
    status,
    application_status,
    requested_mall_name,
    requested_mall_location,
    applied_at,
    created_at
FROM user
WHERE application_status = 'pending'
ORDER BY applied_at DESC;

-- 3. Check application_notes content (JSON)
SELECT 
    id_user,
    name,
    requested_mall_name,
    application_notes,
    applied_at
FROM user
WHERE application_status = 'pending'
LIMIT 5;

-- 4. Count pending applications
SELECT 
    COUNT(*) as total_pending,
    COUNT(CASE WHEN applied_at IS NOT NULL THEN 1 END) as with_applied_at,
    COUNT(CASE WHEN requested_mall_name IS NOT NULL THEN 1 END) as with_mall_name
FROM user
WHERE application_status = 'pending';

-- 5. Check approved applications
SELECT 
    u.id_user,
    u.name,
    u.email,
    u.role,
    u.application_status,
    u.reviewed_at,
    m.id_mall,
    m.nama_mall,
    m.lokasi,
    m.latitude,
    m.longitude,
    am.id_admin_mall
FROM user u
LEFT JOIN admin_mall am ON u.id_user = am.id_user
LEFT JOIN mall m ON am.id_mall = m.id_mall
WHERE u.application_status = 'approved'
ORDER BY u.reviewed_at DESC
LIMIT 10;

-- 6. Check all application statuses
SELECT 
    application_status,
    COUNT(*) as total,
    GROUP_CONCAT(name SEPARATOR ', ') as names
FROM user
WHERE application_status IS NOT NULL
GROUP BY application_status;

-- 7. Check recent registrations (last 7 days)
SELECT 
    id_user,
    name,
    email,
    role,
    status,
    application_status,
    requested_mall_name,
    applied_at,
    created_at
FROM user
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
ORDER BY created_at DESC;

-- 8. Verify field mapping (check for old incorrect fields)
-- These should return 0 rows if fix is applied correctly
SELECT COUNT(*) as incorrect_role_count
FROM user
WHERE role = 'admin' AND application_status = 'pending';

-- 9. Check if any user has status='pending' (should be 0 after fix)
SELECT 
    id_user,
    name,
    email,
    role,
    status,
    application_status
FROM user
WHERE status = 'pending';

-- 10. Full audit of application flow
SELECT 
    'Total Users' as metric,
    COUNT(*) as value
FROM user
UNION ALL
SELECT 
    'Pending Applications',
    COUNT(*)
FROM user
WHERE application_status = 'pending'
UNION ALL
SELECT 
    'Approved Applications',
    COUNT(*)
FROM user
WHERE application_status = 'approved'
UNION ALL
SELECT 
    'Rejected Applications',
    COUNT(*)
FROM user
WHERE application_status = 'rejected'
UNION ALL
SELECT 
    'Admin Mall Users',
    COUNT(*)
FROM user
WHERE role = 'admin_mall'
UNION ALL
SELECT 
    'Malls Created',
    COUNT(*)
FROM mall;

-- ========================================
-- Test Data Insertion (Optional)
-- ========================================

-- Insert test pending application
-- Uncomment to create test data:

/*
INSERT INTO user (
    name,
    email,
    password,
    role,
    status,
    application_status,
    requested_mall_name,
    requested_mall_location,
    application_notes,
    applied_at,
    created_at,
    updated_at
) VALUES (
    'Test Admin Mall',
    'testadmin@mall.com',
    '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5iGBdCYBY.FRy', -- password: password123
    'customer',
    'aktif',
    'pending',
    'Test Mall Plaza',
    'Jl. Test No. 123, Jakarta',
    '{"latitude":-6.200000,"longitude":106.816666,"photo_path":"mall_photos/test.jpg","submitted_from":"web_registration"}',
    NOW(),
    NOW(),
    NOW()
);
*/

-- ========================================
-- Cleanup Test Data (Optional)
-- ========================================

-- Delete test data
-- Uncomment to remove test data:

/*
DELETE FROM user WHERE email = 'testadmin@mall.com';
*/
