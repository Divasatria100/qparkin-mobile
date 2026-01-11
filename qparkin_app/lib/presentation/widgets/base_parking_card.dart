import 'package:flutter/material.dart';
import '../../config/design_constants.dart';

/// Base reusable card widget for all parking-related cards
/// 
/// Provides consistent styling across the booking page:
/// - Background: White
/// - Border: 1.5px PrimaryLight (#E8E0FF)
/// - Border Radius: 16px
/// - Elevation: 2.0
/// - Padding: 16px (from DesignConstants)
/// 
/// Usage:
/// ```dart
/// BaseParkingCard(
///   child: Column(
///     children: [
///       Text('Card Content'),
///     ],
///   ),
/// )
/// ```
class BaseParkingCard extends StatelessWidget {
  /// Child widget to display inside the card
  final Widget child;
  
  /// Optional custom padding (defaults to DesignConstants.cardPadding)
  final EdgeInsetsGeometry? padding;
  
  /// Optional semantics label for accessibility
  final String? semanticsLabel;

  const BaseParkingCard({
    Key? key,
    required this.child,
    this.padding,
    this.semanticsLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      decoration: BoxDecoration(
        color: DesignConstants.backgroundColor,
        borderRadius: BorderRadius.circular(DesignConstants.cardBorderRadius),
        border: Border.all(
          color: DesignConstants.primaryLight,
          width: DesignConstants.cardBorderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: DesignConstants.cardShadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? DesignConstants.cardPadding,
        child: child,
      ),
    );

    if (semanticsLabel != null) {
      return Semantics(
        label: semanticsLabel,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
