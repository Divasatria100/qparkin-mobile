# ✅ Color Migration Checklist

**Tujuan:** Migrasi semua warna hardcoded ke `AppTheme` constants  
**Status:** 🟡 In Progress  
**Priority:** Medium  
**Estimated Time:** 2-3 hours

---

## 📊 Progress Overview

- ✅ **Completed:** 3 files (about_page, app_theme, bottom_nav)
- 🟡 **In Progress:** 0 files
- ⏳ **Pending:** ~50 files
- **Total:** ~53 files

**Completion:** 5.7% (3/53)

---

## ✅ Completed Files

### 1. ✅ qparkin_app/lib/config/app_theme.dart
- [x] Added `primaryPurple`
- [x] Added `primaryOrange`
- [x] Added semantic colors (success, warning, error)
- [x] Added neutral colors (borderGrey, hintGrey)

### 2. ✅ qparkin_app/lib/presentation/screens/about_page.dart
- [x] Import AppTheme
- [x] Replace `Color(0xFF1E3A8A)` → `AppTheme.brandIndigo`
- [x] Replace `Color(0xFFEF4444)` → `AppTheme.brandNavy`
- [x] Replace `Color(0xFF4F46E5)` → `AppTheme.brandNavy`
- [x] Update text colors to standard opacity

### 3. ✅ qparkin_app/lib/presentation/widgets/bottom_nav.dart
- [x] Import AppTheme
- [x] Replace `Color(0xFFFB923C)` → `AppTheme.primaryOrange`

---

## 🟡 High Priority Files

Files yang sering digunakan dan perlu segera diupdate.

### Widgets (Priority 1)

#### ⏳ qparkin_app/lib/presentation/widgets/vehicle_selector.dart
- [ ] Line 82: `Color(0xFF573ED1)` → `AppTheme.primaryPurple`

#### ⏳ qparkin_app/lib/presentation/widgets/unified_time_duration_card.dart
- [ ] Line 846: `Color(0xFF573ED1)` → `AppTheme.primaryPurple`
- [ ] Line 872: `Color(0xFFF44336)` → `AppTheme.errorRed`

#### ⏳ qparkin_app/lib/presentation/widgets/time_duration_picker.dart
- [ ] Line 206: `Color(0xFF573ED1)` → `AppTheme.primaryPurple`

#### ⏳ qparkin_app/lib/presentation/widgets/slot_visualization_widget.dart
- [ ] Line 403: `Color(0xFF573ED1)` → `AppTheme.primaryPurple`

#### ⏳ qparkin_app/lib/presentation/widgets/qr_exit_button.dart
- [ ] Line 76: `Color(0xFF573ED1)` → `AppTheme.primaryPurple`

#### ⏳ qparkin_app/lib/presentation/widgets/point_info_bottom_sheet.dart
- [ ] Line 178: `Color(0xFF573ED1)` → `AppTheme.primaryPurple`

#### ⏳ qparkin_app/lib/presentation/widgets/point_balance_card.dart
- [ ] Line 314: `Color(0xFF573ED1)` → `AppTheme.primaryPurple`

#### ⏳ qparkin_app/lib/presentation/widgets/map_view.dart
- [ ] Line 764: `Color(0xFF573ED1)` → `AppTheme.primaryPurple`

#### ⏳ qparkin_app/lib/presentation/widgets/map_controls.dart
- [ ] Line 137: `Color(0xFF573ED1)` → `AppTheme.primaryPurple`

#### ⏳ qparkin_app/lib/presentation/widgets/floor_selector_widget.dart
- [ ] Line 157: `Color(0xFF573ED1)` → `AppTheme.primaryPurple`

#### ⏳ qparkin_app/lib/presentation/widgets/filter_bottom_sheet.dart
- [ ] Line 236: `Color(0xFF573ED1)` → `AppTheme.primaryPurple`

#### ⏳ qparkin_app/lib/presentation/widgets/error_retry_widget.dart
- [ ] Line 107: `Color(0xFFF44336)` → `AppTheme.errorRed`
- [ ] Line 156: `Color(0xFFF44336)` → `AppTheme.errorRed`
- [ ] Line 185: `Color(0xFFFF9800)` → `AppTheme.warningOrange`

#### ⏳ qparkin_app/lib/presentation/widgets/booking_conflict_dialog.dart
- [ ] Line 93: `Color(0xFF573ED1)` → `AppTheme.primaryPurple`

---

### Screens (Priority 2)

#### ⏳ qparkin_app/lib/presentation/screens/login_screen.dart
- [ ] Line 35: `const labelBlue = Color(0xFF1E3A8A)` → Use `AppTheme.brandNavy`
- [ ] Line 696: `Color(0xFF1E3A8A)` → `AppTheme.brandNavy`
- [ ] Line 900: `Color(0xFF1E3A8A)` → `AppTheme.brandNavy`
- [ ] Line 940: `Color(0xFF1E3A8A)` → `AppTheme.brandNavy`
- [ ] Line 1051: `Color(0xFF1E3A8A)` → `AppTheme.brandNavy`
- [ ] Line 1093: `const labelBlue = Color(0xFF1E3A8A)` → Use `AppTheme.brandNavy`
- [ ] Line 1296: `Color(0xFF1E3A8A)` → `AppTheme.brandNavy`

#### ⏳ qparkin_app/lib/presentation/screens/signup_screen.dart
- [ ] Line 41: `const labelBlue = Color(0xFF1E3A8A)` → Use `AppTheme.brandNavy`
- [ ] Line 73: `Color(0xFF1E3A8A)` → `AppTheme.brandNavy`
- [ ] Line 113: `Color(0xFF1E3A8A)` → `AppTheme.brandNavy`

---

## 📝 Migration Steps

### For Each File:

1. **Add Import**
   ```dart
   import '/config/app_theme.dart';
   ```

2. **Find & Replace Colors**
   - Search for `Color(0xFF...)`
   - Replace with appropriate `AppTheme.*` constant
   - Verify the color matches

3. **Remove Local Constants** (if any)
   ```dart
   // Remove these
   static const primaryPurple = Color(0xFF573ED1);
   static const labelBlue = Color(0xFF1E3A8A);
   ```

4. **Test the File**
   ```bash
   flutter analyze path/to/file.dart
   ```

5. **Visual Check**
   - Run the app
   - Navigate to the screen/widget
   - Verify colors look correct

---

## 🔍 Search Commands

### Find all hardcoded colors:
```bash
# Purple
grep -rn "Color(0xFF573ED1)" qparkin_app/lib/

# Orange
grep -rn "Color(0xFFFB923C)" qparkin_app/lib/

# Navy/Blue
grep -rn "Color(0xFF1E3A8A)" qparkin_app/lib/

# Success Green
grep -rn "Color(0xFF4CAF50)" qparkin_app/lib/

# Warning Orange
grep -rn "Color(0xFFFF9800)" qparkin_app/lib/

# Error Red
grep -rn "Color(0xFFF44336)" qparkin_app/lib/

# All colors
grep -rn "Color(0xFF" qparkin_app/lib/ | wc -l
```

---

## 🎯 Color Mapping Reference

| Hardcoded Color | AppTheme Constant | Usage |
|----------------|-------------------|-------|
| `Color(0xFF573ED1)` | `AppTheme.primaryPurple` | Buttons, selected states |
| `Color(0xFFFB923C)` | `AppTheme.primaryOrange` | FAB, scan button |
| `Color(0xFF1E3A8A)` | `AppTheme.brandNavy` | Primary buttons |
| `Color(0xFF5C3BFF)` | `AppTheme.brandIndigo` | Headers, hero sections |
| `Color(0xFF4CAF50)` | `AppTheme.successGreen` | Success messages |
| `Color(0xFFFF9800)` | `AppTheme.warningOrange` | Warning messages |
| `Color(0xFFF44336)` | `AppTheme.errorRed` | Error messages |
| `Color(0xFFD0D5DD)` | `AppTheme.borderGrey` | Borders, dividers |
| `Color(0xFF949191)` | `AppTheme.hintGrey` | Hints, placeholders |

---

## ⚠️ Special Cases

### 1. Premium Points Card
File: `qparkin_app/lib/presentation/widgets/premium_points_card.dart`

Has custom gold gradient - **DO NOT CHANGE**:
```dart
colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)]  // Keep as is
```

But update these:
- Line 165: `Color(0xFFFFA726)` → Keep (gold accent)
- Line 176: `Color(0xFF573ED1)` → `AppTheme.primaryPurple`
- Line 181: `Color(0xFF573ED1)` → `AppTheme.primaryPurple`
- Line 196: `Color(0xFF573ED1)` → `AppTheme.primaryPurple`
- Line 221: `Color(0xFF573ED1)` → `AppTheme.primaryPurple`

### 2. Vehicle Icon Helper
File: `qparkin_app/lib/utils/vehicle_icon_helper.dart`

Has vehicle-specific colors - **REVIEW BEFORE CHANGING**:
- `Color(0xFF009688)` - Teal for Roda Dua
- `Color(0xFFFF9800)` - Orange for Roda Tiga
- `Color(0xFF1872B3)` - Blue for Roda Empat
- `Color(0xFF757575)` - Grey for others

**Decision:** Keep as is or create vehicle color constants?

---

## 🧪 Testing Checklist

After migration, test these scenarios:

### Visual Testing
- [ ] About page displays correctly
- [ ] Login/signup colors match
- [ ] Home page gradient works
- [ ] Booking page colors correct
- [ ] Profile page colors correct
- [ ] All buttons have correct colors
- [ ] Success/warning/error messages correct
- [ ] FAB color is orange
- [ ] Bottom nav colors correct

### Functional Testing
- [ ] No runtime errors
- [ ] No color-related crashes
- [ ] Theme switching works (if implemented)
- [ ] Dark mode ready (if implemented)

### Code Quality
- [ ] No hardcoded colors remain
- [ ] All files import AppTheme
- [ ] Flutter analyze passes
- [ ] No warnings about colors

---

## 📈 Benefits After Migration

1. **Consistency** - All colors from one source
2. **Maintainability** - Easy to update colors
3. **Scalability** - Easy to add new colors
4. **Theme Support** - Ready for dark mode
5. **Documentation** - Clear color usage
6. **Accessibility** - Easier to ensure contrast ratios

---

## 🚀 Next Steps

1. **Phase 1:** Migrate high-priority widgets (11 files)
2. **Phase 2:** Migrate screens (3 files)
3. **Phase 3:** Migrate remaining widgets
4. **Phase 4:** Final testing and documentation
5. **Phase 5:** Code review and merge

**Estimated Timeline:** 1 week

---

## 📞 Questions?

- **Color not in AppTheme?** Add it to `app_theme.dart`
- **Custom color needed?** Discuss with design team
- **Breaking change?** Document in changelog

---

**Created:** 7 Januari 2026  
**Last Updated:** 7 Januari 2026  
**Status:** 🟡 In Progress (5.7%)
