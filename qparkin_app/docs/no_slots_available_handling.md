# No Slots Available Error Handling Implementation

## Overview

This document describes the implementation of task 12.3: "Handle no slots available" from the booking page slot selection enhancement specification.

## Requirements

- **Requirement 15.1-15.10**: Error Handling for Slot Reservation
  - Notify when no slots available for reservation
  - Suggest alternative floors
  - Provide clear guidance

## Implementation Details

### 1. Enhanced Error Detection (BookingProvider)

**File**: `lib/logic/providers/booking_provider.dart`

#### Error Code Format

When no slots are available, the provider now sets a structured error message:

```dart
_errorMessage = 'NO_SLOTS_AVAILABLE:${floorName}';
```

This format allows the UI to:
- Detect the specific error type
- Extract the floor name for display
- Trigger appropriate UI response

#### Alternative Floor Discovery

Added `getAlternativeFloors()` method:

```dart
List<ParkingFloorModel> getAlternativeFloors() {
  if (_selectedFloor == null) {
    return _floors.where((floor) => floor.hasAvailableSlots).toList()
      ..sort((a, b) => b.availableSlots.compareTo(a.availableSlots));
  }
  
  return _floors
      .where((floor) => 
          floor.idFloor != _selectedFloor!.idFloor && 
          floor.hasAvailableSlots)
      .toList()
    ..sort((a, b) => b.availableSlots.compareTo(a.availableSlots));
}
```

**Features**:
- Excludes the current floor
- Filters only floors with available slots
- Sorts by availability (most available first)
- Returns empty list if no alternatives exist

### 2. Enhanced UI Error Handling (BookingPage)

**File**: `lib/presentation/screens/booking_page.dart`

#### Error Detection

The `_handleReservationError()` method now detects the error code:

```dart
if (errorMessage.startsWith('NO_SLOTS_AVAILABLE:')) {
  final floorName = errorMessage.split(':')[1];
  final alternativeFloors = provider.getAlternativeFloors();
  
  if (alternativeFloors.isNotEmpty) {
    _showAlternativeFloorsDialog(...);
  } else {
    _showNoAlternativesDialog(...);
  }
}
```

#### Alternative Floors Dialog

When alternatives are available, shows an interactive dialog with:

**Visual Design**:
- Orange info icon with "Slot Tidak Tersedia" title
- Clear explanation: "Semua slot di [Floor Name] sudah terisi"
- Blue info box with lightbulb icon: "Coba lantai lain yang masih tersedia"
- Up to 3 alternative floors displayed as cards

**Floor Card Features**:
- Green parking icon in rounded container
- Floor name (bold, 16px)
- Availability count: "X slot tersedia dari Y"
- Tap to switch floors instantly
- Arrow icon indicating interactivity

**User Actions**:
- Tap any floor card → Switches to that floor automatically
- Shows success message: "Beralih ke [Floor Name]"
- Starts auto-refresh timer for new floor
- "Tutup" button to dismiss dialog

**Additional Info**:
- If more than 3 alternatives exist, shows: "+N lantai lainnya tersedia"

#### No Alternatives Dialog

When no alternatives are available, shows a helpful dialog with:

**Visual Design**:
- Orange warning icon with "Parkir Penuh" title
- Clear explanation: "Semua slot di [Floor Name] sudah terisi"
- Orange info box with suggestions

**Suggestions Provided**:
- Coba lagi dalam beberapa menit
- Pilih waktu booking yang berbeda
- Pilih mall lain yang tersedia

**User Actions**:
- "Pilih Mall Lain" → Navigates back to home page
- "Coba Lagi" → Dismisses dialog, allows retry

### 3. User Experience Flow

#### Scenario 1: Alternatives Available

1. User selects floor with no slots
2. Taps "Pesan Slot Acak di [Floor Name]"
3. System detects no slots available
4. Dialog appears with alternative floors
5. User taps alternative floor card
6. System switches to new floor
7. Shows success message
8. Loads slot visualization for new floor
9. User can proceed with reservation

#### Scenario 2: No Alternatives Available

1. User selects floor with no slots
2. Taps "Pesan Slot Acak di [Floor Name]"
3. System detects no slots available
4. Dialog appears with helpful suggestions
5. User can:
   - Try again later (Coba Lagi)
   - Select different mall (Pilih Mall Lain)
   - Change booking time

### 4. Accessibility Features

**Screen Reader Support**:
- Dialog titles announced clearly
- Floor cards have semantic labels
- Success messages announced when switching floors

**Visual Indicators**:
- Color-coded icons (orange for warnings, green for available)
- Clear text hierarchy
- Sufficient contrast ratios

**Touch Targets**:
- Floor cards are large and easy to tap
- Buttons meet minimum 48dp touch target size

## Testing

### Unit Tests

**File**: `test/providers/booking_provider_no_slots_test.dart`

Tests verify:
- Error message format is correct
- `getAlternativeFloors()` method exists and works
- Provider initialization works correctly
- Error codes can be parsed properly

### Manual Testing Scenarios

1. **Test Alternative Floors**:
   - Select floor with no slots
   - Verify dialog shows alternatives
   - Tap alternative floor
   - Verify floor switches correctly

2. **Test No Alternatives**:
   - Simulate all floors full
   - Verify "Parkir Penuh" dialog appears
   - Verify suggestions are helpful
   - Test both action buttons

3. **Test Error Recovery**:
   - Trigger no slots error
   - Dismiss dialog
   - Change time/duration
   - Verify can retry

## Code Quality

### Error Handling Best Practices

✅ **Structured Error Codes**: Uses `NO_SLOTS_AVAILABLE:FloorName` format
✅ **Graceful Degradation**: Falls back to generic error if parsing fails
✅ **User-Friendly Messages**: Clear, actionable Indonesian text
✅ **Helpful Suggestions**: Provides concrete next steps
✅ **Visual Feedback**: Color-coded icons and containers

### UI/UX Best Practices

✅ **Progressive Disclosure**: Shows relevant info at right time
✅ **One-Tap Actions**: Floor switching requires single tap
✅ **Clear Hierarchy**: Important info stands out visually
✅ **Consistent Design**: Matches app's purple/green color scheme
✅ **Responsive Layout**: Works on different screen sizes

## Requirements Compliance

| Requirement | Status | Implementation |
|------------|--------|----------------|
| Notify when no slots available | ✅ | Error code + dialog with clear message |
| Suggest alternative floors | ✅ | `getAlternativeFloors()` + interactive cards |
| Provide clear guidance | ✅ | Suggestions box with 3 actionable items |
| Sort by availability | ✅ | Alternatives sorted by slot count |
| One-tap floor switching | ✅ | Tap card → auto-switch + success message |
| Handle no alternatives | ✅ | Separate dialog with helpful suggestions |

## Future Enhancements

Potential improvements for future iterations:

1. **Real-time Updates**: Show live slot count updates in dialog
2. **Booking Time Suggestions**: Suggest specific times with availability
3. **Nearby Malls**: Suggest other malls with available slots
4. **Notification**: Allow users to get notified when slots become available
5. **Analytics**: Track which alternatives users choose most often

## Related Files

- `lib/logic/providers/booking_provider.dart` - Provider logic
- `lib/presentation/screens/booking_page.dart` - UI implementation
- `lib/data/models/parking_floor_model.dart` - Floor data model
- `test/providers/booking_provider_no_slots_test.dart` - Unit tests

## Conclusion

This implementation provides a comprehensive solution for handling the "no slots available" scenario with:
- Clear error detection and messaging
- Helpful alternative suggestions
- One-tap floor switching
- Graceful handling when no alternatives exist
- User-friendly guidance for next steps

The implementation meets all requirements from specification 15.1-15.10 and provides an excellent user experience even in error scenarios.
