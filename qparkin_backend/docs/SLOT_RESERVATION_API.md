# Slot Reservation API Documentation

## Overview

This document describes the new slot reservation API endpoints that enable hybrid slot reservation functionality in the QParkin mobile application.

## Authentication

All endpoints require authentication using Laravel Sanctum. Include the bearer token in the Authorization header:

```
Authorization: Bearer {token}
```

## Endpoints

### 1. Get Parking Floors

Retrieve a list of parking floors for a specific mall with real-time availability information.

**Endpoint:** `GET /api/parking/floors/{mallId}`

**Parameters:**
- `mallId` (path, required): The ID of the mall

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id_floor": "f1",
      "id_mall": "123",
      "floor_number": 1,
      "floor_name": "Lantai 1",
      "total_slots": 50,
      "available_slots": 12,
      "occupied_slots": 35,
      "reserved_slots": 3,
      "last_updated": "2025-01-15T14:30:00+07:00"
    },
    {
      "id_floor": "f2",
      "id_mall": "123",
      "floor_number": 2,
      "floor_name": "Lantai 2",
      "total_slots": 60,
      "available_slots": 25,
      "occupied_slots": 30,
      "reserved_slots": 5,
      "last_updated": "2025-01-15T14:30:00+07:00"
    }
  ]
}
```

**Status Codes:**
- `200 OK`: Successfully retrieved floors
- `401 Unauthorized`: Missing or invalid authentication token
- `500 Internal Server Error`: Server error

---

### 2. Get Slots for Visualization

Retrieve slot data for visualization purposes (non-interactive display). This endpoint provides the current status of all slots on a specific floor.

**Endpoint:** `GET /api/parking/slots/{floorId}/visualization`

**Parameters:**
- `floorId` (path, required): The ID of the parking floor
- `vehicle_type` (query, optional): Filter slots by vehicle type (e.g., "Roda Empat", "Roda Dua")

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id_slot": "s1",
      "id_floor": "f1",
      "slot_code": "A01",
      "status": "available",
      "slot_type": "regular",
      "position_x": 0,
      "position_y": 0,
      "last_updated": "2025-01-15T14:30:00+07:00"
    },
    {
      "id_slot": "s2",
      "id_floor": "f1",
      "slot_code": "A02",
      "status": "occupied",
      "slot_type": "regular",
      "position_x": 1,
      "position_y": 0,
      "last_updated": "2025-01-15T14:30:00+07:00"
    },
    {
      "id_slot": "s3",
      "id_floor": "f1",
      "slot_code": "A03",
      "status": "reserved",
      "slot_type": "disableFriendly",
      "position_x": 2,
      "position_y": 0,
      "last_updated": "2025-01-15T14:30:00+07:00"
    }
  ]
}
```

**Slot Status Values:**
- `available`: Slot is free and can be reserved
- `occupied`: Slot is currently in use
- `reserved`: Slot is temporarily reserved (5-minute timeout)
- `disabled`: Slot is not available for use

**Slot Type Values:**
- `regular`: Standard parking slot
- `disableFriendly`: Accessible parking slot for disabled persons

**Status Codes:**
- `200 OK`: Successfully retrieved slots
- `401 Unauthorized`: Missing or invalid authentication token
- `500 Internal Server Error`: Server error

---

### 3. Reserve Random Slot

Reserve a random available slot on a specified floor. The system automatically selects and locks an available slot for the user.

**Endpoint:** `POST /api/parking/slots/reserve-random`

**Request Body:**
```json
{
  "id_floor": "f1",
  "id_user": "u123",
  "vehicle_type": "Roda Empat",
  "duration_minutes": 5
}
```

**Parameters:**
- `id_floor` (required): The ID of the parking floor
- `id_user` (required): The ID of the user making the reservation
- `vehicle_type` (required): Type of vehicle ("Roda Empat", "Roda Dua", etc.)
- `duration_minutes` (optional): Reservation duration in minutes (default: 5, max: 30)

**Response (Success):**
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
  },
  "message": "Slot A15 berhasil direservasi untuk 5 menit"
}
```

**Response (No Slots Available):**
```json
{
  "success": false,
  "message": "NO_SLOTS_AVAILABLE",
  "error": "Tidak ada slot tersedia di lantai ini untuk jenis kendaraan yang dipilih"
}
```

**Status Codes:**
- `201 Created`: Slot successfully reserved
- `400 Bad Request`: Invalid request parameters
- `401 Unauthorized`: Missing or invalid authentication token
- `404 Not Found`: No available slots
- `422 Unprocessable Entity`: Validation errors
- `500 Internal Server Error`: Server error

**Important Notes:**
- Reservations expire after the specified duration (default 5 minutes)
- Expired reservations are automatically cleaned up by a scheduled task
- The reserved slot is marked as "reserved" and cannot be selected by other users
- Users must complete their booking before the reservation expires

---

### 4. Create Booking (Updated)

Create a new parking booking. This endpoint now supports optional slot reservation.

**Endpoint:** `POST /api/booking`

**Request Body (With Slot Reservation):**
```json
{
  "id_parkiran": "p123",
  "id_kendaraan": "k456",
  "waktu_mulai": "2025-01-15T16:00:00",
  "durasi_booking": 2,
  "id_slot": "s15",
  "reservation_id": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Request Body (Without Slot Reservation - Auto-Assignment):**
```json
{
  "id_parkiran": "p123",
  "id_kendaraan": "k456",
  "waktu_mulai": "2025-01-15T16:00:00",
  "durasi_booking": 2
}
```

**Parameters:**
- `id_parkiran` (required): The ID of the parking area
- `id_kendaraan` (required): The ID of the vehicle
- `waktu_mulai` (required): Booking start time (ISO 8601 format)
- `durasi_booking` (required): Booking duration in hours (minimum 1)
- `id_slot` (optional): The ID of the reserved slot
- `reservation_id` (optional): The reservation ID from slot reservation

**Response (Success):**
```json
{
  "success": true,
  "message": "Booking berhasil dibuat",
  "data": {
    "id_transaksi": "t789",
    "id_slot": "s15",
    "reservation_id": "550e8400-e29b-41d4-a716-446655440000",
    "waktu_mulai": "2025-01-15T16:00:00+07:00",
    "waktu_selesai": "2025-01-15T18:00:00+07:00",
    "durasi_booking": 2,
    "status": "confirmed",
    "dibooking_pada": "2025-01-15T14:30:00+07:00"
  }
}
```

**Response (Invalid Reservation):**
```json
{
  "success": false,
  "message": "INVALID_RESERVATION",
  "error": "Reservasi tidak valid atau sudah kadaluarsa"
}
```

**Response (Reservation Expired):**
```json
{
  "success": false,
  "message": "RESERVATION_EXPIRED",
  "error": "Reservasi telah kadaluarsa"
}
```

**Response (No Slots Available - Auto-Assignment):**
```json
{
  "success": false,
  "message": "NO_SLOTS_AVAILABLE",
  "error": "Tidak ada slot tersedia"
}
```

**Status Codes:**
- `201 Created`: Booking successfully created
- `400 Bad Request`: Invalid reservation or request parameters
- `401 Unauthorized`: Missing or invalid authentication token
- `404 Not Found`: No available slots (auto-assignment mode)
- `422 Unprocessable Entity`: Validation errors
- `500 Internal Server Error`: Server error

**Backward Compatibility:**
- If `id_slot` and `reservation_id` are not provided, the system will automatically assign an available slot
- This ensures existing booking flows continue to work without modification

---

### 5. Cleanup Expired Reservations

Manually trigger cleanup of expired slot reservations. This is primarily for administrative purposes as cleanup runs automatically every minute.

**Endpoint:** `POST /api/parking/slots/cleanup-expired`

**Response:**
```json
{
  "success": true,
  "message": "Cleaned up 3 expired reservations"
}
```

**Status Codes:**
- `200 OK`: Cleanup completed successfully
- `401 Unauthorized`: Missing or invalid authentication token
- `500 Internal Server Error`: Server error

---

## Workflow Example

### Complete Slot Reservation and Booking Flow

1. **Get Available Floors**
   ```
   GET /api/parking/floors/123
   ```

2. **View Slot Availability (Optional)**
   ```
   GET /api/parking/slots/f1/visualization?vehicle_type=Roda%20Empat
   ```

3. **Reserve a Random Slot**
   ```
   POST /api/parking/slots/reserve-random
   {
     "id_floor": "f1",
     "id_user": "u123",
     "vehicle_type": "Roda Empat",
     "duration_minutes": 5
   }
   ```
   
   Response includes `reservation_id` and `slot_id`

4. **Create Booking with Reserved Slot**
   ```
   POST /api/booking
   {
     "id_parkiran": "p123",
     "id_kendaraan": "k456",
     "waktu_mulai": "2025-01-15T16:00:00",
     "durasi_booking": 2,
     "id_slot": "s15",
     "reservation_id": "550e8400-e29b-41d4-a716-446655440000"
   }
   ```

### Legacy Booking Flow (Without Slot Reservation)

1. **Create Booking (Auto-Assignment)**
   ```
   POST /api/booking
   {
     "id_parkiran": "p123",
     "id_kendaraan": "k456",
     "waktu_mulai": "2025-01-15T16:00:00",
     "durasi_booking": 2
   }
   ```
   
   System automatically assigns an available slot

---

## Error Handling

### Common Error Responses

**Validation Error (422):**
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "id_floor": ["The id floor field is required."],
    "id_user": ["The id user field is required."]
  }
}
```

**Authentication Error (401):**
```json
{
  "message": "Unauthenticated."
}
```

**Server Error (500):**
```json
{
  "success": false,
  "message": "Failed to reserve slot",
  "error": "Database connection error"
}
```

---

## Scheduled Tasks

### Automatic Reservation Cleanup

The system automatically cleans up expired reservations every minute using Laravel's task scheduler.

**Schedule:** Every 1 minute

**Action:**
- Finds all reservations with `status = 'active'` and `expires_at <= now()`
- Updates reservation status to `'expired'`
- Releases the reserved slot (marks as `'available'`)

**To enable the scheduler, add to crontab:**
```bash
* * * * * cd /path-to-project && php artisan schedule:run >> /dev/null 2>&1
```

---

## Database Schema

### slot_reservations Table

| Column | Type | Description |
|--------|------|-------------|
| id_reservation | BIGINT | Primary key |
| reservation_id | VARCHAR(36) | UUID for reservation |
| id_slot | BIGINT | Foreign key to parking_slots |
| id_user | BIGINT | Foreign key to users |
| id_kendaraan | BIGINT | Foreign key to kendaraan (nullable) |
| id_floor | BIGINT | Foreign key to parking_floors |
| status | ENUM | 'active', 'confirmed', 'expired', 'cancelled' |
| reserved_at | TIMESTAMP | When reservation was created |
| expires_at | TIMESTAMP | When reservation expires |
| confirmed_at | TIMESTAMP | When reservation was confirmed (nullable) |

### booking Table (Updated)

| Column | Type | Description |
|--------|------|-------------|
| id_transaksi | BIGINT | Primary key |
| id_slot | BIGINT | Foreign key to parking_slots (nullable) |
| reservation_id | VARCHAR(36) | UUID from slot_reservations (nullable) |
| waktu_mulai | TIMESTAMP | Booking start time |
| waktu_selesai | TIMESTAMP | Booking end time |
| durasi_booking | INT | Duration in hours |
| status | VARCHAR | Booking status |
| dibooking_pada | TIMESTAMP | When booking was created |

---

## Testing

Run the feature tests:

```bash
php artisan test --filter=SlotReservationApiTest
```

Individual test methods:
```bash
php artisan test --filter=it_can_reserve_a_random_slot
php artisan test --filter=it_can_create_booking_with_slot_reservation
php artisan test --filter=it_can_create_booking_without_slot_reservation_using_auto_assignment
```

---

## Migration Guide

See [SLOT_RESERVATION_MIGRATION_GUIDE.md](SLOT_RESERVATION_MIGRATION_GUIDE.md) for detailed migration instructions.

---

## Support

For issues or questions, please contact the development team or create an issue in the project repository.
