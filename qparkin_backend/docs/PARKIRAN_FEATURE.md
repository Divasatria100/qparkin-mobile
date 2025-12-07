# Fitur Parkiran - QPARKIN

## Overview
Fitur parkiran adalah sistem manajemen area parkir yang lengkap untuk admin mall. Fitur ini memungkinkan admin untuk mengelola area parkir dengan sistem lantai dan slot yang terstruktur.

## Fitur Utama

### 1. Daftar Parkiran (`/admin/parkiran`)
- Menampilkan semua area parkir di mall
- Informasi real-time: total lantai, total slot, tersedia, terisi
- Status parkiran: Aktif, Maintenance, Ditutup
- Preview lantai untuk setiap parkiran
- Aksi: Lihat Detail, Edit

### 2. Tambah Parkiran (`/admin/parkiran/create`)
- Form untuk membuat area parkir baru
- Konfigurasi:
  - Nama parkiran
  - Kode parkiran (unik, 3-10 karakter)
  - Status (Tersedia/Maintenance/Ditutup)
  - Jumlah lantai (1-10)
  - Konfigurasi per lantai:
    - Nama lantai
    - Jumlah slot (1-200 per lantai)
- Preview real-time sebelum menyimpan
- Auto-generate slot dengan kode sistematis: `KODE-L1-001`, `KODE-L1-002`, dst.

### 3. Detail Parkiran (`/admin/parkiran/{id}`)
- Overview statistik parkiran
- Grafik utilisasi parkiran
- Detail per lantai dengan progress bar
- Grid slot parkir dengan filter:
  - Filter berdasarkan lantai
  - Filter berdasarkan status (available, occupied, reserved, maintenance)
- Visual coding warna untuk status slot

### 4. Edit Parkiran (`/admin/parkiran/{id}/edit`)
- Edit informasi parkiran
- Update konfigurasi lantai
- Preview perubahan sebelum menyimpan
- Opsi hapus parkiran dengan konfirmasi

## Struktur Database

### Tabel: `parkiran`
- `id_parkiran` (PK)
- `id_mall` (FK)
- `nama_parkiran`
- `kode_parkiran`
- `status` (Tersedia/Ditutup/maintenance)
- `kapasitas` (total slot)
- `jumlah_lantai`

### Tabel: `parking_floors`
- `id_floor` (PK)
- `id_parkiran` (FK)
- `floor_name`
- `floor_number`
- `total_slots`
- `available_slots`
- `status`

### Tabel: `parking_slots`
- `id_slot` (PK)
- `id_floor` (FK)
- `slot_code` (unik)
- `jenis_kendaraan`
- `status` (available/occupied/reserved/maintenance)
- `position_x`, `position_y`

## API Endpoints

### Web Routes (Admin)
```
GET    /admin/parkiran                    - Daftar parkiran
GET    /admin/parkiran/create             - Form tambah parkiran
POST   /admin/parkiran/store              - Simpan parkiran baru
GET    /admin/parkiran/{id}               - Detail parkiran
GET    /admin/parkiran/{id}/edit          - Form edit parkiran
POST   /admin/parkiran/{id}/update        - Update parkiran
DELETE /admin/parkiran/{id}               - Hapus parkiran
```

## Models & Relationships

### Parkiran Model
```php
- belongsTo: Mall
- hasMany: ParkingFloor, TransaksiParkir
- Attributes: total_available_slots, total_occupied_slots, utilization_percentage
```

### ParkingFloor Model
```php
- belongsTo: Parkiran
- hasMany: ParkingSlot, SlotReservation
- Attributes: availability_percentage
```

### ParkingSlot Model
```php
- belongsTo: ParkingFloor
- hasMany: TransaksiParkir, Booking, SlotReservation
- Methods: markAsReserved(), markAsOccupied(), markAsAvailable()
```

## File Structure

### Views
```
resources/views/admin/
├── parkiran.blade.php           # Daftar parkiran
├── tambah-parkiran.blade.php    # Form tambah
├── detail-parkiran.blade.php    # Detail parkiran
└── edit-parkiran.blade.php      # Form edit
```

### CSS
```
public/css/
├── parkiran.css                 # Style daftar
├── tambah-parkiran.css          # Style form tambah
├── detail-parkiran.css          # Style detail
└── edit-parkiran.css            # Style form edit
```

### JavaScript
```
public/js/
├── tambah-parkiran.js           # Logic form tambah
└── edit-parkiran.js             # Logic form edit
```

### Controllers
```
app/Http/Controllers/AdminController.php
- parkiran()           # Index
- createParkiran()     # Show create form
- storeParkiran()      # Store new parkiran
- detailParkiran()     # Show detail
- editParkiran()       # Show edit form
- updateParkiran()     # Update parkiran
- deleteParkiran()     # Delete parkiran
```

## Fitur Tambahan

### Auto-generate Slots
Saat membuat/update parkiran, sistem otomatis:
1. Menghitung total kapasitas dari semua lantai
2. Membuat floor records untuk setiap lantai
3. Generate slot dengan kode sistematis untuk setiap lantai
4. Format kode: `{KODE_PARKIRAN}-L{NOMOR_LANTAI}-{NOMOR_SLOT}`
   - Contoh: `MWR-L1-001`, `MWR-L1-002`, `MWR-L2-001`

### Real-time Preview
- Form tambah dan edit memiliki preview real-time
- Menampilkan perubahan saat user mengetik
- Kalkulasi otomatis total slot dari semua lantai

### Validasi
- Nama parkiran: required, max 255 karakter
- Kode parkiran: required, max 10 karakter, unik
- Jumlah lantai: 1-10
- Jumlah slot per lantai: 1-200

### Konfirmasi Hapus
- Modal konfirmasi dengan input "HAPUS"
- Mencegah penghapusan tidak sengaja
- Cascade delete: hapus floors dan slots terkait

## Integrasi dengan Fitur Lain

### Transaksi Parkir
- Slot dapat di-assign ke transaksi parkir
- Status slot berubah otomatis saat kendaraan masuk/keluar

### Booking/Reservasi
- Slot dapat direservasi oleh customer
- Status slot: reserved

### Dashboard
- Statistik parkiran ditampilkan di dashboard admin
- Real-time availability

## Testing

### Manual Testing Checklist
- [ ] Tambah parkiran baru dengan berbagai konfigurasi lantai
- [ ] Edit parkiran existing
- [ ] Hapus parkiran
- [ ] Filter slot berdasarkan lantai dan status
- [ ] Validasi form (input kosong, invalid)
- [ ] Preview real-time saat input berubah
- [ ] Responsive design (mobile, tablet, desktop)

## Troubleshooting

### Issue: Slot tidak ter-generate
**Solusi**: Pastikan migration `parking_floors` dan `parking_slots` sudah dijalankan

### Issue: Error saat save
**Solusi**: Cek validasi input dan pastikan database connection aktif

### Issue: Preview tidak update
**Solusi**: Cek console browser untuk JavaScript errors

## Future Enhancements
- [ ] Import/export konfigurasi parkiran
- [ ] Visualisasi 2D/3D layout parkiran
- [ ] Bulk edit slots
- [ ] History log perubahan parkiran
- [ ] Analytics utilisasi per lantai
- [ ] Notifikasi saat kapasitas hampir penuh
