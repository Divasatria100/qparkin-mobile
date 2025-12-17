import 'point_history_model.dart';

/// Enum for point filter types
enum PointFilterType {
  all,
  earned,
  used,
}

/// Model representing filter criteria for point history
///
/// This model defines filter options for point transaction history,
/// allowing users to filter by type, date range, and amount range.
///
/// Requirements: 1.3, 1.4
class PointFilterModel {
  final PointFilterType type;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? minAmount;
  final int? maxAmount;

  PointFilterModel({
    this.type = PointFilterType.all,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
  });

  /// Check if any filter is active
  bool get isActive {
    return type != PointFilterType.all ||
        startDate != null ||
        endDate != null ||
        minAmount != null ||
        maxAmount != null;
  }

  /// Get display text for current filter
  String get displayText {
    if (!isActive) return 'Semua';

    final List<String> parts = [];

    if (type == PointFilterType.earned) {
      parts.add('Diperoleh');
    } else if (type == PointFilterType.used) {
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
  bool matches(PointHistoryModel item) {
    // Type filter
    if (type != PointFilterType.all) {
      if (type == PointFilterType.earned && !item.isEarned) return false;
      if (type == PointFilterType.used && !item.isUsed) return false;
    }

    // Date range filter
    if (startDate != null && item.waktu.isBefore(startDate!)) {
      return false;
    }
    if (endDate != null && item.waktu.isAfter(endDate!)) {
      return false;
    }

    // Amount range filter (use absolute points)
    final amount = item.absolutePoints;
    if (minAmount != null && amount < minAmount!) {
      return false;
    }
    if (maxAmount != null && amount > maxAmount!) {
      return false;
    }

    return true;
  }

  /// Create filter for all transactions
  factory PointFilterModel.all() {
    return PointFilterModel(type: PointFilterType.all);
  }

  /// Create filter for earned points only
  factory PointFilterModel.earned() {
    return PointFilterModel(type: PointFilterType.earned);
  }

  /// Create filter for used points only
  factory PointFilterModel.used() {
    return PointFilterModel(type: PointFilterType.used);
  }

  /// Create filter for date range
  factory PointFilterModel.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return PointFilterModel(
      type: PointFilterType.all,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Create filter for amount range
  factory PointFilterModel.amountRange({
    required int minAmount,
    required int maxAmount,
  }) {
    return PointFilterModel(
      type: PointFilterType.all,
      minAmount: minAmount,
      maxAmount: maxAmount,
    );
  }

  /// Create a copy with modified fields
  PointFilterModel copyWith({
    PointFilterType? type,
    DateTime? startDate,
    DateTime? endDate,
    int? minAmount,
    int? maxAmount,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearMinAmount = false,
    bool clearMaxAmount = false,
  }) {
    return PointFilterModel(
      type: type ?? this.type,
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
    );
  }

  /// Create PointFilterModel from JSON
  factory PointFilterModel.fromJson(Map<String, dynamic> json) {
    PointFilterType filterType = PointFilterType.all;
    if (json['type'] != null) {
      switch (json['type'].toString().toLowerCase()) {
        case 'earned':
          filterType = PointFilterType.earned;
          break;
        case 'used':
          filterType = PointFilterType.used;
          break;
        default:
          filterType = PointFilterType.all;
      }
    }

    return PointFilterModel(
      type: filterType,
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

  /// Convert PointFilterModel to JSON
  Map<String, dynamic> toJson() {
    String typeString;
    switch (type) {
      case PointFilterType.earned:
        typeString = 'earned';
        break;
      case PointFilterType.used:
        typeString = 'used';
        break;
      default:
        typeString = 'all';
    }

    return {
      'type': typeString,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'min_amount': minAmount,
      'max_amount': maxAmount,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PointFilterModel &&
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
    return 'PointFilterModel(type: $type, startDate: $startDate, endDate: $endDate, minAmount: $minAmount, maxAmount: $maxAmount)';
  }
}
