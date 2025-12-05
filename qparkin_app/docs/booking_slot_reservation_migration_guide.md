# Booking Slot Reservation Migration Guide

## Overview

This guide provides instructions for migrating from the basic booking system (v1.0) to the enhanced slot reservation system (v2.0). The migration includes database changes, API updates, and feature flag implementation for gradual rollout.

## Version Information

- **From:** v1.0 (Basic booking with automatic slot assignment)
- **To:** v2.0 (Enhanced booking with floor selection and slot reservation)
- **Migration Date:** December 2025
- **Backward Compatibility:** Yes (both systems can coexist)

---

## Database Changes

### 1. New Tables

#### parking_floors

Stores parking floor information for each mall.

```sql
CREATE TABLE parking_floors (
  id_floor VARCHAR(50) PRIMARY KEY,
  id_mall VARCHAR(50) NOT NULL,
  floor_number INT NOT NULL,
  floor_name VARCHAR(100) NOT NULL,
  total_slots INT NOT NULL DEFAULT 0,
  available_slots INT NOT NULL DEFAULT 0,
  occupied_slots INT NOT NULL DEFAULT 0,
  reserved_slots INT NOT NULL DEFAULT 0,
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (id_mall) REFERENCES mall(id_mall) ON DELETE CASCADE,
  INDEX idx_mall_floor (id_mall, floor_number)
);
```

#### parking_slots

Stores individual parking slot information.

```sql
CREATE TABLE parking_slots (
  id_slot VARCHAR(50) PRIMARY KEY,
  id_floor VARCHAR(50) NOT NULL,
  slot_code VARCHAR(20) NOT NULL,
  status ENUM('available', 'occupied', 'reserved', 'disabled') DEFAULT 'available',
  slot_type ENUM('regular', 'disableFriendly') DEFAULT 'regular',
  position_x INT,
  position_y INT,
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (id_floor) REFERENCES parking_floors(id_floor) ON DELETE CASCADE,
  UNIQUE KEY unique_floor_slot (id_floor, slot_code),
  INDEX idx_floor_status (id_floor, status)
);
```

#### slot_reservations

Stores temporary slot reservations (5-minute locks).

```sql
CREATE TABLE slot_reservations (
  reservation_id VARCHAR(50) PRIMARY KEY,
  id_slot VARCHAR(50) NOT NULL,
  id_user VARCHAR(50) NOT NULL,
  slot_code VARCHAR(20) NOT NULL,
  floor_name VARCHAR(100) NOT NULL,
  floor_number VARCHAR(10) NOT NULL,
  slot_type ENUM('regular', 'disableFriendly') DEFAULT 'regular',
  reserved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (id_slot) REFERENCES parking_slots(id_slot) ON DELETE CASCADE,
  FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE,
  INDEX idx_user_active (id_user, is_active),
  INDEX idx_slot_active (id_slot, is_active),
  INDEX idx_expires (expires_at)
);
```

### 2. Modified Tables

#### booking (Add optional slot fields)

```sql
ALTER TABLE booking
ADD COLUMN id_slot VARCHAR(50) NULL AFTER id_kendaraan,
ADD COLUMN reservation_id VARCHAR(50) NULL AFTER id_slot,
ADD CONSTRAINT fk_booking_slot 
  FOREIGN KEY (id_slot) REFERENCES parking_slots(id_slot) ON DELETE SET NULL;

-- Add index for slot lookups
CREATE INDEX idx_booking_slot ON booking(id_slot);
```

#### transaksi_parkir (Add optional slot field)

```sql
ALTER TABLE transaksi_parkir
ADD COLUMN id_slot VARCHAR(50) NULL AFTER id_parkiran,
ADD CONSTRAINT fk_transaksi_slot 
  FOREIGN KEY (id_slot) REFERENCES parking_slots(id_slot) ON DELETE SET NULL;

-- Add index for slot lookups
CREATE INDEX idx_transaksi_slot ON transaksi_parkir(id_slot);
```

#### mall (Add feature flag)

```sql
ALTER TABLE mall
ADD COLUMN has_slot_reservation_enabled BOOLEAN DEFAULT FALSE AFTER status;

-- Add index for feature flag queries
CREATE INDEX idx_mall_slot_reservation ON mall(has_slot_reservation_enabled);
```

---

## Migration Scripts

### Complete Migration Script

Save as: `database/migrations/2025_12_05_add_slot_reservation.sql`

```sql
-- ============================================
-- Slot Reservation Feature Migration
-- Version: 2.0.0
-- Date: 2025-12-05
-- ============================================

START TRANSACTION;

-- 1. Create parking_floors table
CREATE TABLE IF NOT EXISTS parking_floors (
  id_floor VARCHAR(50) PRIMARY KEY,
  id_mall VARCHAR(50) NOT NULL,
  floor_number INT NOT NULL,
  floor_name VARCHAR(100) NOT NULL,
  total_slots INT NOT NULL DEFAULT 0,
  available_slots INT NOT NULL DEFAULT 0,
  occupied_slots INT NOT NULL DEFAULT 0,
  reserved_slots INT NOT NULL DEFAULT 0,
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (id_mall) REFERENCES mall(id_mall) ON DELETE CASCADE,
  INDEX idx_mall_floor (id_mall, floor_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Create parking_slots table
CREATE TABLE IF NOT EXISTS parking_slots (
  id_slot VARCHAR(50) PRIMARY KEY,
  id_floor VARCHAR(50) NOT NULL,
  slot_code VARCHAR(20) NOT NULL,
  status ENUM('available', 'occupied', 'reserved', 'disabled') DEFAULT 'available',
  slot_type ENUM('regular', 'disableFriendly') DEFAULT 'regular',
  position_x INT,
  position_y INT,
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (id_floor) REFERENCES parking_floors(id_floor) ON DELETE CASCADE,
  UNIQUE KEY unique_floor_slot (id_floor, slot_code),
  INDEX idx_floor_status (id_floor, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Create slot_reservations table
CREATE TABLE IF NOT EXISTS slot_reservations (
  reservation_id VARCHAR(50) PRIMARY KEY,
  id_slot VARCHAR(50) NOT NULL,
  id_user VARCHAR(50) NOT NULL,
  slot_code VARCHAR(20) NOT NULL,
  floor_name VARCHAR(100) NOT NULL,
  floor_number VARCHAR(10) NOT NULL,
  slot_type ENUM('regular', 'disableFriendly') DEFAULT 'regular',
  reserved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (id_slot) REFERENCES parking_slots(id_slot) ON DELETE CASCADE,
  FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE,
  INDEX idx_user_active (id_user, is_active),
  INDEX idx_slot_active (id_slot, is_active),
  INDEX idx_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Modify booking table
ALTER TABLE booking
ADD COLUMN id_slot VARCHAR(50) NULL AFTER id_kendaraan,
ADD COLUMN reservation_id VARCHAR(50) NULL AFTER id_slot;

ALTER TABLE booking
ADD CONSTRAINT fk_booking_slot 
  FOREIGN KEY (id_slot) REFERENCES parking_slots(id_slot) ON DELETE SET NULL;

CREATE INDEX idx_booking_slot ON booking(id_slot);

-- 5. Modify transaksi_parkir table
ALTER TABLE transaksi_parkir
ADD COLUMN id_slot VARCHAR(50) NULL AFTER id_parkiran;

ALTER TABLE transaksi_parkir
ADD CONSTRAINT fk_transaksi_slot 
  FOREIGN KEY (id_slot) REFERENCES parking_slots(id_slot) ON DELETE SET NULL;

CREATE INDEX idx_transaksi_slot ON transaksi_parkir(id_slot);

-- 6. Modify mall table (feature flag)
ALTER TABLE mall
ADD COLUMN has_slot_reservation_enabled BOOLEAN DEFAULT FALSE AFTER status;

CREATE INDEX idx_mall_slot_reservation ON mall(has_slot_reservation_enabled);

COMMIT;

-- ============================================
-- Migration completed successfully
-- ============================================
```

### Rollback Script

Save as: `database/migrations/2025_12_05_rollback_slot_reservation.sql`

```sql
-- ============================================
-- Slot Reservation Feature Rollback
-- Version: 2.0.0
-- Date: 2025-12-05
-- ============================================

START TRANSACTION;

-- 1. Remove foreign key constraints
ALTER TABLE booking DROP FOREIGN KEY IF EXISTS fk_booking_slot;
ALTER TABLE transaksi_parkir DROP FOREIGN KEY IF EXISTS fk_transaksi_slot;

-- 2. Remove indexes
DROP INDEX IF EXISTS idx_booking_slot ON booking;
DROP INDEX IF EXISTS idx_transaksi_slot ON transaksi_parkir;
DROP INDEX IF EXISTS idx_mall_slot_reservation ON mall;

-- 3. Remove columns from existing tables
ALTER TABLE booking DROP COLUMN IF EXISTS reservation_id;
ALTER TABLE booking DROP COLUMN IF EXISTS id_slot;
ALTER TABLE transaksi_parkir DROP COLUMN IF EXISTS id_slot;
ALTER TABLE mall DROP COLUMN IF EXISTS has_slot_reservation_enabled;

-- 4. Drop new tables (in reverse order of dependencies)
DROP TABLE IF EXISTS slot_reservations;
DROP TABLE IF EXISTS parking_slots;
DROP TABLE IF EXISTS parking_floors;

COMMIT;

-- ============================================
-- Rollback completed successfully
-- ============================================
```

---

## Backend API Changes

### New Endpoints

Add these endpoints to your Laravel backend:

#### 1. Get Parking Floors

**File:** `routes/api.php`

```php
Route::middleware('auth:api')->group(function () {
    Route::get('/parking/floors/{mallId}', [ParkingController::class, 'getFloors']);
});
```

**File:** `app/Http/Controllers/ParkingController.php`

```php
public function getFloors($mallId)
{
    $floors = ParkingFloor::where('id_mall', $mallId)
        ->orderBy('floor_number')
        ->get();
    
    return response()->json([
        'success' => true,
        'data' => $floors
    ]);
}
```

#### 2. Get Slots for Visualization

```php
Route::middleware('auth:api')->group(function () {
    Route::get('/parking/slots/{floorId}/visualization', [ParkingController::class, 'getSlotsForVisualization']);
});
```

```php
public function getSlotsForVisualization($floorId, Request $request)
{
    $query = ParkingSlot::where('id_floor', $floorId);
    
    if ($request->has('vehicle_type')) {
        // Filter by vehicle type if needed
        $query->where('vehicle_type', $request->vehicle_type);
    }
    
    $slots = $query->get();
    
    $floor = ParkingFloor::find($floorId);
    
    return response()->json([
        'success' => true,
        'data' => $slots,
        'meta' => [
            'total_slots' => $floor->total_slots,
            'available_slots' => $floor->available_slots,
            'occupied_slots' => $floor->occupied_slots,
            'reserved_slots' => $floor->reserved_slots,
        ]
    ]);
}
```

#### 3. Reserve Random Slot

```php
Route::middleware('auth:api')->group(function () {
    Route::post('/parking/slots/reserve-random', [ParkingController::class, 'reserveRandomSlot']);
});
```

```php
public function reserveRandomSlot(Request $request)
{
    $validated = $request->validate([
        'id_floor' => 'required|exists:parking_floors,id_floor',
        'id_user' => 'required|exists:users,id_user',
        'vehicle_type' => 'required|string',
        'duration_minutes' => 'integer|min:1|max:10'
    ]);
    
    $durationMinutes = $validated['duration_minutes'] ?? 5;
    
    // Find available slot
    $slot = ParkingSlot::where('id_floor', $validated['id_floor'])
        ->where('status', 'available')
        ->inRandomOrder()
        ->first();
    
    if (!$slot) {
        // Suggest alternative floors
        $alternativeFloors = ParkingFloor::where('id_mall', $floor->id_mall)
            ->where('id_floor', '!=', $validated['id_floor'])
            ->where('available_slots', '>', 0)
            ->orderBy('available_slots', 'desc')
            ->limit(3)
            ->get(['id_floor', 'floor_name', 'available_slots']);
        
        return response()->json([
            'success' => false,
            'message' => 'Tidak ada slot tersedia di lantai ini',
            'error_code' => 'NO_SLOTS_AVAILABLE',
            'data' => [
                'floor_id' => $validated['id_floor'],
                'suggested_floors' => $alternativeFloors
            ]
        ], 404);
    }
    
    // Check for existing active reservation
    $existingReservation = SlotReservation::where('id_user', $validated['id_user'])
        ->where('is_active', true)
        ->where('expires_at', '>', now())
        ->first();
    
    if ($existingReservation) {
        return response()->json([
            'success' => false,
            'message' => 'Anda sudah memiliki reservasi slot aktif',
            'error_code' => 'RESERVATION_CONFLICT',
            'data' => [
                'existing_reservation_id' => $existingReservation->reservation_id,
                'slot_code' => $existingReservation->slot_code,
                'expires_at' => $existingReservation->expires_at
            ]
        ], 409);
    }
    
    // Create reservation
    $reservation = SlotReservation::create([
        'reservation_id' => 'R' . time() . rand(1000, 9999),
        'id_slot' => $slot->id_slot,
        'id_user' => $validated['id_user'],
        'slot_code' => $slot->slot_code,
        'floor_name' => $slot->floor->floor_name,
        'floor_number' => $slot->floor->floor_number,
        'slot_type' => $slot->slot_type,
        'reserved_at' => now(),
        'expires_at' => now()->addMinutes($durationMinutes),
        'is_active' => true
    ]);
    
    // Update slot status
    $slot->update(['status' => 'reserved']);
    
    // Update floor counts
    $slot->floor->decrement('available_slots');
    $slot->floor->increment('reserved_slots');
    
    return response()->json([
        'success' => true,
        'message' => "Slot {$slot->slot_code} berhasil direservasi untuk {$durationMinutes} menit",
        'data' => $reservation
    ]);
}
```

#### 4. Update Create Booking Endpoint

Modify existing booking creation to support optional slot reservation:

```php
public function createBooking(Request $request)
{
    $validated = $request->validate([
        'id_mall' => 'required|exists:mall,id_mall',
        'id_kendaraan' => 'required|exists:kendaraan,id_kendaraan',
        'waktu_mulai' => 'required|date',
        'durasi_jam' => 'required|integer|min:1|max:12',
        'waktu_selesai' => 'required|date',
        'id_slot' => 'nullable|exists:parking_slots,id_slot',  // NEW: Optional
        'reservation_id' => 'nullable|exists:slot_reservations,reservation_id',  // NEW: Optional
        'notes' => 'nullable|string'
    ]);
    
    // If slot reservation provided, validate it
    if ($validated['id_slot'] && $validated['reservation_id']) {
        $reservation = SlotReservation::where('reservation_id', $validated['reservation_id'])
            ->where('id_slot', $validated['id_slot'])
            ->where('is_active', true)
            ->first();
        
        if (!$reservation) {
            return response()->json([
                'success' => false,
                'message' => 'Reservasi tidak ditemukan atau sudah tidak aktif',
                'error_code' => 'RESERVATION_NOT_FOUND'
            ], 404);
        }
        
        if ($reservation->expires_at < now()) {
            return response()->json([
                'success' => false,
                'message' => 'Reservasi slot telah berakhir. Silakan reservasi ulang.',
                'error_code' => 'RESERVATION_EXPIRED',
                'data' => [
                    'reservation_id' => $reservation->reservation_id,
                    'expired_at' => $reservation->expires_at
                ]
            ], 410);
        }
    }
    
    // Create booking (existing logic)
    $booking = Booking::create([
        // ... existing fields
        'id_slot' => $validated['id_slot'] ?? null,  // NEW
        'reservation_id' => $validated['reservation_id'] ?? null,  // NEW
    ]);
    
    // If slot was reserved, mark reservation as used and update slot status
    if ($validated['id_slot']) {
        if (isset($reservation)) {
            $reservation->update(['is_active' => false]);
        }
        
        $slot = ParkingSlot::find($validated['id_slot']);
        $slot->update(['status' => 'occupied']);
        
        // Update floor counts
        $slot->floor->decrement('reserved_slots');
        $slot->floor->increment('occupied_slots');
    }
    
    // Return booking with slot info
    return response()->json([
        'success' => true,
        'message' => 'Booking berhasil dibuat',
        'data' => [
            // ... existing fields
            'id_slot' => $booking->id_slot,
            'slot_code' => $booking->slot ? $booking->slot->slot_code : null,
            'floor_name' => $booking->slot ? $booking->slot->floor->floor_name : null,
        ]
    ]);
}
```

---

## Feature Flag Implementation

### 1. Enable Feature Per Mall

```php
// Enable slot reservation for specific mall
$mall = Mall::find('MALL001');
$mall->has_slot_reservation_enabled = true;
$mall->save();
```

### 2. Check Feature Flag in Mobile App

```dart
// In BookingProvider or BookingPage
bool get hasSlotReservationEnabled {
  return selectedMall?['has_slot_reservation_enabled'] == true;
}

// Conditional UI rendering
if (hasSlotReservationEnabled) {
  // Show floor selector and slot reservation UI
  FloorSelectorWidget(...);
} else {
  // Use legacy automatic slot assignment
  SlotAvailabilityIndicator(...);
}
```

### 3. Gradual Rollout Strategy

**Phase 1: Pilot (Week 1-2)**
- Enable for 1-2 test malls
- Monitor performance and user feedback
- Fix critical issues

**Phase 2: Limited Rollout (Week 3-4)**
- Enable for 25% of malls
- Continue monitoring
- Gather analytics

**Phase 3: Expanded Rollout (Week 5-6)**
- Enable for 50% of malls
- Optimize based on data
- Prepare for full rollout

**Phase 4: Full Rollout (Week 7+)**
- Enable for all malls
- Monitor system stability
- Provide user support

---

## Backward Compatibility

### How It Works

The system maintains backward compatibility by:

1. **Optional Fields:** `id_slot` and `reservation_id` are nullable in database
2. **Feature Flag:** Malls without the feature enabled use automatic assignment
3. **API Flexibility:** Booking endpoint accepts requests with or without slot info
4. **Fallback Logic:** If slot reservation fails, system falls back to automatic assignment

### Example: Booking Without Slot Reservation

```dart
// Old booking flow still works
final request = BookingRequest(
  idMall: 'MALL001',
  idKendaraan: 'VEH001',
  waktuMulai: DateTime.now().add(Duration(hours: 1)),
  durasiJam: 2,
  // No id_slot or reservation_id
);

// Backend automatically assigns available slot
final response = await bookingService.createBooking(
  request: request,
  token: authToken,
);
```

### Example: Booking With Slot Reservation

```dart
// New booking flow with slot reservation
final request = BookingRequest(
  idMall: 'MALL001',
  idKendaraan: 'VEH001',
  waktuMulai: DateTime.now().add(Duration(hours: 1)),
  durasiJam: 2,
  idSlot: 's15',  // NEW
  reservationId: 'r123',  // NEW
);

final response = await bookingService.createBooking(
  request: request,
  token: authToken,
);
```

---

## Data Seeding

### Sample Data for Testing

```sql
-- Insert sample floors
INSERT INTO parking_floors (id_floor, id_mall, floor_number, floor_name, total_slots, available_slots, occupied_slots, reserved_slots) VALUES
('F1_MALL001', 'MALL001', 1, 'Lantai 1', 50, 12, 35, 3),
('F2_MALL001', 'MALL001', 2, 'Lantai 2', 60, 25, 30, 5),
('F3_MALL001', 'MALL001', 3, 'Lantai 3', 55, 40, 10, 5);

-- Insert sample slots for Floor 1
INSERT INTO parking_slots (id_slot, id_floor, slot_code, status, slot_type, position_x, position_y) VALUES
('S1_F1', 'F1_MALL001', 'A01', 'available', 'regular', 0, 0),
('S2_F1', 'F1_MALL001', 'A02', 'occupied', 'regular', 1, 0),
('S3_F1', 'F1_MALL001', 'A03', 'available', 'disableFriendly', 2, 0),
('S4_F1', 'F1_MALL001', 'A04', 'reserved', 'regular', 3, 0),
('S5_F1', 'F1_MALL001', 'A05', 'available', 'regular', 4, 0);

-- Enable feature for test mall
UPDATE mall SET has_slot_reservation_enabled = TRUE WHERE id_mall = 'MALL001';
```

---

## Testing Checklist

### Database Migration Testing

- [ ] Run migration script on development database
- [ ] Verify all tables created successfully
- [ ] Check foreign key constraints
- [ ] Verify indexes created
- [ ] Test rollback script
- [ ] Restore from rollback and re-run migration

### API Testing

- [ ] Test GET /api/parking/floors/{mallId}
- [ ] Test GET /api/parking/slots/{floorId}/visualization
- [ ] Test POST /api/parking/slots/reserve-random
- [ ] Test updated POST /api/booking/create with slot info
- [ ] Test updated POST /api/booking/create without slot info (backward compatibility)
- [ ] Test reservation expiration handling
- [ ] Test no slots available scenario
- [ ] Test reservation conflict scenario

### Mobile App Testing

- [ ] Test floor selection UI
- [ ] Test slot visualization display
- [ ] Test random slot reservation
- [ ] Test reservation countdown timer
- [ ] Test booking with reserved slot
- [ ] Test booking without slot reservation (legacy flow)
- [ ] Test feature flag conditional rendering
- [ ] Test error handling for all scenarios

### Integration Testing

- [ ] Test complete booking flow with slot reservation
- [ ] Test slot status updates (available → reserved → occupied)
- [ ] Test floor availability count updates
- [ ] Test reservation expiration and cleanup
- [ ] Test concurrent reservations
- [ ] Test booking cancellation with slot release

---

## Monitoring and Rollback Plan

### Monitoring Metrics

Track these metrics after deployment:

1. **Adoption Rate:** % of bookings using slot reservation
2. **Reservation Success Rate:** % of successful slot reservations
3. **Reservation Expiration Rate:** % of reservations that expire
4. **API Performance:** Response times for new endpoints
5. **Error Rate:** Frequency of slot reservation errors
6. **User Satisfaction:** Feedback and ratings

### Rollback Triggers

Rollback if:

- Error rate > 5% for slot reservation endpoints
- API response time > 3 seconds
- Database performance degradation
- Critical bugs affecting booking flow
- User satisfaction drops significantly

### Rollback Procedure

1. **Disable Feature Flag:**
   ```sql
   UPDATE mall SET has_slot_reservation_enabled = FALSE;
   ```

2. **Monitor System:**
   - Verify bookings work with automatic assignment
   - Check error rates return to normal
   - Confirm user experience is stable

3. **Database Rollback (if needed):**
   ```bash
   mysql -u username -p database_name < database/migrations/2025_12_05_rollback_slot_reservation.sql
   ```

4. **Communicate:**
   - Notify users of temporary feature unavailability
   - Inform development team
   - Document issues for resolution

---

## Support and Documentation

### For Developers

- **API Documentation:** `qparkin_app/docs/booking_api_documentation.md`
- **Component Guide:** `qparkin_app/docs/booking_component_guide.md`
- **Design Document:** `.kiro/specs/booking-page-slot-selection-enhancement/design.md`

### For Users

- **User Guide:** `qparkin_app/docs/booking_user_guide.md`
- **FAQ:** See "Frequently Asked Questions" section in user guide
- **Support:** support@qparkin.com

### For Database Administrators

- **Migration Scripts:** `database/migrations/2025_12_05_add_slot_reservation.sql`
- **Rollback Scripts:** `database/migrations/2025_12_05_rollback_slot_reservation.sql`
- **Seeding Scripts:** See "Data Seeding" section above

---

## Changelog

### Version 2.0.0 (2025-12-05)

**Added:**
- Parking floor selection feature
- Visual slot availability display
- Random slot reservation system
- 5-minute slot reservation timeout
- Feature flag for gradual rollout
- New database tables: parking_floors, parking_slots, slot_reservations
- New API endpoints for floor and slot management
- Backward compatibility with v1.0 booking system

**Modified:**
- booking table: Added id_slot and reservation_id columns
- transaksi_parkir table: Added id_slot column
- mall table: Added has_slot_reservation_enabled flag
- Booking creation endpoint: Now supports optional slot reservation

**Deprecated:**
- None (v1.0 booking flow still supported)

---

## Contact

For migration support or questions:

- **Email:** dev-support@qparkin.com
- **Slack:** #qparkin-migration
- **Documentation:** https://docs.qparkin.com/migration

---

**Migration Guide Version:** 1.0  
**Last Updated:** December 5, 2025  
**Author:** QPARKIN Development Team
