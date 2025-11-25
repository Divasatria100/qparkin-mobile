# Design Document

## Overview

The Booking Page is a critical feature in the QPARKIN mobile application that enables drivers to reserve parking slots at selected malls before arrival. This design document outlines the architecture, components, data flow, and UI/UX specifications for implementing a seamless booking experience that integrates with the existing map selection, activity tracking, and parking history systems.

### Design Goals

1. **User-Friendly Experience**: Provide an intuitive, step-by-step booking flow with clear visual feedback
2. **Real-Time Availability**: Display accurate slot availability with automatic updates
3. **Cost Transparency**: Show clear cost breakdown and estimates before confirmation
4. **Seamless Integration**: Connect smoothly with Map Page, Activity Page, and History
5. **Performance**: Load quickly and respond instantly to user interactions
6. **Consistency**: Follow existing design system with purple accent, card-based layouts, and subtle shadows
7. **Accessibility**: Ensure all users can complete bookings regardless of abilities

## Architecture

### Component Structure

```
lib/
├── presentation/
│   ├── screens/
│   │   └── booking_page.dart                 # Main booking page
│   ├── widgets/
│   │   ├── mall_info_card.dart              # Mall details display
│   │   ├── vehicle_selector.dart            # Vehicle selection dropdown
│   │   ├── time_duration_picker.dart        # Time and duration selection
│   │   ├── slot_availability_indicator.dart # Real-time slot status
│   │   ├── cost_breakdown_card.dart         # Pricing details
│   │   ├── booking_summary_card.dart        # Final review before confirm
│   │   └── booking_confirmation_dialog.dart # Success dialog with QR
│   └── dialogs/
│       └── booking_error_dialog.dart        # Error handling dialogs
├── logic/
│   └── providers/
│       └── booking_provider.dart            # State management
├── data/
│   ├── models/
│   │   ├── booking_model.dart              # Booking data structure
│   │   ├── booking_request.dart            # API request model
│   │   └── booking_response.dart           # API response model
│   └── services/
│       └── booking_service.dart            # API communication
└── utils/
    ├── booking_validator.dart              # Input validation
    └── cost_calculator.dart                # Cost estimation logic
```



### Data Flow

```
1. Navigation Flow:
   MapPage (mall selected) 
   → Navigator.push with mall data 
   → BookingPage initialized
   → BookingProvider.initialize(mallData)

2. Booking Creation Flow:
   User fills form 
   → BookingProvider validates inputs
   → BookingService.createBooking(request)
   → API creates transaksi_parkir + booking records
   → Generate QR code
   → Update Activity Page
   → Show confirmation dialog
   → Navigate to Activity Page or Home

3. Real-Time Updates:
   Timer.periodic(30s)
   → BookingService.checkSlotAvailability()
   → Update slot count
   → Notify listeners
   → UI updates automatically

4. Cost Calculation:
   Duration changes
   → CostCalculator.estimate(duration, tariff)
   → Update cost display
   → Show breakdown
```

### State Management

Using Provider pattern with ChangeNotifier:

```dart
class BookingProvider extends ChangeNotifier {
  // State
  MallModel? selectedMall;
  VehicleModel? selectedVehicle;
  DateTime? startTime;
  Duration? bookingDuration;
  int availableSlots = 0;
  double estimatedCost = 0.0;
  bool isLoading = false;
  String? errorMessage;
  
  // Methods
  Future<void> initialize(MallModel mall);
  Future<void> fetchVehicles();
  void selectVehicle(VehicleModel vehicle);
  void setStartTime(DateTime time);
  void setDuration(Duration duration);
  Future<void> checkAvailability();
  Future<BookingResponse> confirmBooking();
  void calculateCost();
}
```



## Components and Interfaces

### 1. BookingPage (Main Screen)

**Purpose**: Main container for booking flow with scrollable content and fixed bottom button

**Key Features**:
- AppBar with back button and "Booking Parkir" title
- ScrollView for content (mall info, vehicle, time, cost)
- Fixed bottom button for confirmation
- Loading overlay during API calls
- Error handling with Snackbar

**Layout Structure**:
```
AppBar (purple, white text)
└─ Back button + "Booking Parkir" title

ScrollView
├─ MallInfoCard (mall details, distance, slots)
├─ SizedBox(height: 16)
├─ VehicleSelector (dropdown with vehicle list)
├─ SizedBox(height: 16)
├─ TimeDurationPicker (date/time + duration)
├─ SizedBox(height: 16)
├─ SlotAvailabilityIndicator (real-time status)
├─ SizedBox(height: 16)
├─ CostBreakdownCard (pricing details)
├─ SizedBox(height: 16)
└─ BookingSummaryCard (final review)

Fixed Bottom Button
└─ "Konfirmasi Booking" (purple gradient, 56dp height)
```

### 2. MallInfoCard Widget

**Purpose**: Display selected mall information with visual hierarchy

**Design Specs**:
- White background, 16px rounded corners
- Elevation 2, shadow blur 8px, offset (0,2)
- 16px padding all sides
- Purple accent for icons

**Content**:
```
Row
├─ Icon(local_parking, purple, 24px)
├─ SizedBox(width: 12)
└─ Column
    ├─ Text(mall name, 18px bold, black87)
    ├─ SizedBox(height: 4)
    ├─ Row(location icon + address, 14px, grey600)
    ├─ SizedBox(height: 4)
    └─ Row(distance icon + distance, 14px, grey600)

Divider (grey200, 1px)

Row (Available Slots)
├─ Icon(check_circle, green, 16px)
├─ SizedBox(width: 8)
└─ Text("X slot tersedia", 14px, green700)
```



### 3. VehicleSelector Widget

**Purpose**: Dropdown to select registered vehicle with visual preview

**Design Specs**:
- White background card, 16px rounded corners
- Elevation 2, 16px padding
- Purple border when focused
- Dropdown shows vehicle cards with icons

**Content**:
```
Card
├─ Text("Pilih Kendaraan", 16px bold, black87)
├─ SizedBox(height: 12)
└─ DropdownButton
    ├─ Selected: Row(vehicle icon + plat + jenis)
    └─ Items: List of vehicle cards
        └─ Each: Row
            ├─ Icon(vehicle type, purple, 20px)
            ├─ SizedBox(width: 12)
            └─ Column
                ├─ Text(plat nomor, 16px bold)
                └─ Text(merk + tipe, 14px grey600)
```

**Empty State**:
```
Card with dashed border
├─ Icon(add_circle, purple, 32px)
├─ SizedBox(height: 8)
├─ Text("Belum ada kendaraan", 16px bold)
├─ SizedBox(height: 4)
├─ Text("Tambahkan kendaraan terlebih dahulu", 14px grey600)
└─ TextButton("Tambah Kendaraan", purple)
```

### 4. TimeDurationPicker Widget

**Purpose**: Select booking start time and duration with visual feedback

**Design Specs**:
- Two-column layout for time and duration
- White background cards, 16px rounded corners
- Purple accent for selected values
- Date/time picker modal on tap

**Content**:
```
Row (two equal columns)
├─ Expanded (Start Time Card)
│   └─ Card
│       ├─ Icon(schedule, purple, 20px)
│       ├─ Text("Waktu Mulai", 14px grey600)
│       ├─ Text(formatted time, 18px bold, black87)
│       └─ Text(formatted date, 14px grey600)
│
└─ Expanded (Duration Card)
    └─ Card
        ├─ Icon(timer, orange, 20px)
        ├─ Text("Durasi", 14px grey600)
        ├─ Text(duration, 18px bold, black87)
        └─ Chips(1h, 2h, 3h, 4h, Custom)

Calculated End Time Display
└─ Container(purple light background, 12px padding)
    └─ Row
        ├─ Icon(event_available, purple, 16px)
        └─ Text("Selesai: [end time]", 14px purple)
```



### 5. SlotAvailabilityIndicator Widget

**Purpose**: Real-time display of parking slot availability with visual status

**Design Specs**:
- Horizontal card with icon and text
- Color-coded status (green/yellow/red)
- Auto-refresh every 30 seconds
- Shimmer loading during refresh

**Content**:
```
Card (white background, 16px rounded)
└─ Row
    ├─ Container (status color background, 48px circle)
    │   └─ Icon(local_parking, white, 24px)
    ├─ SizedBox(width: 16)
    ├─ Column
    │   ├─ Text("Ketersediaan Slot", 14px grey600)
    │   ├─ Text("[X] slot tersedia", 18px bold, status color)
    │   └─ Text("Untuk [vehicle type]", 12px grey500)
    └─ Icon(refresh, grey400, 20px) [tap to refresh]

Status Colors:
- Green (0xFF4CAF50): > 10 slots available
- Yellow (0xFFFF9800): 3-10 slots available
- Red (0xFFF44336): < 3 slots or full
```

### 6. CostBreakdownCard Widget

**Purpose**: Display transparent pricing with breakdown and total

**Design Specs**:
- White background card, 16px rounded corners
- Purple accent for total cost
- Clear visual hierarchy
- Animated number changes

**Content**:
```
Card
├─ Text("Estimasi Biaya", 16px bold, black87)
├─ SizedBox(height: 12)
├─ Divider
├─ Row (Breakdown Item)
│   ├─ Text("Jam pertama", 14px grey600)
│   └─ Text("Rp X.XXX", 14px black87)
├─ Row (Breakdown Item)
│   ├─ Text("X jam berikutnya", 14px grey600)
│   └─ Text("Rp X.XXX", 14px black87)
├─ Divider
├─ Row (Total)
│   ├─ Text("Total Estimasi", 16px bold, black87)
│   └─ Text("Rp X.XXX", 20px bold, purple)
└─ Container (info box, light blue background)
    └─ Row
        ├─ Icon(info, blue, 16px)
        └─ Text("Biaya final dihitung saat keluar", 12px blue)
```



### 7. BookingSummaryCard Widget

**Purpose**: Final review of all booking details before confirmation

**Design Specs**:
- Prominent card with purple border (2px)
- White background, 16px rounded corners
- Elevation 4 for emphasis
- Organized in sections with dividers

**Content**:
```
Card (purple border)
├─ Text("Ringkasan Booking", 18px bold, black87)
├─ SizedBox(height: 16)
│
├─ Section: Lokasi
│   ├─ Icon + Text(mall name, 14px bold)
│   └─ Text(address, 12px grey600)
├─ Divider
│
├─ Section: Kendaraan
│   ├─ Icon + Text(plat nomor, 14px bold)
│   └─ Text(jenis + merk, 12px grey600)
├─ Divider
│
├─ Section: Waktu
│   ├─ Row
│   │   ├─ Icon(schedule) + Text("Mulai", 12px grey600)
│   │   └─ Text(start time, 14px bold)
│   ├─ Row
│   │   ├─ Icon(timer) + Text("Durasi", 12px grey600)
│   │   └─ Text(duration, 14px bold)
│   └─ Row
│       ├─ Icon(event_available) + Text("Selesai", 12px grey600)
│       └─ Text(end time, 14px bold)
├─ Divider
│
└─ Section: Biaya
    └─ Row
        ├─ Text("Total Estimasi", 16px bold)
        └─ Text("Rp X.XXX", 18px bold, purple)
```

### 8. BookingConfirmationDialog Widget

**Purpose**: Success feedback with QR code and next actions

**Design Specs**:
- Full-screen dialog with white background
- Success animation (checkmark with scale/fade)
- QR code display (200x200px)
- Action buttons at bottom

**Content**:
```
Dialog (full screen)
├─ AppBar (transparent, close button)
├─ Column (centered)
│   ├─ Lottie Animation (success checkmark, 120px)
│   ├─ Text("Booking Berhasil!", 24px bold, green)
│   ├─ Text("ID: [booking_id]", 14px grey600)
│   ├─ SizedBox(height: 24)
│   │
│   ├─ Card (QR Code Container)
│   │   ├─ Text("QR Code Masuk", 16px bold)
│   │   ├─ QrImage(qrCode, 200x200)
│   │   └─ Text("Tunjukkan di gerbang masuk", 12px grey600)
│   ├─ SizedBox(height: 24)
│   │
│   ├─ BookingSummaryCard (compact version)
│   └─ SizedBox(height: 24)
│
└─ Column (bottom buttons)
    ├─ ElevatedButton("Lihat Aktivitas", purple, full width)
    └─ TextButton("Kembali ke Beranda", grey)
```



## Data Models

### BookingModel

```dart
class BookingModel {
  final String idTransaksi;
  final String idBooking;
  final String idMall;
  final String idParkiran;
  final String idKendaraan;
  final String qrCode;
  final DateTime waktuMulai;
  final DateTime waktuSelesai;
  final int durasiBooking; // in hours
  final String status; // 'aktif', 'selesai', 'expired'
  final double biayaEstimasi;
  final DateTime dibookingPada;
  
  // Computed properties
  String get formattedDuration;
  String get formattedCost;
  bool get isActive;
  bool get isExpired;
}
```

### BookingRequest

```dart
class BookingRequest {
  final String idMall;
  final String idKendaraan;
  final DateTime waktuMulai;
  final int durasiJam;
  final String? notes;
  
  Map<String, dynamic> toJson();
}
```

### BookingResponse

```dart
class BookingResponse {
  final bool success;
  final String message;
  final BookingModel? booking;
  final String? qrCode;
  final String? errorCode;
  
  factory BookingResponse.fromJson(Map<String, dynamic> json);
}
```

## Error Handling

### Error Types and Messages

| Error Type | User Message | Action |
|------------|--------------|--------|
| NetworkError | "Koneksi internet bermasalah. Periksa koneksi Anda." | Retry button |
| SlotUnavailable | "Slot tidak tersedia untuk waktu yang dipilih." | Suggest alternative times |
| ValidationError | "Mohon lengkapi semua data dengan benar." | Highlight invalid fields |
| ServerError | "Terjadi kesalahan server. Coba lagi nanti." | Contact support option |
| TimeoutError | "Permintaan timeout. Silakan coba lagi." | Retry button |
| BookingConflict | "Anda sudah memiliki booking aktif." | View existing booking |

### Error Display Strategy

1. **Inline Validation**: Show errors below input fields with red text and icon
2. **Snackbar**: Use for temporary errors (network, timeout) with action button
3. **Dialog**: Use for critical errors (booking conflict, server error) with detailed message
4. **Toast**: Use for minor warnings (slot count changed, price updated)



## Testing Strategy

### Unit Tests

1. **BookingProvider Tests**
   - Test state initialization with mall data
   - Test vehicle selection and validation
   - Test time/duration selection and validation
   - Test cost calculation accuracy
   - Test booking creation success/failure scenarios
   - Test error handling and recovery

2. **CostCalculator Tests**
   - Test first hour rate calculation
   - Test additional hours calculation
   - Test edge cases (0 hours, 12+ hours)
   - Test different vehicle types
   - Test tariff changes

3. **BookingValidator Tests**
   - Test start time validation (past, future, range)
   - Test duration validation (min, max, custom)
   - Test vehicle selection validation
   - Test slot availability validation

### Widget Tests

1. **BookingPage Tests**
   - Test initial render with mall data
   - Test form field interactions
   - Test button enable/disable states
   - Test loading states
   - Test error states

2. **Component Widget Tests**
   - Test MallInfoCard displays correct data
   - Test VehicleSelector dropdown behavior
   - Test TimeDurationPicker interactions
   - Test CostBreakdownCard calculations
   - Test BookingSummaryCard data display

### Integration Tests

1. **End-to-End Booking Flow**
   - Navigate from Map to Booking
   - Select vehicle
   - Choose time and duration
   - Verify cost calculation
   - Confirm booking
   - Verify success dialog
   - Navigate to Activity Page
   - Verify booking appears in Activity

2. **Error Scenarios**
   - Test network failure handling
   - Test slot unavailability handling
   - Test validation error display
   - Test booking conflict handling

## Performance Optimizations

### 1. Lazy Loading
- Load vehicle list only when dropdown is opened
- Defer QR code generation until booking confirmed
- Use pagination for large vehicle lists

### 2. Caching
- Cache mall data from Map Page navigation
- Cache vehicle list for session duration
- Cache tariff data to reduce API calls

### 3. Debouncing
- Debounce duration changes (300ms) before recalculating cost
- Debounce slot availability checks (500ms) after time changes

### 4. Optimistic UI Updates
- Update cost display immediately (optimistic)
- Show loading indicator only for API calls
- Use shimmer placeholders for async data

### 5. Memory Management
- Dispose timers in dispose() method
- Cancel pending API calls on page exit
- Clear large objects (QR images) when not needed



## Integration Points

### 1. Map Page Integration

**Navigation**:
```dart
// In MapPage._navigateToBooking()
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BookingPage(
      mall: _selectedMall,
    ),
  ),
);
```

**Data Passed**:
- Mall ID, name, address, distance
- Available slot count
- Mall coordinates (for map display)

### 2. Activity Page Integration

**After Booking Creation**:
```dart
// Trigger Activity Page refresh
Provider.of<ActiveParkingProvider>(context, listen: false)
  .fetchActiveParking();

// Navigate to Activity Page
Navigator.pushReplacementNamed(
  context,
  '/activity',
  arguments: {'initialTab': 0}, // Show Aktivitas tab
);
```

**Data Sync**:
- New booking appears in Activity Page immediately
- Timer starts automatically
- QR code available for gate entry

### 3. History Integration

**After Booking Completion**:
- Booking record added to history automatically
- Status updated from 'aktif' to 'selesai'
- Final cost calculated and recorded
- History page shows completed booking

### 4. Backend API Integration

**Endpoints**:

1. **POST /api/booking/create**
   - Request: BookingRequest JSON
   - Response: BookingResponse with QR code
   - Creates transaksi_parkir and booking records
   - Allocates parking slot

2. **GET /api/booking/check-availability**
   - Query params: mall_id, vehicle_type, start_time, duration
   - Response: Available slot count
   - Real-time availability check

3. **GET /api/vehicles**
   - Query params: user_id (from auth token)
   - Response: List of registered vehicles
   - Cached for session

4. **GET /api/tariff**
   - Query params: mall_id, vehicle_type
   - Response: Tariff structure
   - Cached for session

## Accessibility Features

### Screen Reader Support
- Semantic labels for all interactive elements
- Proper focus order (top to bottom, left to right)
- Announce state changes (slot availability, cost updates)
- Describe icons with meaningful labels

### Visual Accessibility
- Minimum 4.5:1 contrast ratio for all text
- Color is not the only indicator (use icons + text)
- Support font scaling up to 200%
- Clear visual focus indicators

### Motor Accessibility
- Minimum 48dp touch targets for all buttons
- Adequate spacing between interactive elements (8dp minimum)
- Support for alternative input methods
- No time-based interactions required

### Cognitive Accessibility
- Clear, simple language in all messages
- Consistent layout and navigation patterns
- Progress indicators for multi-step processes
- Confirmation dialogs for important actions



## UI/UX Specifications

### Color Palette

```dart
// Primary Colors
const primaryPurple = Color(0xFF573ED1);
const purpleGradientStart = Color(0xFF573ED1);
const purpleGradientEnd = Color(0xFF6B4FE0);
const purpleLight = Color(0xFFE8E0FF);

// Status Colors
const successGreen = Color(0xFF4CAF50);
const warningYellow = Color(0xFFFF9800);
const errorRed = Color(0xFFF44336);
const infoBlue = Color(0xFF2196F3);

// Neutral Colors
const backgroundWhite = Color(0xFFFFFFFF);
const backgroundGrey = Colors.grey.shade50;
const textBlack = Colors.black87;
const textGrey = Colors.grey.shade600;
const borderGrey = Colors.grey.shade200;
```

### Typography

```dart
// Headers
const headerLarge = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: textBlack,
);

const headerMedium = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
  color: textBlack,
);

const headerSmall = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: textBlack,
);

// Body Text
const bodyLarge = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.normal,
  color: textBlack,
);

const bodyMedium = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.normal,
  color: textGrey,
);

// Captions
const caption = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.normal,
  color: textGrey,
);

// Emphasis
const emphasis = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: primaryPurple,
);
```

### Spacing System

```dart
// Padding
const paddingXS = 4.0;
const paddingS = 8.0;
const paddingM = 12.0;
const paddingL = 16.0;
const paddingXL = 24.0;
const paddingXXL = 32.0;

// Margins
const marginXS = 4.0;
const marginS = 8.0;
const marginM = 12.0;
const marginL = 16.0;
const marginXL = 24.0;

// Border Radius
const radiusS = 8.0;
const radiusM = 12.0;
const radiusL = 16.0;
const radiusXL = 24.0;
```

### Elevation & Shadows

```dart
// Card Shadows
const shadowLight = BoxShadow(
  color: Colors.black12,
  blurRadius: 8,
  offset: Offset(0, 2),
);

const shadowMedium = BoxShadow(
  color: Colors.black26,
  blurRadius: 12,
  offset: Offset(0, 4),
);

const shadowHeavy = BoxShadow(
  color: Colors.black38,
  blurRadius: 16,
  offset: Offset(0, 6),
);

// Button Shadow
const buttonShadow = BoxShadow(
  color: Color(0x40573ED1), // Purple with 25% opacity
  blurRadius: 12,
  offset: Offset(0, 4),
);
```

### Animation Specifications

```dart
// Durations
const durationFast = Duration(milliseconds: 200);
const durationMedium = Duration(milliseconds: 300);
const durationSlow = Duration(milliseconds: 500);

// Curves
const curveStandard = Curves.easeInOut;
const curveEmphasized = Curves.easeOutBack;
const curveDecelerate = Curves.easeOut;

// Animations
- Page transitions: 300ms with easeInOut
- Button press: 200ms scale to 0.95
- Card hover: 200ms elevation change
- Success checkmark: 500ms with easeOutBack
- Shimmer loading: 1500ms linear loop
- Cost number change: 300ms with easeInOut
```

## Responsive Design

### Breakpoints

```dart
// Screen sizes
const mobileSmall = 320.0;  // iPhone SE
const mobileMedium = 375.0; // iPhone 12
const mobileLarge = 414.0;  // iPhone 12 Pro Max
const tablet = 768.0;       // iPad

// Responsive padding
double getResponsivePadding(double screenWidth) {
  if (screenWidth < mobileMedium) return 12.0;
  if (screenWidth < mobileLarge) return 16.0;
  if (screenWidth < tablet) return 20.0;
  return 24.0;
}

// Responsive font size
double getResponsiveFontSize(double baseSize, double screenWidth) {
  if (screenWidth < mobileMedium) return baseSize * 0.9;
  if (screenWidth < mobileLarge) return baseSize;
  return baseSize * 1.1;
}
```

### Layout Adaptations

**Small Screens (< 375px)**:
- Single column layout
- Reduced padding (12px)
- Smaller font sizes (90% of base)
- Compact card spacing

**Medium Screens (375-414px)**:
- Standard layout
- Normal padding (16px)
- Base font sizes
- Standard card spacing

**Large Screens (> 414px)**:
- Wider content area
- Increased padding (20-24px)
- Slightly larger fonts (110% of base)
- More generous spacing

