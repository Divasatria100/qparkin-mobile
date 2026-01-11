import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/design_constants.dart';

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
  final int? pointsUsed;
  final int? pointDiscount;
  final double? originalCost;

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
    this.pointsUsed,
    this.pointDiscount,
    this.originalCost,
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
    
    final slotInfo = reservedSlotCode != null && reservedFloorName != null
        ? 'Slot parkir $reservedFloorName - Slot $reservedSlotCode, ${reservedSlotType ?? "Regular Parking"}. '
        : '';
    
    return Semantics(
      label: 'Ringkasan booking. Lokasi $mallName, $mallAddress. ${slotInfo}Kendaraan $vehiclePlat, $vehicleType, $vehicleBrand. Waktu mulai $startTimeText, durasi $durationText, selesai $endTimeText. Total estimasi $costText',
      child: Card(
        elevation: DesignConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignConstants.cardBorderRadius),
          side: BorderSide(
            color: DesignConstants.primaryColor,
            width: DesignConstants.cardBorderWidthFocused,
          ),
        ),
        color: DesignConstants.backgroundColor,
        shadowColor: DesignConstants.cardShadowColor,
        child: SingleChildScrollView(
          child: Padding(
            padding: DesignConstants.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ringkasan Booking',
                  style: DesignConstants.getHeadingStyle(
                    fontSize: DesignConstants.fontSizeH3,
                  ),
                ),
              const SizedBox(height: DesignConstants.spaceLg),
              
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
                      style: DesignConstants.getBodyStyle(
                        fontWeight: DesignConstants.fontWeightBold,
                      ),
                    ),
                    const SizedBox(height: DesignConstants.spaceXs),
                    Text(
                      mallAddress,
                      style: DesignConstants.getCaptionStyle(
                        color: DesignConstants.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              
              Divider(
                color: DesignConstants.dividerColor,
                height: DesignConstants.dividerSpacing,
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
                        style: DesignConstants.getBodyStyle(
                          fontWeight: DesignConstants.fontWeightBold,
                        ),
                      ),
                      const SizedBox(height: DesignConstants.spaceXs),
                      Text(
                        reservedSlotType ?? 'Regular Parking',
                        style: DesignConstants.getCaptionStyle(
                          color: DesignConstants.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: DesignConstants.dividerColor,
                  height: DesignConstants.dividerSpacing,
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
                      style: DesignConstants.getBodyStyle(
                        fontWeight: DesignConstants.fontWeightBold,
                      ),
                    ),
                    const SizedBox(height: DesignConstants.spaceXs),
                    Text(
                      '$vehicleType - $vehicleBrand',
                      style: DesignConstants.getCaptionStyle(
                        color: DesignConstants.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              
              Divider(
                color: DesignConstants.dividerColor,
                height: DesignConstants.dividerSpacing,
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
                    const SizedBox(height: DesignConstants.spaceSm),
                    _buildTimeRow(
                      context,
                      Icons.timer,
                      'Durasi',
                      _formatDuration(duration),
                    ),
                    const SizedBox(height: DesignConstants.spaceSm),
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
                color: DesignConstants.dividerColor,
                height: DesignConstants.dividerSpacing,
              ),
              
              // Cost Section with Point Discount
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Original Cost (if points are used)
                  if (pointsUsed != null && pointsUsed! > 0 && originalCost != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Biaya Parkir',
                          style: DesignConstants.getBodyStyle(
                            color: DesignConstants.textSecondary,
                          ),
                        ),
                        Text(
                          _formatCurrency(originalCost!),
                          style: DesignConstants.getBodyStyle(
                            color: DesignConstants.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignConstants.spaceSm),
                    
                    // Point Discount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.stars,
                              color: DesignConstants.successColor,
                              size: DesignConstants.iconSizeMedium,
                            ),
                            const SizedBox(width: DesignConstants.spaceXs),
                            Text(
                              'Diskon Poin ($pointsUsed poin)',
                              style: DesignConstants.getBodyStyle(
                                color: DesignConstants.successColor,
                                fontWeight: DesignConstants.fontWeightSemiBold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '- ${_formatCurrency(pointDiscount!.toDouble())}',
                          style: DesignConstants.getBodyStyle(
                            color: DesignConstants.successColor,
                            fontWeight: DesignConstants.fontWeightSemiBold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignConstants.spaceMd),
                    Divider(
                      color: DesignConstants.borderPrimary,
                      height: DesignConstants.dividerThickness,
                    ),
                    const SizedBox(height: DesignConstants.spaceMd),
                  ],
                  
                  // Total Cost
                  Semantics(
                    label: pointsUsed != null && pointsUsed! > 0
                        ? 'Total setelah diskon poin $costText'
                        : 'Total estimasi biaya $costText',
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
                                  color: DesignConstants.primaryColor,
                                  size: DesignConstants.iconSizeMedium,
                                ),
                              ),
                              const SizedBox(width: DesignConstants.spaceSm),
                              Flexible(
                                child: Text(
                                  pointsUsed != null && pointsUsed! > 0
                                      ? 'Total Bayar'
                                      : 'Total Estimasi',
                                  style: DesignConstants.getHeadingStyle(
                                    fontSize: DesignConstants.fontSizeH4,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: DesignConstants.spaceSm),
                        Flexible(
                          child: Text(
                            _formatCurrency(totalCost),
                            style: DesignConstants.getHeadingStyle(
                              fontSize: DesignConstants.fontSizeH3,
                              color: DesignConstants.primaryColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Savings indicator
                  if (pointsUsed != null && pointsUsed! > 0 && pointDiscount != null) ...[
                    const SizedBox(height: DesignConstants.spaceSm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignConstants.spaceMd,
                        vertical: DesignConstants.spaceSm,
                      ),
                      decoration: BoxDecoration(
                        color: DesignConstants.successSurface,
                        borderRadius: BorderRadius.circular(DesignConstants.spaceSm),
                        border: Border.all(
                          color: DesignConstants.successColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: DesignConstants.successColor,
                            size: DesignConstants.iconSizeSmall,
                          ),
                          const SizedBox(width: DesignConstants.spaceXs),
                          Flexible(
                            child: Text(
                              'Anda hemat ${_formatCurrency(pointDiscount!.toDouble())} dengan poin!',
                              style: DesignConstants.getCaptionStyle(
                                color: DesignConstants.successColor,
                              ).copyWith(
                                fontWeight: DesignConstants.fontWeightSemiBold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: DesignConstants.primaryColor,
              size: DesignConstants.iconSizeMedium,
            ),
            const SizedBox(width: DesignConstants.spaceSm),
            Text(
              title,
              style: DesignConstants.getCaptionStyle(
                color: DesignConstants.textTertiary,
              ).copyWith(
                fontWeight: DesignConstants.fontWeightSemiBold,
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignConstants.spaceSm),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: content,
        ),
      ],
    );
  }

  Widget _buildTimeRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: DesignConstants.iconSizeSmall,
          color: DesignConstants.textTertiary,
        ),
        const SizedBox(width: DesignConstants.spaceSm),
        Text(
          label,
          style: DesignConstants.getCaptionStyle(
            color: DesignConstants.textTertiary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: DesignConstants.getBodyStyle(
            fontWeight: DesignConstants.fontWeightBold,
          ),
        ),
      ],
    );
  }
}
