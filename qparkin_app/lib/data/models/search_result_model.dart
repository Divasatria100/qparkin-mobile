import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

/// Model for search result from OSM Nominatim API
///
/// Represents a location search result with coordinates, display name,
/// and address details.
///
/// Requirements: 9.4
class SearchResultModel {
  /// Unique identifier for the place
  final String placeId;

  /// Display name of the location (full formatted address)
  final String displayName;

  /// Latitude coordinate
  final double latitude;

  /// Longitude coordinate
  final double longitude;

  /// Type of place (e.g., 'building', 'amenity', 'shop')
  final String? type;

  /// Specific category (e.g., 'mall', 'parking', 'restaurant')
  final String? category;

  /// Address details
  final SearchAddressDetails? address;

  /// Bounding box coordinates [minLat, maxLat, minLon, maxLon]
  final List<double>? boundingBox;

  SearchResultModel({
    required this.placeId,
    required this.displayName,
    required this.latitude,
    required this.longitude,
    this.type,
    this.category,
    this.address,
    this.boundingBox,
  });

  /// Convert to GeoPoint for map operations
  GeoPoint get geoPoint => GeoPoint(
        latitude: latitude,
        longitude: longitude,
      );

  /// Get short display name (first line of address)
  String get shortName {
    final parts = displayName.split(',');
    return parts.isNotEmpty ? parts.first.trim() : displayName;
  }

  /// Get address without the first line (remaining address)
  String get addressWithoutName {
    final parts = displayName.split(',');
    if (parts.length > 1) {
      return parts.sublist(1).join(',').trim();
    }
    return '';
  }

  /// Create from JSON response from Nominatim API
  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      placeId: json['place_id'].toString(),
      displayName: json['display_name'] as String,
      latitude: double.parse(json['lat'].toString()),
      longitude: double.parse(json['lon'].toString()),
      type: json['type'] as String?,
      category: json['class'] as String?,
      address: json['address'] != null
          ? SearchAddressDetails.fromJson(json['address'])
          : null,
      boundingBox: json['boundingbox'] != null
          ? (json['boundingbox'] as List)
              .map((e) => double.parse(e.toString()))
              .toList()
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'display_name': displayName,
      'lat': latitude.toString(),
      'lon': longitude.toString(),
      'type': type,
      'class': category,
      'address': address?.toJson(),
      'boundingbox': boundingBox?.map((e) => e.toString()).toList(),
    };
  }

  @override
  String toString() {
    return 'SearchResultModel(placeId: $placeId, displayName: $displayName, '
        'lat: $latitude, lon: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SearchResultModel &&
        other.placeId == placeId &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return placeId.hashCode ^ latitude.hashCode ^ longitude.hashCode;
  }
}

/// Address details from Nominatim API
class SearchAddressDetails {
  final String? road;
  final String? suburb;
  final String? city;
  final String? state;
  final String? postcode;
  final String? country;
  final String? countryCode;
  final String? building;
  final String? amenity;
  final String? shop;

  SearchAddressDetails({
    this.road,
    this.suburb,
    this.city,
    this.state,
    this.postcode,
    this.country,
    this.countryCode,
    this.building,
    this.amenity,
    this.shop,
  });

  factory SearchAddressDetails.fromJson(Map<String, dynamic> json) {
    return SearchAddressDetails(
      road: json['road'] as String?,
      suburb: json['suburb'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postcode: json['postcode'] as String?,
      country: json['country'] as String?,
      countryCode: json['country_code'] as String?,
      building: json['building'] as String?,
      amenity: json['amenity'] as String?,
      shop: json['shop'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'road': road,
      'suburb': suburb,
      'city': city,
      'state': state,
      'postcode': postcode,
      'country': country,
      'country_code': countryCode,
      'building': building,
      'amenity': amenity,
      'shop': shop,
    };
  }

  /// Get formatted address string
  String get formattedAddress {
    final parts = <String>[];
    if (road != null) parts.add(road!);
    if (suburb != null) parts.add(suburb!);
    if (city != null) parts.add(city!);
    if (state != null) parts.add(state!);
    return parts.join(', ');
  }
}
