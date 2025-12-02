# Reusable Components Guide

## Overview

This guide documents the reusable UI components created for the QPARKIN application. These components are designed to maintain visual consistency, reduce code duplication, and provide a cohesive user experience across the app.

## Component Library

### 1. AnimatedCard

**Location:** `lib/presentation/widgets/common/animated_card.dart`

#### Purpose
Provides consistent micro-interaction feedback for tappable elements with scale animation and shadow effects.

#### Interface

```dart
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final List<BoxShadow>? shadows;
  
  const AnimatedCard({
    Key? key,
    required this.child,
    this.onTap,
    this.borderRadius = 16,
    this.padding,
    this.backgroundColor,
    this.shadows,
  }) : super(key: key);
}
```

#### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `child` | `Widget` | Required | The content to display inside the card |
| `onTap` | `VoidCallback?` | `null` | Callback when card is tapped |
| `borderRadius` | `double` | `16` | Corner radius in dp |
| `padding` | `EdgeInsets?` | `null` | Internal padding |
| `backgroundColor` | `Color?` | `Colors.white` | Background color |
| `shadows` | `List<BoxShadow>?` | Default shadow | Custom shadow effects |

#### Animation Behavior

- **Scale:** Animates to 0.97 on tap down
- **Duration:** 150ms
- **Curve:** `Curves.easeInOut`
- **Shadow:** Elevation changes on press

#### Usage Examples

**Basic Usage:**
```dart
AnimatedCard(
  onTap: () => print('Card tapped'),
  child: Text('Tap me'),
)
```

**Custom Styling:**
```dart
AnimatedCard(
  borderRadius: 20,
  padding: EdgeInsets.all(16),
  backgroundColor: Colors.blue.shade50,
  onTap: () => navigateToDetail(),
  child: Column(
    children: [
      Icon(Icons.car),
      Text('My Vehicle'),
    ],
  ),
)
```

**With Custom Shadow:**
```dart
AnimatedCard(
  shadows: [
    BoxShadow(
      color: Colors.purple.withOpacity(0.2),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ],
  child: content,
)
```

#### Best Practices

1. Use for all tappable cards to maintain consistency
2. Keep `borderRadius` consistent across similar elements (default 16dp)
3. Avoid nesting multiple AnimatedCards
4. Use `const` constructor when possible for performance

---

### 2. GradientHeader

**Location:** `lib/presentation/widgets/common/gradient_header.dart`

#### Purpose
Provides a consistent gradient header component used across main pages for brand identity.

#### Interface

```dart
class GradientHeader extends StatelessWidget {
  final Widget child;
  final double height;
  final EdgeInsets padding;
  final List<Color>? gradientColors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  
  const GradientHeader({
    Key? key,
    required this.child,
    this.height = 180,
    this.padding = const EdgeInsets.fromLTRB(20, 40, 20, 20),
    this.gradientColors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  }) : super(key: key);
}
```

#### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `child` | `Widget` | Required | Content to display in header |
| `height` | `double` | `180` | Header height in dp |
| `padding` | `EdgeInsets` | `(20, 40, 20, 20)` | Internal padding |
| `gradientColors` | `List<Color>?` | QPARKIN gradient | Custom gradient colors |
| `begin` | `AlignmentGeometry` | `topLeft` | Gradient start alignment |
| `end` | `AlignmentGeometry` | `bottomRight` | Gradient end alignment |

#### Default Gradient Colors

```dart
[
  Color(0xFF42CBF8), // Light blue
  Color(0xFF573ED1), // Primary purple
  Color(0xFF39108A), // Dark purple
]
```

#### Usage Examples

**Basic Usage:**
```dart
GradientHeader(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Profile',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 8),
      Text(
        'Manage your account',
        style: TextStyle(color: Colors.white70),
      ),
    ],
  ),
)
```

**Custom Height:**
```dart
GradientHeader(
  height: 220,
  child: UserInfoSection(),
)
```

**Custom Gradient:**
```dart
GradientHeader(
  gradientColors: [
    Colors.orange,
    Colors.red,
    Colors.pink,
  ],
  child: content,
)
```

**With Complex Content:**
```dart
GradientHeader(
  padding: EdgeInsets.fromLTRB(20, 50, 20, 30),
  child: Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Welcome', style: headerStyle),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () => navigateToNotifications(),
          ),
        ],
      ),
      SizedBox(height: 16),
      PremiumPointsCard(points: userPoints),
    ],
  ),
)
```

#### Best Practices

1. Use default gradient colors for brand consistency
2. Adjust `height` based on content needs
3. Ensure text color contrasts well with gradient (use white/white70)
4. Keep padding consistent with 8dp grid system

---

### 3. EmptyStateWidget

**Location:** `lib/presentation/widgets/common/empty_state_widget.dart`

#### Purpose
Displays a consistent empty state with icon, message, and optional action button.

#### Interface

```dart
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? iconColor;
  final double iconSize;
  
  const EmptyStateWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    this.actionText,
    this.onAction,
    this.iconColor,
    this.iconSize = 80,
  }) : super(key: key);
}
```

#### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `title` | `String` | Required | Main heading text |
| `description` | `String` | Required | Descriptive message |
| `icon` | `IconData` | Required | Icon to display |
| `actionText` | `String?` | `null` | Button text (if provided) |
| `onAction` | `VoidCallback?` | `null` | Button callback |
| `iconColor` | `Color?` | Grey | Icon color |
| `iconSize` | `double` | `80` | Icon size in dp |

#### Usage Examples

**Empty Vehicle List:**
```dart
EmptyStateWidget(
  icon: Icons.directions_car_outlined,
  title: 'Tidak ada kendaraan',
  description: 'Anda belum mendaftarkan kendaraan. Tambahkan kendaraan pertama Anda sekarang.',
  actionText: 'Tambah Kendaraan',
  onAction: () => navigateToAddVehicle(),
  iconColor: Colors.purple,
)
```

**Error State:**
```dart
EmptyStateWidget(
  icon: Icons.error_outline,
  title: 'Terjadi Kesalahan',
  description: 'Tidak dapat memuat data. Periksa koneksi internet Anda.',
  actionText: 'Coba Lagi',
  onAction: () => retryFetch(),
  iconColor: Colors.red,
)
```

**No Results:**
```dart
EmptyStateWidget(
  icon: Icons.search_off,
  title: 'Tidak ada hasil',
  description: 'Pencarian Anda tidak menemukan hasil. Coba kata kunci lain.',
  // No action button
)
```

**Custom Icon Size:**
```dart
EmptyStateWidget(
  icon: Icons.inbox_outlined,
  iconSize: 100,
  title: 'Kotak masuk kosong',
  description: 'Anda tidak memiliki notifikasi baru.',
)
```

#### Best Practices

1. Use descriptive, user-friendly messages
2. Provide actionable next steps when possible
3. Choose icons that clearly represent the empty state
4. Keep title concise (1-5 words)
5. Make description helpful (explain why it's empty and what to do)

---

## Component Comparison

| Component | Use Case | Interactive | Animation |
|-----------|----------|-------------|-----------|
| AnimatedCard | Tappable cards | Yes | Scale + Shadow |
| GradientHeader | Page headers | No | None |
| EmptyStateWidget | Empty/error states | Optional | None |

## Design System Integration

### Color Palette

All components follow the QPARKIN color system:

```dart
// Primary Colors
const primaryPurple = Color(0xFF573ED1);
const lightBlue = Color(0xFF42CBF8);
const darkPurple = Color(0xFF39108A);

// Neutral Colors
const textPrimary = Color(0xFF1A1A1A);
const textSecondary = Color(0xFF666666);
const backgroundGrey = Color(0xFFF5F5F5);
```

### Spacing System (8dp Grid)

```dart
const spacing4 = 4.0;
const spacing8 = 8.0;
const spacing12 = 12.0;
const spacing16 = 16.0;
const spacing20 = 20.0;
const spacing24 = 24.0;
const spacing32 = 32.0;
```

### Typography

```dart
// Headers
const headerLarge = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  fontFamily: 'Nunito',
);

const headerMedium = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  fontFamily: 'Nunito',
);

// Body
const bodyLarge = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.normal,
  fontFamily: 'Nunito',
);

const bodyMedium = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.normal,
  fontFamily: 'Nunito',
);
```

## Accessibility Guidelines

All components follow WCAG 2.1 AA standards:

### AnimatedCard
- Minimum touch target: 48dp
- Semantic label provided via child
- Tap feedback for screen readers

### GradientHeader
- Text contrast ratio ≥ 4.5:1
- Semantic structure maintained
- Proper heading hierarchy

### EmptyStateWidget
- Icon has semantic label
- Action button meets 48dp minimum
- Clear, descriptive text

## Testing Components

### Unit Test Example

```dart
testWidgets('AnimatedCard triggers onTap', (tester) async {
  bool tapped = false;
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: AnimatedCard(
          onTap: () => tapped = true,
          child: Text('Test'),
        ),
      ),
    ),
  );
  
  await tester.tap(find.byType(AnimatedCard));
  expect(tapped, true);
});
```

### Integration Test Example

```dart
testWidgets('EmptyStateWidget shows and triggers action', (tester) async {
  bool actionTriggered = false;
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: EmptyStateWidget(
          icon: Icons.inbox,
          title: 'Empty',
          description: 'No items',
          actionText: 'Add Item',
          onAction: () => actionTriggered = true,
        ),
      ),
    ),
  );
  
  expect(find.text('Empty'), findsOneWidget);
  expect(find.text('Add Item'), findsOneWidget);
  
  await tester.tap(find.text('Add Item'));
  expect(actionTriggered, true);
});
```

## Migration Guide

### Replacing Existing Cards

**Before:**
```dart
GestureDetector(
  onTap: () => navigate(),
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: content,
  ),
)
```

**After:**
```dart
AnimatedCard(
  onTap: () => navigate(),
  child: content,
)
```

### Replacing Headers

**Before:**
```dart
Container(
  height: 180,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF42CBF8), Color(0xFF573ED1)],
    ),
  ),
  padding: EdgeInsets.all(20),
  child: content,
)
```

**After:**
```dart
GradientHeader(
  child: content,
)
```

## Performance Considerations

1. **Use const constructors** when child widgets are constant
2. **Avoid rebuilding** components unnecessarily
3. **Cache complex children** using `const` or `final`
4. **Minimize nesting** of animated components

## Related Documentation

- [Design System Guide](./design_system_guide.md)
- [Accessibility Guide](./accessibility_features.md)
- [Component Testing Guide](./component_testing_guide.md)

## Version History

- **v1.0.0** (2024-12): Initial component library with AnimatedCard, GradientHeader, EmptyStateWidget
