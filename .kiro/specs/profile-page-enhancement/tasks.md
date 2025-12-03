# Implementation Plan - Profile Page Enhancement

## PHASE 1: CRITICAL CONSISTENCY FIXES (HIGH PRIORITY)

### Epic 1: Design System Foundation

- [x] 1. Extract and create reusable AnimatedCard component




  - Extract _AnimatedCard from home_page.dart to lib/presentation/widgets/common/animated_card.dart
  - Make it a public class with proper documentation
  - Ensure it accepts customization parameters (borderRadius, padding)
  - Test animation behavior (scale 0.97, duration 150ms)
  - _Requirements: 2.2, 9.1_

- [x] 2. Create GradientHeader reusable component







  - Create lib/presentation/widgets/common/gradient_header.dart
  - Implement with default QPARKIN gradient colors (0xFF42CBF8, 0xFF573ED1, 0xFF39108A)
  - Accept child widget and customization parameters (height, padding, gradientColors)
  - Ensure consistent with home_page and activity_page headers
  - _Requirements: 2.1, 9.2_

- [x] 3. Create EmptyStateWidget reusable component





  - Create lib/presentation/widgets/common/empty_state_widget.dart
  - Accept title, description, icon, actionText, and onAction parameters
  - Implement with consistent styling and spacing
  - Add semantic labels for accessibility
  - _Requirements: 4.3, 9.3_

- [x] 4. Add CurvedNavigationBar to ProfilePage





  - Import CurvedNavigationBar and NavigationUtils
  - Add bottomNavigationBar with index 4
  - Implement onTap using NavigationUtils.handleNavigation(context, index, 4)
  - Test navigation to other pages and back
  - _Requirements: 1.1, 1.2, 1.3, 1.4_

### Epic 2: State Management Implementation

- [x] 5. Create ProfileProvider with state management





  - Create lib/logic/providers/profile_provider.dart
  - Implement ChangeNotifier with user and vehicle state
  - Add loading, error, and success state management
  - Implement fetchUserData() and fetchVehicles() methods
  - Add error handling and clearError() method
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 5.1 Write property test for ProfileProvider state management


  - **Property 4: State Management Reactivity**
  - **Validates: Requirements 3.2, 3.3**
  - Test that all listeners are notified on state changes
  - Generate random user and vehicle data for testing
  - Verify notification count matches update count

- [x] 6. Create ProfileService for API communication





  - Create lib/data/services/profile_service.dart
  - Implement fetchUserData() API call
  - Implement fetchVehicles() API call
  - Implement updateUser() API call
  - Add proper error handling and timeout management
  - _Requirements: 3.4_

- [x] 7. Enhance UserModel and VehicleModel




  - Update lib/data/models/user_model.dart with saldoPoin field
  - Add copyWith() method to UserModel
  - Update lib/data/models/vehicle_model.dart with isActive field
  - Add copyWith() method to VehicleModel
  - Ensure proper JSON serialization
  - _Requirements: 6.1, 5.2_

- [x] 8. Integrate ProfileProvider into ProfilePage





  - Wrap ProfilePage with ChangeNotifierProvider
  - Use Consumer<ProfileProvider> for reactive UI
  - Call fetchUserData() and fetchVehicles() in initState
  - Handle loading, error, and success states
  - _Requirements: 3.2, 3.3, 4.1, 4.2_

### Epic 3: Loading and Error States

- [x] 9. Create ProfileShimmerLoading components





  - Create lib/presentation/widgets/profile/profile_shimmer_loading.dart
  - Implement ProfilePageShimmer for full page loading
  - Implement VehicleCardShimmer for vehicle card loading
  - Implement UserInfoShimmer for user section loading
  - Use consistent shimmer colors and animation
  - _Requirements: 4.1, 9.4_

- [x] 10. Implement error state UI in ProfilePage














  - Show error icon, message, and retry button when hasError is true
  - Use EmptyStateWidget for error display
  - Implement retry button that calls fetchUserData() and fetchVehicles()
  - Add semantic labels for accessibility
  - Ensure minimum 48dp touch target for retry button
  - _Requirements: 4.2, 8.1, 8.2, 8.3_

- [x] 10.1 Write property test for error state recovery




  - **Property 6: Error State Recovery**
  - **Validates: Requirements 4.2**
  - Test that retry button is present in error state
  - Verify retry button triggers data reload
  - Test error clearing after successful retry

- [x] 11. Implement empty state for vehicle list








  - Show EmptyStateWidget when vehicle list is empty
  - Display "Tidak ada kendaraan terdaftar" message
  - Add "Tambah Kendaraan" action button
  - Navigate to add vehicle page on button tap
  - _Requirements: 4.3_
-
- [x] 12. Add pull-to-refresh functionality
















- [ ] 12. Add pull-to-refresh functionality

  - Wrap SingleChildScrollView with RefreshIndicator
  - Set color to brand purple (0xFF573ED1)
  - Implement onRefresh to call provider.refreshAll()
  - Show success snackbar on successful refresh
  - Handle errors gracefully with error snackbar
  - _Requirements: 4.4, 12.1, 12.2, 12.3, 12.4, 12.5_

## PHASE 2: UX ENHANCEMENTS (MEDIUM PRIORITY)

### Epic 4: Interactive Vehicle Management

- [x] 13. Create VehicleCard component





  - Create lib/presentation/widgets/profile/vehicle_card.dart
  - Wrap with AnimatedCard for tap feedback
  - Display vehicle icon, name, type, and plate number
  - Show "Aktif" badge when isActive is true
  - Accept onTap, onEdit, and onDelete callbacks
  - _Requirements: 5.1, 5.2, 5.3, 5.5_

- [x] 13.1 Write property test for active vehicle indicator


  - **Property 8: Active Vehicle Indicator**
  - **Validates: Requirements 5.2**
  - Test that exactly one vehicle has isActive = true
  - Generate random vehicle lists
  - Verify active count is 1 when list is not empty

- [x] 14. Implement swipe-to-delete for vehicle cards





  - Wrap VehicleCard with Dismissible widget
  - Set direction to DismissDirection.endToStart
  - Show red background with delete icon on swipe
  - Implement confirmDismiss to show confirmation dialog
  - Call provider.deleteVehicle() on confirmed dismissal
  - Show undo snackbar after deletion
  - _Requirements: 5.4_

- [x] 15. Update ProfilePage to use VehicleCard





  - Replace existing vehicle card implementation with VehicleCard component
  - Pass vehicle data and isActive status
  - Implement onTap to navigate to VehicleDetailPage
  - Ensure proper spacing and layout
  - _Requirements: 5.1, 5.3_

- [x] 16. Create VehicleDetailPage





  - Create lib/presentation/screens/vehicle_detail_page.dart
  - Display all vehicle information (name, plate, type, isActive)
  - Add edit button to navigate to edit form
  - Add delete button with confirmation dialog
  - Add "Set as Active" button if not currently active
  - Implement proper navigation and state updates
  - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

- [x] 16.1 Write property test for vehicle deletion confirmation


  - **Property 15: Vehicle Deletion Confirmation**
  - **Validates: Requirements 10.4**
  - Test that confirmation dialog appears before deletion
  - Verify deletion only occurs after confirmation
  - Test cancellation preserves vehicle

### Epic 5: Points Integration and Profile Editing

- [x] 17. Integrate PremiumPointsCard in profile header






  - Import PremiumPointsCard from widgets
  - Display user's saldoPoin from ProfileProvider
  - Use PointsCardVariant.gradient for consistent styling
  - Implement onTap to navigate to points history page
  - Ensure reactive updates when points change
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [x] 17.1 Write property test for points display reactivity



  - **Property 10: Points Display Reactivity**
  - **Validates: Requirements 6.2**
  - Test that PremiumPointsCard updates when points change
  - Generate random points values
  - Verify UI reflects new values

- [x] 18. Create EditProfilePage





  - Create lib/presentation/screens/edit_profile_page.dart
  - Implement form with fields: name, email, phone, photo
  - Add image picker for profile photo
  - Implement form validation (email format, required fields)
  - Add save button with loading state
  - Show success/error feedback after save
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 18.1 Write property test for form validation


  - **Property 11: Form Validation**
  - **Validates: Requirements 7.4**
  - Test that all fields are validated before submission
  - Generate random valid and invalid inputs
  - Verify validation errors are displayed correctly

- [x] 19. Add edit profile navigation





  - Update "Ubah informasi akun" menu item in ProfilePage
  - Navigate to EditProfilePage with current user data
  - Handle navigation back after successful save
  - Refresh profile data after edit
  - _Requirements: 7.1_

- [x] 20. Implement vehicle CRUD operations in ProfileProvider




  - Add addVehicle() method with API call
  - Add updateVehicle() method with API call
  - Add deleteVehicle() method with API call
  - Add setActiveVehicle() method with API call
  - Update vehicle list reactively after operations
  - Show success/error feedback
  - _Requirements: 3.3, 5.4, 10.4, 10.5_

### Epic 6: Accessibility and Polish

- [x] 21. Add semantic labels to all interactive elements




  - Add Semantics widgets to all buttons and cards
  - Provide meaningful labels and hints
  - Mark buttons with button: true
  - Add semantic labels to images and icons
  - Test with screen reader (TalkBack/VoiceOver)
  - _Requirements: 8.1, 8.2, 8.5_

- [x] 21.1 Write property test for accessibility labels



  - **Property 12: Accessibility Labels**
  - **Validates: Requirements 8.1, 8.2**
  - Test that all interactive elements have semantic labels
  - Verify labels are meaningful and descriptive
  - Check that hints describe actions

- [x] 22. Ensure minimum touch target sizes





  - Verify all buttons are at least 48dp in height
  - Add padding to small touch targets
  - Test with large text settings
  - Test with display zoom enabled
  - _Requirements: 8.3_

- [x] 22.1 Write property test for touch target size


  - **Property 13: Touch Target Size**
  - **Validates: Requirements 8.3**
  - Test that all interactive elements meet 48dp minimum
  - Generate random button configurations
  - Verify size constraints are met

- [x] 23. Implement semantic announcements for state changes











  - Announce loading states to screen readers
  - Announce success/error messages
  - Announce data updates after refresh
  - Test announcements with screen reader
  - _Requirements: 8.4_
- [x] 24. Add page transitions

- [x] 24. Add page transitions




  - Implement slide transitions for profile navigation
  - Use 300ms duration for consistency
  - Apply right-to-left direction for forward navigation
  - Maintain proper navigation stack
  - _Requirements: 1.4_

## PHASE 3: ADVANCED FEATURES (LOW PRIORITY)

### Epic 7: Logout and Additional Features
-

- [x] 25. Implement logout functionality




  - Add logout option in "Lainnya" section
  - Show confirmation dialog with warning message
  - Clear user data from SharedPreferences on confirm
  - Clear authentication tokens
  - Clear navigation stack
  - Navigate to login/welcome page
  - Use red color for logout button
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

- [x] 25.1 Write property test for logout data clearing


  - **Property 16: Logout Data Clearing**
  - **Validates: Requirements 11.2**
  - Test that all user data is cleared on logout
  - Verify SharedPreferences is empty after logout
  - Check that navigation stack is cleared

- [x] 26. Add notification badge to profile header





  - Add notification icon to header
  - Show badge with unread count
  - Link to notifications page
  - Update badge count reactively
  - _Requirements: Not in original requirements (enhancement)_

- [x] 27. Implement image caching for profile photos





  - Use cached_network_image package
  - Add placeholder images for loading state
  - Handle image loading errors gracefully
  - Optimize image sizes for different screen densities
  - _Requirements: Not in original requirements (performance)_

- [x] 28. Add vehicle usage statistics




  - Display parking count for each vehicle
  - Show total parking time
  - Display total cost spent
  - Add "View History" button for vehicle-specific history
  - _Requirements: Not in original requirements (enhancement)_

### Epic 8: Testing and Documentation

- [x] 29. Write unit tests for ProfileProvider





  - Test fetchUserData success and failure scenarios
  - Test vehicle CRUD operations
  - Test state management (loading, error, success)
  - Test error clearing functionality
  - Test refresh functionality
  - Achieve >90% code coverage

- [x] 30. Write unit tests for models




  - Test UserModel.fromJson and toJson
  - Test VehicleModel.fromJson and toJson
  - Test copyWith methods
  - Test model validation

- [x] 31. Write widget tests for ProfilePage



  - Test rendering with different states (loading, error, success, empty)
  - Test navigation to other pages
  - Test pull-to-refresh functionality
  - Test bottom navigation interaction

- [x] 32. Write widget tests for components




  - Test AnimatedCard animation behavior
  - Test VehicleCard rendering with active/inactive states
  - Test EmptyStateWidget rendering
  - Test GradientHeader rendering

- [x] 33. Write integration tests





  - Test complete profile management flow
  - Test error recovery flow
  - Test vehicle addition and deletion
  - Test navigation between profile pages

- [x] 34. Perform accessibility testing









  - Test with TalkBack (Android)
  - Test with VoiceOver (iOS)
  - Verify all interactive elements are announced
  - Test with large text settings
  - Test with display zoom enabled

- [x] 35. Update documentation





  - Document ProfileProvider API
  - Document reusable components (AnimatedCard, GradientHeader, EmptyStateWidget)
  - Add code examples for component usage
  - Update README with profile page features
  - Document accessibility features

## CHECKPOINT TASKS

- [x] 36. Checkpoint 1 - After Phase 1


















  - Ensure all tests pass
  - Verify navigation consistency across pages
  - Check that state management is working correctly
  - Confirm loading and error states display properly
  - Ask the user if questions arise

- [x] 37. Checkpoint 2 - After Phase 2






  - Ensure all tests pass
  - Verify vehicle management features work correctly
  - Check that points integration is functional
  - Confirm profile editing works as expected
  - Test accessibility features
  - Ask the user if questions arise

- [x] 38. Final Checkpoint - After Phase 3






  - Ensure all tests pass
  - Verify all features are working correctly
  - Check performance metrics (load time <2s)
  - Confirm accessibility compliance (WCAG 2.1 AA)
  - Verify code reusability (80% of components reusable)
  - Test on multiple devices and screen sizes
  - Ask the user if questions arise

## Notes

- All tasks are required for comprehensive implementation
- Each task references specific requirements from requirements.md
- Property-based tests should run minimum 100 iterations
- All components should follow the 8dp grid system
- Use const constructors wherever possible for performance
- Follow Flutter and Dart style guidelines
- Ensure all code is properly documented
- Test on both Android and iOS platforms
