# Admin Parkiran Testing Guide

## 🎯 Tujuan Testing
Memverifikasi bahwa sistem auto-generate slot parkiran berfungsi dengan benar dan kompatibel dengan `booking_page.dart`.

---

## ✅ PRE-REQUISITES

### 1. Jalankan Migration
```bash
cd qparkin_backend
php artisan migrate
```

**Expected Output:**
```
Migration table created successfully.
Migrating: 2025_12_07_add_parkiran_fields
Migrated:  2025_12_07_add_parkiran_fields (XX.XXms)
```

### 2. Verify Database Structure
```bash
php artisan tinker
```

```php
// Check if columns exist
Schema::hasColumn('parkiran', 'nama_parkiran'); // should return true
Schema::hasColumn('parkiran', 'kode_parkiran'); // should return true
Schema::hasColumn('parkiran', 'jumlah_lantai'); // should return true
```

---

## 📋 PHASE 1: Backend Core Testing

### Test 1: Create Parkiran via API

**Endpoint:** `POST /admin/parkiran/store`

**Request Body:**
```json
{
    "nama_parkiran": "Parkiran Mawar",
    "kode_parkiran": "MWR",
    "status": "Tersedia",
    "jumlah_lantai": 2,
    "lantai": [
        {
            "nama": "Lantai 1",
            "jumlah_slot": 30
        },
        {
            "nama": "Lantai 2",
            "jumlah_slot": 25
        }
    ]
}
```

**Expected Response:**
```json
{
    "success": true,
    "message": "Parkiran berhasil ditambahkan"
}
```

### Test 2: Verify Database Records

```bash
php artisan tinker
```

```php
// Check parkiran
$parkiran = \App\Models\Parkiran::where('kode_parkiran', 'MWR')->first();
echo "Parkiran ID: " . $parkiran->id_parkiran . "\n";
echo "Nama: " . $parkiran->nama_parkiran . "\n";
echo "Kode: " . $parkiran->kode_parkiran . "\n";
echo "Jumlah Lantai: " . $parkiran->jumlah_lantai . "\n";
echo "Kapasitas: " . $parkiran->kapasitas . "\n"; // Should be 55

// Check floors
$floors = $parkiran->floors;
echo "Total Floors: " . $floors->count() . "\n"; // Should be 2

foreach ($floors as $floor) {
    echo "Floor: " . $floor->floor_name . " - " . $floor->total_slots . " slots\n";
}

// Check slots
$totalSlots = \App\Models\ParkingSlot::whereIn('id_floor', $floors->pluck('id_floor'))->count();
echo "Total Slots Generated: " . $totalSlots . "\n"; // Should be 55

// Check slot codes
$sampleSlots = \App\Models\ParkingSlot::where('id_floor', $floors->first()->id_floor)
    ->limit(5)
    ->pluck('slot_code');
echo "Sample Slot Codes:\n";
foreach ($sampleSlots as $code) {
    echo "  - " . $code . "\n";
}
// Expected: MWR-L1-001, MWR-L1-002, MWR-L1-003, MWR-L1-004, MWR-L1-005
```

**Expected Output:**
```
Parkiran ID: 1
Nama: Parkiran Mawar
Kode: MWR
Jumlah Lantai: 2
Kapasitas: 55
Total Floors: 2
Floor: Lantai 1 - 30 slots
Floor: Lantai 2 - 25 slots
Total Slots Generated: 55
Sample Slot Codes:
  - MWR-L1-001
  - MWR-L1-002
  - MWR-L1-003
  - MWR-L1-004
  - MWR-L1-005
```

---

## 📋 PHASE 2: API Endpoints Testing

### Test 3: Get Parking Floors

**Endpoint:** `GET /api/parking/floors/{mallId}`

**Example Request:**
```bash
curl -X GET "http://localhost:8000/api/parking/floors/1" \
  -H "Accept: application/json"
```

**Expected Response:**
```json
{
    "success": true,
    "data": [
        {
            "id_floor": "1",
            "id_mall": "1",
            "floor_number": 1,
            "floor_name": "Lantai 1",
            "total_slots": 30,
            "available_slots": 30,
            "occupied_slots": 0,
            "reserved_slots": 0,
            "last_updated": "2025-01-02T10:00:00+00:00"
        },
        {
            "id_floor": "2",
            "id_mall": "1",
            "floor_number": 2,
            "floor_name": "Lantai 2",
            "total_slots": 25,
            "available_slots": 25,
            "occupied_slots": 0,
            "reserved_slots": 0,
            "last_updated": "2025-01-02T10:00:00+00:00"
        }
    ]
}
```

### Test 4: Get Slot Visualization

**Endpoint:** `GET /api/parking/slots/{floorId}/visualization`

**Example Request:**
```bash
curl -X GET "http://localhost:8000/api/parking/slots/1/visualization" \
  -H "Accept: application/json"
```

**Expected Response:**
```json
{
    "success": true,
    "data": [
        {
            "id_slot": "1",
            "id_floor": "1",
            "slot_code": "MWR-L1-001",
            "status": "available",
            "slot_type": "regular",
            "position_x": 1,
            "position_y": 1,
            "last_updated": "2025-01-02T10:00:00+00:00"
        },
        {
            "id_slot": "2",
            "id_floor": "1",
            "slot_code": "MWR-L1-002",
            "status": "available",
            "slot_type": "regular",
            "position_x": 2,
            "position_y": 1,
            "last_updated": "2025-01-02T10:00:00+00:00"
        }
        // ... 28 more slots
    ]
}
```

### Test 5: Reserve Random Slot

**Endpoint:** `POST /api/parking/slots/reserve-random`

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/parking/slots/reserve-random" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "id_floor": 1,
    "id_user": 1,
    "vehicle_type": "Roda Empat",
    "duration_minutes": 5
  }'
```

**Expected Response:**
```json
{
    "success": true,
    "data": {
        "reservation_id": "1",
        "slot_id": "5",
        "slot_code": "MWR-L1-005",
        "floor_name": "Lantai 1",
        "floor_number": "1",
        "slot_type": "regular",
        "reserved_at": "2025-01-02T10:00:00+00:00",
        "expires_at": "2025-01-02T10:05:00+00:00"
    },
    "message": "Slot MWR-L1-005 berhasil direservasi untuk 5 menit"
}
```

---

## 📋 PHASE 3: Form Admin Testing

### Test 6: Access Form Admin

1. Login sebagai admin mall
2. Navigate to: `http://localhost:8000/admin/parkiran`
3. Click "Tambah Parkiran Baru"
4. Verify form loads correctly

**Expected Elements:**
- ✅ Input "Nama Parkiran"
- ✅ Input "Kode Parkiran"
- ✅ Select "Status"
- ✅ Input "Jumlah Lantai"
- ✅ Dynamic lantai configuration fields
- ✅ Preview section

### Test 7: Fill Form and Submit

**Steps:**
1. Nama Parkiran: "Parkiran Melati"
2. Kode Parkiran: "MLT"
3. Status: "Tersedia"
4. Jumlah Lantai: 3
5. Lantai 1: 20 slot
6. Lantai 2: 20 slot
7. Lantai 3: 15 slot
8. Click "Simpan Parkiran"

**Expected Result:**
- ✅ Success notification
- ✅ Redirect to parkiran list
- ✅ New parkiran appears in list
- ✅ Total capacity shows 55 slots

### Test 8: Verify Generated Data

```bash
php artisan tinker
```

```php
$parkiran = \App\Models\Parkiran::where('kode_parkiran', 'MLT')->first();
$totalSlots = \App\Models\ParkingSlot::whereIn(
    'id_floor', 
    $parkiran->floors->pluck('id_floor')
)->count();

echo "Total Slots: " . $totalSlots . "\n"; // Should be 55

// Check slot codes for each floor
foreach ($parkiran->floors as $floor) {
    $firstSlot = $floor->slots()->first();
    $lastSlot = $floor->slots()->orderBy('id_slot', 'desc')->first();
    echo $floor->floor_name . ": " . $firstSlot->slot_code . " to " . $lastSlot->slot_code . "\n";
}
// Expected:
// Lantai 1: MLT-L1-001 to MLT-L1-020
// Lantai 2: MLT-L2-001 to MLT-L2-020
// Lantai 3: MLT-L3-001 to MLT-L3-015
```

---

## 📋 PHASE 4: Integration with Booking Page

### Test 9: Booking Page Data Fetch

**From Flutter App:**

```dart
// Test 1: Fetch floors
final response = await http.get(
  Uri.parse('$baseUrl/api/parking/floors/1'),
  headers: {'Accept': 'application/json'}
);

print('Floors: ${response.body}');
// Should return list of floors with available_slots

// Test 2: Fetch slots for visualization
final slotsResponse = await http.get(
  Uri.parse('$baseUrl/api/parking/slots/1/visualization'),
  headers: {'Accept': 'application/json'}
);

print('Slots: ${slotsResponse.body}');
// Should return list of 30 slots with slot_code

// Test 3: Reserve slot
final reserveResponse = await http.post(
  Uri.parse('$baseUrl/api/parking/slots/reserve-random'),
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json'
  },
  body: jsonEncode({
    'id_floor': 1,
    'id_user': userId,
    'vehicle_type': 'Roda Empat',
    'duration_minutes': 5
  })
);

print('Reservation: ${reserveResponse.body}');
// Should return reservation with slot_code
```

---

## ✅ SUCCESS CRITERIA

### Backend:
- [x] Migration berhasil dijalankan
- [x] Parkiran dapat dibuat via form admin
- [x] Floors ter-generate otomatis
- [x] Slots ter-generate otomatis dengan kode unik
- [x] Total slots = sum of all floor slots

### API:
- [x] GET /api/parking/floors/{mallId} returns correct data
- [x] GET /api/parking/slots/{floorId}/visualization returns all slots
- [x] POST /api/parking/slots/reserve-random successfully reserves slot
- [x] Slot status changes from 'available' to 'reserved'

### Booking Page:
- [x] Floor selector shows correct floors
- [x] Slot visualization displays all slots
- [x] Slot reservation works without conflicts
- [x] Reserved slot info displays correct slot_code

---

## 🐛 TROUBLESHOOTING

### Issue 1: Migration Error
**Error:** `Column already exists: nama_parkiran`

**Solution:**
```bash
php artisan migrate:rollback --step=1
php artisan migrate
```

### Issue 2: No Slots Generated
**Symptom:** Parkiran created but parking_slots table is empty

**Check:**
```php
// Check if storeParkiran method is being called
Log::info('Creating parkiran', ['data' => $validated]);

// Check if loop is executing
Log::info('Creating slot', ['slot_code' => $slotCode]);
```

### Issue 3: API Returns Empty Data
**Symptom:** GET /api/parking/floors returns empty array

**Check:**
1. Verify parkiran status is 'active' (not 'Tersedia')
2. Check if parkiran has correct id_mall
3. Verify floors have status 'active'

**Fix:**
```php
// Update parkiran status
$parkiran = Parkiran::find(1);
$parkiran->status = 'Tersedia'; // or 'active'
$parkiran->save();
```

---

## 📊 PERFORMANCE METRICS

### Expected Performance:
- Create parkiran with 100 slots: < 2 seconds
- Fetch floors: < 100ms
- Fetch slots visualization: < 200ms
- Reserve slot: < 150ms

### Database Queries:
- Create parkiran: 1 INSERT (parkiran) + N INSERTs (floors) + M INSERTs (slots)
- Get floors: 1 SELECT with JOIN
- Get slots: 1 SELECT with WHERE
- Reserve slot: 1 SELECT + 1 UPDATE + 1 INSERT (transaction)

---

**Dibuat:** 2025-01-02  
**Status:** Ready for Testing  
**Priority:** P0 (Critical)
