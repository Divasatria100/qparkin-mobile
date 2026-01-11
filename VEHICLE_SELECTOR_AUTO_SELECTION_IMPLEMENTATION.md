# Vehicle Selector - Auto-Selection Kendaraan Aktif

## Fitur Baru: Auto-Selection Kendaraan Aktif

### Deskripsi
Sistem sekarang secara otomatis memilih kendaraan dengan status 'Aktif' saat halaman booking pertama kali dimuat, memberikan pengalaman booking yang lebih cepat dan efisien.

## Implementasi

### 1. Auto-Selection Logic

**File**: `qparkin_app/lib/presentation/widgets/vehicle_selector.dart`

#### Method Baru: `_autoSelectActiveVehicle()`

```dart
/// Auto-select the active vehicle if available and no vehicle is currently selected
void _autoSelectActiveVehicle() {
  // Only auto-select if no vehicle is currently selected
  if (widget.selectedVehicle != null) {
    debugPrint('[VehicleSelector] Vehicle already selected, skipping auto-selection');
    return;
  }

  // Find the first active vehicle
  try {
    final activeVehicle = _vehicles.firstWhere(
      (vehicle) => vehicle.isActive == true,
    );

    debugPrint('[VehicleSelector] Auto-selecting active vehicle: ${activeVehicle.platNomor}');

    // Notify parent to update selected vehicle
    widget.onVehicleSelected(activeVehicle);

    // Announce to screen readers
    SemanticsService.announce(
      'Kendaraan aktif ${activeVehicle.platNomor} dipilih secara otomatis',
      TextDirection.ltr,
    );
  } catch (e) {
    debugPrint('[VehicleSelector] No active vehicle found for auto-selection');
  }
}
```

#### Modifikasi `_fetchVehicles()`

Method ini sekarang memanggil `_autoSelectActiveVehicle()` setelah data kendaraan berhasil dimuat:

```dart
Future<void> _fetchVehicles() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final vehicles = await widget.vehicleService.getVehicles();
    
    setState(() {
      _vehicles = vehicles;
      _isLoading = false;
    });

    // Auto-select active vehicle if no vehicle is currently selected
    _autoSelectActiveVehicle();
  } catch (e) {
    setState(() {
      _errorMessage = e.toString();
      _isLoading = false;
    });
  }
}
```

### 2. Visual Indicator - Badge "Aktif"

Kendaraan dengan status aktif sekarang menampilkan badge hijau "Aktif" di sebelah plat nomor:

```dart
// Plat Nomor with Active Badge
Row(
  children: [
    Flexible(
      child: Text(
        vehicle.platNomor,
        style: DesignConstants.getBodyStyle(
          fontSize: DesignConstants.fontSizeBodyLarge,
          fontWeight: DesignConstants.fontWeightSemiBold,
          color: isSelected
              ? DesignConstants.primaryColor
              : DesignConstants.textPrimary,
        ),
      ),
    ),
    if (vehicle.isActive) ...[
      const SizedBox(width: DesignConstants.spaceXs),
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981), // Green
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Aktif',
          style: DesignConstants.getBodyStyle(
            fontSize: 10,
            fontWeight: DesignConstants.fontWeightSemiBold,
            color: Colors.white,
          ),
        ),
      ),
    ],
  ],
)
```

### 3. Accessibility Enhancement

Semantic label diperbarui untuk mengumumkan status aktif kendaraan:

```dart
Semantics(
  label: 'Kendaraan ${vehicle.platNomor}, ${vehicle.jenisKendaraan}, '
         '${vehicle.merk} ${vehicle.tipe}'
         '${vehicle.isActive ? ", kendaraan aktif" : ""}'
         '${isSelected ? ", terpilih" : ""}',
  button: true,
  selected: isSelected,
  child: ...
)
```

## Alur Kerja (Flow)

### Skenario 1: Kendaraan Aktif Tersedia
1. User membuka halaman booking
2. `VehicleSelector` widget di-mount
3. `initState()` memanggil `_fetchVehicles()`
4. API mengembalikan daftar kendaraan
5. `_autoSelectActiveVehicle()` dipanggil
6. Sistem menemukan kendaraan dengan `isActive = true`
7. `widget.onVehicleSelected(activeVehicle)` dipanggil
8. **Kolom input langsung menampilkan kendaraan aktif**
9. User dapat langsung melanjutkan ke step berikutnya
10. User tetap bisa mengubah pilihan dengan tap kolom input

### Skenario 2: Tidak Ada Kendaraan Aktif
1. User membuka halaman booking
2. `VehicleSelector` widget di-mount
3. `initState()` memanggil `_fetchVehicles()`
4. API mengembalikan daftar kendaraan
5. `_autoSelectActiveVehicle()` dipanggil
6. Tidak ada kendaraan dengan `isActive = true`
7. **Kolom input tetap kosong** (placeholder: "Pilih kendaraan Anda")
8. User harus memilih kendaraan secara manual

### Skenario 3: Kendaraan Sudah Dipilih Sebelumnya
1. User kembali ke halaman booking (navigasi back)
2. `VehicleSelector` widget di-mount dengan `selectedVehicle != null`
3. `initState()` memanggil `_fetchVehicles()`
4. API mengembalikan daftar kendaraan
5. `_autoSelectActiveVehicle()` dipanggil
6. **Auto-selection di-skip** karena sudah ada kendaraan terpilih
7. Kolom input tetap menampilkan kendaraan yang sudah dipilih sebelumnya

## Fitur Utama

### ✅ Initial Auto-Selection
- Sistem otomatis memindai daftar kendaraan saat halaman dimuat
- Kendaraan dengan `isActive = true` langsung terpilih

### ✅ Immediate UI Update
- Kolom input langsung menampilkan:
  - Ikon kendaraan (motor/mobil)
  - Plat nomor
  - Merk dan tipe
- Tidak perlu klik tambahan untuk melihat kendaraan aktif

### ✅ Dropdown Consistency
- Badge hijau "Aktif" muncul di sebelah plat nomor
- Kendaraan terpilih memiliki:
  - Background soft lavender (#F5F3FF)
  - Ikon centang ungu
  - Warna teks ungu

### ✅ Flexible Override
- User tetap bisa tap kolom input untuk membuka bottom sheet
- User bisa memilih kendaraan lain kapan saja
- Perubahan pilihan langsung ter-update di UI

### ✅ Accessibility Support
- Screen reader mengumumkan: "Kendaraan aktif [plat] dipilih secara otomatis"
- Semantic label mencakup status "kendaraan aktif"

## Visual Design

### Badge "Aktif"
- **Warna**: Green (#10B981)
- **Ukuran font**: 10px
- **Font weight**: SemiBold
- **Padding**: 8px horizontal, 2px vertical
- **Border radius**: 12px
- **Posisi**: Di sebelah kanan plat nomor

### Contoh Tampilan

```
┌─────────────────────────────────────────┐
│ 🏍️  B 4321 XY [Aktif]                  │
│     Yamaha Beat                         │
│     Roda Dua                            │
└─────────────────────────────────────────┘
```

## Testing

### Manual Testing Steps

1. **Test Auto-Selection**
   ```bash
   # Pastikan ada kendaraan dengan is_active = true di database
   # Buka halaman booking
   # Verifikasi: Kolom "Pilih Kendaraan" langsung terisi
   ```

2. **Test Badge Display**
   ```bash
   # Tap kolom "Pilih Kendaraan"
   # Verifikasi: Badge hijau "Aktif" muncul di kendaraan aktif
   ```

3. **Test Override**
   ```bash
   # Tap kolom "Pilih Kendaraan"
   # Pilih kendaraan lain
   # Verifikasi: Pilihan berubah, UI ter-update
   ```

4. **Test No Active Vehicle**
   ```bash
   # Set semua kendaraan is_active = false
   # Buka halaman booking
   # Verifikasi: Kolom tetap kosong, placeholder muncul
   ```

### Debug Logs

```
[VehicleSelector] Fetching vehicles from API...
[VehicleSelector] Vehicles fetched successfully: 3 vehicles
[VehicleSelector] Auto-selecting active vehicle: B 4321 XY
```

atau jika tidak ada kendaraan aktif:

```
[VehicleSelector] Fetching vehicles from API...
[VehicleSelector] Vehicles fetched successfully: 3 vehicles
[VehicleSelector] No active vehicle found for auto-selection
```

## Data Model

### VehicleModel
```dart
class VehicleModel {
  final String idKendaraan;
  final String platNomor;
  final String jenisKendaraan;
  final String merk;
  final String tipe;
  final bool isActive;  // ← Field untuk status aktif
  // ... fields lainnya
}
```

### Backend API Response
```json
{
  "data": [
    {
      "id_kendaraan": "1",
      "plat": "B 4321 XY",
      "jenis": "Roda Dua",
      "merk": "Yamaha",
      "tipe": "Beat",
      "is_active": true  // ← Backend harus mengirim field ini
    }
  ]
}
```

## Compatibility

- ✅ Modal Bottom Sheet implementation
- ✅ BaseParkingCard design system
- ✅ Accessibility (screen readers)
- ✅ Semantic labels
- ✅ Debug logging

## Files Modified

1. `qparkin_app/lib/presentation/widgets/vehicle_selector.dart`
   - Added `_autoSelectActiveVehicle()` method
   - Modified `_fetchVehicles()` to call auto-selection
   - Updated `_buildVehicleItem()` to show "Aktif" badge
   - Enhanced semantic labels

## Next Steps

1. **Hot Restart** aplikasi (bukan hot reload)
2. Test dengan kendaraan yang memiliki `is_active = true`
3. Verifikasi auto-selection berfungsi
4. Verifikasi badge "Aktif" muncul
5. Test override functionality

## Command untuk Testing

```bash
cd qparkin_app
flutter run --dart-define=API_URL=http://192.168.0.101:8000
```

**PENTING**: Gunakan **hot restart** (Shift+R atau tombol restart) untuk memastikan perubahan ter-load dengan benar.
