# Requirements Document

## Introduction

This specification defines the requirements for enhancing the Activity Page (Tab Aktivitas) in the QPARKIN mobile application to display real-time active parking details based on booking and transaction data. The enhancement aligns with Use Cases UC-003 (Booking Slot Parkir) and UC-004 (Parkir Selesai) from the SKPPL documentation, providing drivers with comprehensive visibility into their active parking sessions.

## Glossary

- **System**: The QPARKIN mobile application Activity Page module
- **Driver**: The end user (customer) who parks their vehicle using the QPARKIN app
- **Booking**: A reservation record for a parking slot with scheduled start and end times
- **TransaksiParkir**: A parking transaction record that tracks entry time, exit time, duration, and costs
- **QR Code**: Quick Response code used for check-in and check-out at parking gates
- **Real-time Timer**: A continuously updating display showing elapsed or remaining parking duration
- **Slot Parkir**: A specific parking space identified by id_parkiran and kodeSlot
- **Biaya Parkir Berjalan**: The current estimated parking cost calculated in real-time based on elapsed duration
- **Penalty**: Additional charges automatically calculated when parking duration exceeds booking time limit

## Requirements

### Requirement 1

**User Story:** As a Driver, I want to see my active parking session details on the Activity Page, so that I can monitor my current parking status and costs in real-time.

#### Acceptance Criteria

1. WHEN THE System loads the Activity Tab, THE System SHALL fetch active booking and transaction data from the database for the authenticated Driver
2. WHEN active parking data exists, THE System SHALL display a detailed card showing location, vehicle information, and parking status
3. WHEN no active parking exists, THE System SHALL display an empty state message with appropriate iconography
4. THE System SHALL preserve the existing header "Aktivitas & Riwayat" and tab navigation structure
5. THE System SHALL apply design changes only to content below the tab navigation bar

### Requirement 2

**User Story:** As a Driver, I want to see a real-time timer showing my parking duration, so that I can track how long I have been parked and estimate my costs.

#### Acceptance Criteria

1. WHEN active parking is displayed, THE System SHALL show a timer component that updates every second
2. THE System SHALL calculate elapsed parking duration from waktu_masuk timestamp to current time
3. WHEN booking exists, THE System SHALL display remaining booking duration from current time to waktuSelesaiEstimas
4. THE System SHALL format timer display as "HH:MM:SS" with labels "Jam : Menit : Detik"
5. THE System SHALL display the timer within a purple gradient container (Color 0xFF573ED1 to 0xFF7C3AED)

### Requirement 3

**User Story:** As a Driver, I want to see essential booking and transaction details in a card format, so that I can quickly access important information about my parking session.

#### Acceptance Criteria

1. THE System SHALL display QR Code for check-out from the booking table qrCode field
2. THE System SHALL display parking location including nama_mall from mall table
3. THE System SHALL display id_parkiran and kodeSlot from parkiran table
4. THE System SHALL display plat nomor and jenis_kendaraan from kendaraan table
5. THE System SHALL display waktu_masuk formatted as time string
6. THE System SHALL display waktuSelesaiEstimas from booking table
7. THE System SHALL calculate and display real-time estimated parking cost based on elapsed duration and tarif_parkir
8. THE System SHALL display parking status indicator showing "Parkir Aktif" or "Booking Aktif"
9. WHEN current time exceeds waktuSelesaiEstimas, THE System SHALL calculate and display penalty charges automatically
10. THE System SHALL highlight penalty amount in warning color when applicable

### Requirement 4

**User Story:** As a Driver, I want to see an action button to generate my exit QR code, so that I can complete my parking session and exit the parking area.

#### Acceptance Criteria

1. THE System SHALL provide a "QR Keluar" button with purple background (Color 0xFF573ED1)
2. WHEN Driver taps "QR Keluar", THE System SHALL display the QR code for gate exit
3. THE System SHALL enable the button only when active parking session exists
4. THE System SHALL display the button prominently below the timer component
5. WHEN booking duration is exceeded, THE System SHALL display penalty warning alongside the button

### Requirement 5

**User Story:** As a Driver, I want to see detailed parking information cards, so that I can view start time and duration at a glance.

#### Acceptance Criteria

1. THE System SHALL display a "Waktu Mulai" card with blue icon showing waktu_masuk time
2. THE System SHALL display a "Durasi" card with orange icon showing elapsed duration
3. THE System SHALL format duration display as human-readable text (e.g., "2 jam 15 menit")
4. THE System SHALL arrange detail cards in a horizontal row layout
5. THE System SHALL apply consistent styling with white background, rounded corners, and subtle shadows

### Requirement 6

**User Story:** As a Developer, I want the Activity Page to integrate with existing data models and services, so that the implementation follows clean architecture principles.

#### Acceptance Criteria

1. THE System SHALL use existing data models from lib/data/models directory
2. THE System SHALL create or utilize providers from lib/logic/providers for state management
3. THE System SHALL fetch data through services defined in lib/data/services
4. THE System SHALL handle loading states with appropriate UI feedback
5. THE System SHALL handle error states with user-friendly error messages
6. THE System SHALL implement proper disposal of timers and controllers to prevent memory leaks

### Requirement 7

**User Story:** As a Driver, I want the Activity Page to update automatically when my parking status changes, so that I always see current information.

#### Acceptance Criteria

1. WHEN parking session starts (check-in), THE System SHALL refresh Activity Page data
2. WHEN booking is created, THE System SHALL update Activity Page to show new booking
3. WHEN parking session ends (check-out), THE System SHALL remove active parking display
4. THE System SHALL implement periodic data refresh every 30 seconds for status synchronization
5. THE System SHALL maintain timer accuracy independent of data refresh cycles
