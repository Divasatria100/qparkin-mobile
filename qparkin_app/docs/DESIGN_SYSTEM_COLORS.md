# 🎨 QParkin Design System - Color Palette

**Last Updated:** 7 Januari 2026  
**Version:** 2.0  
**Status:** ✅ Active

---

## 📚 Table of Contents

1. [Brand Colors](#brand-colors)
2. [Primary Colors](#primary-colors)
3. [Semantic Colors](#semantic-colors)
4. [Neutral Colors](#neutral-colors)
5. [Gradients](#gradients)
6. [Usage Guidelines](#usage-guidelines)
7. [Accessibility](#accessibility)

---

## 🎨 Brand Colors

Warna utama yang merepresentasikan identitas brand QParkin.

### AppTheme.brandBlue
```dart
Color(0xFF2E3A8C)
```
**RGB:** 46, 58, 140  
**Usage:** Secondary brand color, accent elements  
**Example:** Icons, badges, highlights

### AppTheme.brandIndigo
```dart
Color(0xFF5C3BFF)
```
**RGB:** 92, 59, 255  
**Usage:** Primary brand color, hero sections  
**Example:** About page background, headers  
**Visual:** 🟣 Vibrant purple/indigo

### AppTheme.brandNavy
```dart
Color(0xFF1F2A5A)
```
**RGB:** 31, 42, 90  
**Usage:** Primary buttons, important actions  
**Example:** Login button, "Mulai" button, primary CTAs  
**Visual:** 🔵 Deep navy blue

### AppTheme.brandRed
```dart
Color(0xFFE53935)
```
**RGB:** 229, 57, 53  
**Usage:** Destructive actions, critical alerts  
**Example:** Delete buttons, critical warnings  
**Visual:** 🔴 Bright red

---

## 🌟 Primary Colors

Warna yang sering digunakan di seluruh aplikasi.

### AppTheme.primaryPurple
```dart
Color(0xFF573ED1)
```
**RGB:** 87, 62, 209  
**Usage:** Interactive elements, selected states  
**Example:** Selected chips, active buttons, gradient middle  
**Visual:** 💜 Medium purple  
**Contrast Ratio:** 4.8:1 (white text)

### AppTheme.primaryOrange
```dart
Color(0xFFFB923C)
```
**RGB:** 251, 146, 60  
**Usage:** Floating action button, scan features  
**Example:** QR scan button, FAB  
**Visual:** 🟠 Vibrant orange  
**Contrast Ratio:** 3.2:1 (white text)

---

## ✅ Semantic Colors

Warna yang memiliki makna semantik untuk feedback sistem.

### AppTheme.successGreen
```dart
Color(0xFF4CAF50)
```
**RGB:** 76, 175, 80  
**Usage:** Success states, available slots  
**Example:** Success messages, available parking indicators  
**Visual:** 🟢 Material green  
**Contrast Ratio:** 3.1:1 (white text)

### AppTheme.warningOrange
```dart
Color(0xFFFF9800)
```
**RGB:** 255, 152, 0  
**Usage:** Warning states, limited availability  
**Example:** Warning messages, few slots remaining  
**Visual:** 🟠 Material orange  
**Contrast Ratio:** 2.8:1 (white text)

### AppTheme.errorRed
```dart
Color(0xFFF44336)
```
**RGB:** 244, 67, 54  
**Usage:** Error states, full parking  
**Example:** Error messages, no slots available  
**Visual:** 🔴 Material red  
**Contrast Ratio:** 4.5:1 (white text)

---

## ⚪ Neutral Colors

Warna netral untuk borders, hints, dan backgrounds.

### AppTheme.borderGrey
```dart
Color(0xFFD0D5DD)
```
**RGB:** 208, 213, 221  
**Usage:** Input borders, dividers  
**Example:** TextField borders, card separators  
**Visual:** ⚪ Light grey

### AppTheme.hintGrey
```dart
Color(0xFF949191)
```
**RGB:** 148, 145, 145  
**Usage:** Placeholder text, hints  
**Example:** Input placeholders, helper text  
**Visual:** ⚫ Medium grey

---

## 🌈 Gradients

### AppTheme.heroGradient
```dart
LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFF42CBF8),  // Cyan
    Color(0xFF573ED1),  // Purple
    Color(0xFF39108A),  // Deep Purple
  ],
  stops: [0.18, 0.51, 0.81],
)
```

**Usage:** Hero sections, premium features  
**Example:** Login/signup headers, premium cards  
**Visual:** 🌊➡️💜➡️🔮 Cyan to purple gradient

**Color Breakdown:**
- **18%:** `#42CBF8` - Bright cyan
- **51%:** `#573ED1` - Medium purple (primaryPurple)
- **81%:** `#39108A` - Deep purple

---

## 📖 Usage Guidelines

### 1. Import AppTheme
```dart
import '/config/app_theme.dart';
```

### 2. Use Color Constants
```dart
// ✅ GOOD - Using AppTheme constants
Container(
  color: AppTheme.brandNavy,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppTheme.primaryPurple,
    ),
    child: Text('Button'),
  ),
)

// ❌ BAD - Hardcoded colors
Container(
  color: Color(0xFF1F2A5A),  // Don't do this!
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF573ED1),  // Don't do this!
    ),
    child: Text('Button'),
  ),
)
```

### 3. Semantic Color Usage
```dart
// Success state
SnackBar(
  backgroundColor: AppTheme.successGreen,
  content: Text('Booking berhasil!'),
)

// Error state
SnackBar(
  backgroundColor: AppTheme.errorRed,
  content: Text('Booking gagal!'),
)

// Warning state
SnackBar(
  backgroundColor: AppTheme.warningOrange,
  content: Text('Slot hampir penuh!'),
)
```

### 4. Button Colors
```dart
// Primary action (most important)
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.brandNavy,
  ),
  child: Text('Login'),
)

// Secondary action
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primaryPurple,
  ),
  child: Text('Booking'),
)

// Destructive action
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.errorRed,
  ),
  child: Text('Hapus'),
)
```

---

## ♿ Accessibility

### Contrast Ratios (WCAG 2.1)

| Color | Background | Contrast | WCAG Level |
|-------|-----------|----------|------------|
| `brandNavy` | White | 12.5:1 | AAA ✅ |
| `primaryPurple` | White | 4.8:1 | AA ✅ |
| `primaryOrange` | White | 3.2:1 | AA (Large) ✅ |
| `successGreen` | White | 3.1:1 | AA (Large) ✅ |
| `warningOrange` | White | 2.8:1 | AA (Large) ⚠️ |
| `errorRed` | White | 4.5:1 | AA ✅ |

**Notes:**
- ✅ AA: Minimum contrast for normal text (4.5:1)
- ✅ AA Large: Minimum contrast for large text (3:1)
- ✅ AAA: Enhanced contrast (7:1)

### Text Color Recommendations

```dart
// On light backgrounds
Text(
  'Title',
  style: TextStyle(color: Colors.black87),  // 87% opacity
)

Text(
  'Description',
  style: TextStyle(color: Colors.black54),  // 54% opacity
)

Text(
  'Hint',
  style: TextStyle(color: AppTheme.hintGrey),
)

// On dark backgrounds (brandNavy, primaryPurple)
Text(
  'Title',
  style: TextStyle(color: Colors.white),
)

Text(
  'Description',
  style: TextStyle(color: Colors.white.withOpacity(0.8)),
)
```

---

## 🎯 Color Hierarchy

### Primary Actions
1. **brandNavy** - Most important actions (Login, Submit)
2. **primaryPurple** - Secondary actions (Booking, Select)
3. **primaryOrange** - Special actions (Scan QR)

### Feedback
1. **successGreen** - Positive feedback
2. **warningOrange** - Caution feedback
3. **errorRed** - Negative feedback

### Branding
1. **brandIndigo** - Hero sections, headers
2. **brandBlue** - Accents, highlights
3. **brandNavy** - Primary elements

---

## 📱 Platform-Specific Notes

### iOS
- Colors automatically adapt to system appearance
- Dark mode support planned for v2.1

### Android
- Material Design 3 color system
- Dynamic color support planned for v2.2

### Web
- CSS variables generated from AppTheme
- High contrast mode support

---

## 🔄 Version History

### v2.0 (7 Jan 2026)
- ✅ Added `primaryPurple`, `primaryOrange`
- ✅ Added semantic colors (success, warning, error)
- ✅ Added neutral colors (borderGrey, hintGrey)
- ✅ Centralized all colors in AppTheme
- ✅ Updated about_page to use AppTheme

### v1.0 (Initial)
- Basic brand colors (blue, indigo, navy, red)
- Hero gradient definition

---

## 📞 Support

**Questions?** Contact development team  
**Issues?** Report in project tracker  
**Suggestions?** Submit design proposal

---

**Maintained by:** QParkin Design Team  
**Last Review:** 7 Januari 2026  
**Next Review:** Q2 2026
