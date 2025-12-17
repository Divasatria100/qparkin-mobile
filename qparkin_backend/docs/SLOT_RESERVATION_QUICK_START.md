# Slot Reservation System - Quick Start Guide

## 🚀 Quick Setup (5 Minutes)

### 1. Run Migrations
```bash
cd qparkin_backend
php artisan migrate
```

### 2. Seed Sample Data
```bash
php artisan db:seed --class=ParkingFloorSeeder
php artisan db:seed --class=ParkingSlotSeeder
```

### 3. Enable Feature for a Mall
```sql
UPDATE mall SET has_slot_reservation_enabled = 1 WHERE id_mall = 1;
```

### 4. Verify Setup
```bash
php artisan tinker
```
```php
// Check floors
ParkingFloor::count();

// Check slots
ParkingSlot::count();

// Check mall feature flag
Mall::find(1)->has_slot_reservation_enabled;
```

## 📊 Database Structure Overview

```
mall (has_slot_reservation_enabled)
  └── parkiran
        └── parking_floors (lantai parkir)
              └── parking_slots (slot individual)
                    └── slot_reservations (reservasi 5 menit)
```

## 🔧 Common Operations

### Get Available Floors
```php
$floors = ParkingFloor::where('id_parkiran', $parkiranId)
    ->active()
    ->hasAvailableSlots()
    ->get();
```

### Get Available Slots for Floor
```php
$slots = ParkingSlot::where('id_floor', $floorId)
    ->available()
    ->forVehicleType('Roda Empat')
    ->get();
```

### Reserve Random Slot
```php
use App\Models\ParkingSlot;
use App\Models\SlotReservation;
use Illuminate\Support\Str;

// Find random available slot
$slot = ParkingSlot::where('id_floor', $floorId)
    ->available()
    ->forVehicleType($jenisKendaraan)
    ->inRandomOrder()
    ->first();

if ($slot) {
    // Mark as reserved
    $slot->markAsReserved();
    
    // Create reservation
    $reservation = SlotReservation::create([
        'id_slot' => $slot->id_slot,
        'id_user' => $userId,
        'id_kendaraan' => $kendaraanId,
        'id_floor' => $floorId,
        'status' => 'active',
        // reservation_id and expires_at auto-generated
    ]);
    
    return $reservation;
}
```

### Confirm Reservation (Create Booking)
```php
$reservation = SlotReservation::where('reservation_id', $reservationId)
    ->active()
    ->first();

if ($reservation && $reservation->isValid()) {
    // Create booking with slot
    $booking = Booking::create([
        'id_transaksi' => $transaksiId,
        'id_slot' => $reservation->id_slot,
        'reservation_id' => $reservation->reservation_id,
        // ... other fields
    ]);
    
    // Confirm reservation
    $reservation->confirm();
    
    // Mark slot as occupied
    $reservation->slot->markAsOccupied();
}
```

### Expire Old Reservations (Scheduled Job)
```php
// In app/Console/Kernel.php
$schedule->call(function () {
    SlotReservation::expired()->each(function ($reservation) {
        $reservation->expire();
    });
})->everyMinute();
```

## 🎯 Model Methods Cheat Sheet

### ParkingFloor
```php
$floor->slots                    // Get all slots
$floor->reservations             // Get all reservations
$floor->availabilityPercentage   // Get availability %
```

### ParkingSlot
```php
$slot->isAvailableForReservation()  // Check if available
$slot->markAsReserved()             // Mark as reserved
$slot->markAsOccupied()             // Mark as occupied
$slot->markAsAvailable()            // Mark as available
```

### SlotReservation
```php
$reservation->isExpired()        // Check if expired
$reservation->isValid()          // Check if still valid
$reservation->confirm()          // Confirm reservation
$reservation->cancel()           // Cancel reservation
$reservation->expire()           // Expire reservation
$reservation->remainingTime      // Get remaining seconds
```

## 🔍 Useful Queries

### Check Mall Feature Flag
```php
$mall = Mall::find($mallId);
if ($mall->has_slot_reservation_enabled) {
    // Show slot reservation UI
}
```

### Get Floor with Slot Count
```php
$floors = ParkingFloor::where('id_parkiran', $parkiranId)
    ->withCount(['slots', 'slots as available_slots_count' => function ($query) {
        $query->where('status', 'available');
    }])
    ->get();
```

### Get Active Reservations for User
```php
$reservations = SlotReservation::where('id_user', $userId)
    ->active()
    ->with(['slot', 'floor'])
    ->get();
```

### Find Slot by Code
```php
$slot = ParkingSlot::where('slot_code', 'A-101')->first();
```

## 🧪 Testing in Tinker

```bash
php artisan tinker
```

```php
// Create test floor
$floor = ParkingFloor::create([
    'id_parkiran' => 1,
    'floor_name' => 'Test Floor',
    'floor_number' => 1,
    'total_slots' => 10,
    'available_slots' => 10,
    'status' => 'active'
]);

// Create test slots
for ($i = 1; $i <= 10; $i++) {
    ParkingSlot::create([
        'id_floor' => $floor->id_floor,
        'slot_code' => "T-" . str_pad($i, 3, '0', STR_PAD_LEFT),
        'jenis_kendaraan' => 'Roda Empat',
        'status' => 'available'
    ]);
}

// Test reservation
$slot = ParkingSlot::where('id_floor', $floor->id_floor)->first();
$reservation = SlotReservation::create([
    'id_slot' => $slot->id_slot,
    'id_user' => 1,
    'id_kendaraan' => 1,
    'id_floor' => $floor->id_floor
]);

// Check reservation
$reservation->reservation_id;  // UUID
$reservation->expires_at;      // 5 minutes from now
$reservation->isValid();       // true
```

## 📝 API Endpoints (To Be Implemented)

### Get Floors
```
GET /api/parking/floors/{mallId}
Response: [
  {
    "id_floor": 1,
    "floor_name": "Lantai 1",
    "floor_number": 1,
    "total_slots": 50,
    "available_slots": 35,
    "availability_percentage": 70
  }
]
```

### Get Slot Visualization
```
GET /api/parking/slots/{floorId}/visualization?vehicle_type=Roda+Empat
Response: [
  {
    "id_slot": 1,
    "slot_code": "A-001",
    "status": "available",
    "position_x": 0,
    "position_y": 0
  }
]
```

### Reserve Random Slot
```
POST /api/parking/slots/reserve-random
Body: {
  "id_floor": 1,
  "id_user": 1,
  "id_kendaraan": 1,
  "jenis_kendaraan": "Roda Empat"
}
Response: {
  "reservation_id": "uuid-here",
  "slot_code": "A-025",
  "floor_name": "Lantai 1",
  "expires_at": "2025-12-05 10:35:00",
  "remaining_seconds": 300
}
```

### Create Booking with Slot
```
POST /api/booking
Body: {
  "id_user": 1,
  "id_kendaraan": 1,
  "id_mall": 1,
  "id_slot": 25,              // NEW
  "reservation_id": "uuid",   // NEW
  "waktu_mulai": "2025-12-05 10:00:00",
  "durasi_booking": 120
}
```

## 🐛 Troubleshooting

### No slots available
```php
// Check if slots exist
ParkingSlot::where('id_floor', $floorId)->count();

// Check slot status
ParkingSlot::where('id_floor', $floorId)
    ->groupBy('status')
    ->selectRaw('status, count(*) as count')
    ->get();
```

### Reservation expired
```php
// Check expiration
$reservation = SlotReservation::find($id);
$reservation->isExpired();  // true/false
$reservation->remainingTime; // seconds left

// Manually expire
$reservation->expire();
```

### Slot stuck in reserved
```php
// Find stuck slots
$stuckSlots = ParkingSlot::where('status', 'reserved')
    ->whereDoesntHave('reservations', function ($query) {
        $query->where('status', 'active');
    })
    ->get();

// Release them
$stuckSlots->each->markAsAvailable();
```

## 📚 Related Documentation

- Full Migration Guide: `docs/SLOT_RESERVATION_MIGRATION_GUIDE.md`
- Migration Summary: `SLOT_RESERVATION_MIGRATION_SUMMARY.md`
- Manual SQL Script: `database/migrations/manual_slot_reservation_migration.sql`

## 🎓 Next Steps

1. ✅ Migrations done
2. ⏳ Implement API endpoints (Task 15.3)
3. ⏳ Create controllers
4. ⏳ Add validation
5. ⏳ Write tests
6. ⏳ Update frontend

---

**Quick Help**: `php artisan tinker` → Test models interactively
**Rollback**: `php artisan migrate:rollback --step=6`
**Status**: `php artisan migrate:status`
