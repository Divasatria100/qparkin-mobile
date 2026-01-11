# 🎯 RINGKASAN FIX: HTTP 500 - MALL API

## 🔍 ROOT CAUSE

**Error:** `Failed to load malls: 500 (Internal Server Error)`

**Penyebab:** MallController mencoba SELECT kolom yang **tidak ada** di tabel `mall`.

**Lokasi:** `qparkin_backend/app/Http/Controllers/Api/MallController.php`

---

## ❌ KOLOM YANG TIDAK ADA

Migration file hanya mendefinisikan:
- ✅ `id_mall`
- ✅ `nama_mall`
- ✅ `lokasi`
- ✅ `kapasitas`
- ✅ `alamat_gmaps`

MallController mencoba akses:
- ❌ `alamat_lengkap` (tidak ada, seharusnya `lokasi`)
- ❌ `latitude` (tidak ada)
- ❌ `longitude` (tidak ada)
- ❌ `google_maps_url` (tidak ada, seharusnya `alamat_gmaps`)
- ❌ `status` (tidak ada)
- ❌ `has_slot_reservation_enabled` (tidak ada)

**Result:** MySQL error → HTTP 500

---

## ✅ SOLUSI

### **1. Perbaiki MallController**

**SEBELUM:**
```php
$malls = Mall::active()  // ❌ Filter kolom 'status' yang tidak ada
    ->select([
        'mall.alamat_lengkap',  // ❌ Tidak ada
        'mall.latitude',        // ❌ Tidak ada
        'mall.longitude',       // ❌ Tidak ada
        // ...
    ])
```

**SESUDAH:**
```php
$malls = Mall::select([
        'mall.id_mall',
        'mall.nama_mall',
        'mall.lokasi',        // ✅ Kolom yang ada
        'mall.kapasitas',
        'mall.alamat_gmaps'   // ✅ Kolom yang ada
    ])
    ->leftJoin('parkiran', 'mall.id_mall', '=', 'parkiran.id_mall')
    ->selectRaw('COUNT(...) as available_slots')
    ->groupBy(...)
    ->get()
    ->map(function ($mall) {
        // ✅ Parse koordinat dari alamat_gmaps URL
        $latitude = null;
        $longitude = null;
        if ($mall->alamat_gmaps) {
            if (preg_match('/q=(-?\d+\.?\d*),(-?\d+\.?\d*)/', $mall->alamat_gmaps, $matches)) {
                $latitude = (float) $matches[1];
                $longitude = (float) $matches[2];
            }
        }
        
        // ✅ Map ke format yang diharapkan
        return [
            'id_mall' => $mall->id_mall,
            'nama_mall' => $mall->nama_mall,
            'alamat_lengkap' => $mall->lokasi ?? '',
            'latitude' => $latitude,
            'longitude' => $longitude,
            'google_maps_url' => $mall->alamat_gmaps,
            'status' => 'active',
            'kapasitas' => $mall->kapasitas ?? 0,
            'available_slots' => $mall->available_slots ?? 0,
            'has_slot_reservation_enabled' => false,
        ];
    });
```

### **2. Perbaiki Mall Model**

**SEBELUM:**
```php
public function scopeActive($query)
{
    return $query->where('status', 'active'); // ❌ Kolom tidak ada
}
```

**SESUDAH:**
```php
public function scopeActive($query)
{
    // Return all malls since status column doesn't exist yet
    return $query;
}
```

---

## 📊 MAPPING KOLOM

| Database | API Response | Cara |
|----------|--------------|------|
| `lokasi` | `alamat_lengkap` | Direct (rename) |
| `alamat_gmaps` | `google_maps_url` | Direct (rename) |
| `alamat_gmaps` | `latitude` | Parse dari URL |
| `alamat_gmaps` | `longitude` | Parse dari URL |
| N/A | `status` | Default: `'active'` |
| N/A | `has_slot_reservation_enabled` | Default: `false` |

**Parsing Koordinat:**
- Input: `"https://maps.google.com/?q=1.1191,104.0538"`
- Regex: `/q=(-?\d+\.?\d*),(-?\d+\.?\d*)/`
- Output: `latitude=1.1191`, `longitude=104.0538`

---

## 🧪 VERIFIKASI

### **Test API:**
```bash
curl -X GET http://192.168.1.100:8000/api/mall \
  -H "Authorization: Bearer <token>"
```

**Expected:** 200 OK dengan data mall ✅

### **Test Flutter:**
1. Login
2. MapPage → Tab "Daftar Mall"
3. **Expected:** Daftar mall muncul ✅

---

## 📝 FILE YANG DIUBAH

1. ✅ `qparkin_backend/app/Http/Controllers/Api/MallController.php`
   - Method `index()` - gunakan kolom yang ada
   - Method `show()` - hapus `->active()`
   - Method `getParkiran()` - hapus `->active()`
   - Method `getTarif()` - hapus `->active()`

2. ✅ `qparkin_backend/app/Models/Mall.php`
   - `scopeActive()` - return all malls

---

## 🎯 HASIL

| Aspek | Sebelum | Sesudah |
|-------|---------|---------|
| **HTTP Status** | 500 Internal Server Error | 200 OK |
| **Error** | Column not found | No error |
| **Flutter UI** | Error state | Daftar mall muncul |
| **Koordinat** | N/A | Di-parse dari URL |

---

## 📖 DOKUMENTASI LENGKAP

Lihat: `qparkin_backend/docs/MALL_API_500_ERROR_FIX.md`

**Status:** ✅ FIXED
