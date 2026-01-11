import 'package:flutter/material.dart';
import '../../config/design_constants.dart';

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

    return Semantics(
      label: 'Informasi mall. $mallName, alamat $address, jarak $distance, $availableSlots slot parkir tersedia, status $slotStatusText',
      child: Card(
        elevation: DesignConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignConstants.cardBorderRadius),
        ),
        color: DesignConstants.backgroundColor,
        shadowColor: DesignConstants.cardShadowColor,
        child: Padding(
          padding: DesignConstants.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mall name with icon
              Row(
                children: [
                  Semantics(
                    label: 'Ikon parkir',
                    child: Container(
                      padding: const EdgeInsets.all(DesignConstants.spaceSm),
                      decoration: BoxDecoration(
                        color: DesignConstants.primarySurface,
                        borderRadius: BorderRadius.circular(DesignConstants.spaceSm),
                      ),
                      child: Icon(
                        Icons.local_parking,
                        color: DesignConstants.primaryColor,
                        size: DesignConstants.iconSizeLarge,
                      ),
                    ),
                  ),
                  const SizedBox(width: DesignConstants.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          label: 'Nama mall',
                          child: Text(
                            mallName,
                            style: DesignConstants.getHeadingStyle(
                              fontSize: DesignConstants.fontSizeH3,
                            ),
                          ),
                        ),
                        const SizedBox(height: DesignConstants.spaceXs),
                        Semantics(
                          label: 'Alamat mall',
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: DesignConstants.iconSizeSmall,
                                color: DesignConstants.textTertiary,
                              ),
                              const SizedBox(width: DesignConstants.spaceXs),
                              Expanded(
                                child: Text(
                                  address,
                                  style: DesignConstants.getBodyStyle(
                                    color: DesignConstants.textTertiary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: DesignConstants.spaceXs),
                        Semantics(
                          label: 'Jarak dari lokasi Anda',
                          child: Row(
                            children: [
                              Icon(
                                Icons.navigation,
                                size: DesignConstants.iconSizeSmall,
                                color: DesignConstants.textTertiary,
                              ),
                              const SizedBox(width: DesignConstants.spaceXs),
                              Text(
                                distance,
                                style: DesignConstants.getBodyStyle(
                                  color: DesignConstants.textTertiary,
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
              
              const SizedBox(height: DesignConstants.spaceMd),
              
              Divider(
                color: DesignConstants.dividerColor,
                height: DesignConstants.dividerThickness,
              ),
              
              const SizedBox(height: DesignConstants.spaceMd),
              
              // Available slots indicator
              Semantics(
                label: 'Ketersediaan slot parkir. $availableSlots slot tersedia. Status $slotStatusText',
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: DesignConstants.iconSizeMedium,
                      color: slotColor,
                    ),
                    const SizedBox(width: DesignConstants.spaceSm),
                    Text(
                      '$availableSlots slot tersedia',
                      style: DesignConstants.getBodyStyle(
                        fontWeight: DesignConstants.fontWeightSemiBold,
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
