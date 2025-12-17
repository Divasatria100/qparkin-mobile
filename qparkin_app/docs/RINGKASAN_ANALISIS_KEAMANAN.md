# RINGKASAN ANALISIS KEAMANAN SISTEM QPARKIN

## IDENTIFIKASI KOMPONEN YANG PERLU DIAUDIT

### 1. AUTENTIKASI DAN OTORISASI PENGGUNA

#### Komponen Kritis:
- **`auth_service.dart`** - Login/register dengan PIN 6 digit + nomor HP
- **Token Management** - Flutter Secure Storage untuk Bearer token
- **Endpoint:** `/api/auth/login`, `/api/auth/register`
- **Role Separation:** Customer (mobile), Admin Mall (web), Super Admin (web)

#### Risiko Teridentifikasi:
- ⚠️ PIN 6 digit = 1 juta kombinasi (relatif lemah)
- ❌ Tidak ada rate limiting untuk brute force prevention
- ❌ Tidak ada token refresh mechanism
- ❌ Tidak ada SSL certificate pinning
- ⚠️ API_URL via environment variable tanpa validasi

---

### 2. AKSES DAN PERUBAHAN DATA PADA BASIS DATA

#### Tabel Sensitif:
**A. Autentikasi:**
- `user` (password, email, no_hp, saldo_poin)
- `customer`, `admin_mall`, `super_admin` (hak_akses)

**B. Transaksi Keuangan:**
- `transaksi_parkir` (biaya, penalty, waktu)
- `pembayaran` (nominal, metode, status)
- `riwayat_poin` (poin, perubahan)

**C. Operasional:**
- `booking` (status, waktu)
- `parkiran` (kapasitas, status)
- `kendaraan` (plat, jenis)

#### Operasi Kritis:
- **CREATE:** Register user, booking, transaksi parkir
- **READ:** Profile, vehicles, slot availability, active parking
- **UPDATE:** Profile, booking status, payment status, poin
- **DELETE:** Vehicle, cancel booking (tidak terlihat implementasi)

#### Risiko Teridentifikasi:
- ❌ Tidak ada soft delete implementation
- ❌ Tidak ada versioning untuk UPDATE operations
- ❌ Tidak ada rollback mechanism untuk transaksi keuangan
- ⚠️ Trigger database untuk otomatisasi (perlu validasi)

---

### 3. ENDPOINT API YANG SENSITIF

#### A. Autentikasi (Public - No Auth Required)
```
POST /api/auth/login
POST /api/auth/register
```
**Risiko:** Brute force, credential stuffing, account enumeration

#### B. Booking (Requires Auth)
```
POST /api/booking/create
GET  /api/booking/check-availability
GET  /api/booking/check-active
```
**Risiko:** Slot manipulation, booking conflict, race condition

#### C. Parking (Requires Auth)
```
GET  /api/parking/active
GET  /api/parking/floors/{mallId}
GET  /api/parking/slots/{floorId}/visualization
POST /api/parking/slots/reserve-random
```
**Risiko:** Unauthorized access, data leakage, slot reservation abuse

#### D. Profile (Requires Auth)
```
GET  /api/profile/user
PUT  /api/profile/user
GET  /api/profile/vehicles
```
**Risiko:** IDOR, horizontal privilege escalation, data manipulation

#### E. Payment (Requires Auth - Assumed)
```
POST /api/payment/process
GET  /api/payment/history
```
**Risiko:** Payment manipulation, unauthorized refund, financial fraud

---

### 4. MEKANISME LOGGING DAN MONITORING

#### Implementasi Saat Ini:
- ✅ Debug logging di services (`debugPrint`)
- ⚠️ Logging mencatat request/response body (potensi sensitive data)
- ❌ Tidak ada centralized logging system
- ❌ Tidak ada audit trail untuk perubahan data kritis
- ❌ Tidak ada real-time alerting

#### Yang Perlu Diaudit:
- Apakah sensitive data (PIN, token, password) ter-log?
- Apakah ada audit trail untuk transaksi keuangan?
- Apakah ada monitoring untuk suspicious activities?
- Apakah log files ter-protect dari unauthorized access?

---

## RENCANA AUDITING SISTEM

### TUJUAN AUDITING

**Umum:**
- Identifikasi kerentanan keamanan
- Validasi integritas data transaksi
- Evaluasi kontrol akses dan autentikasi
- Deteksi potensi unauthorized access dan data leakage

**Spesifik:**
1. Validasi kekuatan PIN 6 digit dan session management
2. Pengujian authorization pada setiap endpoint
3. Verifikasi konsistensi data transaksi dan perhitungan biaya
4. Validasi implementasi HTTPS/TLS dan SSL pinning

### RUANG LINGKUP AUDITING

**Termasuk:**
- Mobile app (Flutter): Services, models, security utils
- Backend API (Laravel): Semua endpoint yang teridentifikasi
- Database (MySQL): Tabel kritis, triggers, constraints
- Configuration: API_URL, secure storage, environment variables

**Tidak Termasuk:**
- Infrastruktur server dan network
- Perangkat keras IoT/gerbang parkir (belum ada)
- Payment gateway eksternal (simulasi)
- Third-party services (Google, Maps)

### METODE AUDITING

**1. Code Review (Static Analysis)**
- Hardcoded credentials
- Input validation
- Error handling
- Authentication & authorization logic

**2. Dynamic Testing (Penetration Testing)**
- Brute force attack
- Session hijacking
- IDOR dan privilege escalation
- API abuse dan rate limiting bypass
- Data integrity manipulation

**3. Database Auditing**
- Access control review
- Data integrity validation
- Audit trail analysis
- Encryption validation

**4. Security Configuration Review**
- Mobile app configuration
- Backend configuration
- Database configuration

---

## RENCANA PENGAMANAN API

### 1. MEKANISME AUTENTIKASI DAN OTORISASI

#### A. Perkuat Autentikasi
**Implementasi Prioritas Tinggi:**
1. **Token Refresh Mechanism**
   - Access token: 15 menit expiry
   - Refresh token: 7 hari expiry
   - Automatic refresh sebelum expiry

2. **Rate Limiting pada Login**
   - Max 5 attempts per 15 menit per IP
   - Max 3 attempts per 15 menit per nomor HP
   - Progressive delay setelah failed attempts

3. **Account Lockout**
   - Lock account setelah 10 failed attempts
   - Unlock via email/SMS verification
   - Admin notification untuk suspicious activities

4. **Multi-Factor Authentication (Optional)**
   - SMS OTP untuk transaksi sensitif
   - Biometric authentication untuk login

#### B. Perkuat Otorisasi
**Implementasi:**
1. **Middleware Authorization**
   ```php
   // Laravel Middleware
   - EnsureTokenIsValid
   - EnsureUserHasRole
   - EnsureResourceOwnership
   ```

2. **Resource Ownership Validation**
   - Setiap request validasi: `user_id == resource.owner_id`
   - Prevent IDOR attacks

3. **Role-Based Access Control (RBAC)**
   - Customer: Akses terbatas ke data sendiri
   - Admin Mall: Akses ke data mall yang dikelola
   - Super Admin: Akses ke semua data

### 2. VALIDASI REQUEST DAN RESPONSE

#### A. Input Validation
**Server-Side Validation (Laravel):**
```php
// Booking Request Validation
'mall_id' => 'required|exists:mall,id_mall',
'vehicle_id' => 'required|exists:kendaraan,id_kendaraan|owned_by:auth_user',
'start_time' => 'required|date|after:now',
'duration' => 'required|integer|min:1|max:24',
```

**Client-Side Validation (Flutter):**
```dart
// Pre-flight validation sebelum API call
- Format nomor HP: +62 format
- PIN: 6 digit numeric
- Duration: 1-24 jam
- Start time: tidak boleh masa lalu
```

#### B. Output Sanitization
- Mask sensitive data di response (PIN, full token)
- Remove stack trace dari error messages
- Consistent error format

#### C. Request Signing (Advanced)
```dart
// Generate signature untuk setiap request
String signature = HMAC-SHA256(
  request_body + timestamp + nonce,
  secret_key
);
headers['X-Signature'] = signature;
headers['X-Timestamp'] = timestamp;
headers['X-Nonce'] = nonce;
```

### 3. PEMBATASAN AKSES (ROLE-BASED ACCESS)

#### Implementasi RBAC Matrix

| Endpoint | Customer | Admin Mall | Super Admin |
|----------|----------|------------|-------------|
| POST /api/auth/login | ✅ | ✅ | ✅ |
| POST /api/booking/create | ✅ | ❌ | ❌ |
| GET /api/parking/active | ✅ | ❌ | ❌ |
| GET /api/profile/user | ✅ (own) | ✅ (own) | ✅ (all) |
| PUT /api/profile/user | ✅ (own) | ✅ (own) | ✅ (all) |
| GET /api/admin/dashboard | ❌ | ✅ (own mall) | ✅ (all) |
| POST /api/admin/tarif | ❌ | ✅ (own mall) | ✅ (all) |
| GET /api/superadmin/reports | ❌ | ❌ | ✅ |

### 4. MITIGASI RISIKO KEAMANAN

#### A. Unauthorized Access Prevention

**1. Token Security**
```dart
// Secure token storage
await _secureStorage.write(
  key: 'auth_token',
  value: token,
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  ),
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ),
);
```

**2. SSL Certificate Pinning**
```dart
// Implement certificate pinning
final client = HttpClient()
  ..badCertificateCallback = (cert, host, port) {
    return cert.sha256 == expectedCertificateHash;
  };
```

**3. API Request Encryption**
- Encrypt sensitive payload (PIN, payment info)
- Use AES-256-GCM for encryption
- Key exchange via Diffie-Hellman

#### B. Data Leakage Prevention

**1. Response Filtering**
```php
// Laravel Resource
class UserResource extends JsonResource {
  public function toArray($request) {
    return [
      'id' => $this->id_user,
      'name' => $this->name,
      'email' => $this->maskEmail($this->email),
      'phone' => $this->maskPhone($this->no_hp),
      'points' => $this->saldo_poin,
      // NEVER return: password, pin, token
    ];
  }
}
```

**2. Logging Sanitization**
```dart
// Remove sensitive data dari logs
debugPrint('[API] Request: ${sanitizeLog(requestBody)}');

String sanitizeLog(String log) {
  return log
    .replaceAll(RegExp(r'"pin":\s*"\d+"'), '"pin":"***"')
    .replaceAll(RegExp(r'"password":\s*"[^"]+"'), '"password":"***"')
    .replaceAll(RegExp(r'"token":\s*"[^"]+"'), '"token":"***"');
}
```

**3. Error Message Sanitization**
```php
// Production error handler
if (app()->environment('production')) {
  return response()->json([
    'success' => false,
    'message' => 'An error occurred. Please try again.',
    'error_code' => 'INTERNAL_ERROR',
  ], 500);
}
```

#### C. API Abuse Prevention

**1. Rate Limiting**
```php
// Laravel Rate Limiting
Route::middleware('throttle:60,1')->group(function () {
  // 60 requests per minute
  Route::post('/booking/create', [BookingController::class, 'create']);
});

Route::middleware('throttle:5,1')->group(function () {
  // 5 requests per minute untuk endpoint sensitif
  Route::post('/auth/login', [AuthController::class, 'login']);
});
```

**2. Request Validation**
- Max request size: 1MB
- Timeout: 30 detik
- Concurrent request limit: 3 per user

**3. Anomaly Detection**
```php
// Detect suspicious patterns
- Multiple failed login attempts
- Rapid booking creation/cancellation
- Unusual API call patterns
- Geographic anomalies (IP location)
```

**4. CAPTCHA untuk Sensitive Operations**
- Login setelah 3 failed attempts
- Booking creation (optional)
- Payment processing

---

## IMPLEMENTASI PRIORITAS

### Phase 1: Critical (Week 1-2)
- [ ] Implement rate limiting pada semua endpoints
- [ ] Add token refresh mechanism
- [ ] Implement SSL certificate pinning
- [ ] Add input validation di semua endpoints
- [ ] Sanitize error messages

### Phase 2: High (Week 3-4)
- [ ] Implement comprehensive audit logging
- [ ] Add request signing mechanism
- [ ] Implement account lockout
- [ ] Add anomaly detection
- [ ] Setup centralized logging

### Phase 3: Medium (Week 5-6)
- [ ] Implement MFA (SMS OTP)
- [ ] Add biometric authentication
- [ ] Implement CAPTCHA
- [ ] Add encryption untuk sensitive payloads
- [ ] Setup real-time monitoring dashboard

### Phase 4: Enhancement (Week 7-8)
- [ ] Penetration testing
- [ ] Security audit
- [ ] Performance optimization
- [ ] Documentation update
- [ ] Team training

---

## MONITORING DAN ALERTING

### Metrics to Monitor:
1. **Authentication:**
   - Failed login attempts
   - Token expiration rate
   - Concurrent sessions per user

2. **API Usage:**
   - Request rate per endpoint
   - Error rate per endpoint
   - Response time percentiles

3. **Security Events:**
   - Unauthorized access attempts
   - Suspicious IP addresses
   - Data manipulation attempts
   - Unusual transaction patterns

### Alerting Rules:
- **Critical:** Immediate notification (SMS + Email)
  - Multiple failed login from same IP
  - Unauthorized admin access attempt
  - Payment manipulation detected

- **High:** Email notification within 15 minutes
  - Rate limit exceeded
  - Unusual API usage pattern
  - Database integrity violation

- **Medium:** Daily digest email
  - High error rate
  - Slow response time
  - Resource usage anomaly

---

## KESIMPULAN

Sistem Qparkin saat ini memiliki fondasi keamanan dasar dengan token-based authentication dan secure storage. Namun, terdapat beberapa gap kritis yang perlu segera ditangani:

**Critical Gaps:**
1. Tidak ada rate limiting (high risk untuk brute force)
2. Tidak ada SSL certificate pinning (MITM attack risk)
3. Tidak ada token refresh (poor UX + security risk)
4. Logging mencatat sensitive data (compliance risk)

**Rekomendasi Prioritas:**
1. Implementasi rate limiting dan account lockout (Week 1)
2. SSL certificate pinning dan token refresh (Week 2)
3. Comprehensive audit logging (Week 3)
4. Penetration testing dan security audit (Week 4)

Dengan implementasi rencana ini, sistem Qparkin akan memiliki postur keamanan yang kuat dan siap untuk production deployment.

---

**Document Version:** 1.0  
**Last Updated:** 14 Desember 2025  
**Next Review:** Setelah Phase 1 implementation
