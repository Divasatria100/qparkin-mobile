# Booking Page Design Consistency Fix

## Overview
Penyelarasan desain (design consistency) pada seluruh card di booking page untuk menciptakan tampilan yang seragam dan profesional.

## Problems Identified

### 1. Inkonsistensi Border Radius
- `MallInfoCard`: Menggunakan `ResponsiveHelper.getBorderRadius()` (bervariasi)
- `VehicleSelector`: 16px
- `FloorSelectorWidget`: 16px
- `SlotAvailabilityIndicator`: 16px
- `UnifiedTimeDurationCard`: 16px
- `BookingSummaryCard`: Menggunakan `ResponsiveHelper.getBorderRadius()` (bervariasi)
- `PointUsageWidget`: 16px

### 2. Inkonsistensi Elevation
- `MallInfoCard`: elevation 2
- `VehicleSelector`: elevation 2
- `FloorSelectorWidget`: elevation tidak ada (manual shadow)
- `SlotAvailabilityIndicator`: elevation 2
- `UnifiedTimeDurationCard`: elevation 3
- `BookingSummaryCard`: elevation 4
- `PointUsageWidget`: tidak ada elevation (manual shadow)

### 3. Inkonsistensi Padding
- `MallInfoCard`: Menggunakan `ResponsiveHelper.getCardPadding()`
- `VehicleSelector`: 16px
- `FloorSelectorWidget`: 12px (untuk floor card)
- `SlotAvailabilityIndicator`: 16px
- `UnifiedTimeDurationCard`: Responsive padding (16-24px)
- `BookingSummaryCard`: Menggunakan `ResponsiveHelper.getCardPadding()`
- `PointUsageWidget`: 16px

### 4. Inkonsistensi Icon Size
- `MallInfoCard`: Menggunakan `ResponsiveHelper.getIconSize()` (24px base)
- `VehicleSelector`: 20px, 32px (bervariasi)
- `FloorSelectorWidget`: 16px, 24px
- `SlotAvailabilityIndicator`: 20px, 24px
- `UnifiedTimeDurationCard`: 24px
- `BookingSummaryCard`: Menggunakan `ResponsiveHelper.getIconSize()` (20px base)
- `PointUsageWidget`: 20px, 24px

### 5. Inkonsistensi Font Sizes
- Heading: 16px, 18px, 20px (tidak konsisten)
- Body: 12px, 13px, 14px, 15px (terlalu banyak variasi)
- Caption: 10px, 11px, 12px (tidak konsisten)

### 6. Inkonsistensi Shadow
- Beberapa menggunakan `Colors.black.withOpacity(0.1)`
- Beberapa menggunakan `Colors.black.withOpacity(0.05)`
- `BookingSummaryCard` menggunakan `primaryColor.withOpacity(0.2)`
- Tidak konsisten

### 7. Inkonsistensi Spacing
- Spacing antar elemen bervariasi: 4px, 8px, 12px, 16px, 20px, 24px
- Tidak mengikuti spacing scale yang konsisten

## Solution: Design System

### Design Constants Created
File: `lib/config/design_constants.dart`

**Key Constants:**
- **Border Radius**: 16px (standard untuk semua card)
- **Elevation**: 2.0 (standard untuk semua card)
- **Padding**: 16px (standard untuk semua card)
- **Icon Sizes**: 16px (small), 20px (medium), 24px (large)
- **Font Sizes**: 
  - H3: 18px (card titles)
  - H4: 16px (section titles)
  - Body: 14px (standard text)
  - Caption: 12px (secondary text)
- **Shadow**: `Colors.black.withOpacity(0.08)` (konsisten)
- **Spacing Scale**: 4px, 8px, 12px, 16px, 24px, 32px

### Cards to Update

1. **MallInfoCard** ✓
   - Standardize border radius: 16px
   - Standardize elevation: 2.0
   - Standardize padding: 16px
   - Standardize icon size: 24px (large)
   - Standardize shadow color

2. **VehicleSelector** ✓
   - Already mostly consistent
   - Update shadow color
   - Standardize spacing

3. **FloorSelectorWidget** ✓
   - Add elevation: 2.0 (remove manual shadow)
   - Update padding: 16px for card, 12px for floor items
   - Standardize icon sizes
   - Update shadow color

4. **SlotAvailabilityIndicator** ✓
   - Already mostly consistent
   - Update shadow color
   - Standardize spacing

5. **UnifiedTimeDurationCard** ✓
   - Change elevation from 3 to 2
   - Standardize padding: 16px
   - Update shadow color
   - Standardize spacing

6. **BookingSummaryCard** ✓
   - Change elevation from 4 to 2
   - Standardize border radius: 16px
   - Standardize padding: 16px
   - Update shadow color (remove purple shadow)
   - Standardize spacing

7. **PointUsageWidget** ✓
   - Add elevation: 2.0
   - Update shadow color
   - Standardize spacing

## Implementation Plan

### Phase 1: Create Design System ✓
- [x] Create `design_constants.dart` with all design tokens

### Phase 2: Update All Cards
- [ ] Update `MallInfoCard`
- [ ] Update `VehicleSelector`
- [ ] Update `FloorSelectorWidget`
- [ ] Update `SlotAvailabilityIndicator`
- [ ] Update `UnifiedTimeDurationCard`
- [ ] Update `BookingSummaryCard`
- [ ] Update `PointUsageWidget`

### Phase 3: Testing
- [ ] Visual testing on different screen sizes
- [ ] Verify consistency across all cards
- [ ] Check accessibility (contrast, touch targets)

## Benefits

1. **Visual Consistency**: Semua card memiliki tampilan yang seragam
2. **Maintainability**: Mudah mengubah desain secara global
3. **Scalability**: Mudah menambah card baru dengan desain konsisten
4. **Professional Look**: Tampilan lebih polish dan profesional
5. **Better UX**: User experience lebih baik dengan visual hierarchy yang jelas

## Design Principles Applied

1. **Consistency**: Semua elemen mengikuti design system
2. **Hierarchy**: Font sizes dan weights mencerminkan importance
3. **Spacing**: Menggunakan spacing scale yang konsisten (8px base)
4. **Accessibility**: Minimum touch target 48px, contrast ratio memadai
5. **Material Design 3**: Mengikuti prinsip Material Design modern

## Notes

- Tidak ada perubahan pada logika bisnis atau fungsi
- Hanya perubahan visual untuk konsistensi
- Semua perubahan backward compatible
- Responsive behavior tetap dipertahankan
