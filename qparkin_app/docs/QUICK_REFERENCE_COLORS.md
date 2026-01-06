# 🎨 Quick Reference - QParkin Colors

**For Developers:** Copy-paste ready color usage examples

---

## 🚀 Quick Start

```dart
import '/config/app_theme.dart';
```

---

## 📋 Common Use Cases

### 1. Primary Button
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.brandNavy,
    foregroundColor: Colors.white,
  ),
  child: Text('Login'),
)
```

### 2. Secondary Button
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primaryPurple,
    foregroundColor: Colors.white,
  ),
  child: Text('Booking'),
)
```

### 3. FAB / Scan Button
```dart
FloatingActionButton(
  backgroundColor: AppTheme.primaryOrange,
  child: Icon(Icons.qr_code_scanner),
  onPressed: () {},
)
```

### 4. Success Message
```dart
SnackBar(
  backgroundColor: AppTheme.successGreen,
  content: Text('Berhasil!'),
)
```

### 5. Error Message
```dart
SnackBar(
  backgroundColor: AppTheme.errorRed,
  content: Text('Gagal!'),
)
```

### 6. Warning Message
```dart
SnackBar(
  backgroundColor: AppTheme.warningOrange,
  content: Text('Perhatian!'),
)
```

### 7. Header Background
```dart
Container(
  decoration: BoxDecoration(
    color: AppTheme.brandIndigo,
    borderRadius: BorderRadius.vertical(
      bottom: Radius.circular(40),
    ),
  ),
)
```

### 8. Gradient Header
```dart
Container(
  decoration: BoxDecoration(
    gradient: AppTheme.heroGradient,
  ),
)
```

### 9. Input Border
```dart
TextField(
  decoration: InputDecoration(
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppTheme.borderGrey),
    ),
  ),
)
```

### 10. Hint Text
```dart
TextField(
  decoration: InputDecoration(
    hintText: 'Masukkan nama',
    hintStyle: TextStyle(color: AppTheme.hintGrey),
  ),
)
```

---

## 🎨 All Colors at a Glance

```dart
// Brand
AppTheme.brandBlue      // #2E3A8C
AppTheme.brandIndigo    // #5C3BFF
AppTheme.brandNavy      // #1F2A5A
AppTheme.brandRed       // #E53935

// Primary
AppTheme.primaryPurple  // #573ED1
AppTheme.primaryOrange  // #FB923C

// Semantic
AppTheme.successGreen   // #4CAF50
AppTheme.warningOrange  // #FF9800
AppTheme.errorRed       // #F44336

// Neutral
AppTheme.borderGrey     // #D0D5DD
AppTheme.hintGrey       // #949191

// Gradient
AppTheme.heroGradient   // Cyan → Purple → Deep Purple
```

---

## ✅ Do's and ❌ Don'ts

### ✅ DO
```dart
// Use AppTheme constants
backgroundColor: AppTheme.brandNavy

// Use semantic colors
backgroundColor: AppTheme.successGreen

// Use gradient for hero sections
decoration: BoxDecoration(gradient: AppTheme.heroGradient)
```

### ❌ DON'T
```dart
// Don't hardcode colors
backgroundColor: Color(0xFF1F2A5A)  // ❌

// Don't use random colors
backgroundColor: Colors.blue  // ❌

// Don't create custom gradients
gradient: LinearGradient(...)  // ❌ Use AppTheme.heroGradient
```

---

## 📱 Screen-Specific Colors

### About Page (Welcome)
- Background: `AppTheme.brandIndigo`
- Button: `AppTheme.brandNavy`
- Icon: `AppTheme.brandNavy`

### Login/Signup
- Header: `AppTheme.primaryPurple`
- Button: `AppTheme.brandNavy`
- Links: `AppTheme.primaryPurple`

### Home Page
- Gradient: `AppTheme.heroGradient`
- Cards: `Colors.white`
- Accents: `AppTheme.primaryPurple`

### Booking Page
- Primary Button: `AppTheme.primaryPurple`
- Available Slot: `AppTheme.successGreen`
- Full Slot: `AppTheme.errorRed`

### Profile Page
- Edit Button: `AppTheme.primaryPurple`
- Logout: `AppTheme.errorRed`

---

## 🔍 Find & Replace Guide

If you need to update hardcoded colors:

```bash
# Find all hardcoded purple
grep -r "Color(0xFF573ED1)" qparkin_app/lib/

# Replace with AppTheme.primaryPurple
# (Do this manually to ensure correctness)
```

**Common replacements:**
- `Color(0xFF573ED1)` → `AppTheme.primaryPurple`
- `Color(0xFFFB923C)` → `AppTheme.primaryOrange`
- `Color(0xFF4CAF50)` → `AppTheme.successGreen`
- `Color(0xFFFF9800)` → `AppTheme.warningOrange`
- `Color(0xFFF44336)` → `AppTheme.errorRed`
- `Color(0xFF1F2A5A)` → `AppTheme.brandNavy`
- `Color(0xFF5C3BFF)` → `AppTheme.brandIndigo`

---

**Last Updated:** 7 Januari 2026  
**Version:** 2.0
