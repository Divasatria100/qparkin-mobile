# Slot Reservation Database Migration Guide

## Overview

Dokumen ini menjelaskan proses migrasi database untuk fitur Slot Reservation System. Migrasi ini menambahkan kemampuan untuk mereservasi slot parkir individual dengan sistem hybrid reservation (user pilih lantai, sistem assign slot otomatis).

## Database Changes

### New Tables

#### 1. `parking_floors`
Tabel untuk menyimpan informasi lantai parkir.

```sql
- id_floor (PK)
- id_parkiran (FK -> parkiran.id_parkiran)
- floor_name (varchar 50)
- floor_number (int)
- total_slots (int)
- available_slots (int)
- status (enum: 'active', 'inactive', 'maintenance')
- created_at, updated_at
```

#### 2. `parking_slots`
Tabel untuk menyimpan slot parkir individual.

```sql
- id_slot (PK)
- id_floor (FK -> parking_floors.id_floor)
- slot_code (varchar 20, unique)
- jenis_kendaraan (enum)
- status (enum: 'available', 'occupied', 'reserved', 'maintenance')
- position_x (int, nullable)
- position_y (int, nullable)
- created_at, updated_at
```

#### 3. `slot_reservations`
Tabel untuk tracking reservasi slot (5 menit timeout).

```sql
- id_reservation (PK)
- reservation_id (varchar 36, unique UUID)
- id_slot (FK -> parking_slots.id_slot)
- id_user (FK -> user.id_user)
- id_kendaraan (FK -> kendaraan.id_kendaraan)
- id_floor (FK -> parking_floors.id_floor)
- status (enum: 'active', 'confirmed', 'expired', 'cancelled')
- reserved_at (timestamp)
- expires_at (timestamp)
- confirmed_at (timestamp, nullable)
- created_at, updated_at
```

### Modified Tables

#### 1. `booking`
Menambahkan kolom untuk slot reservation:

```sql
ALTER TABLE booking ADD:
- id_slot (FK -> parking_slots.id_slot, nullable)
- reservation_id (varchar 36, nullable)
```

#### 2. `transaksi_parkir`
Menambahkan kolom untuk tracking slot:

```sql
ALTER TABLE transaksi_parkir ADD:
- id_slot (FK -> parking_slots.id_slot, nullable)
```

#### 3. `mall`
Menambahkan feature flag:

```sql
ALTER TABLE mall ADD:
- has_slot_reservation_enabled (boolean, default false)
```

## Migration Order

Migrations harus dijalankan dalam urutan berikut (sudah diatur dengan timestamp):

1. `2025_12_05_100000_create_parking_floors_table.php`
2. `2025_12_05_100001_create_parking_slots_table.php`
3. `2025_12_05_100002_create_slot_reservations_table.php`
4. `2025_12_05_100003_add_slot_columns_to_booking_table.php`
5. `2025_12_05_100004_add_slot_column_to_transaksi_parkir_table.php`
6. `2025_12_05_100005_add_slot_reservation_feature_flag_to_mall_table.php`

## Running Migrations

### Development Environment

```bash
# Run migrations
php artisan migrate

# Run seeders untuk generate floors dan slots
php artisan db:seed --class=ParkingFloorSeeder
php artisan db:seed --class=ParkingSlotSeeder
```

### Production Environment

```bash
# Backup database terlebih dahulu
mysqldump -u username -p qparkin > backup_before_slot_migration.sql

# Run migrations
php artisan migrate --force

# Verify migrations
php artisan migrate:status

# Run seeders (optional, bisa manual via admin panel)
php artisan db:seed --class=ParkingFloorSeeder --force
php artisan db:seed --class=ParkingSlotSeeder --force
```

## Rollback Procedure

Jika terjadi masalah, rollback dapat dilakukan:

```bash
# Rollback last batch of migrations
php artisan migrate:rollback

# Rollback specific migration
php artisan migrate:rollback --step=6

# Restore from backup
mysql -u username -p qparkin < backup_before_slot_migration.sql
```

## Data Seeding

### ParkingFloorSeeder

Seeder ini akan membuat lantai parkir untuk setiap `parkiran` yang ada:
- Motor: 2 lantai (Lantai 1, Lantai 2)
- Mobil: 3 lantai (Basement 1, Lantai 1, Lantai 2)
- Lainnya: 1 lantai default

### ParkingSlotSeeder

Seeder ini akan membuat slot individual untuk setiap lantai:
- Slot code format: `{PREFIX}-{NUMBER}` (e.g., "A-001", "B-025")
- Prefix berdasarkan floor_number (A=1, B=2, B1=Basement 1, dst)
- Layout grid 10 slot per baris
- Position X dan Y untuk visualisasi

## Backward Compatibility

### Existing Bookings

- Kolom `id_slot` dan `reservation_id` di tabel `booking` adalah **nullable**
- Booking lama tanpa slot akan tetap berfungsi normal
- Sistem akan fallback ke mekanisme lama (kapasitas parkiran) jika slot tidak ada

### Feature Flag

- `has_slot_reservation_enabled` default **false** untuk semua mall
- Admin dapat enable per mall melalui admin panel
- App akan check feature flag sebelum menampilkan UI slot reservation

## Testing Checklist

### After Migration

- [ ] Verify all tables created successfully
- [ ] Check foreign key constraints
- [ ] Verify indexes created
- [ ] Run seeder and check data integrity
- [ ] Test booking creation with slot
- [ ] Test booking creation without slot (backward compatibility)
- [ ] Test slot reservation flow
- [ ] Test reservation expiration (5 minutes)
- [ ] Test slot status updates

### API Testing

- [ ] GET /api/parking/floors/{mallId}
- [ ] GET /api/parking/slots/{floorId}/visualization
- [ ] POST /api/parking/slots/reserve-random
- [ ] POST /api/booking (with slot_id and reservation_id)
- [ ] Test error scenarios (no slots available, expired reservation)

## Performance Considerations

### Indexes

Migrations sudah include indexes untuk:
- `parking_floors`: id_parkiran, status
- `parking_slots`: id_floor, status, jenis_kendaraan, composite (id_floor + status)
- `slot_reservations`: reservation_id, id_user, id_slot, status, expires_at
- `booking`: id_slot, reservation_id
- `transaksi_parkir`: id_slot
- `mall`: has_slot_reservation_enabled

### Caching Strategy

- Cache floor data: 5 minutes
- Cache slot visualization: 2 minutes
- Real-time updates untuk reservation status

### Cleanup Jobs

Buat scheduled job untuk cleanup expired reservations:

```php
// app/Console/Kernel.php
$schedule->call(function () {
    SlotReservation::expired()->each(function ($reservation) {
        $reservation->expire();
    });
})->everyMinute();
```

## Troubleshooting

### Migration Fails

**Error: Foreign key constraint fails**
- Pastikan parent tables sudah ada sebelum child tables
- Check migration order

**Error: Duplicate column**
- Mungkin migration sudah pernah dijalankan
- Check dengan `php artisan migrate:status`
- Rollback jika perlu

### Seeder Issues

**Error: Parkiran not found**
- Pastikan tabel `parkiran` sudah ada data
- Run `DatabaseSeeder` atau manual insert data parkiran

**Error: Duplicate slot_code**
- Hapus data lama di `parking_slots`
- Re-run seeder

## Support

Untuk pertanyaan atau issue terkait migration:
1. Check migration status: `php artisan migrate:status`
2. Check logs: `storage/logs/laravel.log`
3. Verify database structure: `DESCRIBE table_name;`

## Version History

- **v1.0.0** (2025-12-05): Initial slot reservation migration
  - Created parking_floors, parking_slots, slot_reservations tables
  - Added slot columns to booking and transaksi_parkir
  - Added feature flag to mall table
