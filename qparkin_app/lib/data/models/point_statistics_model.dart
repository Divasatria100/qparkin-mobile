class PointStatistics {
  final int totalEarned;
  final int totalUsed;
  final int thisMonthEarned;
  final int thisMonthUsed;

  PointStatistics({
    required this.totalEarned,
    required this.totalUsed,
    required this.thisMonthEarned,
    required this.thisMonthUsed,
  });

  /// Get net balance (total earned - total used)
  int get netBalance => totalEarned - totalUsed;

  /// Get this month's net balance
  int get thisMonthNet => thisMonthEarned - thisMonthUsed;

  /// Get formatted total earned with thousand separators
  String get formattedTotalEarned => _formatNumber(totalEarned);

  /// Get formatted total used with thousand separators
  String get formattedTotalUsed => _formatNumber(totalUsed);

  /// Get formatted this month earned with thousand separators
  String get formattedThisMonthEarned => _formatNumber(thisMonthEarned);

  /// Get formatted this month used with thousand separators
  String get formattedThisMonthUsed => _formatNumber(thisMonthUsed);

  /// Get formatted net balance with thousand separators
  String get formattedNetBalance => _formatNumber(netBalance);

  /// Get formatted this month net with thousand separators
  String get formattedThisMonthNet => _formatNumber(thisMonthNet);

  /// Check if user has earned any points
  bool get hasEarnedPoints => totalEarned > 0;

  /// Check if user has used any points
  bool get hasUsedPoints => totalUsed > 0;

  /// Check if user has earned points this month
  bool get hasEarnedThisMonth => thisMonthEarned > 0;

  /// Check if user has used points this month
  bool get hasUsedThisMonth => thisMonthUsed > 0;

  /// Validate statistics data
  bool validate() {
    if (totalEarned < 0) return false;
    if (totalUsed < 0) return false;
    if (thisMonthEarned < 0) return false;
    if (thisMonthUsed < 0) return false;
    if (thisMonthEarned > totalEarned) return false;
    if (thisMonthUsed > totalUsed) return false;
    return true;
  }

  /// Create PointStatistics from JSON
  factory PointStatistics.fromJson(Map<String, dynamic> json) {
    return PointStatistics(
      totalEarned: _parseInt(json['total_earned']),
      totalUsed: _parseInt(json['total_used']),
      thisMonthEarned: _parseInt(json['this_month_earned']),
      thisMonthUsed: _parseInt(json['this_month_used']),
    );
  }

  /// Convert PointStatistics to JSON
  Map<String, dynamic> toJson() {
    return {
      'total_earned': totalEarned,
      'total_used': totalUsed,
      'this_month_earned': thisMonthEarned,
      'this_month_used': thisMonthUsed,
    };
  }

  /// Helper method to safely parse int values from JSON
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Helper method to format numbers with thousand separators
  static String _formatNumber(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }

    return buffer.toString();
  }

  /// Create a copy of this model with updated fields
  PointStatistics copyWith({
    int? totalEarned,
    int? totalUsed,
    int? thisMonthEarned,
    int? thisMonthUsed,
  }) {
    return PointStatistics(
      totalEarned: totalEarned ?? this.totalEarned,
      totalUsed: totalUsed ?? this.totalUsed,
      thisMonthEarned: thisMonthEarned ?? this.thisMonthEarned,
      thisMonthUsed: thisMonthUsed ?? this.thisMonthUsed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PointStatistics &&
        other.totalEarned == totalEarned &&
        other.totalUsed == totalUsed &&
        other.thisMonthEarned == thisMonthEarned &&
        other.thisMonthUsed == thisMonthUsed;
  }

  @override
  int get hashCode =>
      totalEarned.hashCode ^
      totalUsed.hashCode ^
      thisMonthEarned.hashCode ^
      thisMonthUsed.hashCode;
}
