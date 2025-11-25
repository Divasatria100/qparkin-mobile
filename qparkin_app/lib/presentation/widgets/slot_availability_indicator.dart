import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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
      return const Color(0xFF4CAF50); // Green
    } else if (widget.availableSlots >= 3) {
      return const Color(0xFFFF9800); // Yellow/Orange
    } else {
      return const Color(0xFFF44336); // Red
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

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: widget.isLoading
            ? _buildShimmerLoading()
            : _buildContent(statusColor),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    // Use consistent shimmer loading widget
    // Requirements: 13.2
    return const SlotAvailabilityShimmer();
  }

  Widget _buildContent(Color statusColor) {
    final statusText = _getStatusText();
    
    return Semantics(
      label: 'Ketersediaan slot parkir. ${widget.availableSlots} slot tersedia untuk ${widget.vehicleType}. Status $statusText',
      child: Row(
        children: [
          // Status Circle with Icon
          Semantics(
            label: 'Indikator status $statusText',
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_parking,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Availability Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ketersediaan Slot',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.availableSlots} slot tersedia',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Untuk ${widget.vehicleType}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
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
                color: Colors.grey.shade400,
                size: 20,
              ),
              tooltip: 'Refresh ketersediaan',
            ),
          ),
        ],
      ),
    );
  }
}
