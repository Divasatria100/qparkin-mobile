# Quick Start - Fitur Parkiran

## Setup Database

```bash
# Jalankan migration untuk menambahkan kolom baru
php artisan migrate
```

## Akses Fitur

1. **Login sebagai Admin Mall**
   - URL: `http://localhost:8000/signin`
   - Role: `admin_mall`

2. **Menu Parkiran**
   - Klik menu "Parkiran" di sidebar
   - URL: `http://localhost:8000/admin/parkiran`

## Cara Menggunakan

### Tambah Parkiran Baru

1. Klik tombol **"Tambah Parkiran"**
2. Isi form:
   - **Nama Parkiran**: Contoh "Parkiran Mawar"
   - **Kode Parkiran**: Contoh "MWR" (3-10 karakter)
   - **Status**: Pilih Aktif/Maintenance/Tidak Aktif
   - **Jumlah Lantai**: Masukkan angka 1-10
3. Konfigurasi setiap lantai:
   - Nama lantai akan otomatis terisi "Lantai 1", "Lantai 2", dst
   - Masukkan jumlah slot per lantai (1-200)
4. Lihat preview di sebelah kanan
5. Klik **"Simpan Parkiran"**

### Lihat Detail Parkiran

1. Dari daftar parkiran, klik **"Lihat Detail"**
2. Anda akan melihat:
   - Statistik overview (total lantai, slot, tersedia, terisi)
   - Grafik utilisasi
   - Detail per lantai
   - Grid semua slot parkir
3. Gunakan filter untuk melihat slot tertentu:
   - Filter berdasarkan lantai
   - Filter berdasarkan status

### Edit Parkiran

1. Klik **"Edit"** pada parkiran yang ingin diubah
2. Ubah informasi yang diperlukan
3. Lihat preview perubahan
4. Klik **"Simpan Perubahan"**

### Hapus Parkiran

1. Dari halaman edit, klik **"Hapus Parkiran"**
2. Ketik "HAPUS" untuk konfirmasi
3. Klik **"Hapus Parkiran"** di modal

## Fitur Otomatis

### Auto-generate Slot
Sistem otomatis membuat slot dengan format:
- `{KODE}-L{LANTAI}-{NOMOR}`
- Contoh: `MWR-L1-001`, `MWR-L1-002`, `MWR-L2-001`

### Real-time Preview
- Preview otomatis update saat Anda mengetik
- Menampilkan total slot dari semua lantai
- Menampilkan detail setiap lantai

### Status Slot
- **Available** (Hijau): Slot kosong, siap digunakan
- **Occupied** (Merah): Slot terisi kendaraan
- **Reserved** (Kuning): Slot direservasi customer
- **Maintenance** (Abu): Slot dalam perbaikan

## Struktur Data

### Parkiran
```
Parkiran Mawar (MWR)
├── Lantai 1 (50 slot)
│   ├── MWR-L1-001
│   ├── MWR-L1-002
│   └── ...
├── Lantai 2 (50 slot)
│   ├── MWR-L2-001
│   └── ...
└── Lantai 3 (50 slot)
```

## Testing

### Test Scenario 1: Tambah Parkiran Sederhana
```
Nama: Parkiran Utama
Kode: P01
Status: Tersedia
Lantai: 2
- Lantai 1: 30 slot
- Lantai 2: 30 slot
Total: 60 slot
```

### Test Scenario 2: Parkiran Multi-Lantai
```
Nama: Parkiran Melati
Kode: MLT
Status: Tersedia
Lantai: 5
- Lantai 1: 50 slot
- Lantai 2: 50 slot
- Lantai 3: 50 slot
- Lantai 4: 40 slot
- Lantai 5: 40 slot
Total: 230 slot
```

## Troubleshooting

### Error: "Admin mall data not found"
**Solusi**: Pastikan user yang login memiliki data di tabel `admin_mall` dengan `id_mall` yang valid

### Error: "SQLSTATE[42S22]: Column not found"
**Solusi**: Jalankan migration: `php artisan migrate`

### Slot tidak muncul di detail
**Solusi**: Pastikan parkiran sudah disimpan dengan benar dan refresh halaman

### Preview tidak update
**Solusi**: 
1. Buka browser console (F12)
2. Cek error JavaScript
3. Pastikan file JS sudah di-load: `/js/tambah-parkiran.js`

## Routes

```
GET    /admin/parkiran              → Daftar parkiran
GET    /admin/parkiran/create       → Form tambah
POST   /admin/parkiran/store        → Simpan baru
GET    /admin/parkiran/{id}         → Detail
GET    /admin/parkiran/{id}/edit    → Form edit
POST   /admin/parkiran/{id}/update  → Update
DELETE /admin/parkiran/{id}         → Hapus
```

## Files Modified/Created

### Backend
- ✅ `app/Models/Parkiran.php` - Updated model
- ✅ `app/Http/Controllers/AdminController.php` - Added methods
- ✅ `database/migrations/2025_12_07_add_parkiran_fields.php` - New migration
- ✅ `routes/web.php` - Added routes

### Frontend
- ✅ `resources/views/admin/parkiran.blade.php` - List view
- ✅ `resources/views/admin/tambah-parkiran.blade.php` - Create form
- ✅ `resources/views/admin/detail-parkiran.blade.php` - Detail view
- ✅ `resources/views/admin/edit-parkiran.blade.php` - Edit form

### Assets
- ✅ `public/css/parkiran.css` - List styles
- ✅ `public/css/tambah-parkiran.css` - Create form styles
- ✅ `public/css/detail-parkiran.css` - Detail styles
- ✅ `public/css/edit-parkiran.css` - Edit form styles
- ✅ `public/js/tambah-parkiran.js` - Create form logic
- ✅ `public/js/edit-parkiran.js` - Edit form logic

## Next Steps

1. Test semua fitur secara manual
2. Tambahkan data parkiran untuk testing
3. Integrasikan dengan fitur transaksi parkir
4. Tambahkan validasi tambahan jika diperlukan

## Support

Jika ada masalah, cek:
1. Laravel log: `storage/logs/laravel.log`
2. Browser console untuk JavaScript errors
3. Network tab untuk API errors
