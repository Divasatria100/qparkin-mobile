# Accessibility Quick Test Card
## Profile Page - Essential Tests Only

**Print this card and keep it handy during testing!**

---

## ⚡ Quick Setup

### Android TalkBack
```
Settings → Accessibility → TalkBack → ON
```

### iOS VoiceOver
```
Settings → Accessibility → VoiceOver → ON
```

### Large Text
```
Android: Settings → Display → Font size → Largest
iOS: Settings → Accessibility → Display & Text Size → Larger Text (Max)
```

### Display Zoom
```
Android: Settings → Display → Display size → Largest
iOS: Settings → Display & Brightness → View → Zoomed
```

---

## ✅ Essential Test Checklist (15 minutes)

### 1. Screen Reader Navigation (5 min)
- [ ] Bottom nav announces "Profile, tab 5 of 5"
- [ ] User name and email are announced
- [ ] Points card announces value and hint
- [ ] Vehicle cards announce name, type, plate
- [ ] All buttons have labels and hints

### 2. Interactive Elements (3 min)
- [ ] All buttons are tappable with screen reader
- [ ] Swipe-to-delete is discoverable
- [ ] Dialogs are accessible
- [ ] Logout flow is clear and safe

### 3. State Changes (3 min)
- [ ] Loading state is announced
- [ ] Error state has retry button
- [ ] Success messages are announced
- [ ] Pull-to-refresh is communicated

### 4. Large Text (2 min)
- [ ] All text scales without truncation
- [ ] No overlapping elements
- [ ] Buttons expand to fit text
- [ ] Dialogs remain readable

### 5. Display Zoom (2 min)
- [ ] All elements visible (no horizontal scroll)
- [ ] Touch targets are easy to tap (48dp+)
- [ ] No overlapping interactive elements

---

## 🚨 Critical Issues to Watch For

1. **Missing Labels** - Interactive elements without semantic labels
2. **Unclear Hints** - Buttons without action descriptions
3. **Text Truncation** - Text cut off with large text
4. **Small Touch Targets** - Buttons smaller than 48dp
5. **Unannounced Changes** - State changes not communicated
6. **Focus Traps** - Can't navigate through page

---

## ✅ Pass Criteria

**Minimum for PASS:**
- ✅ All interactive elements have labels
- ✅ All text readable with large text
- ✅ All touch targets ≥ 48dp
- ✅ State changes are announced
- ✅ No critical blockers

---

## 📝 Quick Issue Log

| # | Severity | Issue | Location |
|---|----------|-------|----------|
| 1 |          |       |          |
| 2 |          |       |          |
| 3 |          |       |          |
| 4 |          |       |          |
| 5 |          |       |          |

**Severity:** Critical / High / Medium / Low

---

## 🎯 Test Result

**Date:** ___________  
**Tester:** ___________  
**Device:** ___________

**Tests Passed:** ___ / 5  
**Critical Issues:** ___  
**Overall:** ⬜ PASS  ⬜ FAIL

**Notes:**
```
_________________________________
_________________________________
_________________________________
```

---

## 📞 Need Help?

- Full guide: `accessibility_testing_execution_guide.md`
- Detailed checklist: `accessibility_testing_checklist.md`
- Testing guide: `accessibility_testing_guide.md`

---

**Remember:** Test on real devices for accurate results!
