# Design Document - Point System Integration

## Overview

This document outlines the technical design for integrating the point reward system into the QParkin mobile application. The system implements a balanced business model where users earn 1 point per Rp1.000 spent and can redeem points at 1 point = Rp100 discount value, with a maximum 30% discount cap to ensure business sustainability.

The design follows QParkin's Clean Architecture pattern with clear separation between data, logic, and presentation layers, using the Provider pattern for state management consistent with existing features like BookingProvider and ActiveParkingProvider.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Point Page  │  │ Point Widgets│  │ Booking Page │      │
│  │              │  │  - Balance   │  │ (Point Usage)│      │
│  │              │  │  - History   │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                       Logic Layer                            │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           PointProvider (ChangeNotifier)             │   │
│  │  - State Management                                  │   │
│  │  - Business Logic Validation                         │   │
│  │  - Cache Management                                  │   │
│  │  - Notification Integration                          │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                        Data Layer                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Point Service│  │ Point Models │  │    Cache     │      │
│  │  - API Calls │  │  - History   │  │ (SharedPrefs)│      │
│  │  - Business  │  │  - Statistics│  │              │      │
│  │    Rules     │  │  - Filter    │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Backend API (Laravel)                     │
│  - /api/points/balance                                       │
│  - /api/points/history                                       │
│  - /api/points/statistics                                    │
│  - /api/points/earn                                          │
│  - /api/points/use                                           │
│  - /api/points/refund                                        │
└─────────────────────────────────────────────────────────────┘
```

### Integration Points

1. **Profile Page** → Point Page navigation
2. **Booking Page** → Point usage for discount
3. **Payment Flow** → Point earning after successful payment
4. **Notification System** → Point balance change notifications
5. **Cache Layer** → Offline data access

## Components and Interfaces

### 1. Data Models

#### PointHistoryModel
```dart
class PointHistoryModel {
  final String idPoin;
  final String idUser;
  final int poin;
  final String perubahan; // 'earned' or 'used'
  final String keterangan;
  final DateTime waktu;
  
  // Business logic helpers
  bool get isEarned => perubahan == 'earned';
  bool get isUsed => perubahan == 'used';
  int get absolutePoints => poin.abs();
  String get formattedValue => 'Rp${(absolutePoints * 100).toStringAsFixed(0)}';
  
  factory PointHistoryModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

#### PointStatisticsModel
```dart
class PointStatisticsModel {
  final int totalEarned;
  final int totalUsed;
  final int currentBalance;
  
  // Derived metrics
  int get netPoints => totalEarned - totalUsed;
  double get usageRate => totalEarned > 0 ? (totalUsed / totalEarned) : 0.0;
  int get equivalentValue => currentBalance * 100; // Rp value
  
  factory PointStatisticsModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

#### PointFilterModel
```dart
class PointFilterModel {
  final PointFilterType type; // all, earned, used
  final DateTimeRange? dateRange;
  final int? minAmount;
  final int? maxAmount;
  
  bool matches(PointHistoryModel history) {
    // Filter logic implementation
  }
  
  factory PointFilterModel.all();
  Map<String, dynamic> toJson();
  factory PointFilterModel.fromJson(Map<String, dynamic> json);
}

enum PointFilterType { all, earned, used }
```

### 2. Service Layer

#### PointService
```dart
class PointService {
  final HttpClient _httpClient;
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Business logic constants
  static const int earningRate = 1000; // 1 poin per Rp1.000
  static const int redemptionValue = 100; // 1 poin = Rp100
  static const double maxDiscountPercent = 0.30; // 30%
  static const int minRedemption = 10; // minimum 10 poin
  
  // API Methods
  Future<int> fetchBalance();
  Future<List<PointHistoryModel>> fetchHistory({int page = 1, int limit = 20});
  Future<PointStatisticsModel> fetchStatistics();
  
  // Business logic methods
  int calculateEarnedPoints(int parkingCost);
  int calculateDiscountAmount(int points);
  int calculateMaxAllowedPoints(int parkingCost);
  bool validatePointUsage(int points, int parkingCost, int userBalance);
  
  // Transaction methods
  Future<PointEarnResponse> earnPoints({
    required String transactionId,
    required int parkingCost,
  });
  
  Future<PointUseResponse> usePoints({
    required String bookingId,
    required int pointAmount,
    required int parkingCost,
  });
  
  Future<PointRefundResponse> refundPoints({
    required String bookingId,
  });
  
  // Error handling with retry
  Future<T> _executeWithRetry<T>(Future<T> Function() operation);
}
```

### 3. Provider Layer

#### PointProvider
```dart
class PointProvider extends ChangeNotifier {
  final PointService _pointService;
  final NotificationProvider _notificationProvider;
  final SharedPreferences _prefs;
  
  // State
  int _balance = 0;
  List<PointHistoryModel> _history = [];
  PointStatisticsModel? _statistics;
  PointFilterModel _currentFilter = PointFilterModel.all();
  bool _isLoading = false;
  String? _error;
  bool _isOffline = false;
  
  // Getters
  int get balance => _balance;
  String get balanceDisplay => '$_balance poin';
  String get equivalentValue => 'Rp${(_balance * 100).toStringAsFixed(0)}';
  List<PointHistoryModel> get filteredHistory => _applyFilter(_history);
  bool get hasPoints => _balance > 0;
  
  // Business logic methods
  int calculateAvailableDiscount(int parkingCost) {
    final maxPoints = _pointService.calculateMaxAllowedPoints(parkingCost);
    final availablePoints = min(_balance, maxPoints);
    return _pointService.calculateDiscountAmount(availablePoints);
  }
  
  bool canUsePoints(int points, int parkingCost) {
    return _pointService.validatePointUsage(points, parkingCost, _balance);
  }
  
  String? validatePointUsage(int points, int parkingCost) {
    if (points < PointService.minRedemption) {
      return 'Minimum penggunaan ${PointService.minRedemption} poin';
    }
    if (points > _balance) {
      return 'Poin tidak mencukupi. Anda memiliki $_balance poin';
    }
    final maxAllowed = _pointService.calculateMaxAllowedPoints(parkingCost);
    if (points > maxAllowed) {
      return 'Maksimal $maxAllowed poin untuk booking ini (30% limit)';
    }
    return null;
  }
  
  // Data operations
  Future<void> fetchBalance();
  Future<void> fetchHistory({bool loadMore = false});
  Future<void> fetchStatistics();
  Future<void> refresh();
  
  // Filter operations
  void applyFilter(PointFilterModel filter);
  void clearFilter();
  
  // Cache operations
  Future<void> _cacheData();
  Future<void> _loadCachedData();
  Future<void> _clearCache();
  
  // Lifecycle
  Future<void> initialize();
  Future<void> dispose();
}
```

### 4. UI Components

#### Point Page
```dart
class PointPage extends StatefulWidget {
  // Main screen showing balance, statistics, and history
  // Features:
  // - Pull-to-refresh
  // - Infinite scroll for history
  // - Filter bottom sheet
  // - Info bottom sheet
  // - Offline indicator
}
```

#### Point Balance Card
```dart
class PointBalanceCard extends StatelessWidget {
  final int balance;
  final String equivalentValue;
  final bool isLoading;
  final VoidCallback? onTap;
  
  // Displays:
  // - Current point balance
  // - Equivalent Rupiah value
  // - Loading shimmer effect
  // - Error state with retry
}
```

#### Point Usage Widget (in Booking Page)
```dart
class PointUsageWidget extends StatefulWidget {
  final int parkingCost;
  final int availablePoints;
  final Function(int points) onPointsSelected;
  
  // Features:
  // - Toggle to enable/disable point usage
  // - Slider to select point amount
  // - Real-time discount calculation
  // - Validation messages
  // - Maximum discount indicator (30%)
}
```

#### Filter Bottom Sheet
```dart
class FilterBottomSheet extends StatefulWidget {
  final PointFilterModel currentFilter;
  final Function(PointFilterModel) onApply;
  
  // Filter options:
  // - Type: All, Earned, Used
  // - Date range picker
  // - Amount range (min/max points)
}
```

#### Point Info Bottom Sheet
```dart
class PointInfoBottomSheet extends StatelessWidget {
  // Displays:
  // - How to earn points (1 poin per Rp1.000)
  // - How to use points (1 poin = Rp100)
  // - Maximum discount rule (30%)
  // - Minimum redemption (10 poin)
  // - Refund policy
  // - Example calculations
}
```

## Data Models

### Point History Model Structure
```json
{
  "idPoin": "POIN123",
  "idUser": "USER456",
  "poin": 50,
  "perubahan": "earned",
  "keterangan": "Parkir di Mall ABC - Rp50.000",
  "waktu": "2025-01-15T10:30:00Z"
}
```

### Point Statistics Model Structure
```json
{
  "totalEarned": 500,
  "totalUsed": 350,
  "currentBalance": 150
}
```

### API Response Structures

#### Balance Response
```json
{
  "balance": 150,
  "equivalentValue": 15000
}
```

#### History Response
```json
{
  "data": [
    {
      "idPoin": "POIN123",
      "idUser": "USER456",
      "poin": 50,
      "perubahan": "earned",
      "keterangan": "Parkir di Mall ABC",
      "waktu": "2025-01-15T10:30:00Z"
    }
  ],
  "pagination": {
    "currentPage": 1,
    "totalPages": 5,
    "totalItems": 100,
    "itemsPerPage": 20
  }
}
```

#### Earn Points Response
```json
{
  "pointsEarned": 50,
  "newBalance": 200,
  "transactionId": "TRX123"
}
```

#### Use Points Response
```json
{
  "discountAmount": 10000,
  "pointsUsed": 100,
  "newBalance": 50,
  "finalCost": 70000
}
```

#### Error Response
```json
{
  "error": "Discount exceeds 30% limit",
  "code": "DISCOUNT_LIMIT_EXCEEDED",
  "maxAllowedPoints": 150
}
```

## Error Handling

### Exception Hierarchy
```dart
abstract class PointException implements Exception {
  final String message;
  final String? code;
  PointException(this.message, [this.code]);
}

class NetworkException extends PointException {
  NetworkException(String message) : super(message, 'NETWORK_ERROR');
}

class AuthException extends PointException {
  AuthException(String message) : super(message, 'AUTH_ERROR');
}

class ValidationException extends PointException {
  ValidationException(String message) : super(message, 'VALIDATION_ERROR');
}

class InsufficientPointsException extends PointException {
  final int required;
  final int available;
  InsufficientPointsException(this.required, this.available)
      : super('Poin tidak mencukupi', 'INSUFFICIENT_POINTS');
}

class DiscountLimitException extends PointException {
  final int maxAllowed;
  DiscountLimitException(this.maxAllowed)
      : super('Maksimal diskon 30%', 'DISCOUNT_LIMIT_EXCEEDED');
}
```

### Error Handler Utility
```dart
class PointErrorHandler {
  static String getUserMessage(Exception error) {
    if (error is NetworkException) {
      return 'Koneksi bermasalah. Periksa koneksi internet Anda.';
    } else if (error is AuthException) {
      return 'Sesi Anda telah berakhir. Silakan login kembali.';
    } else if (error is InsufficientPointsException) {
      return 'Poin tidak mencukupi. Anda memiliki ${error.available} poin. '
             'Butuh ${error.required} poin.';
    } else if (error is DiscountLimitException) {
      return 'Maksimal diskon 30%. Anda dapat menggunakan maksimal '
             '${error.maxAllowed} poin untuk booking ini.';
    } else if (error is ValidationException) {
      return error.message;
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
  
  static void logError(Exception error, StackTrace stackTrace) {
    // Log to analytics/crash reporting
  }
}
```

## Testing Strategy

### Unit Tests

#### Model Tests
- JSON serialization/deserialization
- Business logic helpers (isEarned, formattedValue, etc.)
- Filter matching logic
- Edge cases (null values, invalid data)

#### Service Tests
- API call success scenarios
- Error handling and retry logic
- Business logic calculations:
  - `calculateEarnedPoints(50000)` → 50 poin
  - `calculateDiscountAmount(100)` → Rp10.000
  - `calculateMaxAllowedPoints(100000)` → 300 poin (30% = Rp30.000)
- Validation methods
- Network error scenarios

#### Provider Tests
- State management (loading, error, success)
- Filter application
- Cache operations
- Business logic methods
- Notification integration

### Widget Tests

#### Point Balance Card Tests
- Renders balance correctly
- Shows equivalent value
- Loading state with shimmer
- Error state with retry button
- Tap interaction

#### Point Usage Widget Tests
- Toggle enable/disable
- Slider interaction
- Real-time discount calculation
- Validation messages
- Maximum discount indicator

#### Filter Bottom Sheet Tests
- Filter type selection
- Date range picker
- Amount range input
- Apply/Clear actions

### Integration Tests

#### End-to-End Point Flow
1. User completes parking payment
2. System awards points (1 poin per Rp1.000)
3. Points appear in balance
4. User navigates to booking page
5. User selects points to use
6. System validates and applies discount
7. Booking confirmed with point deduction
8. History updated with transaction

#### Offline Mode Test
1. Fetch and cache point data
2. Disconnect network
3. Open point page
4. Verify cached data displayed
5. Verify offline indicator shown
6. Reconnect network
7. Verify auto-sync

### Business Logic Tests

#### Earning Calculation Tests
```dart
test('calculates earned points correctly', () {
  expect(service.calculateEarnedPoints(50000), 50);
  expect(service.calculateEarnedPoints(75500), 75); // rounded down
  expect(service.calculateEarnedPoints(999), 0); // below threshold
});
```

#### Discount Calculation Tests
```dart
test('calculates discount amount correctly', () {
  expect(service.calculateDiscountAmount(100), 10000);
  expect(service.calculateDiscountAmount(50), 5000);
});
```

#### Maximum Discount Tests
```dart
test('enforces 30% discount limit', () {
  expect(service.calculateMaxAllowedPoints(100000), 300); // 30% = 30k = 300 poin
  expect(service.calculateMaxAllowedPoints(50000), 150); // 30% = 15k = 150 poin
});
```

#### Validation Tests
```dart
test('validates point usage correctly', () {
  // Insufficient points
  expect(
    service.validatePointUsage(100, 50000, 50),
    false,
  );
  
  // Exceeds 30% limit
  expect(
    service.validatePointUsage(200, 50000, 300),
    false,
  );
  
  // Valid usage
  expect(
    service.validatePointUsage(100, 100000, 200),
    true,
  );
});
```

## Performance Optimization

### 1. List Rendering
- Use `ListView.builder` for efficient rendering
- Implement `RepaintBoundary` for list items
- Use `AutomaticKeepAliveClientMixin` for scroll position preservation

### 2. Caching Strategy
```dart
class PointCacheManager {
  static const String balanceKey = 'point_balance';
  static const String historyKey = 'point_history';
  static const String statisticsKey = 'point_statistics';
  static const Duration cacheValidity = Duration(hours: 24);
  
  Future<void> cacheBalance(int balance);
  Future<void> cacheHistory(List<PointHistoryModel> history);
  Future<void> cacheStatistics(PointStatisticsModel stats);
  
  Future<int?> getCachedBalance();
  Future<List<PointHistoryModel>?> getCachedHistory();
  Future<PointStatisticsModel?> getCachedStatistics();
  
  bool isCacheValid(String key);
  Future<void> invalidateCache();
}
```

### 3. Network Optimization
- Implement pagination for history (20 items per page)
- Use debouncing for filter operations
- Implement exponential backoff for retries
- Cancel pending requests on dispose

### 4. State Management Optimization
- Use `notifyListeners()` selectively
- Implement computed properties for derived data
- Avoid unnecessary rebuilds with `Consumer` widgets

## Security Considerations

### 1. API Security
- All requests include authentication token
- Token stored in secure storage (flutter_secure_storage)
- Implement token refresh mechanism
- Validate SSL certificates

### 2. Data Validation
- Validate all user inputs before API calls
- Sanitize data from backend
- Implement business rule validation on frontend
- Double-check validation on backend

### 3. Cache Security
- Encrypt sensitive cached data
- Clear cache on logout
- Implement cache expiration
- Validate cached data integrity

## Integration with Existing Features

### 1. Booking Page Integration
```dart
// In BookingPage
Consumer<PointProvider>(
  builder: (context, pointProvider, child) {
    return PointUsageWidget(
      parkingCost: bookingCost,
      availablePoints: pointProvider.balance,
      onPointsSelected: (points) {
        setState(() {
          _selectedPoints = points;
          _discount = pointProvider.calculateDiscountAmount(points);
          _finalCost = bookingCost - _discount;
        });
      },
    );
  },
)
```

### 2. Payment Flow Integration
```dart
// After successful payment
await pointProvider.earnPoints(
  transactionId: payment.id,
  parkingCost: payment.amount,
);

// Show notification
notificationProvider.showPointEarned(
  points: earnedPoints,
  newBalance: pointProvider.balance,
);
```

### 3. Profile Page Integration
```dart
// In ProfilePage
GestureDetector(
  onTap: () => Navigator.pushNamed(context, '/points'),
  child: PointBalanceCard(
    balance: pointProvider.balance,
    equivalentValue: pointProvider.equivalentValue,
    isLoading: pointProvider.isLoading,
  ),
)
```

## Deployment Considerations

### 1. Backend Requirements
- Implement all required API endpoints
- Add business logic validation
- Set up database tables for point transactions
- Implement transaction logging
- Add admin dashboard for point management

### 2. Database Schema
```sql
CREATE TABLE riwayat_poin (
  id_poin VARCHAR(50) PRIMARY KEY,
  id_user VARCHAR(50) NOT NULL,
  poin INT NOT NULL,
  perubahan ENUM('earned', 'used') NOT NULL,
  keterangan TEXT,
  waktu TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_user) REFERENCES users(id_user)
);

CREATE INDEX idx_user_waktu ON riwayat_poin(id_user, waktu DESC);
```

### 3. Migration Strategy
- Deploy backend endpoints first
- Test with staging environment
- Gradual rollout to users
- Monitor error rates and performance
- Provide user education materials

## Monitoring and Analytics

### 1. Key Metrics
- Point earning rate (points per transaction)
- Point redemption rate (% of users using points)
- Average discount amount
- Point balance distribution
- API response times
- Error rates by type

### 2. Logging
- Log all point transactions
- Log validation failures
- Log API errors with context
- Log cache operations

### 3. User Analytics
- Track point page visits
- Track filter usage
- Track point usage in bookings
- Track user engagement with point system

## Future Enhancements

### Phase 2 Features
1. Point expiration mechanism
2. Point transfer between users
3. Special promotions (double points days)
4. Point milestones and badges
5. Push notifications for point updates

### Phase 3 Features
1. Point redemption for non-parking rewards
2. Tiered loyalty program
3. Referral point bonuses
4. Point leaderboard
5. Advanced analytics dashboard

## Conclusion

This design provides a comprehensive, scalable, and maintainable solution for the point system integration. The balanced business model (1:10 earning to redemption ratio with 30% cap) ensures sustainability while providing value to users. The architecture follows QParkin's established patterns and integrates seamlessly with existing features.
