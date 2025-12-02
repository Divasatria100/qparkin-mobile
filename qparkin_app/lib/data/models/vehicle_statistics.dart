/// Model representing usage statistics for a vehicle
class VehicleStatistics {
  /// Total number of parking sessions for this vehicle
  final int parkingCount;

  /// Total parking time in minutes
  final int totalParkingMinutes;

  /// Total cost spent on parking with this vehicle
  final double totalCostSpent;

  /// Last parking date (null if never parked)
  final DateTime? lastParkingDate;

  VehicleStatistics({
    this.parkingCount = 0,
    this.totalParkingMinutes = 0,
    this.totalCostSpent = 0.0,
    this.lastParkingDate,
  });

  /// Get formatted total parking time (e.g., "5 jam 30 menit")
  String get formattedTotalTime {
    if (totalParkingMinutes == 0) {
      return '0 menit';
    }

    final hours = totalParkingMinutes ~/ 60;
    final minutes = totalParkingMinutes % 60;

    if (hours == 0) {
      return '$minutes menit';
    } else if (minutes == 0) {
      return '$hours jam';
    } else {
      return '$hours jam $minutes menit';
    }
  }

  /// Get formatted total cost with thousand separators (e.g., "Rp 150.000")
  String get formattedTotalCost {
    final intAmount = totalCostSpent.toInt();
    final str = intAmount.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }

    return 'Rp ${buffer.toString()}';
  }

  /// Get average parking duration in minutes
  double get averageParkingMinutes {
    if (parkingCount == 0) return 0.0;
    return totalParkingMinutes / parkingCount;
  }

  /// Get formatted average parking time
  String get formattedAverageTime {
    final avgMinutes = averageParkingMinutes.round();
    if (avgMinutes == 0) {
      return '0 menit';
    }

    final hours = avgMinutes ~/ 60;
    final minutes = avgMinutes % 60;

    if (hours == 0) {
      return '$minutes menit';
    } else if (minutes == 0) {
      return '$hours jam';
    } else {
      return '$hours jam $minutes menit';
    }
  }

  /// Get average cost per parking session
  double get averageCostPerSession {
    if (parkingCount == 0) return 0.0;
    return totalCostSpent / parkingCount;
  }

  /// Get formatted average cost
  String get formattedAverageCost {
    final avgCost = averageCostPerSession.toInt();
    final str = avgCost.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }

    return 'Rp ${buffer.toString()}';
  }

  /// Create VehicleStatistics from JSON
  factory VehicleStatistics.fromJson(Map<String, dynamic> json) {
    return VehicleStatistics(
      parkingCount: _parseInt(json['parking_count']),
      totalParkingMinutes: _parseInt(json['total_parking_minutes']),
      totalCostSpent: _parseDouble(json['total_cost_spent']),
      lastParkingDate: json['last_parking_date'] != null
          ? DateTime.parse(json['last_parking_date'].toString())
          : null,
    );
  }

  /// Convert VehicleStatistics to JSON
  Map<String, dynamic> toJson() {
    return {
      'parking_count': parkingCount,
      'total_parking_minutes': totalParkingMinutes,
      'total_cost_spent': totalCostSpent,
      'last_parking_date': lastParkingDate?.toIso8601String(),
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

  /// Helper method to safely parse double values from JSON
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Create a copy of this model with updated fields
  VehicleStatistics copyWith({
    int? parkingCount,
    int? totalParkingMinutes,
    double? totalCostSpent,
    DateTime? lastParkingDate,
  }) {
    return VehicleStatistics(
      parkingCount: parkingCount ?? this.parkingCount,
      totalParkingMinutes: totalParkingMinutes ?? this.totalParkingMinutes,
      totalCostSpent: totalCostSpent ?? this.totalCostSpent,
      lastParkingDate: lastParkingDate ?? this.lastParkingDate,
    );
  }

  @override
  String toString() {
    return 'VehicleStatistics(parkingCount: $parkingCount, totalParkingMinutes: $totalParkingMinutes, totalCostSpent: $totalCostSpent, lastParkingDate: $lastParkingDate)';
  }
}
