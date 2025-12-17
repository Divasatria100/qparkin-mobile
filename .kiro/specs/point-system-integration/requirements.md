# Requirements Document - Point System Integration

## Introduction

Sistem poin QParkin adalah fitur reward yang memungkinkan pengguna mengumpulkan dan menggunakan poin untuk pembayaran parkir. Dokumen ini menganalisis kondisi implementasi saat ini dan mendefinisikan requirements untuk integrasi yang aman dan konsisten dengan arsitektur aplikasi yang sudah ada.

### Point Mechanism Overview

Sistem poin QParkin menggunakan mekanisme yang seimbang antara memberikan nilai kepada pengguna dan menjaga keberlanjutan bisnis:

**Earning Mechanism (Mendapatkan Poin):**
- Pengguna mendapat **1 poin untuk setiap Rp1.000** pembayaran parkir
- Hanya biaya parkir dasar yang dihitung (tidak termasuk penalti atau biaya tambahan)
- Contoh: Parkir Rp50.000 → Dapat 50 poin

**Redemption Mechanism (Menggunakan Poin):**
- Setiap **1 poin bernilai Rp100** saat digunakan untuk diskon
- Maksimal diskon **30% dari total biaya parkir**
- Minimum penggunaan **10 poin** (Rp1.000 diskon)
- Contoh: Gunakan 100 poin → Diskon Rp10.000

**Business Rationale:**
- **Earning rate 0.1%** (Rp1.000 → 1 poin) memberikan insentif tanpa terlalu membebani bisnis
- **Redemption value 10%** (1 poin → Rp100) memberikan nilai yang menarik bagi pengguna
- **Batas diskon 30%** mencegah kerugian berlebihan dan penyalahgunaan sistem
- **Ratio 1:10** (earning vs redemption) mendorong penggunaan berulang dan loyalitas jangka panjang

Mekanisme ini konsisten dengan UC006 dari SKPPL yang menyatakan sistem harus memberikan reward poin setiap transaksi dan menyediakan penggunaan poin untuk diskon.

## Glossary

### Technical Terms
- **Point System**: Sistem reward poin yang memungkinkan pengguna mendapatkan dan menggunakan poin
- **Point Provider**: State management provider untuk mengelola data poin menggunakan ChangeNotifier pattern
- **Point Service**: Service layer untuk komunikasi dengan backend API poin
- **Point Balance**: Saldo poin yang dimiliki pengguna (stored in UserModel.saldoPoin)
- **Point History**: Riwayat transaksi poin (penambahan dan penggunaan)
- **Point Statistics**: Statistik penggunaan poin (total earned, total used, dll)
- **Notification Provider**: Provider untuk mengelola notifikasi perubahan poin
- **Cache Strategy**: Strategi caching data poin menggunakan SharedPreferences
- **Offline Mode**: Mode dimana aplikasi menggunakan cached data saat tidak ada koneksi

### Business Terms
- **Earning Rate**: Rasio konversi pembayaran ke poin (1 poin per Rp1.000)
- **Redemption Rate**: Nilai tukar poin ke diskon (1 poin = Rp100)
- **Maximum Discount**: Batas maksimal diskon yang dapat diberikan (30% dari total biaya)
- **Minimum Redemption**: Jumlah minimum poin yang dapat digunakan (10 poin)
- **Base Parking Fee**: Biaya parkir dasar tanpa penalti atau biaya tambahan
- **Point Discount**: Potongan harga yang diperoleh dari penggunaan poin
- **Point Refund**: Pengembalian poin saat booking dibatalkan
- **Point Expiration**: Masa berlaku poin (jika diimplementasikan)

## Current Implementation Analysis

### Files Manually Merged from Branch

Anda telah mengambil 4 file dari branch anggota tim:

1. **`point_provider.dart`** (1,707 lines)
   - Provider lengkap dengan state management
   - Menggunakan ChangeNotifier pattern (✓ konsisten dengan arsitektur)
   - Memiliki caching strategy dengan SharedPreferences
   - Terintegrasi dengan NotificationProvider
   - Memiliki error handling dengan PointErrorHandler
   - Memiliki test helper methods

2. **`point_page.dart`** (Screen)
   - UI untuk menampilkan balance dan history
   - Menggunakan Consumer<PointProvider>
   - Memiliki pull-to-refresh functionality
   - Memiliki infinite scroll untuk history
   - Memiliki filter dan info bottom sheets

3. **`point_balance_card.dart`** (Widget)
   - Widget untuk menampilkan saldo poin
   - Memiliki loading state dengan shimmer effect
   - Memiliki error state dengan retry button
   - Accessibility compliant

4. **`point_history_item.dart`** (Widget)
   - Widget untuk menampilkan item riwayat poin
   - Color-coded berdasarkan tipe transaksi

### Missing Dependencies

File-file yang direferensikan tetapi **BELUM ADA** di codebase:

1. **Data Models** (CRITICAL):
   - `point_history_model.dart` - Model untuk riwayat poin
   - `point_statistics_model.dart` - Model untuk statistik poin
   - `point_filter_model.dart` - Model untuk filter riwayat

2. **Services** (CRITICAL):
   - `point_service.dart` - Service untuk API calls

3. **Utilities** (CRITICAL):
   - `point_error_handler.dart` - Error handling utility
   - `point_test_data.dart` - Test data generator

4. **Widgets** (IMPORTANT):
   - `filter_bottom_sheet.dart` - Bottom sheet untuk filter
   - `point_info_bottom_sheet.dart` - Bottom sheet untuk info poin
   - `point_empty_state.dart` - Empty state widget

### Existing Point-Related Code

Yang **SUDAH ADA** di codebase:

1. **`premium_points_card.dart`** - Widget untuk menampilkan poin di profile page
2. **`UserModel.saldoPoin`** - Field saldo poin sudah ada di user model
3. **`NotificationProvider`** - Provider untuk notifikasi (perlu diperluas untuk poin)
4. **Profile Page** - Sudah menampilkan poin dan navigasi ke point page

### Architecture Consistency Check

✅ **KONSISTEN** dengan arsitektur QParkin:
- Menggunakan Clean Architecture (data/logic/presentation separation)
- Menggunakan Provider pattern untuk state management
- Menggunakan ChangeNotifier (sama dengan BookingProvider, ActiveParkingProvider)
- Memiliki service layer untuk API calls
- Memiliki error handling yang proper
- Memiliki caching strategy
- Memiliki test helper methods

⚠️ **PERLU PERHATIAN**:
- Import path inconsistency: `point_page.dart` vs `pages/point_screen.dart`
- NotificationProvider perlu diperluas untuk mendukung point notifications
- Perlu validasi backend API endpoints untuk poin

## Requirements

### Requirement 1: Data Models Implementation

**User Story:** As a developer, I want complete data models for the point system, so that the application can properly handle point data from the backend.

#### Acceptance Criteria

1. WHEN the system receives point history data from API THEN the PointHistory model SHALL parse and validate all required fields (idPoin, idUser, poin, perubahan, keterangan, waktu)
2. WHEN the system receives point statistics data from API THEN the PointStatistics model SHALL parse and calculate derived metrics (totalEarned, totalUsed, currentBalance)
3. WHEN the user applies a filter THEN the PointFilter model SHALL correctly match point history items based on filter criteria (type, date range, amount range)
4. WHEN model data is cached THEN the system SHALL serialize and deserialize models without data loss using toJson/fromJson methods
5. WHEN invalid data is received THEN the models SHALL throw appropriate exceptions with descriptive error messages

### Requirement 2: Service Layer Implementation

**User Story:** As a developer, I want a robust service layer for point operations, so that the application can reliably communicate with the backend API.

#### Acceptance Criteria

1. WHEN fetching point balance THEN the PointService SHALL make GET request to `/api/points/balance` endpoint with authentication token
2. WHEN fetching point history THEN the PointService SHALL support pagination with page and limit parameters
3. WHEN calculating available discount THEN the PointService SHALL apply business rules (1 poin = Rp100, max 30% discount)
4. WHEN using points for payment THEN the PointService SHALL make POST request to `/api/points/use` with pointAmount, bookingId, and parkingCost
5. WHEN using points THEN the PointService SHALL validate that pointAmount does not exceed 30% discount limit before making API call
6. WHEN booking is cancelled THEN the PointService SHALL make POST request to `/api/points/refund` with bookingId to restore points
7. WHEN network error occurs THEN the PointService SHALL retry failed requests up to 3 times with exponential backoff
8. WHEN API returns error THEN the PointService SHALL throw typed exceptions (NetworkException, AuthException, ValidationException, InsufficientPointsException) for proper error handling
9. WHEN making API calls THEN the PointService SHALL include proper headers (Authorization, Content-Type, Accept)
10. WHEN response is received THEN the PointService SHALL validate response structure before parsing

### Requirement 3: Error Handling Implementation

**User Story:** As a user, I want clear and helpful error messages when point operations fail, so that I understand what went wrong and how to fix it.

#### Acceptance Criteria

1. WHEN network error occurs THEN the system SHALL display "Koneksi bermasalah. Periksa koneksi internet Anda." message
2. WHEN authentication fails THEN the system SHALL display "Sesi Anda telah berakhir. Silakan login kembali." message
3. WHEN server error occurs THEN the system SHALL display "Terjadi kesalahan server. Silakan coba beberapa saat lagi." message
4. WHEN validation error occurs THEN the system SHALL display specific field-level error messages
5. WHEN error is logged THEN the system SHALL include context, timestamp, and stack trace for debugging
6. WHEN user is offline THEN the system SHALL indicate offline mode and show cached data if available

### Requirement 4: Widget Components Implementation

**User Story:** As a user, I want intuitive UI components for managing my points, so that I can easily view, filter, and understand my point transactions.

#### Acceptance Criteria

1. WHEN opening filter bottom sheet THEN the system SHALL display filter options (All, Earned, Used, Date Range, Amount Range)
2. WHEN applying filter THEN the system SHALL update history list immediately without full page reload
3. WHEN opening info bottom sheet THEN the system SHALL display point system explanation and usage guidelines
4. WHEN history is empty THEN the system SHALL display empty state with helpful message and illustration
5. WHEN filter results in no matches THEN the system SHALL display "Tidak ada riwayat yang sesuai filter" message
6. WHEN bottom sheet is displayed THEN the system SHALL be accessible with proper semantic labels

### Requirement 5: Provider Integration

**User Story:** As a developer, I want the PointProvider properly integrated with the app's provider tree, so that point data is accessible throughout the application.

#### Acceptance Criteria

1. WHEN app starts THEN the PointProvider SHALL be initialized in main.dart MultiProvider
2. WHEN user logs in THEN the PointProvider SHALL fetch initial point data automatically
3. WHEN user logs out THEN the PointProvider SHALL clear all point data and cache
4. WHEN NotificationProvider detects point changes THEN the system SHALL show notification badge on profile page
5. WHEN user opens point page THEN the system SHALL mark point notifications as read
6. WHEN point balance changes THEN the NotificationProvider SHALL be notified to update badge state

### Requirement 6: Navigation and Routing

**User Story:** As a user, I want seamless navigation to the point page from multiple entry points, so that I can easily access my point information.

#### Acceptance Criteria

1. WHEN user taps point card on profile page THEN the system SHALL navigate to point page with slide-from-right animation
2. WHEN user taps back button on point page THEN the system SHALL return to previous page with proper animation
3. WHEN navigation occurs THEN the system SHALL preserve point data state (no unnecessary refetch)
4. WHEN deep link to point page is triggered THEN the system SHALL navigate correctly with proper authentication check
5. WHEN point page is in navigation stack THEN the system SHALL use AutomaticKeepAliveClientMixin to preserve scroll position

### Requirement 7: Caching Strategy

**User Story:** As a user, I want the app to work offline with cached point data, so that I can view my point information even without internet connection.

#### Acceptance Criteria

1. WHEN point data is fetched successfully THEN the system SHALL cache balance, history, and statistics to SharedPreferences
2. WHEN app starts offline THEN the system SHALL load cached data and display offline indicator
3. WHEN cache is older than 24 hours THEN the system SHALL invalidate cache and require fresh data fetch
4. WHEN connection is restored THEN the system SHALL automatically sync with server and update cache
5. WHEN cache operation fails THEN the system SHALL log error but continue operation without crashing
6. WHEN user pulls to refresh THEN the system SHALL fetch fresh data and update cache

### Requirement 8: Backend API Integration

**User Story:** As a developer, I want to verify and document the backend API endpoints for points, so that the frontend can integrate correctly.

#### Acceptance Criteria

1. WHEN backend API is queried THEN the `/api/points/balance` endpoint SHALL return user's current point balance
2. WHEN backend API is queried THEN the `/api/points/history` endpoint SHALL return paginated point transaction history with type (earned/used), amount, and timestamp
3. WHEN backend API is queried THEN the `/api/points/statistics` endpoint SHALL return point usage statistics (totalEarned, totalUsed, currentBalance)
4. WHEN points are earned THEN the `/api/points/earn` endpoint SHALL calculate points based on parking payment (1 poin per Rp1.000) and add to user balance
5. WHEN points are used THEN the `/api/points/use` endpoint SHALL validate discount limit (max 30%), deduct points, and create transaction record
6. WHEN points are used THEN the `/api/points/use` endpoint SHALL return error if points exceed 30% discount limit or insufficient balance
7. WHEN booking is cancelled THEN the `/api/points/refund` endpoint SHALL restore used points to user balance
8. WHEN calculating discount THEN the backend SHALL apply conversion rate of 1 poin = Rp100
9. WHEN API endpoints are called THEN the system SHALL require valid authentication token in Authorization header
10. WHEN API returns data THEN the response format SHALL match the expected model structure
11. WHEN API endpoints don't exist THEN the system SHALL document required backend implementation with business logic specifications

**Required API Endpoints:**

**GET /api/points/balance**
- Response: `{ "balance": 150, "equivalentValue": 15000 }`

**GET /api/points/history?page=1&limit=20**
- Response: `{ "data": [...], "pagination": {...} }`

**GET /api/points/statistics**
- Response: `{ "totalEarned": 500, "totalUsed": 350, "currentBalance": 150 }`

**POST /api/points/earn**
- Request: `{ "transactionId": "TRX123", "parkingCost": 50000 }`
- Response: `{ "pointsEarned": 50, "newBalance": 200 }`

**POST /api/points/use**
- Request: `{ "bookingId": "BKG123", "pointAmount": 100, "parkingCost": 80000 }`
- Response: `{ "discountAmount": 10000, "newBalance": 50, "finalCost": 70000 }`
- Error: `{ "error": "Discount exceeds 30% limit" }` or `{ "error": "Insufficient points" }`

**POST /api/points/refund**
- Request: `{ "bookingId": "BKG123" }`
- Response: `{ "pointsRefunded": 100, "newBalance": 150 }`

### Requirement 9: Testing and Validation

**User Story:** As a developer, I want comprehensive tests for the point system, so that we can ensure reliability and catch bugs early.

#### Acceptance Criteria

1. WHEN PointProvider is tested THEN unit tests SHALL cover all public methods and state changes
2. WHEN PointService is tested THEN unit tests SHALL cover API calls, error handling, and retry logic
3. WHEN models are tested THEN unit tests SHALL cover JSON serialization, validation, and edge cases
4. WHEN widgets are tested THEN widget tests SHALL cover rendering, interactions, and accessibility
5. WHEN integration is tested THEN integration tests SHALL cover end-to-end point operations
6. WHEN tests are run THEN all tests SHALL pass with >80% code coverage

### Requirement 10: Point Business Logic and Conversion Mechanism

**User Story:** As a business stakeholder, I want a balanced and sustainable point reward mechanism, so that the system provides value to users while maintaining business viability.

#### Acceptance Criteria

1. WHEN a user completes a parking payment THEN the system SHALL award 1 point for every Rp1.000 of payment amount (rounded down)
2. WHEN a user redeems points for discount THEN the system SHALL convert points at a rate of 1 point = Rp100 discount value
3. WHEN a user applies point discount to booking THEN the system SHALL limit the maximum discount to 30% of the total parking cost
4. WHEN calculating point rewards THEN the system SHALL only count base parking fees (excluding penalties, taxes, or other surcharges)
5. WHEN a user has insufficient points THEN the system SHALL display "Poin tidak mencukupi" message and show the required point amount
6. WHEN point discount is applied THEN the system SHALL deduct points from user balance immediately upon successful booking confirmation
7. WHEN a booking is cancelled THEN the system SHALL refund used points back to user balance within 24 hours
8. WHEN displaying point value THEN the system SHALL clearly show both point amount and equivalent Rupiah value (e.g., "100 poin = Rp10.000")
9. WHEN a user earns points THEN the system SHALL show notification with earned amount and new balance
10. WHEN point expiration is implemented THEN the system SHALL notify users 30 days before points expire

**Business Rules:**
- **Earning Rate:** 1 poin per Rp1.000 pembayaran (0.1% cashback rate)
- **Redemption Rate:** 1 poin = Rp100 diskon (10% redemption value)
- **Maximum Discount:** 30% dari total biaya parkir
- **Minimum Redemption:** 10 poin (Rp1.000 diskon)
- **Point Source:** Hanya dari biaya parkir dasar, tidak termasuk penalti atau biaya tambahan
- **Refund Policy:** Poin dikembalikan jika booking dibatalkan dalam 24 jam

**Example Calculation:**
- Parkir Rp50.000 → Dapat 50 poin
- Gunakan 100 poin → Diskon Rp10.000
- Biaya parkir Rp80.000 → Maksimal diskon 30% = Rp24.000 (240 poin)

### Requirement 11: Point Usage in Booking Flow

**User Story:** As a user, I want to easily use my points for discounts when booking parking, so that I can save money on parking costs.

#### Acceptance Criteria

1. WHEN user is on booking page THEN the system SHALL display current point balance and available discount amount
2. WHEN user toggles "Gunakan Poin" option THEN the system SHALL show a slider or input to select point amount to use
3. WHEN user selects point amount THEN the system SHALL immediately update the total cost preview with discount applied
4. WHEN point amount exceeds 30% discount limit THEN the system SHALL cap the discount and show warning message
5. WHEN user has insufficient points THEN the system SHALL disable the point usage option and show required points
6. WHEN booking is confirmed with points THEN the system SHALL show breakdown: original cost, point discount, final cost
7. WHEN point deduction fails THEN the system SHALL rollback the booking and show error message
8. WHEN user views booking confirmation THEN the system SHALL display points used and points saved in the receipt

### Requirement 12: Performance Optimization

**User Story:** As a user, I want the point system to be fast and responsive, so that I don't experience lag or delays.

#### Acceptance Criteria

1. WHEN point page loads THEN the initial render SHALL complete within 500ms
2. WHEN scrolling history list THEN the UI SHALL maintain 60fps with no jank
3. WHEN filtering history THEN the filter operation SHALL complete within 100ms
4. WHEN fetching data THEN the system SHALL show loading indicators for operations >300ms
5. WHEN rendering list items THEN the system SHALL use RepaintBoundary to isolate repaints
6. WHEN caching data THEN the cache operations SHALL not block the UI thread

## Implementation Priority

### Phase 1: Critical Dependencies (MUST HAVE)
1. Data Models (point_history_model, point_statistics_model, point_filter_model)
2. Point Service with business logic (earning rate, redemption rate, discount limits)
3. Error Handler utility (including InsufficientPointsException)
4. Backend API verification/implementation with business rules

### Phase 2: Core Features (MUST HAVE)
5. Point usage in booking flow (UI components for point selection)
6. Point discount calculation and validation
7. Widget components (filter, info, empty state)
8. Provider integration in main.dart
9. NotificationProvider extension
10. Navigation setup

### Phase 3: Enhancement (SHOULD HAVE)
11. Point refund mechanism for cancelled bookings
12. Test data generator
13. Comprehensive testing (unit, widget, integration)
14. Performance optimization
15. Documentation (user guide, API docs)

### Phase 4: Polish (NICE TO HAVE)
16. Advanced filtering options
17. Point usage analytics and insights
18. Point expiration mechanism
19. Gamification elements (badges, milestones)
20. Point transfer between users (if business allows)

## Risk Assessment

### High Risk
- **Backend API tidak tersedia**: Perlu koordinasi dengan backend team untuk implementasi endpoints
- **Data model mismatch**: Format data dari backend mungkin berbeda dengan model yang sudah dibuat

### Medium Risk
- **Performance issues**: History list dengan banyak data bisa menyebabkan lag
- **Cache corruption**: SharedPreferences bisa corrupt dan menyebabkan crash

### Low Risk
- **UI/UX inconsistency**: Widget styling mungkin perlu disesuaikan dengan design system
- **Navigation conflicts**: Route naming bisa konflik dengan existing routes

## Success Criteria

1. ✅ Semua file dependencies berhasil dibuat dan terintegrasi
2. ✅ Point earning mechanism berfungsi (1 poin per Rp1.000 pembayaran)
3. ✅ Point redemption mechanism berfungsi (1 poin = Rp100 diskon, max 30%)
4. ✅ Point usage in booking flow terintegrasi dengan baik
5. ✅ Business rules validation berjalan di frontend dan backend
6. ✅ Offline mode bekerja dengan cached data
7. ✅ Error handling memberikan feedback yang jelas ke user (termasuk insufficient points)
8. ✅ Performance memenuhi target (60fps, <500ms load time)
9. ✅ Tests coverage >80% (termasuk business logic tests)
10. ✅ Backend API endpoints tersedia dan terdokumentasi dengan business rules
11. ✅ Point refund mechanism berfungsi untuk cancelled bookings
12. ✅ Tidak ada regression pada fitur existing
13. ✅ User dapat memahami nilai poin mereka (tampilan Rp equivalent)
14. ✅ Sistem konsisten dengan UC006 dari SKPPL

## Business Logic Examples

### Example 1: Earning Points
**Scenario:** User completes parking payment
- Parking cost: Rp75.500
- Base fee calculation: Rp75.500 / Rp1.000 = 75.5 → **75 poin** (rounded down)
- User notification: "Selamat! Anda mendapat 75 poin dari transaksi ini"

### Example 2: Using Points - Normal Case
**Scenario:** User books parking and uses points
- Parking cost: Rp100.000
- User has: 200 poin
- User wants to use: 150 poin
- Discount calculation: 150 poin × Rp100 = Rp15.000
- Discount percentage: Rp15.000 / Rp100.000 = 15% ✅ (within 30% limit)
- Final cost: Rp100.000 - Rp15.000 = **Rp85.000**
- Remaining points: 200 - 150 = **50 poin**

### Example 3: Using Points - Maximum Discount Limit
**Scenario:** User tries to use more points than allowed
- Parking cost: Rp50.000
- User has: 300 poin
- User wants to use: 200 poin (would give Rp20.000 discount = 40%)
- Maximum allowed discount: 30% × Rp50.000 = Rp15.000
- Maximum points allowed: Rp15.000 / Rp100 = **150 poin**
- System caps at: 150 poin
- Warning message: "Maksimal diskon 30%. Anda dapat menggunakan maksimal 150 poin untuk booking ini."
- Final cost: Rp50.000 - Rp15.000 = **Rp35.000**
- Remaining points: 300 - 150 = **150 poin**

### Example 4: Insufficient Points
**Scenario:** User doesn't have enough points
- Parking cost: Rp80.000
- User has: 50 poin (= Rp5.000 discount)
- User wants to use: 100 poin
- Error message: "Poin tidak mencukupi. Anda memiliki 50 poin (Rp5.000). Butuh 100 poin (Rp10.000)."
- Suggestion: "Gunakan 50 poin untuk diskon Rp5.000"

### Example 5: Booking Cancellation Refund
**Scenario:** User cancels booking and gets points back
- Original booking: Rp100.000
- Points used: 150 poin (Rp15.000 discount)
- User cancels within 24 hours
- Points refunded: **150 poin**
- Notification: "Booking dibatalkan. 150 poin telah dikembalikan ke saldo Anda."

### Example 6: Minimum Redemption
**Scenario:** User tries to use too few points
- User has: 50 poin
- User wants to use: 5 poin (Rp500 discount)
- Minimum redemption: 10 poin
- Error message: "Minimum penggunaan poin adalah 10 poin (Rp1.000)"

## Comparison with Previous Mechanism

### Previous (Too Aggressive):
- Earning: 1 poin per Rp1 → 0.1% cashback rate
- Redemption: 1 poin = Rp1 → 100% redemption value
- **Problem:** Unsustainable, users could get 100% discount easily

### Current (Balanced):
- Earning: 1 poin per Rp1.000 → 0.1% cashback rate (same)
- Redemption: 1 poin = Rp100 → 10% redemption value
- Maximum discount: 30% cap
- **Benefit:** 
  - Sustainable for business (10:1 ratio)
  - Still attractive for users (10% value on redemption)
  - Encourages repeat usage (need 10x spending to earn back)
  - Prevents abuse with 30% cap
