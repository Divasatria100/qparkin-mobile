import 'point_history_model.dart';

/// Enum for point filter type
enum PointFilterType { all, addition, deduction }

/// Enum for point filter period
enum PointFilterPeriod { allTime, thisMonth, last3Months, last6Months }

class PointFilter {
  final PointFilterType type;
  final PointFilterPeriod period;

  PointFilter({
    required this.type,
    required this.period,
  });

  /// Create a filter with all options (no filtering)
  factory PointFilter.all() => PointFilter(
        type: PointFilterType.all,
        period: PointFilterPeriod.allTime,
      );

  /// Check if a point history entry matches this filter
  bool matches(PointHistory history) {
    // Check type filter
    if (type == PointFilterType.addition && !history.isAddition) {
      return false;
    }
    if (type == PointFilterType.deduction && !history.isDeduction) {
      return false;
    }

    // Check period filter
    final now = DateTime.now();
    switch (period) {
      case PointFilterPeriod.thisMonth:
        return history.waktu.year == now.year &&
            history.waktu.month == now.month;
      case PointFilterPeriod.last3Months:
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        return history.waktu.isAfter(threeMonthsAgo);
      case PointFilterPeriod.last6Months:
        final sixMonthsAgo = DateTime(now.year, now.month - 6, now.day);
        return history.waktu.isAfter(sixMonthsAgo);
      default:
        return true;
    }
  }

  /// Get display text for the current filter
  String get displayText {
    final typeText = type == PointFilterType.all
        ? 'Semua'
        : type == PointFilterType.addition
            ? 'Penambahan'
            : 'Pengurangan';
    final periodText = period == PointFilterPeriod.allTime
        ? 'Semua Waktu'
        : period == PointFilterPeriod.thisMonth
            ? 'Bulan Ini'
            : period == PointFilterPeriod.last3Months
                ? '3 Bulan Terakhir'
                : '6 Bulan Terakhir';
    return '$typeText • $periodText';
  }

  /// Get short display text for type filter
  String get typeDisplayText {
    switch (type) {
      case PointFilterType.all:
        return 'Semua';
      case PointFilterType.addition:
        return 'Penambahan';
      case PointFilterType.deduction:
        return 'Pengurangan';
    }
  }

  /// Get short display text for period filter
  String get periodDisplayText {
    switch (period) {
      case PointFilterPeriod.allTime:
        return 'Semua Waktu';
      case PointFilterPeriod.thisMonth:
        return 'Bulan Ini';
      case PointFilterPeriod.last3Months:
        return '3 Bulan Terakhir';
      case PointFilterPeriod.last6Months:
        return '6 Bulan Terakhir';
    }
  }

  /// Check if this filter is the default (all) filter
  bool get isDefault =>
      type == PointFilterType.all && period == PointFilterPeriod.allTime;

  /// Check if any filter is active
  bool get isActive => !isDefault;

  /// Get count of active filters
  int get activeFilterCount {
    int count = 0;
    if (type != PointFilterType.all) count++;
    if (period != PointFilterPeriod.allTime) count++;
    return count;
  }

  /// Create PointFilter from JSON
  factory PointFilter.fromJson(Map<String, dynamic> json) {
    return PointFilter(
      type: _parseFilterType(json['type']),
      period: _parseFilterPeriod(json['period']),
    );
  }

  /// Convert PointFilter to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'period': period.toString().split('.').last,
    };
  }

  /// Helper method to parse filter type from string
  static PointFilterType _parseFilterType(dynamic value) {
    if (value == null) return PointFilterType.all;
    final str = value.toString().toLowerCase();
    if (str == 'addition') return PointFilterType.addition;
    if (str == 'deduction') return PointFilterType.deduction;
    return PointFilterType.all;
  }

  /// Helper method to parse filter period from string
  static PointFilterPeriod _parseFilterPeriod(dynamic value) {
    if (value == null) return PointFilterPeriod.allTime;
    final str = value.toString().toLowerCase();
    if (str == 'thismonth') return PointFilterPeriod.thisMonth;
    if (str == 'last3months') return PointFilterPeriod.last3Months;
    if (str == 'last6months') return PointFilterPeriod.last6Months;
    return PointFilterPeriod.allTime;
  }

  /// Create a copy of this filter with updated fields
  PointFilter copyWith({
    PointFilterType? type,
    PointFilterPeriod? period,
  }) {
    return PointFilter(
      type: type ?? this.type,
      period: period ?? this.period,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PointFilter &&
        other.type == type &&
        other.period == period;
  }

  @override
  int get hashCode => type.hashCode ^ period.hashCode;
}
