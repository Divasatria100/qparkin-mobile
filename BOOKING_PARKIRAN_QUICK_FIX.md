# Booking Parkiran Quick Fix Guide

## Problem
Error saat konfirmasi booking: **"Parkiran tidak tersedia, silahkan pilih mall lain"**

## Quick Diagnosis

```bash
cd qparkin_backend
php check_parkiran.php
```

Jika ada mall dengan status `⚠️ NO PARKIRAN FOUND`, lanjutkan ke fix.

## Quick Fix (2 menit)

### Step 1: Create Missing Parkiran

```bash
cd qparkin_backend
php create_missing_parkiran.php
```

Output yang diharapkan:
```
✅ Created parkiran: Area Parkir Mega Mall Batam Centre (ID: 2)
✅ Created parkiran: Area Parkir One Batam Mall (ID: 3)
✅ Created parkiran: Area Parkir SNL Food Bengkong (ID: 4)

=== Summary ===
Parkiran created: 3
```

### Step 2: Verify Fix

```bash
php check_parkiran.php
```

Semua mall harus menampilkan `✅` dengan parkiran.

### Step 3: Test API (Optional)

```bash
# Windows
test-parkiran-api.bat

# Linux/Mac
./test-parkiran-api.sh
```

### Step 4: Test Mobile App

1. Restart Flutter app
2. Pilih mall yang sebelumnya error
3. Isi form booking
4. Klik "Konfirmasi Booking"
5. ✅ Booking harus berhasil

## What Was Fixed

### Mobile App Changes
- ✅ Better error messages when parkiran not available
- ✅ Visual warning banner in booking page
- ✅ Early validation before booking confirmation

### Backend Changes
- ✅ Created missing parkiran for 3 malls
- ✅ All malls now have default parkiran configuration

### Database Changes
```
Before:
- Mega Mall Batam Centre: ❌ No parkiran
- One Batam Mall: ❌ No parkiran  
- SNL Food Bengkong: ❌ No parkiran
- Panbil Mall: ✅ Has parkiran

After:
- Mega Mall Batam Centre: ✅ Has parkiran (ID: 2)
- One Batam Mall: ✅ Has parkiran (ID: 3)
- SNL Food Bengkong: ✅ Has parkiran (ID: 4)
- Panbil Mall: ✅ Has parkiran (ID: 1)
```

## Admin Mall Next Steps

Setelah parkiran dibuat otomatis, admin mall harus:

1. **Login ke dashboard admin mall**
2. **Buka halaman "Parkiran"**
3. **Edit parkiran yang baru dibuat:**
   - Sesuaikan `kapasitas` jika perlu
   - Atur `jumlah_lantai` (jumlah lantai parkir)
   - Tambahkan lantai parkir dengan konfigurasi slot
   - Atur tarif parkir per jenis kendaraan

## Troubleshooting

### Error: "Column 'lantai' not found"
**Cause:** Script menggunakan kolom yang salah.
**Fix:** Gunakan script yang sudah diperbaiki (menggunakan `jumlah_lantai`).

### Error: "SQLSTATE[23000]: Integrity constraint violation"
**Cause:** Parkiran sudah ada untuk mall tersebut.
**Fix:** Normal, script akan skip mall yang sudah punya parkiran.

### Booking masih error setelah fix
**Cause:** Flutter app masih menggunakan data lama.
**Fix:** 
1. Stop Flutter app
2. Restart: `flutter run --dart-define=API_URL=http://192.168.x.xx:8000`
3. Clear app data jika perlu

### API mengembalikan empty array
**Cause:** Parkiran belum dibuat atau status mall bukan 'active'.
**Fix:**
```bash
php check_parkiran.php  # Verify status
php create_missing_parkiran.php  # Create if missing
```

## Prevention for Future

### 1. Auto-create parkiran saat mall approval

Edit `AdminMallRegistrationController.php`:

```php
use App\Models\Parkiran;

public function approve($id) {
    // ... existing approval code ...
    
    // Auto-create default parkiran
    Parkiran::create([
        'id_mall' => $mall->id_mall,
        'nama_parkiran' => 'Area Parkir ' . $mall->nama_mall,
        'kode_parkiran' => 'P' . str_pad($mall->id_mall, 3, '0', STR_PAD_LEFT),
        'kapasitas' => 100,
        'jumlah_lantai' => 1,
        'status' => 'Tersedia',
    ]);
    
    return response()->json(['success' => true]);
}
```

### 2. Add validation in mall seeder

Edit `database/seeders/MallSeeder.php`:

```php
foreach ($malls as $mallData) {
    $mall = Mall::create($mallData);
    
    // Always create default parkiran
    Parkiran::create([
        'id_mall' => $mall->id_mall,
        'nama_parkiran' => 'Area Parkir ' . $mall->nama_mall,
        'kode_parkiran' => 'P' . str_pad($mall->id_mall, 3, '0', STR_PAD_LEFT),
        'kapasitas' => 100,
        'jumlah_lantai' => 1,
        'status' => 'Tersedia',
    ]);
}
```

## Files Created/Modified

### New Files
- `qparkin_backend/check_parkiran.php` - Check parkiran status
- `qparkin_backend/create_missing_parkiran.php` - Create missing parkiran
- `test-parkiran-api.bat` - Test API endpoints
- `BOOKING_PARKIRAN_NOT_AVAILABLE_FIX.md` - Complete documentation
- `BOOKING_PARKIRAN_QUICK_FIX.md` - This quick guide

### Modified Files
- `qparkin_app/lib/logic/providers/booking_provider.dart` - Better error handling
- `qparkin_app/lib/presentation/screens/booking_page.dart` - Visual warning banner

## Summary

✅ **Problem identified:** 3 malls had no parkiran in database
✅ **Root cause:** Parkiran not created during mall setup
✅ **Quick fix:** Run `create_missing_parkiran.php` script
✅ **Prevention:** Auto-create parkiran on mall approval
✅ **User experience:** Clear error messages and warnings

**Total fix time:** ~2 minutes
**Impact:** All malls now support booking functionality
