import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/point_history_model.dart';
import '../models/point_statistics_model.dart';
import '../../utils/point_error_handler.dart';

/// Service for handling point-related API operations
/// Provides methods for fetching balance, history, statistics, and using points
///
/// Requirements: 1.1, 2.1, 4.1, 6.1
class PointService {
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

  /// Get current point balance for the authenticated user
  /// 
  /// Takes authentication [token]
  /// Returns current balance as int
  /// Throws Exception on network or server errors
  /// 
  /// Requirements: 1.1
  Future<int> getBalance({required String token}) async {
    try {
      // Check if cancelled before starting
      if (_isCancelled) {
        debugPrint('[PointService] Request cancelled before starting');
        throw Exception('Request cancelled');
      }

      final uri = Uri.parse('$_baseUrl/api/points/balance');
      debugPrint('[PointService] Fetching balance at: $uri');

      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      debugPrint('[PointService] Balance response status: ${response.statusCode}');
      debugPrint('[PointService] Balance response body: ${response.body}');

      return _handleBalanceResponse(response);
    } on TimeoutException catch (e, stackTrace) {
      PointErrorHandler.logError(e, context: 'getBalance', stackTrace: stackTrace);
      throw Exception('Koneksi lambat. Silakan coba lagi.');
    } on http.ClientException catch (e, stackTrace) {
      PointErrorHandler.logError(e, context: 'getBalance', stackTrace: stackTrace);
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    } on FormatException catch (e, stackTrace) {
      PointErrorHandler.logError(e, context: 'getBalance', stackTrace: stackTrace);
      throw Exception('Format respons server tidak valid');
    } catch (e, stackTrace) {
      PointErrorHandler.logError(e, context: 'getBalance', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get point history with pagination and filtering
  /// 
  /// Takes authentication [token] and optional parameters:
  /// - [page]: Page number (default: 1)
  /// - [limit]: Items per page (default: 20)
  /// - [type]: Filter by type ('tambah' or 'kurang')
  /// - [startDate]: Filter by start date
  /// - [endDate]: Filter by end date
  /// 
  /// Returns list of PointHistory objects
  /// Throws Exception on network or server errors
  /// 
  /// Requirements: 2.1
  Future<List<PointHistory>> getHistory({
    required String token,
    int page = 1,
    int limit = 20,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Check if cancelled before starting
      if (_isCancelled) {
        debugPrint('[PointService] Request cancelled before starting');
        throw Exception('Request cancelled');
      }

      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }

      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }

      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final uri = Uri.parse('$_baseUrl/api/points/history')
          .replace(queryParameters: queryParams);
      
      debugPrint('[PointService] Fetching history at: $uri');

      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      debugPrint('[PointService] History response status: ${response.statusCode}');
      debugPrint('[PointService] History response body: ${response.body}');

      return _handleHistoryResponse(response);
    } on TimeoutException catch (e, stackTrace) {
      PointErrorHandler.logError(e, context: 'getHistory', stackTrace: stackTrace);
      throw Exception('Koneksi lambat. Silakan coba lagi.');
    } on http.ClientException catch (e, stackTrace) {
      PointErrorHandler.logError(e, context: 'getHistory', stackTrace: stackTrace);
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    } on FormatException catch (e, stackTrace) {
      PointErrorHandler.logError(e, context: 'getHistory', stackTrace: stackTrace);
      throw Exception('Format respons server tidak valid');
    } catch (e, stackTrace) {
      PointErrorHandler.logError(e, context: 'getHistory', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get point statistics (total earned, used, monthly data)
  /// 
  /// Takes authentication [token]
  /// Returns PointStatistics object with aggregated data
  /// Throws Exception on network or server errors
  /// 
  /// Requirements: 4.1
  Future<PointStatistics> getStatistics({required String token}) async {
    try {
      // Check if cancelled before starting
      if (_isCancelled) {
        debugPrint('[PointService] Request cancelled before starting');
        throw Exception('Request cancelled');
      }

      final uri = Uri.parse('$_baseUrl/api/points/statistics');
      debugPrint('[PointService] Fetching statistics at: $uri');

      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      debugPrint('[PointService] Statistics response status: ${response.statusCode}');
      debugPrint('[PointService] Statistics response body: ${response.body}');

      return _handleStatisticsResponse(response);
    } on TimeoutException catch (e, stackTrace) {
      PointErrorHandler.logError(e, context: 'getStatistics', stackTrace: stackTrace);
      throw Exception('Koneksi lambat. Silakan coba lagi.');
    } on http.ClientException catch (e, stackTrace) {
      PointErrorHandler.logError(e, context: 'getStatistics', stackTrace: stackTrace);
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    } on FormatException catch (e, stackTrace) {
      PointErrorHandler.logError(e, context: 'getStatistics', stackTrace: stackTrace);
      throw Exception('Format respons server tidak valid');
    } catch (e, stackTrace) {
      PointErrorHandler.logError(e, context: 'getStatistics', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Use points for payment
  /// 
  /// Takes authentication [token], [amount] of points to use, and [transactionId]
  /// Returns true if successful, false otherwise
  /// Throws Exception on network or server errors
  /// 
  /// Requirements: 6.1
  Future<bool> usePoints({
    required String token,
    required int amount,
    required String transactionId,
  }) async {
    try {
      // Check if cancelled before starting
      if (_isCancelled) {
        debugPrint('[PointService] Request cancelled before starting');
        throw Exception('Request cancelled');
      }

      // Validate input
      if (amount <= 0) {
        throw Exception('Jumlah poin harus lebih dari 0');
      }

      if (transactionId.isEmpty) {
        throw Exception('ID transaksi tidak valid');
      }

      final uri = Uri.parse('$_baseUrl/api/points/use');
      debugPrint('[PointService] Using points at: $uri');
      debugPrint('[PointService] Amount: $amount, Transaction ID: $transactionId');

      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'amount': amount,
          'transaction_id': transactionId,
        }),
      ).timeout(_timeout);

      debugPrint('[PointService] Use points response status: ${response.statusCode}');
      debugPrint('[PointService] Use points response body: ${response.body}');

      return _handleUsePointsResponse(response);
    } on TimeoutException catch (e, stackTrace) {
      PointErrorHandler.logError(e, context: 'usePoints', stackTrace: stackTrace);
      throw Exception('Koneksi lambat. Silakan coba lagi.');
    } on http.ClientException catch (e, stackTrace) {
      PointErrorHandler.logError(e, context: 'usePoints', stackTrace: stackTrace);
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    } on FormatException catch (e, stackTrace) {
      PointErrorHandler.logError(e, context: 'usePoints', stackTrace: stackTrace);
      throw Exception('Format respons server tidak valid');
    } catch (e, stackTrace) {
      PointErrorHandler.logError(e, context: 'usePoints', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get balance with automatic retry on failure
  /// 
  /// Attempts the request up to [maxRetries] times with exponential backoff
  /// Skips retry for auth errors
  /// 
  /// Requirements: 1.1
  Future<int> getBalanceWithRetry({
    required String token,
    int maxRetries = _maxRetries,
  }) async {
    int attempt = 0;
    Duration delay = const Duration(seconds: 1);
    Exception? lastException;

    debugPrint('[PointService] Starting balance retry mechanism (max: $maxRetries)');

    while (attempt < maxRetries) {
      try {
        attempt++;
        debugPrint('[PointService] Balance attempt $attempt of $maxRetries');

        final balance = await getBalance(token: token);

        if (attempt > 1) {
          debugPrint('[PointService] Balance retry successful on attempt $attempt');
        }

        return balance;
      } catch (e) {
        debugPrint('[PointService] Balance attempt $attempt failed: $e');
        lastException = e is Exception ? e : Exception(e.toString());

        // Don't retry on auth errors
        if (e.toString().contains('Unauthorized') || 
            e.toString().contains('401')) {
          debugPrint('[PointService] Auth error - not retrying');
          rethrow;
        }

        if (attempt >= maxRetries) {
          debugPrint('[PointService] All balance retry attempts exhausted');
          throw lastException;
        }

        // Exponential backoff
        debugPrint('[PointService] Waiting ${delay.inSeconds}s before retry...');
        await Future.delayed(delay);
        delay *= 2;
      }
    }

    throw lastException ?? Exception('Failed to get balance after $maxRetries attempts');
  }

  /// Get history with automatic retry on failure
  /// 
  /// Attempts the request up to [maxRetries] times with exponential backoff
  /// Skips retry for auth errors
  /// 
  /// Requirements: 2.1
  Future<List<PointHistory>> getHistoryWithRetry({
    required String token,
    int page = 1,
    int limit = 20,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int maxRetries = _maxRetries,
  }) async {
    int attempt = 0;
    Duration delay = const Duration(seconds: 1);
    Exception? lastException;

    debugPrint('[PointService] Starting history retry mechanism (max: $maxRetries)');

    while (attempt < maxRetries) {
      try {
        attempt++;
        debugPrint('[PointService] History attempt $attempt of $maxRetries');

        final history = await getHistory(
          token: token,
          page: page,
          limit: limit,
          type: type,
          startDate: startDate,
          endDate: endDate,
        );

        if (attempt > 1) {
          debugPrint('[PointService] History retry successful on attempt $attempt');
        }

        return history;
      } catch (e) {
        debugPrint('[PointService] History attempt $attempt failed: $e');
        lastException = e is Exception ? e : Exception(e.toString());

        // Don't retry on auth errors
        if (e.toString().contains('Unauthorized') || 
            e.toString().contains('401')) {
          debugPrint('[PointService] Auth error - not retrying');
          rethrow;
        }

        if (attempt >= maxRetries) {
          debugPrint('[PointService] All history retry attempts exhausted');
          throw lastException;
        }

        // Exponential backoff
        debugPrint('[PointService] Waiting ${delay.inSeconds}s before retry...');
        await Future.delayed(delay);
        delay *= 2;
      }
    }

    throw lastException ?? Exception('Failed to get history after $maxRetries attempts');
  }

  /// Get statistics with automatic retry on failure
  /// 
  /// Attempts the request up to [maxRetries] times with exponential backoff
  /// Skips retry for auth errors
  /// 
  /// Requirements: 4.1
  Future<PointStatistics> getStatisticsWithRetry({
    required String token,
    int maxRetries = _maxRetries,
  }) async {
    int attempt = 0;
    Duration delay = const Duration(seconds: 1);
    Exception? lastException;

    debugPrint('[PointService] Starting statistics retry mechanism (max: $maxRetries)');

    while (attempt < maxRetries) {
      try {
        attempt++;
        debugPrint('[PointService] Statistics attempt $attempt of $maxRetries');

        final statistics = await getStatistics(token: token);

        if (attempt > 1) {
          debugPrint('[PointService] Statistics retry successful on attempt $attempt');
        }

        return statistics;
      } catch (e) {
        debugPrint('[PointService] Statistics attempt $attempt failed: $e');
        lastException = e is Exception ? e : Exception(e.toString());

        // Don't retry on auth errors
        if (e.toString().contains('Unauthorized') || 
            e.toString().contains('401')) {
          debugPrint('[PointService] Auth error - not retrying');
          rethrow;
        }

        if (attempt >= maxRetries) {
          debugPrint('[PointService] All statistics retry attempts exhausted');
          throw lastException;
        }

        // Exponential backoff
        debugPrint('[PointService] Waiting ${delay.inSeconds}s before retry...');
        await Future.delayed(delay);
        delay *= 2;
      }
    }

    throw lastException ?? Exception('Failed to get statistics after $maxRetries attempts');
  }

  /// Use points with automatic retry on failure
  /// 
  /// Attempts the request up to [maxRetries] times with exponential backoff
  /// Skips retry for validation and auth errors
  /// 
  /// Requirements: 6.1
  Future<bool> usePointsWithRetry({
    required String token,
    required int amount,
    required String transactionId,
    int maxRetries = _maxRetries,
  }) async {
    int attempt = 0;
    Duration delay = const Duration(seconds: 1);
    Exception? lastException;

    debugPrint('[PointService] Starting use points retry mechanism (max: $maxRetries)');

    while (attempt < maxRetries) {
      try {
        attempt++;
        debugPrint('[PointService] Use points attempt $attempt of $maxRetries');

        final success = await usePoints(
          token: token,
          amount: amount,
          transactionId: transactionId,
        );

        if (attempt > 1) {
          debugPrint('[PointService] Use points retry successful on attempt $attempt');
        }

        return success;
      } catch (e) {
        debugPrint('[PointService] Use points attempt $attempt failed: $e');
        lastException = e is Exception ? e : Exception(e.toString());

        // Don't retry on validation or auth errors
        if (e.toString().contains('Unauthorized') || 
            e.toString().contains('401') ||
            e.toString().contains('tidak valid') ||
            e.toString().contains('tidak cukup')) {
          debugPrint('[PointService] Non-retryable error - returning');
          rethrow;
        }

        if (attempt >= maxRetries) {
          debugPrint('[PointService] All use points retry attempts exhausted');
          throw lastException;
        }

        // Exponential backoff
        debugPrint('[PointService] Waiting ${delay.inSeconds}s before retry...');
        await Future.delayed(delay);
        delay *= 2;
      }
    }

    throw lastException ?? Exception('Failed to use points after $maxRetries attempts');
  }

  /// Handle balance response and parse into int
  int _handleBalanceResponse(http.Response response) {
    try {
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        debugPrint('[PointService] Balance fetched successfully');
        
        // Handle different response formats
        if (data['balance'] != null) {
          return _parseInt(data['balance']);
        } else if (data['data'] != null && data['data']['balance'] != null) {
          return _parseInt(data['data']['balance']);
        } else if (data['saldo_poin'] != null) {
          return _parseInt(data['saldo_poin']);
        } else if (data['data'] != null && data['data']['saldo_poin'] != null) {
          return _parseInt(data['data']['saldo_poin']);
        }

        debugPrint('[PointService] No balance field in response, returning 0');
        return 0;
      } else if (response.statusCode == 401) {
        debugPrint('[PointService] Unauthorized (401)');
        throw Exception('Sesi Anda telah berakhir. Silakan login kembali.');
      } else if (response.statusCode == 404) {
        debugPrint('[PointService] User not found (404)');
        throw Exception('Data pengguna tidak ditemukan');
      } else if (response.statusCode >= 500) {
        debugPrint('[PointService] Server error (${response.statusCode})');
        throw Exception('Terjadi kesalahan server. Coba lagi nanti.');
      } else {
        debugPrint('[PointService] Unexpected status: ${response.statusCode}');
        final message = data['message']?.toString() ?? 'Terjadi kesalahan';
        throw Exception(message);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      debugPrint('[PointService] Error handling balance response: $e');
      throw Exception('Gagal memproses respons server');
    }
  }

  /// Handle history response and parse into list of PointHistory
  List<PointHistory> _handleHistoryResponse(http.Response response) {
    try {
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        debugPrint('[PointService] History fetched successfully');
        
        // Handle different response formats
        List<dynamic> historyList = [];
        
        if (data['data'] is List) {
          historyList = data['data'];
        } else if (data['data'] != null && data['data']['data'] is List) {
          historyList = data['data']['data'];
        } else if (data['history'] is List) {
          historyList = data['history'];
        } else if (data is List) {
          historyList = data;
        }

        return historyList
            .map((item) => PointHistory.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        debugPrint('[PointService] Unauthorized (401)');
        throw Exception('Sesi Anda telah berakhir. Silakan login kembali.');
      } else if (response.statusCode == 404) {
        debugPrint('[PointService] No history found (404)');
        return []; // Return empty list for no history
      } else if (response.statusCode >= 500) {
        debugPrint('[PointService] Server error (${response.statusCode})');
        throw Exception('Terjadi kesalahan server. Coba lagi nanti.');
      } else {
        debugPrint('[PointService] Unexpected status: ${response.statusCode}');
        final message = data['message']?.toString() ?? 'Terjadi kesalahan';
        throw Exception(message);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      debugPrint('[PointService] Error handling history response: $e');
      throw Exception('Gagal memproses respons server');
    }
  }

  /// Handle statistics response and parse into PointStatistics
  PointStatistics _handleStatisticsResponse(http.Response response) {
    try {
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        debugPrint('[PointService] Statistics fetched successfully');
        
        // Handle different response formats
        if (data['data'] != null && data['data'] is Map) {
          return PointStatistics.fromJson(data['data'] as Map<String, dynamic>);
        } else if (data is Map && data.containsKey('total_earned')) {
          return PointStatistics.fromJson(data as Map<String, dynamic>);
        } else {
          // Return empty statistics if format is unclear
          debugPrint('[PointService] Unclear statistics format, returning zeros');
          return PointStatistics(
            totalEarned: 0,
            totalUsed: 0,
            thisMonthEarned: 0,
            thisMonthUsed: 0,
          );
        }
      } else if (response.statusCode == 401) {
        debugPrint('[PointService] Unauthorized (401)');
        throw Exception('Sesi Anda telah berakhir. Silakan login kembali.');
      } else if (response.statusCode == 404) {
        debugPrint('[PointService] No statistics found (404)');
        // Return empty statistics for new users
        return PointStatistics(
          totalEarned: 0,
          totalUsed: 0,
          thisMonthEarned: 0,
          thisMonthUsed: 0,
        );
      } else if (response.statusCode >= 500) {
        debugPrint('[PointService] Server error (${response.statusCode})');
        throw Exception('Terjadi kesalahan server. Coba lagi nanti.');
      } else {
        debugPrint('[PointService] Unexpected status: ${response.statusCode}');
        final message = data['message']?.toString() ?? 'Terjadi kesalahan';
        throw Exception(message);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      debugPrint('[PointService] Error handling statistics response: $e');
      throw Exception('Gagal memproses respons server');
    }
  }

  /// Handle use points response and return success status
  bool _handleUsePointsResponse(http.Response response) {
    try {
      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[PointService] Points used successfully');
        
        // Check for success indicator
        if (data['success'] == true || data['success'] == 1) {
          return true;
        } else if (data['data'] != null && 
                   (data['data']['success'] == true || data['data']['success'] == 1)) {
          return true;
        }
        
        // If no explicit success field, assume success based on status code
        return true;
      } else if (response.statusCode == 400) {
        debugPrint('[PointService] Validation error (400)');
        final message = data['message']?.toString() ?? 'Data tidak valid';
        throw Exception(message);
      } else if (response.statusCode == 401) {
        debugPrint('[PointService] Unauthorized (401)');
        throw Exception('Sesi Anda telah berakhir. Silakan login kembali.');
      } else if (response.statusCode == 402 || response.statusCode == 403) {
        debugPrint('[PointService] Insufficient points (${response.statusCode})');
        throw Exception('Poin Anda tidak cukup');
      } else if (response.statusCode == 404) {
        debugPrint('[PointService] Transaction not found (404)');
        throw Exception('Transaksi tidak ditemukan');
      } else if (response.statusCode >= 500) {
        debugPrint('[PointService] Server error (${response.statusCode})');
        throw Exception('Terjadi kesalahan server. Coba lagi nanti.');
      } else {
        debugPrint('[PointService] Unexpected status: ${response.statusCode}');
        final message = data['message']?.toString() ?? 'Terjadi kesalahan';
        throw Exception(message);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      debugPrint('[PointService] Error handling use points response: $e');
      throw Exception('Gagal memproses respons server');
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

  /// Cancel all pending API requests
  ///
  /// Call this when the point page is disposed to prevent
  /// memory leaks and unnecessary network operations.
  void cancelPendingRequests() {
    debugPrint('[PointService] Cancelling all pending requests');
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
    debugPrint('[PointService] Disposing service');
    _isCancelled = true;
    _client.close();
  }
}
