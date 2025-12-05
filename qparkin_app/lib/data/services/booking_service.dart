import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/booking_request.dart';
import '../models/booking_response.dart';
import '../models/booking_model.dart';
import '../models/parking_floor_model.dart';
import '../models/parking_slot_model.dart';
import '../models/slot_reservation_model.dart';

/// Service for handling booking-related API operations
/// Provides methods for creating bookings and checking slot availability
///
/// Requirements: 9.1-9.9, 15.4, 15.7
class BookingService {
  // Base URL - configured via environment variable
  static const String _baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const Duration _timeout = Duration(seconds: 10);
  static const int _maxRetries = 3;

  // HTTP client for managing requests
  final http.Client _client = http.Client();

  // Track pending requests for cancellation
  bool _isCancelled = false;

  // Cache for floor data (5 minutes)
  static final Map<String, List<ParkingFloorModel>> _floorCache = {};
  static final Map<String, DateTime> _floorCacheTimestamp = {};
  static const Duration _floorCacheDuration = Duration(minutes: 5);

  // Cache for slot visualization data (2 minutes)
  static final Map<String, List<ParkingSlotModel>> _slotCache = {};
  static final Map<String, DateTime> _slotCacheTimestamp = {};
  static const Duration _slotCacheDuration = Duration(minutes: 2);

  /// Create a new parking booking
  /// 
  /// Takes a [BookingRequest] and authentication [token]
  /// Returns [BookingResponse] with booking details and QR code on success
  /// Throws Exception on network or server errors
  /// 
  /// Requirements: 9.1-9.9, 15.7
  Future<BookingResponse> createBooking({
    required BookingRequest request,
    required String token,
  }) async {
    try {
      // Check if cancelled before starting
      if (_isCancelled) {
        debugPrint('[BookingService] Request cancelled before starting');
        return BookingResponse.error(
          message: 'Request cancelled',
          errorCode: 'CANCELLED',
        );
      }

      // Validate request before sending
      if (!request.validate()) {
        final error = request.getValidationError();
        debugPrint('[BookingService] Validation failed: $error');
        return BookingResponse.validationError(
          error ?? 'Data booking tidak valid',
        );
      }

      final uri = Uri.parse('$_baseUrl/api/booking/create');
      debugPrint('[BookingService] Creating booking at: $uri');
      debugPrint('[BookingService] Request data: ${request.toJson()}');

      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(request.toJson()),
      ).timeout(_timeout);

      debugPrint('[BookingService] Response status: ${response.statusCode}');
      debugPrint('[BookingService] Response body: ${response.body}');

      return _handleBookingResponse(response);
    } on TimeoutException catch (e) {
      debugPrint('[BookingService] Request timeout: $e');
      return BookingResponse.timeoutError();
    } on http.ClientException catch (e) {
      debugPrint('[BookingService] Network error: ${e.message}');
      return BookingResponse.networkError();
    } on FormatException catch (e) {
      debugPrint('[BookingService] Invalid response format: $e');
      return BookingResponse.error(
        message: 'Invalid response from server',
        errorCode: 'FORMAT_ERROR',
      );
    } catch (e) {
      debugPrint('[BookingService] Unexpected error: $e');
      return BookingResponse.error(
        message: 'Terjadi kesalahan: $e',
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Create booking with automatic retry on failure
  /// 
  /// Attempts the request up to [maxRetries] times with exponential backoff
  /// Skips retry for validation and auth errors
  /// 
  /// Requirements: 9.1-9.9, 15.4
  Future<BookingResponse> createBookingWithRetry({
    required BookingRequest request,
    required String token,
    int maxRetries = _maxRetries,
  }) async {
    int attempt = 0;
    Duration delay = const Duration(seconds: 1);
    BookingResponse? lastResponse;

    debugPrint('[BookingService] Starting retry mechanism (max: $maxRetries)');

    while (attempt < maxRetries) {
      try {
        attempt++;
        debugPrint('[BookingService] Attempt $attempt of $maxRetries');

        final response = await createBooking(
          request: request,
          token: token,
        );

        // Return immediately on success
        if (response.success) {
          if (attempt > 1) {
            debugPrint('[BookingService] Retry successful on attempt $attempt');
          }
          return response;
        }

        lastResponse = response;

        // Don't retry on validation or auth errors
        if (response.isValidationError ||
            response.errorCode == 'UNAUTHORIZED' ||
            response.errorCode == 'AUTH_ERROR') {
          debugPrint('[BookingService] Non-retryable error - returning');
          return response;
        }

        // Don't retry on booking conflicts
        if (response.isBookingConflict) {
          debugPrint('[BookingService] Booking conflict - not retrying');
          return response;
        }

        if (attempt >= maxRetries) {
          debugPrint('[BookingService] All retry attempts exhausted');
          return response;
        }

        // Exponential backoff for network/server errors
        if (response.isNetworkError || response.isServerError) {
          debugPrint('[BookingService] Waiting ${delay.inSeconds}s before retry...');
          await Future.delayed(delay);
          delay *= 2;
        } else {
          // For other errors, return immediately
          return response;
        }
      } catch (e) {
        debugPrint('[BookingService] Attempt $attempt failed with exception: $e');
        
        if (attempt >= maxRetries) {
          debugPrint('[BookingService] All retry attempts exhausted');
          return BookingResponse.error(
            message: 'Failed after $maxRetries attempts: $e',
            errorCode: 'MAX_RETRIES_EXCEEDED',
          );
        }

        await Future.delayed(delay);
        delay *= 2;
      }
    }

    // Return last response if available
    return lastResponse ?? BookingResponse.error(
      message: 'Booking failed after multiple attempts',
      errorCode: 'MAX_RETRIES_EXCEEDED',
    );
  }

  /// Check parking slot availability for given parameters
  /// 
  /// Returns the number of available slots matching the criteria
  /// Returns 0 if no slots available or on error
  /// 
  /// Requirements: 5.1-5.7, 15.4, 15.7
  Future<int> checkSlotAvailability({
    required String mallId,
    required String vehicleType,
    required DateTime startTime,
    required int durationHours,
    required String token,
  }) async {
    try {
      // Check if cancelled before starting
      if (_isCancelled) {
        debugPrint('[BookingService] Availability check cancelled');
        return 0;
      }

      final queryParams = {
        'mall_id': mallId,
        'vehicle_type': vehicleType,
        'start_time': startTime.toIso8601String(),
        'duration': durationHours.toString(),
      };

      final uri = Uri.parse('$_baseUrl/api/booking/check-availability')
          .replace(queryParameters: queryParams);
      
      debugPrint('[BookingService] Checking availability at: $uri');

      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      debugPrint('[BookingService] Availability response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          debugPrint('[BookingService] Availability data: $data');

          // Handle different response formats
          if (data['available_slots'] != null) {
            return _parseInt(data['available_slots']);
          } else if (data['data'] != null && data['data']['available_slots'] != null) {
            return _parseInt(data['data']['available_slots']);
          } else if (data['slots'] != null) {
            return _parseInt(data['slots']);
          }

          debugPrint('[BookingService] No slot count in response, returning 0');
          return 0;
        } catch (e) {
          debugPrint('[BookingService] Error parsing availability response: $e');
          return 0;
        }
      } else if (response.statusCode == 404) {
        debugPrint('[BookingService] No slots found (404)');
        return 0;
      } else if (response.statusCode == 401) {
        debugPrint('[BookingService] Unauthorized (401)');
        throw Exception('Unauthorized: Invalid or expired token');
      } else {
        debugPrint('[BookingService] Unexpected status: ${response.statusCode}');
        return 0;
      }
    } on TimeoutException catch (e) {
      debugPrint('[BookingService] Availability check timeout: $e');
      return 0;
    } on http.ClientException catch (e) {
      debugPrint('[BookingService] Network error during availability check: ${e.message}');
      return 0;
    } catch (e) {
      debugPrint('[BookingService] Error checking availability: $e');
      if (e.toString().contains('Unauthorized')) {
        rethrow;
      }
      return 0;
    }
  }

  /// Check slot availability with retry mechanism
  /// 
  /// Attempts the request up to [maxRetries] times
  /// Returns 0 on all failures
  Future<int> checkSlotAvailabilityWithRetry({
    required String mallId,
    required String vehicleType,
    required DateTime startTime,
    required int durationHours,
    required String token,
    int maxRetries = 2, // Fewer retries for availability checks
  }) async {
    int attempt = 0;
    Duration delay = const Duration(milliseconds: 500);

    debugPrint('[BookingService] Checking availability with retry (max: $maxRetries)');

    while (attempt < maxRetries) {
      try {
        attempt++;
        debugPrint('[BookingService] Availability check attempt $attempt of $maxRetries');

        final slots = await checkSlotAvailability(
          mallId: mallId,
          vehicleType: vehicleType,
          startTime: startTime,
          durationHours: durationHours,
          token: token,
        );

        if (attempt > 1) {
          debugPrint('[BookingService] Availability check successful on attempt $attempt');
        }

        return slots;
      } catch (e) {
        debugPrint('[BookingService] Availability check attempt $attempt failed: $e');

        // Don't retry on auth errors
        if (e.toString().contains('Unauthorized')) {
          debugPrint('[BookingService] Auth error - not retrying');
          rethrow;
        }

        if (attempt >= maxRetries) {
          debugPrint('[BookingService] All availability check attempts exhausted');
          return 0;
        }

        await Future.delayed(delay);
        delay *= 2;
      }
    }

    return 0;
  }

  /// Check if user has an active booking
  /// 
  /// Returns true if user has an active booking, false otherwise
  /// Used to prevent duplicate bookings
  /// 
  /// Requirements: 11.6
  Future<bool> checkActiveBooking({required String token}) async {
    try {
      // Check if cancelled before starting
      if (_isCancelled) {
        debugPrint('[BookingService] Active booking check cancelled');
        return false;
      }

      final uri = Uri.parse('$_baseUrl/api/booking/check-active');
      
      debugPrint('[BookingService] Checking for active booking at: $uri');

      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      debugPrint('[BookingService] Active booking check response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          debugPrint('[BookingService] Active booking check data: $data');

          // Handle different response formats
          if (data['has_active_booking'] != null) {
            return data['has_active_booking'] == true || data['has_active_booking'] == 1;
          } else if (data['data'] != null && data['data']['has_active_booking'] != null) {
            return data['data']['has_active_booking'] == true || data['data']['has_active_booking'] == 1;
          } else if (data['active_booking'] != null) {
            // If active_booking object exists, user has active booking
            return true;
          } else if (data['success'] != null) {
            // Some APIs return success: true/false
            return data['success'] == true || data['success'] == 1;
          }

          // Default to false if format is unclear
          debugPrint('[BookingService] Unclear response format, assuming no active booking');
          return false;
        } catch (e) {
          debugPrint('[BookingService] Error parsing active booking response: $e');
          return false;
        }
      } else if (response.statusCode == 404) {
        // No active booking found
        debugPrint('[BookingService] No active booking (404)');
        return false;
      } else if (response.statusCode == 401) {
        debugPrint('[BookingService] Unauthorized (401)');
        throw Exception('Unauthorized: Invalid or expired token');
      } else {
        debugPrint('[BookingService] Unexpected status: ${response.statusCode}');
        return false;
      }
    } on TimeoutException catch (e) {
      debugPrint('[BookingService] Active booking check timeout: $e');
      return false;
    } on http.ClientException catch (e) {
      debugPrint('[BookingService] Network error during active booking check: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[BookingService] Error checking active booking: $e');
      if (e.toString().contains('Unauthorized')) {
        rethrow;
      }
      return false;
    }
  }

  /// Handle booking response and parse into BookingResponse object
  BookingResponse _handleBookingResponse(http.Response response) {
    try {
      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success response
        debugPrint('[BookingService] Booking created successfully');
        return BookingResponse.fromJson(data);
      } else if (response.statusCode == 400) {
        // Validation error
        debugPrint('[BookingService] Validation error (400)');
        return BookingResponse.validationError(
          data['message']?.toString() ?? 'Data tidak valid',
        );
      } else if (response.statusCode == 401) {
        // Unauthorized
        debugPrint('[BookingService] Unauthorized (401)');
        return BookingResponse.error(
          message: 'Sesi Anda telah berakhir. Silakan login kembali.',
          errorCode: 'UNAUTHORIZED',
        );
      } else if (response.statusCode == 404) {
        // Resource not found (mall, vehicle, or slot)
        debugPrint('[BookingService] Resource not found (404)');
        return BookingResponse.error(
          message: data['message']?.toString() ?? 'Data tidak ditemukan',
          errorCode: 'NOT_FOUND',
        );
      } else if (response.statusCode == 409) {
        // Conflict (slot unavailable or active booking exists)
        debugPrint('[BookingService] Conflict (409)');
        final message = data['message']?.toString() ?? 'Terjadi konflik booking';
        
        if (message.toLowerCase().contains('slot')) {
          return BookingResponse.slotUnavailable();
        } else if (message.toLowerCase().contains('aktif') || 
                   message.toLowerCase().contains('active')) {
          return BookingResponse.error(
            message: 'Anda sudah memiliki booking aktif',
            errorCode: 'BOOKING_CONFLICT',
          );
        }
        
        return BookingResponse.error(
          message: message,
          errorCode: 'CONFLICT',
        );
      } else if (response.statusCode >= 500) {
        // Server error
        debugPrint('[BookingService] Server error (${response.statusCode})');
        return BookingResponse.error(
          message: 'Terjadi kesalahan server. Coba lagi nanti.',
          errorCode: 'SERVER_ERROR',
        );
      } else {
        // Other errors
        debugPrint('[BookingService] Unexpected status: ${response.statusCode}');
        return BookingResponse.error(
          message: data['message']?.toString() ?? 'Terjadi kesalahan',
          errorCode: 'UNKNOWN_ERROR',
        );
      }
    } catch (e) {
      debugPrint('[BookingService] Error handling response: $e');
      return BookingResponse.error(
        message: 'Failed to process server response',
        errorCode: 'PARSE_ERROR',
      );
    }
  }

  /// Helper method to safely parse int values
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Get list of parking floors for a mall
  ///
  /// Fetches floor data with availability information
  /// Implements caching strategy (5 minutes)
  /// Returns empty list on error
  ///
  /// Requirements: 11.1-11.10
  Future<List<ParkingFloorModel>> getFloors({
    required String mallId,
    required String token,
  }) async {
    try {
      // Check if cancelled before starting
      if (_isCancelled) {
        debugPrint('[BookingService] getFloors cancelled');
        return [];
      }

      // Check cache first
      final cached = _getCachedFloors(mallId);
      if (cached != null) {
        debugPrint('[BookingService] Returning cached floors for mall $mallId');
        return cached;
      }

      final uri = Uri.parse('$_baseUrl/api/parking/floors/$mallId');
      debugPrint('[BookingService] Fetching floors from: $uri');

      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      debugPrint('[BookingService] getFloors response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          debugPrint('[BookingService] getFloors data: $data');

          List<dynamic> floorsJson;
          
          // Handle different response formats
          if (data['data'] is List) {
            floorsJson = data['data'];
          } else if (data['floors'] is List) {
            floorsJson = data['floors'];
          } else if (data is List) {
            floorsJson = data;
          } else {
            debugPrint('[BookingService] Unexpected response format');
            return [];
          }

          final floors = floorsJson
              .map((json) => ParkingFloorModel.fromJson(json))
              .where((floor) => floor.validate())
              .toList();

          // Cache the result
          _cacheFloors(mallId, floors);

          debugPrint('[BookingService] Parsed ${floors.length} floors');
          return floors;
        } catch (e) {
          debugPrint('[BookingService] Error parsing floors response: $e');
          return [];
        }
      } else if (response.statusCode == 404) {
        debugPrint('[BookingService] No floors found (404)');
        return [];
      } else if (response.statusCode == 401) {
        debugPrint('[BookingService] Unauthorized (401)');
        throw Exception('Unauthorized: Invalid or expired token');
      } else {
        debugPrint('[BookingService] Unexpected status: ${response.statusCode}');
        return [];
      }
    } on TimeoutException catch (e) {
      debugPrint('[BookingService] getFloors timeout: $e');
      return [];
    } on http.ClientException catch (e) {
      debugPrint('[BookingService] Network error during getFloors: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('[BookingService] Error fetching floors: $e');
      if (e.toString().contains('Unauthorized')) {
        rethrow;
      }
      return [];
    }
  }

  /// Get floors with retry mechanism
  ///
  /// Attempts the request up to [maxRetries] times
  /// Returns empty list on all failures
  ///
  /// Requirements: 11.1-11.10
  Future<List<ParkingFloorModel>> getFloorsWithRetry({
    required String mallId,
    required String token,
    int maxRetries = 2,
  }) async {
    int attempt = 0;
    Duration delay = const Duration(milliseconds: 500);

    debugPrint('[BookingService] Fetching floors with retry (max: $maxRetries)');

    while (attempt < maxRetries) {
      try {
        attempt++;
        debugPrint('[BookingService] getFloors attempt $attempt of $maxRetries');

        final floors = await getFloors(
          mallId: mallId,
          token: token,
        );

        if (attempt > 1) {
          debugPrint('[BookingService] getFloors successful on attempt $attempt');
        }

        return floors;
      } catch (e) {
        debugPrint('[BookingService] getFloors attempt $attempt failed: $e');

        // Don't retry on auth errors
        if (e.toString().contains('Unauthorized')) {
          debugPrint('[BookingService] Auth error - not retrying');
          rethrow;
        }

        if (attempt >= maxRetries) {
          debugPrint('[BookingService] All getFloors attempts exhausted');
          return [];
        }

        await Future.delayed(delay);
        delay *= 2;
      }
    }

    return [];
  }

  /// Get slots for visualization on a specific floor
  ///
  /// Fetches slot data for display purposes (non-interactive)
  /// Supports vehicle type filtering
  /// Implements caching strategy (2 minutes)
  /// Returns empty list on error
  ///
  /// Requirements: 11.1-11.10
  Future<List<ParkingSlotModel>> getSlotsForVisualization({
    required String floorId,
    required String token,
    String? vehicleType,
  }) async {
    try {
      // Check if cancelled before starting
      if (_isCancelled) {
        debugPrint('[BookingService] getSlotsForVisualization cancelled');
        return [];
      }

      // Check cache first
      final cacheKey = vehicleType != null ? '${floorId}_$vehicleType' : floorId;
      final cached = _getCachedSlots(cacheKey);
      if (cached != null) {
        debugPrint('[BookingService] Returning cached slots for floor $floorId');
        return cached;
      }

      final queryParams = vehicleType != null
          ? {'vehicle_type': vehicleType}
          : <String, String>{};

      final uri = Uri.parse('$_baseUrl/api/parking/slots/$floorId/visualization')
          .replace(queryParameters: queryParams);
      
      debugPrint('[BookingService] Fetching slots from: $uri');

      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      debugPrint('[BookingService] getSlotsForVisualization response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          debugPrint('[BookingService] getSlotsForVisualization data: $data');

          List<dynamic> slotsJson;
          
          // Handle different response formats
          if (data['data'] is List) {
            slotsJson = data['data'];
          } else if (data['slots'] is List) {
            slotsJson = data['slots'];
          } else if (data is List) {
            slotsJson = data;
          } else {
            debugPrint('[BookingService] Unexpected response format');
            return [];
          }

          final slots = slotsJson
              .map((json) => ParkingSlotModel.fromJson(json))
              .where((slot) => slot.validate())
              .toList();

          // Cache the result
          _cacheSlots(cacheKey, slots);

          debugPrint('[BookingService] Parsed ${slots.length} slots');
          return slots;
        } catch (e) {
          debugPrint('[BookingService] Error parsing slots response: $e');
          return [];
        }
      } else if (response.statusCode == 404) {
        debugPrint('[BookingService] No slots found (404)');
        return [];
      } else if (response.statusCode == 401) {
        debugPrint('[BookingService] Unauthorized (401)');
        throw Exception('Unauthorized: Invalid or expired token');
      } else {
        debugPrint('[BookingService] Unexpected status: ${response.statusCode}');
        return [];
      }
    } on TimeoutException catch (e) {
      debugPrint('[BookingService] getSlotsForVisualization timeout: $e');
      return [];
    } on http.ClientException catch (e) {
      debugPrint('[BookingService] Network error during getSlotsForVisualization: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('[BookingService] Error fetching slots: $e');
      if (e.toString().contains('Unauthorized')) {
        rethrow;
      }
      return [];
    }
  }

  /// Reserve a random available slot on specified floor
  ///
  /// Backend automatically assigns a specific slot
  /// Returns SlotReservationModel on success, null on failure
  /// Implements 5-minute reservation timeout
  ///
  /// Requirements: 11.1-11.10
  Future<SlotReservationModel?> reserveRandomSlot({
    required String floorId,
    required String userId,
    required String vehicleType,
    required String token,
    int durationMinutes = 5,
  }) async {
    try {
      // Check if cancelled before starting
      if (_isCancelled) {
        debugPrint('[BookingService] reserveRandomSlot cancelled');
        return null;
      }

      final uri = Uri.parse('$_baseUrl/api/parking/slots/reserve-random');
      debugPrint('[BookingService] Reserving random slot at: $uri');

      final requestBody = {
        'id_floor': floorId,
        'id_user': userId,
        'vehicle_type': vehicleType,
        'duration_minutes': durationMinutes,
      };

      debugPrint('[BookingService] Reserve request data: $requestBody');

      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      ).timeout(_timeout);

      debugPrint('[BookingService] reserveRandomSlot response status: ${response.statusCode}');
      debugPrint('[BookingService] reserveRandomSlot response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = json.decode(response.body);
          debugPrint('[BookingService] reserveRandomSlot data: $data');

          Map<String, dynamic> reservationJson;
          
          // Handle different response formats
          if (data['data'] is Map) {
            reservationJson = Map<String, dynamic>.from(data['data']);
          } else if (data['reservation'] is Map) {
            reservationJson = Map<String, dynamic>.from(data['reservation']);
          } else if (data is Map && data.containsKey('reservation_id')) {
            reservationJson = Map<String, dynamic>.from(data);
          } else {
            debugPrint('[BookingService] Unexpected response format');
            return null;
          }

          final reservation = SlotReservationModel.fromJson(reservationJson);

          if (!reservation.validate()) {
            debugPrint('[BookingService] Invalid reservation data');
            return null;
          }

          debugPrint('[BookingService] Slot reserved successfully: ${reservation.slotCode}');
          return reservation;
        } catch (e) {
          debugPrint('[BookingService] Error parsing reservation response: $e');
          return null;
        }
      } else if (response.statusCode == 404) {
        debugPrint('[BookingService] No slots available (404)');
        return null;
      } else if (response.statusCode == 409) {
        debugPrint('[BookingService] Conflict - no slots available (409)');
        return null;
      } else if (response.statusCode == 401) {
        debugPrint('[BookingService] Unauthorized (401)');
        throw Exception('Unauthorized: Invalid or expired token');
      } else {
        debugPrint('[BookingService] Unexpected status: ${response.statusCode}');
        return null;
      }
    } on TimeoutException catch (e) {
      debugPrint('[BookingService] reserveRandomSlot timeout: $e');
      return null;
    } on http.ClientException catch (e) {
      debugPrint('[BookingService] Network error during reserveRandomSlot: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('[BookingService] Error reserving slot: $e');
      if (e.toString().contains('Unauthorized')) {
        rethrow;
      }
      return null;
    }
  }

  /// Helper method to get cached floors
  List<ParkingFloorModel>? _getCachedFloors(String mallId) {
    final timestamp = _floorCacheTimestamp[mallId];
    if (timestamp == null) return null;

    final age = DateTime.now().difference(timestamp);
    if (age > _floorCacheDuration) {
      // Cache expired
      _floorCache.remove(mallId);
      _floorCacheTimestamp.remove(mallId);
      return null;
    }

    return _floorCache[mallId];
  }

  /// Helper method to cache floors
  void _cacheFloors(String mallId, List<ParkingFloorModel> floors) {
    _floorCache[mallId] = floors;
    _floorCacheTimestamp[mallId] = DateTime.now();
  }

  /// Helper method to get cached slots
  List<ParkingSlotModel>? _getCachedSlots(String cacheKey) {
    final timestamp = _slotCacheTimestamp[cacheKey];
    if (timestamp == null) return null;

    final age = DateTime.now().difference(timestamp);
    if (age > _slotCacheDuration) {
      // Cache expired
      _slotCache.remove(cacheKey);
      _slotCacheTimestamp.remove(cacheKey);
      return null;
    }

    return _slotCache[cacheKey];
  }

  /// Helper method to cache slots
  void _cacheSlots(String cacheKey, List<ParkingSlotModel> slots) {
    _slotCache[cacheKey] = slots;
    _slotCacheTimestamp[cacheKey] = DateTime.now();
  }

  /// Clear all caches
  void clearCache() {
    debugPrint('[BookingService] Clearing all caches');
    _floorCache.clear();
    _floorCacheTimestamp.clear();
    _slotCache.clear();
    _slotCacheTimestamp.clear();
  }

  /// Cancel all pending API requests
  ///
  /// Call this when the booking page is disposed to prevent
  /// memory leaks and unnecessary network operations.
  ///
  /// Requirements: 15.7
  void cancelPendingRequests() {
    debugPrint('[BookingService] Cancelling all pending requests');
    _isCancelled = true;
  }

  /// Reset cancellation flag
  ///
  /// Call this if you want to reuse the service after cancellation
  void resetCancellation() {
    _isCancelled = false;
  }

  /// Dispose the service and clean up resources
  ///
  /// Requirements: 15.7
  void dispose() {
    debugPrint('[BookingService] Disposing service');
    _isCancelled = true;
    _client.close();
  }
}
