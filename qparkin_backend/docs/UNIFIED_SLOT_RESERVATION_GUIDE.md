# Unified Slot Reservation Implementation Guide

## Overview

This guide explains the **Unified Slot Reservation** approach that prevents overbooking for ALL malls, regardless of whether they have multi-level parking or simple parking areas.

## Problem Statement

### Before Implementation

**Mall with Simple Parking (has_slot_reservation_enabled = false):**
```
1. User books at 14:00 → System checks: "10 slots available" ✅
2. Booking created WITHOUT slot reservation
3. User arrives at 14:00 → Parking is FULL ❌
4. Problem: Other users took the slots (walk-ins or other bookings)
5. Result: OVERBOOKING - User has booking but no guaranteed slot
```

**Risk:** User frustration, complaints, refunds, bad reviews

### After Implementation

**ALL Malls (both multi-level and simple):**
```
1. User books at 14:00 → System RESERVES a specific slot ✅
2. Slot is LOCKED for this booking
3. User arrives at 14:00 → Slot is GUARANTEED ✅
4. Result: NO OVERBOOKING - Every booking has a guaranteed slot
```

## Architecture

### Unified Approach

**Key Principle:** ALL malls use slot reservation internally, but UI behavior differs based on mall type.

#### Mall Type A: Multi-Level Parking (has_slot_reservation_enabled = true)

**User Experience:**
- ✅ User SEES floor selection UI
- ✅ User SEES slot visualization
- ✅ User CHOOSES specific slot (A-015, B-032, etc.)
- ✅ User knows exactly where to park

**Backend:**
- Floors: Multiple (Lantai 1, 2, 3, Basement, etc.)
- Slots: Descriptive codes (A-001, B-015, C-032)
- Reservation: User-selected slot
- Database: `slot_reservations` with user-chosen slot

**Example:** Mega Mall Batam Centre, One Batam Mall

#### Mall Type B: Simple Parking (has_slot_reservation_enabled = false)

**User Experience:**
- ❌ User DOESN'T SEE floor selection UI
- ❌ User DOESN'T SEE slot visualization
- ❌ User DOESN'T CHOOSE slot (system auto-assigns)
- ✅ User just books and arrives (simple flow)

**Backend:**
- Floors: Single generic floor ("Parkiran Motor", "Parkiran Mobil")
- Slots: Generic codes (SLOT-001, SLOT-002, SLOT-003)
- Reservation: System auto-assigns slot
- Database: `slot_reservations` with auto-assigned slot

**Example:** SNL Food Bengkong

### Database Schema

**Same schema for ALL malls:**

```sql
-- Parking Floors (all malls have this)
CREATE TABLE parking_floors (
    id_floor INT PRIMARY KEY,
    id_parkiran INT,
    floor_name VARCHAR(100),  -- "Lantai 1" or "Parkiran Motor"
    floor_number INT,
    total_slots INT,
    available_slots INT,
    status ENUM('active', 'inactive')
);

-- Parking Slots (all malls have this)
CREATE TABLE parking_slots (
    id_slot INT PRIMARY KEY,
    id_floor INT,
    slot_code VARCHAR(50),    -- "A-001" or "SLOT-001"
    jenis_kendaraan VARCHAR(50),
    status ENUM('available', 'reserved', 'occupied'),
    position_x INT,           -- NULL for simple parking
    position_y INT            -- NULL for simple parking
);

-- Slot Reservations (all malls use this)
CREATE TABLE slot_reservations (
    id_reservation INT PRIMARY KEY,
    reservation_id VARCHAR(100),  -- "USER-xxx" or "AUTO-xxx"
    id_slot INT,
    id_user INT,
    reserved_from DATETIME,
    reserved_until DATETIME,
    status ENUM('active', 'completed', 'cancelled', 'expired'),
    expires_at DATETIME
);

-- Bookings (all malls link to slots)
CREATE TABLE booking (
    id_booking INT PRIMARY KEY,
    id_transaksi INT,
    id_slot INT,              -- ALWAYS has slot_id
    id_floor INT,             -- ALWAYS has floor_id
    reservation_id VARCHAR(100),
    waktu_mulai DATETIME,
    waktu_selesai DATETIME,
    durasi_booking INT,
    status VARCHAR(50)
);
```

## Implementation Details

### 1. Database Seeding

#### ParkingFloorSeeder

```php
public function run(): void
{
    $parkirans = Parkiran::with('mall')->get();

    foreach ($parkirans as $parkiran) {
        $mall = $parkiran->mall;
        $hasSlotReservation = $mall && $mall->has_slot_reservation_enabled;
        
        if ($hasSlotReservation) {
            // MULTI-LEVEL: Multiple floors with descriptive names
            $floors = [
                ['floor_name' => 'Lantai 1 Mobil', 'total_slots' => 40],
                ['floor_name' => 'Lantai 2 Mobil', 'total_slots' => 40],
            ];
        } else {
            // SIMPLE: Single generic floor
            $floors = [
                ['floor_name' => 'Parkiran Mobil', 'total_slots' => 40],
            ];
        }
        
        // Create floors...
    }
}
```

#### ParkingSlotSeeder

```php
public function run(): void
{
    $floors = ParkingFloor::with('parkiran.mall')->get();

    foreach ($floors as $floor) {
        $mall = $floor->parkiran->mall;
        $hasSlotReservation = $mall && $mall->has_slot_reservation_enabled;
        
        if ($hasSlotReservation) {
            // MULTI-LEVEL: Descriptive codes (A-001, B-015)
            for ($i = 1; $i <= $totalSlots; $i++) {
                $slotCode = sprintf('%s-%03d', $prefix, $i);
                // Create with position_x, position_y for visualization
            }
        } else {
            // SIMPLE: Generic codes (SLOT-001, SLOT-002)
            for ($i = 1; $i <= $totalSlots; $i++) {
                $slotCode = sprintf('SLOT-%03d', $i);
                // Create without position (no visualization needed)
            }
        }
    }
}
```

### 2. Backend Service

#### SlotAutoAssignmentService

```php
class SlotAutoAssignmentService
{
    /**
     * Auto-assign a slot and create reservation
     * 
     * Prevents overbooking by:
     * 1. Finding available slot for the time period
     * 2. Creating reservation to lock the slot
     * 3. Updating slot status to 'reserved'
     */
    public function assignSlot(
        int $idParkiran,
        int $idKendaraan,
        int $idUser,
        string $waktuMulai,
        int $durasiBooking
    ): ?int {
        // Find slot that is:
        // - Available
        // - Correct vehicle type
        // - Not reserved during requested time
        
        $slot = $this->findAvailableSlot(...);
        
        if (!$slot) {
            return null; // No slots available
        }
        
        // Create reservation to lock the slot
        $reservation = SlotReservation::create([
            'reservation_id' => 'AUTO-' . uniqid(),
            'id_slot' => $slot->id_slot,
            'id_user' => $idUser,
            'reserved_from' => $waktuMulai,
            'reserved_until' => $waktuSelesai,
            'status' => 'active',
        ]);
        
        // Update slot status
        $slot->status = 'reserved';
        $slot->save();
        
        return $slot->id_slot;
    }
}
```

### 3. Booking Controller

```php
public function store(Request $request)
{
    $idSlot = $request->id_slot;
    $reservationId = $request->reservation_id;
    
    // If user provided slot (multi-level parking)
    if ($reservationId) {
        $reservation = SlotReservation::find($reservationId);
        $idSlot = $reservation->id_slot;
    }
    
    // If no slot provided (simple parking)
    if (!$idSlot) {
        // AUTO-ASSIGN with reservation
        $idSlot = $this->autoAssignSlot(
            $request->id_parkiran,
            $request->id_kendaraan,
            $request->waktu_mulai,
            $request->durasi_booking
        );
        
        if (!$idSlot) {
            return response()->json([
                'error' => 'Tidak ada slot tersedia'
            ], 404);
        }
    }
    
    // Create booking with GUARANTEED slot
    $booking = Booking::create([
        'id_slot' => $idSlot,  // ALWAYS has slot
        // ... other fields
    ]);
}
```

### 4. Frontend Behavior

#### BookingPage (Flutter)

```dart
Widget _buildSlotReservationSection(BookingProvider provider) {
  // Hide UI for simple parking
  if (!provider.isSlotReservationEnabled) {
    return const SizedBox.shrink();
  }
  
  // Show UI for multi-level parking
  return Column(
    children: [
      FloorSelectorWidget(...),
      SlotVisualizationWidget(...),
      SlotReservationButton(...),
    ],
  );
}
```

#### BookingProvider (Flutter)

```dart
Future<bool> confirmBooking({required String token}) async {
  final requestData = {
    'id_parkiran': selectedMall['id_parkiran'],
    'id_kendaraan': selectedVehicle['id_kendaraan'],
    'waktu_mulai': startTime.toIso8601String(),
    'durasi_booking': bookingDuration.inHours,
  };
  
  // Add slot info if user selected one (multi-level)
  if (hasReservedSlot) {
    requestData['id_slot'] = reservedSlot.slotId;
    requestData['reservation_id'] = reservedSlot.reservationId;
  }
  // If no slot, backend will auto-assign (simple parking)
  
  final response = await bookingService.createBooking(requestData, token);
  return response.success;
}
```

## Benefits

### 1. No Overbooking

**Before:**
- Simple parking: 10 bookings, only 8 slots → 2 users disappointed ❌

**After:**
- Simple parking: 10 bookings attempted, only 8 accepted → All 8 users guaranteed ✅

### 2. Consistent Backend

- Same database schema for all malls
- Same reservation logic for all malls
- Same slot locking mechanism for all malls
- Easier to maintain and debug

### 3. Flexible UX

- Multi-level: Rich UI with floor/slot selection
- Simple: Clean UI without unnecessary complexity
- Both: Guaranteed slot availability

### 4. Scalable

- Easy to add new malls (just set feature flag)
- Easy to upgrade simple parking to multi-level (just change flag and add floors)
- Easy to test (same logic everywhere)

## Testing

### Test Scenario 1: Multi-Level Parking

```
1. User selects "Mega Mall Batam Centre"
2. UI shows floor selector ✅
3. User selects "Lantai 2"
4. UI shows slot visualization ✅
5. User reserves slot B-015
6. Booking created with slot B-015 ✅
7. User arrives → Parks at Lantai 2, slot B-015 ✅
```

### Test Scenario 2: Simple Parking

```
1. User selects "SNL Food Bengkong"
2. UI hides floor selector ✅
3. User selects time and duration
4. User confirms booking
5. Backend auto-assigns SLOT-007 (user doesn't see this) ✅
6. Booking created with slot SLOT-007 ✅
7. User arrives → Petugas directs to available slot ✅
```

### Test Scenario 3: Overbooking Prevention

```
Simple Parking with 5 slots:

1. User A books 14:00-16:00 → SLOT-001 assigned ✅
2. User B books 14:00-16:00 → SLOT-002 assigned ✅
3. User C books 14:00-16:00 → SLOT-003 assigned ✅
4. User D books 14:00-16:00 → SLOT-004 assigned ✅
5. User E books 14:00-16:00 → SLOT-005 assigned ✅
6. User F books 14:00-16:00 → ERROR: No slots available ❌

Result: Only 5 bookings accepted, all 5 users guaranteed ✅
```

## Setup Instructions

### 1. Run Migrations

```bash
php artisan migrate
```

### 2. Seed Mall Data

```bash
php artisan db:seed --class=MallSeeder
```

### 3. Seed Parking Data

```bash
php artisan db:seed --class=ParkingFloorSeeder
php artisan db:seed --class=ParkingSlotSeeder
```

### 4. Verify Setup

```sql
-- Check malls
SELECT id_mall, nama_mall, has_slot_reservation_enabled FROM mall;

-- Check floors
SELECT f.floor_name, f.total_slots, m.nama_mall, m.has_slot_reservation_enabled
FROM parking_floors f
JOIN parkiran p ON f.id_parkiran = p.id_parkiran
JOIN mall m ON p.id_mall = m.id_mall;

-- Check slots
SELECT s.slot_code, f.floor_name, m.nama_mall
FROM parking_slots s
JOIN parking_floors f ON s.id_floor = f.id_floor
JOIN parkiran p ON f.id_parkiran = p.id_parkiran
JOIN mall m ON p.id_mall = m.id_mall
LIMIT 20;
```

## API Examples

### Create Booking (Multi-Level)

```http
POST /api/bookings
Authorization: Bearer {token}

{
  "id_parkiran": 1,
  "id_kendaraan": 5,
  "waktu_mulai": "2025-12-06 14:00:00",
  "durasi_booking": 2,
  "id_slot": 15,
  "reservation_id": "USER-abc123"
}
```

### Create Booking (Simple - Auto-Assign)

```http
POST /api/bookings
Authorization: Bearer {token}

{
  "id_parkiran": 3,
  "id_kendaraan": 5,
  "waktu_mulai": "2025-12-06 14:00:00",
  "durasi_booking": 2
  // No id_slot or reservation_id
  // Backend will auto-assign
}
```

## Troubleshooting

### Issue: "No slots available" but parking looks empty

**Check:**
```sql
-- See all reservations
SELECT * FROM slot_reservations 
WHERE status = 'active' 
AND reserved_from <= NOW() 
AND reserved_until >= NOW();

-- See slot status
SELECT status, COUNT(*) 
FROM parking_slots 
GROUP BY status;
```

**Solution:**
- Expired reservations not cleaned up
- Run: `php artisan reservations:cleanup`

### Issue: Overbooking still happening

**Check:**
- Is auto-assignment service being used?
- Are reservations being created?
- Is slot status being updated?

**Debug:**
```php
Log::info('Auto-assigning slot', [
    'parkiran' => $idParkiran,
    'vehicle' => $idKendaraan,
    'time' => $waktuMulai,
]);
```

## Related Files

### Backend
- `app/Services/SlotAutoAssignmentService.php`
- `app/Http/Controllers/Api/BookingController.php`
- `database/seeders/ParkingFloorSeeder.php`
- `database/seeders/ParkingSlotSeeder.php`

### Frontend
- `lib/logic/providers/booking_provider.dart`
- `lib/presentation/screens/booking_page.dart`

## References

- [Slot Reservation Architecture](SLOT_RESERVATION_ARCHITECTURE.md)
- [Slot Reservation API](SLOT_RESERVATION_API.md)
- [Feature Flag Guide](SLOT_RESERVATION_FEATURE_FLAG_GUIDE.md)
