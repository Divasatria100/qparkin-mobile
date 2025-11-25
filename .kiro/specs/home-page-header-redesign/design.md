# Design Document - Home Page Header Redesign

## Overview

This document provides a comprehensive design solution for redesigning the QPARKIN Home Page header. The redesign focuses on improving visual balance, enhancing the points display, and maintaining consistency with the Activity Page and Map Page design language.

## Current State Analysis

### Visual Weaknesses Identified

1. **Unbalanced Layout**
   - The profile section (left) and points section (right) compete for attention
   - Points display feels cramped in the corner
   - Horizontal layout creates visual tension on smaller screens
   - Email text may truncate on narrow devices

2. **Points Display Issues**
   - "Poin Saya" label uses grey color (#BDBDBD) which lacks contrast
   - Points value (200) is positioned awkwardly next to profile info
   - No visual separation or card treatment for premium feel
   - Star icon and value feel disconnected from the label

3. **Inconsistency with Other Pages**
   - Activity Page uses clean white backgrounds with card-based layouts
   - Map Page uses consistent spacing and modern card designs
   - Home Page header feels more cluttered and less refined
   - Glassmorphism is overused (location field, notification button)

4. **Visual Hierarchy Problems**
   - Too many competing focal points in one row
   - Greeting text ("Selamat Datang Kembali!") gets lost
   - Search bar placement feels disconnected from header flow

### Design Language from Activity & Map Pages

**Consistent Elements to Maintain:**
- Primary color: #573ED1 (purple)
- White card backgrounds with subtle shadows
- Border radius: 12-16px for cards
- Spacing rhythm: 8dp grid (8, 12, 16, 24, 32px)
- Typography: Bold titles (20-22px), body (14-16px), labels (12-14px)
- Subtle elevation with BoxShadow (opacity 0.05-0.1, blur 8-12)
- Clean, minimal aesthetic with breathing room

## Architecture

### Component Structure

```
Header Container (Gradient Background)
├── SafeArea
│   ├── Top Bar Row
│   │   ├── Location Selector (Glassmorphic)
│   │   └── Notification Button (Glassmorphic)
│   │
│   ├── Greeting Text
│   │
│   ├── Profile & Points Card (NEW)
│   │   ├── Profile Section
│   │   │   ├── Avatar
│   │   │   └── User Info Column
│   │   │       ├── Name
│   │   │       └── Email
│   │   │
│   │   └── Points Card (NEW - Separated)
│   │       ├── Points Label
│   │       ├── Points Value Row
│   │       │   ├── Star Icon
│   │       │   └── Points Number
│   │       └── Optional: Tap to view details
│   │
│   └── Search Bar
```

### Key Design Changes

1. **Separate Points into Premium Card**
   - Extract points from profile row
   - Create dedicated card below profile
   - Use white background with gradient accent
   - Add subtle shadow for elevation

2. **Improve Visual Hierarchy**
   - Greeting → Profile → Points → Search (vertical flow)
   - Each section has clear breathing room
   - Points card becomes a focal point

3. **Enhance Points Presentation**
   - Larger typography for value (28-32px)
   - High contrast label (white or dark text)
   - Icon and value in prominent row
   - Optional: Add "Lihat Detail" link

## Components and Interfaces

### 1. Premium Points Card Widget

**Purpose:** Display user's reward points in a visually appealing, tappable card

**Design Specifications:**
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)], // Warm gold gradient
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Color(0xFFFFA726).withOpacity(0.2),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  ),
  padding: EdgeInsets.all(20),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Left: Label and value
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Poin Saya', style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6D4C41), // Warm brown
          )),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.star, color: Color(0xFFFFA726), size: 28),
              SizedBox(width: 8),
              Text('200', style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6D4C41),
              )),
            ],
          ),
        ],
      ),
      // Right: Action icon
      Icon(Icons.arrow_forward_ios, 
        color: Color(0xFF6D4C41).withOpacity(0.5), 
        size: 20
      ),
    ],
  ),
)
```

**Alternative Design (Purple Theme):**
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Color(0xFF573ED1).withOpacity(0.2),
      width: 2,
    ),
    boxShadow: [
      BoxShadow(
        color: Color(0xFF573ED1).withOpacity(0.1),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  ),
  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  child: Row(
    children: [
      // Icon container
      Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFF573ED1).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.star, color: Color(0xFFFFA726), size: 24),
      ),
      SizedBox(width: 16),
      // Points info
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Poin Saya', style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            )),
            SizedBox(height: 2),
            Text('200 Poin', style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF573ED1),
            )),
          ],
        ),
      ),
      // Arrow
      Icon(Icons.chevron_right, 
        color: Colors.grey.shade400, 
        size: 24
      ),
    ],
  ),
)
```

### 2. Improved Profile Section

**Design Specifications:**
```dart
Row(
  children: [
    // Avatar with subtle shadow
    Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.white.withOpacity(0.3),
        child: Icon(Icons.person, color: Colors.white, size: 32),
      ),
    ),
    SizedBox(width: 16),
    // User info
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Diva Satria', style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          )),
          SizedBox(height: 4),
          Text('divasatria100@gmail.com', 
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  ],
)
```

### 3. Refined Header Layout

**Spacing and Hierarchy:**
```
Top Bar (Location + Notification)
↓ 20px
Greeting Text
↓ 16px
Profile Section
↓ 16px
Points Card (NEW)
↓ 20px
Search Bar
```

## Data Models

No new data models required. The component will use existing user data:

```dart
class UserProfile {
  final String name;
  final String email;
  final int points;
  final String? avatarUrl;
}
```

## Error Handling

### Points Display Errors

1. **Missing Points Data**
   - Display "0 Poin" as fallback
   - Show placeholder icon
   - Log error for debugging

2. **Large Point Values**
   - Format numbers with thousand separators (e.g., "1,234")
   - Truncate to "999+" for values > 999
   - Ensure text doesn't overflow container

3. **Network Errors**
   - Cache last known points value
   - Show cached value with indicator
   - Provide refresh action

## Testing Strategy

### Visual Regression Tests

1. **Layout Tests**
   - Verify spacing matches design specs
   - Check alignment on different screen sizes
   - Validate text doesn't truncate unexpectedly

2. **Interaction Tests**
   - Tap on points card navigates correctly
   - Ripple effect displays on touch
   - State changes are smooth

3. **Accessibility Tests**
   - Contrast ratios meet WCAG AA standards
   - Touch targets meet 48dp minimum
   - Screen reader labels are descriptive

### Performance Tests

1. **Render Performance**
   - Header renders within 300ms
   - Backdrop blur maintains 60fps
   - No layout shifts during load

2. **Memory Usage**
   - Gradient rendering is efficient
   - Shadow effects don't cause memory leaks
   - Images (if added) are properly cached

## Design Mockup (Text Description)

### Recommended Layout Option A: Horizontal Points Card

```
┌─────────────────────────────────────────┐
│  [📍 Lokasi saat ini]        [🔔]       │ ← Glassmorphic
│                                          │
│  Selamat Datang Kembali!                │ ← Greeting
│                                          │
│  [👤]  Diva Satria                      │ ← Profile
│        divasatria100@gmail.com          │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │ Poin Saya          [⭐ 200]    →   │ │ ← Points Card
│  └────────────────────────────────────┘ │
│                                          │
│  [🔍 Cari lokasi parkir...]             │ ← Search
└─────────────────────────────────────────┘
```

### Recommended Layout Option B: Vertical Points Card

```
┌─────────────────────────────────────────┐
│  [📍 Lokasi saat ini]        [🔔]       │
│                                          │
│  Selamat Datang Kembali!                │
│                                          │
│  [👤]  Diva Satria                      │
│        divasatria100@gmail.com          │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │  [⭐]  Poin Saya                   │ │
│  │        200 Poin              →     │ │
│  └────────────────────────────────────┘ │
│                                          │
│  [🔍 Cari lokasi parkir...]             │
└─────────────────────────────────────────┘
```

## Implementation Notes

1. **Gradient Background**: Keep existing gradient (#7C5ED1 → #573ED1)
2. **Points Card**: Use Option B (Vertical) for better visual balance
3. **Animation**: Add subtle fade-in for points card (200ms delay)
4. **Interaction**: Make points card tappable → navigate to points history
5. **Responsive**: Test on screens from 320px to 428px width

## Design Rationale

### Why Separate Points Card?

1. **Visual Hierarchy**: Creates clear focal point for rewards
2. **Scalability**: Easier to add features (progress bar, tier badge)
3. **Consistency**: Matches card-based design of Activity/Map pages
4. **Accessibility**: Larger touch target, better contrast
5. **Premium Feel**: Elevated design increases perceived value

### Why This Color Scheme?

1. **Gold Gradient**: Associates with rewards and value
2. **Purple Border**: Maintains brand consistency
3. **White Background**: Clean, modern, matches other pages
4. **High Contrast**: Ensures readability for all users

### Why This Spacing?

1. **16px between sections**: Provides breathing room
2. **20px padding in card**: Comfortable touch target
3. **8dp grid system**: Maintains consistency across app
4. **Vertical layout**: Reduces horizontal crowding
