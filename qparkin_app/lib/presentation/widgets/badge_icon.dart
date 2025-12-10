import 'package:flutter/material.dart';

/// Badge icon widget for showing notification indicators
///
/// Displays a small red dot badge on top of an icon when there are
/// unread notifications or updates.
///
/// Requirements: 7.5
class BadgeIcon extends StatelessWidget {
  final IconData icon;
  final bool showBadge;
  final double iconSize;
  final Color? iconColor;
  final double badgeSize;
  final Color badgeColor;

  const BadgeIcon({
    super.key,
    required this.icon,
    this.showBadge = false,
    this.iconSize = 24,
    this.iconColor,
    this.badgeSize = 8,
    this.badgeColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
        if (showBadge)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
