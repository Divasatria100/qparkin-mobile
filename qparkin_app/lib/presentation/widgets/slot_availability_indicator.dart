import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../../config/design_constants.dart';
import 'base_parking_card.dart';
import 'booking_shimmer_loading.dart';

/// Widget to display real-time parking slot availability with color-coded status
/// Features manual refresh capability and shimmer loading during updates
///
/// Requirements: 5.1-5.7, 12.1-12.9, 13.2
class SlotAvailabilityIndicator extends StatefulWidget {
  final int availableSlots;
  final String vehicleType;
  final bool isLoading;
  final VoidCallback onRefresh;

  const SlotAvailabilityIndicator({
    Key? key,
    required this.availableSlots,
    required this.vehicleType,
    this.isLoading = false,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<SlotAvailabilityIndicator> createState() =>
      _SlotAvailabilityIndicatorState();
}

class _SlotAvailabilityIndicatorState
    extends State<SlotAvailabilityIndicator> {
  Color _getStatusColor() {
    if (widget.availableSlots > 10) {
      return DesignConstants.successColor;
    } else if (widget.availableSlots >= 3) {
      return DesignConstants.warningColor;
    } else {
      return DesignConstants.errorColor;
    }
  }

  String _getStatusText() {
    if (widget.availableSlots > 10) {
      return 'Banyak slot tersedia';
    } else if (widget.availableSlots >= 3) {
      return 'Slot terbatas';
    } else if (widget.availableSlots > 0) {
      return 'Hampir penuh';
    } else {
      return 'Penuh';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return BaseParkingCard(
      child: widget.isLoading
          ? _buildShimmerLoading()
          : _buildContent(statusColor),
    );
  }

  Widget _buildShimmerLoading() {
    return const SlotAvailabilityShimmer();
  }

  Widget _buildContent(Color statusColor) {
    final statusText = _getStatusText();

    return Semantics(
      label:
          'Ketersediaan slot parkir. ${widget.availableSlots} slot tersedia untuk ${widget.vehicleType}. Status $statusText',
      child: Row(
        children: [
          // Status Circle with Icon
          Semantics(
            label: 'Indikator status $statusText',
            child: Container(
              width: DesignConstants.minTouchTarget,
              height: DesignConstants.minTouchTarget,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_parking,
                color: DesignConstants.backgroundColor,
                size: DesignConstants.iconSizeLarge,
              ),
            ),
          ),

          const SizedBox(width: DesignConstants.spaceLg),

          // Availability Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ketersediaan Slot',
                  style: DesignConstants.getBodyStyle(
                    color: DesignConstants.textTertiary,
                  ),
                ),
                const SizedBox(height: DesignConstants.spaceXs),
                Text(
                  '${widget.availableSlots} slot tersedia',
                  style: DesignConstants.getHeadingStyle(
                    fontSize: DesignConstants.fontSizeH3,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: DesignConstants.spaceXs),
                Text(
                  'Untuk ${widget.vehicleType}',
                  style: DesignConstants.getCaptionStyle(
                    color: DesignConstants.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Refresh Button
          Semantics(
            label: 'Tombol refresh ketersediaan slot',
            hint: 'Ketuk untuk memperbarui informasi ketersediaan slot',
            button: true,
            child: IconButton(
              onPressed: () {
                widget.onRefresh();
                SemanticsService.announce(
                  'Memperbarui ketersediaan slot',
                  TextDirection.ltr,
                );
              },
              icon: Icon(
                Icons.refresh,
                color: DesignConstants.textSecondary,
                size: DesignConstants.iconSizeMedium,
              ),
              tooltip: 'Refresh ketersediaan',
            ),
          ),
        ],
      ),
    );
  }
}
