import 'package:flutter/material.dart';

/// Helper class for responsive design calculations
/// Provides methods to adapt padding, font sizes, and spacing based on screen size
/// Supports various screen sizes, orientations, and accessibility features
///
/// Requirements: 9.1, 9.5
class ResponsiveHelper {
  // Screen size breakpoints
  static const double mobileSmall = 320.0;  // Small phones
  static const double mobileMedium = 375.0; // Medium phones
  static const double mobileLarge = 414.0;  // Large phones
  static const double tablet = 768.0;       // Tablets (7-10 inch)
  static const double tabletLarge = 1024.0; // Large tablets (10+ inch)

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
  
  /// Check if device is a tablet
  static bool isTablet(BuildContext context) {
    final diagonal = MediaQuery.of(context).size.shortestSide;
    
    // Consider it a tablet if shortest side is >= 600dp
    return diagonal >= 600;
  }
  
  /// Get grid column count based on screen size and orientation
  /// Used for responsive grid layouts
  static int getGridColumnCount(BuildContext context, {int defaultColumns = 2}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;
    
    // Tablet in landscape: 4 columns
    if (screenWidth >= tablet && orientation == Orientation.landscape) {
      return 4;
    }
    
    // Tablet in portrait: 3 columns
    if (screenWidth >= tablet) {
      return 3;
    }
    
    // Large phone in landscape: 3 columns
    if (screenWidth >= mobileLarge && orientation == Orientation.landscape) {
      return 3;
    }
    
    // Default for phones
    return defaultColumns;
  }
  
  /// Get responsive grid spacing
  static double getGridSpacing(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= tablet) {
      return 16.0;
    } else if (screenWidth >= mobileLarge) {
      return 12.0;
    }
    return 8.0;
  }
  
  /// Check if motion reduction is enabled (accessibility)
  /// Requirements: 9.5
  static bool shouldReduceMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }
  
  /// Get animation duration based on motion reduction preference
  /// Requirements: 9.5
  static Duration getAnimationDuration(BuildContext context, Duration defaultDuration) {
    if (shouldReduceMotion(context)) {
      return Duration.zero; // No animation
    }
    return defaultDuration;
  }
  
  /// Get responsive app bar height
  static double getAppBarHeight(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    
    if (orientation == Orientation.landscape) {
      return 150.0; // Reduced height in landscape
    }
    return 200.0; // Default height in portrait
  }
  
  /// Get responsive list item height
  static double getListItemHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= tablet) {
      return 80.0;
    }
    return 72.0;
  }
  
  /// Get responsive bottom sheet max height
  static double getBottomSheetMaxHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;
    
    if (orientation == Orientation.landscape) {
      return screenHeight * 0.9; // 90% in landscape
    }
    return screenHeight * 0.85; // 85% in portrait
  }
  
  /// Get text scale factor with limits for readability
  static double getTextScaleFactor(BuildContext context) {
    final textScaler = MediaQuery.of(context).textScaler;
    final textScaleFactor = textScaler.scale(1.0);
    
    // Limit text scale factor to prevent layout issues
    // Min: 0.8, Max: 1.5
    return textScaleFactor.clamp(0.8, 1.5);
  }
  
  /// Get responsive margin for screen edges
  static EdgeInsets getScreenMargin(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;
    
    if (screenWidth >= tablet) {
      // Tablets: larger margins
      if (orientation == Orientation.landscape) {
        return const EdgeInsets.symmetric(horizontal: 48.0, vertical: 16.0);
      }
      return const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0);
    }
    
    // Phones: standard margins
    if (orientation == Orientation.landscape) {
      return const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0);
    }
    return const EdgeInsets.all(16.0);
  }
  
  /// Get responsive dialog width
  static double getDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= tablet) {
      return 500.0; // Fixed width for tablets
    }
    return screenWidth * 0.9; // 90% of screen width for phones
  }
}
