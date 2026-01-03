# Point System Testing Guide - Phase 1

## Quick Start

```bash
cd qparkin_app
flutter run
```

## Test Scenarios

### 1. Basic Navigation
- [ ] Open app → Navigate to Profile page
- [ ] Tap on PremiumPointsCard (purple card with points)
- [ ] Verify PointPage opens successfully
- [ ] Verify back button returns to Profile

### 2. Point Balance Display
- [ ] Check balance card shows mock balance
- [ ] Verify shimmer loading appears briefly (800ms)
- [ ] Verify balance displays correctly after loading
- [ ] Check "Poin Saya" title in balance card

### 3. Point History List
- [ ] Verify history list displays sample transactions
- [ ] Check each item shows:
  - [ ] Icon (+ for earned, - for used)
  - [ ] Amount with "+" or "-" prefix
  - [ ] Description text
  - [ ] Date/time
- [ ] Verify list is scrollable
- [ ] Check infinite scroll loads more items

### 4. Pull-to-Refresh
- [ ] Pull down on the page
- [ ] Verify refresh indicator appears
- [ ] Verify success snackbar shows "Data berhasil diperbarui"
- [ ] Check data reloads

### 5. Filter Functionality
- [ ] Tap filter icon in app bar
- [ ] Verify filter bottom sheet opens
- [ ] Test Type filter:
  - [ ] Select "Semua" (All)
  - [ ] Select "Poin Masuk" (Earned)
  - [ ] Select "Poin Keluar" (Used)
- [ ] Test Date Range filter:
  - [ ] Tap date range field
  - [ ] Select start and end dates
  - [ ] Verify dates display correctly
  - [ ] Tap clear button to reset
- [ ] Test Amount Range filter:
  - [ ] Enter minimum amount
  - [ ] Enter maximum amount
  - [ ] Verify validation
- [ ] Tap "Terapkan" button
- [ ] Verify filtered results display
- [ ] Check "Filter Aktif" badge appears
- [ ] Tap "Reset" to clear filters

### 6. Info Bottom Sheet
- [ ] Tap info icon in app bar
- [ ] Verify info bottom sheet opens
- [ ] Check all sections display:
  - [ ] "Apa itu Poin QParkin?"
  - [ ] "Cara Mendapatkan Poin"
  - [ ] "Cara Menggunakan Poin"
  - [ ] "Masa Berlaku"
  - [ ] "Syarat & Ketentuan"
- [ ] Verify emojis display correctly
- [ ] Tap "Mengerti" button to close

### 7. Empty State (Optional)
To test empty state, you need to modify the code temporarily:
- Comment out the test data loading in `point_page.dart`
- Verify empty state displays with:
  - [ ] Star icon
  - [ ] "Belum Ada Riwayat Poin" title
  - [ ] Helpful description
  - [ ] 3 info cards explaining how to earn points

### 8. Notification Badge
- [ ] Check if badge appears on PremiumPointsCard (may not work yet)
- [ ] Open PointPage
- [ ] Return to Profile
- [ ] Verify badge disappears

### 9. Responsive Design
Test on different screen sizes:
- [ ] Small phone (320dp width)
- [ ] Medium phone (375dp width)
- [ ] Large phone (414dp width)
- [ ] Tablet (768dp+ width)

Verify:
- [ ] Padding adjusts appropriately
- [ ] Font sizes scale correctly
- [ ] Touch targets are adequate (48x48dp minimum)

### 10. Accessibility
- [ ] Enable TalkBack/VoiceOver
- [ ] Navigate through the page
- [ ] Verify all elements are announced
- [ ] Check semantic labels are meaningful

## Expected Behavior

### Mock Data
- **Balance**: Calculated from sample history (~425 points)
- **History**: 15 sample transactions
- **Network Delay**: 800ms simulated delay
- **Pagination**: 20 items per page

### UI Elements
- **Brand Color**: Purple `#573ED1`
- **Loading**: Shimmer effect
- **Animations**: Smooth transitions
- **Feedback**: Snackbars for actions

## Known Limitations (Phase 1)

- ✅ Mock data only (no real API)
- ✅ Notification badge may not work fully
- ✅ Point usage not implemented
- ✅ Statistics not displayed yet
- ✅ No real-time updates

These will be addressed in Phase 2 with real API integration.

## Troubleshooting

### Issue: App doesn't compile
**Solution**: Run `flutter pub get` and `flutter clean`

### Issue: Point page shows error
**Solution**: Check that PointProvider is in MultiProvider in main.dart

### Issue: No data displays
**Solution**: Check console logs for errors, verify mock data is loading

### Issue: Filter doesn't work
**Solution**: Verify PointFilter model is correctly imported

### Issue: Navigation fails
**Solution**: Check route is registered in main.dart routes

## Reporting Issues

When reporting bugs, include:
1. Device/emulator details
2. Steps to reproduce
3. Expected vs actual behavior
4. Screenshots if applicable
5. Console logs

## Next Steps After Testing

1. Document all bugs found
2. Prioritize critical issues
3. Fix bugs in Day 4
4. Polish UI/UX in Day 5
5. Prepare for Phase 2 (real API integration)

---

**Happy Testing! 🧪**
