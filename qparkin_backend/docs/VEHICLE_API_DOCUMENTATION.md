# Vehicle API Documentation

## Overview
API endpoints untuk manajemen kendaraan pengguna di aplikasi QParkin Mobile.

## Base URL
```
https://your-domain.com/api
```

## Authentication
Semua endpoint memerlukan authentication menggunakan Sanctum token.

**Header Required:**
```
Authorization: Bearer {token}
Content-Type: application/json
Accept: application/json
```

---

## Endpoints

### 1. Get All Vehicles
Mendapatkan semua kendaraan milik user yang sedang login.

**Endpoint:** `GET /kendaraan`

**Response Success (200):**
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
      "foto_path": "vehicles/1234567890_1_avanza.jpg",
      "foto_url": "https://your-domain.com/storage/vehicles/1234567890_1_avanza.jpg",
      "is_active": true,
      "created_at": "2026-01-01T10:00:00.000000Z",
      "updated_at": "2026-01-01T10:00:00.000000Z",
      "last_used_at": "2026-01-01T15:30:00.000000Z",
      "statistics": {
        "parking_count": 15,
        "total_parking_minutes": 1200,
        "total_cost_spent": 150000,
        "last_parking_date": "2026-01-01T15:30:00.000000Z"
      }
    }
  ]
}
```

---

### 2. Add New Vehicle
Menambahkan kendaraan baru.

**Endpoint:** `POST /kendaraan`

**Request Body (multipart/form-data):**
```
plat_nomor: string (required, max:20, unique)
jenis_kendaraan: enum (required) - "Roda Dua" | "Roda Tiga" | "Roda Empat" | "Lebih dari Enam"
merk: string (required, max:50)
tipe: string (required, max:50)
warna: string (optional, max:50)
is_active: boolean (optional, default: false)
foto: file (optional, image, max:2MB, jpeg/png/jpg)
```

**Example Request:**
```bash
curl -X POST https://your-domain.com/api/kendaraan \
  -H "Authorization: Bearer {token}" \
  -F "plat_nomor=B 1234 XYZ" \
  -F "jenis_kendaraan=Roda Empat" \
  -F "merk=Toyota" \
  -F "tipe=Avanza" \
  -F "warna=Hitam" \
  -F "is_active=true" \
  -F "foto=@/path/to/photo.jpg"
```

**Response Success (201):**
```json
{
  "success": true,
  "message": "Vehicle added successfully",
  "data": {
    "id_kendaraan": 1,
    "plat": "B 1234 XYZ",
    "jenis": "Roda Empat",
    "merk": "Toyota",
    "tipe": "Avanza",
    "warna": "Hitam",
    "foto_path": "vehicles/1234567890_1_avanza.jpg",
    "foto_url": "https://your-domain.com/storage/vehicles/1234567890_1_avanza.jpg",
    "is_active": true,
    "created_at": "2026-01-01T10:00:00.000000Z",
    "updated_at": "2026-01-01T10:00:00.000000Z",
    "last_used_at": null,
    "statistics": {
      "parking_count": 0,
      "total_parking_minutes": 0,
      "total_cost_spent": 0,
      "last_parking_date": null
    }
  }
}
```

**Response Error (422):**
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "plat_nomor": ["The plat nomor has already been taken."],
    "jenis_kendaraan": ["The selected jenis kendaraan is invalid."]
  }
}
```

---

### 3. Get Vehicle Details
Mendapatkan detail kendaraan spesifik.

**Endpoint:** `GET /kendaraan/{id}`

**Response Success (200):**
```json
{
  "success": true,
  "message": "Vehicle retrieved successfully",
  "data": {
    "id_kendaraan": 1,
    "plat": "B 1234 XYZ",
    "jenis": "Roda Empat",
    "merk": "Toyota",
    "tipe": "Avanza",
    "warna": "Hitam",
    "foto_url": "https://your-domain.com/storage/vehicles/1234567890_1_avanza.jpg",
    "is_active": true,
    "created_at": "2026-01-01T10:00:00.000000Z",
    "updated_at": "2026-01-01T10:00:00.000000Z",
    "last_used_at": "2026-01-01T15:30:00.000000Z",
    "statistics": {
      "parking_count": 15,
      "total_parking_minutes": 1200,
      "total_cost_spent": 150000,
      "last_parking_date": "2026-01-01T15:30:00.000000Z"
    }
  }
}
```

**Response Error (404):**
```json
{
  "success": false,
  "message": "Vehicle not found"
}
```

---

### 4. Update Vehicle
Mengupdate data kendaraan.

**Endpoint:** `PUT /kendaraan/{id}`

**Request Body (multipart/form-data):**
```
plat_nomor: string (optional, max:20, unique)
jenis_kendaraan: enum (optional) - "Roda Dua" | "Roda Tiga" | "Roda Empat" | "Lebih dari Enam"
merk: string (optional, max:50)
tipe: string (optional, max:50)
warna: string (optional, max:50)
is_active: boolean (optional)
foto: file (optional, image, max:2MB, jpeg/png/jpg)
```

**Note:** Untuk update dengan foto, gunakan POST dengan `_method=PUT`

**Response Success (200):**
```json
{
  "success": true,
  "message": "Vehicle updated successfully",
  "data": {
    "id_kendaraan": 1,
    "plat": "B 1234 XYZ",
    "jenis": "Roda Empat",
    "merk": "Toyota",
    "tipe": "Avanza",
    "warna": "Merah",
    "foto_url": "https://your-domain.com/storage/vehicles/new_photo.jpg",
    "is_active": true,
    "created_at": "2026-01-01T10:00:00.000000Z",
    "updated_at": "2026-01-01T12:00:00.000000Z",
    "last_used_at": "2026-01-01T15:30:00.000000Z",
    "statistics": {
      "parking_count": 15,
      "total_parking_minutes": 1200,
      "total_cost_spent": 150000,
      "last_parking_date": "2026-01-01T15:30:00.000000Z"
    }
  }
}
```

---

### 5. Delete Vehicle
Menghapus kendaraan.

**Endpoint:** `DELETE /kendaraan/{id}`

**Response Success (200):**
```json
{
  "success": true,
  "message": "Vehicle deleted successfully"
}
```

**Response Error (400):**
```json
{
  "success": false,
  "message": "Cannot delete vehicle with active parking transaction"
}
```

**Response Error (404):**
```json
{
  "success": false,
  "message": "Vehicle not found"
}
```

---

### 6. Set Active Vehicle
Menjadikan kendaraan sebagai kendaraan aktif (utama).

**Endpoint:** `PUT /kendaraan/{id}/set-active`

**Response Success (200):**
```json
{
  "success": true,
  "message": "Vehicle set as active successfully",
  "data": {
    "id_kendaraan": 1,
    "plat": "B 1234 XYZ",
    "jenis": "Roda Empat",
    "merk": "Toyota",
    "tipe": "Avanza",
    "warna": "Hitam",
    "foto_url": "https://your-domain.com/storage/vehicles/1234567890_1_avanza.jpg",
    "is_active": true,
    "created_at": "2026-01-01T10:00:00.000000Z",
    "updated_at": "2026-01-01T12:00:00.000000Z",
    "last_used_at": "2026-01-01T15:30:00.000000Z"
  }
}
```

---

## Data Models

### Vehicle Object
```typescript
{
  id_kendaraan: number,
  plat: string,
  jenis: "Roda Dua" | "Roda Tiga" | "Roda Empat" | "Lebih dari Enam",
  merk: string,
  tipe: string,
  warna: string | null,
  foto_path: string | null,
  foto_url: string | null,
  is_active: boolean,
  created_at: string (ISO 8601),
  updated_at: string (ISO 8601),
  last_used_at: string | null (ISO 8601),
  statistics: {
    parking_count: number,
    total_parking_minutes: number,
    total_cost_spent: number,
    last_parking_date: string | null (ISO 8601)
  }
}
```

---

## Error Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request |
| 401 | Unauthorized |
| 404 | Not Found |
| 422 | Validation Error |
| 500 | Server Error |

---

## Business Rules

1. **Unique Plate Number**: Setiap plat nomor harus unik di seluruh sistem
2. **Active Vehicle**: Hanya satu kendaraan yang bisa aktif per user
3. **Auto-deactivate**: Ketika satu kendaraan di-set aktif, kendaraan lain otomatis non-aktif
4. **Delete Protection**: Kendaraan dengan transaksi parkir aktif tidak bisa dihapus
5. **Photo Storage**: Foto disimpan di `storage/app/public/vehicles/`
6. **Photo Naming**: Format: `{timestamp}_{user_id}_{original_name}`
7. **Plate Format**: Plat nomor otomatis diubah ke uppercase
8. **Timestamps**: `created_at` dan `updated_at` dikelola otomatis oleh Laravel
9. **Last Used**: `last_used_at` diupdate oleh sistem parkir, bukan manual

---

## Testing

### Using cURL

**Get All Vehicles:**
```bash
curl -X GET https://your-domain.com/api/kendaraan \
  -H "Authorization: Bearer {token}" \
  -H "Accept: application/json"
```

**Add Vehicle:**
```bash
curl -X POST https://your-domain.com/api/kendaraan \
  -H "Authorization: Bearer {token}" \
  -F "plat_nomor=B 1234 XYZ" \
  -F "jenis_kendaraan=Roda Empat" \
  -F "merk=Toyota" \
  -F "tipe=Avanza" \
  -F "warna=Hitam" \
  -F "is_active=true"
```

**Set Active:**
```bash
curl -X PUT https://your-domain.com/api/kendaraan/1/set-active \
  -H "Authorization: Bearer {token}" \
  -H "Accept: application/json"
```

**Delete Vehicle:**
```bash
curl -X DELETE https://your-domain.com/api/kendaraan/1 \
  -H "Authorization: Bearer {token}" \
  -H "Accept: application/json"
```

---

## Integration Notes

### Flutter Integration
1. Gunakan `http` atau `dio` package
2. Simpan token di `flutter_secure_storage`
3. Handle multipart untuk upload foto
4. Parse response JSON ke VehicleModel
5. Update UI melalui Provider/Bloc

### Photo Upload
```dart
// Example Flutter code
var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/kendaraan'));
request.headers['Authorization'] = 'Bearer $token';
request.fields['plat_nomor'] = 'B 1234 XYZ';
request.fields['jenis_kendaraan'] = 'Roda Empat';
request.fields['merk'] = 'Toyota';
request.fields['tipe'] = 'Avanza';

if (photoFile != null) {
  request.files.add(await http.MultipartFile.fromPath('foto', photoFile.path));
}

var response = await request.send();
```

---

## Database Schema

```sql
CREATE TABLE kendaraan (
  id_kendaraan BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  id_user BIGINT UNSIGNED,
  plat VARCHAR(20) UNIQUE,
  jenis ENUM('Roda Dua', 'Roda Tiga', 'Roda Empat', 'Lebih dari Enam'),
  merk VARCHAR(50),
  tipe VARCHAR(50),
  warna VARCHAR(50),
  foto_path VARCHAR(255),
  is_active BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP NULL,
  updated_at TIMESTAMP NULL,
  last_used_at TIMESTAMP NULL,
  FOREIGN KEY (id_user) REFERENCES user(id_user)
);
```

---

## Changelog

### Version 1.0.0 (2026-01-01)
- Initial API implementation
- CRUD operations for vehicles
- Photo upload support
- Active vehicle management
- Statistics integration
