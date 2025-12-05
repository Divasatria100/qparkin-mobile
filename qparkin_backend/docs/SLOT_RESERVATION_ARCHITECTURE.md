# Slot Reservation System - Architecture Overview

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Flutter Mobile App                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │ Floor Select │→ │ Slot Visual  │→ │ Reserve Random Slot  │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
└────────────────────────────┬────────────────────────────────────┘
                             │ HTTP/JSON API
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│                      Laravel Backend API                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    API Controllers                        │  │
│  │  • ParkingFloorController                                │  │
│  │  • ParkingSlotController                                 │  │
│  │  • SlotReservationController                             │  │
│  │  • BookingController (updated)                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                             ↓                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   Business Services                       │  │
│  │  • SlotReservationService                                │  │
│  │  • SlotVisualizationService                              │  │
│  └──────────────────────────────────────────────────────────┘  │
│                             ↓                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   Eloquent Models                         │  │
│  │  • ParkingFloor                                          │  │
│  │  • ParkingSlot                                           │  │
│  │  • SlotReservation                                       │  │
│  │  • Booking (updated)                                     │  │
│  │  • TransaksiParkir (updated)                             │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│                        MySQL Database                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │ parking_     │→ │ parking_     │→ │ slot_reservations    │  │
│  │ floors       │  │ slots        │  │ (5 min timeout)      │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
│         ↑                  ↑                    ↑                │
│         └──────────────────┴────────────────────┘                │
│                            │                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │ booking      │  │ transaksi_   │  │ mall (feature flag)  │  │
│  │ (updated)    │  │ parkir       │  │                      │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Data Flow

### 1. Floor Selection Flow

```
User Opens Booking Page
         ↓
App checks mall.has_slot_reservation_enabled
         ↓
    [Enabled?]
    ↙        ↘
  YES         NO
   ↓           ↓
GET /api/parking/floors/{mallId}    Use old booking flow
   ↓
Display floor list with availability
   ↓
User selects floor
```

### 2. Slot Visualization Flow

```
User selects floor
         ↓
GET /api/parking/slots/{floorId}/visualization?vehicle_type=X
         ↓
Backend queries parking_slots
         ↓
Filter by: id_floor, jenis_kendaraan, status
         ↓
Return slot grid data (display only, non-interactive)
         ↓
App shows slot visualization
         ↓
Auto-refresh every 15 seconds
```

### 3. Slot Reservation Flow

```
User clicks "Pesan Slot Acak"
         ↓
POST /api/parking/slots/reserve-random
Body: {
  id_floor: 1,
  id_user: 1,
  id_kendaraan: 1,
  jenis_kendaraan: "Roda Empat"
}
         ↓
Backend finds random available slot
         ↓
BEGIN TRANSACTION
  ├─ Mark slot as 'reserved'
  ├─ Create slot_reservation record
  │  ├─ Generate UUID
  │  ├─ Set expires_at = now + 5 minutes
  │  └─ Status = 'active'
  └─ Update floor.available_slots -= 1
COMMIT
         ↓
Return reservation details
{
  reservation_id: "uuid",
  slot_code: "A-025",
  floor_name: "Lantai 1",
  expires_at: "2025-12-05 10:35:00",
  remaining_seconds: 300
}
         ↓
App shows ReservedSlotInfoCard
         ↓
Start 5-minute countdown timer
```

### 4. Booking Confirmation Flow

```
User fills time & duration
         ↓
User clicks "Konfirmasi Booking"
         ↓
POST /api/booking
Body: {
  id_user: 1,
  id_kendaraan: 1,
  id_mall: 1,
  id_slot: 25,              ← NEW
  reservation_id: "uuid",   ← NEW
  waktu_mulai: "...",
  durasi_booking: 120
}
         ↓
Backend validates reservation
  ├─ Check reservation exists
  ├─ Check not expired
  └─ Check belongs to user
         ↓
    [Valid?]
    ↙        ↘
  YES         NO
   ↓           ↓
BEGIN TRANSACTION          Return error
  ├─ Create transaksi_parkir (with id_slot)
  ├─ Create booking (with id_slot, reservation_id)
  ├─ Update reservation.status = 'confirmed'
  ├─ Update reservation.confirmed_at = now
  └─ Update slot.status = 'occupied'
COMMIT
   ↓
Return booking confirmation
   ↓
Show QR code with slot info
```

### 5. Reservation Expiration Flow

```
Scheduled Job runs every minute
         ↓
Find reservations where:
  - status = 'active'
  - expires_at <= now
         ↓
For each expired reservation:
  BEGIN TRANSACTION
    ├─ Update reservation.status = 'expired'
    ├─ Update slot.status = 'available'
    └─ Update floor.available_slots += 1
  COMMIT
         ↓
Send notification to user (optional)
```

---

## 🗄️ Database Relationships

```
mall
 ├─ has_slot_reservation_enabled (boolean)
 └─ parkiran (1:N)
      ├─ jenis_kendaraan
      ├─ kapasitas (total capacity)
      └─ parking_floors (1:N)
           ├─ floor_name
           ├─ floor_number
           ├─ total_slots
           ├─ available_slots
           └─ parking_slots (1:N)
                ├─ slot_code (unique)
                ├─ jenis_kendaraan
                ├─ status (available/occupied/reserved/maintenance)
                ├─ position_x, position_y
                └─ slot_reservations (1:N)
                     ├─ reservation_id (UUID)
                     ├─ id_user (FK)
                     ├─ id_kendaraan (FK)
                     ├─ status (active/confirmed/expired/cancelled)
                     ├─ reserved_at
                     ├─ expires_at (reserved_at + 5 min)
                     └─ confirmed_at

booking
 ├─ id_transaksi (PK, FK to transaksi_parkir)
 ├─ id_slot (FK to parking_slots) ← NEW
 ├─ reservation_id (UUID) ← NEW
 └─ ... (existing fields)

transaksi_parkir
 ├─ id_transaksi (PK)
 ├─ id_slot (FK to parking_slots) ← NEW
 └─ ... (existing fields)
```

---

## 🔐 Security & Validation

### API Authentication
```
All endpoints require: auth:sanctum middleware
User must be authenticated with valid token
```

### Validation Rules

#### Reserve Slot
```php
- id_floor: required, exists:parking_floors
- id_user: required, exists:user
- id_kendaraan: required, exists:kendaraan, belongs to user
- jenis_kendaraan: required, enum
- Floor must be active
- Floor must have available slots
- User must not have active reservation
- Vehicle type must match floor
```

#### Create Booking
```php
- id_slot: nullable, exists:parking_slots
- reservation_id: nullable, exists:slot_reservations
- If provided:
  - Reservation must exist
  - Reservation must not be expired
  - Reservation must belong to user
  - Slot must match reservation
```

---

## ⚡ Performance Optimizations

### Caching Strategy
```
Floor Data:
  - Cache key: "parking_floors:{mallId}"
  - TTL: 5 minutes
  - Invalidate on: floor update, slot status change

Slot Visualization:
  - Cache key: "parking_slots:{floorId}:{vehicleType}"
  - TTL: 2 minutes
  - Invalidate on: slot status change
```

### Database Indexes
```sql
-- Composite indexes for common queries
parking_slots: (id_floor, status)
parking_slots: (id_floor, jenis_kendaraan, status)
slot_reservations: (status, expires_at)
slot_reservations: (id_user, status)
```

### Query Optimization
```php
// Eager loading
ParkingFloor::with(['slots', 'parkiran.mall'])->get();

// Select only needed columns
ParkingSlot::select('id_slot', 'slot_code', 'status')->get();

// Use database transactions for atomic operations
DB::transaction(function () {
    // Reserve slot operations
});
```

---

## 🔄 State Transitions

### Slot Status
```
available → reserved → occupied → available
    ↓           ↓
    └─────→ maintenance
```

### Reservation Status
```
active → confirmed
   ↓         ↓
   ↓      (booking created)
   ↓
   ├→ expired (timeout)
   └→ cancelled (user action)
```

---

## 🎯 Feature Flag Logic

```php
// Check if mall has slot reservation enabled
$mall = Mall::find($mallId);

if ($mall->has_slot_reservation_enabled) {
    // Show slot reservation UI
    // Use new booking flow with slots
} else {
    // Show old booking UI
    // Use old booking flow (capacity-based)
}
```

---

## 🧪 Testing Strategy

### Unit Tests
- Model methods (markAsReserved, isExpired, etc.)
- Service methods (findAvailableSlot, reserveSlot)
- Validation rules

### Feature Tests
- API endpoints (GET floors, POST reserve, etc.)
- Authentication & authorization
- Error responses

### Integration Tests
- Complete booking flow with slot
- Reservation expiration
- Concurrent reservations
- Backward compatibility

---

## 📊 Monitoring & Logging

### Key Metrics
- Reservation success rate
- Average reservation time
- Slot utilization rate
- Expiration rate
- API response times

### Logs
```php
// Log reservation creation
Log::info('Slot reserved', [
    'reservation_id' => $reservation->reservation_id,
    'slot_code' => $slot->slot_code,
    'user_id' => $userId
]);

// Log expiration
Log::warning('Reservation expired', [
    'reservation_id' => $reservation->reservation_id,
    'slot_code' => $slot->slot_code
]);
```

---

## 🚀 Deployment Strategy

### Phase 1: Database Migration
- Run migrations on staging
- Test with sample data
- Verify rollback procedure

### Phase 2: API Implementation
- Deploy API endpoints
- Test with Postman
- Enable for test mall only

### Phase 3: Gradual Rollout
- Enable for 1 mall
- Monitor for 1 week
- Enable for more malls gradually

### Phase 4: Full Rollout
- Enable for all malls
- Monitor performance
- Gather user feedback

---

## 📚 Related Documentation

- [Migration Guide](SLOT_RESERVATION_MIGRATION_GUIDE.md)
- [Quick Start Guide](SLOT_RESERVATION_QUICK_START.md)
- [API Implementation Checklist](TASK_15_3_API_IMPLEMENTATION_CHECKLIST.md)
- [Completion Report](../TASK_15_COMPLETION_REPORT.md)

---

**Version**: 1.0.0  
**Last Updated**: December 5, 2025
