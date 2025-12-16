# RENCANA PENGAMANAN API (API SECURITY PLAN)
## Sistem Qparkin Mobile & Backend

---

## RINGKASAN EKSEKUTIF

Dokumen ini menyajikan rencana komprehensif untuk mengamankan API Qparkin berdasarkan kondisi implementasi saat ini. Rencana ini mencakup mekanisme autentikasi dan otorisasi, validasi request/response, pembatasan akses berbasis role, serta mitigasi risiko keamanan seperti unauthorized access, data leakage, dan API abuse.

**Status Implementasi Saat Ini:**
-  Token-based authentication (Bearer token)
-  Flutter Secure Storage untuk token management
-  Partial input validation
-  No rate limiting implementation
-  No SSL certificate pinning
-  No API request signing

**Target Keamanan:**
- Implementasi defense-in-depth strategy
- Zero-trust architecture untuk API access
- Comprehensive audit logging
- Automated threat detection

**Prioritas Implementasi:**
1. **Critical (Week 1-2):** Rate limiting, SSL pinning, token refresh
2. **High (Week 3-4):** Audit logging, request signing, account lockout
3. **Medium (Week 5-6):** MFA, biometric auth, anomaly detection

---

## DAFTAR ISI

1. Mekanisme Autentikasi dan Otorisasi API
2. Validasi Request dan Response
3. Pembatasan Akses (Role-Based Access Control)
4. Mitigasi Risiko Keamanan
5. Monitoring dan Alerting
6. Implementasi Checklist
7. Kesimpulan

---

## 1. MEKANISME AUTENTIKASI DAN OTORISASI API

### 1.1 Kondisi Autentikasi Saat Ini

**Implementasi Existing:**
```dart
// auth_service.dart - Current Implementation
Future<Map<String, dynamic>> login({
  required String phone,
  required String pin,
  required bool rememberMe,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/auth/login'),
    body: jsonEncode({'nomor_hp': phone, 'pin': pin}),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    await _secureStorage.write(key: 'auth_token', value: data['token']);
    return {'success': true, 'user': data['user']};
  }
  return {'success': false};
}
```

**Flow Autentikasi:**
1. User login dengan nomor HP + PIN 6 digit
2. Backend validasi kredensial
3. Backend generate Bearer token
4. Token disimpan di Flutter Secure Storage
5. Setiap API request: `Authorization: Bearer {token}`

**Kelemahan Teridentifikasi:**
- ❌ Tidak ada token expiration yang jelas
- ❌ Tidak ada token refresh mechanism
- ❌ Tidak ada token revocation
- ⚠️ Token lifetime tidak dikonfigurasi
- ⚠️ Tidak ada device fingerprinting
- ⚠️ Tidak ada session management

### 1.2 Rekomendasi: JWT dengan Access & Refresh Token

**A. Backend Implementation (Laravel)**


```php
// app/Http/Controllers/AuthController.php
use Firebase\JWT\JWT;
use Firebase\JWT\Key;

public function login(Request $request) {
    // Validasi kredensial
    $user = User::where('no_hp', $request->nomor_hp)->first();
    
    if (!$user || !Hash::check($request->pin, $user->password)) {
        return response()->json([
            'success' => false,
            'message' => 'Kredensial tidak valid'
        ], 401);
    }
    
    // Generate Access Token (15 menit)
    $accessToken = JWT::encode([
        'iss' => config('app.url'),
        'sub' => $user->id_user,
        'role' => $user->role,
        'iat' => time(),
        'exp' => time() + (15 * 60),
        'type' => 'access'
    ], config('jwt.secret'), 'HS256');
    
    // Generate Refresh Token (7 hari)
    $refreshToken = JWT::encode([
        'iss' => config('app.url'),
        'sub' => $user->id_user,
        'iat' => time(),
        'exp' => time() + (7 * 24 * 60 * 60),
        'type' => 'refresh'
    ], config('jwt.refresh_secret'), 'HS256');
    
    // Simpan refresh token di database
    RefreshToken::create([
        'user_id' => $user->id_user,
        'token' => hash('sha256', $refreshToken),
        'expires_at' => now()->addDays(7),
        'device_info' => $request->userAgent(),
        'ip_address' => $request->ip()
    ]);
    
    return response()->json([
        'success' => true,
        'access_token' => $accessToken,
        'refresh_token' => $refreshToken,
        'expires_in' => 900,
        'user' => new UserResource($user)
    ]);
}
```

**B. Token Refresh Endpoint**
```php
// POST /api/auth/refresh
public function refresh(Request $request) {
    try {
        $refreshToken = $request->bearerToken();
        $decoded = JWT::decode($refreshToken, 
            new Key(config('jwt.refresh_secret'), 'HS256'));
        
        if ($decoded->type !== 'refresh') {
            throw new Exception('Invalid token type');
        }
        
        // Validasi token di database
        $tokenHash = hash('sha256', $refreshToken);
        $storedToken = RefreshToken::where('token', $tokenHash)
            ->where('user_id', $decoded->sub)
            ->where('expires_at', '>', now())
            ->where('revoked', false)
            ->first();
            
        if (!$storedToken) {
            throw new Exception('Token not found or expired');
        }
        
        // Generate access token baru
        $user = User::findOrFail($decoded->sub);
        $newAccessToken = JWT::encode([
            'iss' => config('app.url'),
            'sub' => $user->id_user,
            'role' => $user->role,
            'iat' => time(),
            'exp' => time() + (15 * 60),
            'type' => 'access'
        ], config('jwt.secret'), 'HS256');
        
        return response()->json([
            'success' => true,
            'access_token' => $newAccessToken,
            'expires_in' => 900
        ]);
        
    } catch (Exception $e) {
        return response()->json([
            'success' => false,
            'message' => 'Invalid or expired refresh token'
        ], 401);
    }
}
```

**C. Client-Side Implementation (Flutter)**


```dart
// lib/data/services/auth_service.dart - Enhanced
class AuthService {
  final _secureStorage = const FlutterSecureStorage();
  Timer? _refreshTimer;
  
  Future<Map<String, dynamic>> login({
    required String phone,
    required String pin,
    required bool rememberMe,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      body: jsonEncode({'nomor_hp': phone, 'pin': pin}),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Simpan tokens
      await _secureStorage.write(
        key: 'access_token', 
        value: data['access_token']
      );
      await _secureStorage.write(
        key: 'refresh_token', 
        value: data['refresh_token']
      );
      await _secureStorage.write(
        key: 'token_expires_at',
        value: DateTime.now()
          .add(Duration(seconds: data['expires_in']))
          .toIso8601String()
      );
      
      // Setup auto-refresh (1 menit sebelum expiry)
      _setupTokenRefresh(data['expires_in'] - 60);
      
      return {'success': true, 'user': data['user']};
    }
    
    return {'success': false, 'message': 'Login failed'};
  }
  
  void _setupTokenRefresh(int secondsUntilRefresh) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer(
      Duration(seconds: secondsUntilRefresh), 
      () async {
        await refreshToken();
      }
    );
  }
  
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(
        key: 'refresh_token'
      );
      if (refreshToken == null) return false;
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/refresh'),
        headers: {
          'Authorization': 'Bearer $refreshToken',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _secureStorage.write(
          key: 'access_token', 
          value: data['access_token']
        );
        await _secureStorage.write(
          key: 'token_expires_at',
          value: DateTime.now()
            .add(Duration(seconds: data['expires_in']))
            .toIso8601String()
        );
        
        _setupTokenRefresh(data['expires_in'] - 60);
        return true;
      }
      
      // Refresh token invalid, logout user
      await logout();
      return false;
      
    } catch (e) {
      debugPrint('[AuthService] Token refresh failed: $e');
      return false;
    }
  }
  
  Future<Map<String, String>> getAuthHeaders() async {
    // Check if token needs refresh
    final expiresAt = await _secureStorage.read(
      key: 'token_expires_at'
    );
    if (expiresAt != null) {
      final expiry = DateTime.parse(expiresAt);
      if (DateTime.now().isAfter(
        expiry.subtract(Duration(minutes: 2))
      )) {
        await refreshToken();
      }
    }
    
    final token = await _secureStorage.read(key: 'access_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  Future<void> logout() async {
    _refreshTimer?.cancel();
    await _secureStorage.deleteAll();
  }
}
```

### 1.3 Role-Based Authorization

**A. Middleware Authorization (Backend)**
```php
// app/Http/Middleware/EnsureUserHasRole.php
namespace App\Http\Middleware;

class EnsureUserHasRole
{
    public function handle(Request $request, Closure $next, ...$roles)
    {
        $user = $request->user();
        
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 401);
        }
        
        if (!in_array($user->role, $roles)) {
            return response()->json([
                'success' => false,
                'message' => 'Forbidden: Insufficient permissions'
            ], 403);
        }
        
        return $next($request);
    }
}
```

**B. Resource Ownership Validation**
```php
// app/Http/Middleware/EnsureResourceOwnership.php
public function handle(Request $request, Closure $next, $resourceType)
{
    $user = $request->user();
    $resourceId = $request->route($resourceType . '_id');
    
    switch ($resourceType) {
        case 'booking':
            $resource = Booking::find($resourceId);
            if (!$resource || $resource->id_user !== $user->id_user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Forbidden: Not your resource'
                ], 403);
            }
            break;
            
        case 'vehicle':
            $resource = Kendaraan::find($resourceId);
            if (!$resource || $resource->id_user !== $user->id_user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Forbidden: Not your vehicle'
                ], 403);
            }
            break;
    }
    
    return $next($request);
}
```

**C. Route Protection**
```php
// routes/api.php
// Public routes
Route::post('/auth/login', [AuthController::class, 'login']);
Route::post('/auth/register', [AuthController::class, 'register']);

// Customer routes
Route::middleware(['auth:api', 'role:customer'])->group(function () {
    Route::post('/booking/create', [BookingController::class, 'create']);
    Route::get('/parking/active', [ParkingController::class, 'getActive']);
    Route::get('/profile/user', [ProfileController::class, 'getUser']);
    
    // With ownership validation
    Route::middleware('ownership:booking')->group(function () {
        Route::get('/booking/{booking_id}', [BookingController::class, 'show']);
        Route::delete('/booking/{booking_id}', [BookingController::class, 'cancel']);
    });
});

// Admin Mall routes
Route::middleware(['auth:api', 'role:admin_mall'])->group(function () {
    Route::get('/admin/dashboard', [AdminController::class, 'dashboard']);
    Route::post('/admin/tarif', [AdminController::class, 'setTarif']);
});

// Super Admin routes
Route::middleware(['auth:api', 'role:super_admin'])->group(function () {
    Route::get('/superadmin/reports', [SuperAdminController::class, 'getReports']);
    Route::get('/superadmin/audit-log', [SuperAdminController::class, 'getAuditLog']);
});
```

---

## 2. VALIDASI REQUEST DAN RESPONSE

### 2.1 Input Validation (Server-Side)

**A. Form Request Validation**
```php
// app/Http/Requests/CreateBookingRequest.php
namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class CreateBookingRequest extends FormRequest
{
    public function rules()
    {
        return [
            'mall_id' => 'required|exists:mall,id_mall',
            'vehicle_id' => 'required|exists:kendaraan,id_kendaraan',
            'start_time' => 'required|date|after:now',
            'duration' => 'required|integer|min:1|max:24',
            'vehicle_type' => 'required|in:Roda Dua,Roda Tiga,Roda Empat',
        ];
    }
    
    public function messages()
    {
        return [
            'mall_id.required' => 'Mall harus dipilih',
            'mall_id.exists' => 'Mall tidak ditemukan',
            'start_time.after' => 'Waktu mulai harus di masa depan',
            'duration.min' => 'Durasi minimal 1 jam',
            'duration.max' => 'Durasi maksimal 24 jam',
        ];
    }
    
    public function withValidator($validator)
    {
        $validator->after(function ($validator) {
            // Validasi vehicle ownership
            $vehicle = Kendaraan::find($this->vehicle_id);
            if ($vehicle && $vehicle->id_user !== auth()->id()) {
                $validator->errors()->add(
                    'vehicle_id', 
                    'Kendaraan bukan milik Anda'
                );
            }
            
            // Validasi active booking
            $hasActiveBooking = Booking::where('id_user', auth()->id())
                ->where('status', 'aktif')
                ->exists();
            if ($hasActiveBooking) {
                $validator->errors()->add(
                    'booking', 
                    'Anda sudah memiliki booking aktif'
                );
            }
        });
    }
}
```

**B. Input Sanitization**
```php
// app/Helpers/InputSanitizer.php
class InputSanitizer
{
    public static function sanitizePhone($phone)
    {
        // Remove all non-numeric
        $phone = preg_replace('/\D/', '', $phone);
        // Remove leading 0 or 62
        $phone = preg_replace('/^(0|62)/', '', $phone);
        return $phone;
    }
    
    public static function sanitizeString($string)
    {
        $string = strip_tags($string);
        $string = htmlspecialchars($string, ENT_QUOTES, 'UTF-8');
        return trim($string);
    }
}
```

### 2.2 Output Sanitization

**A. API Resource**
```php
// app/Http/Resources/UserResource.php
class UserResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id_user,
            'name' => $this->name,
            'email' => $this->maskEmail($this->email),
            'phone' => $this->maskPhone($this->no_hp),
            'role' => $this->role,
            'points' => $this->saldo_poin,
            'status' => $this->status,
            // NEVER expose: password, pin, token
        ];
    }
    
    private function maskEmail($email)
    {
        $parts = explode('@', $email);
        $name = $parts[0];
        $domain = $parts[1];
        $maskedName = substr($name, 0, 2) . 
            str_repeat('*', strlen($name) - 2);
        return $maskedName . '@' . $domain;
    }
    
    private function maskPhone($phone)
    {
        return substr($phone, 0, 4) . 
            str_repeat('*', strlen($phone) - 6) . 
            substr($phone, -2);
    }
}
```

### 2.3 Rate Limiting

**A. Laravel Rate Limiting**
```php
// app/Providers/RouteServiceProvider.php
protected function configureRateLimiting()
{
    // Default rate limit
    RateLimiter::for('api', function (Request $request) {
        return Limit::perMinute(60)
            ->by($request->user()?->id ?: $request->ip());
    });
    
    // Strict untuk auth endpoints
    RateLimiter::for('auth', function (Request $request) {
        return [
            Limit::perMinute(5)->by($request->ip()),
            Limit::perMinute(3)->by($request->input('nomor_hp')),
        ];
    });
    
    // Rate limit untuk booking
    RateLimiter::for('booking', function (Request $request) {
        return Limit::perMinute(10)->by($request->user()->id);
    });
}

// routes/api.php
Route::middleware('throttle:auth')->group(function () {
    Route::post('/auth/login', [AuthController::class, 'login']);
    Route::post('/auth/register', [AuthController::class, 'register']);
});

Route::middleware(['auth:api', 'throttle:booking'])->group(function () {
    Route::post('/booking/create', [BookingController::class, 'create']);
});
```

---

## 3. PEMBATASAN AKSES (RBAC)

### 3.1 RBAC Matrix

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

### 3.2 Permission Gates

```php
// app/Providers/AuthServiceProvider.php
public function boot()
{
    Gate::define('manage-booking', function ($user, $booking) {
        return $user->id_user === $booking->id_user;
    });
    
    Gate::define('manage-mall', function ($user, $mall) {
        if ($user->role === 'super_admin') return true;
        if ($user->role === 'admin_mall') {
            return $user->adminMall->id_mall === $mall->id_mall;
        }
        return false;
    });
}

// Usage in controller
public function show($bookingId)
{
    $booking = Booking::findOrFail($bookingId);
    
    if (!Gate::allows('manage-booking', $booking)) {
        return response()->json([
            'success' => false,
            'message' => 'Unauthorized'
        ], 403);
    }
    
    return response()->json([
        'success' => true,
        'data' => new BookingResource($booking)
    ]);
}
```

---

## 4. MITIGASI RISIKO KEAMANAN

### 4.1 Unauthorized Access Prevention

**A. SSL Certificate Pinning (Flutter)**


```dart
// lib/utils/ssl_pinning.dart
import 'dart:io';

class SSLPinning {
  static const String expectedCertHash = 
    'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=';
  
  static HttpClient createHttpClient() {
    final client = HttpClient();
    
    client.badCertificateCallback = (cert, host, port) {
      final certHash = cert.sha256.toString();
      
      if (certHash == expectedCertHash) {
        return true;
      }
      
      debugPrint('[SSL] Certificate validation failed');
      debugPrint('[SSL] Expected: $expectedCertHash');
      debugPrint('[SSL] Got: $certHash');
      
      return false;
    };
    
    return client;
  }
}
```

**B. Request Signing**
```dart
// lib/utils/request_signer.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';

class RequestSigner {
  static const String _secretKey = 
    String.fromEnvironment('API_SECRET_KEY');
  
  static Map<String, String> signRequest(Map<String, dynamic> body) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final nonce = _generateNonce();
    
    // Create signature
    final payload = jsonEncode(body) + timestamp + nonce;
    final signature = _hmacSha256(payload, _secretKey);
    
    return {
      'X-Signature': signature,
      'X-Timestamp': timestamp,
      'X-Nonce': nonce,
    };
  }
  
  static String _hmacSha256(String message, String secret) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(message);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return base64.encode(digest.bytes);
  }
  
  static String _generateNonce() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return base64.encode(values);
  }
}
```

### 4.2 Data Leakage Prevention

**A. Logging Sanitization**
```dart
// lib/utils/log_sanitizer.dart
class LogSanitizer {
  static String sanitizeLog(String log) {
    return log
      .replaceAll(RegExp(r'"pin":\s*"\d+"'), '"pin":"***"')
      .replaceAll(RegExp(r'"password":\s*"[^"]+"'), '"password":"***"')
      .replaceAll(RegExp(r'"token":\s*"[^"]+"'), '"token":"***"')
      .replaceAll(RegExp(r'"Authorization":\s*"Bearer [^"]+"'), 
        '"Authorization":"Bearer ***"');
  }
}

// Usage
debugPrint('[API] Request: ${LogSanitizer.sanitizeLog(requestBody)}');
```

**B. Error Message Sanitization (Backend)**
```php
// app/Exceptions/Handler.php
public function render($request, Throwable $exception)
{
    if (app()->environment('production')) {
        // Don't expose stack trace in production
        return response()->json([
            'success' => false,
            'message' => 'An error occurred. Please try again.',
            'error_code' => 'INTERNAL_ERROR',
        ], 500);
    }
    
    return parent::render($request, $exception);
}
```

### 4.3 API Abuse Prevention

**A. Account Lockout**
```php
// app/Services/SecurityMonitor.php
class SecurityMonitor
{
    public static function trackFailedLogin($identifier)
    {
        $key = "failed_login:{$identifier}";
        $attempts = Cache::get($key, 0) + 1;
        
        Cache::put($key, $attempts, now()->addMinutes(15));
        
        if ($attempts >= 5) {
            // Lock account
            User::where('no_hp', $identifier)
                ->update(['status' => 'locked']);
            
            self::alert('Account locked', [
                'identifier' => $identifier,
                'attempts' => $attempts,
                'ip' => request()->ip()
            ]);
        }
        
        return $attempts;
    }
    
    public static function trackSuspiciousActivity($userId, $activity)
    {
        Log::channel('security')->warning('Suspicious activity', [
            'user_id' => $userId,
            'activity' => $activity,
            'ip' => request()->ip(),
            'user_agent' => request()->userAgent()
        ]);
        
        self::alert('Suspicious activity detected', [
            'user_id' => $userId,
            'activity' => $activity
        ]);
    }
    
    private static function alert($message, $context)
    {
        Log::channel('alerts')->critical($message, $context);
        // Send to Slack, email, SMS, etc.
    }
}
```

**B. Anomaly Detection**
```php
// app/Services/AnomalyDetector.php
class AnomalyDetector
{
    public static function detectUnusualBookingPattern($userId)
    {
        // Check for rapid booking creation/cancellation
        $recentBookings = Booking::where('id_user', $userId)
            ->where('created_at', '>', now()->subMinutes(10))
            ->count();
        
        if ($recentBookings > 5) {
            SecurityMonitor::trackSuspiciousActivity(
                $userId, 
                'Rapid booking creation'
            );
            return true;
        }
        
        return false;
    }
    
    public static function detectGeographicAnomaly($userId, $currentIp)
    {
        $lastLogin = AuditLog::where('user_id', $userId)
            ->where('action', 'login_success')
            ->latest()
            ->first();
        
        if ($lastLogin) {
            $lastIp = $lastLogin->ip_address;
            // Check if IPs are from different countries
            // (requires IP geolocation service)
            if (self::isDifferentCountry($lastIp, $currentIp)) {
                SecurityMonitor::trackSuspiciousActivity(
                    $userId,
                    'Login from different country'
                );
                return true;
            }
        }
        
        return false;
    }
}
```

### 4.4 Audit Logging

```php
// app/Services/AuditLogger.php
class AuditLogger
{
    public static function log($action, $resourceType, $resourceId, $details = [])
    {
        AuditLog::create([
            'user_id' => Auth::id(),
            'action' => $action,
            'resource_type' => $resourceType,
            'resource_id' => $resourceId,
            'details' => json_encode($details),
            'ip_address' => request()->ip(),
            'user_agent' => request()->userAgent(),
            'created_at' => now(),
        ]);
    }
    
    public static function logLogin($userId, $success)
    {
        self::log(
            $success ? 'login_success' : 'login_failed',
            'user',
            $userId,
            ['success' => $success]
        );
    }
    
    public static function logBooking($bookingId, $action)
    {
        self::log($action, 'booking', $bookingId);
    }
    
    public static function logPayment($paymentId, $amount, $method)
    {
        self::log('payment', 'pembayaran', $paymentId, [
            'amount' => $amount,
            'method' => $method
        ]);
    }
    
    public static function logDataChange($resourceType, $resourceId, $oldData, $newData)
    {
        self::log('data_change', $resourceType, $resourceId, [
            'old' => $oldData,
            'new' => $newData,
            'changed_fields' => array_keys(array_diff_assoc($newData, $oldData))
        ]);
    }
}

// Usage in controllers
public function create(CreateBookingRequest $request)
{
    $booking = Booking::create($request->validated());
    AuditLogger::logBooking($booking->id, 'booking_created');
    
    return response()->json([
        'success' => true, 
        'data' => new BookingResource($booking)
    ]);
}

public function update(Request $request, $id)
{
    $booking = Booking::findOrFail($id);
    $oldData = $booking->toArray();
    
    $booking->update($request->validated());
    
    AuditLogger::logDataChange('booking', $id, $oldData, $booking->toArray());
    
    return response()->json([
        'success' => true,
        'data' => new BookingResource($booking)
    ]);
}
```

---

## 5. MONITORING DAN ALERTING

### 5.1 Metrics to Monitor

**A. Authentication Metrics**
- Failed login attempts per IP/user
- Token expiration rate
- Concurrent sessions per user
- Geographic login patterns

**B. API Usage Metrics**
- Request rate per endpoint
- Error rate per endpoint
- Response time percentiles (p50, p95, p99)
- Rate limit hits

**C. Security Events**
- Unauthorized access attempts
- Suspicious IP addresses
- Data manipulation attempts
- Unusual transaction patterns
- Account lockouts

### 5.2 Alerting Rules

**Critical (Immediate - SMS + Email):**
- Multiple failed login from same IP (>10 in 5 min)
- Unauthorized admin access attempt
- Payment manipulation detected
- Database integrity violation
- SSL certificate validation failure

**High (Email within 15 minutes):**
- Rate limit exceeded (>100 requests/min)
- Unusual API usage pattern
- Geographic anomaly detected
- Multiple account lockouts

**Medium (Daily digest email):**
- High error rate (>5%)
- Slow response time (>3s average)
- Resource usage anomaly

### 5.3 Monitoring Dashboard

```php
// app/Http/Controllers/MonitoringController.php
class MonitoringController extends Controller
{
    public function getSecurityMetrics()
    {
        return response()->json([
            'failed_logins_24h' => $this->getFailedLogins(),
            'active_sessions' => $this->getActiveSessions(),
            'rate_limit_hits' => $this->getRateLimitHits(),
            'suspicious_activities' => $this->getSuspiciousActivities(),
            'api_health' => $this->getApiHealth(),
        ]);
    }
    
    private function getFailedLogins()
    {
        return AuditLog::where('action', 'login_failed')
            ->where('created_at', '>', now()->subDay())
            ->count();
    }
    
    private function getActiveSessions()
    {
        return RefreshToken::where('expires_at', '>', now())
            ->where('revoked', false)
            ->count();
    }
    
    private function getRateLimitHits()
    {
        // Query from rate limit logs
        return Cache::get('rate_limit_hits_24h', 0);
    }
    
    private function getSuspiciousActivities()
    {
        return Log::channel('security')
            ->where('level', 'warning')
            ->where('created_at', '>', now()->subDay())
            ->get();
    }
    
    private function getApiHealth()
    {
        return [
            'status' => 'healthy',
            'uptime' => $this->getUptime(),
            'avg_response_time' => $this->getAvgResponseTime(),
            'error_rate' => $this->getErrorRate(),
        ];
    }
}
```

---

## 6. IMPLEMENTASI CHECKLIST

### Phase 1: Critical (Week 1-2)

**Priority: IMMEDIATE**

- [ ] **JWT Implementation**
  - [ ] Install Firebase JWT library
  - [ ] Create JWT secret keys (access + refresh)
  - [ ] Implement token generation in AuthController
  - [ ] Create refresh_tokens table migration
  - [ ] Implement refresh endpoint
  - [ ] Update client-side token management

- [ ] **Rate Limiting**
  - [ ] Configure rate limiters in RouteServiceProvider
  - [ ] Apply throttle middleware to all routes
  - [ ] Implement custom rate limit responses
  - [ ] Add rate limit headers to responses

- [ ] **SSL Certificate Pinning**
  - [ ] Generate certificate hash
  - [ ] Implement SSLPinning class in Flutter
  - [ ] Update all HTTP clients to use pinning
  - [ ] Test certificate validation

- [ ] **Input Validation**
  - [ ] Create Form Request classes for all endpoints
  - [ ] Implement custom validation rules
  - [ ] Add input sanitization helpers
  - [ ] Test validation edge cases

- [ ] **Error Message Sanitization**
  - [ ] Update exception handler for production
  - [ ] Remove stack traces from responses
  - [ ] Implement consistent error format
  - [ ] Test error responses

### Phase 2: High (Week 3-4)

**Priority: HIGH**

- [ ] **Audit Logging**
  - [ ] Create audit_logs table migration
  - [ ] Implement AuditLogger service
  - [ ] Add logging to all critical operations
  - [ ] Create audit log viewer for admins

- [ ] **Request Signing**
  - [ ] Implement RequestSigner utility
  - [ ] Add signature validation middleware
  - [ ] Update client to sign requests
  - [ ] Test signature validation

- [ ] **Account Lockout**
  - [ ] Implement SecurityMonitor service
  - [ ] Add account locking logic
  - [ ] Create unlock mechanism (email/SMS)
  - [ ] Test lockout scenarios

- [ ] **Anomaly Detection**
  - [ ] Implement AnomalyDetector service
  - [ ] Add detection for rapid actions
  - [ ] Implement geographic anomaly detection
  - [ ] Setup alerting for anomalies

- [ ] **Resource Ownership Validation**
  - [ ] Create ownership middleware
  - [ ] Apply to all resource endpoints
  - [ ] Test IDOR prevention
  - [ ] Document ownership rules

### Phase 3: Medium (Week 5-6)

**Priority: MEDIUM**

- [ ] **Multi-Factor Authentication**
  - [ ] Integrate SMS OTP service
  - [ ] Implement MFA enrollment
  - [ ] Add MFA verification to login
  - [ ] Create MFA backup codes

- [ ] **Biometric Authentication**
  - [ ] Implement local_auth package
  - [ ] Add biometric login option
  - [ ] Store biometric preference
  - [ ] Test on multiple devices

- [ ] **CAPTCHA**
  - [ ] Integrate reCAPTCHA
  - [ ] Add to login after failed attempts
  - [ ] Add to sensitive operations
  - [ ] Test CAPTCHA flow

- [ ] **Monitoring Dashboard**
  - [ ] Create monitoring endpoints
  - [ ] Build admin dashboard UI
  - [ ] Implement real-time metrics
  - [ ] Setup alerting system

- [ ] **Security Testing**
  - [ ] Conduct penetration testing
  - [ ] Perform security audit
  - [ ] Fix identified vulnerabilities
  - [ ] Document security posture

---

## 7. KESIMPULAN

### 7.1 Ringkasan Rencana

Rencana pengamanan API ini menyediakan roadmap komprehensif untuk meningkatkan keamanan sistem Qparkin dari kondisi saat ini menuju production-ready security posture. Implementasi bertahap memastikan critical vulnerabilities ditangani terlebih dahulu sambil membangun defense-in-depth strategy yang robust.

### 7.2 Gap Analysis

**Current State:**
- ✅ Basic token authentication
- ✅ Secure storage implementation
- ⚠️ Partial input validation
- ❌ No rate limiting
- ❌ No SSL pinning
- ❌ No audit logging

**Target State:**
- ✅ JWT with refresh tokens
- ✅ Comprehensive rate limiting
- ✅ SSL certificate pinning
- ✅ Complete input/output validation
- ✅ Comprehensive audit logging
- ✅ Anomaly detection
- ✅ Real-time monitoring

### 7.3 Prioritas Immediate

**Week 1-2 (Critical):**
1. **Token Refresh Mechanism** - Mencegah poor UX dan security risk
2. **Rate Limiting** - Mencegah brute force attacks
3. **SSL Certificate Pinning** - Mencegah MITM attacks
4. **Input Validation** - Mencegah injection attacks

**Expected Impact:**
- 90% reduction in brute force risk
- 100% protection against MITM
- 95% reduction in injection vulnerabilities
- Improved user experience with auto-refresh

### 7.4 Success Metrics

**Security Metrics:**
- Zero critical vulnerabilities
- < 3 high severity vulnerabilities
- 100% endpoint authorization coverage
- 100% input validation coverage
- < 0.1% false positive rate for anomaly detection

**Performance Metrics:**
- API response time < 500ms (p95)
- Token refresh success rate > 99%
- Rate limit accuracy > 99.9%
- Zero downtime during implementation

**Compliance Metrics:**
- OWASP API Top 10 compliance: 100%
- OWASP Mobile Top 10 compliance: 100%
- Audit log completeness: 100%
- Security incident response time: < 1 hour

### 7.5 Risk Mitigation Summary

| Risk | Current | After Phase 1 | After Phase 3 |
|------|---------|---------------|---------------|
| Brute Force | High | Low | Very Low |
| MITM Attack | High | Very Low | Very Low |
| Token Theft | Medium | Low | Very Low |
| Data Leakage | Medium | Low | Very Low |
| API Abuse | High | Low | Very Low |
| Unauthorized Access | Medium | Low | Very Low |

### 7.6 Next Steps

1. **Immediate (This Week):**
   - Review and approve this security plan
   - Allocate resources for implementation
   - Setup development environment for security features

2. **Week 1-2:**
   - Begin Phase 1 implementation
   - Daily standup for security team
   - Weekly progress report to stakeholders

3. **Week 3-4:**
   - Complete Phase 1
   - Begin Phase 2 implementation
   - Conduct interim security assessment

4. **Week 5-6:**
   - Complete Phase 2
   - Begin Phase 3 implementation
   - Prepare for penetration testing

5. **Week 7-8:**
   - Complete Phase 3
   - Conduct comprehensive security audit
   - Document final security posture
   - Train team on security best practices

---

## APPENDIX

### A. Glossary

- **JWT (JSON Web Token):** Standard untuk token authentication
- **RBAC (Role-Based Access Control):** Sistem otorisasi berbasis role
- **MITM (Man-in-the-Middle):** Serangan intersepsi komunikasi
- **IDOR (Insecure Direct Object Reference):** Kerentanan akses langsung ke resource
- **Rate Limiting:** Pembatasan jumlah request per waktu
- **SSL Pinning:** Validasi certificate untuk mencegah MITM
- **Audit Log:** Catatan aktivitas sistem untuk forensik

### B. References

1. OWASP API Security Top 10 (2023)
2. OWASP Mobile Security Testing Guide
3. Laravel Security Best Practices
4. Flutter Security Guidelines
5. JWT Best Current Practices (RFC 8725)

### C. Contact Information

**Security Team Lead:** [Name]  
**Email:** security@qparkin.com  
**Emergency:** +62-xxx-xxxx-xxxx

**Reporting Security Issues:**
- Email: security@qparkin.com
- Severity: Critical/High/Medium/Low
- Response Time:
  - Critical: 1 hour
  - High: 4 hours
  - Medium: 24 hours
  - Low: 1 week

---

**Document Version:** 1.0  
**Date:** 14 Desember 2025  
**Author:** Security Team  
**Status:** Approved for Implementation  
**Next Review:** After Phase 1 Completion

---

**END OF DOCUMENT**
