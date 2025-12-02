import 'package:flutter/material.dart';

/// AnimatedCard - Reusable card widget with scale animation on press
///
/// Provides smooth micro-interaction feedback for tappable cards across the app.
/// This component is used throughout QPARKIN to maintain consistent interaction
/// patterns and visual feedback.
///
/// Features:
/// - Scale animation (0.97) on tap down
/// - Shadow elevation change on press
/// - Ripple effect with brand color (0xFF573ED1)
/// - 150ms animation duration with easeInOut curve
/// - Customizable border radius and padding
///
/// Usage:
/// ```dart
/// AnimatedCard(
///   onTap: () => print('Card tapped'),
///   borderRadius: 16,
///   child: Container(
///     padding: EdgeInsets.all(16),
///     child: Text('Card Content'),
///   ),
/// )
/// ```
///
/// Design System:
/// - Follows QPARKIN 8dp grid system
/// - Uses brand purple color (0xFF573ED1) for ripple effects
/// - Consistent with home_page, activity_page, and map_page interactions
class AnimatedCard extends StatefulWidget {
  /// The widget to display inside the card
  final Widget child;

  /// Callback function when the card is tapped
  final VoidCallback? onTap;

  /// Border radius for the card corners (default: 16dp)
  final double borderRadius;

  /// Optional padding inside the card
  final EdgeInsets? padding;

  /// Creates an AnimatedCard widget
  ///
  /// The [child] parameter is required and represents the content of the card.
  /// The [onTap] callback is optional and will be called when the card is tapped.
  /// The [borderRadius] defaults to 16dp following the QPARKIN design system.
  /// The [padding] is optional and can be used to add internal spacing.
  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 16,
    this.padding,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        widget.onTap?.call();
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              splashColor: const Color(0xFF573ED1).withValues(alpha: 0.15),
              highlightColor: const Color(0xFF573ED1).withValues(alpha: 0.08),
              child: widget.padding != null
                  ? Padding(
                      padding: widget.padding!,
                      child: widget.child,
                    )
                  : widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
