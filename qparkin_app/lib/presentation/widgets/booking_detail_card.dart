import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/active_parking_model.dart';

/// A card widget displaying comprehensive booking and transaction details
/// Shows mall location, parking slot, vehicle info, time, and cost information
class BookingDetailCard extends StatelessWidget {
  final ActiveParkingModel activeParking;

  const BookingDetailCard({
    Key? key,
    required this.activeParking,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate current cost
    final currentCost = activeParking.calculateCurrentCost();
    
    return Semantics(
      label: 'Detail parkir',
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Mall location (with null check)
          if (activeParking.namaMall.isNotEmpty)
            _buildDetailRow(
              icon: Icons.location_on,
              iconColor: const Color(0xFF2196F3),
              title: activeParking.namaMall,
              subtitle: activeParking.kodeSlot.isNotEmpty 
                  ? 'Area: ${activeParking.kodeSlot}' 
                  : 'Area: -',
            ),
          if (activeParking.namaMall.isNotEmpty) const SizedBox(height: 12),
          
          // Vehicle information (with null checks)
          if (activeParking.platNomor.isNotEmpty)
            _buildDetailRow(
              icon: Icons.directions_car,
              iconColor: const Color(0xFF4CAF50),
              title: activeParking.platNomor,
              subtitle: _buildVehicleSubtitle(),
            ),
          if (activeParking.platNomor.isNotEmpty) const SizedBox(height: 12),
          
          // Entry time
          _buildDetailRow(
            icon: Icons.access_time,
            iconColor: const Color(0xFF9C27B0),
            title: 'Waktu Masuk',
            subtitle: _formatTime(activeParking.waktuMasuk),
          ),
          const SizedBox(height: 12),
          
          // Estimated end time (if booking exists)
          if (activeParking.waktuSelesaiEstimas != null) ...[
            _buildDetailRow(
              icon: Icons.timer,
              iconColor: activeParking.isPenaltyApplicable() 
                  ? const Color(0xFFF44336) 
                  : const Color(0xFFFF9800),
              title: 'Estimasi Selesai',
              subtitle: _formatTime(activeParking.waktuSelesaiEstimas!),
              isWarning: activeParking.isPenaltyApplicable(),
            ),
            const SizedBox(height: 12),
          ],
          
          // Current parking cost
          _buildDetailRow(
            icon: Icons.attach_money,
            iconColor: const Color(0xFF4CAF50),
            title: 'Biaya Berjalan',
            subtitle: _formatCurrency(currentCost),
          ),
          
          // Penalty (if applicable)
          if (activeParking.isPenaltyApplicable()) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.warning,
              iconColor: const Color(0xFFF44336),
              title: 'Penalty',
              subtitle: activeParking.penalty != null 
                  ? _formatCurrency(activeParking.penalty!) 
                  : 'Akan dihitung saat keluar',
              isWarning: true,
            ),
          ],
        ],
        ),
      ),
    );
  }

  /// Build vehicle subtitle with null checks
  String _buildVehicleSubtitle() {
    final parts = <String>[];
    
    if (activeParking.jenisKendaraan.isNotEmpty) {
      parts.add(activeParking.jenisKendaraan);
    }
    
    if (activeParking.merkKendaraan.isNotEmpty) {
      parts.add(activeParking.merkKendaraan);
    }
    
    if (activeParking.tipeKendaraan.isNotEmpty) {
      parts.add(activeParking.tipeKendaraan);
    }
    
    return parts.isNotEmpty ? parts.join(' - ') : 'Kendaraan';
  }

  /// Build a single detail row with icon and text
  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool isWarning = false,
  }) {
    // Build semantic label for screen readers
    final semanticLabel = '$title: $subtitle${isWarning ? ". Peringatan" : ""}';
    
    return Semantics(
      label: semanticLabel,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container with semantic label
          Semantics(
            label: _getIconSemanticLabel(icon),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Text content
          Expanded(
            child: ExcludeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isWarning ? const Color(0xFFF44336) : const Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isWarning ? const Color(0xFFFF9800) : const Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get semantic label for icons
  String _getIconSemanticLabel(IconData icon) {
    if (icon == Icons.location_on) return 'Lokasi';
    if (icon == Icons.directions_car) return 'Kendaraan';
    if (icon == Icons.access_time) return 'Waktu masuk';
    if (icon == Icons.timer) return 'Waktu selesai';
    if (icon == Icons.attach_money) return 'Biaya';
    if (icon == Icons.warning) return 'Peringatan penalty';
    return 'Ikon';
  }

  /// Format DateTime to time string (HH:MM)
  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Format currency to Indonesian Rupiah
  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
