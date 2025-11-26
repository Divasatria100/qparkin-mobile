import 'package:flutter/material.dart';
import '../../utils/responsive_helper.dart';

/// Widget to display mall information including name, address, distance, and available slots
/// Used in the Booking Page to show details of the selected mall
class MallInfoCard extends StatelessWidget {
  final String mallName;
  final String address;
  final String distance;
  final int availableSlots;

  const MallInfoCard({
    Key? key,
    required this.mallName,
    required this.address,
    required this.distance,
    required this.availableSlots,
  }) : super(key: key);

  Color _getSlotStatusColor() {
    if (availableSlots > 10) {
      return const Color(0xFF4CAF50); // Green
    } else if (availableSlots >= 3) {
      return const Color(0xFFFF9800); // Yellow/Orange
    } else {
      return const Color(0xFFF44336); // Red
    }
  }

  @override
  Widget build(BuildContext context) {
    final slotColor = _getSlotStatusColor();
    final slotStatusText = availableSlots > 10 
        ? 'Banyak slot tersedia' 
        : availableSlots >= 3 
            ? 'Slot terbatas' 
            : availableSlots > 0 
                ? 'Hampir penuh' 
                : 'Penuh';
    
    final borderRadius = ResponsiveHelper.getBorderRadius(context);
    final padding = ResponsiveHelper.getCardPadding(context);
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(context, 18);
    final bodyFontSize = ResponsiveHelper.getResponsiveFontSize(context, 14);
    final iconSize = ResponsiveHelper.getIconSize(context, 24);

    return Semantics(
      label: 'Informasi mall. $mallName, alamat $address, jarak $distance, $availableSlots slot parkir tersedia, status $slotStatusText',
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.1),
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mall name with icon
              Row(
                children: [
                  Semantics(
                    label: 'Ikon parkir',
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF573ED1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.local_parking,
                        color: const Color(0xFF573ED1),
                        size: iconSize,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          label: 'Nama mall',
                          child: Text(
                            mallName,
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Semantics(
                          label: 'Alamat mall',
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: bodyFontSize,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  address,
                                  style: TextStyle(
                                    fontSize: bodyFontSize,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Semantics(
                          label: 'Jarak dari lokasi Anda',
                          child: Row(
                            children: [
                              Icon(
                                Icons.navigation,
                                size: bodyFontSize,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                distance,
                                style: TextStyle(
                                  fontSize: bodyFontSize,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Divider(
                color: Colors.grey.shade200,
                height: 1,
              ),
              
              const SizedBox(height: 12),
              
              // Available slots indicator
              Semantics(
                label: 'Ketersediaan slot parkir. $availableSlots slot tersedia. Status $slotStatusText',
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: bodyFontSize + 2,
                      color: slotColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$availableSlots slot tersedia',
                      style: TextStyle(
                        fontSize: bodyFontSize,
                        fontWeight: FontWeight.w600,
                        color: slotColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
