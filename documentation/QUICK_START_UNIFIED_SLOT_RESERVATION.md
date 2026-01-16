# Quick Start: Unified Slot Reservation

## 🎯 What This Solves

**Problem:** User books parking at simple parking area, but when they arrive, parking is full → **OVERBOOKING**

**Solution:** ALL malls now use slot reservation internally to guarantee slots, but UI adapts to parking type.

## 🚀 Quick Setup (5 Minutes)

### Step 1: Run Setup Script

```bash
cd qparkin_backend
setup_unified_slot_reservation.bat
```

This will:
- ✅ Seed mall data with feature flags
- ✅ Create parking floors (multi-level vs simple)
- ✅ Create parking slots (descriptive vs generic)
- ✅ Run tests to verify

### Step 2: Verify Database

```sql
-- Check malls
SELECT id_mall, nama_mall, has_slot_reservation_enabled FROM mall;

-- Expected:
-- 1 | Mega Mall Batam Centre | 1 (multi-level)
-- 2 | One Batam Mall         | 1 (multi-level)
-- 3 | SNL Food Bengkong      | 0 (simple)

-- Check floors
SELECT m.nama_mall, f.floor_name, f.total_slots
FROM parking_floors f
JOIN parkiran p ON f.id_parkiran = p.id_parkiran
JOIN mall m ON p.id_mall = m.id_mall;

-- Expected:
-- Mega Mall: Lantai 1 Mobil, Lantai 2 Mobil
-- SNL Food: Parkiran Mobil

-- Check slots
SELECT m.nama_mall, s.slot_code
FROM parking_slots s
JOIN parking_floors f ON s.id_floor = f.id_floor
JOIN parkiran p ON f.id_parkiran = p.id_parkiran
JOIN mall m ON p.id_mall = m.id_mall
LIMIT 10;

-- Expected:
-- Mega Mall: A-001, A-002, B-001
-- SNL Food: SLOT-001, SLOT-002
```

### Step 3: Test API

```bash
# Test simple parking (auto-assign)
curl -X POST http://localhost:8000/api/bookings \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "id_parkiran": 3,
    "id_kendaraan": 5,
    "waktu_mulai": "2025-12-06 14:00:00",
    "durasi_booking": 2
  }'

# Response should include:
# {
#   "id_booking": 123,
#   "id_slot": 7,              ← Auto-assigned
#   "reservation_id": "AUTO-..." ← Auto-created
# }
```

### Step 4: Test Frontend

```bash
cd qparkin_app
flutter run

# Test Flow:
# 1. Select "SNL Food Bengkong"
# 2. UI should NOT show floor selector ✅
# 3. Book parking
# 4. Check Activity page → Should show booking with slot ✅
```

## 📊 How It Works

### Multi-Level Parking (Mega Mall, One Batam)

```
User Flow:
1. Select mall → UI shows floor selector
2. Select floor → UI shows slot visualization
3. Select slot → User picks A-015
4. Confirm → Backend reserves A-015
5. Arrive → Park at Lantai 2, slot A-015

Backend:
- Floors: Lantai 1, 2, Basement
- Slots: A-001, B-015, C-032
- Reservation: User-selected
- UI: Full visualization
```

### Simple Parking (SNL Food)

```
User Flow:
1. Select mall → UI hides floor selector
2. Select time → No slot selection needed
3. Confirm → Backend AUTO-ASSIGNS SLOT-007
4. Arrive → Petugas directs to slot

Backend:
- Floors: Parkiran Mobil (single)
- Slots: SLOT-001, SLOT-002, SLOT-003
- Reservation: Auto-assigned
- UI: Hidden (seamless)
```

### Key Difference

| Aspect | Multi-Level | Simple |
|--------|-------------|--------|
| **UI** | Shows floor/slot selector | Hides selector |
| **User Action** | Picks specific slot | Just books |
| **Backend** | Reserves user-selected slot | Auto-assigns slot |
| **Result** | Both guaranteed ✅ | Both guaranteed ✅ |

## 🧪 Testing Overbooking Prevention

### Test Scenario: 5 Slots, 6 Bookings

```bash
# Setup: Simple parking with 5 slots

# Booking 1-5: Should succeed
for i in {1..5}; do
  curl -X POST http://localhost:8000/api/bookings \
    -H "Authorization: Bearer {token}" \
    -d "id_parkiran=3&waktu_mulai=2025-12-06 14:00:00&durasi_booking=2"
done

# Booking 6: Should FAIL (no slots)
curl -X POST http://localhost:8000/api/bookings \
  -H "Authorization: Bearer {token}" \
  -d "id_parkiran=3&waktu_mulai=2025-12-06 14:00:00&durasi_booking=2"

# Expected response:
# {
#   "success": false,
#   "message": "NO_SLOTS_AVAILABLE",
#   "error": "Tidak ada slot tersedia untuk waktu yang dipilih"
# }
```

**Result:** ✅ Only 5 bookings accepted, all 5 users guaranteed slots

## 📁 Files Created

### Backend (5 files)

1. **SlotAutoAssignmentService.php** - Auto-assignment logic
2. **SlotAutoAssignmentServiceTest.php** - Unit tests
3. **UNIFIED_SLOT_RESERVATION_GUIDE.md** - Full documentation
4. **setup_unified_slot_reservation.bat** - Setup script
5. **Updated:** ParkingFloorSeeder.php, ParkingSlotSeeder.php, BookingController.php

### Documentation (2 files)

1. **UNIFIED_SLOT_RESERVATION_IMPLEMENTATION_SUMMARY.md** - Implementation details
2. **QUICK_START_UNIFIED_SLOT_RESERVATION.md** - This file

## 🔧 Troubleshooting

### Issue: "No slots available" but parking looks empty

**Solution:**
```bash
# Clean up expired reservations
php artisan reservations:cleanup

# Or manually:
DELETE FROM slot_reservations 
WHERE status = 'active' 
AND expires_at < NOW();
```

### Issue: Tests failing

**Solution:**
```bash
# Re-run migrations
php artisan migrate:fresh

# Re-seed data
php artisan db:seed --class=MallSeeder
php artisan db:seed --class=ParkingFloorSeeder
php artisan db:seed --class=ParkingSlotSeeder

# Run tests again
php artisan test tests/Unit/SlotAutoAssignmentServiceTest.php
```

### Issue: Frontend not showing changes

**Solution:**
```bash
cd qparkin_app
flutter clean
flutter pub get
flutter run
```

## 📚 Full Documentation

For detailed information, see:

- **Implementation Guide:** [UNIFIED_SLOT_RESERVATION_GUIDE.md](qparkin_backend/docs/UNIFIED_SLOT_RESERVATION_GUIDE.md)
- **Implementation Summary:** [UNIFIED_SLOT_RESERVATION_IMPLEMENTATION_SUMMARY.md](UNIFIED_SLOT_RESERVATION_IMPLEMENTATION_SUMMARY.md)
- **Feature Flag Guide:** [SLOT_RESERVATION_FEATURE_FLAG_GUIDE.md](qparkin_backend/docs/SLOT_RESERVATION_FEATURE_FLAG_GUIDE.md)

## ✅ Success Checklist

- [ ] Setup script ran successfully
- [ ] Database has correct mall/floor/slot data
- [ ] API test returns slot_id for simple parking
- [ ] Frontend hides floor selector for simple parking
- [ ] Unit tests pass
- [ ] Manual overbooking test prevents 6th booking
- [ ] Activity page shows slot information

## 🎉 Done!

Your system now prevents overbooking for ALL parking types while maintaining a clean UX for each type.

**Key Achievement:** Every booking is guaranteed a slot, whether user picks it or system assigns it.
