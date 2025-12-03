# Requirements Document

## Introduction

Sistem QPARKIN saat ini memiliki halaman peta (map_page.dart) yang menampilkan placeholder untuk peta lokasi parkir. Fitur ini perlu diimplementasikan menggunakan OpenStreetMap (OSM) untuk memberikan pengalaman navigasi yang lengkap kepada pengguna dalam mencari dan menuju lokasi parkir mall.

Integrasi peta OSM akan memungkinkan pengguna untuk:
- Melihat lokasi mall pada peta interaktif
- Mendapatkan rute dari lokasi mereka ke mall tujuan
- Melihat estimasi jarak dan waktu tempuh
- Bernavigasi dengan mudah antara daftar mall dan tampilan peta

## Glossary

- **OSM (OpenStreetMap)**: Platform peta open-source yang menyediakan data peta global
- **flutter_osm_plugin**: Package Flutter untuk mengintegrasikan OpenStreetMap
- **Marker**: Pin atau penanda lokasi pada peta
- **Polyline**: Garis yang menghubungkan dua titik pada peta untuk menampilkan rute
- **Geolocation**: Proses mendapatkan koordinat geografis (latitude, longitude) dari perangkat
- **Mall**: Pusat perbelanjaan yang menyediakan fasilitas parkir
- **Driver**: Pengguna aplikasi QPARKIN yang mencari lokasi parkir
- **Tab Navigation**: Sistem navigasi dengan tab untuk beralih antara tampilan peta dan daftar
- **Current Location**: Lokasi pengguna saat ini berdasarkan GPS perangkat
- **Route**: Jalur perjalanan dari lokasi pengguna ke mall tujuan

## Requirements

### Requirement 1

**User Story:** As a driver, I want to view parking mall locations on an interactive map, so that I can visualize where parking facilities are located relative to my position.

#### Acceptance Criteria

1. WHEN the driver opens the map tab THEN the system SHALL display an interactive OpenStreetMap with zoom and pan controls
2. WHEN mall data is available THEN the system SHALL display markers for each mall location on the map
3. WHEN the driver taps on a mall marker THEN the system SHALL display mall information including name, address, and available parking slots
4. WHEN the map loads THEN the system SHALL center the view on the driver's current location or a default location if permission is denied
5. WHILE the driver interacts with the map THEN the system SHALL maintain smooth performance with frame rate above 30 FPS

### Requirement 2

**User Story:** As a driver, I want to see my current location on the map, so that I can understand my position relative to available parking locations.

#### Acceptance Criteria

1. WHEN the app requests location permission THEN the system SHALL display a permission dialog with clear explanation
2. IF location permission is granted THEN the system SHALL display the driver's current location with a distinct marker on the map
3. WHEN the driver taps the "My Location" button THEN the system SHALL center the map on the driver's current location with appropriate zoom level
4. IF location permission is denied THEN the system SHALL display an informative message and continue to function with default location
5. WHILE location services are active THEN the system SHALL update the driver's position marker when location changes significantly (more than 10 meters)

### Requirement 3

**User Story:** As a driver, I want to navigate from the mall list to the map view with the selected mall highlighted, so that I can quickly see the mall's location and plan my route.

#### Acceptance Criteria

1. WHEN the driver taps a mall card in the "Daftar Mall" tab THEN the system SHALL automatically switch to the "Peta" tab
2. WHEN switching to the map tab THEN the system SHALL center the map on the selected mall location
3. WHEN a mall is selected THEN the system SHALL display the mall's marker with a distinct highlight or animation
4. WHEN the driver taps "Rute" button on a mall card THEN the system SHALL switch to map tab and display the route to that mall
5. WHEN the map displays a selected mall THEN the system SHALL show an information card overlay with mall details

### Requirement 4

**User Story:** As a driver, I want to see the route from my current location to a selected mall, so that I can navigate to the parking facility efficiently.

#### Acceptance Criteria

1. WHEN the driver selects a mall and location permission is granted THEN the system SHALL calculate and display a route from current location to the mall
2. WHEN a route is displayed THEN the system SHALL draw a polyline on the map showing the path from origin to destination
3. WHEN a route is calculated THEN the system SHALL display estimated distance in kilometers
4. WHEN a route is calculated THEN the system SHALL display estimated travel time in minutes
5. IF route calculation fails THEN the system SHALL display an error message and allow the driver to retry

### Requirement 5

**User Story:** As a driver, I want the map to handle errors gracefully, so that I can continue using the app even when network or GPS issues occur.

#### Acceptance Criteria

1. IF the device has no internet connection THEN the system SHALL display a clear error message indicating network unavailability
2. IF GPS is disabled THEN the system SHALL display a message prompting the driver to enable location services
3. IF map tiles fail to load THEN the system SHALL display a retry button and maintain app stability
4. WHEN an error occurs THEN the system SHALL log the error details for debugging purposes
5. IF location permission is permanently denied THEN the system SHALL provide instructions to enable it in device settings

### Requirement 6

**User Story:** As a driver, I want the map interface to be intuitive and responsive, so that I can interact with it easily while planning my parking.

#### Acceptance Criteria

1. WHEN the driver performs zoom gestures THEN the system SHALL respond smoothly with zoom levels between 5 and 20
2. WHEN the driver pans the map THEN the system SHALL update the view without lag or stuttering
3. WHEN the driver taps UI controls THEN the system SHALL provide visual feedback within 100 milliseconds
4. WHEN the map is loading THEN the system SHALL display a loading indicator to inform the driver
5. WHEN the driver rotates the device THEN the system SHALL maintain map state and selected mall information

### Requirement 7

**User Story:** As a system, I want to use dummy coordinate data for malls during development, so that the map feature can be tested before backend integration is complete.

#### Acceptance Criteria

1. WHEN the app initializes THEN the system SHALL load mall coordinates from a local data source
2. WHEN displaying malls THEN the system SHALL use hardcoded latitude and longitude values for each mall
3. WHEN the data structure is defined THEN the system SHALL include fields for id, name, address, latitude, longitude, and available slots
4. WHEN the code is written THEN the system SHALL include comments indicating where API integration will replace dummy data
5. WHEN dummy data is used THEN the system SHALL include at least 5 different mall locations with realistic coordinates for Batam area

### Requirement 8

**User Story:** As a developer, I want the map implementation to be extensible, so that it can easily integrate with the backend API in the future.

#### Acceptance Criteria

1. WHEN the code is structured THEN the system SHALL separate data fetching logic from UI rendering logic
2. WHEN state management is implemented THEN the system SHALL use Provider, Riverpod, Bloc, or GetX pattern consistently
3. WHEN the map controller is created THEN the system SHALL expose methods for adding markers, drawing routes, and updating camera position
4. WHEN the code is documented THEN the system SHALL include clear comments explaining integration points for API calls
5. WHEN the architecture is designed THEN the system SHALL follow Flutter best practices for separation of concerns
