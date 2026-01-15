import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/active_parking_model.dart';

class ParkingService {
  // Base URL - should be configured via environment variable
  static const String _baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const Duration _timeout = Duration(seconds: 10);

  /// Fetch active parking data for the authenticated user
  /// Returns ActiveParkingModel if active parking exists, null otherwise
  /// Throws Exception on network or parsing errors
  Future<ActiveParkingModel?> getActiveParking({required String token}) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/booking/active');
      debugPrint('[ParkingService] Fetching active parking from: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      debugPrint('[ParkingService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          debugPrint('[ParkingService] Response data received');
          
          // Check if there's active parking data
          if (data['data'] != null && data['data'] is Map) {
            final parking = ActiveParkingModel.fromJson(data['data']);
            debugPrint('[ParkingService] Successfully parsed active parking: ${parking.idTransaksi}');
            return parking;
          }
          
          // No active parking
          debugPrint('[ParkingService] No active parking data in response');
          return null;
        } catch (e) {
          debugPrint('[ParkingService] Error parsing response: $e');
          throw Exception('Failed to parse response data');
        }
      } else if (response.statusCode == 404) {
        // No active parking found
        debugPrint('[ParkingService] No active parking found (404)');
        return null;
      } else if (response.statusCode == 401) {
        debugPrint('[ParkingService] Unauthorized (401)');
        throw Exception('Unauthorized: Invalid or expired token');
      } else if (response.statusCode >= 500) {
        debugPrint('[ParkingService] Server error (${response.statusCode})');
        throw Exception('Server error: Please try again later');
      } else {
        debugPrint('[ParkingService] Unexpected status code: ${response.statusCode}');
        throw Exception('Failed to fetch active parking: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      debugPrint('[ParkingService] Request timeout: $e');
      throw Exception('Request timeout: Please check your internet connection');
    } on http.ClientException catch (e) {
      debugPrint('[ParkingService] Network error: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } on FormatException catch (e) {
      debugPrint('[ParkingService] Invalid response format: $e');
      throw Exception('Invalid response from server');
    } catch (e) {
      debugPrint('[ParkingService] Unexpected error: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Failed to fetch active parking: $e');
    }
  }

  /// Retry mechanism for failed requests
  /// Attempts the request up to [maxRetries] times with exponential backoff
  Future<ActiveParkingModel?> getActiveParkingWithRetry({
    required String token,
    int maxRetries = 3,
  }) async {
    int attempt = 0;
    Duration delay = const Duration(seconds: 1);
    Exception? lastError;

    debugPrint('[ParkingService] Starting retry mechanism (max: $maxRetries)');

    while (attempt < maxRetries) {
      try {
        attempt++;
        debugPrint('[ParkingService] Attempt $attempt of $maxRetries');
        
        final result = await getActiveParking(token: token);
        
        if (attempt > 1) {
          debugPrint('[ParkingService] Retry successful on attempt $attempt');
        }
        
        return result;
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        debugPrint('[ParkingService] Attempt $attempt failed: $e');
        
        if (attempt >= maxRetries) {
          debugPrint('[ParkingService] All retry attempts exhausted');
          rethrow;
        }
        
        // Don't retry on auth errors
        if (e.toString().contains('Unauthorized') || e.toString().contains('401')) {
          debugPrint('[ParkingService] Auth error - not retrying');
          rethrow;
        }
        
        // Exponential backoff
        debugPrint('[ParkingService] Waiting ${delay.inSeconds}s before retry...');
        await Future.delayed(delay);
        delay *= 2;
      }
    }
    
    // This should never be reached, but just in case
    if (lastError != null) {
      throw lastError;
    }
    return null;
  }
}
