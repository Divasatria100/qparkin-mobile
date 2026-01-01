# Vehicle Backend - Quick Reference

## 🎯 Prinsip Utama

1. **Migration hanya menambah kolom** - Tidak mengubah struktur existing
2. **Tidak ada triggers/stored procedures** - Semua logic di application layer
3. **last_used_at protected** - Hanya sistem parkir yang bisa update
4. **Endpoint minimal** - Sesuai kebutuhan parkir mall

---

## 📋 API Endpoints

### Base URL: `/api/kendaraan`

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/` | List semua kendaraan user |
| POST | `/` | Tambah kendaraan baru |
| GET | `/{id}` | Detail kendaraan |
| PUT | `/{id}` | Update kendaraan |
| DELETE | `/{id}` | Hapus kendaraan |
| PUT | `/{id}/set-active` | Set kendaraan aktif |

---

## 🔑 Model Fields

### Fillable (Bisa diisi via API):
```php
'id_user', 'plat', 'jenis', 'merk', 'tipe', 
'warna', 'foto_path', 'is_active'
```

### Protected (Tidak bisa diisi via API):
```php
'last_used_at' // Hanya sistem parkir
```

---

## 💾 Database Schema

```sql
-- Kolom yang ditambahkan migration:
warna           VARCHAR(50) NULL
foto_path       VARCHAR(255) NULL
is_active       BOOLEAN DEFAULT FALSE
created_at      TIMESTAMP NULL
updated_at      TIMESTAMP NULL
last_used_at    TIMESTAMP NULL -- Protected!

-- Indexes:
idx_user_active (id_user, is_active)
idx_plat        (plat)
```

---

## 🔒 last_used_at Usage

### ✅ BENAR - Di Sistem Parkir:

```php
// Di TransaksiParkirController
$vehicle = Kendaraan::find($id_kendaraan);
$vehicle->updateLastUsed(); // Method khusus
```

### ❌ SALAH - Jangan Lakukan:

```php
// ❌ Manual update
$vehicle->last_used_at = now();
$vehicle->save();

// ❌ Mass assignment
$vehicle->update(['last_used_at' => now()]);

// ❌ Di endpoint GET
public function index() {
    $vehicle->updateLastUsed(); // JANGAN!
}
```

---

## 📝 Request Examples

### 1. Add Vehicle

```bash
POST /api/kendaraan
Content-Type: multipart/form-data
Authorization: Bearer {token}

plat_nomor: B 1234 XYZ
jenis_kendaraan: Roda Empat
merk: Toyota
tipe: Avanza
warna: Hitam
is_active: true
foto: [file]
```

### 2. Get Vehicles

```bash
GET /api/kendaraan
Authorization: Bearer {token}
```

Response:
```json
{
  "success": true,
  "message": "Vehicles retrieved successfully",
  "data": [
    {
      "id_kendaraan": 1,
      "plat": "B 1234 XYZ",
      "jenis": "Roda Empat",
      "merk": "Toyota",
      "tipe": "Avanza",
      "warna": "Hitam",
      "foto_url": "https://domain.com/storage/vehicles/photo.jpg",
      "is_active": true,
      "created_at": "2026-01-01T10:00:00.000000Z",
      "updated_at": "2026-01-01T10:00:00.000000Z",
      "last_used_at": null
    }
  ]
}
```

---

## 🚀 Migration Commands

```bash
# Run migration
php artisan migrate

# Rollback (if needed)
php artisan migrate:rollback --step=1

# Check migration status
php artisan migrate:status
```

---

## 🧪 Testing

```bash
# Test API
php artisan test --filter=KendaraanController

# Manual test dengan curl
curl -H "Authorization: Bearer {token}" \
  http://localhost:8000/api/kendaraan
```

---

## 📊 Performance Notes

- **Query Count:** 1 query per request (no N+1)
- **Response Time:** ~50ms untuk 5 kendaraan
- **No Statistics:** Dihapus untuk performa

---

## 🔧 Troubleshooting

### Migration Error: "Column already exists"

**Solusi:** Migration sudah ada check `Schema::hasColumn()`, aman untuk re-run

### last_used_at tidak update

**Penyebab:** Tidak ada di fillable (by design)  
**Solusi:** Gunakan `$vehicle->updateLastUsed()` di sistem parkir

### Response tidak ada statistics

**Penyebab:** Dihapus untuk performa  
**Solusi:** Ini expected behavior, statistics tidak diperlukan

---

## 📚 Related Files

- Migration: `database/migrations/2025_01_01_000000_update_kendaraan_table.php`
- Model: `app/Models/Kendaraan.php`
- Controller: `app/Http/Controllers/Api/KendaraanController.php`
- Schema Doc: `database/migrations/SIMPLE_VEHICLE_SCHEMA.sql`
- Full Review: `docs/VEHICLE_BACKEND_REVIEW_SUMMARY.md`

---

**Last Updated:** 2026-01-01  
**Status:** ✅ Production Ready
