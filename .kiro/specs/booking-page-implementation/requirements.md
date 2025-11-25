# Requirements Document

## Introduction

This specification defines the requirements for implementing the Booking Page in the QPARKIN mobile application. The Booking Page enables drivers to reserve parking slots at selected malls before arrival, ensuring slot availability and providing a seamless parking experience. This feature aligns with Use Case UC-004 (Booking Slot Parkir) from the SKPPL documentation and integrates with the existing map selection flow, activity tracking, and parking history system.

## Glossary

- **System**: The QPARKIN mobile application Booking Page module
- **Driver**: The end user (customer) who books and parks their vehicle using the QPARKIN app
- **Mall**: A shopping center location with parking facilities managed by QPARKIN
- **Slot Parkir**: A specific parking space identified by id_parkiran and kodeSlot
- **Booking**: A reservation record for a parking slot with scheduled start and end times
- **TransaksiParkir**: A parking transaction record created when booking is confirmed
- **Tarif Parkir**: Parking rate structure including first hour rate and subsequent hourly rates
- **QR Code**: Quick Response code generated for booking verification and gate access
- **Estimasi Biaya**: Estimated parking cost calculated based on booking duration and tariff
- **Jenis Kendaraan**: Vehicle type (Roda Dua, Roda Tiga, Roda Empat, Lebih dari Enam)
- **Penalty**: Additional charges applied when parking duration exceeds booking time

## Requirements

### Requirement 1

**User Story:** As a Driver, I want to navigate from the Map Page to the Booking Page after selecting a mall, so that I can reserve a parking slot at my chosen location.

#### Acceptance Criteria

1. WHEN Driver selects a mall on Map Page and taps "Booking Sekarang", THE System SHALL navigate to Booking Page with selected mall data
2. THE System SHALL pass mall information including id_mall, nama_mall, lokasi, alamat_gmaps, and available slot count
3. THE System SHALL display a loading indicator during navigation transition
4. THE System SHALL maintain bottom navigation bar visibility with Map icon highlighted
5. THE System SHALL provide a back button to return to Map Page without losing mall selection

### Requirement 2

**User Story:** As a Driver, I want to see comprehensive mall information on the Booking Page, so that I can confirm I'm booking at the correct location.

#### Acceptance Criteria

1. THE System SHALL display mall name prominently at the top of the page
2. THE System SHALL display mall address with location pin icon
3. THE System SHALL display distance from current location
4. THE System SHALL show available parking slots count with real-time updates
5. THE System SHALL display mall operating hours if available
6. THE System SHALL use a card-based layout with white background and subtle shadow (elevation 2-4)
7. THE System SHALL apply consistent purple accent color (0xFF573ED1) for primary elements

### Requirement 3

**User Story:** As a Driver, I want to select my vehicle from registered vehicles, so that the system can apply correct parking rates and track my booking.

#### Acceptance Criteria

1. THE System SHALL fetch registered vehicles from kendaraan table for authenticated Driver
2. THE System SHALL display vehicle selection dropdown showing plat nomor, jenis, merk, and tipe
3. WHEN no vehicles are registered, THE System SHALL display "Tambah Kendaraan" button navigating to vehicle registration
4. THE System SHALL pre-select the most recently used vehicle if available
5. THE System SHALL validate vehicle selection before allowing booking confirmation
6. THE System SHALL display vehicle icon based on jenis_kendaraan type
7. THE System SHALL apply purple accent color to selected vehicle card

### Requirement 4

**User Story:** As a Driver, I want to select booking start time and duration, so that I can reserve a slot for my planned parking period.

#### Acceptance Criteria

1. THE System SHALL provide date-time picker for booking start time (waktu_mulai)
2. THE System SHALL default start time to current time + 15 minutes
3. THE System SHALL allow start time selection up to 7 days in advance
4. THE System SHALL prevent selection of past times
5. THE System SHALL provide duration selector with preset options (1 hour, 2 hours, 3 hours, 4 hours, Custom)
6. WHEN Custom is selected, THE System SHALL display hour and minute pickers
7. THE System SHALL calculate waktu_selesai_estimas as waktu_mulai + durasi_booking
8. THE System SHALL display calculated end time prominently
9. THE System SHALL validate that duration is at least 30 minutes and maximum 12 hours

### Requirement 5

**User Story:** As a Driver, I want to see parking slot availability for my selected time period, so that I can confirm slots are available before booking.

#### Acceptance Criteria

1. WHEN Driver selects start time and duration, THE System SHALL query parkiran table for available slots
2. THE System SHALL filter slots by jenis_kendaraan matching selected vehicle
3. THE System SHALL check existing bookings to exclude reserved slots for the time period
4. THE System SHALL display available slot count with visual indicator (green for available, yellow for limited, red for full)
5. WHEN no slots are available, THE System SHALL disable booking button and suggest alternative times
6. THE System SHALL refresh availability every 30 seconds while page is active
7. THE System SHALL display slot location information (lantai, area) if available

### Requirement 6

**User Story:** As a Driver, I want to see estimated parking cost before confirming booking, so that I can make an informed decision.

#### Acceptance Criteria

1. THE System SHALL fetch tarif_parkir from database based on id_mall and jenis_kendaraan
2. THE System SHALL calculate estimated cost using formula: first hour rate + (additional hours × hourly rate)
3. THE System SHALL display cost breakdown showing first hour rate and subsequent hourly rate
4. THE System SHALL display total estimated cost prominently in large text
5. THE System SHALL update cost calculation immediately when duration changes
6. THE System SHALL display penalty warning if booking duration is likely to be exceeded
7. THE System SHALL format currency as "Rp X.XXX" with thousand separators

### Requirement 7

**User Story:** As a Driver, I want to review all booking details before confirmation, so that I can verify information accuracy.

#### Acceptance Criteria

1. THE System SHALL display a summary card containing all booking details
2. THE System SHALL show mall name, address, and parking area
3. THE System SHALL show selected vehicle information (plat, jenis, merk)
4. THE System SHALL show booking time range (waktu_mulai to waktu_selesai_estimas)
5. THE System SHALL show duration in human-readable format (e.g., "2 jam 30 menit")
6. THE System SHALL show estimated cost with breakdown
7. THE System SHALL use card layout with white background and rounded corners (16px radius)
8. THE System SHALL apply consistent spacing (16-24px padding) for readability

### Requirement 8

**User Story:** As a Driver, I want to confirm my booking with a clear action button, so that I can complete the reservation process.

#### Acceptance Criteria

1. THE System SHALL provide "Konfirmasi Booking" button with purple gradient background (0xFF573ED1 to 0xFF6B4FE0)
2. THE System SHALL position button at bottom of page with fixed positioning
3. THE System SHALL disable button when required fields are incomplete or invalid
4. THE System SHALL display button with 56dp minimum height for accessibility
5. WHEN button is tapped, THE System SHALL validate all inputs before proceeding
6. THE System SHALL display loading indicator on button during booking creation
7. THE System SHALL apply shadow effect (elevation 8) to button for prominence

### Requirement 9

**User Story:** As a Driver, I want the system to create booking and transaction records when I confirm, so that my reservation is saved and tracked.

#### Acceptance Criteria

1. WHEN Driver confirms booking, THE System SHALL create transaksi_parkir record with jenis_transaksi='booking'
2. THE System SHALL create booking record linked to transaksi_parkir via id_transaksi
3. THE System SHALL generate unique QR code for booking verification
4. THE System SHALL allocate available parking slot and update parkiran status
5. THE System SHALL set booking status to 'aktif'
6. THE System SHALL record waktu_mulai, waktu_selesai, and durasi_booking
7. THE System SHALL calculate and store estimated biaya based on tarif_parkir
8. THE System SHALL execute database transaction atomically to ensure data consistency
9. WHEN booking creation fails, THE System SHALL rollback all changes and display error message

### Requirement 10

**User Story:** As a Driver, I want to receive confirmation after successful booking, so that I know my reservation is complete and can access booking details.

#### Acceptance Criteria

1. WHEN booking is created successfully, THE System SHALL display success dialog with checkmark animation
2. THE System SHALL show booking confirmation number (id_transaksi)
3. THE System SHALL display QR code for gate entry
4. THE System SHALL show booking details including slot code, time range, and cost
5. THE System SHALL provide "Lihat Aktivitas" button navigating to Activity Page
6. THE System SHALL provide "Selesai" button returning to Home Page
7. THE System SHALL send notification to Driver with booking details
8. THE System SHALL update Activity Page to display new active booking
9. THE System SHALL add booking to parking history

### Requirement 11

**User Story:** As a Driver, I want to see helpful error messages when booking fails, so that I can understand what went wrong and take corrective action.

#### Acceptance Criteria

1. WHEN network error occurs, THE System SHALL display "Koneksi internet bermasalah" with retry button
2. WHEN slots become unavailable during booking, THE System SHALL display "Slot tidak tersedia" and suggest alternative times
3. WHEN validation fails, THE System SHALL highlight invalid fields with red border and error text
4. WHEN server error occurs, THE System SHALL display "Terjadi kesalahan server" with support contact option
5. THE System SHALL use red color (0xFFF44336) for error indicators
6. THE System SHALL display error messages in Snackbar at bottom of screen
7. THE System SHALL auto-dismiss error messages after 4 seconds unless action is required

### Requirement 12

**User Story:** As a Driver, I want the Booking Page to follow the app's design system, so that the experience is consistent with other pages.

#### Acceptance Criteria

1. THE System SHALL use purple primary color (0xFF573ED1) for buttons, accents, and highlights
2. THE System SHALL use white background (0xFFFFFFFF) for main content area
3. THE System SHALL use grey shade 50 (Colors.grey.shade50) for section backgrounds
4. THE System SHALL apply rounded corners (12-16px radius) to all cards and containers
5. THE System SHALL use subtle shadows (elevation 2-4, blur 8-12px, offset 0,2) for depth
6. THE System SHALL use consistent typography (16-18px for body, 20-24px for headers, 14px for captions)
7. THE System SHALL apply 16-24px padding for content spacing
8. THE System SHALL use icons from Material Icons library
9. THE System SHALL ensure minimum 48dp touch target size for all interactive elements

### Requirement 13

**User Story:** As a Driver, I want the Booking Page to be responsive and performant, so that I can complete bookings quickly on any device.

#### Acceptance Criteria

1. THE System SHALL load booking page within 2 seconds on average network conditions
2. THE System SHALL display shimmer loading placeholders during data fetch
3. THE System SHALL cache mall and vehicle data to reduce API calls
4. THE System SHALL debounce duration changes to prevent excessive cost recalculations
5. THE System SHALL optimize image loading with lazy loading and caching
6. THE System SHALL handle orientation changes without losing form data
7. THE System SHALL support screen sizes from 320px to 768px width
8. THE System SHALL maintain 60fps scroll performance
9. THE System SHALL limit API calls to essential operations only

### Requirement 14

**User Story:** As a Driver, I want the Booking Page to be accessible, so that all users including those with disabilities can use the feature.

#### Acceptance Criteria

1. THE System SHALL provide semantic labels for all interactive elements
2. THE System SHALL ensure minimum 4.5:1 color contrast ratio for text
3. THE System SHALL support screen reader navigation with proper focus order
4. THE System SHALL provide haptic feedback for button taps
5. THE System SHALL display error messages with both color and text indicators
6. THE System SHALL allow font scaling up to 200% without breaking layout
7. THE System SHALL provide alternative text for all icons and images
8. THE System SHALL ensure all touch targets meet 48dp minimum size requirement

### Requirement 15

**User Story:** As a Developer, I want the Booking Page to integrate with existing architecture, so that the implementation follows clean architecture principles and is maintainable.

#### Acceptance Criteria

1. THE System SHALL create BookingProvider in lib/logic/providers for state management
2. THE System SHALL create BookingService in lib/data/services for API communication
3. THE System SHALL create BookingModel in lib/data/models for data representation
4. THE System SHALL use existing ParkingService for slot availability checks
5. THE System SHALL use existing VehicleService for vehicle data fetching
6. THE System SHALL implement proper error handling with try-catch blocks
7. THE System SHALL dispose controllers and timers in dispose() method
8. THE System SHALL use Provider pattern for dependency injection
9. THE System SHALL write unit tests for business logic with minimum 80% coverage
10. THE System SHALL write widget tests for UI components
11. THE System SHALL follow Dart style guide and Flutter best practices
12. THE System SHALL document public APIs with dartdoc comments

