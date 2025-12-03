import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/responsive_helper.dart';

/// Widget to display a comprehensive summary of booking details before confirmation
/// Features organized sections with dividers and purple border for emphasis
class BookingSummaryCard extends StatelessWidget {
  final String mallName;
  final String mallAddress;
  final String vehiclePlat;
  final String vehicleType;
  final String vehicleBrand;
  final DateTime startTime;
  final Duration duration;
  final DateTime endTime;
  final double totalCost;
  final String? reservedSlotCode;
  final String? reservedFloorName;
  final String? reservedSlotType;

  const BookingSummaryCard({
    Key? key,
    required this.mallName,
    required this.mallAddress,
    required this.vehiclePlat,
    required this.vehicleType,
    required this.vehicleBrand,
    required this.startTime,
    required this.duration,
    required this.endTime,
    required this.totalCost,
    this.reservedSlotCode,
    this.reservedFloorName,
    this.reservedSlotType,
  }) : super(key: key);

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (minutes == 0) {
      return '$hours jam';
    }
    return '$hours jam $minutes menit';
  }

  @override
  Widget build(BuildContext context) {
    final startTimeText = DateFormat('HH:mm, dd MMM yyyy').format(startTime);
    final endTimeText = DateFormat('HH:mm, dd MMM yyyy').format(endTime);
    final durationText = _formatDuration(duration);
    final costText = _formatCurrency(totalCost);
    
    final borderRadius = ResponsiveHelper.getBorderRadius(context);
    final padding = ResponsiveHelper.getCardPadding(context);
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(context, 18);
    final bodyFontSize = ResponsiveHelper.getResponsiveFontSize(context, 14);
    final captionFontSize = ResponsiveHelper.getResponsiveFontSize(context, 12);
    final costFontSize = ResponsiveHelper.getResponsiveFontSize(context, 18);
    final iconSize = ResponsiveHelper.getIconSize(context, 20);
    
    final slotInfo = reservedSlotCode != null && reservedFloorName != null
        ? 'Slot parkir $reservedFloorName - Slot $reservedSlotCode, ${reservedSlotType ?? "Regular Parking"}. '
        : '';
    
    return Semantics(
      label: 'Ringkasan booking. Lokasi $mallName, $mallAddress. ${slotInfo}Kendaraan $vehiclePlat, $vehicleType, $vehicleBrand. Waktu mulai $startTimeText, durasi $durationText, selesai $endTimeText. Total estimasi $costText',
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: const BorderSide(
            color: Color(0xFF573ED1),
            width: 2,
          ),
        ),
        color: Colors.white,
        shadowColor: const Color(0xFF573ED1).withOpacity(0.2),
        child: SingleChildScrollView(
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ringkasan Booking',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              const SizedBox(height: 16),
              
              // Location Section
              _buildSection(
                context: context,
                icon: Icons.location_on,
                title: 'Lokasi',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mallName,
                      style: TextStyle(
                        fontSize: bodyFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mallAddress,
                      style: TextStyle(
                        fontSize: captionFontSize,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              Divider(
                color: Colors.grey.shade200,
                height: 24,
              ),
              
              // Reserved Slot Section (if available)
              if (reservedSlotCode != null && reservedFloorName != null) ...[
                _buildSection(
                  context: context,
                  icon: Icons.local_parking,
                  title: 'Slot Parkir',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$reservedFloorName - Slot $reservedSlotCode',
                        style: TextStyle(
                          fontSize: bodyFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reservedSlotType ?? 'Regular Parking',
                        style: TextStyle(
                          fontSize: captionFontSize,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.grey.shade200,
                  height: 24,
                ),
              ],
              
              // Vehicle Section
              _buildSection(
                context: context,
                icon: Icons.directions_car,
                title: 'Kendaraan',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehiclePlat,
                      style: TextStyle(
                        fontSize: bodyFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$vehicleType - $vehicleBrand',
                      style: TextStyle(
                        fontSize: captionFontSize,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              Divider(
                color: Colors.grey.shade200,
                height: 24,
              ),
              
              // Time Section
              _buildSection(
                context: context,
                icon: Icons.schedule,
                title: 'Waktu',
                content: Column(
                  children: [
                    _buildTimeRow(
                      context,
                      Icons.schedule,
                      'Mulai',
                      DateFormat('HH:mm, dd MMM yyyy').format(startTime),
                    ),
                    const SizedBox(height: 8),
                    _buildTimeRow(
                      context,
                      Icons.timer,
                      'Durasi',
                      _formatDuration(duration),
                    ),
                    const SizedBox(height: 8),
                    _buildTimeRow(
                      context,
                      Icons.event_available,
                      'Selesai',
                      DateFormat('HH:mm, dd MMM yyyy').format(endTime),
                    ),
                  ],
                ),
              ),
              
              Divider(
                color: Colors.grey.shade200,
                height: 24,
              ),
              
              // Cost Section
              Semantics(
                label: 'Total estimasi biaya $costText',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Semantics(
                            label: 'Ikon pembayaran',
                            child: Icon(
                              Icons.payments,
                              color: const Color(0xFF573ED1),
                              size: iconSize,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Total Estimasi',
                              style: TextStyle(
                                fontSize: titleFontSize * 0.9,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _formatCurrency(totalCost),
                        style: TextStyle(
                          fontSize: costFontSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF573ED1),
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget content,
  }) {
    final iconSize = ResponsiveHelper.getIconSize(context, 20);
    final captionFontSize = ResponsiveHelper.getResponsiveFontSize(context, 12);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF573ED1),
              size: iconSize,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: captionFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: content,
        ),
      ],
    );
  }

  Widget _buildTimeRow(BuildContext context, IconData icon, String label, String value) {
    final captionFontSize = ResponsiveHelper.getResponsiveFontSize(context, 12);
    final bodyFontSize = ResponsiveHelper.getResponsiveFontSize(context, 14);
    
    return Row(
      children: [
        Icon(
          icon,
          size: captionFontSize + 2,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: captionFontSize,
            color: Colors.grey.shade600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: bodyFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
