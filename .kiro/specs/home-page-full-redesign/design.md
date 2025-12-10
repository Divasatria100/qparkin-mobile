# Design Document - Home Page Full Redesign

## Overview

Dokumen ini menjelaskan desain lengkap untuk improvisasi Home Page aplikasi QPARKIN agar konsisten dengan Activity Page dan Map Page. Desain ini fokus pada peningkatan konsistensi visual, keterbacaan, dan kualitas tampilan tanpa mengubah fungsionalitas yang sudah ada.

### Design Goals

1. **Visual Consistency**: Menyamakan style dengan Activity Page dan Map Page
2. **Modern & Minimal**: Tampilan yang clean, modern, dan tidak berlebihan
3. **Clear Hierarchy**: Informasi penting lebih menonjol dengan hierarki yang jelas
4. **Responsive Interaction**: Feedback visual yang jelas pada setiap interaksi
5. **Accessibility**: Memenuhi standar WCAG AA untuk aksesibilitas

## Architecture

### Component Structure

```
HomePage
├── Header Section (Already Redesigned)
│   ├── Location Search Bar
│   ├── Notification Button
│   ├── Welcome Text
│   ├── Profile Section
│   ├── Premium Points Card
│   └── Search Bar
│
└── Content Section (Focus of This Redesign)
    ├── Nearby Locations Section
    │   ├── Section Header
    │   │   ├── Title "Lokasi Parkir Terdekat"
    │   │   └── "Lihat Semua" Button
    │   └── Location Cards List (Max 3)
    │       └── ParkingLocationCard (Redesigned)
    │           ├── Icon Container
    │           ├── Location Info
    │           │   ├── Name + Distance Badge
    │           │   ├── Address
    │           │   └── Available Slots Badge + Arrow
    │           └── InkWell Wrapper
    │
    └── Quick Actions Section
        ├── Section Title "Akses Cepat"
        └── Quick Actions Grid (4 columns)
            └── QuickActionCard (Reusable Component)
                ├── Icon Container
                ├── Label
                └── InkWell Wrapper
```

### State Management

- **Loading State**: Shimmer loading untuk Parking Location Cards
- **Empty State**: Tampilan ketika tidak ada data lokasi
- **Error State**: Tampilan ketika terjadi error dengan retry button
- **Success State**: Tampilan normal dengan data lokasi

## Components and Interfaces

### 1. ParkingLocationCard Component

**Purpose**: Menampilkan informasi lokasi parkir terdekat dengan desain yang konsisten

**Design Specifications**:
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.grey.shade200,
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
  padding: EdgeInsets.all(16),
)
```

**Layout Structure**:
- Icon Container (left): 44x44px, purple background, 12px border radius
- Content (center): Flexible width
  - Name (16px bold) + Distance Badge (right aligned)
  - Address (14px, grey.shade600, max 2 lines)
  - Available Slots Badge (left) + Arrow Icon (right)
- Spacing: 16px between icon and content, 8px between elements

**Interactive Behavior**:
- Wrapped in Material + InkWell
- OnTap: Navigate to Map Page
- Ripple effect with 16px border radius
- Subtle scale animation (0.98) on press

### 2. QuickActionCard Component (Reusable)

**Purpose**: Komponen reusable untuk Quick Actions dengan styling konsisten

**Method Signature**:
```dart
Widget _buildQuickActionCard({
  required IconData icon,
  required String label,
  required Color color,
  VoidCallback? onTap,
  bool useFontAwesome = false,
})
```

**Design Specifications**:
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: color.withOpacity(0.2),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
)
```

**Icon Container**:
```dart
Container(
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: color.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Icon(icon, color: color, size: 20),
)
```

**Grid Configuration**:
- 4 columns (crossAxisCount: 4)
- 12px spacing (crossAxisSpacing & mainAxisSpacing)
- Aspect ratio: 0.85 (childAspectRatio)

### 3. ShimmerLoading Component

**Purpose**: Menampilkan loading state yang informatif

**Design Specifications**:
- Shimmer gradient: Colors.grey.shade200 → Colors.grey.shade100
- Animation duration: 1500ms
- Card skeleton: Same size as actual card (height ~140px)
- Show 3 skeleton cards

**Implementation**:
```dart
Shimmer.fromColors(
  baseColor: Colors.grey.shade200,
  highlightColor: Colors.grey.shade100,
  child: Container(
    height: 140,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
  ),
)
```

### 4. EmptyState Component

**Purpose**: Menampilkan state ketika tidak ada data

**Design Specifications**:
```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Icon(
      Icons.location_off,
      size: 48,
      color: Colors.grey.shade400,
    ),
    SizedBox(height: 16),
    Text(
      'Tidak ada lokasi parkir tersedia',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ),
    SizedBox(height: 8),
    Text(
      'Coba lagi nanti atau cari di lokasi lain',
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade600,
      ),
    ),
  ],
)
```

### 5. ErrorState Component

**Purpose**: Menampilkan error state dengan retry button

**Design Specifications**:
```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Icon(
      Icons.error_outline,
      size: 48,
      color: Color(0xFFF44336),
    ),
    SizedBox(height: 16),
    Text('Terjadi Kesalahan', style: ...),
    SizedBox(height: 8),
    Text(errorMessage, style: ...),
    SizedBox(height: 24),
    ElevatedButton.icon(
      onPressed: onRetry,
      icon: Icon(Icons.refresh),
      label: Text('Coba Lagi'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF573ED1),
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  ],
)
```

## Data Models

### ParkingLocation Model

```dart
class ParkingLocation {
  final String name;
  final String distance;
  final String address;
  final int availableSlots;
  
  ParkingLocation({
    required this.name,
    required this.distance,
    required this.address,
    required this.availableSlots,
  });
}
```

### QuickAction Model

```dart
class QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool useFontAwesome;
  
  QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.useFontAwesome = false,
  });
}
```

## Error Handling

### Loading Errors

**Scenario**: Gagal memuat data lokasi parkir
**Handling**:
1. Tampilkan ErrorState component
2. Provide retry button
3. Log error untuk debugging
4. Show user-friendly error message

### Empty Data

**Scenario**: Tidak ada lokasi parkir tersedia
**Handling**:
1. Tampilkan EmptyState component
2. Provide helpful message
3. Suggest alternative actions

### Navigation Errors

**Scenario**: Gagal navigasi ke halaman lain
**Handling**:
1. Show snackbar dengan error message
2. Log error untuk debugging
3. Prevent app crash

## Testing Strategy

### Unit Tests

1. **Component Rendering Tests**
   - Test ParkingLocationCard renders correctly
   - Test QuickActionCard renders with different props
   - Test ShimmerLoading displays properly

2. **Interaction Tests**
   - Test card tap navigation
   - Test retry button functionality
   - Test "Lihat Semua" button navigation

3. **State Tests**
   - Test loading state display
   - Test empty state display
   - Test error state display

### Widget Tests

1. **Layout Tests**
   - Test 4-column grid layout
   - Test spacing consistency (8dp grid)
   - Test responsive layout

2. **Visual Tests**
   - Test color consistency
   - Test typography hierarchy
   - Test shadow and border rendering

### Integration Tests

1. **Navigation Flow**
   - Test Home → Map navigation
   - Test Home → Activity navigation
   - Test "Lihat Semua" navigation

2. **Data Loading**
   - Test loading state → success state
   - Test loading state → error state
   - Test retry functionality

## Design System Reference

### Colors

```dart
// Primary Colors
const primaryPurple = Color(0xFF573ED1);
const primaryBlue = Color(0xFF3B82F6);
const primaryGold = Color(0xFFFFA726);
const primaryGreen = Color(0xFF4CAF50);

// Neutral Colors
const textPrimary = Colors.black87;
const textSecondary = Colors.grey.shade600;
const borderColor = Colors.grey.shade200;
const backgroundColor = Colors.white;

// State Colors
const successColor = Colors.green.shade700;
const errorColor = Color(0xFFF44336);
const warningColor = Color(0xFFFF9800);
```

### Typography Scale

```dart
// Section Titles
TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
  color: Colors.black87,
)

// Card Titles
TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: Colors.black87,
)

// Body Text
TextStyle(
  fontSize: 14,
  color: Colors.grey.shade600,
)

// Badge Text
TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  color: Colors.grey.shade600,
)
```

### Spacing System (8dp Grid)

```dart
// Small spacing
const spacing8 = 8.0;

// Medium spacing
const spacing12 = 12.0;
const spacing16 = 16.0;

// Large spacing
const spacing24 = 24.0;
const spacing32 = 32.0;
```

### Shadow System

```dart
// Subtle shadow (cards)
BoxShadow(
  color: Colors.black.withOpacity(0.05),
  blurRadius: 8,
  offset: Offset(0, 2),
)

// Medium shadow (elevated elements)
BoxShadow(
  color: Colors.black.withOpacity(0.1),
  blurRadius: 12,
  offset: Offset(0, 4),
)
```

### Border Radius

```dart
// Card border radius
const cardRadius = 16.0;

// Icon container radius
const iconRadius = 12.0;

// Badge radius
const badgeRadius = 8.0;
```

## Accessibility Considerations

### Touch Targets

- Minimum touch target: 48dp x 48dp
- Card padding: 16px (provides adequate touch area)
- Button padding: 16px vertical, 32px horizontal

### Color Contrast

- Text on white background: 4.5:1 minimum (WCAG AA)
- Primary text (black87): 13.6:1 ratio ✓
- Secondary text (grey.shade600): 4.6:1 ratio ✓
- Badge text: Ensure sufficient contrast with background

### Semantic Structure

- Proper heading hierarchy
- Meaningful labels for screen readers
- Alternative text for icons
- Semantic HTML/Flutter widgets

### Interactive Feedback

- Visual feedback on all tappable elements (ripple effect)
- Clear focus indicators
- Consistent interaction patterns
- Smooth animations (not too fast, not too slow)

## Performance Optimizations

### Rendering Optimization

1. **Const Constructors**: Use const for static widgets
2. **Widget Reuse**: Reusable _buildQuickActionCard method
3. **Efficient Lists**: Use ListView.builder for dynamic lists
4. **Image Optimization**: Optimize icon sizes and formats

### Animation Performance

1. **Hardware Acceleration**: Use Transform for animations
2. **Smooth Transitions**: 60fps target for all animations
3. **Debouncing**: Prevent rapid repeated taps
4. **Lazy Loading**: Load data only when needed

### Memory Management

1. **Dispose Controllers**: Properly dispose animation controllers
2. **Cache Management**: Cache frequently used data
3. **Image Caching**: Use cached network images
4. **State Management**: Efficient state updates

## Migration Strategy

### Phase 1: Content Section Background
- Change background from grey to white
- Update content container decoration
- Test visual consistency

### Phase 2: Parking Location Cards
- Redesign card layout and styling
- Add InkWell for interactions
- Implement badges for distance and slots
- Add navigation to Map Page

### Phase 3: Quick Actions Grid
- Implement _buildQuickActionCard method
- Update grid to 4 columns
- Apply consistent styling
- Add proper interactions

### Phase 4: Loading & Error States
- Implement ShimmerLoading component
- Add EmptyState component
- Add ErrorState with retry
- Test all state transitions

### Phase 5: Micro Interactions
- Add scale animations on press
- Refine ripple effects
- Test animation performance
- Ensure smooth transitions

### Phase 6: Testing & Refinement
- Run all tests (unit, widget, integration)
- Check accessibility compliance
- Performance testing
- Final visual polish

## Conclusion

Desain ini memberikan improvisasi menyeluruh pada Home Page dengan fokus pada:
- **Konsistensi visual** dengan Activity dan Map Page
- **Komponen reusable** untuk maintainability
- **State management** yang proper (loading, empty, error)
- **Micro interactions** untuk UX yang lebih baik
- **Accessibility** yang memenuhi standar WCAG AA
- **Performance** yang optimal

Implementasi akan dilakukan secara bertahap sesuai migration strategy untuk memastikan setiap perubahan dapat ditest dengan baik sebelum melanjutkan ke tahap berikutnya.
