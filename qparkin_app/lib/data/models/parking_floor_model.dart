/// Model representing a parking floor within a mall
class ParkingFloorModel {
  final String idFloor;
  final String idMall;
  final int floorNumber;
  final String floorName;
  final String? jenisKendaraan; // ✅ ADD: Vehicle type for this floor
  final int totalSlots;
  final int availableSlots;
  final int occupiedSlots;
  final int reservedSlots;
  final DateTime lastUpdated;

  ParkingFloorModel({
    required this.idFloor,
    required this.idMall,
    required this.floorNumber,
    required this.floorName,
    this.jenisKendaraan, // ✅ ADD: Optional vehicle type
    required this.totalSlots,
    required this.availableSlots,
    required this.occupiedSlots,
    required this.reservedSlots,
    required this.lastUpdated,
  });

  /// Check if floor has available slots
  bool get hasAvailableSlots => availableSlots > 0;

  /// Calculate occupancy rate (0.0 to 1.0)
  double get occupancyRate {
    if (totalSlots == 0) return 0.0;
    return (occupiedSlots + reservedSlots) / totalSlots;
  }

  /// Get formatted availability text (e.g., "12 slot tersedia")
  String get availabilityText => '$availableSlots slot tersedia';

  /// Get formatted occupancy percentage (e.g., "75%")
  String get occupancyPercentage {
    final percentage = (occupancyRate * 100).toInt();
    return '$percentage%';
  }

  /// Validate floor data
  bool validate() {
    if (idFloor.isEmpty) return false;
    if (idMall.isEmpty) return false;
    if (floorNumber < 0) return false;
    if (floorName.isEmpty) return false;
    if (totalSlots < 0) return false;
    if (availableSlots < 0) return false;
    if (occupiedSlots < 0) return false;
    if (reservedSlots < 0) return false;
    // Validate that sum of slots doesn't exceed total
    if (availableSlots + occupiedSlots + reservedSlots > totalSlots) {
      return false;
    }
    return true;
  }

  /// Create ParkingFloorModel from JSON
  factory ParkingFloorModel.fromJson(Map<String, dynamic> json) {
    return ParkingFloorModel(
      idFloor: json['id_floor']?.toString() ?? '',
      idMall: json['id_mall']?.toString() ?? '',
      floorNumber: _parseInt(json['floor_number']),
      floorName: json['floor_name']?.toString() ?? '',
      jenisKendaraan: json['jenis_kendaraan']?.toString(), // ✅ ADD: Parse vehicle type
      totalSlots: _parseInt(json['total_slots']),
      availableSlots: _parseInt(json['available_slots']),
      occupiedSlots: _parseInt(json['occupied_slots']),
      reservedSlots: _parseInt(json['reserved_slots']),
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'].toString())
          : DateTime.now(),
    );
  }

  /// Convert ParkingFloorModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id_floor': idFloor,
      'id_mall': idMall,
      'floor_number': floorNumber,
      'floor_name': floorName,
      'jenis_kendaraan': jenisKendaraan, // ✅ ADD: Include vehicle type
      'total_slots': totalSlots,
      'available_slots': availableSlots,
      'occupied_slots': occupiedSlots,
      'reserved_slots': reservedSlots,
      'last_updated': lastUpdated.toIso8601String(),
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

  /// Create a copy of this model with updated fields
  ParkingFloorModel copyWith({
    String? idFloor,
    String? idMall,
    int? floorNumber,
    String? floorName,
    String? jenisKendaraan, // ✅ ADD: Vehicle type parameter
    int? totalSlots,
    int? availableSlots,
    int? occupiedSlots,
    int? reservedSlots,
    DateTime? lastUpdated,
  }) {
    return ParkingFloorModel(
      idFloor: idFloor ?? this.idFloor,
      idMall: idMall ?? this.idMall,
      floorNumber: floorNumber ?? this.floorNumber,
      floorName: floorName ?? this.floorName,
      jenisKendaraan: jenisKendaraan ?? this.jenisKendaraan, // ✅ ADD: Copy vehicle type
      totalSlots: totalSlots ?? this.totalSlots,
      availableSlots: availableSlots ?? this.availableSlots,
      occupiedSlots: occupiedSlots ?? this.occupiedSlots,
      reservedSlots: reservedSlots ?? this.reservedSlots,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParkingFloorModel && other.idFloor == idFloor;
  }

  @override
  int get hashCode => idFloor.hashCode;
}
