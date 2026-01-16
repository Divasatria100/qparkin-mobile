# Flutter Integration Guide - Admin Parkiran Slot System

**Date:** 2025-01-02  
**Status:** Ready for Integration  
**Backend Status:** ✅ Tested & Working

---

## 🎯 OVERVIEW

Backend sistem auto-generate slot parkiran sudah **100% siap** dan telah ditest. Guide ini untuk Flutter team melakukan integrasi dengan `booking_page.dart`.

---

## ✅ BACKEND STATUS

### What's Ready:
- ✅ Migration executed
- ✅ Auto-generate slot working (tested with 18 slots)
- ✅ API endpoints tested and returning correct data
- ✅ Response format matches Flutter models
- ✅ Slot codes format: `{KODE}-L{LANTAI}-{NOMOR}` (e.g., `TST-L1-001`)

### Test Data Available:
```
Parkiran: "Parkiran Test Mawar"
Kode: TST
Mall ID: 8
Lantai 1: 10 slots (TST-L1-001 to TST-L1-010)
Lantai 2: 8 slots (TST-L2-001 to TST-L2-008)
```

---

## 📋 API ENDPOINTS

### 1. Get Parking Floors

**Endpoint:** `GET /api/parking/floors/{mallId}`

**Headers:**
```
Authorization: Bearer {token}
Accept: application/json
```

**Response:**
```json
{
    "success": true,
    "data": [
        {
            "id_floor": "8",
            "id_mall": "8",
            "floor_number": 1,
            "floor_name": "Lantai 1",
            "total_slots": 10,
            "available_slots": 10,
            "occupied_slots": 0,
            "reserved_slots": 0,
            "last_updated": "2025-01-02T10:00:00+00:00"
        }
    ]
}
```

**Flutter Model:** `ParkingFloorModel`
```dart
class ParkingFloorModel {
  final String idFloor;
  final String idMall;
  final int floorNumber;
  final String floorName;
  final int totalSlots;
  final int availableSlots;
  final int occupiedSlots;
  final int reservedSlots;
  final DateTime lastUpdated;

  factory ParkingFloorModel.fromJson(Map<String, dynamic> json) {
    return ParkingFloorModel(
      idFloor: json['id_floor'].toString(),
      idMall: json['id_mall'].toString(),
      floorNumber: json['floor_number'],
      floorName: json['floor_name'],
      totalSlots: json['total_slots'],
      availableSlots: json['available_slots'],
      occupiedSlots: json['occupied_slots'],
      reservedSlots: json['reserved_slots'],
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }
}
```

---

### 2. Get Slots for Visualization

**Endpoint:** `GET /api/parking/slots/{floorId}/visualization`

**Headers:**
```
Authorization: Bearer {token}
Accept: application/json
```

**Query Parameters (Optional):**
- `vehicle_type` - Filter by vehicle type (e.g., "Roda Empat")

**Response:**
```json
{
    "success": true,
    "data": [
        {
            "id_slot": "8",
            "id_floor": "8",
            "slot_code": "TST-L1-001",
            "status": "available",
            "slot_type": "regular",
            "position_x": 1,
            "position_y": 1,
            "last_updated": "2025-01-02T10:00:00+00:00"
        }
    ]
}
```

**Flutter Model:** `ParkingSlotModel`
```dart
class ParkingSlotModel {
  final String idSlot;
  final String idFloor;
  final String slotCode;
  final String status; // 'available', 'reserved', 'occupied'
  final String slotType; // 'regular', 'disableFriendly'
  final int positionX;
  final int positionY;
  final DateTime lastUpdated;

  factory ParkingSlotModel.fromJson(Map<String, dynamic> json) {
    return ParkingSlotModel(
      idSlot: json['id_slot'].toString(),
      idFloor: json['id_floor'].toString(),
      slotCode: json['slot_code'],
      status: json['status'],
      slotType: json['slot_type'],
      positionX: json['position_x'],
      positionY: json['position_y'],
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }
}
```

---

### 3. Reserve Random Slot

**Endpoint:** `POST /api/parking/slots/reserve-random`

**Headers:**
```
Authorization: Bearer {token}
Accept: application/json
Content-Type: application/json
```

**Request Body:**
```json
{
    "id_floor": 8,
    "id_user": 1,
    "vehicle_type": "Roda Empat",
    "duration_minutes": 5
}
```

**Response:**
```json
{
    "success": true,
    "data": {
        "reservation_id": "1",
        "slot_id": "10",
        "slot_code": "TST-L1-010",
        "floor_name": "Lantai 1",
        "floor_number": "1",
        "slot_type": "regular",
        "reserved_at": "2025-01-02T10:00:00+00:00",
        "expires_at": "2025-01-02T10:05:00+00:00"
    },
    "message": "Slot TST-L1-010 berhasil direservasi untuk 5 menit"
}
```

**Flutter Model:** `SlotReservationModel`
```dart
class SlotReservationModel {
  final String reservationId;
  final String slotId;
  final String slotCode;
  final String floorName;
  final String floorNumber;
  final String slotType;
  final DateTime reservedAt;
  final DateTime expiresAt;

  factory SlotReservationModel.fromJson(Map<String, dynamic> json) {
    return SlotReservationModel(
      reservationId: json['reservation_id'].toString(),
      slotId: json['slot_id'].toString(),
      slotCode: json['slot_code'],
      floorName: json['floor_name'],
      floorNumber: json['floor_number'],
      slotType: json['slot_type'],
      reservedAt: DateTime.parse(json['reserved_at']),
      expiresAt: DateTime.parse(json['expires_at']),
    );
  }
}
```

---

## 🔧 INTEGRATION STEPS

### Step 1: Update API Service

**File:** `lib/data/services/booking_service.dart`

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/parking_floor_model.dart';
import '../models/parking_slot_model.dart';
import '../models/slot_reservation_model.dart';

class BookingService {
  final String baseUrl;
  final String? token;

  BookingService({required this.baseUrl, this.token});

  // Get parking floors for a mall
  Future<List<ParkingFloorModel>> getFloors(String mallId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/parking/floors/$mallId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return (data['data'] as List)
            .map((json) => ParkingFloorModel.fromJson(json))
            .toList();
      }
    }
    throw Exception('Failed to load floors');
  }

  // Get slots for visualization
  Future<List<ParkingSlotModel>> getSlotsForVisualization(
    String floorId, {
    String? vehicleType,
  }) async {
    var uri = Uri.parse('$baseUrl/api/parking/slots/$floorId/visualization');
    if (vehicleType != null) {
      uri = uri.replace(queryParameters: {'vehicle_type': vehicleType});
    }

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return (data['data'] as List)
            .map((json) => ParkingSlotModel.fromJson(json))
            .toList();
      }
    }
    throw Exception('Failed to load slots');
  }

  // Reserve random slot
  Future<SlotReservationModel> reserveRandomSlot({
    required String floorId,
    required String userId,
    required String vehicleType,
    int durationMinutes = 5,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/parking/slots/reserve-random'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'id_floor': int.parse(floorId),
        'id_user': int.parse(userId),
        'vehicle_type': vehicleType,
        'duration_minutes': durationMinutes,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['success']) {
        return SlotReservationModel.fromJson(data['data']);
      }
    } else if (response.statusCode == 404) {
      final data = json.decode(response.body);
      if (data['message'] == 'NO_SLOTS_AVAILABLE') {
        throw NoSlotsAvailableException(data['error']);
      }
    }
    throw Exception('Failed to reserve slot');
  }
}

class NoSlotsAvailableException implements Exception {
  final String message;
  NoSlotsAvailableException(this.message);
}
```

---

### Step 2: Update Booking Provider

**File:** `lib/logic/providers/booking_provider.dart`

```dart
import 'package:flutter/foundation.dart';
import '../../data/services/booking_service.dart';
import '../../data/models/parking_floor_model.dart';
import '../../data/models/parking_slot_model.dart';
import '../../data/models/slot_reservation_model.dart';

class BookingProvider with ChangeNotifier {
  final BookingService _bookingService;

  List<ParkingFloorModel> _floors = [];
  List<ParkingSlotModel> _slots = [];
  SlotReservationModel? _reservation;
  
  bool _isLoadingFloors = false;
  bool _isLoadingSlots = false;
  bool _isReserving = false;
  
  String? _error;

  BookingProvider(this._bookingService);

  // Getters
  List<ParkingFloorModel> get floors => _floors;
  List<ParkingSlotModel> get slots => _slots;
  SlotReservationModel? get reservation => _reservation;
  bool get isLoadingFloors => _isLoadingFloors;
  bool get isLoadingSlots => _isLoadingSlots;
  bool get isReserving => _isReserving;
  String? get error => _error;

  // Load floors for a mall
  Future<void> loadFloors(String mallId) async {
    _isLoadingFloors = true;
    _error = null;
    notifyListeners();

    try {
      _floors = await _bookingService.getFloors(mallId);
      _isLoadingFloors = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoadingFloors = false;
      notifyListeners();
    }
  }

  // Load slots for a floor
  Future<void> loadSlots(String floorId, {String? vehicleType}) async {
    _isLoadingSlots = true;
    _error = null;
    notifyListeners();

    try {
      _slots = await _bookingService.getSlotsForVisualization(
        floorId,
        vehicleType: vehicleType,
      );
      _isLoadingSlots = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoadingSlots = false;
      notifyListeners();
    }
  }

  // Reserve random slot
  Future<bool> reserveSlot({
    required String floorId,
    required String userId,
    required String vehicleType,
    int durationMinutes = 5,
  }) async {
    _isReserving = true;
    _error = null;
    notifyListeners();

    try {
      _reservation = await _bookingService.reserveRandomSlot(
        floorId: floorId,
        userId: userId,
        vehicleType: vehicleType,
        durationMinutes: durationMinutes,
      );
      _isReserving = false;
      notifyListeners();
      return true;
    } on NoSlotsAvailableException catch (e) {
      _error = e.message;
      _isReserving = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isReserving = false;
      notifyListeners();
      return false;
    }
  }

  // Clear reservation
  void clearReservation() {
    _reservation = null;
    notifyListeners();
  }
}
```

---

### Step 3: Test Integration

**Test File:** `test/integration/admin_parkiran_integration_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/data/services/booking_service.dart';
import 'package:qparkin_app/logic/providers/booking_provider.dart';

void main() {
  group('Admin Parkiran Integration Tests', () {
    late BookingService bookingService;
    late BookingProvider bookingProvider;

    setUp(() {
      // Use test backend URL
      bookingService = BookingService(
        baseUrl: 'http://127.0.0.1:8000',
        token: 'test_token', // Replace with actual test token
      );
      bookingProvider = BookingProvider(bookingService);
    });

    test('Should load floors for mall', () async {
      // Test with mall ID 8 (test data)
      await bookingProvider.loadFloors('8');

      expect(bookingProvider.floors.isNotEmpty, true);
      expect(bookingProvider.floors.length, 2); // Lantai 1 & 2
      expect(bookingProvider.floors[0].floorName, 'Lantai 1');
      expect(bookingProvider.floors[0].totalSlots, 10);
    });

    test('Should load slots for floor', () async {
      // Test with floor ID 8 (Lantai 1)
      await bookingProvider.loadSlots('8');

      expect(bookingProvider.slots.isNotEmpty, true);
      expect(bookingProvider.slots.length, 10);
      expect(bookingProvider.slots[0].slotCode, 'TST-L1-001');
      expect(bookingProvider.slots[0].status, 'available');
    });

    test('Should reserve random slot', () async {
      final success = await bookingProvider.reserveSlot(
        floorId: '8',
        userId: '1',
        vehicleType: 'Roda Empat',
        durationMinutes: 5,
      );

      expect(success, true);
      expect(bookingProvider.reservation, isNotNull);
      expect(bookingProvider.reservation!.slotCode.startsWith('TST-L1-'), true);
    });
  });
}
```

---

## 🧪 TESTING CHECKLIST

### Manual Testing:
- [ ] Login to app with valid credentials
- [ ] Navigate to booking page
- [ ] Verify floor selector shows "Lantai 1" and "Lantai 2"
- [ ] Select "Lantai 1"
- [ ] Verify slot visualization shows 10 slots
- [ ] Verify slot codes: TST-L1-001 to TST-L1-010
- [ ] Tap "Reserve Slot" button
- [ ] Verify reservation success message
- [ ] Verify reserved slot code displays correctly
- [ ] Verify booking summary shows slot code

### Automated Testing:
- [ ] Run integration tests
- [ ] Run widget tests for booking page
- [ ] Run provider tests
- [ ] Check for memory leaks
- [ ] Test error scenarios (no slots available)

---

## 🐛 TROUBLESHOOTING

### Issue 1: 401 Unauthorized
**Cause:** Missing or invalid authentication token

**Solution:**
```dart
// Ensure token is passed to BookingService
final token = await secureStorage.read(key: 'auth_token');
final bookingService = BookingService(
  baseUrl: apiUrl,
  token: token,
);
```

### Issue 2: Empty floors list
**Cause:** Mall has no parkiran with status "Tersedia"

**Solution:**
- Check if mall ID is correct
- Verify parkiran exists in database
- Check parkiran status is "Tersedia" (not "Ditutup")

### Issue 3: Slot codes not displaying
**Cause:** API response format mismatch

**Solution:**
- Check `ParkingSlotModel.fromJson()` implementation
- Verify field names match API response
- Check for null values

---

## 📞 SUPPORT

**Backend Team Contact:**
- API issues: Check `qparkin_backend/storage/logs/laravel.log`
- Database issues: Run `php artisan tinker` to inspect data

**Test Data:**
- Mall ID: 8
- Floor IDs: 8 (Lantai 1), 9 (Lantai 2)
- Slot Codes: TST-L1-001 to TST-L2-008

**Documentation:**
- `ADMIN_PARKIRAN_TESTING_COMPLETE.md` - Test results
- `ADMIN_PARKIRAN_IMPLEMENTATION_COMPLETE.md` - Implementation details

---

**Last Updated:** 2025-01-02  
**Backend Version:** Tested & Working  
**Ready for Integration:** ✅ YES

