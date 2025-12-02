# Accessibility Testing Execution Guide
## Profile Page Enhancement - Step-by-Step Manual Testing

**Date:** December 3, 2025  
**Feature:** Profile Page Enhancement  
**Tester:** [Your Name]  
**App Version:** [Version Number]

---

## 📋 Pre-Testing Checklist

Before starting accessibility testing, ensure you have:

- [ ] Flutter app built and installed on test devices
- [ ] Android device (physical or emulator) with TalkBack available
- [ ] iOS device (physical or simulator) with VoiceOver available
- [ ] Test account with sample data (user profile, vehicles)
- [ ] Network connectivity for testing API calls
- [ ] This testing guide printed or on a separate device
- [ ] Screen recording capability for documenting issues
- [ ] Notepad for recording observations

---

## 🤖 PART 1: TalkBack Testing (Android)

### Setup Instructions

1. **Enable TalkBack:**
   ```
   Settings → Accessibility → TalkBack → Toggle ON
   ```
   - Complete the tutorial if this is your first time
   - Practice basic gestures before starting tests

2. **TalkBack Quick Reference:**
   - **Swipe Right:** Next element
   - **Swipe Left:** Previous element
   - **Double Tap:** Activate element
   - **Two-finger Swipe Down:** Read from top
   - **Two-finger Swipe Up:** Read from current position
   - **Swipe Down then Right:** Global context menu

### Test Execution

#### Test 1: Profile Page Navigation
**Objective:** Verify bottom navigation announces profile tab correctly

**Steps:**
1. Open the app and navigate to Home page
2. Swipe right through bottom navigation items
3. Double-tap on Profile tab

**Expected Results:**
- [ ] TalkBack announces "Profile, tab 5 of 5" or similar
- [ ] Profile tab is clearly indicated as selected
- [ ] Navigation completes successfully

**Actual Results:**
```
[Record what you observe]
```

**Status:** ⬜ PASS  ⬜ FAIL  
**Issues:** [If failed, describe the issue]

---

#### Test 2: User Information Section
**Objective:** Verify user profile information is announced clearly

**Steps:**
1. On Profile page, swipe right from the top
2. Navigate through user name, email, and profile photo
3. Listen to each announcement

**Expected Results:**
- [ ] User name is announced: "Nama pengguna: [Name]"
- [ ] Email is announced: "Email: [email@example.com]"
- [ ] Profile photo has label: "Foto profil [Name]"
- [ ] All information is clear and understandable

**Actual Results:**
```
[Record what you observe]
```

**Status:** ⬜ PASS  ⬜ FAIL  
**Issues:** [If failed, describe the issue]

---

#### Test 3: Points Card Interaction
**Objective:** Verify points card is accessible and actionable

**Steps:**
1. Navigate to the PremiumPointsCard
2. Listen to the announcement
3. Double-tap to activate

**Expected Results:**
- [ ] Announces: "Kartu poin, saldo poin Anda: [X] poin"
- [ ] Announces hint: "Ketuk untuk melihat riwayat poin"
- [ ] Recognized as a button
- [ ] Navigation to points history works

**Actual Results:**
```
[Record what you observe]
```

**Status:** ⬜ PASS  ⬜ FAIL  
**Issues:** [If failed, describe the issue]

---

#### Test 4: Vehicle Cards
**Objective:** Verify vehicle list is accessible and interactive

**Steps:**
1. Navigate to "Informasi Kendaraan" section
2. Swipe through each vehicle card
3. Try swipe-to-delete gesture on a vehicle
4. Confirm deletion dialog

**Expected Results:**
- [ ] Section header announced: "Informasi Kendaraan"
- [ ] Each vehicle announces: name, type, plate number
- [ ] Active vehicle announces "Aktif" status
- [ ] Swipe action is discoverable: "Geser ke kiri untuk menghapus"
- [ ] Confirmation dialog is accessible
- [ ] Delete and Cancel buttons are clearly labeled

**Actual Results:**
```
[Record what you observe]
```

**Status:** ⬜ PASS  ⬜ FAIL  
**Issues:** [If failed, describe the issue]

---

#### Test 5: Empty Vehicle State
**Objective:** Verify empty state is accessible

**Steps:**
1. Delete all vehicles (or use test account with no vehicles)
2. Navigate to vehicle section
3. Listen to empty state announcement

**Expected Results:**
- [ ] Empty state message is announced
- [ ] "Tambah Kendaraan" button is clearly labeled
- [ ] Button hint describes action
- [ ] Icon has appropriate semantic label

**Actual Results:**
```
[Record what you observe]
```

**Status:** ⬜ PASS  ⬜ FAIL  
**Issues:** [If failed, describe the issue]

---

#### Test 6: Error State Recovery
**Objective:** Verify error states are accessible

**Steps:**
1. Disconnect network/enable airplane mode
2. Pull to refresh or restart app
3. Navigate through error state
4. Tap retry button

**Expected Results:**
- [ ] Error message is announced clearly
- [ ] Retry button is labeled: "Coba Lagi, button"
- [ ] Error icon has semantic label
- [ ] Retry action is accessible

**Actual Results:**
```
[Record what you observe]
```

**Status:** ⬜ PASS  ⬜ FAIL  
**Issues:** [If failed, describe the issue]

---

#### Test 7: Loading State
**Objective:** Verify loading state is communicated

**Steps:**
1. Clear app data or logout
2. Login and navigate to profile
3. Listen for loading announcements

**Expected Results:**
- [ ] Loading state is announced: "Memuat data profil"
- [ ] Shimmer placeholders have appropriate labels
- [ ] User knows data is being loaded
- [ ] Success announcement when loaded: "Data profil berhasil dimuat"

**Actual Results:**
```
[Record what you observe]
```

**Status:** ⬜ PASS  ⬜ FAIL  
**Issues:** [If failed, describe the issue]

---

#### Test 8: Menu Items
**Objective:** Verify all menu items are accessible

**Steps:**
1. Navigate to "Akun" section
2. Swipe through each menu item
3. Navigate to "Lainnya" section
4. Swipe through each menu item

**Expected Results:**
- [ ] "Akun" section header is announced
- [ ] "Ubah informasi akun" is clearly labeled with subtitle
- [ ] "List Kendaraan" is clearly labeled
- [ ] "Lainnya" section header is announced
- [ ] "Bantuan", "Kebijakan Privasi", "Tentang Aplikasi" are labeled
- [ ] "Keluar" button is clearly labeled with warning context

**Actual Results:**
```
[Record what you observe]
```

**Status:** ⬜ PASS  ⬜ FAIL  
**Issues:** [If failed, describe the issue]

---

#### Test 9: Logout Flow
**Objective:** Verify logout is accessible and safe

**Steps:**
1. Navigate to "Keluar" menu item
2. Double-tap to activate
3. Navigate through confirmation dialog
4. Test both Cancel and Logout buttons

**Expected Results:**
- [ ] Logout button has warning context
- [ ] Dialog title is announced: "Dialog konfirmasi keluar"
- [ ] Dialog message is announced clearly
- [ ] "Batal" button: "Tombol batal, Ketuk untuk membatalkan keluar"
- [ ] "Keluar" button: "Tombol keluar, Ketuk untuk keluar dari akun"
- [ ] Logout success is announced: "Berhasil keluar dari akun"

**Actual Results:**
```
[Record what you observe]
```

**Status:** ⬜ PASS  ⬜ FAIL  
**Issues:** [If failed, describe the issue]

---

#### Test 10: Pull-to-Refresh
**Objective:** Verify refresh gesture is accessible

**Steps:**
1. On profile page, perform pull-to-refresh gesture
2. Listen for announcements during refresh
3. Wait for completion

**Expected Results:**
- [ ] Refresh start announced: "Memperbarui data profil"
- [ ] Loading indicator is present
- [ ] Success announced: "Data profil berhasil diperbarui"
- [ ] Or error announced if failed: "Gagal memperbarui data profil"

**Actual Results:**
```
[Record what you observe]
```

**Status:** ⬜ PASS  ⬜ FAIL  
**Issues:** [If failed, describe the issue]

---

#### Test 11: Notification Badge
**Objective:** Verify notification icon is accessible

**Steps:**
1. Ensure there are unread notifications
2. Navigate to notification icon in header
3. Listen to announcement
4. Double-tap to open notifications

**Expected Results:**
- [ ] Announces: "Notifikasi, [X] notifikasi belum dibaca"
- [ ] Hint: "Ketuk untuk membuka halaman notifikasi"
- [ ] Navigation works correctly
- [ ] If no notifications: "Notifikasi, tidak ada notifikasi baru"

**Actual Results:**
```
[Record what you observe]
```

**Status:** ⬜ PASS  ⬜ FAIL  
**Issues:** [If failed, describe the issue]

---

### Android TalkBack Summary

**Total Tests:** 11  
**Passed:** ___  
**Failed:** ___  
**Pass Rate:** ___%

**Critical Issues Found:** ___  
**Notes:**
```
[Add any additional observations or patterns noticed]
```

---

## 🍎 PART 2: VoiceOver Testing (iOS)

### Setup Instructions

1. **Enable VoiceOver:**
   ```
   Settings → Accessibility → VoiceOver → Toggle ON
   ```
   - Complete the tutorial if this is your first time
   - Practice basic gestures before starting tests

2. **VoiceOver Quick Reference:**
   - **Swipe Right:** Next element
   - **Swipe Left:** Previous element
   - **Double Tap:** Activate element
   - **Two-finger Swipe Down:** Read all from top
   - **Three-finger Swipe:** Scroll
   - **Rotor:** Rotate two fingers to change navigation mode

### Test Execution

#### Test 12: Profile Page Navigation (iOS)
**Objective:** Verify navigation works with VoiceOver

**Steps:**
1. Navigate to Profile page using bottom navigation
2. Listen to VoiceOver announcements

**Expected Results:**
- [ ] VoiceOver announces "Profile, tab, 5 of 5"
- [ ] Current tab is clearly indicated
- [ ] Navigation is smooth

**Actual Results:**
```
[Record what you observe]
```

**Status:** ⬜ PASS  ⬜ FAIL  
**Issues:** [If failed, describe the issue]

---

#### Test 13: User Information (iOS)
**Objective:** Verify user info is accessible on iOS

**Steps:**
1. Swipe through user information section
2. Listen to each element

**Expected Results:**
- [ ] All text elements are announced clearly
- [ ] Profile photo has semantic label
- [ ] Information is grouped logically
- [ ] Email and name are distinguishable

**Actual Results:**
```
[Record what you observe]
```

**Status:** ⬜ PASS  ⬜ FAIL  
**Issues:** [If failed, describe the issue]

---

#### Test 14: Vehicle Cards (iOS)
**Objective:** Verify vehicle management on iOS

**Steps:**
1. Navigate through vehicle list
2. Test swipe-to-delete
3. Test vehicle card tap

**Expected Results:**
- [ ] Vehicle information is announced completely
- [ ] Active status is announced
- [ ] Swipe actions are available
- [ ] Tap navigation works

**Actual Results:**
```
[Record what you observe]
```

**Status:** ⬜ PASS  ⬜ FAIL  
**Issues:** [If failed, describe the issue]

---

#### Test 15: Interactive Elements (iOS)
**Objective:** Verify all buttons work with VoiceOver

**Steps:**
1. Navigate through all buttons on page
2. Test each button activation
3. Verify button traits

**Expected Results:**
- [ ] All buttons are focusable
- [ ] All have clear labels and hints
- [ ] Button trait is properly set
- [ ] Activation works correctly

**Actual Results:**
```
[Record what you observe]
```

**Status:** ⬜ PASS  ⬜ FAIL  
**Issues:** [If failed, describe the issue]

---

#### Test 16: State Changes (iOS)
**Objective:** Verify state changes are announced

**Steps:**
1. Trigger loading state
2. Trigger error state
3. Trigger success state
4. Listen for announcements

**Expected Results:**
- [ ] Loading announced
- [ ] Error announced with message
- [ ] Success announced
- [ ] Focus management is appropriate

**Actual Results:**
```
[Record what you observe]
```

**Status:** ⬜ PASS  ⬜ FAIL  
**Issues:** [If failed, describe the issue]

---

### iOS VoiceOver Summary

**Total Tests:** 5  
**Passed:** ___  
**Failed:** ___  
**Pass Rate:** ___%

**Critical Issues Found:** ___  
**Notes:**
```
[Add any additional observations]
```

---

## 📏 PART 3: Large Text Settings Testing

### Setup Instructions

**Android:**
```
Settings → Display → Font size → Largest
Settings → Display → Display size → Largest (optional)
```

**iOS:**
```
Settings → Accessibility → Display & Text Size → Larger Text
Move slider to maximum
```

### Test Execution

#### Test 17: Overall Text Scaling
**Objective:** Verify all text scales properly

**Steps:**
1. Set text size to maximum
2. Navigate through entire profile page
3. Check all text elements

**Expected Results:**
- [ ] All text scales appropriately
- [ ] No text is cut off or truncated
- [ ] No overlapping text elements
- [ ] Layout adjusts to accommodate larger text
- [ ] Buttons expand to fit text

**Actual Results:**
```
[Record what you observe]
```

**Status:** ⬜ PASS  ⬜ FAIL  
**Issues:** [If failed, describe the issue]

---

#### Test 18: Vehicle Cards with Large Text
**Objective:** Verify vehicle cards handle large text

**Steps:**
1. View vehicle cards with maximum text size
2. Check all text fields

**Expected Results:**
- [ ] Vehicle name is fully visible
- [ ] Type and plate number are readable
- [ ] "Aktif" badge is visible
- [ ] Cards expand vertically if needed
- [ ] No information is hidden

**Actual Results:**
```
[Record what you observe]
```

**Status:** ⬜ PASS  ⬜ FAIL  
**Issues:** [If failed, describe the issue]

---

#### Test 19: Menu Items with Large Text
**Objective:** Verify menu items handle large text

**Steps:**
1. View all menu sections with maximum text size
2. Check titles and subtitles

**Expected Results:**
- [ ] All menu items are readable
- [ ] Icons and text don't overlap
- [ ] Spacing is maintained
- [ ] Subtitles are visible
- [ ] No text overflow

**Actual Results:**
```
[Record what you observe]
```

**Status:** ⬜ PASS  ⬜ FAIL  
**Issues:** [If failed, describe the issue]

---

#### Test 20: Dialogs with Large Text
**Objective:** Verify dialogs handle large text

**Steps:**
1. Open confirmation dialogs (delete, logout)
2. Check all text in dialogs

**Expected Results:**
- [ ] Dialog title is fully visible
- [ ] Dialog content is readable
- [ ] Buttons are accessible
- [ ] No content is cut off
- [ ] Dialog expands if needed

**Actual Results:**
```
[Record what you observe]
```

**Status:** ⬜ PASS  ⬜ FAIL  
**Issues:** [If failed, describe the issue]

---

### Large Text Summary

**Total Tests:** 4  
**Passed:** ___  
**Failed:** ___  
**Pass Rate:** ___%

**Critical Issues Found:** ___  
**Notes:**
```
[Add any additional observations]
```

---

## 🔍 PART 4: Display Zoom Testing

### Setup Instructions

**Android:**
```
Settings → Display → Display size → Largest
```

**iOS:**
```
Settings → Display & Brightness → View → Zoomed
(If available on device)
```

### Test Execution

#### Test 21: Overall Layout with Zoom
**Objective:** Verify layout adapts to display zoom

**Steps:**
1. Enable maximum display zoom
2. Navigate through entire profile page
3. Check all sections

**Expected Results:**
- [ ] All elements are visible
- [ ] No horizontal scrolling required
- [ ] Layout adapts to larger display scale
- [ ] Content is reachable
- [ ] No elements are cut off

**Actual Results:**
```
[Record what you observe]
```

**Status:** ⬜ PASS  ⬜ FAIL  
**Issues:** [If failed, describe the issue]

---

#### Test 22: Touch Targets with Zoom
**Objective:** Verify touch targets are accessible

**Steps:**
1. Try tapping all interactive elements
2. Check for accidental taps
3. Verify minimum 48dp size

**Expected Results:**
- [ ] All buttons are easy to tap
- [ ] No accidental taps on adjacent elements
- [ ] Touch targets meet 48dp minimum
- [ ] Spacing between elements is adequate
- [ ] No overlap between interactive elements

**Actual Results:**
```
[Record what you observe]
```

**Status:** ⬜ PASS  ⬜ FAIL  
**Issues:** [If failed, describe the issue]

---

#### Test 23: Navigation with Zoom
**Objective:** Verify bottom navigation with zoom

**Steps:**
1. Test bottom navigation bar
2. Try tapping each tab

**Expected Results:**
- [ ] All navigation items are accessible
- [ ] Icons and labels are clear
- [ ] No overlap between items
- [ ] Selected state is visible
- [ ] Navigation works correctly

**Actual Results:**
```
[Record what you observe]
```

**Status:** ⬜ PASS  ⬜ FAIL  
**Issues:** [If failed, describe the issue]

---

#### Test 24: Scrolling with Zoom
**Objective:** Verify scrolling behavior

**Steps:**
1. Scroll through entire profile page
2. Check all content is reachable

**Expected Results:**
- [ ] Smooth scrolling behavior
- [ ] All content is reachable
- [ ] No content is hidden off-screen
- [ ] Pull-to-refresh still works
- [ ] No performance issues

**Actual Results:**
```
[Record what you observe]
```

**Status:** ⬜ PASS  ⬜ FAIL  
**Issues:** [If failed, describe the issue]

---

### Display Zoom Summary

**Total Tests:** 4  
**Passed:** ___  
**Failed:** ___  
**Pass Rate:** ___%

**Critical Issues Found:** ___  
**Notes:**
```
[Add any additional observations]
```

---

## 🎯 PART 5: Interactive Elements Verification

### Test Execution

#### Test 25: All Buttons Inventory
**Objective:** Verify all buttons are accessible

**Steps:**
1. Create inventory of all buttons
2. Test each button with screen reader
3. Verify touch target size

**Button Checklist:**
- [ ] Edit profile button - Accessible, 48dp+
- [ ] Change password button - Accessible, 48dp+
- [ ] List Kendaraan button - Accessible, 48dp+
- [ ] Logout button - Accessible, 48dp+, Red color
- [ ] Add vehicle button (empty state) - Accessible, 48dp+
- [ ] Retry button (error state) - Accessible, 48dp+
- [ ] Notification icon - Accessible, 48dp+
- [ ] Points card - Accessible, 48dp+
- [ ] Vehicle cards - Accessible, 48dp+

**Actual Results:**
```
[Record any issues found]
```

**Status:** ⬜ PASS  ⬜ FAIL  
**Issues:** [If failed, describe the issue]

---

## 📊 FINAL SUMMARY

### Overall Test Results

**Platform:** Android / iOS  
**Device:** [Device name and OS version]  
**Test Date:** [Date]  
**Tester:** [Name]

**Total Test Cases:** 25  
**Passed:** ___  
**Failed:** ___  
**Pass Rate:** ___%

### Issues by Severity

**Critical (Blocks task completion):** ___
```
[List critical issues]
```

**High (Significantly impacts usability):** ___
```
[List high priority issues]
```

**Medium (Impacts usability, has workaround):** ___
```
[List medium priority issues]
```

**Low (Minor inconvenience):** ___
```
[List low priority issues]
```

### WCAG 2.1 AA Compliance

**Level A Compliance:** ⬜ YES  ⬜ NO  
**Level AA Compliance:** ⬜ YES  ⬜ NO

**Compliance Notes:**
```
[Add notes about compliance status]
```

### Key Findings

1. **Finding 1:**
   ```
   [Describe finding]
   ```

2. **Finding 2:**
   ```
   [Describe finding]
   ```

3. **Finding 3:**
   ```
   [Describe finding]
   ```

### Recommendations

1. **Recommendation 1:**
   ```
   [Describe recommendation]
   ```

2. **Recommendation 2:**
   ```
   [Describe recommendation]
   ```

3. **Recommendation 3:**
   ```
   [Describe recommendation]
   ```

### Next Steps

- [ ] Document all issues in issue tracking system
- [ ] Prioritize fixes: Critical → High → Medium → Low
- [ ] Implement fixes for critical and high priority issues
- [ ] Retest after fixes are implemented
- [ ] Update accessibility documentation
- [ ] Consider user testing with people with disabilities

### Sign-Off

**Tested By:** ___________________  
**Date:** ___________________  
**Approved By:** ___________________  
**Date:** ___________________

---

## 📝 Notes and Observations

```
[Add any additional notes, patterns, or observations from testing]
```

---

## 📚 Reference Materials

- **WCAG 2.1 Guidelines:** https://www.w3.org/WAI/WCAG21/quickref/
- **Flutter Accessibility:** https://docs.flutter.dev/development/accessibility-and-localization/accessibility
- **Material Design Accessibility:** https://material.io/design/usability/accessibility.html
- **Android Accessibility:** https://developer.android.com/guide/topics/ui/accessibility
- **iOS Accessibility:** https://developer.apple.com/accessibility/

---

**End of Accessibility Testing Execution Guide**
