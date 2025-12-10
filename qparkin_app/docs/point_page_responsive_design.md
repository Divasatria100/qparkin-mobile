# Point Page Responsive Design Implementation

## Overview

This document describes the responsive design implementation for the Point Page feature in QPARKIN. The implementation ensures the point page works seamlessly across various Android screen sizes, orientations, and accessibility settings.

## Requirements Addressed

- **Requirement 9.1**: Responsive design for various screen sizes
- **Requirement 9.5**: Motion reduction support for animations

## Screen Size Support

### Breakpoints

The responsive design uses the following breakpoints defined in `ResponsiveHelper`:

- **Mobile Small**: 320dp (e.g., small phones)
- **Mobile Medium**: 375dp (e.g., standard phones)
- **Mobile Large**: 414dp (e.g., large phones)
- **Tablet**: 768dp (e.g., 7-10 inch tablets)
- **Tablet Large**: 1024dp (e.g., 10+ inch tablets)

### Responsive Features

#### 1. Dynamic Padding and Spacing

```dart
// Padding adapts based on screen width
final padding = ResponsiveHelper.getResponsivePadding(context);
// Returns: 12dp (small), 16dp (medium), 20dp (large), 24dp (tablet)

// Spacing reduces in landscape mode
final spacing = ResponsiveHelper.getOrientationAwareSpacing(context, 16.0);
// Returns: 16dp (portrait), 12dp (landscape)
```

#### 2. Responsive Font Sizes

All text elements scale appropriately:

```dart
final fontSize = ResponsiveHelper.getResponsiveFontSize(context, 16);
// Returns: 14.4dp (small), 16dp (medium), 17.6dp (large)
```

#### 3. Grid Layout Adaptation

The statistics card grid adapts to screen size and orientation:

- **Phone Portrait**: 2 columns
- **Phone Landscape**: 3 columns
- **Tablet Portrait**: 3 columns
- **Tablet Landscape**: 4 columns

```dart
final columns = ResponsiveHelper.getGridColumnCount(context, defaultColumns: 2);
```

#### 4. Touch Target Sizes

All interactive elements meet the minimum 48x48dp touch target requirement:

- Buttons: `minimumSize: Size.fromHeight(48)`
- Filter chips: `minWidth: 48, minHeight: 48`
- Icon buttons: `constraints: BoxConstraints(minWidth: 48, minHeight: 48)`

## Orientation Support

### Landscape Mode Optimizations

#### 1. Reduced App Bar Height

```dart
// Portrait: 200dp, Landscape: 150dp
final expandedHeight = ResponsiveHelper.getAppBarHeight(context);
```

#### 2. Side-by-Side Layout (Tablets)

In landscape mode on tablets, the Overview tab displays balance and statistics cards side-by-side:

```dart
Row(
  children: [
    Expanded(child: PointBalanceCard(...)),
    SizedBox(width: spacing),
    Expanded(child: PointStatisticsCard(...)),
  ],
)
```

#### 3. Adjusted Spacing

Spacing is reduced by 25% in landscape mode to maximize content visibility:

```dart
if (isLandscape(context)) {
  return portraitSpacing * 0.75;
}
```

#### 4. Bottom Sheet Height

Bottom sheets adapt to orientation:

- **Portrait**: 85% of screen height
- **Landscape**: 90% of screen height

## Accessibility Features

### Motion Reduction Support

The implementation respects the system's motion reduction preference:

#### 1. Shimmer Animations

```dart
if (ResponsiveHelper.shouldReduceMotion(context)) {
  // Display static loading state
  return Container(color: Colors.grey[300]);
} else {
  // Display animated shimmer
  return AnimatedBuilder(...);
}
```

#### 2. Animation Duration Control

```dart
final duration = ResponsiveHelper.getAnimationDuration(
  context,
  Duration(milliseconds: 300),
);
// Returns: Duration.zero if motion is reduced, otherwise original duration
```

### Text Scaling

Text scale factor is limited to prevent layout issues while still supporting accessibility:

```dart
// Clamps between 0.8x and 1.5x
final scaleFactor = ResponsiveHelper.getTextScaleFactor(context);
```

### Semantic Labels

All interactive elements include proper semantic labels for screen readers:

```dart
Semantics(
  label: 'Saldo poin Anda. 1,250 poin',
  button: true,
  hint: 'Ketuk untuk melihat detail',
  child: Widget(...),
)
```

## Testing Recommendations

### Screen Sizes to Test

1. **Small Phone** (320x568): iPhone SE, small Android devices
2. **Medium Phone** (375x667): iPhone 12, standard Android devices
3. **Large Phone** (414x896): iPhone 12 Pro Max, large Android devices
4. **Tablet** (768x1024): iPad, 7-10 inch Android tablets
5. **Large Tablet** (1024x1366): iPad Pro, 10+ inch Android tablets

### Orientations to Test

- Portrait mode (all devices)
- Landscape mode (all devices)

### Accessibility Settings to Test

1. **Text Size**: Test with system text size set to:
   - Small (0.85x)
   - Default (1.0x)
   - Large (1.15x)
   - Extra Large (1.3x)

2. **Motion Reduction**: Enable "Reduce motion" in system accessibility settings

3. **Screen Reader**: Test with TalkBack (Android) enabled

## Implementation Files

### Core Files

- `lib/utils/responsive_helper.dart`: Responsive design utilities
- `lib/presentation/screens/point_page.dart`: Main point page with responsive layouts
- `lib/presentation/widgets/point_balance_card.dart`: Responsive balance card
- `lib/presentation/widgets/point_statistics_card.dart`: Responsive statistics grid
- `lib/presentation/widgets/filter_bottom_sheet.dart`: Responsive bottom sheet
- `lib/presentation/widgets/point_info_bottom_sheet.dart`: Responsive info sheet

### Key Methods in ResponsiveHelper

| Method | Purpose |
|--------|---------|
| `getResponsivePadding()` | Returns padding based on screen width |
| `getResponsiveFontSize()` | Scales font size for screen width |
| `getGridColumnCount()` | Returns optimal grid columns |
| `isLandscape()` | Checks if device is in landscape |
| `isTablet()` | Checks if device is a tablet |
| `shouldReduceMotion()` | Checks motion reduction preference |
| `getAnimationDuration()` | Returns duration respecting motion preference |
| `getAppBarHeight()` | Returns orientation-aware app bar height |
| `getBottomSheetMaxHeight()` | Returns orientation-aware sheet height |

## Performance Considerations

1. **Layout Calculations**: All responsive calculations are performed during build, not in initState
2. **Conditional Rendering**: Different layouts for portrait/landscape avoid unnecessary rebuilds
3. **Animation Control**: Animations are disabled when motion reduction is enabled, improving performance
4. **Grid Optimization**: Grid spacing and columns are calculated once per build

## Future Enhancements

1. **Foldable Device Support**: Add support for foldable devices with multiple screen configurations
2. **Desktop Support**: Extend responsive design for desktop/web platforms
3. **Dynamic Type**: Further enhance text scaling support
4. **High Contrast Mode**: Add support for high contrast accessibility mode

## References

- [Material Design Guidelines - Layout](https://material.io/design/layout/responsive-layout-grid.html)
- [Flutter Responsive Design](https://docs.flutter.dev/development/ui/layout/responsive)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Android Accessibility](https://developer.android.com/guide/topics/ui/accessibility)
