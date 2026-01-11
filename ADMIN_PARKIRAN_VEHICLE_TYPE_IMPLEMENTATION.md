# Admin Parkiran - Vehicle Type Selection Implementation

## Problem
The parkiran form in the admin dashboard was missing an input field to select which vehicle types are allowed to park in a specific parking area. While the database already had a `jenis_kendaraan` column, the form didn't expose this functionality.

## Solution Implemented

### 1. Database Schema (Already Exists)
The `parkiran` table already has the column:
```sql
jenis_kendaraan ENUM('Roda Dua', 'Roda Tiga', 'Roda Empat', 'Lebih dari Enam')
```

### 2. Frontend Changes

#### Form View (`tambah-parkiran.blade.php`)
Added new dropdown field after status selection:
```html
<div class="form-group">
    <label for="jenisKendaraan">Jenis Kendaraan yang Diizinkan *</label>
    <select id="jenisKendaraan" name="jenis_kendaraan" required>
        <option value="" hidden>Pilih Jenis Kendaraan</option>
        <option value="Roda Dua">Roda Dua (Motor)</option>
        <option value="Roda Tiga">Roda Tiga</option>
        <option value="Roda Empat">Roda Empat (Mobil)</option>
        <option value="Lebih dari Enam">Lebih dari Enam (Truk/Bus)</option>
    </select>
    <span class="form-hint">Tentukan jenis kendaraan yang boleh parkir di area ini</span>
</div>
```

#### Preview Section
Added vehicle type display in preview card:
```html
<div class="preview-item">
    <span>Jenis Kendaraan:</span>
    <span id="previewJenisKendaraan">-</span>
</div>
```

#### JavaScript (`tambah-parkiran.js`)
- Added `jenisKendaraan` element reference
- Added `previewJenisKendaraan` element reference
- Added event listener for vehicle type change
- Updated validation to check vehicle type is selected
- Updated preview function to display selected vehicle type
- Updated form data payload to include `jenis_kendaraan`

### 3. Backend Changes

#### AdminController (`storeParkiran` method)
**Validation:**
```php
$validated = $request->validate([
    'nama_parkiran' => 'required|string|max:255',
    'kode_parkiran' => 'required|string|max:10',
    'status' => 'required|in:Tersedia,Ditutup',
    'jenis_kendaraan' => 'required|in:Roda Dua,Roda Tiga,Roda Empat,Lebih dari Enam', // NEW
    'jumlah_lantai' => 'required|integer|min:1|max:10',
    'lantai' => 'required|array',
    'lantai.*.nama' => 'required|string',
    'lantai.*.jumlah_slot' => 'required|integer|min:1',
    'lantai.*.status' => 'nullable|in:active,maintenance,inactive',
]);
```

**Parkiran Creation:**
```php
$parkiran = Parkiran::create([
    'id_mall' => $adminMall->id_mall,
    'nama_parkiran' => $validated['nama_parkiran'],
    'kode_parkiran' => $validated['kode_parkiran'],
    'jenis_kendaraan' => $validated['jenis_kendaraan'], // NEW
    'status' => $validated['status'],
    'jumlah_lantai' => $validated['jumlah_lantai'],
    'kapasitas' => $totalKapasitas,
]);
```

**Slot Creation:**
```php
ParkingSlot::create([
    'id_floor' => $floor->id_floor,
    'slot_code' => $validated['kode_parkiran'] . '-L' . ($index + 1) . '-' . str_pad($i, 3, '0', STR_PAD_LEFT),
    'jenis_kendaraan' => $validated['jenis_kendaraan'], // CHANGED from hardcoded 'Roda Empat'
    'status' => 'available',
    'position_x' => $i,
    'position_y' => $index + 1,
]);
```

#### AdminController (`updateParkiran` method)
Same changes applied to the update method:
- Added validation for `jenis_kendaraan`
- Updated parkiran update to include `jenis_kendaraan`
- Changed slot creation to use `$validated['jenis_kendaraan']` instead of hardcoded value

## Files Modified

### Frontend
1. `qparkin_backend/resources/views/admin/tambah-parkiran.blade.php`
   - Added vehicle type dropdown field
   - Added preview display for vehicle type

2. `qparkin_backend/public/js/tambah-parkiran.js`
   - Added element references
   - Added event listeners
   - Updated validation logic
   - Updated preview function
   - Updated form data payload

3. `qparkin_backend/resources/views/admin/edit-parkiran.blade.php`
   - Added vehicle type dropdown field with current value selected
   - Added vehicle type display in current info section
   - Added preview display for vehicle type

4. `qparkin_backend/public/js/edit-parkiran.js`
   - Added element references
   - Added event listeners
   - Updated validation logic
   - Updated preview function
   - Updated form data payload

### Backend
5. `qparkin_backend/app/Http/Controllers/AdminController.php`
   - Updated `storeParkiran()` validation and creation logic
   - Updated `updateParkiran()` validation and update logic
   - Changed slot creation to use selected vehicle type

## Impact

### Before
- Parkiran could only be created for "Roda Empat" (hardcoded)
- No way to specify vehicle type restrictions
- All slots were created with "Roda Empat" regardless of actual use case

### After
- Admin can select which vehicle type is allowed for each parkiran
- Supports all 4 vehicle types: Roda Dua, Roda Tiga, Roda Empat, Lebih dari Enam
- Slots are automatically created with the correct vehicle type
- Preview shows selected vehicle type before saving
- Validation ensures vehicle type is always specified

## Testing

To test the implementation:

### Test Tambah Parkiran (Create)

1. **Navigate to Tambah Parkiran page**
   ```
   http://192.168.0.101:8000/admin/parkiran/tambah
   ```

2. **Fill in the form:**
   - Nama Parkiran: "Parkiran Motor"
   - Kode Parkiran: "MTR"
   - Status: "Aktif"
   - **Jenis Kendaraan: "Roda Dua"** (NEW FIELD)
   - Jumlah Lantai: 2
   - Configure each floor

3. **Verify preview updates** with selected vehicle type

4. **Save and check database:**
   ```sql
   SELECT id_parkiran, nama_parkiran, jenis_kendaraan FROM parkiran ORDER BY id_parkiran DESC LIMIT 1;
   ```

5. **Verify slots have correct vehicle type:**
   ```sql
   SELECT slot_code, jenis_kendaraan FROM parking_slots 
   WHERE id_floor IN (SELECT id_floor FROM parking_floors WHERE id_parkiran = [new_parkiran_id])
   LIMIT 5;
   ```

### Test Edit Parkiran (Update)

1. **Navigate to Edit Parkiran page**
   ```
   http://192.168.0.101:8000/admin/parkiran/edit/[parkiran_id]
   ```

2. **Verify current vehicle type is displayed:**
   - Check "Informasi Saat Ini" section shows current vehicle type
   - Check dropdown has correct value selected

3. **Change vehicle type:**
   - Select different vehicle type (e.g., from "Roda Empat" to "Roda Dua")
   - Verify preview updates

4. **Save and verify:**
   - Check database for updated vehicle type
   - Check all slots are recreated with new vehicle type

## Benefits

1. **Flexibility**: Different parking areas can now be designated for different vehicle types
2. **Accuracy**: Slot availability filtering can now work correctly based on vehicle type
3. **User Experience**: Mobile app users will see only relevant parking areas for their vehicle type
4. **Data Integrity**: Vehicle type is now consistently stored at both parkiran and slot levels

## Next Steps (Optional Enhancements)

1. **Parkiran List**: Display vehicle type in the parkiran list table
2. **API Filtering**: Update mobile API to filter parkiran by user's vehicle type
3. **Mixed Vehicle Types**: Consider allowing multiple vehicle types per parkiran (would require schema change to JSON array)
4. **Detail Parkiran**: Show vehicle type in detail parkiran page
