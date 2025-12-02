import 'package:flutter/material.dart';
import '../../../data/models/vehicle_model.dart';
import '../common/animated_card.dart';

/// VehicleCard - Reusable vehicle card widget with interactive feedback
///
/// Displays vehicle information with consistent styling and micro-interactions.
/// This component is used in the profile page to show registered vehicles.
///
/// Features:
/// - AnimatedCard wrapper for tap feedback
/// - Vehicle icon with colored background
/// - Vehicle name, type, and plate number display
/// - "Aktif" badge for active vehicle
/// - Swipe-to-delete functionality (when wrapped with Dismissible)
/// - Customizable callbacks for tap, edit, and delete actions
///
/// Usage:
/// ```dart
/// VehicleCard(
///   vehicle: vehicleModel,
///   isActive: true,
///   onTap: () => navigateToDetail(),
///   onEdit: () => editVehicle(),
///   onDelete: () => deleteVehicle(),
/// )
/// ```
///
/// Design System:
/// - Follows QPARKIN 8dp grid system
/// - Uses consistent border radius (12dp)
/// - Matches profile page vehicle display styling
class VehicleCard extends StatelessWidget {
  /// The vehicle model containing all vehicle information
  final VehicleModel vehicle;

  /// Whether this vehicle is the active vehicle
  final bool isActive;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Callback when the edit action is triggered
  final VoidCallback? onEdit;

  /// Callback when the delete action is triggered
  final VoidCallback? onDelete;

  /// Creates a VehicleCard widget
  ///
  /// The [vehicle] parameter is required and contains the vehicle data.
  /// The [isActive] parameter indicates if this is the active vehicle.
  /// The [onTap], [onEdit], and [onDelete] callbacks are optional.
  const VehicleCard({
    Key? key,
    required this.vehicle,
    this.isActive = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasStatistics = vehicle.statistics != null;
    
    return Semantics(
      label: 'Kartu kendaraan ${vehicle.merk} ${vehicle.tipe} dengan plat nomor ${vehicle.platNomor}${isActive ? ', kendaraan aktif' : ''}',
      button: true,
      hint: 'Ketuk untuk melihat detail kendaraan',
      child: AnimatedCard(
        onTap: onTap,
        borderRadius: 12,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Vehicle icon with colored background
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      color: Color(0xFF1872B3),
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Vehicle information
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Vehicle name and active badge
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${vehicle.merk} ${vehicle.tipe}',
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Color(0xFF1A1A1A),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isActive)
                              Semantics(
                                label: 'Kendaraan aktif',
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Aktif',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Vehicle type
                        Text(
                          vehicle.jenisKendaraan,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Plate number
                        Text(
                          vehicle.platNomor,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1872B3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Statistics section
              if (hasStatistics) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // Statistics row
                      Row(
                        children: [
                          // Parking count
                          Expanded(
                            child: _StatisticItem(
                              icon: Icons.local_parking,
                              label: 'Parkir',
                              value: '${vehicle.statistics!.parkingCount}x',
                            ),
                          ),
                          // Total time
                          Expanded(
                            child: _StatisticItem(
                              icon: Icons.access_time,
                              label: 'Waktu',
                              value: vehicle.statistics!.formattedTotalTime,
                            ),
                          ),
                          // Total cost
                          Expanded(
                            child: _StatisticItem(
                              icon: Icons.payments,
                              label: 'Biaya',
                              value: vehicle.statistics!.formattedTotalCost,
                            ),
                          ),
                        ],
                      ),
                      // View History button
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: onTap,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            backgroundColor: const Color(0xFF573ED1).withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'Lihat Riwayat',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF573ED1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Internal widget for displaying a single statistic item
class _StatisticItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatisticItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF573ED1),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF8E8E93),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
