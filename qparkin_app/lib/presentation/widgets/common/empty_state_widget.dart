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
/// - Follows QPARKIN design language
///
/// Usage:
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
/// Without action button:
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.inbox,
///   title: 'Tidak ada data',
///   description: 'Belum ada data untuk ditampilkan',
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

  /// Creates an EmptyStateWidget
  ///
  /// The [icon], [title], and [description] parameters are required.
  /// The [actionText] defaults to 'Tambah Sekarang'.
  /// The [onAction] callback is optional - if null, no button is shown.
  /// The [iconColor] is optional and defaults to brand purple.
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionText = 'Tambah Sekarang',
    this.onAction,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? const Color(0xFF573ED1);

    return Semantics(
      label: '$title. $description',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with circular background
              Semantics(
                label: 'Ikon status kosong',
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: effectiveIconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 48,
                    color: effectiveIconColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    fontFamily: 'Nunito',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                  fontFamily: 'Nunito',
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              // Action button (if onAction is provided)
              if (onAction != null) ...[
                const SizedBox(height: 24),
                Semantics(
                  button: true,
                  label: actionText,
                  hint: 'Ketuk untuk $actionText',
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: onAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF573ED1),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        actionText,
                        style: const TextStyle(
                          fontSize: 16,
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
    );
  }
}
