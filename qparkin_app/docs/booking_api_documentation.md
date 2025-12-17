# Booking Feature API Documentation

## Overview
This document provides comprehensive documentation for all API endpoints used by the Booking feature in the QPARKIN mobile application.

## Base URL
```
Production: https://api.qparkin.com
Development: http://localhost:8000
```

## Authentication
All API endpoints require authentication using Bearer token in the Authorization header:
```
Authorization: Bearer <access_token>
```

---

## Endpoints

### 1. Get Parking Floors

Retrieves the list of parking floors for a specific mall with availability information.

**Endpoint:** `GET /api/parking/floors/{mallId}`

**Headers:**
```json
{
  "Authorization": "Bearer <access_token>"
}
```

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| mallId | string | Yes | Unique identifier of the mall |

**Example Request:**
```
GET /api/parking/floors/MALL001
Headers:
  Authorization: Bearer <access_token>
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id_floor": "f1",
      "id_mall": "MALL001",
      "floor_number": 1,
      "floor_name": "Lantai 1",
      "total_slots": 50,
      "available_slots": 12,
      "occupied_slots": 35,
      "reserved_slots": 3,
      "last_updated": "2025-01-15T14:30:00Z"
    },
    {
      "id_floor": "f2",
      "id_mall": "MALL001",
      "floor_number": 2,
      "floor_name": "Lantai 2",
      "total_slots": 60,
      "available_slots": 25,
      "occupied_slots": 30,
      "reserved_slots": 5,
      "last_updated": "2025-01-15T14:30:00Z"
    }
  ]
}
```

**Error Responses:**

**404 Not Found:**
```json
{
  "success": false,
  "message": "Mall tidak ditemukan",
  "error_code": "MALL_NOT_FOUND"
}
```

**401 Unauthorized:**
```json
{
  "success": false,
  "message": "Token tidak valid atau telah kadaluarsa",
  "error_code": "UNAUTHORIZED"
}
```

---

### 2. Get Slots for Visualization

Retrieves parking slot data for visualization purposes (non-interactive display).

**Endpoint:** `GET /api/parking/slots/{floorId}/visualization`

**Headers:**
```json
{
  "Authorization": "Bearer <access_token>"
}
```

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| floorId | string | Yes | Unique identifier of the floor |

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| vehicle_type | string | No | Filter by vehicle type (Roda Dua, Roda Empat, etc.) |

**Example Request:**
```
GET /api/parking/slots/f1/visualization?vehicle_type=Roda%20Empat
Headers:
  Authorization: Bearer <access_token>
```

**Success Response (200 OK):**
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
      "last_updated": "2025-01-15T14:30:00Z"
    },
    {
      "id_slot": "s2",
      "id_floor": "f1",
      "slot_code": "A02",
      "status": "occupied",
      "slot_type": "regular",
      "position_x": 1,
      "position_y": 0,
      "last_updated": "2025-01-15T14:30:00Z"
    },
    {
      "id_slot": "s3",
      "id_floor": "f1",
      "slot_code": "A03",
      "status": "available",
      "slot_type": "disableFriendly",
      "position_x": 2,
      "position_y": 0,
      "last_updated": "2025-01-15T14:30:00Z"
    }
  ],
  "meta": {
    "total_slots": 50,
    "available_slots": 12,
    "occupied_slots": 35,
    "reserved_slots": 3
  }
}
```

**Slot Status Values:**
- `available` - Slot is free and can be reserved
- `occupied` - Slot is currently in use
- `reserved` - Slot is reserved but not yet occupied
- `disabled` - Slot is unavailable (maintenance, etc.)

**Slot Type Values:**
- `regular` - Standard parking slot
- `disableFriendly` - Accessible parking slot for disabled persons

**Error Responses:**

**404 Not Found:**
```json
{
  "success": false,
  "message": "Lantai tidak ditemukan",
  "error_code": "FLOOR_NOT_FOUND"
}
```

---

### 3. Reserve Random Slot

Reserves a random available slot on the specified floor. The system automatically assigns a specific slot.

**Endpoint:** `POST /api/parking/slots/reserve-random`

**Headers:**
```json
{
  "Authorization": "Bearer <access_token>",
  "Content-Type": "application/json"
}
```

**Request Body:**
```json
{
  "id_floor": "f1",
  "id_user": "u123",
  "vehicle_type": "Roda Empat",
  "duration_minutes": 5
}
```

**Request Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id_floor | string | Yes | Unique identifier of the floor |
| id_user | string | Yes | Unique identifier of the user |
| vehicle_type | string | Yes | Type of vehicle (Roda Dua, Roda Empat, etc.) |
| duration_minutes | integer | No | Reservation duration in minutes (default: 5) |

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Slot A15 berhasil direservasi untuk 5 menit",
  "data": {
    "reservation_id": "r123",
    "slot_id": "s15",
    "slot_code": "A15",
    "floor_name": "Lantai 1",
    "floor_number": "1",
    "slot_type": "regular",
    "reserved_at": "2025-01-15T14:30:00Z",
    "expires_at": "2025-01-15T14:35:00Z",
    "is_active": true
  }
}
```

**Error Responses:**

**404 Not Found - No Slots Available:**
```json
{
  "success": false,
  "message": "Tidak ada slot tersedia di lantai ini",
  "error_code": "NO_SLOTS_AVAILABLE",
  "data": {
    "floor_id": "f1",
    "floor_name": "Lantai 1",
    "suggested_floors": [
      {
        "id_floor": "f2",
        "floor_name": "Lantai 2",
        "available_slots": 15
      },
      {
        "id_floor": "f3",
        "floor_name": "Lantai 3",
        "available_slots": 8
      }
    ]
  }
}
```

**409 Conflict - User Already Has Reservation:**
```json
{
  "success": false,
  "message": "Anda sudah memiliki reservasi slot aktif",
  "error_code": "RESERVATION_CONFLICT",
  "data": {
    "existing_reservation_id": "r122",
    "slot_code": "B10",
    "expires_at": "2025-01-15T14:33:00Z"
  }
}
```

**400 Bad Request - Invalid Floor:**
```json
{
  "success": false,
  "message": "Lantai tidak valid atau tidak tersedia",
  "error_code": "INVALID_FLOOR"
}
```

**408 Request Timeout:**
```json
{
  "success": false,
  "message": "Waktu reservasi habis. Silakan coba lagi.",
  "error_code": "RESERVATION_TIMEOUT"
}
```

---

### 4. Create Booking

Creates a new parking booking for the authenticated user.

**Endpoint:** `POST /api/booking/create`

**Headers:**
```json
{
  "Authorization": "Bearer <access_token>",
  "Content-Type": "application/json"
}
```

**Request Body:**
```json
{
  "id_mall": "MALL001",
  "id_kendaraan": "VEH001",
  "waktu_mulai": "2025-11-26T10:00:00Z",
  "durasi_jam": 2,
  "waktu_selesai": "2025-11-26T12:00:00Z",
  "id_slot": "s15",
  "reservation_id": "r123",
  "notes": "Optional booking notes"
}
```

**Request Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id_mall | string | Yes | Unique identifier of the mall |
| id_kendaraan | string | Yes | Unique identifier of the vehicle |
| waktu_mulai | datetime | Yes | Booking start time (ISO 8601 format) |
| durasi_jam | integer | Yes | Booking duration in hours (1-12) |
| waktu_selesai | datetime | Yes | Calculated end time (ISO 8601 format) |
| id_slot | string | No | Unique identifier of reserved slot (if using slot reservation) |
| reservation_id | string | No | Reservation ID from random slot reservation |
| notes | string | No | Optional notes for the booking |

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Booking berhasil dibuat",
  "data": {
    "id_transaksi": "TRX20251126001",
    "id_booking": "BKG20251126001",
    "qr_code": "QR_TRX20251126001_BKG20251126001",
    "id_mall": "MALL001",
    "id_parkiran": "P001",
    "id_kendaraan": "VEH001",
    "id_slot": "s15",
    "slot_code": "A15",
    "floor_name": "Lantai 1",
    "waktu_mulai": "2025-11-26T10:00:00Z",
    "waktu_selesai": "2025-11-26T12:00:00Z",
    "durasi_booking": 2,
    "status": "aktif",
    "biaya_estimasi": 11000.0,
    "diboking_pada": "2025-11-26T09:45:00Z"
  }
}
```

**Note:** The `id_slot`, `slot_code`, and `floor_name` fields are included when booking is created with slot reservation. For backward compatibility, these fields are optional and bookings can still be created without slot reservation (automatic assignment).

**Error Responses:**

**400 Bad Request - Validation Error:**
```json
{
  "success": false,
  "message": "Data booking tidak valid",
  "error_code": "VALIDATION_ERROR",
  "errors": {
    "waktu_mulai": "Waktu mulai harus di masa depan",
    "durasi_jam": "Durasi harus antara 1-12 jam"
  }
}
```

**409 Conflict - Booking Conflict:**
```json
{
  "success": false,
  "message": "Anda sudah memiliki booking aktif",
  "error_code": "BOOKING_CONFLICT",
  "data": {
    "existing_booking_id": "BKG20251126000"
  }
}
```

**410 Gone - Reservation Expired:**
```json
{
  "success": false,
  "message": "Reservasi slot telah berakhir. Silakan reservasi ulang.",
  "error_code": "RESERVATION_EXPIRED",
  "data": {
    "reservation_id": "r123",
    "expired_at": "2025-01-15T14:35:00Z"
  }
}
```

**404 Not Found - Slot Unavailable:**
```json
{
  "success": false,
  "message": "Slot tidak tersedia untuk waktu yang dipilih",
  "error_code": "SLOT_UNAVAILABLE",
  "data": {
    "available_slots": 0,
    "suggested_times": [
      "2025-11-26T11:00:00Z",
      "2025-11-26T13:00:00Z"
    ]
  }
}
```

**401 Unauthorized:**
```json
{
  "success": false,
  "message": "Token tidak valid atau telah kadaluarsa",
  "error_code": "UNAUTHORIZED"
}
```

**500 Internal Server Error:**
```json
{
  "success": false,
  "message": "Terjadi kesalahan server",
  "error_code": "SERVER_ERROR"
}
```

---

### 5. Check Slot Availability

Checks the number of available parking slots for a specific time period.

**Endpoint:** `GET /api/booking/check-availability`

**Headers:**
```json
{
  "Authorization": "Bearer <access_token>"
}
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| mall_id | string | Yes | Unique identifier of the mall |
| vehicle_type | string | Yes | Type of vehicle (Roda Dua, Roda Tiga, Roda Empat, Lebih dari Enam) |
| start_time | datetime | Yes | Booking start time (ISO 8601 format) |
| duration_hours | integer | Yes | Booking duration in hours |

**Example Request:**
```
GET /api/booking/check-availability?mall_id=MALL001&vehicle_type=Roda%20Empat&start_time=2025-11-26T10:00:00Z&duration_hours=2
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "available_slots": 15,
    "total_slots": 50,
    "mall_id": "MALL001",
    "vehicle_type": "Roda Empat",
    "checked_at": "2025-11-26T09:45:00Z"
  }
}
```

**Error Responses:**

**400 Bad Request:**
```json
{
  "success": false,
  "message": "Parameter tidak valid",
  "error_code": "VALIDATION_ERROR",
  "errors": {
    "start_time": "Format waktu tidak valid"
  }
}
```

**404 Not Found:**
```json
{
  "success": false,
  "message": "Mall tidak ditemukan",
  "error_code": "NOT_FOUND"
}
```

---

### 6. Check Active Booking

Checks if the authenticated user has an active booking.

**Endpoint:** `GET /api/booking/check-active`

**Headers:**
```json
{
  "Authorization": "Bearer <access_token>"
}
```

**Success Response (200 OK) - Has Active Booking:**
```json
{
  "success": true,
  "has_active_booking": true,
  "data": {
    "id_booking": "BKG20251126001",
    "id_transaksi": "TRX20251126001",
    "status": "aktif",
    "waktu_mulai": "2025-11-26T10:00:00Z",
    "waktu_selesai": "2025-11-26T12:00:00Z"
  }
}
```

**Success Response (200 OK) - No Active Booking:**
```json
{
  "success": true,
  "has_active_booking": false
}
```

**Error Responses:**

**401 Unauthorized:**
```json
{
  "success": false,
  "message": "Token tidak valid atau telah kadaluarsa",
  "error_code": "UNAUTHORIZED"
}
```

---

### 7. Get Vehicles

Retrieves the list of vehicles registered by the authenticated user.

**Endpoint:** `GET /api/vehicles`

**Headers:**
```json
{
  "Authorization": "Bearer <access_token>"
}
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id_kendaraan": "VEH001",
      "plat_nomor": "B1234XYZ",
      "jenis_kendaraan": "Roda Empat",
      "merk": "Toyota",
      "tipe": "Avanza",
      "warna": "Hitam"
    },
    {
      "id_kendaraan": "VEH002",
      "plat_nomor": "B5678ABC",
      "jenis_kendaraan": "Roda Dua",
      "merk": "Honda",
      "tipe": "Beat",
      "warna": "Merah"
    }
  ]
}
```

**Error Responses:**

**401 Unauthorized:**
```json
{
  "success": false,
  "message": "Token tidak valid atau telah kadaluarsa",
  "error_code": "UNAUTHORIZED"
}
```

---

### 8. Get Tariff

Retrieves parking tariff information for a specific mall and vehicle type.

**Endpoint:** `GET /api/tariff`

**Headers:**
```json
{
  "Authorization": "Bearer <access_token>"
}
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| mall_id | string | Yes | Unique identifier of the mall |
| vehicle_type | string | Yes | Type of vehicle |

**Example Request:**
```
GET /api/tariff?mall_id=MALL001&vehicle_type=Roda%20Empat
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id_tarif": "TARIF001",
    "id_mall": "MALL001",
    "jenis_kendaraan": "Roda Empat",
    "tarif_jam_pertama": 5000.0,
    "tarif_per_jam": 3000.0,
    "tarif_maksimal_harian": 50000.0,
    "berlaku_dari": "2025-01-01T00:00:00Z",
    "berlaku_sampai": null
  }
}
```

**Error Responses:**

**404 Not Found:**
```json
{
  "success": false,
  "message": "Tarif tidak ditemukan",
  "error_code": "NOT_FOUND"
}
```

---

## Error Codes Reference

| Error Code | HTTP Status | Description |
|------------|-------------|-------------|
| VALIDATION_ERROR | 400 | Request data validation failed |
| UNAUTHORIZED | 401 | Invalid or expired authentication token |
| NOT_FOUND | 404 | Requested resource not found |
| MALL_NOT_FOUND | 404 | Mall not found |
| FLOOR_NOT_FOUND | 404 | Floor not found |
| NO_SLOTS_AVAILABLE | 404 | No parking slots available on the floor |
| BOOKING_CONFLICT | 409 | User already has an active booking |
| RESERVATION_CONFLICT | 409 | User already has an active slot reservation |
| SLOT_UNAVAILABLE | 404 | No parking slots available for requested time |
| RESERVATION_EXPIRED | 410 | Slot reservation has expired |
| RESERVATION_TIMEOUT | 408 | Slot reservation request timed out |
| INVALID_FLOOR | 400 | Floor is invalid or unavailable |
| NETWORK_ERROR | - | Client-side network connection error |
| TIMEOUT_ERROR | 408 | Request timeout |
| SERVER_ERROR | 500 | Internal server error |

---

## Rate Limiting

API requests are rate-limited to prevent abuse:
- **Limit:** 100 requests per minute per user
- **Headers:** Rate limit information is included in response headers:
  ```
  X-RateLimit-Limit: 100
  X-RateLimit-Remaining: 95
  X-RateLimit-Reset: 1732608000
  ```

**Rate Limit Exceeded Response (429):**
```json
{
  "success": false,
  "message": "Terlalu banyak permintaan. Silakan coba lagi nanti.",
  "error_code": "RATE_LIMIT_EXCEEDED",
  "retry_after": 60
}
```

---

## Retry Logic

The mobile app implements automatic retry logic for failed requests:
- **Max Retries:** 3 attempts
- **Retry Delay:** Exponential backoff (1s, 2s, 4s)
- **Retryable Errors:** Network errors, timeouts, 5xx server errors
- **Non-Retryable Errors:** 4xx client errors (except 408 timeout)

---

## Testing

### Test Credentials
```
Email: test@qparkin.com
Password: Test123!
Token: test_token_12345
```

### Test Mall IDs
- MALL001: Mega Mall Batam Centre
- MALL002: BCS Mall
- MALL003: Harbour Bay Mall

### Test Vehicle IDs
- VEH001: B1234XYZ (Roda Empat)
- VEH002: B5678ABC (Roda Dua)

---

## Changelog

### Version 2.0.0 (2025-12-05)
- Added slot reservation endpoints
- Added GET /api/parking/floors/{mallId} endpoint
- Added GET /api/parking/slots/{floorId}/visualization endpoint
- Added POST /api/parking/slots/reserve-random endpoint
- Updated Create Booking endpoint to support optional slot reservation
- Added new error codes for slot reservation
- Documented backward compatibility for bookings without slot reservation

### Version 1.0.0 (2025-11-26)
- Initial API documentation
- All booking endpoints documented
- Error codes standardized
- Rate limiting implemented

---

## Support

For API issues or questions:
- Email: api-support@qparkin.com
- Slack: #api-support
- Documentation: https://docs.qparkin.com/api
