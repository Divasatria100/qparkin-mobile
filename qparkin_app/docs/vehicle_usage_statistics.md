# Vehicle Usage Statistics Implementation

## Overview

This document describes the implementation of vehicle usage statistics in the QPARKIN mobile app. This feature displays parking history metrics for each registered vehicle, helping users track their parking patterns and expenses.

## Implementation Date

December 3, 2025

## Components

### 1. VehicleStatistics Model

**Location**: `lib/data/models/vehicle_statistics.dart`

A new model that encapsulates usage statistics for a vehicle:

```dart
class VehicleStatistics {
  final int parkingCount;           // Total number of parking sessions
  final int totalParkingMinutes;    // Total parking time in minutes
  final double totalCostSpent;      // Total cost spent on parking
  final DateTime? lastParkingDate;  // Last parking date
}
```

**Key Features**:
- Formatted display methods for time and cost
- Average calculations (average parking duration, average cost per session)
- JSON serialization/deserialization
- Safe parsing of numeric values

### 2. Enhanced VehicleModel

**Location**: `lib/data/models/vehicle_model.dart`

The `VehicleModel` has been enhanced to include an optional `statistics` field:

```dart
class VehicleModel {
  // ... existing fields
  final VehicleStatistics? statistics;
}
```

This allows vehicles to optionally include usage statistics when fetched from the API.

### 3. Enhanced VehicleCard Widget

**Location**: `lib/presentation/widgets/profile/vehicle_card.dart`

The `VehicleCard` widget now displays statistics when available:

**Statistics Display**:
- **Parking Count**: Shows total number of parking sessions (e.g., "15x")
- **Total Time**: Shows total parking time formatted (e.g., "20 jam")
- **Total Cost**: Shows total cost with thousand separators (e.g., "Rp 150.000")
- **View History Button**: Navigates to vehicle-specific history

**Visual Design**:
- Statistics appear in a light gray container below vehicle info
- Three-column layout with icons for each metric
- Consistent with QPARKIN design system (8dp grid, purple accent color)
- Responsive text sizing to prevent overflow

### 4. ProfileProvider Updates

**Location**: `lib/logic/providers/profile_provider.dart`

Mock data has been added to demonstrate the statistics feature:

```dart
VehicleModel(
  // ... vehicle fields
  statistics: VehicleStatistics(
    parkingCount: 15,
    totalParkingMinutes: 1200,  // 20 hours
    totalCostSpent: 150000,
    lastParkingDate: DateTime.now().subtract(const Duration(days: 2)),
  ),
)
```

## API Integration

### Expected API Response Format

When the backend API is implemented, it should return vehicle data with statistics:

```json
{
  "id_kendaraan": "1",
  "plat_nomor": "B 1234 XYZ",
  "jenis_kendaraan": "Roda Empat",
  "merk": "Toyota",
  "tipe": "Avanza",
  "warna": "Hitam",
  "is_active": true,
  "statistics": {
    "parking_count": 15,
    "total_parking_minutes": 1200,
    "total_cost_spent": 150000,
    "last_parking_date": "2025-12-01T10:30:00Z"
  }
}
```

### Backend Requirements

The backend should calculate statistics by:
1. Counting completed parking transactions for each vehicle
2. Summing total parking duration from all transactions
3. Summing total costs from all transactions
4. Tracking the most recent parking date

## User Experience

### Display Logic

- **With Statistics**: Vehicle card expands to show statistics section with metrics and "Lihat Riwayat" button
- **Without Statistics**: Vehicle card displays normally without statistics section (backward compatible)

### Interaction

- Tapping the "Lihat Riwayat" button navigates to vehicle detail page
- Statistics provide at-a-glance insights without cluttering the UI
- Formatted values make numbers easy to read (thousand separators, time units)

## Testing

All existing tests continue to pass:
- ✅ `test/models/vehicle_model_test.dart` - Model serialization
- ✅ `test/widgets/vehicle_card_test.dart` - Widget rendering
- ✅ `test/providers/profile_provider_test.dart` - State management

## Future Enhancements

Potential improvements for future iterations:

1. **Detailed History View**: Create a dedicated page showing transaction history for a specific vehicle
2. **Charts and Graphs**: Visualize parking patterns over time
3. **Comparison**: Compare statistics across multiple vehicles
4. **Export**: Allow users to export parking history as PDF or CSV
5. **Filters**: Filter history by date range, mall, or cost
6. **Insights**: Provide AI-generated insights about parking habits

## Accessibility

The statistics display includes:
- Semantic labels for screen readers
- Sufficient color contrast (WCAG AA compliant)
- Touch targets meet minimum 48dp requirement
- Text scales properly with system font size settings

## Performance Considerations

- Statistics are optional and don't impact performance when absent
- Formatted strings are computed on-demand (no caching needed for small datasets)
- Minimal memory footprint (4 fields per vehicle)

## Maintenance Notes

- Statistics are calculated server-side to ensure accuracy
- Client-side formatting ensures consistent display across devices
- Model includes safe parsing to handle various data types from API
- Backward compatible with vehicles that don't have statistics

## Related Files

- `lib/data/models/vehicle_statistics.dart` - Statistics model
- `lib/data/models/vehicle_model.dart` - Enhanced vehicle model
- `lib/presentation/widgets/profile/vehicle_card.dart` - Enhanced card widget
- `lib/logic/providers/profile_provider.dart` - Mock data provider
- `test/models/vehicle_model_test.dart` - Model tests
- `test/widgets/vehicle_card_test.dart` - Widget tests

## References

- Task: `.kiro/specs/profile-page-enhancement/tasks.md` - Task 28
- Design: `.kiro/specs/profile-page-enhancement/design.md`
- Requirements: `.kiro/specs/profile-page-enhancement/requirements.md`
