# Vehicle Integration Architecture Diagram

## System Overview

```
┌────────────────────────────────────────────────────────────────────┐
│                         USER DEVICE (Mobile)                        │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │                    Flutter Application                        │ │
│  │                                                                │ │
│  │  ┌────────────────────────────────────────────────────────┐  │ │
│  │  │              Presentation Layer (UI)                    │  │ │
│  │  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │  │ │
│  │  │  │   Tambah     │  │     List     │  │    Detail    │ │  │ │
│  │  │  │  Kendaraan   │  │  Kendaraan   │  │   Vehicle    │ │  │ │
│  │  │  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘ │  │ │
│  │  └─────────┼──────────────────┼──────────────────┼─────────┘  │ │
│  │            └──────────────────┼──────────────────┘             │ │
│  │                               │                                │ │
│  │  ┌────────────────────────────▼────────────────────────────┐  │ │
│  │  │           Logic Layer (State Management)                 │  │ │
│  │  │                                                           │  │ │
│  │  │              ┌─────────────────────┐                     │  │ │
│  │  │              │  ProfileProvider    │                     │  │ │
│  │  │              │  ┌───────────────┐  │                     │  │ │
│  │  │              │  │ _vehicles     │  │                     │  │ │
│  │  │              │  │ _isLoading    │  │                     │  │ │
│  │  │              │  │ _errorMessage │  │                     │  │ │
│  │  │              │  └───────────────┘  │                     │  │ │
│  │  │              │  ┌───────────────┐  │                     │  │ │
│  │  │              │  │ fetchVehicles()│  │                     │  │ │
│  │  │              │  │ addVehicle()  │  │                     │  │ │
│  │  │              │  │ deleteVehicle()│  │                     │  │ │
│  │  │              │  │ setActive()   │  │                     │  │ │
│  │  │              │  └───────────────┘  │                     │  │ │
│  │  │              └──────────┬──────────┘                     │  │ │
│  │  └─────────────────────────┼────────────────────────────────┘  │ │
│  │                            │                                    │ │
│  │  ┌─────────────────────────▼────────────────────────────────┐  │ │
│  │  │            Data Layer (Services)                          │  │ │
│  │  │                                                            │  │ │
│  │  │         ┌──────────────────────────────┐                  │  │ │
│  │  │         │   VehicleApiService          │                  │  │ │
│  │  │         │  ┌────────────────────────┐  │                  │  │ │
│  │  │         │  │ baseUrl                │  │                  │  │ │
│  │  │         │  │ _storage (token)       │  │                  │  │ │
│  │  │         │  └────────────────────────┘  │                  │  │ │
│  │  │         │  ┌────────────────────────┐  │                  │  │ │
│  │  │         │  │ getVehicles()          │  │                  │  │ │
│  │  │         │  │ addVehicle()           │  │                  │  │ │
│  │  │         │  │ updateVehicle()        │  │                  │  │ │
│  │  │         │  │ deleteVehicle()        │  │                  │  │ │
│  │  │         │  │ setActiveVehicle()     │  │                  │  │ │
│  │  │         │  └────────────────────────┘  │                  │  │ │
│  │  │         └──────────────┬───────────────┘                  │  │ │
│  │  └────────────────────────┼──────────────────────────────────┘  │ │
│  └───────────────────────────┼─────────────────────────────────────┘ │
└────────────────────────────────┼───────────────────────────────────────┘
                                 │
                                 │ HTTPS Request
                                 │ Authorization: Bearer {token}
                                 │
┌────────────────────────────────▼───────────────────────────────────────┐
│                         SERVER (Backend)                                │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐ │
│  │                    Laravel Application                            │ │
│  │                                                                    │ │
│  │  ┌────────────────────────────────────────────────────────────┐  │ │
│  │  │                  Routes (api.php)                           │  │ │
│  │  │                                                              │  │ │
│  │  │  GET    /api/kendaraan          → index()                   │  │ │
│  │  │  POST   /api/kendaraan          → store()                   │  │ │
│  │  │  GET    /api/kendaraan/{id}     → show()                    │  │ │
│  │  │  PUT    /api/kendaraan/{id}     → update()                  │  │ │
│  │  │  DELETE /api/kendaraan/{id}     → destroy()                 │  │ │
│  │  │  PUT    /api/kendaraan/{id}/set-active → setActive()        │  │ │
│  │  │                                                              │  │ │
│  │  └────────────────────────┬───────────────────────────────────┘  │ │
│  │                           │                                       │ │
│  │  ┌────────────────────────▼───────────────────────────────────┐  │ │
│  │  │         Middleware (auth:sanctum)                           │  │ │
│  │  │  - Verify token                                             │  │ │
│  │  │  - Get authenticated user                                   │  │ │
│  │  └────────────────────────┬───────────────────────────────────┘  │ │
│  │                           │                                       │ │
│  │  ┌────────────────────────▼───────────────────────────────────┐  │ │
│  │  │         KendaraanController                                 │  │ │
│  │  │                                                              │  │ │
│  │  │  index()    → Get all user vehicles                         │  │ │
│  │  │  store()    → Validate, upload photo, save                  │  │ │
│  │  │  show()     → Get vehicle details                           │  │ │
│  │  │  update()   → Update vehicle data                           │  │ │
│  │  │  destroy()  → Delete vehicle                                │  │ │
│  │  │  setActive()→ Set as active vehicle                         │  │ │
│  │  │                                                              │  │ │
│  │  └────────────────────────┬───────────────────────────────────┘  │ │
│  │                           │                                       │ │
│  │  ┌────────────────────────▼───────────────────────────────────┐  │ │
│  │  │              Kendaraan Model                                │  │ │
│  │  │                                                              │  │ │
│  │  │  - Relationships (user, transaksiParkir)                    │  │ │
│  │  │  - Scopes (active, forUser)                                 │  │ │
│  │  │  - Computed attributes (foto_url)                           │  │ │
│  │  │  - Methods (getStatistics)                                  │  │ │
│  │  │                                                              │  │ │
│  │  └────────────────────────┬───────────────────────────────────┘  │ │
│  └───────────────────────────┼──────────────────────────────────────┘ │
└────────────────────────────────┼───────────────────────────────────────┘
                                 │
                                 │ SQL Queries
                                 │
┌────────────────────────────────▼───────────────────────────────────────┐
│                         DATABASE (MySQL)                                │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐ │
│  │                      Tables                                       │ │
│  │                                                                    │ │
│  │  ┌─────────────────┐      ┌─────────────────┐                    │ │
│  │  │      user       │      │   kendaraan     │                    │ │
│  │  ├─────────────────┤      ├─────────────────┤                    │ │
│  │  │ id_user (PK)    │◄─────┤ id_kendaraan(PK)│                    │ │
│  │  │ name            │      │ id_user (FK)    │                    │ │
│  │  │ email           │      │ plat (UNIQUE)   │                    │ │
│  │  │ nomor_hp        │      │ jenis           │                    │ │
│  │  │ role            │      │ merk            │                    │ │
│  │  │ saldo_poin      │      │ tipe            │                    │ │
│  │  │ status          │      │ warna           │                    │ │
│  │  └─────────────────┘      │ foto_path       │                    │ │
│  │                           │ is_active       │                    │ │
│  │                           │ created_at      │                    │ │
│  │                           │ updated_at      │                    │ │
│  │                           │ last_used_at    │                    │ │
│  │                           └────────┬────────┘                    │ │
│  │                                    │                              │ │
│  │                                    │                              │ │
│  │                           ┌────────▼────────┐                    │ │
│  │                           │ transaksi_parkir│                    │ │
│  │                           ├─────────────────┤                    │ │
│  │                           │ id_transaksi(PK)│                    │ │
│  │                           │ id_kendaraan(FK)│                    │ │
│  │                           │ waktu_masuk     │                    │ │
│  │                           │ waktu_keluar    │                    │ │
│  │                           │ ...             │                    │ │
│  │                           └─────────────────┘                    │ │
│  │                                                                    │ │
│  └──────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐ │
│  │                      Storage                                      │ │
│  │                                                                    │ │
│  │  storage/app/public/vehicles/                                     │ │
│  │  ├── 1234567890_1_avanza.jpg                                      │ │
│  │  ├── 1234567891_1_beat.jpg                                        │ │
│  │  └── ...                                                          │ │
│  │                                                                    │ │
│  │  Accessible via: https://domain.com/storage/vehicles/...          │ │
│  │                                                                    │ │
│  └──────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
```

## Request Flow Example: Add Vehicle

```
┌─────────┐
│  USER   │
└────┬────┘
     │ 1. Fill form & select photo
     ▼
┌─────────────────────┐
│ tambah_kendaraan.dart│
└────┬────────────────┘
     │ 2. Call provider.addVehicle(vehicle, foto)
     ▼
┌─────────────────────┐
│  ProfileProvider    │
└────┬────────────────┘
     │ 3. Call _vehicleApiService.addVehicle(...)
     ▼
┌─────────────────────┐
│ VehicleApiService   │
└────┬────────────────┘
     │ 4. Build multipart request
     │    - Add fields (plat, jenis, merk, tipe, warna, is_active)
     │    - Add file (foto)
     │    - Add header (Authorization: Bearer {token})
     ▼
┌─────────────────────┐
│   HTTP POST         │
│   /api/kendaraan    │
└────┬────────────────┘
     │ 5. HTTPS Request
     ▼
┌─────────────────────┐
│  Laravel Router     │
└────┬────────────────┘
     │ 6. Route to controller
     ▼
┌─────────────────────┐
│ auth:sanctum        │
│ Middleware          │
└────┬────────────────┘
     │ 7. Verify token & get user
     ▼
┌─────────────────────┐
│ KendaraanController │
│ @store              │
└────┬────────────────┘
     │ 8. Validate request
     │    - Check required fields
     │    - Validate plat format
     │    - Check file type/size
     ▼
┌─────────────────────┐
│  Business Logic     │
└────┬────────────────┘
     │ 9. Process data
     │    - Deactivate other vehicles if is_active=true
     │    - Upload photo to storage/vehicles/
     │    - Convert plat to uppercase
     ▼
┌─────────────────────┐
│  Kendaraan Model    │
└────┬────────────────┘
     │ 10. Save to database
     │     INSERT INTO kendaraan (...)
     ▼
┌─────────────────────┐
│  MySQL Database     │
└────┬────────────────┘
     │ 11. Return inserted record
     ▼
┌─────────────────────┐
│  JSON Response      │
│  {                  │
│    success: true,   │
│    data: {...}      │
│  }                  │
└────┬────────────────┘
     │ 12. Parse response
     ▼
┌─────────────────────┐
│ VehicleApiService   │
└────┬────────────────┘
     │ 13. Return VehicleModel
     ▼
┌─────────────────────┐
│  ProfileProvider    │
└────┬────────────────┘
     │ 14. Update state & notifyListeners()
     ▼
┌─────────────────────┐
│  Consumer rebuilds  │
└────┬────────────────┘
     │ 15. UI updates
     ▼
┌─────────┐
│  USER   │ ← Sees new vehicle in list
└─────────┘
```

## Data Structure Mapping

```
Flutter (VehicleModel)          Backend (Kendaraan)         Database (kendaraan)
─────────────────────────────────────────────────────────────────────────────────
idKendaraan: String       ←→    id_kendaraan: int      ←→   id_kendaraan: BIGINT
platNomor: String         ←→    plat: string           ←→   plat: VARCHAR(20)
jenisKendaraan: String    ←→    jenis: enum            ←→   jenis: ENUM(...)
merk: String              ←→    merk: string           ←→   merk: VARCHAR(50)
tipe: String              ←→    tipe: string           ←→   tipe: VARCHAR(50)
warna: String?            ←→    warna: string?         ←→   warna: VARCHAR(50)
isActive: bool            ←→    is_active: bool        ←→   is_active: BOOLEAN
createdAt: DateTime       ←→    created_at: Carbon     ←→   created_at: TIMESTAMP
updatedAt: DateTime       ←→    updated_at: Carbon     ←→   updated_at: TIMESTAMP
lastUsedAt: DateTime?     ←→    last_used_at: Carbon?  ←→   last_used_at: TIMESTAMP
statistics: VehicleStats  ←→    getStatistics()        ←→   (computed from transaksi)
```

## Security Flow

```
┌──────────────┐
│ User Login   │
└──────┬───────┘
       │ POST /api/auth/login
       ▼
┌──────────────┐
│ AuthController│
└──────┬───────┘
       │ Verify credentials
       ▼
┌──────────────┐
│ Generate     │
│ Sanctum Token│
└──────┬───────┘
       │ Return token
       ▼
┌──────────────┐
│ Flutter App  │
│ Store token  │
│ in Secure    │
│ Storage      │
└──────┬───────┘
       │ Include in all requests
       │ Authorization: Bearer {token}
       ▼
┌──────────────┐
│ API Request  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ auth:sanctum │
│ Middleware   │
└──────┬───────┘
       │ Verify token
       │ Get user from token
       ▼
┌──────────────┐
│ Controller   │
│ $user =      │
│ $request->   │
│ user()       │
└──────┬───────┘
       │ Use user ID for queries
       │ WHERE id_user = $user->id_user
       ▼
┌──────────────┐
│ User can only│
│ access their │
│ own vehicles │
└──────────────┘
```

## File Upload Flow

```
┌──────────────┐
│ User selects │
│ photo        │
└──────┬───────┘
       │ File object
       ▼
┌──────────────┐
│ Image Picker │
│ (Flutter)    │
└──────┬───────┘
       │ Compress if needed
       ▼
┌──────────────┐
│ Multipart    │
│ Request      │
└──────┬───────┘
       │ foto: File
       ▼
┌──────────────┐
│ Laravel      │
│ Validation   │
└──────┬───────┘
       │ Check:
       │ - Type: jpeg/png/jpg
       │ - Size: < 2MB
       ▼
┌──────────────┐
│ Store File   │
│ storage/app/ │
│ public/      │
│ vehicles/    │
└──────┬───────┘
       │ Generate filename:
       │ {timestamp}_{user_id}_{original}
       ▼
┌──────────────┐
│ Save path    │
│ to database  │
│ foto_path    │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Return URL   │
│ foto_url:    │
│ https://.../ │
│ storage/     │
│ vehicles/... │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Flutter      │
│ displays     │
│ image        │
└──────────────┘
```

## Error Handling Flow

```
┌──────────────┐
│ API Request  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Try-Catch    │
│ Block        │
└──────┬───────┘
       │
       ├─ Success ──────────────────┐
       │                             ▼
       │                      ┌──────────────┐
       │                      │ Return 200   │
       │                      │ {success:true}│
       │                      └──────────────┘
       │
       ├─ Validation Error ─────────┐
       │                             ▼
       │                      ┌──────────────┐
       │                      │ Return 422   │
       │                      │ {errors:{}}  │
       │                      └──────────────┘
       │
       ├─ Not Found ────────────────┐
       │                             ▼
       │                      ┌──────────────┐
       │                      │ Return 404   │
       │                      │ {message:...}│
       │                      └──────────────┘
       │
       ├─ Unauthorized ─────────────┐
       │                             ▼
       │                      ┌──────────────┐
       │                      │ Return 401   │
       │                      │ {message:...}│
       │                      └──────────────┘
       │
       └─ Server Error ─────────────┐
                                     ▼
                              ┌──────────────┐
                              │ Return 500   │
                              │ {error:...}  │
                              └──────────────┘
                                     │
                                     ▼
                              ┌──────────────┐
                              │ Flutter      │
                              │ catches      │
                              │ exception    │
                              └──────┬───────┘
                                     │
                                     ▼
                              ┌──────────────┐
                              │ Show user-   │
                              │ friendly     │
                              │ error message│
                              └──────────────┘
```

---

## Legend

```
┌─────┐
│ Box │  = Component/Process
└─────┘

  │
  ▼     = Data/Control Flow

  ◄─►   = Bidirectional Relationship

 (PK)   = Primary Key
 (FK)   = Foreign Key
```
