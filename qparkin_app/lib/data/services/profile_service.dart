import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/vehicle_model.dart';

/// Service for handling profile-related API operations
/// Provides methods for fetching and updating user data and vehicles
///
/// Requirements: 3.4
class ProfileService {
  // Base URL - configured via environment variable
  static const String _baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const Duration _timeout = Duration(seconds: 10);

  // HTTP client for managing requests
  final http.Client _client = http.Client();

  // Track pending requests for cancellation
  bool _isCancelled = false;

  /// Fetch user data from the API
  /// 
  /// Takes an authentication [token]
  /// Returns [UserModel] with user details on success
  /// Throws Exception on network or server errors
  /// 
  /// Requirements: 3.4
  Future<UserModel> fetchUserData({required String token}) async {
    try {
      // Check if cancelled before starting
      if (_isCancelled) {
        debugPrint('[ProfileService] Request cancelled before starting');
        throw Exception('Request cancelled');
      }

      final uri = Uri.parse('$_baseUrl/api/profile/user');
      debugPrint('[ProfileService] Fetching user data from: $uri');

      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      debugPrint('[ProfileService] User data response status: ${response.statusCode}');
      debugPrint('[ProfileService] User data response body: ${response.body}');

      return _handleUserDataResponse(response);
    } on TimeoutException catch (e) {
      debugPrint('[ProfileService] Request timeout: $e');
      throw Exception('Koneksi timeout. Silakan coba lagi.');
    } on http.ClientException catch (e) {
      debugPrint('[ProfileService] Network error: ${e.message}');
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    } on FormatException catch (e) {
      debugPrint('[ProfileService] Invalid response format: $e');
      throw Exception('Format respons server tidak valid.');
    } catch (e) {
      debugPrint('[ProfileService] Unexpected error: $e');
      rethrow;
    }
  }

  /// Fetch vehicles associated with the user
  /// 
  /// Takes an authentication [token]
  /// Returns List of [VehicleModel] on success
  /// Throws Exception on network or server errors
  /// 
  /// Requirements: 3.4
  Future<List<VehicleModel>> fetchVehicles({required String token}) async {
    try {
      // Check if cancelled before starting
      if (_isCancelled) {
        debugPrint('[ProfileService] Request cancelled before starting');
        throw Exception('Request cancelled');
      }

      final uri = Uri.parse('$_baseUrl/api/profile/vehicles');
      debugPrint('[ProfileService] Fetching vehicles from: $uri');

      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      debugPrint('[ProfileService] Vehicles response status: ${response.statusCode}');
      debugPrint('[ProfileService] Vehicles response body: ${response.body}');

      return _handleVehiclesResponse(response);
    } on TimeoutException catch (e) {
      debugPrint('[ProfileService] Request timeout: $e');
      throw Exception('Koneksi timeout. Silakan coba lagi.');
    } on http.ClientException catch (e) {
      debugPrint('[ProfileService] Network error: ${e.message}');
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    } on FormatException catch (e) {
      debugPrint('[ProfileService] Invalid response format: $e');
      throw Exception('Format respons server tidak valid.');
    } catch (e) {
      debugPrint('[ProfileService] Unexpected error: $e');
      rethrow;
    }
  }

  /// Update user profile data
  /// 
  /// Takes a [UserModel] with updated data and authentication [token]
  /// Returns updated [UserModel] on success
  /// Throws Exception on network, validation, or server errors
  /// 
  /// Requirements: 3.4
  Future<UserModel> updateUser({
    required UserModel user,
    required String token,
  }) async {
    try {
      // Check if cancelled before starting
      if (_isCancelled) {
        debugPrint('[ProfileService] Request cancelled before starting');
        throw Exception('Request cancelled');
      }

      final uri = Uri.parse('$_baseUrl/api/profile/user');
      debugPrint('[ProfileService] Updating user data at: $uri');
      debugPrint('[ProfileService] Update data: ${user.toJson()}');

      final response = await _client.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(user.toJson()),
      ).timeout(_timeout);

      debugPrint('[ProfileService] Update response status: ${response.statusCode}');
      debugPrint('[ProfileService] Update response body: ${response.body}');

      return _handleUserDataResponse(response);
    } on TimeoutException catch (e) {
      debugPrint('[ProfileService] Request timeout: $e');
      throw Exception('Koneksi timeout. Silakan coba lagi.');
    } on http.ClientException catch (e) {
      debugPrint('[ProfileService] Network error: ${e.message}');
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    } on FormatException catch (e) {
      debugPrint('[ProfileService] Invalid response format: $e');
      throw Exception('Format respons server tidak valid.');
    } catch (e) {
      debugPrint('[ProfileService] Unexpected error: $e');
      rethrow;
    }
  }

  /// Handle user data response and parse into UserModel
  UserModel _handleUserDataResponse(http.Response response) {
    try {
      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success response
        debugPrint('[ProfileService] User data retrieved successfully');
        
        // Handle different response formats
        if (data['data'] != null) {
          return UserModel.fromJson(data['data']);
        } else if (data['user'] != null) {
          return UserModel.fromJson(data['user']);
        } else {
          return UserModel.fromJson(data);
        }
      } else if (response.statusCode == 400) {
        // Validation error
        debugPrint('[ProfileService] Validation error (400)');
        final message = data['message']?.toString() ?? 'Data tidak valid';
        throw Exception(message);
      } else if (response.statusCode == 401) {
        // Unauthorized
        debugPrint('[ProfileService] Unauthorized (401)');
        throw Exception('Sesi Anda telah berakhir. Silakan login kembali.');
      } else if (response.statusCode == 404) {
        // Resource not found
        debugPrint('[ProfileService] Resource not found (404)');
        throw Exception('Data pengguna tidak ditemukan.');
      } else if (response.statusCode >= 500) {
        // Server error
        debugPrint('[ProfileService] Server error (${response.statusCode})');
        throw Exception('Terjadi kesalahan server. Coba lagi nanti.');
      } else {
        // Other errors
        debugPrint('[ProfileService] Unexpected status: ${response.statusCode}');
        final message = data['message']?.toString() ?? 'Terjadi kesalahan';
        throw Exception(message);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      debugPrint('[ProfileService] Error handling response: $e');
      throw Exception('Gagal memproses respons server.');
    }
  }

  /// Handle vehicles response and parse into List<VehicleModel>
  List<VehicleModel> _handleVehiclesResponse(http.Response response) {
    try {
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Success response
        debugPrint('[ProfileService] Vehicles retrieved successfully');
        
        List<dynamic> vehiclesJson;
        
        // Handle different response formats
        if (data['data'] != null) {
          vehiclesJson = data['data'] as List<dynamic>;
        } else if (data['vehicles'] != null) {
          vehiclesJson = data['vehicles'] as List<dynamic>;
        } else if (data is List) {
          vehiclesJson = data;
        } else {
          debugPrint('[ProfileService] No vehicles found in response');
          return [];
        }

        return vehiclesJson
            .map((json) => VehicleModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        // Unauthorized
        debugPrint('[ProfileService] Unauthorized (401)');
        throw Exception('Sesi Anda telah berakhir. Silakan login kembali.');
      } else if (response.statusCode == 404) {
        // No vehicles found - return empty list
        debugPrint('[ProfileService] No vehicles found (404)');
        return [];
      } else if (response.statusCode >= 500) {
        // Server error
        debugPrint('[ProfileService] Server error (${response.statusCode})');
        throw Exception('Terjadi kesalahan server. Coba lagi nanti.');
      } else {
        // Other errors
        debugPrint('[ProfileService] Unexpected status: ${response.statusCode}');
        final message = data['message']?.toString() ?? 'Terjadi kesalahan';
        throw Exception(message);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      debugPrint('[ProfileService] Error handling response: $e');
      throw Exception('Gagal memproses respons server.');
    }
  }

  /// Cancel all pending API requests
  ///
  /// Call this when the profile page is disposed to prevent
  /// memory leaks and unnecessary network operations.
  void cancelPendingRequests() {
    debugPrint('[ProfileService] Cancelling all pending requests');
    _isCancelled = true;
  }

  /// Reset cancellation flag
  ///
  /// Call this if you want to reuse the service after cancellation
  void resetCancellation() {
    _isCancelled = false;
  }

  /// Dispose the service and clean up resources
  void dispose() {
    debugPrint('[ProfileService] Disposing service');
    _isCancelled = true;
    _client.close();
  }
}
