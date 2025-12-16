import 'point_history_model.dart';

/// Model representing filter criteria for point history
///
/// This model defines filter options for point transaction history,
/// allowing users to filter by type, date range, and amount range.
///
/// Requirements: 3.1
class PointFilter {
  final String? type; // 'all', 'earned', 'used'
  final DateTime? startDate;
  final DateTime? endDate;
  final int? minAmount;
  final int? maxAmount;

  PointFilter({
    this.type,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
  });

  /// Check if any filter is active
  bool get isActive {
    return type != null && type != 'all' ||
        startDate != null ||
        endDate != null ||
        minAmount != null ||
        maxAmount != null;
  }

  /// Get display text for current filter
  String get displayText {
    if (!isActive) return 'Semua';

    final List<String> parts = [];

    if (type == 'earned') {
      parts.add('Diperoleh');
    } else if (type == 'used') {
      parts.add('Digunakan');
    }

    if (startDate != null || endDate != null) {
      parts.add('Tanggal');
    }

    if (minAmount != null || maxAmount != null) {
      parts.add('Jumlah');
    }

    return parts.join(', ');
  }

  /// Check if a point history item matches this filter
  bool matches(PointHistory item) {
    // Type filter
    if (type != null && type != 'all') {
      if (type == 'earned' && !item.isAddition) return false;
      if (type == 'used' && !item.isDeduction) return false;
    }

    // Date range filter
    if (startDate != null && item.waktu.isBefore(startDate!)) {
      return false;
    }
    if (endDate != null && item.waktu.isAfter(endDate!)) {
      return false;
    }

    // Amount range filter
    if (minAmount != null && item.poin < minAmount!) {
      return false;
    }
    if (maxAmount != null && item.poin > maxAmount!) {
      return false;
    }

    return true;
  }

  /// Create filter for all transactions
  factory PointFilter.all() {
    return PointFilter(type: 'all');
  }

  /// Create filter for earned points only
  factory PointFilter.earned() {
    return PointFilter(type: 'earned');
  }

  /// Create filter for used points only
  factory PointFilter.used() {
    return PointFilter(type: 'used');
  }

  /// Create filter for date range
  factory PointFilter.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return PointFilter(
      type: 'all',
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Create filter for amount range
  factory PointFilter.amountRange({
    required int minAmount,
    required int maxAmount,
  }) {
    return PointFilter(
      type: 'all',
      minAmount: minAmount,
      maxAmount: maxAmount,
    );
  }

  /// Create a copy with modified fields
  PointFilter copyWith({
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int? minAmount,
    int? maxAmount,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearMinAmount = false,
    bool clearMaxAmount = false,
  }) {
    return PointFilter(
      type: type ?? this.type,
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
    );
  }

  /// Create PointFilter from JSON
  factory PointFilter.fromJson(Map<String, dynamic> json) {
    return PointFilter(
      type: json['type'],
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,
      minAmount: json['min_amount'],
      maxAmount: json['max_amount'],
    );
  }

  /// Convert PointFilter to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'min_amount': minAmount,
      'max_amount': maxAmount,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PointFilter &&
        other.type == type &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.minAmount == minAmount &&
        other.maxAmount == maxAmount;
  }

  @override
  int get hashCode {
    return type.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        minAmount.hashCode ^
        maxAmount.hashCode;
  }

  @override
  String toString() {
    return 'PointFilter(type: $type, startDate: $startDate, endDate: $endDate, minAmount: $minAmount, maxAmount: $maxAmount)';
  }
}
