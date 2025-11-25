import 'package:flutter/material.dart';

/// Helper class for responsive design calculations
/// Provides methods to adapt padding, font sizes, and spacing based on screen size
///
/// Requirements: 13.7
class ResponsiveHelper {
  // Screen size breakpoints
  static const double mobileSmall = 320.0;  // iPhone SE
  static const double mobileMedium = 375.0; // iPhone 12
  static const double mobileLarge = 414.0;  // iPhone 12 Pro Max
  static const double tablet = 768.0;       // iPad

  /// Get responsive padding based on screen width
  static double getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < mobileMedium) {
      return 12.0;
    } else if (screenWidth < mobileLarge) {
      return 16.0;
    } else if (screenWidth < tablet) {
      return 20.0;
    }
    return 24.0;
  }

  /// Get responsive font size based on base size and screen width
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < mobileMedium) {
      return baseSize * 0.9;
    } else if (screenWidth < mobileLarge) {
      return baseSize;
    }
    return baseSize * 1.1;
  }

  /// Get responsive card spacing
  static double getCardSpacing(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < mobileMedium) {
      return 12.0;
    } else if (screenWidth < mobileLarge) {
      return 16.0;
    }
    return 20.0;
  }

  /// Get responsive border radius
  static double getBorderRadius(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < mobileMedium) {
      return 12.0;
    }
    return 16.0;
  }

  /// Get responsive icon size
  static double getIconSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < mobileMedium) {
      return baseSize * 0.9;
    }
    return baseSize;
  }

  /// Check if screen is small
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileMedium;
  }

  /// Check if screen is medium
  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileMedium && width < mobileLarge;
  }

  /// Check if screen is large
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= mobileLarge;
  }

  /// Get responsive horizontal padding for content
  static EdgeInsets getContentPadding(BuildContext context) {
    final padding = getResponsivePadding(context);
    return EdgeInsets.symmetric(horizontal: padding);
  }

  /// Get responsive padding for cards
  static EdgeInsets getCardPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;
    
    // Reduce padding in landscape mode
    if (orientation == Orientation.landscape) {
      if (screenWidth < mobileMedium) {
        return const EdgeInsets.all(10.0);
      } else if (screenWidth < mobileLarge) {
        return const EdgeInsets.all(14.0);
      }
      return const EdgeInsets.all(16.0);
    }
    
    if (screenWidth < mobileMedium) {
      return const EdgeInsets.all(12.0);
    } else if (screenWidth < mobileLarge) {
      return const EdgeInsets.all(16.0);
    }
    return const EdgeInsets.all(20.0);
  }
  
  /// Check if device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  /// Get orientation-aware spacing
  static double getOrientationAwareSpacing(BuildContext context, double portraitSpacing) {
    if (isLandscape(context)) {
      return portraitSpacing * 0.75; // Reduce spacing in landscape
    }
    return portraitSpacing;
  }
}
