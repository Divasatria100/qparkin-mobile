# Booking Slot - Single Source of Truth Quick Reference

## Masalah
- Card "Slot Tidak Tersedia" terus muncul meskipun slot tersedia
- Label slot berubah dari "60" ke "0" saat pilih durasi
- Data tidak konsisten

## Root Cause
**Konflik data dari 2 sumber:**
1. `loadFloorsForVehicle()` → _availableSlots = 60 ✅
2. `checkAvailability()` → _availableSlots = 0 ❌ (menimpa nilai)

**Triggered by:**
- `setStartTime()` → `_debounceAvailabilityCheck()` ❌
- `setDuration()` → `_debounceAvailabilityCheck()` ❌

## Solusi
**Single Source of Truth: `loadFloorsForVehicle()` ONLY**

### Changes Made

#### 1. Removed `SlotUnavailableWidget`
```dart
// REMOVED: SlotUnavailableWidget - Caused data inconsistency
```

#### 2. Removed All `startPeriodicAvailabilityCheck()` Calls (UI)
```dart
// REMOVED: startPeriodicAvailabilityCheck
// Slot availability determined solely by loadFloorsForVehicle()
```

#### 3. Removed `_debounceAvailabilityCheck()` from Provider Methods
```dart
// In setStartTime():
// REMOVED: _debounceAvailabilityCheck
// Time selection does not affect slot availability

// In setDuration():
// REMOVED: _debounceAvailabilityCheck
// Duration selection does not affect slot availability
```

#### 4. Updated Refresh Logic
```dart
onRefresh: () {
  // Refresh floors data (single source of truth)
  provider.loadFloorsForVehicle(
    jenisKendaraan: jenisKendaraan,
    token: token,
  );
},
```

## Expected Behavior

### ✅ Correct Flow:
```
1. Select vehicle "Roda Dua"
   → loadFloorsForVehicle()
   → _availableSlots = 60

2. Select time
   → setStartTime() (NO checkAvailability)
   → _availableSlots = 60 (unchanged)

3. Select duration
   → setDuration() (NO checkAvailability)
   → _availableSlots = 60 (unchanged)

Result: Consistent "60 slot tersedia" ✅
```

### ❌ Old Flow (Fixed):
```
1. Select vehicle
   → _availableSlots = 60

2. Select duration
   → _debounceAvailabilityCheck()
   → checkAvailability()
   → _availableSlots = 0 (overwrites!)

Result: Inconsistent "0 slot tersedia" ❌
```

## Testing
```bash
# Run test script
test-booking-single-source-fix.bat

# Or run app
flutter run --dart-define=API_URL=http://192.168.0.101:8000
```

## Verification
- ✅ Slot value stays 60 (doesn't change to 0)
- ✅ No "Slot Tidak Tersedia" card
- ✅ No periodic API calls
- ✅ No checkAvailability() in debug log
- ✅ Refresh button reloads floors data

## Files Changed
- `qparkin_app/lib/logic/providers/booking_provider.dart` (2 methods)
- `qparkin_app/lib/presentation/screens/booking_page.dart` (~50 lines)

## Documentation
- Full details: `BOOKING_SLOT_FINAL_FIX_COMPLETE.md`
- Previous fixes: `BOOKING_SLOT_SINGLE_SOURCE_OF_TRUTH_FIX.md`
- Test script: `test-booking-single-source-fix.bat`
