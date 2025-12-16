# Requirements Document - Point System Integration

## Introduction

Sistem poin QParkin adalah fitur reward yang memungkinkan pengguna mengumpulkan dan menggunakan poin untuk pembayaran parkir. Dokumen ini menganalisis kondisi implementasi saat ini dan mendefinisikan requirements untuk integrasi yang aman dan konsisten dengan arsitektur aplikasi yang sudah ada.

## Glossary

- **Point System**: Sistem reward poin yang memungkinkan pengguna mendapatkan dan menggunakan poin
- **Point Provider**: State management provider untuk mengelola data poin menggunakan ChangeNotifier pattern
- **Point Service**: Service layer untuk komunikasi dengan backend API poin
- **Point Balance**: Saldo poin yang dimiliki pengguna (stored in UserModel.saldoPoin)
- **Point History**: Riwayat transaksi poin (penambahan dan penggunaan)
- **Point Statistics**: Statistik penggunaan poin (total earned, total used, dll)
- **Notification Provider**: Provider untuk mengelola notifikasi perubahan poin
- **Cache Strategy**: Strategi caching data poin menggunakan SharedPreferences
- **Offline Mode**: Mode dimana aplikasi menggunakan cached data saat tidak ada koneksi

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
3. WHEN using points for payment THEN the PointService SHALL make POST request with amount and transactionId and handle success/failure responses
4. WHEN network error occurs THEN the PointService SHALL retry failed requests up to 3 times with exponential backoff
5. WHEN API returns error THEN the PointService SHALL throw typed exceptions (NetworkException, AuthException, ValidationException) for proper error handling
6. WHEN making API calls THEN the PointService SHALL include proper headers (Authorization, Content-Type, Accept)
7. WHEN response is received THEN the PointService SHALL validate response structure before parsing

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
2. WHEN backend API is queried THEN the `/api/points/history` endpoint SHALL return paginated point transaction history
3. WHEN backend API is queried THEN the `/api/points/statistics` endpoint SHALL return point usage statistics
4. WHEN points are used THEN the `/api/points/use` endpoint SHALL deduct points and create transaction record
5. WHEN API endpoints are called THEN the system SHALL require valid authentication token in Authorization header
6. WHEN API returns data THEN the response format SHALL match the expected model structure
7. WHEN API endpoints don't exist THEN the system SHALL document required backend implementation

### Requirement 9: Testing and Validation

**User Story:** As a developer, I want comprehensive tests for the point system, so that we can ensure reliability and catch bugs early.

#### Acceptance Criteria

1. WHEN PointProvider is tested THEN unit tests SHALL cover all public methods and state changes
2. WHEN PointService is tested THEN unit tests SHALL cover API calls, error handling, and retry logic
3. WHEN models are tested THEN unit tests SHALL cover JSON serialization, validation, and edge cases
4. WHEN widgets are tested THEN widget tests SHALL cover rendering, interactions, and accessibility
5. WHEN integration is tested THEN integration tests SHALL cover end-to-end point operations
6. WHEN tests are run THEN all tests SHALL pass with >80% code coverage

### Requirement 10: Performance Optimization

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
2. Point Service (API integration)
3. Error Handler utility
4. Backend API verification/implementation

### Phase 2: Core Features (MUST HAVE)
5. Widget components (filter, info, empty state)
6. Provider integration in main.dart
7. NotificationProvider extension
8. Navigation setup

### Phase 3: Enhancement (SHOULD HAVE)
9. Test data generator
10. Comprehensive testing
11. Performance optimization
12. Documentation

### Phase 4: Polish (NICE TO HAVE)
13. Advanced filtering options
14. Point usage analytics
15. Point redemption features
16. Gamification elements

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
2. ✅ Point system berfungsi end-to-end (fetch, display, use points)
3. ✅ Offline mode bekerja dengan cached data
4. ✅ Error handling memberikan feedback yang jelas ke user
5. ✅ Performance memenuhi target (60fps, <500ms load time)
6. ✅ Tests coverage >80%
7. ✅ Backend API endpoints tersedia dan terdokumentasi
8. ✅ Tidak ada regression pada fitur existing
