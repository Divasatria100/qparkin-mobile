import 'package:flutter/material.dart';

/// GradientHeader - Reusable gradient header component for QPARKIN app
///
/// Provides a consistent purple gradient header across all pages.
/// The gradient follows the QPARKIN design system with customizable
/// height, padding, and optional custom gradient colors.
///
/// Default gradient colors:
/// - Light purple: #7C5ED1
/// - Primary purple: #573ED1
///
/// Usage:
/// ```dart
/// GradientHeader(
///   child: Column(
///     children: [
///       Text('Header Content'),
///       // ... other widgets
///     ],
///   ),
/// )
/// ```
///
/// Customization:
/// ```dart
/// GradientHeader(
///   height: 200,
///   padding: EdgeInsets.all(24),
///   gradientColors: [Color(0xFF42CBF8), Color(0xFF573ED1), Color(0xFF39108A)],
///   child: YourWidget(),
/// )
/// ```
class GradientHeader extends StatelessWidget {
  /// The widget to display inside the gradient header
  final Widget child;

  /// Height of the gradient header container
  /// Default: 180
  final double height;

  /// Padding inside the gradient header
  /// Default: EdgeInsets.fromLTRB(20, 40, 20, 100)
  final EdgeInsets padding;

  /// Custom gradient colors (optional)
  /// If not provided, uses default QPARKIN gradient colors
  /// Default: [Color(0xFF7C5ED1), Color(0xFF573ED1)]
  final List<Color>? gradientColors;

  /// Creates a gradient header widget
  ///
  /// The [child] parameter is required and will be displayed inside the gradient.
  /// All other parameters are optional and have sensible defaults.
  const GradientHeader({
    super.key,
    required this.child,
    this.height = 180,
    this.padding = const EdgeInsets.fromLTRB(20, 40, 20, 100),
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    // Use custom colors if provided, otherwise use default QPARKIN gradient
    final colors = gradientColors ??
        [
          const Color(0xFF7C5ED1), // Lighter purple
          const Color(0xFF573ED1), // Primary purple
        ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
