# Requirements Document

## Introduction

This specification defines the requirements for enhancing the Booking Page in the QPARKIN mobile application with two major UX/UI improvements:

1. **Hybrid Slot Reservation Feature**: Adding floor selection and visual slot availability display with system-based random slot locking
2. **Modern Time & Duration Design**: Redesigning the time and duration picker with a unified card layout and improved interaction patterns

These enhancements align with the SKPPL documentation's vision for a comprehensive booking system (F002) while providing guaranteed slot reservation through system-controlled allocation in a simulation environment.

## Glossary

- **System**: The QPARKIN mobile application Booking Page module
- **Driver**: The end user (customer) who books parking slots
- **Lantai Parkir**: Parking floor/level within a mall parking structure
- **Slot Parkir**: A specific parking space with unique identifier (kode_slot)
- **Slot Map**: Visual representation of parking slots showing availability status (non-interactive)
- **Slot Grid**: Visual grid layout displaying slot availability per floor (display-only)
- **Random Slot Locking**: System automatically assigns and locks a specific available slot
- **Unified Card**: Single card component containing both time and duration selectors
- **Interactive Chip**: Larger, more prominent selection button for duration options
- **Date Picker**: Calendar-based interface for selecting booking date and time

## Requirements

### Requirement 1: Floor Selection Interface

**User Story:** As a Driver, I want to select which parking floor I prefer, so that I can choose a convenient location within the mall parking structure.

#### Acceptance Criteria

1. WHEN Driver reaches slot selection step, THE System SHALL display list of available parking floors
2. THE System SHALL show available slot count for each floor in real-time
3. THE System SHALL display floor information including floor number/name and total capacity
4. THE System SHALL highlight floors with available slots in green and unavailable floors in grey
5. THE System SHALL sort floors by availability (most available first) or by floor number
6. THE System SHALL use card-based layout with 16px rounded corners and elevation 2
7. THE System SHALL apply purple accent (0xFF573ED1) to selected floor
8. WHEN Driver selects a floor, THE System SHALL expand to show slot selection interface
9. THE System SHALL validate that selected floor has available slots before proceeding

### Requirement 2: Visual Slot Availability Display (Non-Interactive)

**User Story:** As a Driver, I want to see current slot availability visually, so that I can understand the parking situation before requesting a random slot reservation.

#### Acceptance Criteria

1. WHEN Driver selects a floor, THE System SHALL display slot availability visualization
2. THE System SHALL provide visual grid layout representing slot positions (4-6 columns)
3. THE System SHALL color-code slots: Green (available), Grey (occupied), Yellow (reserved), Red (disabled)
4. THE System SHALL display slot code (e.g., "A01", "B15") on each slot for reference
5. THE System SHALL show slot type indicator (Regular, Disable-friendly) with icons
6. THE System SHALL NOT allow user interaction with individual slots (display-only)
7. THE System SHALL NOT provide tap/click functionality on slot cards
8. THE System SHALL update slot availability in real-time (every 15 seconds)
9. THE System SHALL provide "Refresh" button to manually update slot availability
10. THE System SHALL display total available slots count above the grid
11. THE System SHALL show last updated timestamp for transparency

### Requirement 3: Random Slot Reservation System

**User Story:** As a Driver, I want the system to automatically reserve a specific slot for me on my chosen floor, so that I have guaranteed parking without manual selection complexity.

#### Acceptance Criteria

1. THE System SHALL provide "Pesan Slot Acak di [Nama Lantai]" button below slot visualization
2. THE System SHALL validate floor selection and slot availability before processing
3. WHEN Driver taps reservation button, THE System SHALL call backend to lock a random available slot
4. THE System SHALL display loading indicator during slot reservation process
5. THE System SHALL receive specific slot assignment (e.g., "L1-A12") from backend
6. THE System SHALL display reserved slot information in booking summary
7. THE System SHALL include reserved slot details in QR code data for gate verification
8. THE System SHALL show reserved slot in booking confirmation dialog
9. THE System SHALL display reserved slot location in Activity Page for active bookings
10. WHEN no slots available during reservation, THE System SHALL notify user and suggest alternative floors
11. THE System SHALL implement 5-minute reservation timeout to prevent slot hoarding
12. THE System SHALL release reserved slot if booking is not completed within timeout

### Requirement 4: Modern Time & Duration Unified Card

**User Story:** As a Driver, I want a modern, intuitive interface for selecting booking time and duration, so that I can quickly set my parking schedule.

#### Acceptance Criteria

1. THE System SHALL combine time and duration selection in a single unified card
2. THE System SHALL use white background with 16px rounded corners and elevation 3
3. THE System SHALL apply 20-24px padding for comfortable spacing
4. THE System SHALL display "Waktu & Durasi Booking" as card header (18px bold)
5. THE System SHALL organize content in vertical layout with clear visual hierarchy
6. THE System SHALL use purple accent (0xFF573ED1) for selected states and icons
7. THE System SHALL maintain consistent spacing (16px) between sections
8. THE System SHALL display calculated end time prominently at bottom of card
9. THE System SHALL animate transitions between states (300ms ease-in-out)

### Requirement 5: Enhanced Date & Time Picker

**User Story:** As a Driver, I want an improved date and time picker, so that I can easily select my preferred booking start time.

#### Acceptance Criteria

1. THE System SHALL display current selected date and time in large, readable format (20px bold)
2. THE System SHALL show date in format "Senin, 15 Januari 2025" (day name, date, month, year)
3. THE System SHALL show time in format "14:30" (24-hour format)
4. THE System SHALL use calendar icon (24px, purple) next to date/time display
5. WHEN Driver taps date/time section, THE System SHALL open Material date picker
6. THE System SHALL use purple theme for date picker dialog
7. AFTER date selection, THE System SHALL automatically open time picker
8. THE System SHALL validate selected time is not in the past
9. THE System SHALL default to current time + 15 minutes if no time selected
10. THE System SHALL display validation error below picker if time is invalid
11. THE System SHALL provide "Sekarang + 15 menit" quick action button

### Requirement 6: Improved Duration Selector with Large Chips

**User Story:** As a Driver, I want larger, more prominent duration selection buttons, so that I can easily tap my preferred parking duration.

#### Acceptance Criteria

1. THE System SHALL display duration options as large interactive chips
2. THE System SHALL use chip size of minimum 80px width × 56px height for easy tapping
3. THE System SHALL provide preset durations: 1 Jam, 2 Jam, 3 Jam, 4 Jam, > 4 Jam
4. THE System SHALL arrange chips in horizontal scrollable row with 12px spacing
5. THE System SHALL apply purple background (0xFF573ED1) to selected chip
6. THE System SHALL apply light purple background (0xFFE8E0FF) to unselected chips
7. THE System SHALL use white text (16px bold) for selected chip
8. THE System SHALL use purple text (16px bold) for unselected chips
9. THE System SHALL add checkmark icon to selected chip
10. WHEN "> 4 Jam" is selected, THE System SHALL open custom duration dialog
11. THE System SHALL display selected duration prominently below chips (e.g., "Durasi: 2 jam")
12. THE System SHALL animate chip selection with scale effect (scale to 1.05 on tap)
13. THE System SHALL provide haptic feedback on chip selection

### Requirement 7: Calculated End Time Display

**User Story:** As a Driver, I want to see the calculated end time clearly displayed, so that I know exactly when my booking expires.

#### Acceptance Criteria

1. THE System SHALL calculate end time as start time + duration
2. THE System SHALL display end time in prominent container at bottom of unified card
3. THE System SHALL use light purple background (0xFFE8E0FF) for end time container
4. THE System SHALL display end time in format "Selesai: Senin, 15 Jan 2025 - 16:30"
5. THE System SHALL use purple text (16px bold) for end time
6. THE System SHALL include clock icon (20px, purple) next to end time
7. THE System SHALL update end time automatically when start time or duration changes
8. THE System SHALL animate end time changes with fade transition (200ms)
9. THE System SHALL display duration summary (e.g., "Total: 2 jam") below end time

### Requirement 8: Responsive Layout for Unified Card

**User Story:** As a Driver, I want the time and duration card to work well on different screen sizes, so that I have a consistent experience across devices.

#### Acceptance Criteria

1. THE System SHALL adapt card layout for screen widths from 320px to 768px
2. ON small screens (< 375px), THE System SHALL use 16px padding and 14px font sizes
3. ON medium screens (375-414px), THE System SHALL use 20px padding and 16px font sizes
4. ON large screens (> 414px), THE System SHALL use 24px padding and 18px font sizes
5. THE System SHALL stack duration chips vertically on very small screens (< 360px)
6. THE System SHALL maintain minimum 48dp touch target size for all interactive elements
7. THE System SHALL ensure text remains readable at 200% font scaling
8. THE System SHALL preserve card proportions in landscape orientation

### Requirement 9: Accessibility for Enhanced Components

**User Story:** As a Driver with accessibility needs, I want the new slot selection and time/duration features to be fully accessible, so that I can use them with assistive technologies.

#### Acceptance Criteria

1. THE System SHALL provide semantic labels for all floor and slot selection elements
2. THE System SHALL announce slot availability status to screen readers
3. THE System SHALL support keyboard navigation for slot grid (arrow keys)
4. THE System SHALL provide clear focus indicators (2px purple border) for all interactive elements
5. THE System SHALL announce selected slot information to screen readers
6. THE System SHALL ensure 4.5:1 minimum contrast ratio for all text and icons
7. THE System SHALL provide alternative text for slot status colors (not color-only indicators)
8. THE System SHALL support screen reader navigation through duration chips
9. THE System SHALL announce calculated end time changes to screen readers
10. THE System SHALL provide haptic feedback for all selections

### Requirement 10: Slot Reservation Data Models

**User Story:** As a Developer, I want proper data models for slot reservation, so that slot information is structured and type-safe.

#### Acceptance Criteria

1. THE System SHALL create ParkingFloorModel in lib/data/models/
2. THE System SHALL create ParkingSlotModel in lib/data/models/ (for display purposes)
3. THE System SHALL create SlotReservationModel in lib/data/models/
4. THE System SHALL include floor properties: id, floorNumber, floorName, totalSlots, availableSlots
5. THE System SHALL include slot properties: id, slotCode, floorId, status, slotType (for visualization)
6. THE System SHALL include reservation properties: reservationId, slotId, slotCode, floorName, expiresAt
7. THE System SHALL define SlotStatus enum: available, occupied, reserved, disabled
8. THE System SHALL define SlotType enum: regular, disableFriendly
9. THE System SHALL implement fromJson() and toJson() methods for API integration
10. THE System SHALL include validation methods for slot reservation

### Requirement 11: Slot Reservation API Integration

**User Story:** As a Developer, I want API endpoints for slot reservation, so that floor data is fetched and random slots are reserved by the backend.

#### Acceptance Criteria

1. THE System SHALL create getFloors() method in BookingService
2. THE System SHALL create getSlotsForVisualization() method in BookingService
3. THE System SHALL create reserveRandomSlot() method in BookingService
4. THE System SHALL implement GET /api/parking/floors/{mallId} endpoint call
5. THE System SHALL implement GET /api/parking/slots/{floorId}/visualization endpoint call
6. THE System SHALL implement POST /api/parking/slots/reserve-random endpoint call
7. THE System SHALL include authentication token in all API calls
8. THE System SHALL handle network errors with retry logic (max 2 retries)
9. THE System SHALL cache floor data for 5 minutes to reduce API calls
10. THE System SHALL implement real-time slot status updates via polling (every 15 seconds)

### Requirement 12: Slot Reservation State Management

**User Story:** As a Developer, I want proper state management for slot reservation, so that reservation data is reactive and consistent.

#### Acceptance Criteria

1. THE System SHALL add floor selection state to BookingProvider
2. THE System SHALL add slot visualization state to BookingProvider
3. THE System SHALL add slot reservation state to BookingProvider
4. THE System SHALL implement selectFloor() method in BookingProvider
5. THE System SHALL implement refreshSlotVisualization() method in BookingProvider
6. THE System SHALL implement reserveRandomSlot() method in BookingProvider
7. THE System SHALL validate floor selection before reservation
8. THE System SHALL clear reservation when floor changes
9. THE System SHALL update booking request to include reserved slot ID
10. THE System SHALL notify listeners when reservation changes
11. THE System SHALL handle reservation timeout gracefully with user notification

### Requirement 13: Visual Design Consistency

**User Story:** As a Driver, I want the new features to match the existing app design, so that the experience feels cohesive.

#### Acceptance Criteria

1. THE System SHALL use purple primary color (0xFF573ED1) consistently
2. THE System SHALL use white background (0xFFFFFFFF) for cards
3. THE System SHALL apply 16px rounded corners to all cards
4. THE System SHALL use elevation 2-4 for card shadows
5. THE System SHALL use consistent icon sizes (20-24px)
6. THE System SHALL apply 16-24px padding for content spacing
7. THE System SHALL use consistent typography (16-18px body, 20-24px headers)
8. THE System SHALL maintain existing color palette for status indicators
9. THE System SHALL use consistent animation durations (200-300ms)
10. THE System SHALL follow Material Design 3 guidelines

### Requirement 14: Performance Optimization

**User Story:** As a Driver, I want slot selection and time/duration features to load quickly, so that I can complete bookings without delays.

#### Acceptance Criteria

1. THE System SHALL load floor list within 1 second
2. THE System SHALL load slot grid within 1.5 seconds
3. THE System SHALL cache floor and slot data for 5 minutes
4. THE System SHALL use lazy loading for slot grid (load visible slots first)
5. THE System SHALL debounce slot refresh requests (500ms)
6. THE System SHALL optimize slot grid rendering with ListView.builder
7. THE System SHALL limit slot status polling to active booking session only
8. THE System SHALL cancel pending API calls when user navigates away
9. THE System SHALL use shimmer loading placeholders for slot grid
10. THE System SHALL maintain 60fps scroll performance in slot list

### Requirement 15: Error Handling for Slot Reservation

**User Story:** As a Driver, I want clear error messages when slot reservation fails, so that I understand what went wrong and how to fix it.

#### Acceptance Criteria

1. WHEN floor data fails to load, THE System SHALL display "Gagal memuat data lantai" with retry button
2. WHEN slot visualization fails to load, THE System SHALL display "Gagal memuat tampilan slot" with retry button
3. WHEN no slots available for reservation, THE System SHALL notify "Tidak ada slot tersedia di lantai ini" and suggest alternatives
4. WHEN network error occurs, THE System SHALL display "Koneksi internet bermasalah" with retry
5. WHEN slot reservation fails, THE System SHALL display "Gagal mereservasi slot" and allow retry
6. WHEN reservation timeout occurs, THE System SHALL display "Waktu reservasi habis" and allow new reservation
7. THE System SHALL use red color (0xFFF44336) for error indicators
8. THE System SHALL display errors in Snackbar with action buttons
9. THE System SHALL log errors for debugging without exposing technical details to user
10. THE System SHALL provide fallback to alternative floors if current floor becomes unavailable

### Requirement 16: Testing Requirements

**User Story:** As a Developer, I want comprehensive tests for new features, so that slot selection and time/duration enhancements are reliable.

#### Acceptance Criteria

1. THE System SHALL include unit tests for ParkingFloorModel and ParkingSlotModel
2. THE System SHALL include unit tests for slot selection methods in BookingProvider
3. THE System SHALL include widget tests for FloorSelectorWidget
4. THE System SHALL include widget tests for SlotGridWidget
5. THE System SHALL include widget tests for UnifiedTimeDurationCard
6. THE System SHALL include integration tests for complete slot selection flow
7. THE System SHALL include integration tests for time/duration selection flow
8. THE System SHALL test error scenarios (slot unavailable, network failure)
9. THE System SHALL test accessibility features with screen reader simulation
10. THE System SHALL achieve minimum 80% code coverage for new components

### Requirement 17: Migration and Backward Compatibility

**User Story:** As a Developer, I want smooth migration to new features, so that existing bookings continue to work during rollout.

#### Acceptance Criteria

1. THE System SHALL support bookings without slot selection (automatic assignment) during transition
2. THE System SHALL add slot_id field to booking table as nullable initially
3. THE System SHALL update existing booking flow to work with or without slot selection
4. THE System SHALL provide feature flag to enable/disable slot selection per mall
5. THE System SHALL maintain API compatibility with old booking request format
6. THE System SHALL handle missing slot data gracefully in booking history
7. THE System SHALL provide migration script for existing bookings
8. THE System SHALL document API changes in booking_api_documentation.md
9. THE System SHALL update booking_user_guide.md with slot selection instructions

