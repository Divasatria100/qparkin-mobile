import 'parking_slot_model.dart';

/// Model representing a reserved parking slot
class SlotReservationModel {
  final String reservationId;
  final String slotId;
  final String slotCode;
  final String floorName;
  final String floorNumber;
  final SlotType slotType;
  final DateTime reservedAt;
  final DateTime expiresAt;
  final bool isActive;

  SlotReservationModel({
    required this.reservationId,
    required this.slotId,
    required this.slotCode,
    required this.floorName,
    required this.floorNumber,
    required this.slotType,
    required this.reservedAt,
    required this.expiresAt,
    required this.isActive,
  });

  /// Check if reservation has expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Get remaining time until expiration
  Duration get timeRemaining {
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Get display name (e.g., "Lantai 1 - Slot A15")
  String get displayName => '$floorName - Slot $slotCode';

  /// Get type label
  String get typeLabel {
    return slotType == SlotType.disableFriendly
        ? 'Disable-Friendly'
        : 'Regular Parking';
  }

  /// Get formatted expiration time (e.g., "14:45")
  String get formattedExpirationTime {
    final hour = expiresAt.hour.toString().padLeft(2, '0');
    final minute = expiresAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get formatted remaining time (e.g., "4 menit 30 detik")
  String get formattedRemainingTime {
    final remaining = timeRemaining;
    if (remaining == Duration.zero) {
      return 'Habis';
    }

    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;

    if (minutes > 0) {
      return '$minutes menit $seconds detik';
    } else {
      return '$seconds detik';
    }
  }

  /// Check if reservation is still valid (active and not expired)
  bool get isValid => isActive && !isExpired;

  /// Validate reservation data
  bool validate() {
    if (reservationId.isEmpty) return false;
    if (slotId.isEmpty) return false;
    if (slotCode.isEmpty) return false;
    if (floorName.isEmpty) return false;
    if (floorNumber.isEmpty) return false;
    if (expiresAt.isBefore(reservedAt)) return false;
    return true;
  }

  /// Create SlotReservationModel from JSON
  factory SlotReservationModel.fromJson(Map<String, dynamic> json) {
    return SlotReservationModel(
      reservationId: json['reservation_id']?.toString() ?? '',
      slotId: json['slot_id']?.toString() ?? '',
      slotCode: json['slot_code']?.toString() ?? '',
      floorName: json['floor_name']?.toString() ?? '',
      floorNumber: json['floor_number']?.toString() ?? '',
      slotType: SlotType.fromString(json['slot_type']?.toString() ?? 'regular'),
      reservedAt: json['reserved_at'] != null
          ? DateTime.parse(json['reserved_at'].toString())
          : DateTime.now(),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'].toString())
          : DateTime.now().add(const Duration(minutes: 5)),
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }

  /// Convert SlotReservationModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'reservation_id': reservationId,
      'slot_id': slotId,
      'slot_code': slotCode,
      'floor_name': floorName,
      'floor_number': floorNumber,
      'slot_type': slotType.toStringValue(),
      'reserved_at': reservedAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// Create a copy of this model with updated fields
  SlotReservationModel copyWith({
    String? reservationId,
    String? slotId,
    String? slotCode,
    String? floorName,
    String? floorNumber,
    SlotType? slotType,
    DateTime? reservedAt,
    DateTime? expiresAt,
    bool? isActive,
  }) {
    return SlotReservationModel(
      reservationId: reservationId ?? this.reservationId,
      slotId: slotId ?? this.slotId,
      slotCode: slotCode ?? this.slotCode,
      floorName: floorName ?? this.floorName,
      floorNumber: floorNumber ?? this.floorNumber,
      slotType: slotType ?? this.slotType,
      reservedAt: reservedAt ?? this.reservedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SlotReservationModel &&
        other.reservationId == reservationId;
  }

  @override
  int get hashCode => reservationId.hashCode;
}
