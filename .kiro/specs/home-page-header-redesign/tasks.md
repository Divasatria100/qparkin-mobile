# Implementation Plan - Home Page Header Redesign

## Task Overview

This implementation plan breaks down the Home Page header redesign into discrete, manageable coding tasks. Each task builds incrementally to transform the current header into a modern, balanced design consistent with Activity Page and Map Page.

---

## - [ ] 1. Create Premium Points Card Widget

Create a reusable widget for displaying user points in a premium card design.

- Create new file `qparkin_app/lib/presentation/widgets/premium_points_card.dart`
- Implement widget with two design variants (gold gradient and purple border)
- Add parameters: `points`, `onTap`, `variant` (enum: gold/purple)
- Include proper padding, shadows, and border radius (16px)
- Add ripple effect for tap interaction
- Implement accessibility labels for screen readers
- _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 5.2, 5.3_

## - [ ] 2. Refactor Profile Section Layout

Improve the profile section to work independently without points display.

- Modify profile Row in `home_page.dart` to remove points column
- Adjust avatar size to 28px radius (down from 30px)
- Update name text style to 20px (down from 22px) for better balance
- Ensure email text has proper ellipsis overflow handling
- Add subtle shadow to avatar CircleAvatar
- Maintain white color scheme for text on gradient background
- _Requirements: 3.2, 3.4, 5.4_

## - [ ] 3. Restructure Header Layout Hierarchy

Reorganize header elements to create better visual flow and spacing.

- Reorder header children in Column widget:
  1. Top bar (location + notification)
  2. Greeting text
  3. Profile section
  4. Points card (NEW)
  5. Search bar
- Update spacing between sections: 20px after top bar, 16px between profile/points, 20px before search
- Ensure consistent padding: 24px horizontal throughout
- Adjust vertical padding: 20px top, 24px bottom
- _Requirements: 3.1, 3.3, 3.5, 1.2_

## - [ ] 4. Integrate Premium Points Card into Header

Add the new points card widget to the header layout.

- Import `PremiumPointsCard` widget in `home_page.dart`
- Add points card below profile section with 16px spacing
- Pass hardcoded points value (200) initially
- Implement `onTap` callback to navigate to points history (placeholder)
- Choose purple border variant for brand consistency
- Test layout on different screen sizes (320px - 428px width)
- _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.3_

## - [ ] 5. Optimize Glassmorphic Elements

Ensure glassmorphic effects (location selector, notification button) are consistent and performant.

- Review backdrop blur sigma values (keep at 10)
- Ensure border radius consistency (16px for location, 24px for notification)
- Verify opacity values (0.2 for background, 0.3 for border)
- Test scroll performance with backdrop blur
- Add performance monitoring if needed
- _Requirements: 4.2, 6.2, 6.4_

## - [ ] 6. Enhance Typography Consistency

Standardize font sizes, weights, and colors across header elements.

- Update greeting text: 18px, bold, white (down from 20px)
- Update profile name: 20px, bold, white, letterSpacing 0.3
- Update profile email: 13px, regular, white with 0.8 opacity
- Update points label: 13px, semibold, grey.shade600
- Update points value: 24px, bold, primary purple
- Ensure all text has proper contrast ratios (4.5:1 minimum)
- _Requirements: 1.3, 5.1, 5.4_

## - [ ] 7. Add Smooth Animations

Implement subtle animations for points card appearance and interactions.

- Add fade-in animation for points card (200ms delay, 300ms duration)
- Implement scale animation on points card tap (0.98 scale)
- Add ripple effect using InkWell for tap feedback
- Ensure animations maintain 60fps performance
- Test animation timing matches Activity/Map page transitions
- _Requirements: 4.4, 6.3, 6.5_

## - [ ] 8. Implement Responsive Layout Adjustments

Ensure header adapts gracefully to different screen sizes.

- Test layout on small screens (320px width)
- Test layout on medium screens (375px width)
- Test layout on large screens (428px width)
- Adjust font sizes if needed for small screens
- Ensure no text truncation occurs
- Verify touch targets remain 48dp minimum
- _Requirements: 3.4, 5.2, 5.4_

## - [ ] 9. Add Accessibility Enhancements

Improve accessibility for screen readers and users with disabilities.

- Add Semantics widget to points card with descriptive label
- Ensure all interactive elements have semantic labels
- Verify contrast ratios meet WCAG AA standards (4.5:1)
- Test with screen reader (TalkBack/VoiceOver)
- Ensure focus order is logical (top to bottom)
- _Requirements: 5.1, 5.2, 5.3, 5.4_

## - [ ]* 10. Write Widget Tests

Create comprehensive tests for the new points card widget.

- Test PremiumPointsCard renders correctly with different point values
- Test onTap callback is triggered
- Test both design variants (gold and purple)
- Test accessibility labels are present
- Test layout constraints and overflow handling
- _Requirements: All requirements validation_

## - [ ]* 11. Write Integration Tests

Test the complete header layout and interactions.

- Test header renders with all components
- Test points card tap navigation
- Test layout on different screen sizes
- Test animations play smoothly
- Test accessibility features work correctly
- _Requirements: All requirements validation_

## - [ ]* 12. Perform Visual Regression Testing

Ensure the redesign matches design specifications.

- Capture screenshots of header on different devices
- Compare spacing against design specs (8dp grid)
- Verify colors match design tokens
- Check shadow and elevation effects
- Validate typography sizes and weights
- _Requirements: 1.1, 1.2, 1.3, 1.4_

## - [ ]* 13. Performance Profiling

Measure and optimize header rendering performance.

- Profile header render time (target: <300ms)
- Measure backdrop blur impact on scroll performance
- Check for layout shifts during load
- Optimize gradient rendering if needed
- Ensure memory usage is stable
- _Requirements: 6.1, 6.2, 6.3, 6.4_

## - [ ]* 14. Create Documentation

Document the new header design and usage.

- Update component documentation for PremiumPointsCard
- Add usage examples and code snippets
- Document design decisions and rationale
- Create before/after comparison screenshots
- Update style guide with new patterns
- _Requirements: All requirements_

---

## Implementation Notes

- **Start with Task 1**: Create the points card widget first as it's the foundation
- **Test incrementally**: After each task, verify the changes work correctly
- **Maintain consistency**: Always reference Activity/Map page designs
- **Focus on core tasks**: Optional tasks (marked with *) can be done after core implementation
- **Use existing patterns**: Leverage existing widgets and utilities where possible

## Success Criteria

The implementation is complete when:
1. ✅ Points card is visually distinct and premium-looking
2. ✅ Header layout is balanced with clear hierarchy
3. ✅ Design is consistent with Activity/Map pages
4. ✅ All accessibility requirements are met
5. ✅ Performance targets are achieved (render <300ms, 60fps)
6. ✅ Code is tested and documented
