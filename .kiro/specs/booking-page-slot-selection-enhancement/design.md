# Design Document

## Overview

This design document outlines the implementation of two major UX/UI enhancements to the QPARKIN Booking Page:

1. **Hybrid Slot Reservation Feature**: Floor selection and visual slot availability display with system-controlled random slot assignment
2. **Modern Time & Duration Design**: Unified card design with improved date picker and larger interactive chips

### Design Goals

1. **Guaranteed Slot Reservation**: Ensure drivers get specific slot assignments through system-controlled allocation
2. **Visual Transparency**: Provide clear visual representation of parking availability without manual selection complexity
3. **Modern Interface**: Implement contemporary UI patterns with larger touch targets
4. **Seamless Integration**: Integrate smoothly with existing booking flow
5. **Performance**: Maintain fast load times and smooth interactions
6. **Accessibility**: Ensure all users can access and use new features

## Architecture

### Component Structure

```
lib/
├── presentation/
│   ├── screens/
│   │   └── booking_page.dart                    # Updated with slot reservation
│   ├── widgets/
│   │   ├── floor_selector_widget.dart          # NEW: Floor selection
│   │   ├── slot_visualization_widget.dart      # NEW: Slot display (non-interactive)
│   │   ├── slot_reservation_button.dart        # NEW: Random slot reservation
│   │   ├── unified_time_duration_card.dart     # NEW: Combined time/duration
│   │   ├── reserved_slot_info_card.dart        # NEW: Reserved slot display
│   │   └── time_duration_picker.dart           # DEPRECATED (replaced)
├── logic/
│   └── providers/
│       └── booking_provider.dart                # Updated with reservation state
├── data/
│   ├── models/
│   │   ├── parking_floor_model.dart            # NEW: Floor data
│   │   ├── parking_slot_model.dart             # NEW: Slot data (for visualization)
│   │   └── slot_reservation_model.dart         # NEW: Reservation data
│   └── services/
│       └── booking_service.dart                 # Updated with reservation APIs
└── utils/
    └── slot_validator.dart                      # NEW: Slot validation
```



### Data Flow

```
1. Slot Reservation Flow:
   User selects mall → BookingPage loads
   → BookingProvider.fetchFloors(mallId)
   → Display FloorSelectorWidget
   → User selects floor
   → BookingProvider.fetchSlotsForVisualization(floorId)
   → Display SlotVisualizationWidget (non-interactive)
   → User taps "Pesan Slot Acak di [Nama Lantai]"
   → BookingProvider.reserveRandomSlot(floorId)
   → Backend assigns specific slot (e.g., L1-A12)
   → Display ReservedSlotInfoCard
   → Continue to time/duration selection

2. Time & Duration Flow:
   User views UnifiedTimeDurationCard
   → Taps date/time section
   → Opens Material DatePicker
   → User selects date
   → Opens Material TimePicker
   → User selects time
   → BookingProvider.setStartTime(dateTime)
   → User taps duration chip
   → BookingProvider.setDuration(duration)
   → Calculate and display end time
   → Update cost calculation

3. Booking Confirmation Flow:
   User reviews summary (including reserved slot)
   → Taps "Konfirmasi Booking"
   → BookingProvider.confirmBooking()
   → BookingService.createBooking(with reservedSlotId)
   → Backend confirms slot reservation
   → Return QR code with slot info
   → Display confirmation dialog
   → Navigate to Activity Page
```



## Components and Interfaces

### 1. FloorSelectorWidget

**Purpose**: Display list of parking floors with availability information

**Design Specs**:
- Vertical list of floor cards
- Each card: 16px rounded corners, elevation 2
- White background, purple accent for selected
- Height: 80px per card
- Spacing: 12px between cards

**Content Structure**:
```
Card (per floor)
├─ Row
│   ├─ Container (Floor Number Badge)
│   │   ├─ Circle (56px diameter, purple background)
│   │   └─ Text (floor number, 20px bold, white)
│   ├─ SizedBox(width: 16)
│   ├─ Column (Floor Info)
│   │   ├─ Text (floor name, 16px bold, black87)
│   │   ├─ SizedBox(height: 4)
│   │   └─ Row
│   │       ├─ Icon (local_parking, 16px, green/grey)
│   │       ├─ SizedBox(width: 4)
│   │       └─ Text ("X slot tersedia", 14px, grey600)
│   └─ Spacer()
│   └─ Icon (chevron_right, 24px, grey400)
```

**States**:
- Default: White background, grey text
- Available: Green parking icon
- Unavailable: Grey parking icon, disabled state
- Selected: Purple border (2px), purple background tint



### 2. SlotVisualizationWidget (Non-Interactive)

**Purpose**: Visual display of parking slots with status colors (display-only)

**Design Specs**:
- GridView with 4-6 columns (responsive)
- Each slot: 64x64px square
- 8px spacing between slots
- Rounded corners: 8px
- NO tap/click interaction
- NO selection state

**Content Structure**:
```
Column
├─ Row (Header)
│   ├─ Text ("Ketersediaan Slot", 16px bold)
│   ├─ Spacer()
│   ├─ Text ("Terakhir diperbarui: 14:30", 12px grey)
│   └─ IconButton (refresh, 20px)
├─ SizedBox(height: 12)
├─ Text ("X slot tersedia dari Y total", 14px grey600)
├─ SizedBox(height: 16)
└─ GridView.builder (NON-INTERACTIVE)
    └─ For each slot:
        Container (Slot Card - DISPLAY ONLY)
        ├─ Background color (status-based)
        ├─ NO border (no selection)
        ├─ NO tap handler
        └─ Column (centered)
            ├─ Icon (slot type, 20px)
            ├─ SizedBox(height: 4)
            └─ Text (slot code, 12px bold)
```

**Color Coding**:
- Available: Green (0xFF4CAF50) background, white text
- Occupied: Grey (0xFF9E9E9E) background, white text
- Reserved: Yellow (0xFFFF9800) background, white text
- Disabled: Red (0xFFF44336) background, white text

**Icons**:
- Regular slot: local_parking icon
- Disable-friendly: accessible icon

### 3. SlotReservationButton

**Purpose**: Action button to request random slot reservation on selected floor

**Design Specs**:
- Full width button below slot visualization
- Height: 56px
- Purple background (0xFF573ED1)
- White text (16px bold)
- 16px rounded corners
- Elevation 4

**Content Structure**:
```
Container (Full width, 56px height)
└─ ElevatedButton
    ├─ Background: Purple (0xFF573ED1)
    ├─ Shape: RoundedRectangleBorder (16px radius)
    └─ Row (centered)
        ├─ Icon (casino, 20px, white) // Random icon
        ├─ SizedBox(width: 8)
        └─ Text ("Pesan Slot Acak di [Nama Lantai]", 16px bold, white)
```

**States**:
- Enabled: Purple background, white text
- Loading: Purple background, CircularProgressIndicator
- Disabled: Grey background, grey text

### 4. ReservedSlotInfoCard

**Purpose**: Display reserved slot information after successful reservation

**Design Specs**:
- White background card
- 16px rounded corners, elevation 3
- 16px padding
- Green accent for success state

**Content Structure**:
```
Card
├─ Container (Light green background, 12px padding, 8px radius)
│   └─ Row
│       ├─ Icon (check_circle, 24px, green)
│       ├─ SizedBox(width: 12)
│       └─ Column
│           ├─ Text ("Slot Berhasil Direservasi", 16px bold, green)
│           ├─ SizedBox(height: 4)
│           ├─ Text (slot code, 20px bold, black87)
│           │   "Lantai 2 - Slot A15"
│           ├─ Text (slot type, 14px, grey600)
│           │   "Regular Parking"
│           └─ Text ("Berlaku hingga: 14:45", 12px, grey600)
└─ SizedBox(height: 8)
└─ Text ("Slot ini telah dikunci untuk Anda", 12px, grey600)
```

**Animation**: 
- Slide up from bottom (300ms ease-out)
- Scale in effect (1.0 to 1.05 to 1.0)



### 5. UnifiedTimeDurationCard

**Purpose**: Modern combined interface for time and duration selection

**Design Specs**:
- Single card containing both selectors
- White background, 16px rounded corners
- Elevation 3 for prominence
- 24px padding all sides
- Purple accent color throughout

**Content Structure**:
```
Card
├─ Text ("Waktu & Durasi Booking", 18px bold, black87)
├─ SizedBox(height: 20)
│
├─ Section: Date & Time Selection
│   ├─ Row
│   │   ├─ Icon (calendar_today, 24px, purple)
│   │   ├─ SizedBox(width: 12)
│   │   └─ Column
│   │       ├─ Text (date, 20px bold, black87)
│   │       │   "Senin, 15 Januari 2025"
│   │       ├─ SizedBox(height: 4)
│   │       └─ Text (time, 20px bold, purple)
│   │           "14:30"
│   └─ InkWell (tap to open picker)
├─ SizedBox(height: 20)
├─ Divider (grey200, 1px)
├─ SizedBox(height: 20)
│
├─ Section: Duration Selection
│   ├─ Text ("Pilih Durasi", 16px bold, black87)
│   ├─ SizedBox(height: 12)
│   └─ SingleChildScrollView (horizontal)
│       └─ Row (duration chips)
│           ├─ DurationChip ("1 Jam", 80x56px)
│           ├─ SizedBox(width: 12)
│           ├─ DurationChip ("2 Jam", 80x56px)
│           ├─ SizedBox(width: 12)
│           ├─ DurationChip ("3 Jam", 80x56px)
│           ├─ SizedBox(width: 12)
│           ├─ DurationChip ("4 Jam", 80x56px)
│           ├─ SizedBox(width: 12)
│           └─ DurationChip ("> 4 Jam", 80x56px)
├─ SizedBox(height: 16)
├─ Text ("Durasi: 2 jam", 14px, grey600)
├─ SizedBox(height: 20)
├─ Divider (grey200, 1px)
├─ SizedBox(height: 16)
│
└─ Section: Calculated End Time
    └─ Container (light purple background, 16px padding, 12px rounded)
        └─ Row
            ├─ Icon (schedule, 20px, purple)
            ├─ SizedBox(width: 8)
            └─ Column
                ├─ Text ("Selesai:", 14px, purple)
                ├─ Text ("Senin, 15 Jan 2025 - 16:30", 16px bold, purple)
                └─ Text ("Total: 2 jam", 12px, purple)
```



### 6. DurationChip Component

**Purpose**: Large, interactive button for duration selection

**Design Specs**:
- Size: 80px width × 56px height (minimum)
- Rounded corners: 12px
- Elevation: 2 (unselected), 4 (selected)
- Animation: Scale to 1.05 on tap, 200ms ease-out

**States**:

**Unselected**:
```
Container
├─ Background: Light purple (0xFFE8E0FF)
├─ Border: None
└─ Column (centered)
    ├─ Text (duration, 16px bold, purple)
    └─ No icon
```

**Selected**:
```
Container
├─ Background: Purple (0xFF573ED1)
├─ Border: None
├─ Shadow: Elevation 4
└─ Column (centered)
    ├─ Icon (check_circle, 16px, white)
    ├─ SizedBox(height: 4)
    └─ Text (duration, 16px bold, white)
```

**Pressed** (during tap):
```
- Scale: 0.95
- Duration: 100ms
- Haptic feedback: light impact
```







## Data Models

### ParkingFloorModel

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
  
  // Computed properties
  bool get hasAvailableSlots => availableSlots > 0;
  double get occupancyRate => (occupiedSlots + reservedSlots) / totalSlots;
  String get availabilityText => '$availableSlots slot tersedia';
  
  ParkingFloorModel({
    required this.idFloor,
    required this.idMall,
    required this.floorNumber,
    required this.floorName,
    required this.totalSlots,
    required this.availableSlots,
    required this.occupiedSlots,
    required this.reservedSlots,
    required this.lastUpdated,
  });
  
  factory ParkingFloorModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

### ParkingSlotModel (For Visualization Only)

```dart
enum SlotStatus { available, occupied, reserved, disabled }
enum SlotType { regular, disableFriendly }

class ParkingSlotModel {
  final String idSlot;
  final String idFloor;
  final String slotCode;
  final SlotStatus status;
  final SlotType slotType;
  final int? positionX;
  final int? positionY;
  final DateTime lastUpdated;
  
  // Computed properties for visualization
  Color get statusColor {
    switch (status) {
      case SlotStatus.available:
        return const Color(0xFF4CAF50);
      case SlotStatus.occupied:
        return const Color(0xFF9E9E9E);
      case SlotStatus.reserved:
        return const Color(0xFFFF9800);
      case SlotStatus.disabled:
        return const Color(0xFFF44336);
    }
  }
  IconData get typeIcon {
    return slotType == SlotType.disableFriendly
        ? Icons.accessible
        : Icons.local_parking;
  }
  String get typeLabel {
    return slotType == SlotType.disableFriendly
        ? 'Disable-Friendly'
        : 'Regular';
  }
  
  ParkingSlotModel({
    required this.idSlot,
    required this.idFloor,
    required this.slotCode,
    required this.status,
    required this.slotType,
    this.positionX,
    this.positionY,
    required this.lastUpdated,
  });
  
  factory ParkingSlotModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

### SlotReservationModel

```dart
class SlotReservationModel {
  final String reservationId;
  final String slotId;
  final String slotCode;
  final String floorName;
  final String floorNumber;
  final SlotType slotType;
  final DateTime reservedAt;
  final DateTime expiresAt;
  final bool isActive;
  
  // Computed properties
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  Duration get timeRemaining => expiresAt.difference(DateTime.now());
  String get displayName => '$floorName - Slot $slotCode';
  String get typeLabel => slotType == SlotType.disableFriendly 
      ? 'Disable-Friendly' 
      : 'Regular Parking';
  
  SlotReservationModel({
    required this.reservationId,
    required this.slotId,
    required this.slotCode,
    required this.floorName,
    required this.floorNumber,
    required this.slotType,
    required this.reservedAt,
    required this.expiresAt,
    required this.isActive,
  });
  
  factory SlotReservationModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```



## State Management Updates

### BookingProvider Extensions

```dart
class BookingProvider extends ChangeNotifier {
  // Existing state...
  
  // NEW: Slot reservation state
  List<ParkingFloorModel> _floors = [];
  ParkingFloorModel? _selectedFloor;
  List<ParkingSlotModel> _slotsVisualization = [];
  SlotReservationModel? _reservedSlot;
  bool _isLoadingFloors = false;
  bool _isLoadingSlots = false;
  bool _isReservingSlot = false;
  Timer? _slotRefreshTimer;
  Timer? _reservationTimer;
  
  // NEW: Getters
  List<ParkingFloorModel> get floors => _floors;
  ParkingFloorModel? get selectedFloor => _selectedFloor;
  List<ParkingSlotModel> get slotsVisualization => _slotsVisualization;
  SlotReservationModel? get reservedSlot => _reservedSlot;
  bool get isLoadingFloors => _isLoadingFloors;
  bool get isLoadingSlots => _isLoadingSlots;
  bool get isReservingSlot => _isReservingSlot;
  bool get hasReservedSlot => _reservedSlot != null && !_reservedSlot!.isExpired;
  
  // NEW: Methods
  Future<void> fetchFloors(String mallId, String token);
  Future<void> fetchSlotsForVisualization(String floorId, String token);
  void selectFloor(ParkingFloorModel floor);
  Future<bool> reserveRandomSlot(String floorId, String token);
  void clearReservation();
  Future<void> refreshSlotVisualization(String token);
  void startSlotRefreshTimer(String token);
  void stopSlotRefreshTimer();
  void startReservationTimer();
  void stopReservationTimer();
  
  // UPDATED: Booking confirmation includes reserved slot
  @override
  Future<bool> confirmBooking({
    required String token,
    Function(BookingModel)? onSuccess,
  }) async {
    // Validate slot reservation
    if (_reservedSlot == null || _reservedSlot!.isExpired) {
      _errorMessage = 'Reservasi slot telah berakhir. Silakan reservasi ulang.';
      notifyListeners();
      return false;
    }
    
    // Include reserved slot ID in booking request
    final request = BookingRequest(
      // ... existing fields
      idSlot: _reservedSlot!.slotId,
      reservationId: _reservedSlot!.reservationId,
    );
    
    // ... rest of booking logic
  }
}
```



## API Integration

### New Endpoints

#### 1. GET /api/parking/floors/{mallId}

**Purpose**: Fetch list of parking floors for a mall

**Request**:
```
GET /api/parking/floors/123
Headers:
  Authorization: Bearer {token}
```

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id_floor": "f1",
      "id_mall": "123",
      "floor_number": 1,
      "floor_name": "Lantai 1",
      "total_slots": 50,
      "available_slots": 12,
      "occupied_slots": 35,
      "reserved_slots": 3,
      "last_updated": "2025-01-15T14:30:00Z"
    },
    {
      "id_floor": "f2",
      "floor_number": 2,
      "floor_name": "Lantai 2",
      "total_slots": 60,
      "available_slots": 25,
      "occupied_slots": 30,
      "reserved_slots": 5,
      "last_updated": "2025-01-15T14:30:00Z"
    }
  ]
}
```

#### 2. GET /api/parking/slots/{floorId}/visualization

**Purpose**: Fetch slot data for visualization (non-interactive display)

**Request**:
```
GET /api/parking/slots/f1/visualization?vehicle_type=Roda%20Empat
Headers:
  Authorization: Bearer {token}
```

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id_slot": "s1",
      "id_floor": "f1",
      "slot_code": "A01",
      "status": "available",
      "slot_type": "regular",
      "position_x": 0,
      "position_y": 0,
      "last_updated": "2025-01-15T14:30:00Z"
    }
  ]
}
```

#### 3. POST /api/parking/slots/reserve-random

**Purpose**: Reserve a random available slot on specified floor

**Request**:
```json
{
  "id_floor": "f1",
  "id_user": "u123",
  "vehicle_type": "Roda Empat",
  "duration_minutes": 5
}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "reservation_id": "r123",
    "slot_id": "s15",
    "slot_code": "A15",
    "floor_name": "Lantai 1",
    "floor_number": "1",
    "slot_type": "regular",
    "reserved_at": "2025-01-15T14:30:00Z",
    "expires_at": "2025-01-15T14:35:00Z"
  },
  "message": "Slot A15 berhasil direservasi untuk 5 menit"
}
```



## Updated Booking Flow

### New Booking Page Layout

```
AppBar ("Booking Parkir")

ScrollView
├─ MallInfoCard
├─ SizedBox(height: 16)
│
├─ VehicleSelector
├─ SizedBox(height: 16)
│
├─ NEW: Floor & Slot Reservation Section
│   ├─ Text ("Pilih Lokasi Parkir", 18px bold)
│   ├─ SizedBox(height: 12)
│   ├─ FloorSelectorWidget
│   ├─ SizedBox(height: 16)
│   ├─ IF floor selected:
│   │   ├─ SlotVisualizationWidget (NON-INTERACTIVE)
│   │   ├─ SizedBox(height: 16)
│   │   ├─ SlotReservationButton
│   │   └─ IF slot reserved:
│   │       └─ ReservedSlotInfoCard
├─ SizedBox(height: 16)
│
├─ UPDATED: UnifiedTimeDurationCard
│   (Replaces TimeDurationPicker)
├─ SizedBox(height: 16)
│
├─ SlotAvailabilityIndicator
├─ SizedBox(height: 16)
│
├─ CostBreakdownCard
├─ SizedBox(height: 16)
│
└─ BookingSummaryCard (updated with slot info)

Fixed Bottom Button
└─ "Konfirmasi Booking"
```

### Validation Flow

```dart
bool get canConfirmBooking {
  return _selectedMall != null &&
      _selectedVehicle != null &&
      _reservedSlot != null &&        // NEW: Reserved slot required
      !_reservedSlot!.isExpired &&    // NEW: Check expiration
      _startTime != null &&
      _bookingDuration != null &&
      _availableSlots > 0 &&
      !hasValidationErrors &&
      !_isLoading;
}
```



## Performance Optimizations

### 1. Lazy Loading for Slot Visualization
```dart
// Load slots only when floor is selected
void selectFloor(ParkingFloorModel floor) {
  _selectedFloor = floor;
  _reservedSlot = null;
  _slotsVisualization = [];
  notifyListeners();
  
  // Fetch slots for visualization asynchronously
  fetchSlotsForVisualization(floor.idFloor, _authToken);
}
```

### 2. Caching Strategy
```dart
// Cache floor data for 5 minutes
static final Map<String, List<ParkingFloorModel>> _floorCache = {};
static final Map<String, DateTime> _floorCacheTimestamp = {};

Future<void> fetchFloors(String mallId, String token) async {
  // Check cache first
  final cached = _getCachedFloors(mallId);
  if (cached != null) {
    _floors = cached;
    notifyListeners();
    return;
  }
  
  // Fetch from API
  final floors = await _bookingService.getFloors(mallId, token);
  _cacheFloors(mallId, floors);
  _floors = floors;
  notifyListeners();
}
```

### 3. Debounced Slot Refresh
```dart
Timer? _slotRefreshDebounce;

void refreshSlotVisualization(String token) {
  _slotRefreshDebounce?.cancel();
  _slotRefreshDebounce = Timer(
    const Duration(milliseconds: 500),
    () => fetchSlotsForVisualization(_selectedFloor!.idFloor, token),
  );
}
```

### 4. Reservation Timeout Management
```dart
void startReservationTimer() {
  _reservationTimer?.cancel();
  if (_reservedSlot != null) {
    final timeRemaining = _reservedSlot!.timeRemaining;
    _reservationTimer = Timer(timeRemaining, () {
      // Auto-clear expired reservation
      clearReservation();
      _showErrorSnackbar('Waktu reservasi habis. Silakan reservasi ulang.');
    });
  }
}
```





## Accessibility Implementation

### Screen Reader Support

```dart
// Floor card
Semantics(
  label: 'Lantai ${floor.floorNumber}, ${floor.floorName}',
  hint: '${floor.availableSlots} slot tersedia. Ketuk untuk melihat slot.',
  button: true,
  enabled: floor.hasAvailableSlots,
  child: FloorCard(...),
)

// Slot visualization (non-interactive)
Semantics(
  label: 'Visualisasi ketersediaan slot lantai ${floor.floorName}',
  hint: '${floor.availableSlots} slot tersedia dari ${floor.totalSlots} total slot',
  readOnly: true,
  child: SlotVisualizationWidget(...),
)

// Reservation button
Semantics(
  label: 'Pesan slot acak di ${floor.floorName}',
  hint: 'Ketuk untuk mereservasi slot secara otomatis di lantai ini',
  button: true,
  enabled: floor.hasAvailableSlots && !_isReservingSlot,
  child: SlotReservationButton(...),
)

// Reserved slot info
Semantics(
  label: 'Slot ${reservation.slotCode} berhasil direservasi',
  hint: 'Slot ${reservation.displayName}, ${reservation.typeLabel}',
  readOnly: true,
  child: ReservedSlotInfoCard(...),
)

// Duration chip
Semantics(
  label: 'Durasi ${duration.inHours} jam',
  hint: 'Ketuk untuk memilih durasi ${duration.inHours} jam',
  button: true,
  selected: duration == _selectedDuration,
  child: DurationChip(...),
)
```

### Keyboard Navigation

```dart
// Slot grid keyboard support
Focus(
  onKey: (node, event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _moveSelection(Direction.right);
        return KeyEventResult.handled;
      }
      // Handle other arrow keys...
    }
    return KeyEventResult.ignored;
  },
  child: SlotGrid(...),
)
```

### Focus Indicators

```dart
// Purple focus border for all interactive elements
Container(
  decoration: BoxDecoration(
    border: _isFocused
        ? Border.all(color: Color(0xFF573ED1), width: 2)
        : null,
    borderRadius: BorderRadius.circular(12),
  ),
  child: ...,
)
```



## Error Handling

### Slot Reservation Errors

```dart
// Floor loading error
if (error is NetworkException) {
  _showErrorSnackbar(
    'Gagal memuat data lantai. Periksa koneksi internet Anda.',
    action: SnackBarAction(
      label: 'Coba Lagi',
      onPressed: () => fetchFloors(mallId, token),
    ),
  );
}

// No slots available for reservation
Future<bool> reserveRandomSlot(String floorId, String token) async {
  try {
    _isReservingSlot = true;
    notifyListeners();
    
    final reservation = await _bookingService.reserveRandomSlot(floorId, token);
    
    if (reservation != null) {
      _reservedSlot = reservation;
      startReservationTimer();
      notifyListeners();
      return true;
    } else {
      _showErrorSnackbar(
        'Tidak ada slot tersedia di lantai ini. Silakan pilih lantai lain.',
        backgroundColor: Colors.orange,
      );
      return false;
    }
  } catch (error) {
    if (error.toString().contains('NO_SLOTS_AVAILABLE')) {
      _showErrorDialog(
        title: 'Slot Tidak Tersedia',
        message: 'Semua slot di lantai ini sudah terisi. Silakan pilih lantai lain atau coba lagi nanti.',
        actions: [
          TextButton(
            child: Text('Pilih Lantai Lain'),
            onPressed: () {
              Navigator.pop(context);
              clearReservation();
              // Scroll back to floor selection
            },
          ),
        ],
      );
    }
    return false;
  } finally {
    _isReservingSlot = false;
    notifyListeners();
  }
}

// Reservation timeout
void _handleReservationTimeout() {
  _showErrorDialog(
    title: 'Waktu Reservasi Habis',
    message: 'Reservasi slot Anda telah berakhir. Silakan lakukan reservasi ulang.',
    actions: [
      TextButton(
        child: Text('Reservasi Ulang'),
        onPressed: () {
          Navigator.pop(context);
          if (_selectedFloor != null) {
            reserveRandomSlot(_selectedFloor!.idFloor, _authToken);
          }
        },
      ),
    ],
  );
}
```

### Time Selection Errors

```dart
// Past time validation
if (selectedTime.isBefore(DateTime.now())) {
  setState(() {
    _timeError = 'Waktu tidak boleh di masa lalu';
  });
  return;
}

// Too far in future
if (selectedTime.isAfter(DateTime.now().add(Duration(days: 7)))) {
  setState(() {
    _timeError = 'Booking maksimal 7 hari ke depan';
  });
  return;
}
```



## Testing Strategy

### Unit Tests

```dart
// test/models/parking_floor_model_test.dart
test('ParkingFloorModel.fromJson creates valid model', () {
  final json = {
    'id_floor': 'f1',
    'floor_number': 1,
    'available_slots': 10,
    // ...
  };
  final floor = ParkingFloorModel.fromJson(json);
  expect(floor.idFloor, 'f1');
  expect(floor.hasAvailableSlots, true);
});

// test/providers/booking_provider_reservation_test.dart
test('reserveRandomSlot updates state correctly', () async {
  final provider = BookingProvider();
  final floor = ParkingFloorModel(/* ... */);
  
  provider.selectFloor(floor);
  
  final success = await provider.reserveRandomSlot(floor.idFloor, 'token');
  
  expect(success, true);
  expect(provider.reservedSlot, isNotNull);
  expect(provider.hasReservedSlot, true);
});

test('reservation expires correctly', () async {
  final provider = BookingProvider();
  final expiredReservation = SlotReservationModel(
    expiresAt: DateTime.now().subtract(Duration(minutes: 1)),
    // ...
  );
  
  provider._reservedSlot = expiredReservation;
  
  expect(provider.hasReservedSlot, false);
});
```

### Widget Tests

```dart
// test/widgets/floor_selector_widget_test.dart
testWidgets('FloorSelectorWidget displays floors', (tester) async {
  final floors = [
    ParkingFloorModel(/* floor 1 */),
    ParkingFloorModel(/* floor 2 */),
  ];
  
  await tester.pumpWidget(
    MaterialApp(
      home: FloorSelectorWidget(
        floors: floors,
        onFloorSelected: (_) {},
      ),
    ),
  );
  
  expect(find.text('Lantai 1'), findsOneWidget);
  expect(find.text('Lantai 2'), findsOneWidget);
});

// test/widgets/unified_time_duration_card_test.dart
testWidgets('UnifiedTimeDurationCard displays time and duration', (tester) async {
  final startTime = DateTime(2025, 1, 15, 14, 30);
  final duration = Duration(hours: 2);
  
  await tester.pumpWidget(
    MaterialApp(
      home: UnifiedTimeDurationCard(
        startTime: startTime,
        duration: duration,
        onTimeChanged: (_) {},
        onDurationChanged: (_) {},
      ),
    ),
  );
  
  expect(find.text('14:30'), findsOneWidget);
  expect(find.text('2 Jam'), findsOneWidget);
  expect(find.textContaining('16:30'), findsOneWidget); // End time
});
```

### Integration Tests

```dart
// test/integration/booking_slot_reservation_test.dart
testWidgets('Complete slot reservation flow', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Navigate to booking page
  await tester.tap(find.text('Booking Sekarang'));
  await tester.pumpAndSettle();
  
  // Select floor
  await tester.tap(find.text('Lantai 1'));
  await tester.pumpAndSettle();
  
  // Wait for slot visualization to load
  await tester.pump(Duration(seconds: 2));
  
  // Tap reservation button
  await tester.tap(find.text('Pesan Slot Acak di Lantai 1'));
  await tester.pumpAndSettle();
  
  // Verify reservation success
  expect(find.text('Slot Berhasil Direservasi'), findsOneWidget);
  expect(find.textContaining('Lantai 1 - Slot'), findsOneWidget);
  
  // Continue with booking...
});
```



## Migration Strategy

### Phase 1: Add Slot Reservation (Optional)

1. Add new database columns (nullable):
   - `booking.id_slot` (nullable foreign key)
   - `booking.reservation_id` (nullable)
   - `transaksi_parkir.id_slot` (nullable foreign key)

2. Implement slot reservation UI as optional feature
3. Backend supports both booking modes:
   - With slot reservation: Reserve specific slot via random assignment
   - Without slot reservation: Auto-assign available slot

4. Feature flag per mall:
   ```dart
   if (mall.hasSlotReservationEnabled) {
     // Show slot reservation UI
   } else {
     // Use automatic slot assignment
   }
   ```

### Phase 2: Unified Time/Duration Card

1. Create UnifiedTimeDurationCard widget
2. Add feature flag to toggle between old and new UI
3. Test with subset of users
4. Gradually roll out to all users
5. Deprecate old TimeDurationPicker

### Phase 3: Full Rollout

1. Enable slot reservation for all malls
2. Make slot reservation mandatory
3. Update database constraints (make id_slot NOT NULL)
4. Remove old TimeDurationPicker code
5. Update documentation

### Backward Compatibility

```dart
// Support old booking format without slot reservation
class BookingRequest {
  final String? idSlot; // Nullable for backward compatibility
  final String? reservationId; // Nullable for backward compatibility
  
  Map<String, dynamic> toJson() {
    final json = {
      'id_mall': idMall,
      'id_kendaraan': idKendaraan,
      // ...
    };
    
    // Only include slot if reserved
    if (idSlot != null) {
      json['id_slot'] = idSlot;
    }
    if (reservationId != null) {
      json['reservation_id'] = reservationId;
    }
    
    return json;
  }
}
```

