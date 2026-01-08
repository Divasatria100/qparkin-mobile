# API Documentation - Mall Location Feature

## 📡 Endpoints

### 1. Get All Malls (with Location)

**Endpoint:** `GET /api/mall`

**Authentication:** Required (Bearer Token)

**Response:**
```json
{
  "success": true,
  "message": "Malls retrieved successfully",
  "data": [
    {
      "id_mall": 1,
      "nama_mall": "Grand Indonesia",
      "lokasi": "Jakarta Pusat",
      "latitude": -6.195396,
      "longitude": 106.822754,
      "google_maps_url": "https://www.google.com/maps/dir/?api=1&destination=-6.195396,106.822754",
      "status": "active",
      "kapasitas": 500,
      "available_slots": 120,
      "has_slot_reservation_enabled": true
    }
  ]
}
```

### 2. Get Single Mall Details (with Location)

**Endpoint:** `GET /api/mall/{id}`

**Authentication:** Required (Bearer Token)

**Response:**
```json
{
  "success": true,
  "message": "Mall details retrieved successfully",
  "data": {
    "id_mall": 1,
    "nama_mall": "Grand Indonesia",
    "lokasi": "Jakarta Pusat",
    "latitude": -6.195396,
    "longitude": 106.822754,
    "google_maps_url": "https://www.google.com/maps/dir/?api=1&destination=-6.195396,106.822754",
    "status": "active",
    "kapasitas": 500,
    "available_slots": 120,
    "has_slot_reservation_enabled": true,
    "parkiran": [...],
    "tarif": [...]
  }
}
```

## 📱 Flutter Integration Example

### 1. Model Update

```dart
// lib/data/models/mall_model.dart

class MallModel {
  final int idMall;
  final String namaMall;
  final String? lokasi;
  final double? latitude;
  final double? longitude;
  final String? googleMapsUrl;
  final String status;
  final int kapasitas;
  final int availableSlots;
  final bool hasSlotReservationEnabled;

  MallModel({
    required this.idMall,
    required this.namaMall,
    this.lokasi,
    this.latitude,
    this.longitude,
    this.googleMapsUrl,
    required this.status,
    required this.kapasitas,
    required this.availableSlots,
    required this.hasSlotReservationEnabled,
  });

  factory MallModel.fromJson(Map<String, dynamic> json) {
    return MallModel(
      idMall: json['id_mall'],
      namaMall: json['nama_mall'],
      lokasi: json['lokasi'],
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
      googleMapsUrl: json['google_maps_url'],
      status: json['status'],
      kapasitas: json['kapasitas'],
      availableSlots: json['available_slots'],
      hasSlotReservationEnabled: json['has_slot_reservation_enabled'] ?? false,
    );
  }

  bool hasValidCoordinates() {
    return latitude != null && longitude != null;
  }
}
```

### 2. Service Method

```dart
// lib/data/services/mall_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/mall_model.dart';

class MallService {
  final String baseUrl;
  final String? token;

  MallService({required this.baseUrl, this.token});

  Future<List<MallModel>> getMalls() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/mall'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return (data['data'] as List)
            .map((mall) => MallModel.fromJson(mall))
            .toList();
      }
    }
    throw Exception('Failed to load malls');
  }

  Future<MallModel> getMallDetails(int mallId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/mall/$mallId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return MallModel.fromJson(data['data']);
      }
    }
    throw Exception('Failed to load mall details');
  }
}
```

### 3. Display Mall on Map

```dart
// lib/presentation/screens/mall_map_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MallMapPage extends StatelessWidget {
  final MallModel mall;

  const MallMapPage({Key? key, required this.mall}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!mall.hasValidCoordinates()) {
      return Scaffold(
        appBar: AppBar(title: Text('Lokasi ${mall.namaMall}')),
        body: Center(
          child: Text('Koordinat lokasi belum tersedia'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Lokasi ${mall.namaMall}'),
        actions: [
          IconButton(
            icon: Icon(Icons.navigation),
            onPressed: () => _openGoogleMaps(mall.googleMapsUrl),
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(mall.latitude!, mall.longitude!),
          zoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(mall.latitude!, mall.longitude!),
                width: 80,
                height: 80,
                builder: (context) => Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openGoogleMaps(String? url) {
    if (url != null) {
      // Use url_launcher package
      // launch(url);
    }
  }
}
```

### 4. Mall List with Distance

```dart
// lib/presentation/widgets/mall_card.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class MallCard extends StatelessWidget {
  final MallModel mall;
  final Position? userLocation;

  const MallCard({
    Key? key,
    required this.mall,
    this.userLocation,
  }) : super(key: key);

  double? _calculateDistance() {
    if (userLocation == null || !mall.hasValidCoordinates()) {
      return null;
    }

    return Geolocator.distanceBetween(
      userLocation!.latitude,
      userLocation!.longitude,
      mall.latitude!,
      mall.longitude!,
    ) / 1000; // Convert to km
  }

  @override
  Widget build(BuildContext context) {
    final distance = _calculateDistance();

    return Card(
      child: ListTile(
        leading: Icon(Icons.local_parking, size: 40),
        title: Text(mall.namaMall),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mall.lokasi ?? '-'),
            if (distance != null)
              Text(
                '${distance.toStringAsFixed(1)} km dari Anda',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            Text('Slot tersedia: ${mall.availableSlots}'),
          ],
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to mall details
        },
      ),
    );
  }
}
```

## 🗺️ Required Flutter Packages

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter_map: ^6.0.0
  latlong2: ^0.9.0
  geolocator: ^10.1.0
  url_launcher: ^6.2.0
```

## 🔧 Android Permissions

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

## 🍎 iOS Permissions

Add to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby malls</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location to show nearby malls</string>
```

## 📊 Use Cases

### 1. Show Nearest Malls
```dart
Future<List<MallModel>> getNearestMalls() async {
  final position = await Geolocator.getCurrentPosition();
  final malls = await mallService.getMalls();
  
  // Sort by distance
  malls.sort((a, b) {
    if (!a.hasValidCoordinates() || !b.hasValidCoordinates()) return 0;
    
    final distanceA = Geolocator.distanceBetween(
      position.latitude, position.longitude,
      a.latitude!, a.longitude!,
    );
    
    final distanceB = Geolocator.distanceBetween(
      position.latitude, position.longitude,
      b.latitude!, b.longitude!,
    );
    
    return distanceA.compareTo(distanceB);
  });
  
  return malls;
}
```

### 2. Navigate to Mall
```dart
Future<void> navigateToMall(MallModel mall) async {
  if (mall.googleMapsUrl != null) {
    await launch(mall.googleMapsUrl!);
  } else if (mall.hasValidCoordinates()) {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${mall.latitude},${mall.longitude}';
    await launch(url);
  }
}
```

### 3. Filter Malls by Radius
```dart
List<MallModel> filterMallsByRadius(
  List<MallModel> malls,
  Position userLocation,
  double radiusKm,
) {
  return malls.where((mall) {
    if (!mall.hasValidCoordinates()) return false;
    
    final distance = Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      mall.latitude!,
      mall.longitude!,
    ) / 1000;
    
    return distance <= radiusKm;
  }).toList();
}
```

## 🎯 Testing

### Test API Response
```bash
curl -X GET "http://localhost:8000/api/mall" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

### Expected Response
```json
{
  "success": true,
  "message": "Malls retrieved successfully",
  "data": [
    {
      "id_mall": 1,
      "nama_mall": "Grand Indonesia",
      "latitude": -6.195396,
      "longitude": 106.822754,
      ...
    }
  ]
}
```

## 📝 Notes

1. **Null Safety**: Always check if coordinates exist before using them
2. **Distance Calculation**: Use Geolocator package for accurate distance
3. **Google Maps**: Use url_launcher to open Google Maps for navigation
4. **Permissions**: Request location permissions at runtime
5. **Error Handling**: Handle cases where location is not available

---

**API Ready for Mobile Integration** 🚀
