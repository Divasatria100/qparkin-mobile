# Booking History Integration

## Overview

This document describes how bookings integrate with the parking history system after completion.

## Current Implementation

### History Data Structure

The Activity Page's "Riwayat" tab currently displays parking history using a static list with the following structure:

```dart
{
  'location': 'Mall Name',
  'date': '15 Nov 2023',
  'time': '10:00 - 12:30',
  'duration': '2 jam 30 menit',
  'cost': 'Rp 15.000',
}
```

### Booking Data Structure

Bookings created through the BookingPage use the `BookingModel` class with the following key fields:

```dart
class BookingModel {
  final String idTransaksi;
  final String idBooking;
  final String idMall;
  final String namaMall;  // Maps to history 'location'
  final DateTime waktuMulai;  // Maps to history 'date' and 'time' (start)
  final DateTime waktuSelesai;  // Maps to history 'time' (end)
  final int durasiBooking;  // Maps to history 'duration'
  final String status;  // 'aktif', 'selesai', 'expired'
  final double biayaEstimasi;  // Maps to history 'cost'
}
```

## Integration Flow

### 1. Booking Creation
When a booking is created via `BookingPage`:
1. User confirms booking
2. `BookingProvider.confirmBooking()` calls `BookingService.createBooking()`
3. Backend creates `transaksi_parkir` and `booking` records with `status='aktif'`
4. Booking appears in Activity Page's "Aktivitas" tab

### 2. Booking Completion
When a booking is completed (user exits parking):
1. User scans QR code at exit gate
2. Backend updates booking `status='selesai'`
3. Backend calculates final cost (may differ from estimate if overtime)
4. Booking automatically moves from "Aktivitas" to "Riwayat" tab

### 3. History Display
The history tab should fetch completed bookings from the backend:

```dart
// Recommended implementation
class HistoryProvider extends ChangeNotifier {
  final ParkingService _parkingService;
  List<BookingModel> _history = [];
  
  Future<void> fetchHistory({required String token}) async {
    // Fetch completed bookings from backend
    final bookings = await _parkingService.getParkingHistory(token: token);
    _history = bookings.where((b) => b.status == 'selesai').toList();
    notifyListeners();
  }
}
```

## Data Mapping

### BookingModel → History Display

| BookingModel Field | History Field | Transformation |
|-------------------|---------------|----------------|
| `namaMall` | `location` | Direct mapping |
| `waktuMulai` | `date` | Format: `DateFormat('dd MMM yyyy')` |
| `waktuMulai` + `waktuSelesai` | `time` | Format: `HH:mm - HH:mm` |
| `durasiBooking` | `duration` | Format: `X jam Y menit` |
| `biayaEstimasi` or `biayaAkhir` | `cost` | Format: `Rp X.XXX` |

### Example Transformation

```dart
Map<String, dynamic> bookingToHistory(BookingModel booking) {
  final startTime = DateFormat('HH:mm').format(booking.waktuMulai);
  final endTime = DateFormat('HH:mm').format(booking.waktuSelesai);
  final date = DateFormat('dd MMM yyyy').format(booking.waktuMulai);
  
  final hours = booking.durasiBooking;
  final minutes = ((booking.waktuSelesai.difference(booking.waktuMulai).inMinutes % 60));
  final duration = minutes > 0 
      ? '$hours jam $minutes menit' 
      : '$hours jam';
  
  final cost = CostCalculator.formatCurrency(booking.biayaAkhir ?? booking.biayaEstimasi);
  
  return {
    'location': booking.namaMall,
    'date': date,
    'time': '$startTime - $endTime',
    'duration': duration,
    'cost': cost,
  };
}
```

## Backend Requirements

For proper history integration, the backend must:

1. **Update Booking Status**: Change `status` from `'aktif'` to `'selesai'` when parking ends
2. **Calculate Final Cost**: Store actual cost in `biaya_akhir` field (may include penalties)
3. **Provide History Endpoint**: API endpoint to fetch completed bookings
   ```
   GET /api/parking/history?token={token}&status=selesai
   ```
4. **Sort by Date**: Return history sorted by `waktu_selesai` descending (most recent first)
5. **Pagination**: Support pagination for large history lists

## Testing Verification

To verify history integration:

1. **Create a booking** via BookingPage
2. **Verify it appears** in Activity Page "Aktivitas" tab
3. **Complete the parking** (scan QR at exit)
4. **Verify status update** to `'selesai'`
5. **Verify it appears** in Activity Page "Riwayat" tab
6. **Verify data accuracy**: location, date, time, duration, cost match booking

## Current Status

✅ **Completed**:
- Booking creation flow
- Activity Page displays active bookings
- Data structure compatibility between BookingModel and history format

⏳ **Pending** (Backend Implementation):
- Automatic status update from 'aktif' to 'selesai'
- History API endpoint
- Final cost calculation with penalties
- History provider/service in mobile app

## Requirements Reference

This integration satisfies:
- **Requirement 10.8**: Update Activity Page to display new active booking
- **Requirement 10.9**: Verify booking appears in history after completion
- **Requirement 15.4**: Use existing ParkingService for data fetching

## Notes

- The current static history data in `activity_page.dart` should be replaced with dynamic data from `HistoryProvider` once backend endpoints are ready
- History should automatically refresh when user navigates to the "Riwayat" tab
- Consider implementing pull-to-refresh for manual history updates
- Consider caching history data to improve performance and reduce API calls
