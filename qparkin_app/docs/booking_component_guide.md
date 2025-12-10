# Booking Feature Component Usage Guide

## Overview
This guide provides detailed documentation on how to use all components in the Booking feature, including widgets, providers, services, and utilities.

---

## Table of Contents
1. [Providers](#providers)
2. [Services](#services)
3. [Widgets](#widgets)
4. [Utilities](#utilities)
5. [Models](#models)
6. [Usage Examples](#usage-examples)

---

## Providers

### BookingProvider

State management provider for the booking feature.

**Location:** `lib/logic/providers/booking_provider.dart`

**Purpose:** Manages booking form state, validation, cost calculation, slot availability checking, and booking creation.

**Constructor:**
```dart
BookingProvider({BookingService? bookingService})
```

**Key Properties:**
```dart
// Mall and vehicle selection
Map<String, dynamic>? selectedMall
Map<String, dynamic>? selectedVehicle

// Time and duration
DateTime? startTime
Duration? bookingDuration
DateTime? calculatedEndTime

// Cost information
double estimatedCost
Map<String, dynamic>? costBreakdown

// Slot availability
int availableSlots
DateTime? lastAvailabilityCheck

// State flags
bool isLoading
bool isCheckingAvailability
String? errorMessage
Map<String, String> validationErrors

// Booking result
BookingModel? createdBooking
```

**Key Methods:**
```dart
// Initialize with mall data
void initialize(Map<String, dynamic> mallData)

// Select vehicle
void selectVehicle(Map<String, dynamic> vehicle)

// Set booking time
void setStartTime(DateTime time, {String? token})

// Set booking duration
void setDuration(Duration duration, {String? token})

// Calculate estimated cost
void calculateCost()

// Check slot availability
Future<void> checkAvailability({required String token})

// Start/stop periodic availability checks
void startPeriodicAvailabilityCheck({required String token})
void stopPeriodicAvailabilityCheck()

// Confirm booking
Future<bool> confirmBooking({
  required String token,
  Function(BookingModel)? onSuccess,
  bool skipActiveCheck = false,
})

// Clear state
void clear()
```

**Usage Example:**
```dart
// In your widget
final bookingProvider = Provider.of<BookingProvider>(context);

// Initialize with mall data
bookingProvider.initialize(mallData);

// Select vehicle
bookingProvider.selectVehicle(vehicleData);

// Set time and duration
bookingProvider.setStartTime(
  DateTime.now().add(Duration(hours: 1)),
  token: authToken,
);
bookingProvider.setDuration(
  Duration(hours: 2),
  token: authToken,
);

// Start periodic availability checks
bookingProvider.startPeriodicAvailabilityCheck(token: authToken);

// Confirm booking
final success = await bookingProvider.confirmBooking(
  token: authToken,
  onSuccess: (booking) {
    // Navigate to confirmation dialog
    showDialog(
      context: context,
      builder: (context) => BookingConfirmationDialog(
        booking: booking,
        onViewActivity: () => Navigator.pushNamed(context, '/activity'),
        onBackToHome: () => Navigator.pushNamed(context, '/home'),
      ),
    );
  },
);
```

---

## Services

### BookingService

Handles all API communication for booking operations.

**Location:** `lib/data/services/booking_service.dart`

**Constructor:**
```dart
BookingService({
  String? baseUrl,
  http.Client? client,
})
```

**Key Methods:**
```dart
// Create booking
Future<BookingResponse> createBooking({
  required BookingRequest request,
  required String token,
})

// Create booking with retry logic
Future<BookingResponse> createBookingWithRetry({
  required BookingRequest request,
  required String token,
  int maxRetries = 3,
})

// Check slot availability
Future<int> checkSlotAvailability({
  required String mallId,
  required String vehicleType,
  required DateTime startTime,
  required int durationHours,
  required String token,
})

// Check slot availability with retry
Future<int> checkSlotAvailabilityWithRetry({
  required String mallId,
  required String vehicleType,
  required DateTime startTime,
  required int durationHours,
  required String token,
  int maxRetries = 2,
})

// Check if user has active booking
Future<bool> checkActiveBooking({required String token})

// Cancel pending requests
void cancelPendingRequests()
```

**Usage Example:**
```dart
final bookingService = BookingService();

// Create booking
final request = BookingRequest(
  idMall: 'MALL001',
  idKendaraan: 'VEH001',
  waktuMulai: DateTime.now().add(Duration(hours: 1)),
  durasiJam: 2,
);

final response = await bookingService.createBookingWithRetry(
  request: request,
  token: authToken,
  maxRetries: 3,
);

if (response.success) {
  print('Booking created: ${response.booking?.idBooking}');
} else {
  print('Error: ${response.message}');
}
```

---

## Widgets

### 1. MallInfoCard

Displays mall information including name, address, distance, and available slots.

**Location:** `lib/presentation/widgets/mall_info_card.dart`

**Constructor:**
```dart
MallInfoCard({
  Key? key,
  required this.mallName,
  required this.address,
  required this.distance,
  required this.availableSlots,
})
```

**Props:**

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| mallName | String | Yes | Name of the mall |
| address | String | Yes | Mall address |
| distance | String | Yes | Distance from current location (e.g., "1.3 km") |
| availableSlots | int | Yes | Number of available parking slots |

**Usage:**
```dart
MallInfoCard(
  mallName: 'Mega Mall Batam Centre',
  address: 'Jl. Engku Putri, Batam Centre',
  distance: '1.3 km',
  availableSlots: 15,
)
```

---

### 2. VehicleSelector

Dropdown widget for selecting a registered vehicle.

**Location:** `lib/presentation/widgets/vehicle_selector.dart`

**Constructor:**
```dart
VehicleSelector({
  Key? key,
  required this.vehicles,
  required this.selectedVehicle,
  required this.onVehicleSelected,
  this.isLoading = false,
  this.onAddVehicle,
})
```

**Props:**

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| vehicles | List<VehicleModel> | Yes | List of available vehicles |
| selectedVehicle | VehicleModel? | Yes | Currently selected vehicle |
| onVehicleSelected | Function(VehicleModel) | Yes | Callback when vehicle is selected |
| isLoading | bool | No | Show loading indicator |
| onAddVehicle | VoidCallback? | No | Callback for "Add Vehicle" button |

**Usage:**
```dart
VehicleSelector(
  vehicles: vehicleList,
  selectedVehicle: bookingProvider.selectedVehicle,
  onVehicleSelected: (vehicle) {
    bookingProvider.selectVehicle(vehicle.toJson());
  },
  isLoading: isLoadingVehicles,
  onAddVehicle: () {
    Navigator.pushNamed(context, '/add-vehicle');
  },
)
```

---

### 3. TimeDurationPicker

Widget for selecting booking start time and duration.

**Location:** `lib/presentation/widgets/time_duration_picker.dart`

**Constructor:**
```dart
TimeDurationPicker({
  Key? key,
  required this.startTime,
  required this.duration,
  required this.onStartTimeChanged,
  required this.onDurationChanged,
  this.minStartTime,
  this.maxStartTime,
  this.durationOptions = const [1, 2, 3, 4],
})
```

**Props:**

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| startTime | DateTime? | Yes | Current start time |
| duration | Duration? | Yes | Current duration |
| onStartTimeChanged | Function(DateTime) | Yes | Callback when start time changes |
| onDurationChanged | Function(Duration) | Yes | Callback when duration changes |
| minStartTime | DateTime? | No | Minimum selectable start time |
| maxStartTime | DateTime? | No | Maximum selectable start time |
| durationOptions | List<int> | No | Duration preset options in hours |

**Usage:**
```dart
TimeDurationPicker(
  startTime: bookingProvider.startTime,
  duration: bookingProvider.bookingDuration,
  onStartTimeChanged: (time) {
    bookingProvider.setStartTime(time, token: authToken);
  },
  onDurationChanged: (duration) {
    bookingProvider.setDuration(duration, token: authToken);
  },
  minStartTime: DateTime.now().add(Duration(minutes: 15)),
  maxStartTime: DateTime.now().add(Duration(days: 7)),
  durationOptions: [1, 2, 3, 4, 6, 8],
)
```

---

### 4. SlotAvailabilityIndicator

Real-time indicator showing parking slot availability.

**Location:** `lib/presentation/widgets/slot_availability_indicator.dart`

**Constructor:**
```dart
SlotAvailabilityIndicator({
  Key? key,
  required this.availableSlots,
  required this.vehicleType,
  required this.onRefresh,
  this.isLoading = false,
  this.lastChecked,
})
```

**Props:**

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| availableSlots | int | Yes | Number of available slots |
| vehicleType | String | Yes | Type of vehicle |
| onRefresh | VoidCallback | Yes | Callback for manual refresh |
| isLoading | bool | No | Show loading indicator |
| lastChecked | DateTime? | No | Last availability check time |

**Usage:**
```dart
SlotAvailabilityIndicator(
  availableSlots: bookingProvider.availableSlots,
  vehicleType: selectedVehicle.jenisKendaraan,
  onRefresh: () {
    bookingProvider.refreshAvailability(token: authToken);
  },
  isLoading: bookingProvider.isCheckingAvailability,
  lastChecked: bookingProvider.lastAvailabilityCheck,
)
```

---

### 5. CostBreakdownCard

Displays parking cost breakdown and total estimate.

**Location:** `lib/presentation/widgets/cost_breakdown_card.dart`

**Constructor:**
```dart
CostBreakdownCard({
  Key? key,
  required this.firstHourRate,
  required this.additionalHourRate,
  required this.duration,
  required this.totalCost,
  this.breakdown,
})
```

**Props:**

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| firstHourRate | double | Yes | First hour parking rate |
| additionalHourRate | double | Yes | Additional hour rate |
| duration | Duration | Yes | Booking duration |
| totalCost | double | Yes | Total estimated cost |
| breakdown | Map<String, dynamic>? | No | Detailed cost breakdown |

**Usage:**
```dart
CostBreakdownCard(
  firstHourRate: bookingProvider.firstHourRate,
  additionalHourRate: bookingProvider.additionalHourRate,
  duration: bookingProvider.bookingDuration!,
  totalCost: bookingProvider.estimatedCost,
  breakdown: bookingProvider.costBreakdown,
)
```

---

### 6. BookingSummaryCard

Final review card showing all booking details.

**Location:** `lib/presentation/widgets/booking_summary_card.dart`

**Constructor:**
```dart
BookingSummaryCard({
  Key? key,
  required this.mallName,
  required this.address,
  required this.vehiclePlate,
  required this.vehicleType,
  required this.startTime,
  required this.endTime,
  required this.duration,
  required this.totalCost,
})
```

**Props:**

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| mallName | String | Yes | Mall name |
| address | String | Yes | Mall address |
| vehiclePlate | String | Yes | Vehicle plate number |
| vehicleType | String | Yes | Vehicle type |
| startTime | DateTime | Yes | Booking start time |
| endTime | DateTime | Yes | Booking end time |
| duration | Duration | Yes | Booking duration |
| totalCost | double | Yes | Total estimated cost |

**Usage:**
```dart
BookingSummaryCard(
  mallName: selectedMall['name'],
  address: selectedMall['address'],
  vehiclePlate: selectedVehicle['plat_nomor'],
  vehicleType: selectedVehicle['jenis_kendaraan'],
  startTime: bookingProvider.startTime!,
  endTime: bookingProvider.calculatedEndTime!,
  duration: bookingProvider.bookingDuration!,
  totalCost: bookingProvider.estimatedCost,
)
```

---

## Utilities

### CostCalculator

Utility class for parking cost calculations.

**Location:** `lib/utils/cost_calculator.dart`

**Methods:**
```dart
// Estimate total cost
static double estimateCost({
  required double durationHours,
  required double firstHourRate,
  required double additionalHourRate,
})

// Generate cost breakdown
static Map<String, dynamic> generateCostBreakdown({
  required double durationHours,
  required double firstHourRate,
  required double additionalHourRate,
})

// Convert Duration to hours
static double durationToHours(Duration duration)

// Format currency
static String formatCurrency(double amount)
```

**Usage:**
```dart
final cost = CostCalculator.estimateCost(
  durationHours: 2.5,
  firstHourRate: 5000.0,
  additionalHourRate: 3000.0,
);

final breakdown = CostCalculator.generateCostBreakdown(
  durationHours: 2.5,
  firstHourRate: 5000.0,
  additionalHourRate: 3000.0,
);

final formatted = CostCalculator.formatCurrency(cost);
// Output: "Rp 9.500"
```

---

### BookingValidator

Utility class for input validation.

**Location:** `lib/utils/booking_validator.dart`

**Methods:**
```dart
// Validate start time
static String? validateStartTime(DateTime? startTime)

// Validate duration
static String? validateDuration(Duration? duration)

// Validate vehicle selection
static String? validateVehicle(String? vehicleId)

// Validate all inputs
static Map<String, String> validateAll({
  DateTime? startTime,
  Duration? duration,
  String? vehicleId,
})
```

**Usage:**
```dart
final errors = BookingValidator.validateAll(
  startTime: DateTime.now().add(Duration(hours: 1)),
  duration: Duration(hours: 2),
  vehicleId: 'VEH001',
);

if (errors.isEmpty) {
  // All validations passed
} else {
  // Show validation errors
  errors.forEach((field, message) {
    print('$field: $message');
  });
}
```

---

## Models

### BookingModel

Represents a booking record.

**Location:** `lib/data/models/booking_model.dart`

**Properties:**
```dart
final String idTransaksi
final String idBooking
final String qrCode
final String idMall
final String idParkiran
final String idKendaraan
final DateTime waktuMulai
final DateTime waktuSelesai
final int durasiBooking
final String status
final double biayaEstimasi
final DateTime dibookingPada
```

**Methods:**
```dart
factory BookingModel.fromJson(Map<String, dynamic> json)
Map<String, dynamic> toJson()
String get formattedDuration
String get formattedCost
bool get isActive
bool get isExpired
```

---

### BookingRequest

Represents a booking creation request.

**Location:** `lib/data/models/booking_request.dart`

**Properties:**
```dart
final String idMall
final String idKendaraan
final DateTime waktuMulai
final int durasiJam
final String? notes
```

**Methods:**
```dart
Map<String, dynamic> toJson()
```

---

### BookingResponse

Represents API response for booking operations.

**Location:** `lib/data/models/booking_response.dart`

**Properties:**
```dart
final bool success
final String message
final BookingModel? booking
final String? qrCode
final String? errorCode
```

**Factory Constructors:**
```dart
factory BookingResponse.success({
  required String message,
  required BookingModel booking,
  String? qrCode,
})

factory BookingResponse.error({
  required String message,
  required String errorCode,
})

factory BookingResponse.fromJson(Map<String, dynamic> json)
```

---

## Usage Examples

### Complete Booking Flow

```dart
class BookingPage extends StatefulWidget {
  final Map<String, dynamic> mallData;
  
  const BookingPage({Key? key, required this.mallData}) : super(key: key);
  
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  @override
  void initState() {
    super.initState();
    
    // Initialize booking provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      bookingProvider.initialize(widget.mallData);
      
      // Start periodic availability checks
      final authToken = getAuthToken();
      bookingProvider.startPeriodicAvailabilityCheck(token: authToken);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Parkir'),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Mall info
                MallInfoCard(
                  mallName: widget.mallData['name'],
                  address: widget.mallData['address'],
                  distance: widget.mallData['distance'],
                  availableSlots: bookingProvider.availableSlots,
                ),
                
                SizedBox(height: 16),
                
                // Vehicle selector
                VehicleSelector(
                  vehicles: vehicleList,
                  selectedVehicle: bookingProvider.selectedVehicle,
                  onVehicleSelected: (vehicle) {
                    bookingProvider.selectVehicle(vehicle.toJson());
                  },
                ),
                
                SizedBox(height: 16),
                
                // Time and duration picker
                TimeDurationPicker(
                  startTime: bookingProvider.startTime,
                  duration: bookingProvider.bookingDuration,
                  onStartTimeChanged: (time) {
                    bookingProvider.setStartTime(time, token: authToken);
                  },
                  onDurationChanged: (duration) {
                    bookingProvider.setDuration(duration, token: authToken);
                  },
                ),
                
                SizedBox(height: 16),
                
                // Slot availability
                SlotAvailabilityIndicator(
                  availableSlots: bookingProvider.availableSlots,
                  vehicleType: selectedVehicle?.jenisKendaraan ?? '',
                  onRefresh: () {
                    bookingProvider.refreshAvailability(token: authToken);
                  },
                  isLoading: bookingProvider.isCheckingAvailability,
                ),
                
                SizedBox(height: 16),
                
                // Cost breakdown
                if (bookingProvider.bookingDuration != null)
                  CostBreakdownCard(
                    firstHourRate: bookingProvider.firstHourRate,
                    additionalHourRate: bookingProvider.additionalHourRate,
                    duration: bookingProvider.bookingDuration!,
                    totalCost: bookingProvider.estimatedCost,
                  ),
                
                SizedBox(height: 16),
                
                // Booking summary
                if (bookingProvider.canConfirmBooking)
                  BookingSummaryCard(
                    mallName: widget.mallData['name'],
                    address: widget.mallData['address'],
                    vehiclePlate: selectedVehicle!.platNomor,
                    vehicleType: selectedVehicle!.jenisKendaraan,
                    startTime: bookingProvider.startTime!,
                    endTime: bookingProvider.calculatedEndTime!,
                    duration: bookingProvider.bookingDuration!,
                    totalCost: bookingProvider.estimatedCost,
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          return Container(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: bookingProvider.canConfirmBooking
                  ? () => _confirmBooking(context, bookingProvider)
                  : null,
              child: bookingProvider.isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Konfirmasi Booking'),
            ),
          );
        },
      ),
    );
  }
  
  Future<void> _confirmBooking(
    BuildContext context,
    BookingProvider bookingProvider,
  ) async {
    final authToken = getAuthToken();
    
    final success = await bookingProvider.confirmBooking(
      token: authToken,
      onSuccess: (booking) {
        // Show confirmation dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => BookingConfirmationDialog(
            booking: booking,
            onViewActivity: () {
              Navigator.pushReplacementNamed(context, '/activity');
            },
            onBackToHome: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
        );
      },
    );
    
    if (!success && bookingProvider.errorMessage != null) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingProvider.errorMessage!),
          action: SnackBarAction(
            label: 'Coba Lagi',
            onPressed: () => _confirmBooking(context, bookingProvider),
          ),
        ),
      );
    }
  }
  
  @override
  void dispose() {
    // Stop periodic checks when leaving page
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    bookingProvider.stopPeriodicAvailabilityCheck();
    super.dispose();
  }
}
```

---

## Best Practices

1. **Always dispose providers** when leaving the page
2. **Use Consumer widgets** for reactive UI updates
3. **Handle loading states** with shimmer or progress indicators
4. **Show user-friendly error messages** from provider.errorMessage
5. **Validate inputs** before allowing booking confirmation
6. **Cache data** to reduce API calls
7. **Implement retry logic** for network failures
8. **Test all edge cases** with unit and widget tests

---

## Troubleshooting

### Common Issues

**Issue:** Availability not updating
- **Solution:** Ensure `startPeriodicAvailabilityCheck()` is called with valid token

**Issue:** Cost not calculating
- **Solution:** Verify both startTime and duration are set

**Issue:** Booking fails with validation error
- **Solution:** Check `provider.validationErrors` for specific field errors

**Issue:** Memory leaks
- **Solution:** Always call `stopPeriodicAvailabilityCheck()` in dispose()

---

## Support

For component usage questions:
- Check inline dartdoc comments in source files
- Review unit tests for usage examples
- Contact: dev-support@qparkin.com
