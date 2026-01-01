import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/vehicle_model.dart';

/// Service untuk handle API calls terkait kendaraan
/// Menggunakan endpoint dari qparkin_backend
class VehicleApiService {
  final String baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  VehicleApiService({required this.baseUrl});

  /// Get authorization token from secure storage
  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  /// Build headers with authorization
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  /// Get all vehicles for current user
  /// GET /api/kendaraan
  Future<List<VehicleModel>> getVehicles() async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/api/kendaraan');
      
      // DEBUG: Log the full URL being called
      print('[VehicleApiService] GET URL: $uri');
      print('[VehicleApiService] Base URL: $baseUrl');
      print('[VehicleApiService] Method: GET');
      
      final response = await http.get(
        uri,
        headers: headers,
      );

      print('[VehicleApiService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List vehiclesJson = data['data'];
          return vehiclesJson
              .map((json) => VehicleModel.fromJson(json))
              .toList();
        }
      }

      throw Exception('Failed to load vehicles: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching vehicles: $e');
    }
  }

  /// Add new vehicle
  /// POST /api/kendaraan
  Future<VehicleModel> addVehicle({
    required String platNomor,
    required String jenisKendaraan,
    required String merk,
    required String tipe,
    String? warna,
    bool isActive = false,
    File? foto,
  }) async {
    try {
      final token = await _getToken();
      final uri = Uri.parse('$baseUrl/api/kendaraan');

      // DEBUG: Log the full URL being called
      print('[VehicleApiService] POST URL: $uri');
      print('[VehicleApiService] Base URL: $baseUrl');
      print('[VehicleApiService] Method: POST');
      print('[VehicleApiService] Token present: ${token != null && token.isNotEmpty}');
      print('[VehicleApiService] Has photo: ${foto != null}');

      http.Response response;

      // Use multipart only if photo is provided, otherwise use regular POST
      if (foto != null) {
        // Multipart request for photo upload
        var request = http.MultipartRequest('POST', uri);
        request.headers['Authorization'] = 'Bearer ${token ?? ''}';
        request.headers['Accept'] = 'application/json';

        // Add fields
        request.fields['plat_nomor'] = platNomor;
        request.fields['jenis_kendaraan'] = jenisKendaraan;
        request.fields['merk'] = merk;
        request.fields['tipe'] = tipe;
        if (warna != null && warna.isNotEmpty) {
          request.fields['warna'] = warna;
        }
        request.fields['is_active'] = isActive.toString();

        // Add photo
        request.files.add(
          await http.MultipartFile.fromPath('foto', foto.path),
        );

        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        // Regular JSON POST without photo
        final headers = await _getHeaders();
        headers['Content-Type'] = 'application/json';

        final body = {
          'plat_nomor': platNomor,
          'jenis_kendaraan': jenisKendaraan,
          'merk': merk,
          'tipe': tipe,
          'is_active': isActive,
        };
        
        if (warna != null && warna.isNotEmpty) {
          body['warna'] = warna;
        }

        response = await http.post(
          uri,
          headers: headers,
          body: json.encode(body),
        );
      }

      // DEBUG: Log response details
      print('[VehicleApiService] Response status: ${response.statusCode}');
      print('[VehicleApiService] Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return VehicleModel.fromJson(data['data']);
        }
      }

      // Handle validation errors
      if (response.statusCode == 422) {
        final data = json.decode(response.body);
        final errors = data['errors'] as Map<String, dynamic>?;
        if (errors != null) {
          final errorMessages = errors.values
              .expand((e) => e as List)
              .join(', ');
          throw Exception(errorMessages);
        }
      }

      throw Exception('Failed to add vehicle: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error adding vehicle: $e');
    }
  }

  /// Get vehicle details
  /// GET /api/kendaraan/{id}
  Future<VehicleModel> getVehicle(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/kendaraan/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return VehicleModel.fromJson(data['data']);
        }
      }

      if (response.statusCode == 404) {
        throw Exception('Vehicle not found');
      }

      throw Exception('Failed to load vehicle: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching vehicle: $e');
    }
  }

  /// Update vehicle
  /// PUT /api/kendaraan/{id}
  Future<VehicleModel> updateVehicle({
    required String id,
    String? platNomor,
    String? jenisKendaraan,
    String? merk,
    String? tipe,
    String? warna,
    bool? isActive,
    File? foto,
  }) async {
    try {
      final token = await _getToken();
      final uri = Uri.parse('$baseUrl/api/kendaraan/$id');

      // Use multipart if photo is provided
      if (foto != null) {
        var request = http.MultipartRequest('POST', uri);
        request.headers['Authorization'] = 'Bearer ${token ?? ''}';
        request.headers['Accept'] = 'application/json';
        request.fields['_method'] = 'PUT'; // Laravel method spoofing

        if (platNomor != null) request.fields['plat_nomor'] = platNomor;
        if (jenisKendaraan != null) {
          request.fields['jenis_kendaraan'] = jenisKendaraan;
        }
        if (merk != null) request.fields['merk'] = merk;
        if (tipe != null) request.fields['tipe'] = tipe;
        if (warna != null) request.fields['warna'] = warna;
        if (isActive != null) request.fields['is_active'] = isActive.toString();

        request.files.add(
          await http.MultipartFile.fromPath('foto', foto.path),
        );

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true) {
            return VehicleModel.fromJson(data['data']);
          }
        }
      } else {
        // Use regular PUT request
        final headers = await _getHeaders();
        headers['Content-Type'] = 'application/json';

        final body = <String, dynamic>{};
        if (platNomor != null) body['plat_nomor'] = platNomor;
        if (jenisKendaraan != null) body['jenis_kendaraan'] = jenisKendaraan;
        if (merk != null) body['merk'] = merk;
        if (tipe != null) body['tipe'] = tipe;
        if (warna != null) body['warna'] = warna;
        if (isActive != null) body['is_active'] = isActive;

        final response = await http.put(
          uri,
          headers: headers,
          body: json.encode(body),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true) {
            return VehicleModel.fromJson(data['data']);
          }
        }
      }

      throw Exception('Failed to update vehicle');
    } catch (e) {
      throw Exception('Error updating vehicle: $e');
    }
  }

  /// Delete vehicle
  /// DELETE /api/kendaraan/{id}
  Future<void> deleteVehicle(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/kendaraan/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return;
        }
      }

      if (response.statusCode == 400) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Cannot delete vehicle');
      }

      if (response.statusCode == 404) {
        throw Exception('Vehicle not found');
      }

      throw Exception('Failed to delete vehicle: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error deleting vehicle: $e');
    }
  }

  /// Set vehicle as active
  /// PUT /api/kendaraan/{id}/set-active
  Future<VehicleModel> setActiveVehicle(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/api/kendaraan/$id/set-active'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return VehicleModel.fromJson(data['data']);
        }
      }

      if (response.statusCode == 404) {
        throw Exception('Vehicle not found');
      }

      throw Exception('Failed to set active vehicle: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error setting active vehicle: $e');
    }
  }
}
