# 🔧 Parkiran Status Maintenance - Root Cause Analysis & Fix

**Date:** 2025-01-03  
**Status:** ⚠️ CRITICAL - SQL Error on Status Update  
**Priority:** P0

---

## 🎯 PROBLEM STATEMENT

**Error:** SQL Error ketika mengubah status parkiran menjadi "maintenance"

**Root Cause:** Kolom `parkiran.status` di database hanya menerima nilai ENUM:
```sql
enum('status', ['Tersedia', 'Ditutup'])
```

**Current Issue:** Form dan controller mencoba menyimpan nilai `'maintenance'` yang TIDAK ADA dalam ENUM definition.

---

## 📊 CURRENT DATABASE STRUCTURE

### Table: `parkiran`
```sql
CREATE TABLE parkiran (
    id_parkiran BIGINT PRIMARY KEY,
    id_mall BIGINT,
    nama_parkiran VARCHAR(255),
    kode_parkiran VARCHAR(10),
    jenis_kendaraan ENUM(...),
    kapasitas INT,
    status ENUM('Tersedia', 'Ditutup'),  -- ❌ TIDAK ADA 'maintenance'
    jumlah_lantai INT
);
```

### Table: `parking_floors`
```sql
CREATE TABLE parking_floors (
    id_floor BIGINT PRIMARY KEY,
    id_parkiran BIGINT,
    floor_name VARCHAR(50),
    floor_number INT,
    total_slots INT,
    available_slots INT,
    status VARCHAR(20)  -- ✅ Bisa menerima 'active', 'maintenance', 'inactive'
);
```

---

## 🔍 ARCHITECTURE ANALYSIS

### Current Status Hierarchy (BROKEN):

```
Parkiran (Global)
├── status: 'Tersedia' | 'Ditutup' | 'maintenance' ❌ (maintenance tidak valid)
└── Floors
    ├── Lantai 1: status = 'active'
    ├── Lantai 2: status = 'active'
    └── Lantai 3: status = 'active'
```

### Correct Status Hierarchy (SHOULD BE):

```
Parkiran (Global)
├── status: 'Tersedia' | 'Ditutup' ✅ (hanya 2 nilai)
└── Floors
    ├── Lantai 1: status = 'active' | 'maintenance' | 'inactive'
    ├── Lantai 2: status = 'active' | 'maintenance' | 'inactive'
    └── Lantai 3: status = 'active' | 'maintenance' | 'inactive'
```

---

## 💡 SOLUTION ARCHITECTURE

### Principle: Separation of Concerns

**Parkiran Status (Global):**
- `Tersedia` = Parkiran operasional (bisa digunakan)
- `Ditutup` = Parkiran tidak operasional (seluruh area ditutup)

**Floor Status (Per Lantai):**
- `active` = Lantai normal, slot bisa di-booking
- `maintenance` = Lantai sedang maintenance, slot TIDAK bisa di-booking
- `inactive` = Lantai tidak aktif

### Business Logic:

1. **Jika Parkiran = 'Ditutup':**
   - Semua lantai otomatis non-bookable
   - Tidak perlu cek status lantai

2. **Jika Parkiran = 'Tersedia':**
   - Cek status per lantai
   - Lantai 'active' → bookable
   - Lantai 'maintenance' → non-bookable
   - Lantai 'inactive' → non-bookable

---

## 🔧 REQUIRED CHANGES

### 1. Database Migration (OPTIONAL - Clarify ENUM)

**File:** `qparkin_backend/database/migrations/2025_01_03_fix_parkiran_status_enum.php`

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up()
    {
        // Parkiran status hanya 2 nilai: Tersedia, Ditutup
        // Maintenance diterapkan di level lantai (parking_floors.status)
        
        // Pastikan tidak ada data dengan status 'maintenance'
        DB::table('parkiran')
            ->where('status', 'maintenance')
            ->update(['status' => 'Tersedia']);
        
        // ENUM sudah benar, tidak perlu diubah
        // Hanya dokumentasi bahwa maintenance ada di parking_floors
    }

    public function down()
    {
        // No changes needed
    }
};
```

### 2. Controller Validation Fix

**File:** `qparkin_backend/app/Http/Controllers/AdminController.php`

**Method:** `storeParkiran()` dan `updateParkiran()`

**Before (BROKEN):**
```php
$validated = $request->validate([
    'status' => 'required|in:Tersedia,Ditutup,maintenance',  // ❌ maintenance invalid
]);
```

**After (FIXED):**
```php
$validated = $request->validate([
    'nama_parkiran' => 'required|string|max:255',
    'kode_parkiran' => 'required|string|max:10',
    'status' => 'required|in:Tersedia,Ditutup',  // ✅ Only 2 values
    'jumlah_lantai' => 'required|integer|min:1|max:10',
    'lantai' => 'required|array',
    'lantai.*.nama' => 'required|string',
    'lantai.*.jumlah_slot' => 'required|integer|min:1',
    'lantai.*.status' => 'nullable|in:active,maintenance,inactive',  // ✅ Per-floor status
]);
```

### 3. Form Update (Add Floor Status)

**File:** `qparkin_backend/resources/views/admin/edit-parkiran.blade.php`

**Add per-floor status selection:**

```html
<!-- Status Parkiran (Global) -->
<div class="form-group">
    <label>Status Parkiran *</label>
    <select name="status" required>
        <option value="Tersedia">Tersedia (Operasional)</option>
        <option value="Ditutup">Ditutup (Seluruh Area)</option>
    </select>
    <span class="hint">Status global untuk seluruh parkiran</span>
</div>

<!-- Konfigurasi Lantai -->
<div id="lantaiContainer">
    <!-- For each lantai -->
    <div class="lantai-item">
        <h5>Lantai 1</h5>
        
        <input type="text" name="lantai[0][nama]" value="Lantai 1" required>
        <input type="number" name="lantai[0][jumlah_slot]" value="30" required>
        
        <!-- NEW: Status per lantai -->
        <div class="form-group">
            <label>Status Lantai</label>
            <select name="lantai[0][status]">
                <option value="active">Aktif (Normal)</option>
                <option value="maintenance">Maintenance (Tidak Bookable)</option>
                <option value="inactive">Tidak Aktif</option>
            </select>
            <span class="hint">Jika maintenance, slot di lantai ini tidak bisa di-booking</span>
        </div>
    </div>
</div>
```

### 4. Controller Logic Update

**File:** `qparkin_backend/app/Http/Controllers/AdminController.php`

**Method:** `storeParkiran()`

```php
public function storeParkiran(Request $request)
{
    $validated = $request->validate([
        'nama_parkiran' => 'required|string|max:255',
        'kode_parkiran' => 'required|string|max:10',
        'status' => 'required|in:Tersedia,Ditutup',  // ✅ FIXED
        'jumlah_lantai' => 'required|integer|min:1|max:10',
        'lantai' => 'required|array',
        'lantai.*.nama' => 'required|string',
        'lantai.*.jumlah_slot' => 'required|integer|min:1',
        'lantai.*.status' => 'nullable|in:active,maintenance,inactive',  // ✅ NEW
    ]);

    \DB::beginTransaction();
    try {
        $totalKapasitas = collect($validated['lantai'])->sum('jumlah_slot');

        $parkiran = Parkiran::create([
            'id_mall' => $adminMall->id_mall,
            'nama_parkiran' => $validated['nama_parkiran'],
            'kode_parkiran' => $validated['kode_parkiran'],
            'status' => $validated['status'],  // ✅ Only 'Tersedia' or 'Ditutup'
            'jumlah_lantai' => $validated['jumlah_lantai'],
            'kapasitas' => $totalKapasitas,
        ]);

        foreach ($validated['lantai'] as $index => $lantaiData) {
            $floorStatus = $lantaiData['status'] ?? 'active';  // ✅ Default to 'active'
            
            $floor = ParkingFloor::create([
                'id_parkiran' => $parkiran->id_parkiran,
                'floor_name' => $lantaiData['nama'],
                'floor_number' => $index + 1,
                'total_slots' => $lantaiData['jumlah_slot'],
                'available_slots' => $lantaiData['jumlah_slot'],
                'status' => $floorStatus,  // ✅ Per-floor status
            ]);

            // Create slots...
        }

        \DB::commit();
        return response()->json(['success' => true, 'message' => 'Parkiran berhasil ditambahkan']);
    } catch (\Exception $e) {
        \DB::rollBack();
        return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
    }
}
```

---

## 📤 PAYLOAD EXAMPLES

### Before (BROKEN):

```json
{
    "nama_parkiran": "Parkiran Mawar",
    "kode_parkiran": "MWR",
    "status": "maintenance",  // ❌ INVALID - SQL Error!
    "jumlah_lantai": 2,
    "lantai": [
        {"nama": "Lantai 1", "jumlah_slot": 30},
        {"nama": "Lantai 2", "jumlah_slot": 25}
    ]
}
```

### After (FIXED):

```json
{
    "nama_parkiran": "Parkiran Mawar",
    "kode_parkiran": "MWR",
    "status": "Tersedia",  // ✅ VALID
    "jumlah_lantai": 2,
    "lantai": [
        {
            "nama": "Lantai 1",
            "jumlah_slot": 30,
            "status": "active"  // ✅ Normal operation
        },
        {
            "nama": "Lantai 2",
            "jumlah_slot": 25,
            "status": "maintenance"  // ✅ Maintenance - not bookable
        }
    ]
}
```

---

## 🔄 BOOKING LOGIC (NO CHANGES NEEDED)

**File:** `qparkin_backend/app/Http/Controllers/Api/ParkingSlotController.php`

The booking API already filters by floor status:

```php
public function getAvailableSlots($floorId)
{
    $floor = ParkingFloor::where('id_floor', $floorId)
        ->where('status', 'active')  // ✅ Already checks floor status
        ->firstOrFail();
    
    // Return slots only if floor is active
}
```

**No changes needed** - booking logic already respects floor status!

---

## ✅ VALIDATION CHECKLIST

### Database Level:
- [ ] `parkiran.status` ENUM = `['Tersedia', 'Ditutup']` ✅
- [ ] `parking_floors.status` VARCHAR = any value ✅
- [ ] No existing data with `parkiran.status = 'maintenance'`

### Controller Level:
- [ ] `storeParkiran()` validation: `status` in `['Tersedia', 'Ditutup']`
- [ ] `updateParkiran()` validation: `status` in `['Tersedia', 'Ditutup']`
- [ ] Accept `lantai.*.status` in `['active', 'maintenance', 'inactive']`

### Form Level:
- [ ] Parkiran status dropdown: Only 'Tersedia' and 'Ditutup'
- [ ] Per-floor status dropdown: 'active', 'maintenance', 'inactive'
- [ ] Clear labels explaining the difference

### API Level:
- [ ] Booking API filters floors by `status = 'active'` ✅ (already done)
- [ ] Slot visualization respects floor status ✅ (already done)

---

## 🚫 WHAT NOT TO CHANGE

❌ **DO NOT CHANGE:**
- `booking_page.dart` (Flutter app)
- Slot reservation logic
- Auto-generate slot logic
- Existing API endpoints
- Database table structure (except clarification)

✅ **ONLY CHANGE:**
- Controller validation rules
- Form UI (add per-floor status)
- Documentation

---

## 📝 IMPLEMENTATION STEPS

### Step 1: Fix Controller Validation

```bash
# Edit AdminController.php
# Change validation from:
'status' => 'required|in:Tersedia,Ditutup,maintenance'
# To:
'status' => 'required|in:Tersedia,Ditutup'
```

### Step 2: Update Form (Optional Enhancement)

Add per-floor status selection in edit form.

### Step 3: Clean Existing Data

```sql
-- Check if any parkiran has 'maintenance' status
SELECT * FROM parkiran WHERE status = 'maintenance';

-- If found, update to 'Tersedia'
UPDATE parkiran SET status = 'Tersedia' WHERE status = 'maintenance';
```

### Step 4: Test

1. Create new parkiran with status 'Tersedia' ✅
2. Create new parkiran with status 'Ditutup' ✅
3. Try to create with status 'maintenance' ❌ (should fail validation)
4. Update floor status to 'maintenance' ✅
5. Verify booking API excludes maintenance floors ✅

---

## 🎯 SUMMARY

**Problem:** `parkiran.status` ENUM doesn't include 'maintenance'

**Solution:** 
- Keep parkiran status simple: `Tersedia` | `Ditutup`
- Apply maintenance at floor level: `parking_floors.status`

**Impact:**
- ✅ No breaking changes to existing system
- ✅ No changes to booking_page.dart
- ✅ No changes to API endpoints
- ✅ Minimal controller changes
- ✅ Optional form enhancement

**Result:** Clean separation of concerns with proper status hierarchy.

---

**Analyzed by:** Kiro AI Assistant  
**Date:** 2025-01-03  
**Status:** ✅ SOLUTION READY  
**Ready for Implementation:** YES
