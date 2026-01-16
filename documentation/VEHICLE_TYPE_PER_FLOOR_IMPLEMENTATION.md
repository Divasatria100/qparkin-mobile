# Vehicle Type Per Floor - Realistic Business Logic Implementation

## Problem Analysis

### Previous Implementation (INCORRECT)
- Jenis kendaraan ditentukan di level **parkiran** (global untuk semua lantai)
- Semua lantai dalam satu parkiran harus menggunakan jenis kendaraan yang sama
- Tidak realistis: dalam praktik nyata, mall bisa punya Lantai 1 untuk motor, Lantai 2-3 untuk mobil

### Correct Implementation (REALISTIC)
- Jenis kendaraan ditentukan di level **lantai parkir** (per floor)
- Setiap lantai bisa memiliki jenis kendaraan yang berbeda
- Realistis: Lantai 1 = Motor, Lantai 2 = Mobil, Lantai 3 = Mobil, Basement = Truk

## Database Schema Changes

### Migration 1: Add jenis_kendaraan to parking_floors
**File:** `2026_01_11_000001_add_jenis_kendaraan_to_parking_floors_table.php`

```php
Schema::table('parking_floors', function (Blueprint $table) {
    $table->enum('jenis_kendaraan', ['Roda Dua', 'Roda Tiga', 'Roda Empat', 'Lebih dari Enam'])
          ->after('floor_number')
          ->nullable()
          ->comment('Jenis kendaraan yang diizinkan di lantai ini');
    
    $table->index('jenis_kendaraan');
});
```

### Migration 2: Remove jenis_kendaraan from parkiran
**File:** `2026_01_11_000002_remove_jenis_kendaraan_from_parkiran_table.php`

```php
Schema::table('parkiran', function (Blueprint $table) {
    $table->dropColumn('jenis_kendaraan');
});
```

### Run Migrations
```bash
cd qparkin_backend
php artisan migrate
```

## Backend Changes

### 1. Model Updates

#### ParkingFloor Model
**File:** `app/Models/ParkingFloor.php`

```php
protected $fillable = [
    'id_parkiran',
    'floor_name',
    'floor_number',
    'jenis_kendaraan', // ✅ ADDED
    'total_slots',
    'available_slots',
    'status'
];

// ✅ NEW: Scope untuk filter by vehicle type
public function scopeForVehicleType($query, $jenisKendaraan)
{
    return $query->where('jenis_kendaraan', $jenisKendaraan);
}
```

#### Parkiran Model
**File:** `app/Models/Parkiran.php`

```php
protected $fillable = [
    'id_mall',
    'nama_parkiran',
    'kode_parkiran',
    // 'jenis_kendaraan', // ✅ REMOVED
    'kapasitas',
    'status',
    'jumlah_lantai'
];
```

### 2. AdminController Updates

#### storeParkiran Method
**File:** `app/Http/Controllers/AdminController.php`

```php
$validated = $request->validate([
    'nama_parkiran' => 'required|string|max:255',
    'kode_parkiran' => 'required|string|max:10',
    'status' => 'required|in:Tersedia,Ditutup',
    'jumlah_lantai' => 'required|integer|min:1|max:10',
    'lantai' => 'required|array',
    'lantai.*.nama' => 'required|string',
    'lantai.*.jumlah_slot' => 'required|integer|min:1',
    'lantai.*.jenis_kendaraan' => 'required|in:Roda Dua,Roda Tiga,Roda Empat,Lebih dari Enam', // ✅ ADDED
    'lantai.*.status' => 'nullable|in:active,maintenance,inactive',
]);

// Create floors and slots
foreach ($validated['lantai'] as $index => $lantaiData) {
    $jenisKendaraan = $lantaiData['jenis_kendaraan']; // ✅ Get from lantai data
    
    $floor = ParkingFloor::create([
        'id_parkiran' => $parkiran->id_parkiran,
        'floor_name' => $lantaiData['nama'],
        'floor_number' => $index + 1,
        'jenis_kendaraan' => $jenisKendaraan, // ✅ ADDED
        'total_slots' => $lantaiData['jumlah_slot'],
        'available_slots' => $lantaiData['jumlah_slot'],
        'status' => $floorStatus,
    ]);

    // Create slots with floor's vehicle type
    for ($i = 1; $i <= $lantaiData['jumlah_slot']; $i++) {
        ParkingSlot::create([
            'id_floor' => $floor->id_floor,
            'slot_code' => $validated['kode_parkiran'] . '-L' . ($index + 1) . '-' . str_pad($i, 3, '0', STR_PAD_LEFT),
            'jenis_kendaraan' => $jenisKendaraan, // ✅ Use floor's vehicle type
            'status' => 'available',
            'position_x' => $i,
            'position_y' => $index + 1,
        ]);
    }
}
```

### 3. API Updates

#### ParkingSlotController - getFloors Method
**File:** `app/Http/Controllers/Api/ParkingSlotController.php`

```php
$floors = ParkingFloor::whereIn('id_parkiran', $parkiranIds)
    ->active()
    ->with('parkiran')
    ->get()
    ->map(function ($floor) use ($mallId) {
        return [
            'id_floor' => $floor->id_floor,
            'id_mall' => $mallId,
            'floor_number' => $floor->floor_number,
            'floor_name' => $floor->floor_name,
            'jenis_kendaraan' => $floor->jenis_kendaraan, // ✅ ADDED
            'total_slots' => $totalSlots,
            'available_slots' => $availableSlots,
            'occupied_slots' => $occupiedSlots,
            'reserved_slots' => $reservedSlots,
            'last_updated' => Carbon::now()->toIso8601String()
        ];
    });
```

## Frontend Changes

### 1. Flutter Model Update

#### ParkingFloorModel
**File:** `qparkin_app/lib/data/models/parking_floor_model.dart`

```dart
class ParkingFloorModel {
  final String idFloor;
  final String idMall;
  final int floorNumber;
  final String floorName;
  final String? jenisKendaraan; // ✅ ADDED: Vehicle type for this floor
  final int totalSlots;
  final int availableSlots;
  final int occupiedSlots;
  final int reservedSlots;
  final DateTime lastUpdated;

  ParkingFloorModel({
    required this.idFloor,
    required this.idMall,
    required this.floorNumber,
    required this.floorName,
    this.jenisKendaraan, // ✅ ADDED: Optional vehicle type
    required this.totalSlots,
    required this.availableSlots,
    required this.occupiedSlots,
    required this.reservedSlots,
    required this.lastUpdated,
  });

  factory ParkingFloorModel.fromJson(Map<String, dynamic> json) {
    return ParkingFloorModel(
      idFloor: json['id_floor']?.toString() ?? '',
      idMall: json['id_mall']?.toString() ?? '',
      floorNumber: _parseInt(json['floor_number']),
      floorName: json['floor_name']?.toString() ?? '',
      jenisKendaraan: json['jenis_kendaraan']?.toString(), // ✅ ADDED
      totalSlots: _parseInt(json['total_slots']),
      availableSlots: _parseInt(json['available_slots']),
      occupiedSlots: _parseInt(json['occupied_slots']),
      reservedSlots: _parseInt(json['reserved_slots']),
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'].toString())
          : DateTime.now(),
    );
  }
}
```

### 2. BookingProvider Logic Update

**File:** `qparkin_app/lib/logic/providers/booking_provider.dart`

**BEFORE (Incorrect):**
```dart
// Showed all floors regardless of vehicle type
await loadFloors();
```

**AFTER (Correct):**
```dart
// Filter floors by selected vehicle's type
Future<void> loadFloorsForVehicle(String jenisKendaraan) async {
  _isLoadingFloors = true;
  notifyListeners();

  try {
    final allFloors = await _bookingService.getFloors(_mallId);
    
    // ✅ Filter floors that match vehicle type
    _floors = allFloors.where((floor) {
      return floor.jenisKendaraan == jenisKendaraan;
    }).toList();
    
    _isLoadingFloors = false;
    notifyListeners();
  } catch (e) {
    _isLoadingFloors = false;
    _error = e.toString();
    notifyListeners();
  }
}

// Call this when vehicle is selected
void selectVehicle(VehicleModel vehicle) {
  _selectedVehicle = vehicle;
  _selectedFloor = null; // Reset floor selection
  _floors = []; // Clear floors
  
  // Load floors for this vehicle type
  loadFloorsForVehicle(vehicle.jenisKendaraan);
  
  notifyListeners();
}
```

### 3. Booking Page UI Update

**File:** `qparkin_app/lib/presentation/screens/booking_page.dart`

```dart
// Floor selector only shows floors matching vehicle type
if (bookingProvider.isSlotReservationEnabled && 
    bookingProvider.selectedVehicle != null &&
    bookingProvider.floors.isNotEmpty) { // ✅ Floors already filtered by vehicle type
  FloorSelectorWidget(
    floors: bookingProvider.floors, // Only shows matching floors
    selectedFloor: bookingProvider.selectedFloor,
    onFloorSelected: (floor) {
      bookingProvider.selectFloor(floor);
    },
  ),
}
```

## Admin Form Changes

### Tambah Parkiran Form

**File:** `qparkin_backend/resources/views/admin/tambah-parkiran.blade.php`

Remove global vehicle type dropdown, add per-lantai dropdown:

```html
<!-- REMOVED: Global vehicle type dropdown -->
<!-- <div class="form-group">
    <label for="jenisKendaraan">Jenis Kendaraan *</label>
    <select id="jenisKendaraan" name="jenis_kendaraan" required>
        ...
    </select>
</div> -->

<!-- ADDED: Per-lantai vehicle type in lantai configuration -->
<div class="lantai-fields">
    <div class="lantai-field">
        <label for="namaLantai${i}">Nama Lantai</label>
        <input type="text" id="namaLantai${i}" name="namaLantai${i}" 
               value="Lantai ${i}" required>
    </div>
    <div class="lantai-field">
        <label for="slotLantai${i}">Jumlah Slot *</label>
        <input type="number" id="slotLantai${i}" name="slotLantai${i}" 
               min="1" max="200" value="20" required>
    </div>
    <!-- ✅ ADDED: Vehicle type per floor -->
    <div class="lantai-field">
        <label for="jenisKendaraanLantai${i}">Jenis Kendaraan *</label>
        <select id="jenisKendaraanLantai${i}" name="jenisKendaraanLantai${i}" required>
            <option value="Roda Dua">Roda Dua (Motor)</option>
            <option value="Roda Tiga">Roda Tiga</option>
            <option value="Roda Empat" selected>Roda Empat (Mobil)</option>
            <option value="Lebih dari Enam">Lebih dari Enam (Truk/Bus)</option>
        </select>
    </div>
</div>
```

### JavaScript Update

**File:** `qparkin_backend/public/js/tambah-parkiran.js`

```javascript
// Collect lantai data with vehicle type
for (let i = 1; i <= jumlahLantaiValue; i++) {
    const namaInput = document.getElementById(`namaLantai${i}`);
    const slotInput = document.getElementById(`slotLantai${i}`);
    const jenisKendaraanInput = document.getElementById(`jenisKendaraanLantai${i}`); // ✅ ADDED
    
    lantaiData.push({
        nama: namaInput.value.trim(),
        jumlah_slot: parseInt(slotInput.value),
        jenis_kendaraan: jenisKendaraanInput.value // ✅ ADDED
    });
}
```

## Business Logic Flow

### Correct Flow (After Implementation)

1. **Admin creates parkiran:**
   - Lantai 1: "Lantai Motor" - Jenis: Roda Dua - 50 slot
   - Lantai 2: "Lantai Mobil A" - Jenis: Roda Empat - 30 slot
   - Lantai 3: "Lantai Mobil B" - Jenis: Roda Empat - 30 slot

2. **User selects vehicle:**
   - User has motor (Roda Dua)
   - System filters floors: Only shows "Lantai Motor"

3. **User books slot:**
   - User sees only Lantai 1 (Motor)
   - User selects floor and slot
   - Booking created with correct vehicle type match

### Benefits

1. **Realistic:** Matches real-world parking structure
2. **Flexible:** Different floors can serve different vehicle types
3. **Accurate:** No mismatch between vehicle and floor
4. **Scalable:** Easy to add mixed-use floors in future

## Testing

### 1. Run Migrations
```bash
cd qparkin_backend
php artisan migrate
```

### 2. Create Test Parkiran
```
Nama: Parkiran Test
Kode: TEST
Status: Tersedia

Lantai 1:
- Nama: Lantai Motor
- Jumlah Slot: 20
- Jenis Kendaraan: Roda Dua

Lantai 2:
- Nama: Lantai Mobil
- Jumlah Slot: 15
- Jenis Kendaraan: Roda Empat
```

### 3. Verify Database
```sql
-- Check floors have vehicle types
SELECT id_floor, floor_name, jenis_kendaraan, total_slots 
FROM parking_floors 
WHERE id_parkiran = [test_parkiran_id];

-- Check slots inherit floor's vehicle type
SELECT ps.slot_code, ps.jenis_kendaraan, pf.floor_name
FROM parking_slots ps
JOIN parking_floors pf ON ps.id_floor = pf.id_floor
WHERE pf.id_parkiran = [test_parkiran_id]
LIMIT 10;
```

### 4. Test Mobile App
1. Register vehicle with type "Roda Dua"
2. Go to booking page
3. Select the motor vehicle
4. Verify only "Lantai Motor" appears in floor selector
5. Register another vehicle with type "Roda Empat"
6. Select the car vehicle
7. Verify only "Lantai Mobil" appears

## Files Modified

### Backend
1. `database/migrations/2026_01_11_000001_add_jenis_kendaraan_to_parking_floors_table.php` - NEW
2. `database/migrations/2026_01_11_000002_remove_jenis_kendaraan_from_parkiran_table.php` - NEW
3. `app/Models/ParkingFloor.php` - MODIFIED
4. `app/Models/Parkiran.php` - MODIFIED
5. `app/Http/Controllers/AdminController.php` - MODIFIED (storeParkiran, updateParkiran)
6. `app/Http/Controllers/Api/ParkingSlotController.php` - MODIFIED (getFloors)

### Frontend (Flutter)
7. `qparkin_app/lib/data/models/parking_floor_model.dart` - MODIFIED
8. `qparkin_app/lib/logic/providers/booking_provider.dart` - NEEDS UPDATE (filter logic)
9. `qparkin_app/lib/presentation/screens/booking_page.dart` - NEEDS UPDATE (if needed)

### Admin Forms
10. `qparkin_backend/resources/views/admin/tambah-parkiran.blade.php` - NEEDS UPDATE
11. `qparkin_backend/public/js/tambah-parkiran.js` - NEEDS UPDATE
12. `qparkin_backend/resources/views/admin/edit-parkiran.blade.php` - NEEDS UPDATE
13. `qparkin_backend/public/js/edit-parkiran.js` - NEEDS UPDATE

## Next Steps

1. ✅ Run migrations
2. ⏳ Update admin forms (tambah & edit parkiran)
3. ⏳ Update BookingProvider filter logic
4. ⏳ Test end-to-end flow
5. ⏳ Update existing data (if any)
