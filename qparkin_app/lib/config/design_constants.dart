/// Design System Constants for QParkin App
/// 
/// Centralized design tokens for consistent UI across all components
/// Following Material Design 3 principles with custom brand colors
library;

import 'package:flutter/material.dart';

/// Design constants for consistent UI
class DesignConstants {
  // Private constructor to prevent instantiation
  DesignConstants._();
  
  // ============================================================================
  // COLORS
  // ============================================================================
  
  /// Primary brand color (Purple)
  static const Color primaryColor = Color(0xFF573ED1);
  
  /// Success color (Green)
  static const Color successColor = Color(0xFF4CAF50);
  
  /// Warning color (Orange)
  static const Color warningColor = Color(0xFFFF9800);
  
  /// Error color (Red)
  static const Color errorColor = Color(0xFFF44336);
  
  /// Info color (Blue)
  static const Color infoColor = Color(0xFF2196F3);
  
  /// Background colors
  static const Color backgroundColor = Colors.white;
  static final Color backgroundSecondary = Colors.grey.shade50;
  static final Color backgroundTertiary = Colors.grey.shade100;
  
  /// Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static final Color textTertiary = Colors.grey.shade600;
  
  /// Border colors
  static final Color borderPrimary = Colors.grey.shade300;
  static final Color borderSecondary = Colors.grey.shade200;
  
  /// Surface colors with opacity
  static Color get primarySurface => primaryColor.withOpacity(0.1);
  static Color get successSurface => successColor.withOpacity(0.1);
  static Color get warningSurface => warningColor.withOpacity(0.1);
  static Color get errorSurface => errorColor.withOpacity(0.1);
  
  // ============================================================================
  // SPACING
  // ============================================================================
  
  /// Base spacing unit (8px)
  static const double spaceUnit = 8.0;
  
  /// Spacing scale
  static const double spaceXs = spaceUnit * 0.5;  // 4px
  static const double spaceSm = spaceUnit;         // 8px
  static const double spaceMd = spaceUnit * 1.5;  // 12px
  static const double spaceLg = spaceUnit * 2;    // 16px
  static const double spaceXl = spaceUnit * 3;    // 24px
  static const double space2xl = spaceUnit * 4;   // 32px
  
  // ============================================================================
  // CARD DESIGN
  // ============================================================================
  
  /// Standard card border radius
  static const double cardBorderRadius = 16.0;
  
  /// Standard card elevation
  static const double cardElevation = 2.0;
  
  /// Standard card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(spaceLg);
  
  /// Card shadow color
  static Color get cardShadowColor => Colors.black.withOpacity(0.08);
  
  /// Card border width
  static const double cardBorderWidth = 1.0;
  
  /// Focused card border width
  static const double cardBorderWidthFocused = 2.0;
  
  // ============================================================================
  // TYPOGRAPHY
  // ============================================================================
  
  /// Heading font sizes
  static const double fontSizeH1 = 24.0;
  static const double fontSizeH2 = 20.0;
  static const double fontSizeH3 = 18.0;
  static const double fontSizeH4 = 16.0;
  
  /// Body font sizes
  static const double fontSizeBody = 14.0;
  static const double fontSizeBodyLarge = 16.0;
  static const double fontSizeBodySmall = 12.0;
  
  /// Caption font size
  static const double fontSizeCaption = 12.0;
  static const double fontSizeCaptionSmall = 10.0;
  
  /// Font weights
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  
  // ============================================================================
  // ICONS
  // ============================================================================
  
  /// Standard icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;
  static const double iconSizeXLarge = 32.0;
  
  // ============================================================================
  // BUTTONS & INTERACTIVE ELEMENTS
  // ============================================================================
  
  /// Button border radius
  static const double buttonBorderRadius = 12.0;
  
  /// Button height
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 40.0;
  static const double buttonHeightLarge = 56.0;
  
  /// Button padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: spaceLg,
    vertical: spaceMd,
  );
  
  /// Minimum touch target size (accessibility)
  static const double minTouchTarget = 48.0;
  
  // ============================================================================
  // DIVIDERS
  // ============================================================================
  
  /// Divider thickness
  static const double dividerThickness = 1.0;
  
  /// Divider color
  static Color get dividerColor => Colors.grey.shade200;
  
  /// Divider spacing
  static const double dividerSpacing = spaceLg;
  
  // ============================================================================
  // ANIMATIONS
  // ============================================================================
  
  /// Standard animation duration
  static const Duration animationDuration = Duration(milliseconds: 200);
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationSlow = Duration(milliseconds: 300);
  
  /// Standard animation curve
  static const Curve animationCurve = Curves.easeInOut;
  
  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  /// Get card decoration with consistent styling
  static BoxDecoration getCardDecoration({
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    bool hasShadow = true,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? DesignConstants.backgroundColor,
      borderRadius: BorderRadius.circular(cardBorderRadius),
      border: borderColor != null
          ? Border.all(
              color: borderColor,
              width: borderWidth ?? cardBorderWidth,
            )
          : null,
      boxShadow: hasShadow
          ? [
              BoxShadow(
                color: cardShadowColor,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );
  }
  
  /// Get text style with consistent styling
  static TextStyle getTextStyle({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight ?? fontWeightRegular,
      color: color ?? textPrimary,
    );
  }
  
  /// Get heading text style
  static TextStyle getHeadingStyle({
    required double fontSize,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeightBold,
      color: color ?? textPrimary,
    );
  }
  
  /// Get body text style
  static TextStyle getBodyStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize ?? fontSizeBody,
      fontWeight: fontWeight ?? fontWeightRegular,
      color: color ?? textPrimary,
    );
  }
  
  /// Get caption text style
  static TextStyle getCaptionStyle({
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSizeCaption,
      fontWeight: fontWeightRegular,
      color: color ?? textSecondary,
    );
  }
}
