import 'package:flutter/material.dart';

/// Enum for points card design variants
enum PointsCardVariant {
  gold, // Warm gold gradient design
  purple, // Purple border design (recommended for brand consistency)
}

/// A premium card widget for displaying user reward points
///
/// This widget provides a visually appealing, tappable card that displays
/// the user's accumulated reward points. It supports two design variants
/// and includes proper accessibility labels.
///
/// Example usage:
/// ```dart
/// PremiumPointsCard(
///   points: 200,
///   variant: PointsCardVariant.purple,
///   onTap: () => Navigator.pushNamed(context, '/points-history'),
/// )
/// ```
class PremiumPointsCard extends StatelessWidget {
  /// The number of points to display
  final int points;

  /// Callback function when the card is tapped
  final VoidCallback? onTap;

  /// The visual design variant to use
  final PointsCardVariant variant;

  const PremiumPointsCard({
    Key? key,
    required this.points,
    this.onTap,
    this.variant = PointsCardVariant.purple,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Poin reward Anda: $points poin. Ketuk untuk melihat detail',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: _buildDecoration(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Icon container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getIconBackgroundColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.star,
                    color: _getIconColor(),
                    size: 24,
                    semanticLabel: 'Ikon bintang poin',
                  ),
                ),
                const SizedBox(width: 16),
                // Points info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExcludeSemantics(
                        child: Text(
                          'Poin Saya',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _getLabelColor(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      ExcludeSemantics(
                        child: Text(
                          '$points Poin',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _getValueColor(),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow indicator
                if (onTap != null)
                  Icon(
                    Icons.chevron_right,
                    color: _getArrowColor(),
                    size: 24,
                    semanticLabel: 'Panah navigasi',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the decoration based on the selected variant
  BoxDecoration _buildDecoration() {
    switch (variant) {
      case PointsCardVariant.gold:
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFA726).withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case PointsCardVariant.purple:
        return BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF573ED1).withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF573ED1).withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
    }
  }

  /// Gets the icon background color based on variant
  Color _getIconBackgroundColor() {
    switch (variant) {
      case PointsCardVariant.gold:
        return const Color(0xFFFFA726).withOpacity(0.2);
      case PointsCardVariant.purple:
        return const Color(0xFF573ED1).withOpacity(0.1);
    }
  }

  /// Gets the icon color based on variant
  Color _getIconColor() {
    return const Color(0xFFFFA726); // Gold star for both variants
  }

  /// Gets the label text color based on variant
  Color _getLabelColor() {
    switch (variant) {
      case PointsCardVariant.gold:
        return const Color(0xFF6D4C41); // Warm brown
      case PointsCardVariant.purple:
        return Colors.grey.shade600;
    }
  }

  /// Gets the value text color based on variant
  Color _getValueColor() {
    switch (variant) {
      case PointsCardVariant.gold:
        return const Color(0xFF6D4C41); // Warm brown
      case PointsCardVariant.purple:
        return const Color(0xFF573ED1); // Brand purple
    }
  }

  /// Gets the arrow icon color based on variant
  Color _getArrowColor() {
    switch (variant) {
      case PointsCardVariant.gold:
        return const Color(0xFF6D4C41).withOpacity(0.5);
      case PointsCardVariant.purple:
        return Colors.grey.shade400;
    }
  }
}
