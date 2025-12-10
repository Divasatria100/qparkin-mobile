# Point API Documentation

## Overview
This document describes the Point Management API endpoints for the QPARKIN application.

## Authentication
All endpoints require authentication using Laravel Sanctum. Include the bearer token in the Authorization header:
```
Authorization: Bearer {token}
```

## Endpoints

### 1. Get Point Balance
**Endpoint:** `GET /api/points/balance`

**Description:** Returns the current point balance for the authenticated user.

**Response:**
```json
{
  "success": true,
  "balance": 1250
}
```

**Example:**
```bash
curl -X GET http://localhost:8000/api/points/balance \
  -H "Authorization: Bearer {token}"
```

---

### 2. Get Point History
**Endpoint:** `GET /api/points/history`

**Description:** Returns paginated point transaction history with optional filtering.

**Query Parameters:**
- `page` (optional, integer, min: 1) - Page number for pagination
- `limit` (optional, integer, min: 1, max: 100) - Number of items per page (default: 20)
- `type` (optional, enum: 'tambah', 'kurang') - Filter by transaction type
- `start_date` (optional, date) - Filter by start date (YYYY-MM-DD)
- `end_date` (optional, date) - Filter by end date (YYYY-MM-DD)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id_poin": 1,
      "id_user": 123,
      "id_transaksi": 456,
      "poin": 100,
      "perubahan": "tambah",
      "keterangan": "Reward dari transaksi parkir",
      "waktu": "2024-12-02 10:30:00"
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total": 45,
    "last_page": 3
  }
}
```

**Examples:**
```bash
# Get first page
curl -X GET "http://localhost:8000/api/points/history" \
  -H "Authorization: Bearer {token}"

# Get page 2 with 10 items
curl -X GET "http://localhost:8000/api/points/history?page=2&limit=10" \
  -H "Authorization: Bearer {token}"

# Filter by type (additions only)
curl -X GET "http://localhost:8000/api/points/history?type=tambah" \
  -H "Authorization: Bearer {token}"

# Filter by date range
curl -X GET "http://localhost:8000/api/points/history?start_date=2024-01-01&end_date=2024-12-31" \
  -H "Authorization: Bearer {token}"
```

---

### 3. Get Point Statistics
**Endpoint:** `GET /api/points/statistics`

**Description:** Returns aggregated point statistics for the authenticated user.

**Response:**
```json
{
  "success": true,
  "statistics": {
    "total_earned": 5000,
    "total_used": 1200,
    "this_month_earned": 500,
    "this_month_used": 150
  }
}
```

**Example:**
```bash
curl -X GET http://localhost:8000/api/points/statistics \
  -H "Authorization: Bearer {token}"
```

---

### 4. Use Points
**Endpoint:** `POST /api/points/use`

**Description:** Deducts points from user balance for payment purposes.

**Request Body:**
```json
{
  "amount": 200,
  "transaction_id": "TRX123456",
  "description": "Pembayaran parkir di Mall ABC"
}
```

**Parameters:**
- `amount` (required, integer, min: 1) - Number of points to use
- `transaction_id` (optional, string) - Associated transaction ID
- `description` (optional, string, max: 255) - Description of the usage

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poin berhasil digunakan",
  "new_balance": 1050,
  "points_used": 200
}
```

**Error Response - Insufficient Balance (400):**
```json
{
  "success": false,
  "message": "Saldo poin tidak mencukupi",
  "current_balance": 100,
  "required_amount": 200
}
```

**Error Response - Validation Error (422):**
```json
{
  "success": false,
  "message": "Validation error",
  "errors": {
    "amount": ["The amount field is required."]
  }
}
```

**Examples:**
```bash
# Use points for payment
curl -X POST http://localhost:8000/api/points/use \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 200,
    "transaction_id": "TRX123456",
    "description": "Pembayaran parkir"
  }'

# Use points without transaction ID
curl -X POST http://localhost:8000/api/points/use \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 150
  }'
```

---

## Error Responses

### 401 Unauthorized
Returned when the request lacks valid authentication credentials.
```json
{
  "message": "Unauthenticated."
}
```

### 422 Validation Error
Returned when request parameters fail validation.
```json
{
  "success": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["Error message"]
  }
}
```

### 500 Internal Server Error
Returned when an unexpected error occurs on the server.
```json
{
  "success": false,
  "message": "Error message details"
}
```

---

## Testing with Postman

1. **Login first** to get authentication token:
   ```
   POST /api/login
   Body: { "nomor_hp": "081234567890", "pin": "123456" }
   ```

2. **Copy the token** from the login response

3. **Set Authorization header** in Postman:
   - Type: Bearer Token
   - Token: {paste your token}

4. **Test each endpoint** using the examples above

---

## Database Schema

### Table: user
- `id_user` (bigint, PK)
- `saldo_poin` (int) - Current point balance

### Table: riwayat_poin
- `id_poin` (bigint, PK)
- `id_user` (bigint, FK)
- `id_transaksi` (bigint, FK, nullable)
- `poin` (int) - Amount of points changed
- `perubahan` (enum: 'tambah', 'kurang') - Type of change
- `keterangan` (varchar 255) - Description
- `waktu` (datetime) - Timestamp

---

## Implementation Notes

1. **Atomicity**: The `usePoints` endpoint uses database transactions to ensure atomicity - either both the balance update and history entry succeed, or both fail.

2. **Validation**: All endpoints include comprehensive input validation to prevent invalid data.

3. **Error Handling**: All endpoints include try-catch blocks to handle unexpected errors gracefully.

4. **Pagination**: The history endpoint supports pagination to handle large datasets efficiently.

5. **Filtering**: The history endpoint supports filtering by type and date range for better user experience.

6. **Authentication**: All endpoints are protected by Laravel Sanctum authentication middleware.
