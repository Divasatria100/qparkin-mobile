import 'package:intl/intl.dart';

/// Model representing point usage statistics
///
/// This model aggregates point transaction data to provide insights
/// about user's point earning and spending patterns.
///
/// Business Logic:
/// - 1 poin = Rp100 discount value
/// - Provides derived metrics for analytics
///
/// Requirements: 1.2, 1.4
class PointStatisticsModel {
  final int totalEarned;
  final int totalUsed;
  final int currentBalance;
  final int transactionCount;
  final DateTime? lastTransaction;

  PointStatisticsModel({
    required this.totalEarned,
    required this.totalUsed,
    required this.currentBalance,
    required this.transactionCount,
    this.lastTransaction,
  });

  /// Calculate net points (earned - used)
  int get netPoints => totalEarned - totalUsed;
  
  /// Calculate the usage rate (percentage of points used vs earned)
  double get usageRate {
    if (totalEarned == 0) return 0.0;
    return (totalUsed / totalEarned);
  }
  
  /// Calculate the percentage of points used vs earned (0-100)
  double get usagePercentage => usageRate * 100;
  
  /// Get equivalent Rupiah value of current balance (1 poin = Rp100)
  int get equivalentValue => currentBalance * 100;
  
  /// Get formatted equivalent value
  String get formattedEquivalentValue {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(equivalentValue);
  }

  /// Check if user has ever earned points
  bool get hasEarnedPoints => totalEarned > 0;

  /// Check if user has ever used points
  bool get hasUsedPoints => totalUsed > 0;

  /// Check if user has any transactions
  bool get hasTransactions => transactionCount > 0;

  /// Get formatted total earned with label
  String get formattedTotalEarned => '+$totalEarned Poin';

  /// Get formatted total used with label
  String get formattedTotalUsed => '-$totalUsed Poin';

  /// Get formatted current balance with label
  String get formattedCurrentBalance => '$currentBalance Poin';

  /// Create PointStatisticsModel from JSON
  /// Handles both snake_case and camelCase field names
  /// Throws FormatException if data is invalid
  factory PointStatisticsModel.fromJson(Map<String, dynamic> json) {
    try {
      return PointStatisticsModel(
        totalEarned: json['total_earned'] ?? json['totalEarned'] ?? 0,
        totalUsed: json['total_used'] ?? json['totalUsed'] ?? 0,
        currentBalance: json['current_balance'] ?? json['currentBalance'] ?? 0,
        transactionCount: json['transaction_count'] ?? json['transactionCount'] ?? 0,
        lastTransaction: json['last_transaction'] != null
            ? DateTime.parse(json['last_transaction'])
            : null,
      );
    } catch (e) {
      throw FormatException('Invalid PointStatisticsModel JSON: $e');
    }
  }

  /// Convert PointStatisticsModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'total_earned': totalEarned,
      'total_used': totalUsed,
      'current_balance': currentBalance,
      'transaction_count': transactionCount,
      'last_transaction': lastTransaction?.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  PointStatisticsModel copyWith({
    int? totalEarned,
    int? totalUsed,
    int? currentBalance,
    int? transactionCount,
    DateTime? lastTransaction,
  }) {
    return PointStatisticsModel(
      totalEarned: totalEarned ?? this.totalEarned,
      totalUsed: totalUsed ?? this.totalUsed,
      currentBalance: currentBalance ?? this.currentBalance,
      transactionCount: transactionCount ?? this.transactionCount,
      lastTransaction: lastTransaction ?? this.lastTransaction,
    );
  }

  /// Create empty statistics
  factory PointStatisticsModel.empty() {
    return PointStatisticsModel(
      totalEarned: 0,
      totalUsed: 0,
      currentBalance: 0,
      transactionCount: 0,
      lastTransaction: null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PointStatisticsModel &&
        other.totalEarned == totalEarned &&
        other.totalUsed == totalUsed &&
        other.currentBalance == currentBalance &&
        other.transactionCount == transactionCount &&
        other.lastTransaction == lastTransaction;
  }

  @override
  int get hashCode {
    return totalEarned.hashCode ^
        totalUsed.hashCode ^
        currentBalance.hashCode ^
        transactionCount.hashCode ^
        lastTransaction.hashCode;
  }

  @override
  String toString() {
    return 'PointStatisticsModel(totalEarned: $totalEarned, totalUsed: $totalUsed, currentBalance: $currentBalance, transactionCount: $transactionCount, lastTransaction: $lastTransaction)';
  }
}
