# Mall Seeder - DISABLED

## Status

✅ **MallSeeder has been DISABLED**

## Reason

Mall data is now created through the **Admin Mall Registration Flow**, not via database seeder.

## New Workflow

### Admin Mall Registration Flow:

1. **Admin Mall registers** via `/signup` page
   - Fills in mall information (nama mall, alamat, koordinat, dll)
   - Creates user account with role `admin_mall`

2. **SuperAdmin reviews** via `/super/pengajuan-akun`
   - Views pending registrations
   - Can approve or reject

3. **Upon approval:**
   - Mall record created in `mall` table
   - AdminMall record created in `admin_mall` table
   - Relationship established: 1 Admin Mall = 1 Mall

## Benefits

✅ **Real-world workflow** - Matches actual business process  
✅ **Proper relationships** - Ensures 1:1 admin-mall relationship  
✅ **Data integrity** - No orphaned malls without admin  
✅ **Audit trail** - Registration tracked via `pending_admin_mall` table  

## Files Modified

### Seeders (DISABLED):
- `qparkin_backend/database/seeders/MallSeeder.php` - Emptied with explanation
- `qparkin_backend/database/seeders/AdminMallSeeder.php` - Should also be disabled
- `qparkin_backend/database/seeders/DatabaseSeeder.php` - Commented out both seeders

### Registration Controllers:
- `qparkin_backend/app/Http/Controllers/Auth/AdminMallRegistrationController.php` - Handles registration
- `qparkin_backend/app/Http/Controllers/SuperAdminController.php` - Handles approval

## For Development/Testing

If you need test mall data for development:

### Option 1: Use Registration Flow (Recommended)
```
1. Go to http://localhost:8000/signup
2. Fill in mall registration form
3. Login as superadmin
4. Go to http://localhost:8000/super/pengajuan-akun
5. Approve the registration
```

### Option 2: Manual SQL Insert (Quick Testing)
```sql
-- Insert mall
INSERT INTO mall (nama_mall, alamat_lengkap, latitude, longitude, kapasitas, status, has_slot_reservation_enabled)
VALUES ('Test Mall', 'Test Address', 1.1234, 104.1234, 100, 'active', true);

-- Get the mall ID
SET @mall_id = LAST_INSERT_ID();

-- Insert user for admin mall
INSERT INTO user (nama, email, password, no_hp, role)
VALUES ('Admin Test Mall', 'admin@testmall.com', '$2y$10$...', '081234567890', 'admin_mall');

-- Get the user ID
SET @user_id = LAST_INSERT_ID();

-- Link admin to mall
INSERT INTO admin_mall (id_user, id_mall)
VALUES (@user_id, @mall_id);
```

### Option 3: Re-enable Seeder Temporarily
If you really need seeder for automated testing:

1. Uncomment in `DatabaseSeeder.php`:
   ```php
   MallSeeder::class,
   AdminMallSeeder::class,
   ```

2. Restore data in `MallSeeder.php`

3. Run: `php artisan db:seed --class=MallSeeder`

**Note:** Remember to disable again after testing to avoid conflicts with registration flow.

## Previous Seeder Data (For Reference)

The old seeder created these malls:

1. **Mega Mall Batam Centre**
   - Address: Jl. Engku Putri no.1, Batam Centre
   - Capacity: 200
   - Slot Reservation: Enabled

2. **One Batam Mall**
   - Address: Jl. Raja H. Fisabilillah No. 9, Batam Center
   - Capacity: 150
   - Slot Reservation: Enabled

3. **SNL Food Bengkong**
   - Address: Garden Avenue Square, Bengkong, Batam
   - Capacity: 100
   - Slot Reservation: Disabled

## Related Documentation

- `ADMIN_MALL_REGISTRATION_FIX_COMPLETE.md` - Registration flow implementation
- `ADMIN_MALL_IMPLEMENTATION_COMPLETE.md` - Complete admin mall system
- `ADMIN_MALL_QUICK_START.md` - Quick start guide for admin mall features

## Impact on Existing Code

✅ **No breaking changes** - API endpoints still work the same  
✅ **Flutter app unaffected** - Still fetches from `/api/mall`  
✅ **Database schema unchanged** - Only seeder behavior changed  

## Testing

After disabling seeder:

1. **Fresh database:**
   ```bash
   php artisan migrate:fresh
   php artisan db:seed
   ```
   Result: No mall data (expected)

2. **Create mall via registration:**
   - Use `/signup` flow
   - Verify mall appears in `/api/mall`
   - Verify Flutter app shows the mall

3. **Verify relationship:**
   ```sql
   SELECT m.nama_mall, u.nama as admin_name, u.email
   FROM mall m
   JOIN admin_mall am ON m.id_mall = am.id_mall
   JOIN user u ON am.id_user = u.id_user;
   ```
   Should show proper 1:1 relationship.

## Status

✅ **COMPLETE** - MallSeeder disabled, registration flow is the primary method for creating mall data.
