# Booking Slot Reservation Field Fix

## Issue Summary

**Problem**: Booking fails with "NO_SLOTS_AVAILABLE" error despite available slots existing in database.

**Root Cause**: The `SlotAutoAssignmentService.createTemporaryReservation()` method was missing required fields `id_kendaraan` and `id_floor` when creating slot reservations.

**Error Message**:
```
SQLSTATE[HY000]: General error: 1364 Field 'id_kendaraan' doesn't have a default value
```

## Investigation Process

### 1. Initial Symptoms
- Mobile app shows "NO_SLOTS_AVAILABLE" error
- Database verification shows 60 slots exist, 20 are "Roda Dua" type
- All slots have status "available"
- Manual query successfully finds slot (ID: 61, code: UTAMA-L1-001)

### 2. Log Analysis
Laravel logs revealed the actual error:
```
[2026-01-15 10:45:29] local.INFO: Finding available slot
[2026-01-15 10:45:29] local.INFO: Found available slot: 61 (UTAMA-L1-001)
[2026-01-15 10:45:29] local.ERROR: Error creating temporary reservation: 
  Field 'id_kendaraan' doesn't have a default value
[2026-01-15 10:45:29] local.ERROR: Failed to create reservation for slot 61
[2026-01-15 10:45:29] local.WARNING: Failed to auto-assign slot
```

### 3. Schema Analysis
The `slot_reservations` table requires these fields:
- `id_reservation` (auto-increment primary key)
- `reservation_id` (UUID string)
- `id_slot` (foreign key to parking_slots)
- `id_user` (foreign key to user)
- **`id_kendaraan` (foreign key to kendaraan) - MISSING**
- **`id_floor` (foreign key to parking_floors) - MISSING**
- `status` (enum: active, confirmed, expired, cancelled)
- `reserved_at` (timestamp)
- `expires_at` (timestamp)
- `confirmed_at` (nullable timestamp)

## Solution Implemented

### Modified Files

#### 1. `qparkin_backend/app/Services/SlotAutoAssignmentService.php`

**Changes to `assignSlot()` method**:
```php
// OLD: Missing id_floor and id_kendaraan parameters
$reservation = $this->createTemporaryReservation(
    $slot->id_slot,
    $idUser,
    $waktuMulai,
    $durasiBooking
);

// NEW: Include all required parameters
$reservation = $this->createTemporaryReservation(
    $slot->id_slot,
    $slot->id_floor,      // Added
    $idKendaraan,         // Added
    $idUser,
    $waktuMulai,
    $durasiBooking
);
```

**Changes to `createTemporaryReservation()` method**:
```php
// OLD: Missing parameters and fields
private function createTemporaryReservation(
    int $idSlot,
    int $idUser,
    string $waktuMulai,
    int $durasiBooking
): ?SlotReservation {
    $reservation = SlotReservation::create([
        'reservation_id' => $reservationId,
        'id_slot' => $idSlot,
        'id_user' => $idUser,
        'reserved_at' => Carbon::now(),
        'status' => 'active',
        'expires_at' => $startTime,
    ]);
}

// NEW: Include all required parameters and fields
private function createTemporaryReservation(
    int $idSlot,
    int $idFloor,         // Added
    int $idKendaraan,     // Added
    int $idUser,
    string $waktuMulai,
    int $durasiBooking
): ?SlotReservation {
    $reservation = SlotReservation::create([
        'reservation_id' => $reservationId,
        'id_slot' => $idSlot,
        'id_floor' => $idFloor,           // Added
        'id_kendaraan' => $idKendaraan,   // Added
        'id_user' => $idUser,
        'reserved_at' => Carbon::now(),
        'status' => 'active',
        'expires_at' => $startTime,
    ]);
    
    // Added success logging
    Log::info("Created temporary reservation {$reservationId} for slot {$idSlot}");
}
```

## Testing

### Test Script
Run `test-booking-slot-assignment-fix.bat` to verify the fix.

### Expected Results
1. ✅ Slot is found: ID 61, code UTAMA-L1-001
2. ✅ Temporary reservation is created successfully
3. ✅ Booking returns 201 with booking data
4. ✅ Log shows: "Created temporary reservation AUTO-xxx for slot 61"
5. ✅ Log shows: "Auto-assigned slot UTAMA-L1-001 (ID: 61) for user X"

### Manual Testing Steps
1. **Clear cache**:
   ```bash
   cd qparkin_backend
   php artisan config:clear
   php artisan cache:clear
   ```

2. **Restart backend server**:
   ```bash
   php artisan serve
   ```

3. **Test from mobile app**:
   - Select Panbil Mall (id_parkiran: 1)
   - Select vehicle (id_kendaraan: 2, jenis: "Roda Dua")
   - Choose start time and duration
   - Confirm booking
   - Should succeed with booking confirmation

4. **Check logs**:
   ```bash
   tail -f storage/logs/laravel.log
   ```

## Related Issues Fixed

### Previous Issues (Now Resolved)
1. ✅ **id_parkiran not found** - Fixed by adding `id_parkiran` to MallModel
2. ✅ **jenis_kendaraan null** - Fixed by using `$kendaraan->jenis` instead of `$kendaraan->jenis_kendaraan`
3. ✅ **reserved_from/reserved_until columns** - Fixed by using `reserved_at` and `expires_at`
4. ✅ **Missing id_kendaraan and id_floor** - Fixed in this update
5. ✅ **updated_at column not found** - Fixed by disabling timestamps in Booking model (see `BOOKING_TIMESTAMPS_FIX.md`)

## Database State

### Verified Data
- **Parkiran ID 1** (Panbil Mall): 3 active floors, 60 total slots
- **Floor 4**: Lantai UTAMA, type "Roda Dua", 20 available slots
- **Slot 61**: Code UTAMA-L1-001, type "Roda Dua", status "available"
- **Vehicle ID 2**: Type "Roda Dua", matches floor and slot requirements

## Files Modified
1. `qparkin_backend/app/Services/SlotAutoAssignmentService.php`
   - Updated `assignSlot()` method signature call
   - Updated `createTemporaryReservation()` method signature and implementation
   - Added logging for successful reservation creation

## Files Created
1. `test-booking-slot-assignment-fix.bat` - Test script for verification
2. `BOOKING_SLOT_RESERVATION_FIELD_FIX.md` - This documentation

## Next Steps

After applying this fix:
1. Restart the backend server
2. Clear all caches
3. Test booking from mobile app
4. Verify logs show successful reservation creation
5. Confirm booking completes successfully

## Technical Notes

### Why This Happened
The `slot_reservations` table was designed to track which vehicle and floor are associated with each reservation. This is important for:
- **Vehicle type validation**: Ensuring the reserved slot matches the vehicle type
- **Floor tracking**: Knowing which floor the reservation is on
- **Reporting**: Generating statistics by vehicle type and floor
- **Conflict prevention**: Avoiding double-booking of slots

The service was initially written without these fields, likely because they seemed redundant (since slot already has floor). However, the database schema enforces these relationships for data integrity.

### Design Pattern
This follows the **Explicit Relationship Pattern** where foreign keys are explicitly stored even when they could be derived through joins. Benefits:
- Faster queries (no joins needed)
- Data integrity enforcement at database level
- Clearer data model
- Better indexing performance

## Status
✅ **FIXED** - Ready for testing
