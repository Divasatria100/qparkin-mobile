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

### 1. Create Booking

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
    "waktu_mulai": "2025-11-26T10:00:00Z",
    "waktu_selesai": "2025-11-26T12:00:00Z",
    "durasi_booking": 2,
    "status": "aktif",
    "biaya_estimasi": 11000.0,
    "diboking_pada": "2025-11-26T09:45:00Z"
  }
}
```

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

### 2. Check Slot Availability

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

### 3. Check Active Booking

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

### 4. Get Vehicles

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

### 5. Get Tariff

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
| BOOKING_CONFLICT | 409 | User already has an active booking |
| SLOT_UNAVAILABLE | 404 | No parking slots available for requested time |
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
