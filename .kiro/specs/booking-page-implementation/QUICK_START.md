# Booking Page Implementation - Quick Start Guide

## Overview

This guide provides a quick reference for implementing the Booking Page feature in QPARKIN. For detailed specifications, refer to the requirements.md, design.md, and tasks.md files.

## Prerequisites

- Flutter SDK 3.0+
- Dart 2.19+
- Existing QPARKIN codebase with Map, Activity, and History pages
- Backend API endpoints for booking creation and slot availability

## File Structure

Create the following files in your project:

```
lib/
├── data/
│   ├── models/
│   │   ├── booking_model.dart
│   │   ├── booking_request.dart
│   │   └── booking_response.dart
│   └── services/
│       └── booking_service.dart
├── logic/
│   └── providers/
│       └── booking_provider.dart
├── presentation/
│   ├── screens/
│   │   └── booking_page.dart
│   ├── widgets/
│   │   ├── mall_info_card.dart
│   │   ├── vehicle_selector.dart
│   │   ├── time_duration_picker.dart
│   │   ├── slot_availability_indicator.dart
│   │   ├── cost_breakdown_card.dart
│   │   └── booking_summary_card.dart
│   └── dialogs/
│       └── booking_confirmation_dialog.dart
└── utils/
    ├── booking_validator.dart
    └── cost_calculator.dart
```

## Quick Implementation Steps

### 1. Create Data Models (15 minutes)

```dart
// lib/data/models/booking_model.dart
class BookingModel {
  final String idTransaksi;
  final String idBooking;
  final String qrCode;
  final DateTime waktuMulai;
  final DateTime waktuSelesai;
  final double biayaEstimasi;
  
  // Add fromJson, toJson, and computed properties
}
```

### 2. Implement Booking Service (30 minutes)

```dart
// lib/data/services/booking_service.dart
class BookingService {
  Future<BookingResponse> createBooking(BookingRequest request) async {
    // POST /api/booking/create
  }
  
  Future<int> checkSlotAvailability({
    required String mallId,
    required String vehicleType,
    required DateTime startTime,
    required int duration,
  }) async {
    // GET /api/booking/check-availability
  }
}
```

### 3. Create Booking Provider (45 minutes)

```dart
// lib/logic/providers/booking_provider.dart
class BookingProvider extends ChangeNotifier {
  MallModel? selectedMall;
  VehicleModel? selectedVehicle;
  DateTime? startTime;
  Duration? bookingDuration;
  double estimatedCost = 0.0;
  int availableSlots = 0;
  bool isLoading = false;
  String? errorMessage;
  
  Future<void> initialize(MallModel mall) { }
  void selectVehicle(VehicleModel vehicle) { }
  void setStartTime(DateTime time) { }
  void setDuration(Duration duration) { }
  void calculateCost() { }
  Future<BookingResponse> confirmBooking() { }
}
```

### 4. Build Widget Components (2-3 hours)

Create each widget component following the design specs:

- **MallInfoCard**: Display mall details (30 min)
- **VehicleSelector**: Dropdown for vehicle selection (45 min)
- **TimeDurationPicker**: Time and duration selection (1 hour)
- **SlotAvailabilityIndicator**: Real-time slot status (30 min)
- **CostBreakdownCard**: Pricing breakdown (30 min)
- **BookingSummaryCard**: Final review (30 min)

### 5. Implement Main Booking Page (1-2 hours)

```dart
// lib/presentation/screens/booking_page.dart
class BookingPage extends StatefulWidget {
  final MallModel mall;
  
  const BookingPage({required this.mall});
  
  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookingProvider()..initialize(widget.mall),
      child: Scaffold(
        appBar: AppBar(title: Text('Booking Parkir')),
        body: SingleChildScrollView(
          child: Column(
            children: [
              MallInfoCard(),
              VehicleSelector(),
              TimeDurationPicker(),
              SlotAvailabilityIndicator(),
              CostBreakdownCard(),
              BookingSummaryCard(),
            ],
          ),
        ),
        bottomNavigationBar: _buildConfirmButton(),
      ),
    );
  }
}
```

### 6. Add Navigation from Map Page (15 minutes)

```dart
// In map_page.dart
void _navigateToBooking() {
  if (_selectedMall != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingPage(mall: _selectedMall!),
      ),
    );
  }
}
```

### 7. Implement Success Dialog (30 minutes)

```dart
// lib/presentation/dialogs/booking_confirmation_dialog.dart
class BookingConfirmationDialog extends StatelessWidget {
  final BookingModel booking;
  
  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Column(
        children: [
          // Success animation
          // QR code display
          // Booking details
          // Action buttons
        ],
      ),
    );
  }
}
```

## Color Palette Reference

```dart
const primaryPurple = Color(0xFF573ED1);
const purpleGradientStart = Color(0xFF573ED1);
const purpleGradientEnd = Color(0xFF6B4FE0);
const successGreen = Color(0xFF4CAF50);
const warningYellow = Color(0xFFFF9800);
const errorRed = Color(0xFFF44336);
const backgroundWhite = Color(0xFFFFFFFF);
const textBlack = Colors.black87;
const textGrey = Colors.grey.shade600;
```

## Common Patterns

### Card Styling

```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
  padding: EdgeInsets.all(16),
  child: // Your content
)
```

### Purple Gradient Button

```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF573ED1), Color(0xFF6B4FE0)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Color(0xFF573ED1).withOpacity(0.3),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      minimumSize: Size(double.infinity, 56),
    ),
    child: Text('Konfirmasi Booking'),
  ),
)
```

### Error Handling

```dart
try {
  final response = await bookingService.createBooking(request);
  if (response.success) {
    // Show success dialog
  } else {
    // Show error message
    _showError(response.message);
  }
} catch (e) {
  // Handle network/server errors
  _showError(_getUserFriendlyError(e.toString()));
}
```

## Testing Checklist

- [ ] All widget components render correctly
- [ ] Form validation works for all fields
- [ ] Cost calculation is accurate
- [ ] Slot availability updates in real-time
- [ ] Booking creation succeeds with valid data
- [ ] Error handling works for all error types
- [ ] Navigation flows correctly (Map → Booking → Activity)
- [ ] Success dialog displays QR code
- [ ] Activity Page shows new booking
- [ ] History Page shows completed booking
- [ ] Accessibility features work (screen reader, contrast, touch targets)
- [ ] Performance meets targets (< 2s load, 60fps scroll)

## Common Issues & Solutions

### Issue: Cost not updating when duration changes
**Solution**: Ensure calculateCost() is called in setDuration() and notifyListeners() is called after

### Issue: Slot availability not refreshing
**Solution**: Check Timer is started in initState() and disposed in dispose()

### Issue: Navigation not working
**Solution**: Verify route is registered in main.dart or use MaterialPageRoute

### Issue: QR code not displaying
**Solution**: Ensure qr_flutter package is added to pubspec.yaml

### Issue: Form validation not working
**Solution**: Check all validators return null for valid input and error string for invalid

## Resources

- **SKPPL Document**: qparkin_app/assets/docs/skppl_qparkin.md
- **Activity Page Reference**: qparkin_app/lib/presentation/screens/activity_page.dart
- **Map Page Reference**: qparkin_app/lib/presentation/screens/map_page.dart
- **Provider Pattern**: https://pub.dev/packages/provider
- **QR Code Package**: https://pub.dev/packages/qr_flutter
- **Lottie Animations**: https://pub.dev/packages/lottie

## Next Steps

1. Review requirements.md for detailed acceptance criteria
2. Review design.md for component specifications
3. Follow tasks.md for step-by-step implementation
4. Test each component independently before integration
5. Perform end-to-end testing after completion
6. Conduct user acceptance testing
7. Deploy to production

## Support

For questions or issues during implementation:
- Review the INTEGRATION_SUMMARY.md for design decisions
- Check existing Activity Page implementation for patterns
- Refer to SKPPL document for business requirements
- Test with real backend API endpoints

