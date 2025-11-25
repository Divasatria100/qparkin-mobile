# Design Document

## Overview

The Activity Page enhancement transforms the Aktivitas tab into a real-time parking monitoring dashboard. The design centers around a prominent circular animated timer that serves as the visual focal point, allowing drivers to instantly see their parking duration at a glance. The page follows a clear information hierarchy: animated timer → booking details → action button, ensuring optimal user experience and readability.

## Architecture

### Component Structure

```
ActivityPage (StatefulWidget)
├── AppBar (preserved from original)
├── TabBar (preserved from original)
└── TabBarView
    ├── Aktivitas Tab (ENHANCED)
    │   ├── ActiveParkingProvider (State Management)
    │   ├── CircularTimerWidget (NEW - Focal Point)
    │   ├── BookingDetailCard (NEW)
    │   └── QRExitButton (NEW)
    └── Riwayat Tab (unchanged)
```

### State Management Pattern

The Activity Page will use the Provider pattern (ChangeNotifier) for state management:

- **ActiveParkingProvider**: Manages active parking session data, timer updates, and real-time cost calculations
- **BookingProvider**: Handles booking data fetching and status updates
- **TransactionProvider**: Manages transaction data and penalty calculations

### Data Flow

```
Database (MySQL)
    ↓
API Service (Laravel Backend)
    ↓
HTTP Client (lib/data/services)
    ↓
Data Models (lib/data/models)
    ↓
Providers (lib/logic/providers)
    ↓
UI Components (lib/presentation/screens/activity_page.dart)
```

## Components and Interfaces

### 1. CircularTimerWidget (NEW)

**Purpose**: Display animated circular progress timer as the visual focal point

**Properties**:
- `startTime`: DateTime - parking entry time (waktu_masuk)
- `endTime`: DateTime? - booking end time (waktuSelesaiEstimas), nullable for non-booking sessions
- `isBooking`: bool - indicates if session is from booking
- `onTimerUpdate`: Function(Duration) - callback for elapsed time updates

**Visual Design**:
- Circular progress ring with animated gradient (clockwise animation)
- Gradient colors: #8D71FA → #3B77DC (purple to blue)
- Center displays: Large time text (HH:MM:SS format)
- Below time: Small label "Durasi Parkir" or "Sisa Waktu Booking"
- Ring thickness: 12px
- Diameter: 240px (prominent size)
- Background: White with subtle shadow
- Animation: Smooth 1-second interval updates

**Implementation Details**:
```dart
class CircularTimerWidget extends StatefulWidget {
  final DateTime startTime;
  final DateTime? endTime;
  final bool isBooking;
  final Function(Duration) onTimerUpdate;
  
  // Uses CustomPainter for circular progress
  // Timer updates every second
  // Calculates progress percentage for animation
}
```

### 2. BookingDetailCard (NEW)

**Purpose**: Display comprehensive booking and transaction details below the timer

**Data Sources**:
- `booking` table: qrCode, waktu_mulai, waktu_selesai, durasi_booking, status
- `transaksi_parkir` table: waktu_masuk, waktu_keluar, biaya, penalty
- `mall` table: nama_mall, lokasi
- `parkiran` table: id_parkiran, kodeSlot
- `kendaraan` table: plat, jenis_kendaraan, merk, tipe

**Layout Structure**:
```
┌─────────────────────────────────────┐
│  📍 Nama Mall                       │
│  Area: Slot Code                    │
├─────────────────────────────────────┤
│  🚗 Plat Nomor                      │
│  Jenis: Merk - Tipe                 │
├─────────────────────────────────────┤
│  ⏰ Waktu Masuk: HH:MM              │
│  ⏱️  Estimasi Selesai: HH:MM        │
├─────────────────────────────────────┤
│  💰 Biaya Berjalan: Rp XX,XXX       │
│  ⚠️  Penalty: Rp X,XXX (if any)     │
└─────────────────────────────────────┘
```

**Visual Design**:
- White background with rounded corners (16px radius)
- Subtle shadow (elevation 2)
- Icon + text layout for each row
- Penalty row highlighted in orange/red when applicable
- Padding: 20px all sides
- Spacing between rows: 12px

### 3. QRExitButton (NEW)

**Purpose**: Single action button to display exit QR code

**Visual Design**:
- Full-width button with purple gradient background (#573ED1)
- White text: "Tampilkan QR Keluar"
- QR code icon on the left
- Height: 56px
- Border radius: 12px
- Elevation: 4
- Positioned at bottom with 24px margin

**Behavior**:
- Enabled only when active parking exists
- On tap: Navigate to QR display dialog/screen
- Shows loading state during QR generation
- Disabled state: Gray background, reduced opacity

### 4. EmptyStateWidget (Preserved)

**Purpose**: Display when no active parking session exists

**Visual Design** (unchanged from original):
- Centered layout
- Gray circular icon background
- Car icon
- "Tidak ada parkir aktif" heading
- Descriptive subtext

## Data Models

### ActiveParkingModel (NEW)

```dart
class ActiveParkingModel {
  final String idTransaksi;
  final String idBooking;
  final String qrCode;
  
  // Mall & Location
  final String namaMall;
  final String lokasiMall;
  final String idParkiran;
  final String kodeSlot;
  
  // Vehicle
  final String platNomor;
  final String jenisKendaraan;
  final String merkKendaraan;
  final String tipeKendaraan;
  
  // Time
  final DateTime waktuMasuk;
  final DateTime? waktuSelesaiEstimas;
  final bool isBooking;
  
  // Cost
  final double biayaPerJam;
  final double biayaJamPertama;
  final double? penalty;
  
  // Status
  final String statusParkir; // 'aktif', 'booking_aktif'
  
  // Methods
  Duration getElapsedDuration();
  Duration? getRemainingDuration();
  double calculateCurrentCost();
  bool isPenaltyApplicable();
}
```

### TimerState (NEW)

```dart
class TimerState {
  final Duration elapsed;
  final Duration? remaining;
  final double progress; // 0.0 to 1.0 for circular animation
  final bool isOvertime;
  final double currentCost;
  final double? penaltyAmount;
}
```

## Error Handling

### Network Errors
- **Scenario**: API call fails to fetch active parking data
- **Handling**: Display retry button with error message
- **UI**: Show snackbar notification, maintain last known state

### Data Inconsistency
- **Scenario**: Missing required fields in database response
- **Handling**: Log error, show partial data with warning indicator
- **UI**: Display available information, mark missing fields

### Timer Synchronization
- **Scenario**: Device time differs from server time
- **Handling**: Use server timestamp as source of truth
- **UI**: Periodic sync every 30 seconds to correct drift

### Booking Expiration
- **Scenario**: Booking time exceeded while viewing page
- **Handling**: Automatically calculate penalty, update UI
- **UI**: Highlight penalty in warning color, show notification

## Testing Strategy

### Unit Tests
1. **ActiveParkingModel Tests**
   - Test duration calculations (elapsed, remaining)
   - Test cost calculations with various tariffs
   - Test penalty calculation logic
   - Test status determination

2. **Timer Logic Tests**
   - Test timer accuracy over extended periods
   - Test progress calculation for circular animation
   - Test overtime detection

3. **Data Parsing Tests**
   - Test JSON to model conversion
   - Test handling of null/missing fields
   - Test date/time parsing

### Widget Tests
1. **CircularTimerWidget Tests**
   - Test timer display updates
   - Test progress animation rendering
   - Test gradient application
   - Test label text changes

2. **BookingDetailCard Tests**
   - Test data display formatting
   - Test penalty highlighting
   - Test icon rendering
   - Test responsive layout

3. **QRExitButton Tests**
   - Test enabled/disabled states
   - Test tap behavior
   - Test loading state display

### Integration Tests
1. **Full Page Flow**
   - Test loading active parking data
   - Test timer running for 60 seconds
   - Test QR button navigation
   - Test empty state display

2. **Provider Integration**
   - Test state updates propagate to UI
   - Test multiple listeners
   - Test disposal and cleanup

3. **API Integration**
   - Test successful data fetch
   - Test error handling
   - Test retry mechanism

### Performance Tests
1. **Timer Performance**
   - Verify timer updates don't cause frame drops
   - Test memory usage over 1-hour session
   - Verify smooth circular animation

2. **Data Refresh**
   - Test 30-second periodic refresh impact
   - Verify no UI jank during refresh
   - Test battery consumption

## Visual Design Specifications

### Color Palette
- **Primary Purple**: #573ED1
- **Timer Gradient Start**: #8D71FA
- **Timer Gradient End**: #3B77DC
- **Warning Orange**: #FF9800
- **Error Red**: #F44336
- **Success Green**: #4CAF50
- **Text Primary**: #212121
- **Text Secondary**: #757575
- **Background**: #FFFFFF
- **Border**: #E0E0E0

### Typography
- **Timer Display**: 48sp, Bold, White
- **Timer Label**: 14sp, Regular, White70
- **Card Heading**: 16sp, SemiBold, #212121
- **Card Body**: 14sp, Regular, #757575
- **Button Text**: 16sp, Bold, White

### Spacing
- **Page Padding**: 24px horizontal, 16px vertical
- **Component Spacing**: 24px between major components
- **Card Internal Padding**: 20px
- **Row Spacing**: 12px within cards

### Animations
- **Timer Progress**: Linear, 1000ms duration, continuous
- **Card Entry**: FadeIn + SlideUp, 300ms, ease-out
- **Button Press**: Scale 0.95, 100ms, ease-in-out
- **Data Refresh**: Subtle pulse on timer, 200ms

## Accessibility Considerations

1. **Semantic Labels**: All icons have semantic labels for screen readers
2. **Color Contrast**: Text meets WCAG AA standards (4.5:1 minimum)
3. **Touch Targets**: Buttons minimum 48x48dp
4. **Timer Announcements**: Screen reader announces time every minute
5. **Error Messages**: Clear, actionable error text

## Implementation Notes

### Timer Optimization
- Use `Timer.periodic` with 1-second interval
- Cancel timer in `dispose()` to prevent memory leaks
- Use `setState()` only for timer updates, not full rebuilds
- Consider using `ValueNotifier` for timer value to minimize rebuilds

### Circular Progress Rendering
- Use `CustomPainter` for efficient circular progress drawing
- Cache gradient shader for performance
- Use `Canvas.drawArc` for smooth circular animation
- Implement `shouldRepaint` to optimize redraws

### Data Caching
- Cache active parking data in provider
- Implement 30-second background refresh
- Use optimistic UI updates for better UX
- Handle stale data gracefully

### Navigation Preservation
- Maintain tab state when switching between tabs
- Preserve timer state during navigation
- Handle app lifecycle (pause/resume) correctly
- Save timer state to prevent reset on rebuild
