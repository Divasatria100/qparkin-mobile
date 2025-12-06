# Slot Reservation Feature Flag Implementation Guide

## Overview

This guide explains the implementation of the `has_slot_reservation_enabled` feature flag for gradual rollout of slot reservation functionality across different malls.

## Architecture

### Backend (Laravel)

#### Database Schema

**Table: `mall`**
```sql
ALTER TABLE mall 
ADD COLUMN has_slot_reservation_enabled BOOLEAN DEFAULT FALSE AFTER alamat_gmaps,
ADD INDEX idx_has_slot_reservation_enabled (has_slot_reservation_enabled);
```

**Fields:**
- `has_slot_reservation_enabled` (BOOLEAN): Controls whether slot reservation is available for this mall
- Default: `false` (disabled by default for gradual rollout)
- Indexed for query performance

#### Model

**File: `app/Models/Mall.php`**

```php
protected $fillable = [
    'nama_mall',
    'lokasi',
    'kapasitas',
    'alamat_gmaps',
    'has_slot_reservation_enabled'
];

protected $casts = [
    'has_slot_reservation_enabled' => 'boolean',
];
```

#### API Response

All mall endpoints automatically include the feature flag:

```json
{
  "id_mall": 1,
  "nama_mall": "Mega Mall Batam Centre",
  "lokasi": "Jl. Engku Putri no.1, Batam Centre",
  "kapasitas": 200,
  "has_slot_reservation_enabled": true
}
```

### Frontend (Flutter)

#### Model

**File: `lib/data/models/mall_model.dart`**

```dart
class MallModel {
  final bool hasSlotReservationEnabled;
  
  MallModel({
    // ... other fields
    this.hasSlotReservationEnabled = false,
  });
  
  factory MallModel.fromJson(Map<String, dynamic> json) {
    return MallModel(
      // ... other fields
      hasSlotReservationEnabled: json['has_slot_reservation_enabled'] == true ||
          json['has_slot_reservation_enabled'] == 1,
    );
  }
}
```

#### Provider

**File: `lib/logic/providers/booking_provider.dart`**

```dart
bool get isSlotReservationEnabled {
  if (_selectedMall == null) return false;
  return _selectedMall!['has_slot_reservation_enabled'] == true ||
      _selectedMall!['has_slot_reservation_enabled'] == 1;
}
```

#### UI Behavior

**File: `lib/presentation/screens/booking_page.dart`**

```dart
Widget _buildSlotReservationSection(BookingProvider provider, double spacing) {
  // Hide entire section if feature is disabled
  if (!provider.isSlotReservationEnabled) {
    return const SizedBox.shrink();
  }
  
  // Show floor selector, slot visualization, and reservation button
  return Column(
    children: [
      FloorSelectorWidget(...),
      SlotVisualizationWidget(...),
      SlotReservationButton(...),
    ],
  );
}
```

## Setup Instructions

### 1. Run Migration

```bash
# Windows
php artisan migrate --path=database/migrations/2025_12_05_100005_add_slot_reservation_feature_flag_to_mall_table.php

# Or use the setup script
run_slot_reservation_setup.bat
```

### 2. Seed Mall Data

```bash
php artisan db:seed --class=MallSeeder
```

This will create 3 malls:
- **Mega Mall Batam Centre**: `has_slot_reservation_enabled = true`
- **One Batam Mall**: `has_slot_reservation_enabled = true`
- **SNL Food Bengkong**: `has_slot_reservation_enabled = false` (for testing)

### 3. Verify Setup

```sql
SELECT id_mall, nama_mall, has_slot_reservation_enabled 
FROM mall;
```

Expected output:
```
+----------+---------------------------+-------------------------------+
| id_mall  | nama_mall                 | has_slot_reservation_enabled  |
+----------+---------------------------+-------------------------------+
| 1        | Mega Mall Batam Centre    | 1                             |
| 2        | One Batam Mall            | 1                             |
| 3        | SNL Food Bengkong         | 0                             |
+----------+---------------------------+-------------------------------+
```

## Usage

### Enable Slot Reservation for a Mall

```sql
UPDATE mall 
SET has_slot_reservation_enabled = TRUE 
WHERE id_mall = 3;
```

### Disable Slot Reservation for a Mall

```sql
UPDATE mall 
SET has_slot_reservation_enabled = FALSE 
WHERE id_mall = 1;
```

### Query Malls with Slot Reservation

```sql
-- Get all malls with slot reservation enabled
SELECT * FROM mall 
WHERE has_slot_reservation_enabled = TRUE;

-- Get all malls with slot reservation disabled
SELECT * FROM mall 
WHERE has_slot_reservation_enabled = FALSE;
```

## Testing

### Test Scenarios

1. **Mall with Slot Reservation Enabled**
   - Navigate to booking page for "Mega Mall Batam Centre"
   - ✅ Floor selector should be visible
   - ✅ Slot visualization should be visible
   - ✅ Reservation button should be visible

2. **Mall with Slot Reservation Disabled**
   - Navigate to booking page for "SNL Food Bengkong"
   - ✅ Floor selector should be hidden
   - ✅ Slot visualization should be hidden
   - ✅ Reservation button should be hidden
   - ✅ Booking should still work (auto-assignment)

3. **Feature Flag Toggle**
   - Disable feature for a mall
   - Refresh booking page
   - ✅ UI should update immediately

### Manual Testing

```bash
# 1. Start backend
cd qparkin_backend
composer run dev

# 2. Start Flutter app
cd qparkin_app
flutter run --dart-define=API_URL=http://192.168.1.1:8000

# 3. Test booking flow
# - Select "Mega Mall Batam Centre" → Should show slot reservation
# - Select "SNL Food Bengkong" → Should hide slot reservation
```

## Gradual Rollout Strategy

### Phase 1: Pilot (Current)
- Enable for 1-2 malls
- Monitor performance and user feedback
- Fix any issues

### Phase 2: Expansion
- Enable for 50% of malls
- Continue monitoring
- Optimize based on data

### Phase 3: Full Rollout
- Enable for all malls
- Remove feature flag (optional)

### Rollback Plan

If issues occur:

```sql
-- Disable for all malls
UPDATE mall SET has_slot_reservation_enabled = FALSE;

-- Or disable for specific mall
UPDATE mall SET has_slot_reservation_enabled = FALSE WHERE id_mall = 1;
```

## Performance Considerations

### Database Index

The `has_slot_reservation_enabled` column is indexed for fast queries:

```sql
CREATE INDEX idx_has_slot_reservation_enabled 
ON mall(has_slot_reservation_enabled);
```

### Caching

Consider caching mall data with feature flags:

```php
$malls = Cache::remember('malls_with_features', 3600, function () {
    return Mall::select('id_mall', 'nama_mall', 'has_slot_reservation_enabled')
        ->get();
});
```

## Troubleshooting

### Issue: Slot reservation not showing

**Check:**
1. Migration ran successfully
2. Mall has `has_slot_reservation_enabled = true`
3. Frontend is fetching latest mall data
4. No caching issues

**Solution:**
```bash
# Backend
php artisan config:clear
php artisan cache:clear

# Frontend
flutter clean
flutter pub get
```

### Issue: Feature flag not updating

**Check:**
1. Database value is correct
2. API response includes the field
3. Frontend model is parsing correctly

**Debug:**
```dart
// Add debug print in BookingProvider
print('Mall data: $_selectedMall');
print('Feature flag: $isSlotReservationEnabled');
```

## API Documentation

### GET /api/malls

**Response:**
```json
{
  "data": [
    {
      "id_mall": 1,
      "nama_mall": "Mega Mall Batam Centre",
      "lokasi": "Jl. Engku Putri no.1, Batam Centre",
      "kapasitas": 200,
      "has_slot_reservation_enabled": true
    }
  ]
}
```

### GET /api/malls/{id}

**Response:**
```json
{
  "data": {
    "id_mall": 1,
    "nama_mall": "Mega Mall Batam Centre",
    "lokasi": "Jl. Engku Putri no.1, Batam Centre",
    "kapasitas": 200,
    "has_slot_reservation_enabled": true
  }
}
```

## Related Files

### Backend
- `database/migrations/2025_12_05_100005_add_slot_reservation_feature_flag_to_mall_table.php`
- `database/seeders/MallSeeder.php`
- `app/Models/Mall.php`

### Frontend
- `lib/data/models/mall_model.dart`
- `lib/logic/providers/booking_provider.dart`
- `lib/presentation/screens/booking_page.dart`

## References

- [Slot Reservation Architecture](SLOT_RESERVATION_ARCHITECTURE.md)
- [Slot Reservation API](SLOT_RESERVATION_API.md)
- [Task 15 Completion Report](../TASK_15_COMPLETION_REPORT.md)
