import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/point_history_model.dart';
import '../models/point_statistics_model.dart';
import '../../utils/point_test_data.dart';

/// Service for point-related API operations
///
/// Business Logic Constants:
/// - Earning Rate: 1 poin per Rp1.000 pembayaran
/// - Redemption Value: 1 poin = Rp100 diskon
/// - Maximum Discount: 30% dari total biaya parkir
/// - Minimum Redemption: 10 poin
///
/// Phase 1: Mock implementation with test data
/// Phase 2: Will integrate with real backend API
///
/// Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.7, 2.8, 2.9, 2.10
class PointService {
  final http.Client _httpClient;
  final String _baseUrl;
  
  // Business logic constants
  static const int earningRate = 1000; // 1 poin per Rp1.000
  static const int redemptionValue = 100; // 1 poin = Rp100
  static const double maxDiscountPercent = 0.30; // 30%
  static const int minRedemption = 10; // minimum 10 poin
  
  // Retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Simulate network delay (for mock mode)
  static const Duration _networkDelay = Duration(milliseconds: 800);
  
  PointService({
    http.Client? httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? 'http://localhost:8000';

  // ============================================================================
  // BUSINESS LOGIC METHODS
  // ============================================================================
  
  /// Calculate earned points from parking cost
  /// Formula: parkingCost / 1000 (rounded down)
  /// Example: Rp50.000 → 50 poin
  ///
  /// Requirements: 10.1
  int calculateEarnedPoints(int parkingCost) {
    if (parkingCost < 0) return 0;
    return parkingCost ~/ earningRate;
  }
  
  /// Calculate discount amount from points
  /// Formula: points × 100
  /// Example: 100 poin → Rp10.000
  ///
  /// Requirements: 10.2
  int calculateDiscountAmount(int points) {
    if (points < 0) return 0;
    return points * redemptionValue;
  }
  
  /// Calculate maximum allowed points for a given parking cost
  /// Formula: (parkingCost × 0.30) / 100
  /// Example: Rp100.000 → max 300 poin (Rp30.000 discount)
  ///
  /// Requirements: 10.3
  int calculateMaxAllowedPoints(int parkingCost) {
    if (parkingCost < 0) return 0;
    final maxDiscount = (parkingCost * maxDiscountPercent).floor();
    return maxDiscount ~/ redemptionValue;
  }
  
  /// Validate point usage
  /// Returns true if points can be used, false otherwise
  ///
  /// Validation rules:
  /// - Points must be >= minRedemption (10)
  /// - Points must be <= userBalance
  /// - Discount must not exceed 30% of parkingCost
  ///
  /// Requirements: 2.3, 2.5, 10.3, 10.4, 10.5
  bool validatePointUsage(int points, int parkingCost, int userBalance) {
    // Check minimum redemption
    if (points < minRedemption) {
      debugPrint('[PointService] Validation failed: Below minimum ($minRedemption poin)');
      return false;
    }
    
    // Check user balance
    if (points > userBalance) {
      debugPrint('[PointService] Validation failed: Insufficient balance');
      return false;
    }
    
    // Check 30% discount limit
    final maxAllowed = calculateMaxAllowedPoints(parkingCost);
    if (points > maxAllowed) {
      debugPrint('[PointService] Validation failed: Exceeds 30% limit (max: $maxAllowed poin)');
      return false;
    }
    
    return true;
  }
  
  /// Get validation error message
  /// Returns null if valid, error message if invalid
  ///
  /// Requirements: 10.5, 11.4
  String? getValidationError(int points, int parkingCost, int userBalance) {
    if (points < minRedemption) {
      return 'Minimum penggunaan $minRedemption poin (Rp${minRedemption * redemptionValue})';
    }
    
    if (points > userBalance) {
      final needed = points - userBalance;
      return 'Poin tidak mencukupi. Anda memiliki $userBalance poin. Butuh $needed poin lagi.';
    }
    
    final maxAllowed = calculateMaxAllowedPoints(parkingCost);
    if (points > maxAllowed) {
      final maxDiscount = calculateDiscountAmount(maxAllowed);
      return 'Maksimal diskon 30%. Anda dapat menggunakan maksimal $maxAllowed poin (Rp$maxDiscount) untuk booking ini.';
    }
    
    return null;
  }
  
  // ============================================================================
  // API METHODS
  // ============================================================================
  
  /// Get current point balance
  ///
  /// Phase 1: Returns mock balance
  /// Phase 2: Will call GET /api/points/balance
  ///
  /// Requirements: 2.1, 2.6, 2.9
  Future<int> getBalance({required String token}) async {
    debugPrint('[PointService] Fetching balance (mock)...');
    
    // Simulate network delay
    await Future.delayed(_networkDelay);
    
    // Return mock balance
    final mockBalance = PointTestData.mockBalance;
    debugPrint('[PointService] Balance fetched: $mockBalance');
    
    return mockBalance;
  }

  /// Get point history with pagination
  ///
  /// Phase 1: Returns mock history
  /// Phase 2: Will call GET /api/points/history?page={page}&limit={limit}
  ///
  /// Requirements: 2.2, 2.6, 2.9
  Future<List<PointHistoryModel>> getHistory({
    required String token,
    int page = 1,
    int limit = 20,
  }) async {
    debugPrint('[PointService] Fetching history (page: $page, limit: $limit) (mock)...');
    
    // Simulate network delay
    await Future.delayed(_networkDelay);
    
    // Generate mock history
    final allHistory = PointTestData.generateSampleHistory();
    
    // Simulate pagination
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    
    if (startIndex >= allHistory.length) {
      debugPrint('[PointService] No more history (page $page)');
      return [];
    }
    
    final paginatedHistory = allHistory.sublist(
      startIndex,
      endIndex > allHistory.length ? allHistory.length : endIndex,
    );
    
    debugPrint('[PointService] History fetched: ${paginatedHistory.length} items');
    
    return paginatedHistory;
  }

  /// Get point statistics
  ///
  /// Phase 1: Returns mock statistics
  /// Phase 2: Will call GET /api/points/statistics
  ///
  /// Requirements: 2.2, 2.6, 2.9
  Future<PointStatisticsModel> getStatistics({required String token}) async {
    debugPrint('[PointService] Fetching statistics (mock)...');
    
    // Simulate network delay
    await Future.delayed(_networkDelay);
    
    // Generate mock statistics
    final mockStats = PointTestData.generateMockStatistics();
    
    debugPrint('[PointService] Statistics fetched: ${mockStats.toJson()}');
    
    return mockStats;
  }

  /// Earn points after successful parking payment
  ///
  /// Phase 1: Simulates point earning
  /// Phase 2: Will call POST /api/points/earn
  ///
  /// Requirements: 2.4, 8.4, 10.1
  Future<Map<String, dynamic>> earnPoints({
    required String transactionId,
    required int parkingCost,
    required String token,
  }) async {
    debugPrint('[PointService] Earning points for transaction $transactionId (cost: Rp$parkingCost) (mock)...');
    
    // Calculate earned points
    final pointsEarned = calculateEarnedPoints(parkingCost);
    
    // Simulate network delay
    await Future.delayed(_networkDelay);
    
    // Simulate API response
    final response = {
      'pointsEarned': pointsEarned,
      'newBalance': 150 + pointsEarned, // Mock new balance
      'transactionId': transactionId,
    };
    
    debugPrint('[PointService] Points earned: $pointsEarned, new balance: ${response['newBalance']}');
    
    return response;
  }
  
  /// Use points for booking discount
  ///
  /// Phase 1: Simulates point usage with validation
  /// Phase 2: Will call POST /api/points/use
  ///
  /// Requirements: 2.4, 2.5, 8.5, 8.6, 10.2, 10.3, 10.6
  Future<Map<String, dynamic>> usePoints({
    required String bookingId,
    required int pointAmount,
    required int parkingCost,
    required String token,
  }) async {
    debugPrint('[PointService] Using $pointAmount points for booking $bookingId (cost: Rp$parkingCost) (mock)...');
    
    // Validate before API call (client-side validation)
    final mockBalance = 200; // Mock current balance
    if (!validatePointUsage(pointAmount, parkingCost, mockBalance)) {
      final error = getValidationError(pointAmount, parkingCost, mockBalance);
      throw Exception(error ?? 'Invalid point usage');
    }
    
    // Calculate discount
    final discountAmount = calculateDiscountAmount(pointAmount);
    final finalCost = parkingCost - discountAmount;
    
    // Simulate network delay
    await Future.delayed(_networkDelay);
    
    // Simulate API response
    final response = {
      'discountAmount': discountAmount,
      'pointsUsed': pointAmount,
      'newBalance': mockBalance - pointAmount,
      'finalCost': finalCost,
      'bookingId': bookingId,
    };
    
    debugPrint('[PointService] Points used: $pointAmount, discount: Rp$discountAmount, final cost: Rp$finalCost');
    
    return response;
  }
  
  /// Refund points for cancelled booking
  ///
  /// Phase 1: Simulates point refund
  /// Phase 2: Will call POST /api/points/refund
  ///
  /// Requirements: 2.6, 8.7, 10.7
  Future<Map<String, dynamic>> refundPoints({
    required String bookingId,
    required String token,
  }) async {
    debugPrint('[PointService] Refunding points for booking $bookingId (mock)...');
    
    // Simulate network delay
    await Future.delayed(_networkDelay);
    
    // Simulate API response
    final mockRefundAmount = 100; // Mock refund amount
    final response = {
      'pointsRefunded': mockRefundAmount,
      'newBalance': 150 + mockRefundAmount,
      'bookingId': bookingId,
    };
    
    debugPrint('[PointService] Points refunded: $mockRefundAmount, new balance: ${response['newBalance']}');
    
    return response;
  }
  
  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  /// Execute operation with retry logic
  /// Retries up to maxRetries times with exponential backoff
  ///
  /// Requirements: 2.7
  Future<T> _executeWithRetry<T>(Future<T> Function() operation) async {
    int attempts = 0;
    Duration delay = retryDelay;
    
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          debugPrint('[PointService] Max retries reached, throwing error');
          rethrow;
        }
        
        debugPrint('[PointService] Attempt $attempts failed, retrying in ${delay.inSeconds}s...');
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      }
    }
    
    throw Exception('Operation failed after $maxRetries attempts');
  }
  
  /// Build headers for API requests
  ///
  /// Requirements: 2.6, 2.9
  Map<String, String> _buildHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Dispose service resources
  void dispose() {
    debugPrint('[PointService] Disposing service');
    _httpClient.close();
  }
}
