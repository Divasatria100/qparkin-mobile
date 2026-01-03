import 'package:flutter/material.dart';

/// EmptyStateWidget - Reusable empty state component for QPARKIN app
///
/// Provides a consistent empty state display across the application when
/// data is not available or lists are empty. Includes an icon, title,
/// description, and optional action button.
///
/// Features:
/// - Consistent styling and spacing following 8dp grid system
/// - Semantic labels for accessibility (screen reader support)
/// - Optional action button with customizable text and callback
/// - Customizable icon and colors
/// - Compact mode for constrained spaces (cards, horizontal lists)
/// - Follows QPARKIN design language
///
/// Usage:
/// Full page mode:
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.directions_car,
///   title: 'Tidak ada kendaraan',
///   description: 'Anda belum memiliki kendaraan terdaftar',
///   actionText: 'Tambah Kendaraan',
///   onAction: () => Navigator.push(...),
/// )
/// ```
///
/// Compact mode (for cards):
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.directions_car,
///   title: 'Tidak ada kendaraan',
///   description: 'Tambahkan kendaraan pertama Anda',
///   compact: true,
///   actionText: 'Tambah',
///   onAction: () => Navigator.push(...),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  /// The icon to display at the top of the empty state
  final IconData icon;

  /// The main title text
  final String title;

  /// The description text explaining the empty state
  final String description;

  /// The text for the action button (optional)
  /// Default: 'Tambah Sekarang'
  final String actionText;

  /// Callback function when the action button is tapped (optional)
  /// If null, no action button will be displayed
  final VoidCallback? onAction;

  /// Custom color for the icon (optional)
  /// If not provided, uses brand purple (0xFF573ED1)
  final Color? iconColor;

  /// Compact mode for constrained spaces (cards, horizontal lists)
  /// When true, uses smaller sizes and reduced padding
  /// Default: false
  final bool compact;

  /// Creates an EmptyStateWidget
  ///
  /// The [icon], [title], and [description] parameters are required.
  /// The [actionText] defaults to 'Tambah Sekarang'.
  /// The [onAction] callback is optional - if null, no button is shown.
  /// The [iconColor] is optional and defaults to brand purple.
  /// The [compact] mode is optional and defaults to false.
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionText = 'Tambah Sekarang',
    this.onAction,
    this.iconColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? const Color(0xFF573ED1);
    
    // Adaptive sizing based on compact mode
    final iconContainerSize = compact ? 56.0 : 96.0;
    final iconSize = compact ? 28.0 : 48.0;
    final padding = compact ? 16.0 : 32.0;
    final titleFontSize = compact ? 16.0 : 20.0;
    final descriptionFontSize = compact ? 12.0 : 14.0;
    final spacingAfterIcon = compact ? 12.0 : 24.0;
    final spacingAfterTitle = compact ? 4.0 : 8.0;
    final spacingBeforeButton = compact ? 12.0 : 24.0;
    final buttonHeight = compact ? 40.0 : 48.0;
    final buttonFontSize = compact ? 14.0 : 16.0;

    return Semantics(
      label: '$title. $description',
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with circular background
                Semantics(
                  label: 'Ikon status kosong',
                  child: Container(
                    width: iconContainerSize,
                    height: iconContainerSize,
                    decoration: BoxDecoration(
                      color: effectiveIconColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: iconSize,
                      color: effectiveIconColor,
                    ),
                  ),
                ),
                SizedBox(height: spacingAfterIcon),

                // Title
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      fontFamily: 'Nunito',
                    ),
                    textAlign: TextAlign.center,
                    maxLines: compact ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: spacingAfterTitle),

                // Description
                Text(
                  description,
                  style: TextStyle(
                    fontSize: descriptionFontSize,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                    fontFamily: 'Nunito',
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: compact ? 2 : 4,
                  overflow: TextOverflow.ellipsis,
                ),

                // Action button (if onAction is provided)
                if (onAction != null) ...[
                  SizedBox(height: spacingBeforeButton),
                  Semantics(
                    button: true,
                    label: actionText,
                    hint: 'Ketuk untuk $actionText',
                    child: SizedBox(
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: onAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF573ED1),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(compact ? 8 : 12),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: compact ? 16 : 24,
                            vertical: compact ? 8 : 12,
                          ),
                        ),
                        child: Text(
                          actionText,
                          style: TextStyle(
                            fontSize: buttonFontSize,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
