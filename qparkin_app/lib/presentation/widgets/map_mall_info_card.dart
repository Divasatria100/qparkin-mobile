import 'package:flutter/material.dart';
import '../../data/models/mall_model.dart';
import '../../data/models/route_data.dart';

/// Widget to display mall information overlay on the map
/// 
/// Shows mall name, address, distance, available slots, and route information.
/// Includes a close button to dismiss the card.
/// Animates appearance for better UX.
/// 
/// Requirements: 1.3, 3.5, 4.3, 4.4
class MapMallInfoCard extends StatefulWidget {
  final MallModel mall;
  final RouteData? route;
  final VoidCallback onClose;

  const MapMallInfoCard({
    Key? key,
    required this.mall,
    this.route,
    required this.onClose,
  }) : super(key: key);

  @override
  State<MapMallInfoCard> createState() => _MapMallInfoCardState();
}

class _MapMallInfoCardState extends State<MapMallInfoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Colors.black.withOpacity(0.2),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with mall name and close button
                Row(
                  children: [
                    // Mall icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF573ED1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.local_parking,
                        color: Color(0xFF573ED1),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Mall name
                    Expanded(
                      child: Text(
                        widget.mall.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // Close button
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: widget.onClose,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.mall.address,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Available slots
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getSlotStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getSlotStatusColor().withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: _getSlotStatusColor(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.mall.formattedAvailableSlots,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _getSlotStatusColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Route information (if available)
                if (widget.route != null) ...[
                  const SizedBox(height: 12),
                  
                  Divider(
                    color: Colors.grey.shade200,
                    height: 1,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Route details
                  Row(
                    children: [
                      // Distance
                      Expanded(
                        child: _buildRouteInfo(
                          icon: Icons.straighten,
                          label: 'Jarak',
                          value: widget.route!.formattedDistance,
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Duration
                      Expanded(
                        child: _buildRouteInfo(
                          icon: Icons.access_time,
                          label: 'Waktu',
                          value: widget.route!.formattedDuration,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build route information widget
  Widget _buildRouteInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF573ED1).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: const Color(0xFF573ED1),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF573ED1),
            ),
          ),
        ],
      ),
    );
  }

  /// Get color based on available slots
  Color _getSlotStatusColor() {
    if (widget.mall.availableSlots > 10) {
      return const Color(0xFF4CAF50); // Green
    } else if (widget.mall.availableSlots >= 3) {
      return const Color(0xFFFF9800); // Orange
    } else if (widget.mall.availableSlots > 0) {
      return const Color(0xFFF44336); // Red
    } else {
      return Colors.grey; // Full
    }
  }
}
