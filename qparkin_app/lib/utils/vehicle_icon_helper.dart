// 📄 lib/utils/vehicle_icon_helper.dart
import 'package:flutter/material.dart';

/// VehicleIconHelper - Centralized vehicle icon mapping utility
///
/// Provides consistent icon and color mapping for vehicle types across the app.
/// This ensures that vehicle icons are displayed consistently in:
/// - List Kendaraan page
/// - Profile page vehicle cards
/// - Vehicle detail pages
/// - Any other vehicle displays
///
/// Usage:
/// ```dart
/// IconData icon = VehicleIconHelper.getIcon('Roda Dua');
/// Color color = VehicleIconHelper.getColor('Roda Dua');
/// ```
class VehicleIconHelper {
  /// Private constructor to prevent instantiation
  VehicleIconHelper._();

  /// Get the appropriate icon for a vehicle type
  ///
  /// Maps vehicle types (jenis kendaraan) to Material Icons:
  /// - Roda Dua → two_wheeler (motorcycle icon)
  /// - Roda Tiga → electric_rickshaw (three-wheeler icon)
  /// - Roda Empat → directions_car (car icon)
  /// - Default → local_shipping (truck icon for larger vehicles)
  ///
  /// The mapping is case-insensitive for robustness.
  static IconData getIcon(String jenisKendaraan) {
    switch (jenisKendaraan.toLowerCase()) {
      case 'roda dua':
        return Icons.two_wheeler;
      case 'roda tiga':
        return Icons.electric_rickshaw;
      case 'roda empat':
        return Icons.directions_car;
      default:
        // For "Lebih dari Enam" or any other type
        return Icons.local_shipping;
    }
  }

  /// Get the appropriate color for a vehicle type
  ///
  /// Maps vehicle types to consistent brand colors:
  /// - Roda Dua → Teal (contrasts with purple theme)
  /// - Roda Tiga → Orange (distinctive for three-wheelers)
  /// - Roda Empat → Blue (traditional car color)
  /// - Default → Grey (neutral for larger vehicles)
  ///
  /// The mapping is case-insensitive for robustness.
  static Color getColor(String jenisKendaraan) {
    switch (jenisKendaraan.toLowerCase()) {
      case 'roda dua':
        return const Color(0xFF009688); // Teal - contrasts with purple theme
      case 'roda tiga':
        return const Color(0xFFFF9800); // Orange
      case 'roda empat':
        return const Color(0xFF1872B3); // Blue
      default:
        // For "Lebih dari Enam" or any other type
        return const Color(0xFF757575); // Grey
    }
  }

  /// Get the appropriate background color for a vehicle icon
  ///
  /// Returns a light tinted version of the vehicle color for backgrounds.
  /// Uses 10% opacity of the main color for subtle visual hierarchy.
  static Color getBackgroundColor(String jenisKendaraan) {
    return getColor(jenisKendaraan).withOpacity(0.1);
  }
}
