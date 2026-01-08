import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

/// Model representing a mall with parking facilities.
/// 
/// Contains all information needed to display a mall on the map and in lists,
/// including location coordinates, name, address, and parking availability.
/// 
/// This model is used throughout the app for:
/// - Displaying mall markers on the map
/// - Showing mall information in lists
/// - Calculating routes to malls
/// - Tracking parking availability
/// 
/// Example:
/// ```dart
/// final mall = MallModel(
///   id: '1',
///   name: 'Mega Mall Batam Centre',
///   address: 'Jl. Engku Putri no.1, Batam Centre',
///   latitude: 1.1191,
///   longitude: 104.0538,
///   availableSlots: 45,
/// );
/// 
/// // Use with map
/// final geoPoint = mall.geoPoint;
/// await mapController.addMarker(geoPoint);
/// 
/// // Check availability
/// if (mall.hasAvailableSlots) {
///   print('${mall.formattedAvailableSlots}');
/// }
/// ```
class MallModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int availableSlots;
  final String distance;
  final bool hasSlotReservationEnabled;
  final String? googleMapsUrl;  // Tambah field untuk navigasi eksternal

  MallModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.availableSlots,
    this.distance = '',
    this.hasSlotReservationEnabled = false,
    this.googleMapsUrl,  // Tambah parameter
  });

  /// Convert latitude and longitude to [GeoPoint] for OSM plugin.
  /// 
  /// Returns a [GeoPoint] object that can be used with flutter_osm_plugin
  /// for map operations like adding markers or calculating routes.
  /// 
  /// Example:
  /// ```dart
  /// final mall = MallModel(...);
  /// await mapController.addMarker(mall.geoPoint);
  /// ```
  GeoPoint get geoPoint => GeoPoint(latitude: latitude, longitude: longitude);

  /// Check if mall has available parking slots.
  /// 
  /// Returns `true` if [availableSlots] is greater than 0, `false` otherwise.
  /// 
  /// Example:
  /// ```dart
  /// if (mall.hasAvailableSlots) {
  ///   print('Parking available!');
  /// }
  /// ```
  bool get hasAvailableSlots => availableSlots > 0;

  /// Get formatted available slots string in Indonesian.
  /// 
  /// Returns a user-friendly string describing parking availability:
  /// - "Penuh" if no slots available
  /// - "1 slot tersedia" if exactly 1 slot
  /// - "X slot tersedia" for multiple slots
  /// 
  /// Example:
  /// ```dart
  /// print(mall.formattedAvailableSlots); // "45 slot tersedia"
  /// ```
  String get formattedAvailableSlots {
    if (availableSlots == 0) {
      return 'Penuh';
    } else if (availableSlots == 1) {
      return '1 slot tersedia';
    } else {
      return '$availableSlots slot tersedia';
    }
  }

  /// Validate mall data.
  /// 
  /// Checks that all required fields are present and valid:
  /// - ID is not empty
  /// - Name is not empty
  /// - Address is not empty
  /// - Latitude is in valid range (-90 to 90)
  /// - Longitude is in valid range (-180 to 180)
  /// - Available slots is not negative
  /// 
  /// Returns:
  ///   `true` if all validation checks pass, `false` otherwise.
  /// 
  /// Example:
  /// ```dart
  /// final mall = MallModel.fromJson(jsonData);
  /// if (!mall.validate()) {
  ///   print('Invalid mall data');
  /// }
  /// ```
  bool validate() {
    if (id.isEmpty) return false;
    if (name.isEmpty) return false;
    if (address.isEmpty) return false;
    if (latitude < -90 || latitude > 90) return false;
    if (longitude < -180 || longitude > 180) return false;
    if (availableSlots < 0) return false;
    return true;
  }

  /// Create MallModel from JSON
  /// 
  /// TODO: API Integration - Parse coordinates from alamat_gmaps field
  /// 
  /// Expected API response format from GET /api/malls:
  /// ```json
  /// {
  ///   "id_mall": "1",
  ///   "nama_mall": "Mega Mall Batam Centre",
  ///   "lokasi": "Jl. Engku Putri no.1, Batam Centre",
  ///   "alamat_gmaps": "https://maps.google.com/?q=1.1191,104.0538",
  ///   "kapasitas": 45
  /// }
  /// ```
  /// 
  /// The alamat_gmaps field contains a Google Maps URL with coordinates.
  /// Parse this URL to extract latitude and longitude:
  /// 
  /// Example parsing logic:
  /// ```dart
  /// static (double, double) _parseGoogleMapsUrl(String url) {
  ///   final regex = RegExp(r'q=(-?\d+\.?\d*),(-?\d+\.?\d*)');
  ///   final match = regex.firstMatch(url);
  ///   if (match != null) {
  ///     return (double.parse(match.group(1)!), double.parse(match.group(2)!));
  ///   }
  ///   return (0.0, 0.0);
  /// }
  /// ```
  /// 
  /// Current implementation uses direct latitude/longitude fields for dummy data.
  /// When API is integrated, uncomment the parsing logic above and use:
  /// ```dart
  /// final (lat, lng) = _parseGoogleMapsUrl(json['alamat_gmaps'] ?? '');
  /// latitude: lat,
  /// longitude: lng,
  /// ```
  factory MallModel.fromJson(Map<String, dynamic> json) {
    return MallModel(
      id: json['id']?.toString() ?? json['id_mall']?.toString() ?? '',
      name: json['name']?.toString() ?? json['nama_mall']?.toString() ?? '',
      address: json['address']?.toString() ?? json['lokasi']?.toString() ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      availableSlots: _parseInt(json['available_slots'] ?? json['kapasitas']),
      distance: json['distance']?.toString() ?? '',
      hasSlotReservationEnabled: json['has_slot_reservation_enabled'] == true ||
          json['has_slot_reservation_enabled'] == 1,
      googleMapsUrl: json['google_maps_url']?.toString(),  // Parse dari API
    );
  }

  /// Convert [MallModel] to JSON.
  /// 
  /// Serializes the mall data to a JSON-compatible map for API requests
  /// or local storage.
  /// 
  /// Returns:
  ///   A [Map] containing all mall properties as key-value pairs.
  /// 
  /// Example:
  /// ```dart
  /// final mall = MallModel(...);
  /// final json = mall.toJson();
  /// final jsonString = jsonEncode(json);
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'available_slots': availableSlots,
      'distance': distance,
      'has_slot_reservation_enabled': hasSlotReservationEnabled,
      'google_maps_url': googleMapsUrl,  // Tambah ke JSON
    };
  }

  /// Helper method to safely parse double values from JSON
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Helper method to safely parse int values from JSON
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Create a copy of this model with updated fields.
  /// 
  /// Returns a new [MallModel] instance with the same values as this instance,
  /// except for any fields explicitly provided as parameters.
  /// 
  /// Parameters:
  ///   All parameters are optional. Only provided parameters will be updated.
  /// 
  /// Returns:
  ///   A new [MallModel] with updated values.
  /// 
  /// Example:
  /// ```dart
  /// final mall = MallModel(...);
  /// final updatedMall = mall.copyWith(availableSlots: 30);
  /// // All other fields remain the same
  /// ```
  MallModel copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    int? availableSlots,
    String? distance,
    bool? hasSlotReservationEnabled,
    String? googleMapsUrl,  // Tambah parameter
  }) {
    return MallModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      availableSlots: availableSlots ?? this.availableSlots,
      distance: distance ?? this.distance,
      hasSlotReservationEnabled:
          hasSlotReservationEnabled ?? this.hasSlotReservationEnabled,
      googleMapsUrl: googleMapsUrl ?? this.googleMapsUrl,  // Tambah copy
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MallModel &&
        other.id == id &&
        other.name == name &&
        other.address == address &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.availableSlots == availableSlots &&
        other.distance == distance &&
        other.hasSlotReservationEnabled == hasSlotReservationEnabled &&
        other.googleMapsUrl == googleMapsUrl;  // Tambah comparison
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      address,
      latitude,
      longitude,
      availableSlots,
      distance,
      hasSlotReservationEnabled,
      googleMapsUrl,  // Tambah ke hash
    );
  }

  @override
  String toString() {
    return 'MallModel(id: $id, name: $name, address: $address, '
        'latitude: $latitude, longitude: $longitude, '
        'availableSlots: $availableSlots, distance: $distance, '
        'hasSlotReservationEnabled: $hasSlotReservationEnabled, '
        'googleMapsUrl: $googleMapsUrl)';  // Tambah ke string
  }
}
