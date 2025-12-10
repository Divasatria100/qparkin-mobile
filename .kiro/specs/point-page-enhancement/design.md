# Design Document: Point Page Enhancement

## Overview

Point Page Enhancement adalah implementasi lengkap halaman poin dalam aplikasi QPARKIN yang menampilkan sistem reward poin kepada Driver. Halaman ini dirancang dengan arsitektur clean architecture menggunakan Flutter, mengikuti pola yang sudah ada di aplikasi (Provider pattern untuk state management, layered architecture dengan separation of concerns).

### Key Design Goals

1. **User-Centric Design**: Tampilan yang intuitif dengan saldo poin sebagai focal point
2. **Real-time Updates**: Menggunakan Provider pattern untuk reactive UI updates
3. **Performance**: Efficient data loading dengan caching dan pagination
4. **Offline-First**: Mendukung offline viewing dengan cached data
5. **Accessibility**: Memenuhi WCAG AA standards untuk inklusivitas
6. **Maintainability**: Mengikuti struktur kode existing dengan clear separation of concerns

## Architecture

### Layer Architecture

Mengikuti clean architecture pattern yang sudah diterapkan di QPARKIN:

```
┌─────────────────────────────────────────────────────────┐
│                   Presentation Layer                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  PointPage   │  │   Widgets    │  │   Dialogs    │  │
│  │  (Screen)    │  │  (Reusable)  │  │ (BottomSheet)│  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                     Logic Layer                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │         PointProvider (ChangeNotifier)           │   │
│  │  - Manages point balance state                   │   │
│  │  - Manages point history state                   │   │
│  │  - Handles filtering and statistics              │   │
│  │  - Coordinates with API service                  │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                      Data Layer                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ PointService │  │ PointModel   │  │ SharedPrefs  │  │
│  │ (API calls)  │  │ (Data model) │  │  (Cache)     │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                   Backend API (Laravel)                  │
│  - GET /api/points/balance                               │
│  - GET /api/points/history                               │
│  - GET /api/points/statistics                            │
│  - POST /api/points/use                                  │
└─────────────────────────────────────────────────────────┘
```

### State Management Flow

```
User Action → PointPage → PointProvider → PointService → Backend API
                  ↑            ↓              ↓
                  └────────────┴──────────────┘
                    (notifyListeners updates UI)
```

## Components and Interfaces

### 1. Presentation Layer Components

#### PointPage (Main Screen)

**File**: `lib/presentation/screens/point_page.dart`

**Responsibilities**:
- Display point balance prominently
- Show tabs for Overview and History
- Handle user interactions
- Display loading, error, and empty states

**Key Widgets**:
- `PointBalanceCard`: Large card showing current balance
- `PointStatisticsCard`: Summary statistics
- `PointHistoryList`: Scrollable list of point transactions
- `FilterChip`: Filter options for history
- `PointInfoBottomSheet`: Information dialog

**State Dependencies**:
- Consumes `PointProvider` via `Consumer<PointProvider>`
- Listens to balance, history, and filter state changes

#### Reusable Widgets

**PointBalanceCard**
```dart
class PointBalanceCard extends StatelessWidget {
  final int balance;
  final bool isLoading;
  
  // Displays large balance with star icon
  // Includes shimmer loading state
}
```

**PointHistoryItem**
```dart
class PointHistoryItem extends StatelessWidget {
  final PointHistory history;
  final VoidCallback onTap;
  
  // Displays single history entry
  // Color-coded: green for addition, red for deduction
  // Shows date, amount, and description
}
```

**PointStatisticsCard**
```dart
class PointStatisticsCard extends StatelessWidget {
  final PointStatistics stats;
  
  // Shows 4 metrics in grid:
  // - Total earned
  // - Total used
  // - This month earned
  // - This month used
}
```

**FilterBottomSheet**
```dart
class FilterBottomSheet extends StatelessWidget {
  final PointFilter currentFilter;
  final Function(PointFilter) onApply;
  
  // Allows filtering by:
  // - Type: All, Addition, Deduction
  // - Period: All Time, This Month, Last 3 Months, Last 6 Months
}
```

### 2. Logic Layer Components

#### PointProvider

**File**: `lib/logic/providers/point_provider.dart`

**Extends**: `ChangeNotifier`

**State Properties**:
```dart
class PointProvider extends ChangeNotifier {
  // Balance state
  int? _balance;
  bool _isLoadingBalance = false;
  String? _balanceError;
  
  // History state
  List<PointHistory> _history = [];
  bool _isLoadingHistory = false;
  String? _historyError;
  
  // Statistics state
  PointStatistics? _statistics;
  
  // Filter state
  PointFilter _filter = PointFilter.all();
  
  // Cache state
  DateTime? _lastSyncTime;
  
  // Getters
  int? get balance => _balance;
  bool get isLoadingBalance => _isLoadingBalance;
  String? get balanceError => _balanceError;
  List<PointHistory> get filteredHistory => _applyFilter(_history);
  PointStatistics? get statistics => _statistics;
  PointFilter get currentFilter => _filter;
  
  // Public methods
  Future<void> fetchBalance();
  Future<void> fetchHistory();
  Future<void> fetchStatistics();
  Future<void> refreshAll();
  void setFilter(PointFilter filter);
  Future<bool> usePoints(int amount, String transactionId);
  
  // Private methods
  List<PointHistory> _applyFilter(List<PointHistory> history);
  void _cacheData();
  void _loadCachedData();
}
```

**Key Methods**:

1. **fetchBalance()**: Fetches current point balance from API
2. **fetchHistory()**: Fetches point transaction history with pagination
3. **fetchStatistics()**: Calculates statistics from history data
4. **refreshAll()**: Refreshes all data (balance, history, statistics)
5. **setFilter()**: Applies filter to history list
6. **usePoints()**: Deducts points for payment (called from payment page)

### 3. Data Layer Components

#### PointService

**File**: `lib/data/services/point_service.dart`

**Responsibilities**:
- Make HTTP requests to backend API
- Handle API responses and errors
- Transform JSON to model objects

**Methods**:
```dart
class PointService {
  final HttpClient _httpClient;
  
  Future<int> getBalance();
  Future<List<PointHistory>> getHistory({
    int page = 1,
    int limit = 20,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<PointStatistics> getStatistics();
  Future<bool> usePoints(int amount, String transactionId);
}
```

**API Endpoints**:
- `GET /api/points/balance` - Returns current balance
- `GET /api/points/history?page=1&limit=20&type=tambah&start_date=2024-01-01` - Returns paginated history
- `GET /api/points/statistics` - Returns aggregated statistics
- `POST /api/points/use` - Deducts points for payment

#### Models

**PointHistory Model**

**File**: `lib/data/models/point_history_model.dart`

```dart
class PointHistory {
  final int idPoin;
  final int idUser;
  final int? idTransaksi;
  final int poin;
  final String perubahan; // 'tambah' or 'kurang'
  final String keterangan;
  final DateTime waktu;
  
  PointHistory({
    required this.idPoin,
    required this.idUser,
    this.idTransaksi,
    required this.poin,
    required this.perubahan,
    required this.keterangan,
    required this.waktu,
  });
  
  factory PointHistory.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  
  bool get isAddition => perubahan == 'tambah';
  bool get isDeduction => perubahan == 'kurang';
  bool get hasTransaction => idTransaksi != null;
}
```

**PointStatistics Model**

**File**: `lib/data/models/point_statistics_model.dart`

```dart
class PointStatistics {
  final int totalEarned;
  final int totalUsed;
  final int thisMonthEarned;
  final int thisMonthUsed;
  
  PointStatistics({
    required this.totalEarned,
    required this.totalUsed,
    required this.thisMonthEarned,
    required this.thisMonthUsed,
  });
  
  factory PointStatistics.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  
  int get netBalance => totalEarned - totalUsed;
  int get thisMonthNet => thisMonthEarned - thisMonthUsed;
}
```

**PointFilter Model**

**File**: `lib/data/models/point_filter_model.dart`

```dart
enum PointFilterType { all, addition, deduction }
enum PointFilterPeriod { allTime, thisMonth, last3Months, last6Months }

class PointFilter {
  final PointFilterType type;
  final PointFilterPeriod period;
  
  PointFilter({
    required this.type,
    required this.period,
  });
  
  factory PointFilter.all() => PointFilter(
    type: PointFilterType.all,
    period: PointFilterPeriod.allTime,
  );
  
  bool matches(PointHistory history) {
    // Check type filter
    if (type == PointFilterType.addition && !history.isAddition) return false;
    if (type == PointFilterType.deduction && !history.isDeduction) return false;
    
    // Check period filter
    final now = DateTime.now();
    switch (period) {
      case PointFilterPeriod.thisMonth:
        return history.waktu.year == now.year && 
               history.waktu.month == now.month;
      case PointFilterPeriod.last3Months:
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        return history.waktu.isAfter(threeMonthsAgo);
      case PointFilterPeriod.last6Months:
        final sixMonthsAgo = DateTime(now.year, now.month - 6, now.day);
        return history.waktu.isAfter(sixMonthsAgo);
      default:
        return true;
    }
  }
  
  String get displayText {
    final typeText = type == PointFilterType.all ? 'Semua' :
                     type == PointFilterType.addition ? 'Penambahan' : 'Pengurangan';
    final periodText = period == PointFilterPeriod.allTime ? 'Semua Waktu' :
                       period == PointFilterPeriod.thisMonth ? 'Bulan Ini' :
                       period == PointFilterPeriod.last3Months ? '3 Bulan Terakhir' :
                       '6 Bulan Terakhir';
    return '$typeText • $periodText';
  }
}
```

## Data Models

### Database Schema (Backend)

Menggunakan tabel yang sudah ada di SKPPL:

**Table: user**
- `id_user` (bigint, PK)
- `saldo_poin` (int) - Current point balance

**Table: riwayat_poin**
- `id_poin` (bigint, PK)
- `id_user` (bigint, FK)
- `id_transaksi` (bigint, FK, nullable)
- `poin` (int) - Amount of points changed
- `perubahan` (enum: 'tambah', 'kurang')
- `keterangan` (varchar 255) - Description
- `waktu` (datetime) - Timestamp

### Data Flow

**Fetching Balance**:
```
PointPage → PointProvider.fetchBalance() 
  → PointService.getBalance() 
  → GET /api/points/balance 
  → Backend queries user.saldo_poin
  → Returns { "balance": 1250 }
  → PointProvider updates _balance
  → notifyListeners()
  → UI rebuilds with new balance
```

**Fetching History**:
```
PointPage → PointProvider.fetchHistory() 
  → PointService.getHistory(page: 1, limit: 20)
  → GET /api/points/history?page=1&limit=20
  → Backend queries riwayat_poin with pagination
  → Returns { "data": [...], "meta": {...} }
  → PointProvider updates _history
  → notifyListeners()
  → UI rebuilds with history list
```

**Using Points for Payment**:
```
PaymentPage → PointProvider.usePoints(amount, transactionId)
  → PointService.usePoints(amount, transactionId)
  → POST /api/points/use { amount, transaction_id }
  → Backend:
      1. Validates sufficient balance
      2. Deducts from user.saldo_poin
      3. Creates entry in riwayat_poin (perubahan='kurang')
      4. Updates pembayaran table
  → Returns { "success": true, "new_balance": 750 }
  → PointProvider updates _balance
  → notifyListeners()
  → PaymentPage shows success
  → PointPage auto-refreshes
```

### Caching Strategy

**SharedPreferences Cache**:
```dart
// Cache keys
static const String CACHE_KEY_BALANCE = 'point_balance';
static const String CACHE_KEY_HISTORY = 'point_history';
static const String CACHE_KEY_LAST_SYNC = 'point_last_sync';

// Cache implementation in PointProvider
void _cacheData() {
  final prefs = await SharedPreferences.getInstance();
  prefs.setInt(CACHE_KEY_BALANCE, _balance ?? 0);
  prefs.setString(CACHE_KEY_HISTORY, jsonEncode(_history));
  prefs.setString(CACHE_KEY_LAST_SYNC, DateTime.now().toIso8601String());
}

void _loadCachedData() {
  final prefs = await SharedPreferences.getInstance();
  _balance = prefs.getInt(CACHE_KEY_BALANCE);
  final historyJson = prefs.getString(CACHE_KEY_HISTORY);
  if (historyJson != null) {
    _history = (jsonDecode(historyJson) as List)
        .map((e) => PointHistory.fromJson(e))
        .toList();
  }
  final lastSyncStr = prefs.getString(CACHE_KEY_LAST_SYNC);
  if (lastSyncStr != null) {
    _lastSyncTime = DateTime.parse(lastSyncStr);
  }
  notifyListeners();
}
```

**Cache Invalidation**:
- Auto-refresh if last sync > 30 seconds when page is opened
- Manual refresh via pull-to-refresh
- Clear cache on logout
- Update cache after successful API calls

