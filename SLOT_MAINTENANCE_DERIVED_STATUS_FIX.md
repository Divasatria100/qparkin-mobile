# Slot Maintenance Derived Status Fix

## Problem Statement

**Issue:** Slots under maintenance floors were still displaying as "Available" instead of "Maintenance"

### Current State (BEFORE FIX):
- ✅ `parking_floors.status = 'maintenance'` (Database correct)
- ✅ `parking_slots.status = 'available'` (Database correct - NOT changed)
- ✅ UI lantai menampilkan "Maintenance" badge (Floor display correct)
- ❌ UI slot masih menampilkan "Available" (Slot display WRONG)
- ❌ Filter "Maintenance" tidak menampilkan apa pun (Filter WRONG)

### Root Cause Analysis

**The Problem:**
Maintenance is a **FLOOR STATE**, not a **SLOT STATE**. The slot status in the database should remain as `available`, `occupied`, or `reserved`. However, the **DISPLAY STATUS** must be **DERIVED** from the parent floor's status.

**Technical Root Cause:**
The Blade view was directly displaying `$slot->status` without checking the parent `$floor->status`. This caused:
1. Slots to show their database status (`available`) instead of derived status (`maintenance`)
2. Filter to search for `slot.status == 'maintenance'` which doesn't exist in the database

---

## Solution: Derived Status Pattern

### Architecture Principle

```
Database Layer (Source of Truth):
├── parking_floors.status = 'maintenance'  ← Floor state
└── parking_slots.status = 'available'     ← Slot state (unchanged)

Display Layer (Derived):
└── displayStatus = floor.status == 'maintenance' ? 'maintenance' : slot.status
```

### Implementation

#### 1. Blade View - Derive Display Status

**File:** `qparkin_backend/resources/views/admin/detail-parkiran.blade.php`

**BEFORE:**
```blade
<div class="slot-grid" id="slotGrid">
    @foreach($parkiran->floors as $floor)
        @foreach($floor->slots as $slot)
        <div class="slot-item {{ $slot->status }}" 
             data-floor="{{ $floor->id_floor }}" 
             data-status="{{ $slot->status }}">
            <div class="slot-code">{{ $slot->slot_code }}</div>
            <div class="slot-status">{{ ucfirst($slot->status) }}</div>
        </div>
        @endforeach
    @endforeach
</div>
```

**AFTER:**
```blade
<div class="slot-grid" id="slotGrid">
    @foreach($parkiran->floors as $floor)
        @foreach($floor->slots as $slot)
        @php
            // Derive display status from parent floor
            $displayStatus = $floor->status == 'maintenance' ? 'maintenance' : $slot->status;
            $displayStatusText = $floor->status == 'maintenance' ? 'Maintenance' : ucfirst($slot->status);
        @endphp
        <div class="slot-item {{ $displayStatus }}" 
             data-floor="{{ $floor->id_floor }}" 
             data-status="{{ $displayStatus }}" 
             data-floor-status="{{ $floor->status }}">
            <div class="slot-code">{{ $slot->slot_code }}</div>
            <div class="slot-status">{{ $displayStatusText }}</div>
        </div>
        @endforeach
    @endforeach
</div>
```

**Key Changes:**
1. Added `@php` block to derive display status
2. `$displayStatus` checks floor status first, then falls back to slot status
3. `data-status` now contains derived status (for filtering)
4. Added `data-floor-status` for debugging/reference
5. CSS class uses `$displayStatus` (for styling)
6. Display text uses `$displayStatusText` (for UI)

#### 2. JavaScript Filter - Use Derived Status

**BEFORE:**
```javascript
function filterSlots() {
    const selectedFloor = filterLantai.value;
    const selectedStatus = filterStatus.value;

    slots.forEach(slot => {
        const floorMatch = selectedFloor === 'all' || slot.dataset.floor === selectedFloor;
        const statusMatch = selectedStatus === 'all' || slot.dataset.status === selectedStatus;

        if (floorMatch && statusMatch) {
            slot.style.display = 'flex';
        } else {
            slot.style.display = 'none';
        }
    });
}
```

**AFTER:**
```javascript
function filterSlots() {
    const selectedFloor = filterLantai.value;
    const selectedStatus = filterStatus.value;

    slots.forEach(slot => {
        const floorMatch = selectedFloor === 'all' || slot.dataset.floor === selectedFloor;
        // Use the derived display status (which includes floor maintenance)
        const displayStatus = slot.dataset.status;
        const statusMatch = selectedStatus === 'all' || displayStatus === selectedStatus;

        if (floorMatch && statusMatch) {
            slot.style.display = 'flex';
        } else {
            slot.style.display = 'none';
        }
    });
}
```

**Key Changes:**
1. Added comment explaining we use derived status
2. Filter now works with `data-status` which contains derived value
3. When user selects "Maintenance" filter, it will show all slots where `displayStatus == 'maintenance'`

---

## Verification Checklist

### ✅ Database Layer (NO CHANGES)
- [ ] `parking_floors.status` can be 'active', 'maintenance', or 'inactive'
- [ ] `parking_slots.status` remains 'available', 'occupied', 'reserved', or 'maintenance'
- [ ] NO database migrations required
- [ ] NO slot status updates in database

### ✅ Controller Layer (NO CHANGES)
- [ ] `detailParkiran()` already uses eager loading: `Parkiran::with(['floors.slots'])`
- [ ] Controller passes floor status to view correctly
- [ ] NO controller changes required

### ✅ View Layer (FIXED)
- [ ] Slots under maintenance floors display "Maintenance" status
- [ ] Slots under active floors display their actual status (available/occupied/reserved)
- [ ] CSS styling applies correctly (gray background for maintenance)
- [ ] Slot items have correct `data-status` attribute with derived value

### ✅ Filter Functionality (FIXED)
- [ ] Filter "Maintenance" shows all slots where parent floor is maintenance
- [ ] Filter "Available" shows only slots that are available AND floor is active
- [ ] Filter "Occupied" shows only occupied slots (regardless of floor status)
- [ ] Filter "All" shows all slots with their derived status

### ✅ User Experience
- [ ] Admin can see which slots are unavailable due to floor maintenance
- [ ] Visual distinction between maintenance (floor-level) and occupied (slot-level)
- [ ] Filter provides accurate results based on derived status
- [ ] No confusion between database state and display state

---

## Testing Scenarios

### Scenario 1: Floor in Maintenance
**Setup:**
- Floor 1: status = 'maintenance'
- Slot A1-001: status = 'available' (in database)
- Slot A1-002: status = 'occupied' (in database)

**Expected Display:**
- Slot A1-001: Shows "Maintenance" (derived from floor)
- Slot A1-002: Shows "Maintenance" (derived from floor, overrides occupied)

**Filter "Maintenance":**
- Should show: A1-001, A1-002

### Scenario 2: Floor Active
**Setup:**
- Floor 2: status = 'active'
- Slot A2-001: status = 'available'
- Slot A2-002: status = 'occupied'

**Expected Display:**
- Slot A2-001: Shows "Available" (from slot status)
- Slot A2-002: Shows "Occupied" (from slot status)

**Filter "Maintenance":**
- Should NOT show: A2-001, A2-002

### Scenario 3: Mixed Floors
**Setup:**
- Floor 1: status = 'maintenance' (20 slots)
- Floor 2: status = 'active' (20 slots, 10 available, 10 occupied)

**Filter "Maintenance":**
- Should show: All 20 slots from Floor 1

**Filter "Available":**
- Should show: Only 10 available slots from Floor 2 (NOT Floor 1)

---

## Code Flow Diagram

```
User Views Detail Parkiran Page
         ↓
Controller: detailParkiran($id)
         ↓
Eager Load: Parkiran::with(['floors.slots'])
         ↓
Pass to Blade View
         ↓
Blade Loop: @foreach floors → @foreach slots
         ↓
Derive Status: 
    if (floor.status == 'maintenance')
        displayStatus = 'maintenance'
    else
        displayStatus = slot.status
         ↓
Render HTML:
    <div class="slot-item {{ displayStatus }}"
         data-status="{{ displayStatus }}">
         ↓
JavaScript Filter:
    Filter by data-status (derived value)
         ↓
User Sees Correct Status
```

---

## Benefits of This Approach

### 1. **Data Integrity**
- Database remains clean and normalized
- Slot status reflects actual slot state
- Floor status reflects floor operational state
- No redundant data

### 2. **Flexibility**
- Easy to change floor status without touching slots
- Slot status preserved when floor returns from maintenance
- Can add more floor states without database changes

### 3. **Performance**
- No database updates required when changing floor status
- Derivation happens at display time (minimal overhead)
- Eager loading prevents N+1 queries

### 4. **Maintainability**
- Clear separation of concerns (floor state vs slot state)
- Display logic centralized in view layer
- Easy to understand and debug

### 5. **User Experience**
- Accurate visual representation
- Filters work as expected
- No confusion about slot availability

---

## What We DID NOT Change

### ❌ Database
- NO changes to `parking_slots` table
- NO changes to `parking_floors` table
- NO migrations required
- NO slot status updates

### ❌ Controller
- NO changes to `AdminController.php`
- Eager loading already correct
- NO API changes

### ❌ API Contract
- NO changes to booking API
- NO changes to slot reservation logic
- Booking API already filters by `floor.status = 'active'`

### ❌ Flutter App
- NO changes to `booking_page.dart`
- NO changes to mobile app
- API contract unchanged

---

## Files Modified

### 1. Blade View
**File:** `qparkin_backend/resources/views/admin/detail-parkiran.blade.php`

**Changes:**
- Added `@php` block to derive display status
- Updated slot item rendering to use derived status
- Updated JavaScript filter to use derived status

**Lines Changed:** ~3 sections (slot grid rendering, filter logic, console log)

---

## Conclusion

This fix implements the **Derived Status Pattern** where:
- **Database** stores the source of truth (floor status + slot status)
- **Display Layer** derives the effective status for UI
- **Filter Logic** works with derived status

**Result:**
- ✅ Slots under maintenance floors now show "Maintenance"
- ✅ Filter "Maintenance" now works correctly
- ✅ No database changes required
- ✅ No API contract changes
- ✅ No Flutter app changes
- ✅ Clean separation of concerns

**Status:** ✅ COMPLETE - Ready for testing
**Date:** January 3, 2026
**Impact:** Display layer only (minimal risk)
