import 'package:flutter/material.dart';

/// Enum representing slot status
enum SlotStatus {
  available,
  occupied,
  reserved,
  disabled;

  /// Get status from string value
  static SlotStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'available':
      case 'tersedia':
        return SlotStatus.available;
      case 'occupied':
      case 'terisi':
        return SlotStatus.occupied;
      case 'reserved':
      case 'direservasi':
        return SlotStatus.reserved;
      case 'disabled':
      case 'nonaktif':
        return SlotStatus.disabled;
      default:
        return SlotStatus.available;
    }
  }

  /// Convert status to string
  String toStringValue() {
    switch (this) {
      case SlotStatus.available:
        return 'available';
      case SlotStatus.occupied:
        return 'occupied';
      case SlotStatus.reserved:
        return 'reserved';
      case SlotStatus.disabled:
        return 'disabled';
    }
  }
}

/// Enum representing slot type
enum SlotType {
  regular,
  disableFriendly;

  /// Get type from string value
  static SlotType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'disable_friendly':
      case 'disable-friendly':
      case 'disablefriendly':
        return SlotType.disableFriendly;
      case 'regular':
      default:
        return SlotType.regular;
    }
  }

  /// Convert type to string
  String toStringValue() {
    switch (this) {
      case SlotType.regular:
        return 'regular';
      case SlotType.disableFriendly:
        return 'disable_friendly';
    }
  }

  /// Get icon for slot type
  IconData get icon {
    switch (this) {
      case SlotType.disableFriendly:
        return Icons.accessible;
      case SlotType.regular:
        return Icons.local_parking;
    }
  }
}

/// Model representing a parking slot for visualization purposes (non-interactive)
class ParkingSlotModel {
  final String idSlot;
  final String idFloor;
  final String slotCode;
  final SlotStatus status;
  final SlotType slotType;
  final int? positionX;
  final int? positionY;
  final DateTime lastUpdated;

  ParkingSlotModel({
    required this.idSlot,
    required this.idFloor,
    required this.slotCode,
    required this.status,
    required this.slotType,
    this.positionX,
    this.positionY,
    required this.lastUpdated,
  });

  /// Get color based on slot status
  Color get statusColor {
    switch (status) {
      case SlotStatus.available:
        return const Color(0xFF4CAF50); // Green
      case SlotStatus.occupied:
        return const Color(0xFF9E9E9E); // Grey
      case SlotStatus.reserved:
        return const Color(0xFFFF9800); // Yellow/Orange
      case SlotStatus.disabled:
        return const Color(0xFFF44336); // Red
    }
  }

  /// Get icon based on slot type
  IconData get typeIcon {
    return slotType == SlotType.disableFriendly
        ? Icons.accessible
        : Icons.local_parking;
  }

  /// Get label for slot type
  String get typeLabel {
    return slotType == SlotType.disableFriendly
        ? 'Disable-Friendly'
        : 'Regular';
  }

  /// Get label for slot status
  String get statusLabel {
    switch (status) {
      case SlotStatus.available:
        return 'Tersedia';
      case SlotStatus.occupied:
        return 'Terisi';
      case SlotStatus.reserved:
        return 'Direservasi';
      case SlotStatus.disabled:
        return 'Nonaktif';
    }
  }

  /// Check if slot is available for reservation
  bool get isAvailable => status == SlotStatus.available;

  /// Validate slot data
  bool validate() {
    if (idSlot.isEmpty) return false;
    if (idFloor.isEmpty) return false;
    if (slotCode.isEmpty) return false;
    if (positionX != null && positionX! < 0) return false;
    if (positionY != null && positionY! < 0) return false;
    return true;
  }

  /// Create ParkingSlotModel from JSON
  factory ParkingSlotModel.fromJson(Map<String, dynamic> json) {
    return ParkingSlotModel(
      idSlot: json['id_slot']?.toString() ?? '',
      idFloor: json['id_floor']?.toString() ?? '',
      slotCode: json['slot_code']?.toString() ?? '',
      status: SlotStatus.fromString(json['status']?.toString() ?? 'available'),
      slotType: SlotType.fromString(json['slot_type']?.toString() ?? 'regular'),
      positionX: json['position_x'] != null ? _parseInt(json['position_x']) : null,
      positionY: json['position_y'] != null ? _parseInt(json['position_y']) : null,
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'].toString())
          : DateTime.now(),
    );
  }

  /// Convert ParkingSlotModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id_slot': idSlot,
      'id_floor': idFloor,
      'slot_code': slotCode,
      'status': status.toStringValue(),
      'slot_type': slotType.toStringValue(),
      'position_x': positionX,
      'position_y': positionY,
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
  ParkingSlotModel copyWith({
    String? idSlot,
    String? idFloor,
    String? slotCode,
    SlotStatus? status,
    SlotType? slotType,
    int? positionX,
    int? positionY,
    DateTime? lastUpdated,
  }) {
    return ParkingSlotModel(
      idSlot: idSlot ?? this.idSlot,
      idFloor: idFloor ?? this.idFloor,
      slotCode: slotCode ?? this.slotCode,
      status: status ?? this.status,
      slotType: slotType ?? this.slotType,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParkingSlotModel && other.idSlot == idSlot;
  }

  @override
  int get hashCode => idSlot.hashCode;
}
