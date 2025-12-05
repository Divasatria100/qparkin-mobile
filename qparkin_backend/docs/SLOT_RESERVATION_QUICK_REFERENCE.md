# Slot Reservation API - Quick Reference

## Quick Start

### 1. Reserve a Slot

```bash
POST /api/parking/slots/reserve-random
Authorization: Bearer {token}

{
  "id_floor": "f1",
  "id_user": "u123",
  "vehicle_type": "Roda Empat",
  "duration_minutes": 5
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "reservation_id": "550e8400-e29b-41d4-a716-446655440000",
    "slot_id": "s15",
    "slot_code": "A15",
    "floor_name": "Lantai 1",
    "floor_number": "1",
    "slot_type": "regular",
    "reserved_at": "2025-01-15T14:30:00+07:00",
    "expires_at": "2025-01-15T14:35:00+07:00"
  }
}
```

### 2. Create Booking with Reserved Slot

```bash
POST /api/booking
Authorization: Bearer {token}

{
  "id_parkiran": "p123",
  "id_kendaraan": "k456",
  "waktu_mulai": "2025-01-15T16:00:00",
  "durasi_booking": 2,
  "id_slot": "s15",
  "reservation_id": "550e8400-e29b-41d4-a716-446655440000"
}
```

### 3. Create Booking without Reservation (Auto-Assignment)

```bash
POST /api/booking
Authorization: Bearer {token}

{
  "id_parkiran": "p123",
  "id_kendaraan": "k456",
  "waktu_mulai": "2025-01-15T16:00:00",
  "durasi_booking": 2
}
```

## Common Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/parking/floors/{mallId}` | GET | Get floors with availability |
| `/api/parking/slots/{floorId}/visualization` | GET | Get slot visualization |
| `/api/parking/slots/reserve-random` | POST | Reserve random slot |
| `/api/booking` | POST | Create booking |

## Error Codes

| Code | Meaning | Action |
|------|---------|--------|
| `NO_SLOTS_AVAILABLE` | No slots available | Try different floor or wait |
| `INVALID_RESERVATION` | Reservation invalid | Create new reservation |
| `RESERVATION_EXPIRED` | Reservation expired | Create new reservation |

## Testing

```bash
# Run all slot reservation tests
php artisan test --filter=SlotReservationApiTest

# Run specific test
php artisan test --filter=it_can_reserve_a_random_slot
```

## Scheduler Setup

Add to crontab:
```bash
* * * * * cd /path-to-project && php artisan schedule:run >> /dev/null 2>&1
```

## Key Points

- ✓ Reservations expire after 5 minutes (default)
- ✓ Expired reservations auto-cleanup every minute
- ✓ Backward compatible with old booking flow
- ✓ Transaction-safe slot assignment
- ✓ Real-time availability updates

## Documentation

- Full API Docs: `docs/SLOT_RESERVATION_API.md`
- Implementation Summary: `docs/TASK_15_3_IMPLEMENTATION_SUMMARY.md`
- Migration Guide: `docs/SLOT_RESERVATION_MIGRATION_GUIDE.md`
