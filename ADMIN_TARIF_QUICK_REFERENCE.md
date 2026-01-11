# Admin Tarif - Quick Reference

## Status Fitur

| Komponen | Status | Keterangan |
|----------|--------|------------|
| Database Schema | ✅ Complete | Tabel `tarif_parkir` dan `riwayat_tarif` |
| Backend Routes | ✅ Complete | Web routes dan API routes |
| Admin UI | ✅ Complete | Halaman tarif dan edit tarif |
| Backend Logic | ✅ Complete | CRUD tarif dengan riwayat |
| API Integration | ❌ Missing | Tarif belum di-include di Mall API |
| Mobile App | ❌ Missing | Belum menggunakan tarif dari API |

---

## Quick Commands

### Test Backend

```bash
# Start Laravel server
cd qparkin_backend
php artisan serve

# Test edit tarif
# 1. Login: http://localhost:8000/admin/login
# 2. Tarif: http://localhost:8000/admin/tarif
# 3. Edit: http://localhost:8000/admin/tarif/1/edit
```

### Diagnostic Commands (NEW)

```bash
# Check tarif data in database
cd qparkin_backend
php test_tarif_data.php

# Create missing tarif
php check_and_create_tarif.php

# View logs
tail -f storage/logs/laravel.log

# Clear cache
php artisan cache:clear
php artisan config:clear
php artisan view:clear
```

### Test API

```bash
# Get mall list with tarif
curl -X GET "http://localhost:8000/api/mall" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Get specific mall tarif
curl -X GET "http://localhost:8000/api/mall/1/tarif" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Test Mobile App

```bash
cd qparkin_app
flutter run --dart-define=API_URL=http://192.168.0.101:8000
```

---

## Database Structure

### Tabel `tarif_parkir`

| Field | Type | Description |
|-------|------|-------------|
| id_tarif | BIGINT | Primary key |
| id_mall | BIGINT | Foreign key to mall |
| jenis_kendaraan | ENUM | Roda Dua, Tiga, Empat, Lebih dari Enam |
| satu_jam_pertama | DECIMAL(10,2) | Tarif jam pertama |
| tarif_parkir_per_jam | DECIMAL(10,2) | Tarif per jam berikutnya |

### Tabel `riwayat_tarif`

| Field | Type | Description |
|-------|------|-------------|
| id_riwayat | BIGINT | Primary key |
| id_tarif | BIGINT | Foreign key to tarif_parkir |
| id_mall | BIGINT | Foreign key to mall |
| id_user | BIGINT | Admin yang mengubah |
| tarif_lama_jam_pertama | DECIMAL | Tarif lama |
| tarif_baru_jam_pertama | DECIMAL | Tarif baru |
| waktu_perubahan | TIMESTAMP | Waktu perubahan |

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/tarif` | Halaman daftar tarif |
| GET | `/admin/tarif/{id}/edit` | Form edit tarif |
| POST | `/admin/tarif/{id}` | Update tarif |
| GET | `/api/mall` | Get mall list (perlu tambah tarif) |
| GET | `/api/mall/{id}` | Get mall detail (perlu tambah tarif) |
| GET | `/api/mall/{id}/tarif` | Get tarif for mall |

---

## Implementation Checklist

### Backend (Priority 1)

- [ ] Modify `MallController::index()` - add tarif to response
- [ ] Modify `MallController::show()` - add tarif to response
- [ ] Test API returns tarif array
- [ ] Verify edit tarif saves to database
- [ ] Verify riwayat tarif recorded

### Mobile App (Priority 2)

- [ ] Add `_tarifs` field to BookingProvider
- [ ] Modify `initialize()` to extract tarif from mall data
- [ ] Modify `selectVehicle()` to update tarif based on vehicle type
- [ ] Add `getTarifForVehicleType()` method
- [ ] Test tarif loaded from API
- [ ] Test cost calculation uses correct tarif

### Testing (Priority 3)

- [ ] Edit tarif Roda Dua in admin
- [ ] Verify API returns new tarif
- [ ] Restart mobile app
- [ ] Select Roda Dua vehicle
- [ ] Verify cost uses new tarif
- [ ] Change to Roda Empat
- [ ] Verify cost changes

---

## Code Snippets

### Backend: Add Tarif to Mall API

```php
// In MallController::index()
->map(function ($mall) {
    // Get tarif for this mall
    $tarifs = \App\Models\TarifParkir::where('id_mall', $mall->id_mall)
        ->select(['jenis_kendaraan', 'satu_jam_pertama', 'tarif_parkir_per_jam'])
        ->get()
        ->map(function($tarif) {
            return [
                'jenis_kendaraan' => $tarif->jenis_kendaraan,
                'satu_jam_pertama' => (float) $tarif->satu_jam_pertama,
                'tarif_parkir_per_jam' => (float) $tarif->tarif_parkir_per_jam,
            ];
        });

    return [
        // ... existing fields ...
        'tarif' => $tarifs, // ADD THIS
    ];
});
```

### Mobile: Load Tarif in BookingProvider

```dart
// In initialize() method
if (mallData['tarif'] != null && mallData['tarif'] is List) {
  _tarifs = List<Map<String, dynamic>>.from(mallData['tarif']);
  debugPrint('[BookingProvider] Loaded ${_tarifs.length} tarifs');
}
```

### Mobile: Update Tarif on Vehicle Selection

```dart
// In selectVehicle() method
final jenisKendaraan = vehicle['jenis_kendaraan']?.toString();

if (jenisKendaraan != null && _tarifs.isNotEmpty) {
  final matchingTarif = _tarifs.firstWhere(
    (tarif) => tarif['jenis_kendaraan'] == jenisKendaraan,
    orElse: () => <String, dynamic>{},
  );
  
  if (matchingTarif.isNotEmpty) {
    _firstHourRate = _parseDouble(matchingTarif['satu_jam_pertama']);
    _additionalHourRate = _parseDouble(matchingTarif['tarif_parkir_per_jam']);
    
    debugPrint('[BookingProvider] Updated tarif for $jenisKendaraan');
  }
}

// Recalculate cost
if (_bookingDuration != null) {
  calculateCost();
}
```

---

## Expected Behavior

### Admin Edit Tarif

1. Admin login → Dashboard
2. Klik menu "Tarif"
3. Lihat 4 kartu tarif (Roda Dua, Tiga, Empat, Lebih dari Enam)
4. Klik "Edit" pada salah satu kartu
5. Ubah nilai tarif
6. Klik "Simpan Perubahan"
7. Redirect ke halaman tarif dengan success message
8. Kartu tarif menampilkan nilai baru
9. Tabel riwayat menampilkan perubahan

### Mobile App Booking

1. User pilih mall dari map
2. Navigate ke booking page
3. **Tarif dimuat dari mall data**
4. User pilih kendaraan Roda Dua
5. **Tarif update ke tarif Roda Dua**
6. User pilih durasi 3 jam
7. **Cost dihitung: Rp 2.000 + (2 × Rp 1.000) = Rp 4.000**
8. User ganti ke Roda Empat
9. **Tarif update ke tarif Roda Empat**
10. **Cost dihitung: Rp 5.000 + (2 × Rp 3.000) = Rp 11.000**

---

## Troubleshooting

### Issue: 404 error saat klik Edit tarif ✅ FIXED

**Symptom**: Tombol "Edit" mengarah ke halaman 404

**Root Cause**: Tarif tidak ada di database untuk mall tertentu

**Check**:
```bash
cd qparkin_backend
php test_tarif_data.php
```

**Solution**: 
```bash
php check_and_create_tarif.php
```

**Documentation**: See `ADMIN_TARIF_404_FIX_COMPLETE.md`

### Issue: API tidak return tarif

**Check**:
```bash
curl -X GET "http://localhost:8000/api/mall/1" | jq '.data.tarif'
```

**Solution**: Pastikan MallController sudah dimodifikasi

### Issue: Mobile app tidak load tarif

**Check logs**:
```
[BookingProvider] Loaded X tarifs from mall data
```

**Solution**: Pastikan mall data dari API include tarif

### Issue: Cost calculation salah

**Check**:
```dart
debugPrint('[BookingProvider] First hour: $_firstHourRate');
debugPrint('[BookingProvider] Additional: $_additionalHourRate');
```

**Solution**: Pastikan tarif ter-update saat pilih kendaraan

---

## Files to Modify

### Backend
1. `qparkin_backend/app/Http/Controllers/Api/MallController.php`
   - Method: `index()` - line ~40
   - Method: `show()` - line ~80

### Mobile App
1. `qparkin_app/lib/logic/providers/booking_provider.dart`
   - Add field: `_tarifs` - line ~77
   - Method: `initialize()` - line ~180
   - Method: `selectVehicle()` - line ~280

---

## Related Documentation

- `ADMIN_TARIF_ANALYSIS_AND_IMPLEMENTATION.md` - Analisis lengkap
- `ADMIN_TARIF_IMPLEMENTATION_GUIDE.md` - Panduan implementasi detail
- `ADMIN_TARIF_404_FIX_COMPLETE.md` - Fix untuk 404 error ✅
- `qparkin_backend/resources/views/admin/tarif.blade.php` - UI tarif
- `qparkin_backend/resources/views/admin/edit-tarif.blade.php` - UI edit
- `qparkin_backend/test_tarif_data.php` - Diagnostic script
- `qparkin_backend/check_and_create_tarif.php` - Fix script

---

**Last Updated**: 2026-01-12

**Status**: Implementation Complete ✅ | 404 Error Fixed ✅
