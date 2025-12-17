# Implementation Plan - Point System Integration

## Overview

This implementation plan breaks down the Point System Integration into discrete, manageable tasks. Each task builds incrementally on previous work, with checkpoints to ensure all tests pass before proceeding.

The plan follows a bottom-up approach: data models → services → business logic → provider → UI components → integration.

---

## Phase 1: Foundation - Data Models and Services

### 1. Implement Core Data Models

- [x] 1.1 Create PointHistoryModel with business logic helpers
  - Implement fromJson/toJson methods
  - Add isEarned, isUsed, absolutePoints getters
  - Add formattedValue getter for Rupiah display
  - Handle null/invalid data gracefully
  - _Requirements: 1.1, 1.4, 1.5_

- [x] 1.2 Create PointStatisticsModel with derived metrics
  - Implement fromJson/toJson methods
  - Add netPoints, usageRate, equivalentValue getters
  - Calculate metrics correctly
  - _Requirements: 1.2, 1.4_

- [x] 1.3 Create PointFilterModel with matching logic
  - Implement filter types (all, earned, used)
  - Add date range and amount range support
  - Implement matches() method for filtering
  - Add factory constructors (all, earned, used)
  - _Requirements: 1.3, 1.4_

- [ ]* 1.4 Write unit tests for data models
  - Test JSON serialization/deserialization
  - Test business logic helpers
  - Test filter matching logic
  - Test edge cases (null, invalid data)
  - _Requirements: 9.3_

### 2. Implement Point Service with Business Logic

- [x] 2.1 Create PointService class structure
  - Set up HttpClient integration
  - Define business logic constants (earning rate, redemption value, max discount)
  - Implement retry mechanism with exponential backoff
  - Add proper error handling
  - _Requirements: 2.1, 2.4, 2.7_

- [x] 2.2 Implement business logic calculation methods
  - `calculateEarnedPoints(int parkingCost)` → 1 poin per Rp1.000
  - `calculateDiscountAmount(int points)` → 1 poin = Rp100
  - `calculateMaxAllowedPoints(int parkingCost)` → 30% limit
  - `validatePointUsage(int points, int parkingCost, int balance)` → validation
  - _Requirements: 10.1, 10.2, 10.3, 10.4_

- [x] 2.3 Implement API methods for fetching data
  - `fetchBalance()` → GET /api/points/balance
  - `fetchHistory({page, limit})` → GET /api/points/history with pagination
  - `fetchStatistics()` → GET /api/points/statistics
  - Include authentication headers
  - Validate response structure
  - _Requirements: 2.1, 2.2, 2.6, 2.10_

- [x] 2.4 Implement API methods for transactions
  - `earnPoints({transactionId, parkingCost})` → POST /api/points/earn
  - `usePoints({bookingId, pointAmount, parkingCost})` → POST /api/points/use
  - `refundPoints({bookingId})` → POST /api/points/refund
  - Validate business rules before API call
  - Handle success/error responses
  - _Requirements: 2.3, 2.4, 2.5, 2.8, 8.4, 8.5, 8.6, 8.7_

- [ ]* 2.5 Write unit tests for PointService
  - Test business logic calculations
  - Test API call success scenarios
  - Test error handling and retry logic
  - Test validation methods
  - Test network error scenarios
  - _Requirements: 9.2_

### 3. Implement Error Handling System

- [ ] 3.1 Create custom exception classes
  - NetworkException for connection errors
  - AuthException for authentication failures
  - ValidationException for validation errors
  - InsufficientPointsException with required/available fields
  - DiscountLimitException with maxAllowed field
  - _Requirements: 2.5, 3.4_

- [ ] 3.2 Implement PointErrorHandler utility
  - `getUserMessage(Exception)` → user-friendly error messages
  - `logError(Exception, StackTrace)` → error logging
  - Map exceptions to Indonesian messages
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ]* 3.3 Write unit tests for error handling
  - Test exception creation
  - Test error message generation
  - Test error logging
  - _Requirements: 9.3_

### 4. Checkpoint - Ensure all tests pass
- Ensure all tests pass, ask the user if questions arise.

---

## Phase 2: State Management and Provider

### 5. Implement PointProvider

- [x] 5.1 Create PointProvider class structure
  - Extend ChangeNotifier
  - Inject PointService, NotificationProvider, SharedPreferences
  - Define state variables (balance, history, statistics, filter, loading, error)
  - Implement getters (balance, balanceDisplay, equivalentValue, filteredHistory)
  - _Requirements: 5.1, 5.6_

- [x] 5.2 Implement data fetching methods
  - `fetchBalance()` → fetch and update balance
  - `fetchHistory({loadMore})` → fetch with pagination
  - `fetchStatistics()` → fetch statistics
  - `refresh()` → refresh all data
  - Handle loading and error states
  - _Requirements: 5.2_

- [x] 5.3 Implement business logic methods in provider
  - `calculateAvailableDiscount(int parkingCost)` → max discount for user
  - `canUsePoints(int points, int parkingCost)` → validation check
  - `validatePointUsage(int points, int parkingCost)` → error message or null
  - Use PointService for calculations
  - _Requirements: 10.3, 10.5, 11.4_

- [x] 5.4 Implement filter operations
  - `applyFilter(PointFilterModel)` → apply filter and notify
  - `clearFilter()` → reset to all filter
  - `_applyFilter(List<PointHistoryModel>)` → filter history list
  - _Requirements: 4.2_

- [x] 5.5 Implement cache operations
  - `_cacheData()` → save to SharedPreferences
  - `_loadCachedData()` → load from cache
  - `_clearCache()` → clear on logout
  - Check cache validity (24 hours)
  - _Requirements: 7.1, 7.2, 7.3, 7.5_

- [x] 5.6 Implement lifecycle methods
  - `initialize()` → load cached data, fetch fresh if online
  - `dispose()` → cleanup
  - Handle offline mode indicator
  - _Requirements: 5.2, 5.3, 7.2, 7.4_

- [ ]* 5.7 Write unit tests for PointProvider
  - Test state management (loading, error, success)
  - Test data fetching methods
  - Test business logic methods
  - Test filter operations
  - Test cache operations
  - Test offline mode
  - _Requirements: 9.1_

### 6. Integrate with NotificationProvider

- [ ] 6.1 Extend NotificationProvider for point notifications
  - Add point notification badge state
  - Add method to show point earned notification
  - Add method to mark point notifications as read
  - _Requirements: 5.4, 5.5_

- [ ] 6.2 Connect PointProvider with NotificationProvider
  - Notify when balance changes
  - Update notification badge
  - Clear badge when point page opened
  - _Requirements: 5.4, 5.6_

- [ ]* 6.3 Write integration tests for notification flow
  - Test notification on point earned
  - Test badge update
  - Test badge clear on page open
  - _Requirements: 9.5_

### 7. Checkpoint - Ensure all tests pass
- Ensure all tests pass, ask the user if questions arise.

---

## Phase 3: UI Components

### 8. Implement Point Balance Card Widget

- [x] 8.1 Create PointBalanceCard widget
  - Display balance and equivalent value
  - Show loading state with shimmer effect
  - Show error state with retry button
  - Handle tap interaction
  - Add accessibility labels
  - _Requirements: 4.3, 4.6_

- [ ]* 8.2 Write widget tests for PointBalanceCard
  - Test rendering with different states
  - Test loading shimmer
  - Test error state and retry
  - Test tap interaction
  - Test accessibility
  - _Requirements: 9.4_

### 9. Implement Filter Bottom Sheet

- [x] 9.1 Create FilterBottomSheet widget
  - Display filter type options (All, Earned, Used)
  - Add date range picker
  - Add amount range inputs
  - Implement Apply and Clear actions
  - Add accessibility labels
  - _Requirements: 4.1, 4.6_

- [ ]* 9.2 Write widget tests for FilterBottomSheet
  - Test filter type selection
  - Test date range picker
  - Test amount range input
  - Test Apply/Clear actions
  - Test accessibility
  - _Requirements: 9.4_

### 10. Implement Point Info Bottom Sheet

- [x] 10.1 Create PointInfoBottomSheet widget
  - Display earning mechanism (1 poin per Rp1.000)
  - Display redemption mechanism (1 poin = Rp100)
  - Display maximum discount rule (30%)
  - Display minimum redemption (10 poin)
  - Display refund policy
  - Show example calculations
  - Add accessibility labels
  - _Requirements: 4.3, 4.6, 10.8_

- [ ]* 10.2 Write widget tests for PointInfoBottomSheet
  - Test content rendering
  - Test accessibility
  - _Requirements: 9.4_

### 11. Implement Point Empty State Widget

- [x] 11.1 Create PointEmptyState widget
  - Display helpful message for empty history
  - Display illustration
  - Handle "no filter matches" case
  - Add accessibility labels
  - _Requirements: 4.4, 4.5, 4.6_

- [ ]* 11.2 Write widget tests for PointEmptyState
  - Test rendering
  - Test different messages
  - Test accessibility
  - _Requirements: 9.4_

### 12. Implement Point History Item Widget

- [x] 12.1 Update PointHistoryItem widget (already exists)
  - Ensure color-coding by transaction type
  - Display formatted values
  - Add accessibility labels
  - _Requirements: 4.6_

- [ ]* 12.2 Write widget tests for PointHistoryItem
  - Test rendering for earned points
  - Test rendering for used points
  - Test accessibility
  - _Requirements: 9.4_

### 13. Checkpoint - Ensure all tests pass
- Ensure all tests pass, ask the user if questions arise.

---

## Phase 4: Point Page Implementation

### 14. Implement Point Page

- [x] 14.1 Create PointPage screen structure
  - Set up StatefulWidget with AutomaticKeepAliveClientMixin
  - Add Consumer<PointProvider> for state management
  - Implement pull-to-refresh functionality
  - Add offline indicator
  - _Requirements: 6.3, 6.5, 7.2, 7.6_

- [x] 14.2 Implement point balance section
  - Display PointBalanceCard at top
  - Show statistics (total earned, total used)
  - Add info button to open PointInfoBottomSheet
  - _Requirements: 4.3_

- [x] 14.3 Implement history list section
  - Use ListView.builder for efficient rendering
  - Implement infinite scroll with pagination
  - Add filter button to open FilterBottomSheet
  - Show PointEmptyState when no history
  - Use RepaintBoundary for list items
  - _Requirements: 4.1, 4.2, 4.4, 4.5, 12.5_

- [x] 14.4 Implement loading and error states
  - Show shimmer loading for initial load
  - Show loading indicator for pagination
  - Show error message with retry button
  - Handle offline mode gracefully
  - _Requirements: 3.6, 12.4_

- [ ]* 14.5 Write widget tests for PointPage
  - Test rendering with data
  - Test pull-to-refresh
  - Test infinite scroll
  - Test filter interaction
  - Test info button
  - Test loading states
  - Test error states
  - Test accessibility
  - _Requirements: 9.4_

### 15. Implement Navigation and Routing

- [x] 15.1 Add point page route to app routes
  - Define route name '/point'
  - Add route in route configuration (main.dart)
  - _Requirements: 6.1_

- [x] 15.2 Update Profile Page navigation
  - Add tap handler to premium_points_card
  - Navigate to point page with slide animation
  - Preserve state on navigation
  - _Requirements: 6.1, 6.3_

- [ ] 15.3 Implement deep linking support
  - Handle deep link to point page
  - Add authentication check
  - _Requirements: 6.4_

- [ ]* 15.4 Write integration tests for navigation
  - Test navigation from profile page
  - Test back navigation
  - Test state preservation
  - Test deep linking
  - _Requirements: 9.5_

### 16. Checkpoint - Ensure all tests pass
- Ensure all tests pass, ask the user if questions arise.

---

## Phase 5: Point Usage in Booking Flow

### 17. Implement Point Usage Widget

- [x] 17.1 Create PointUsageWidget for booking page
  - Add toggle to enable/disable point usage
  - Display current balance and available discount
  - Add slider to select point amount
  - Show real-time discount calculation
  - Display validation messages
  - Show maximum discount indicator (30%)
  - Add accessibility labels
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

- [ ]* 17.2 Write widget tests for PointUsageWidget
  - Test toggle interaction
  - Test slider interaction
  - Test discount calculation
  - Test validation messages
  - Test maximum discount indicator
  - Test accessibility
  - _Requirements: 9.4_

### 18. Integrate Point Usage with Booking Page

- [x] 18.1 Add PointUsageWidget to BookingPage
  - Place widget in booking summary section
  - Connect with PointProvider
  - Update cost calculation when points selected
  - _Requirements: 11.1, 11.3_

- [x] 18.2 Update booking confirmation flow
  - Include point usage in booking request
  - Call PointService.usePoints() on confirmation
  - Handle point deduction success/failure
  - Rollback booking if point deduction fails
  - _Requirements: 11.6, 11.7, 10.6_

- [x] 18.3 Update booking confirmation display
  - Show breakdown: original cost, point discount, final cost
  - Display points used and points saved
  - Update receipt with point information
  - _Requirements: 11.6, 11.8_

- [ ]* 18.4 Write integration tests for point usage in booking
  - Test end-to-end booking with points
  - Test point deduction on confirmation
  - Test rollback on failure
  - Test confirmation display
  - _Requirements: 9.5_

### 19. Implement Point Earning After Payment

- [ ] 19.1 Update payment success flow
  - Call PointService.earnPoints() after successful payment
  - Calculate earned points (1 poin per Rp1.000)
  - Update PointProvider balance
  - _Requirements: 10.1, 10.9_

- [ ] 19.2 Show point earned notification
  - Display notification with earned amount
  - Show new balance
  - Add navigation to point page
  - _Requirements: 10.9_

- [ ]* 19.3 Write integration tests for point earning
  - Test point earning after payment
  - Test notification display
  - Test balance update
  - _Requirements: 9.5_

### 20. Implement Point Refund for Cancelled Bookings

- [ ] 20.1 Update booking cancellation flow
  - Check if booking used points
  - Call PointService.refundPoints() on cancellation
  - Update PointProvider balance
  - _Requirements: 10.7_

- [ ] 20.2 Show point refund notification
  - Display notification with refunded amount
  - Show new balance
  - _Requirements: 10.7_

- [ ]* 20.3 Write integration tests for point refund
  - Test point refund on cancellation
  - Test notification display
  - Test balance update
  - _Requirements: 9.5_

### 21. Checkpoint - Ensure all tests pass
- Ensure all tests pass, ask the user if questions arise.

---

## Phase 6: Provider Integration and Testing

### 22. Integrate PointProvider in App

- [x] 22.1 Add PointProvider to MultiProvider in main.dart
  - Initialize PointProvider with dependencies
  - Place in correct order in provider tree
  - _Requirements: 5.1_
  - **Status:** Already implemented in main.dart as ChangeNotifierProxyProvider

- [x] 22.2 Initialize PointProvider on app start
  - Call initialize() after user login
  - Load cached data
  - Fetch fresh data if online
  - _Requirements: 5.2, 7.2_
  - **Implementation:** Added `pointProvider.initialize()` call in login_screen.dart after successful login

- [x] 22.3 Clear PointProvider on logout
  - Call dispose() on logout
  - Clear all cached data
  - Reset state
  - _Requirements: 5.3, 7.3_
  - **Implementation:** Added `pointProvider.clear()` call in profile_page.dart logout flow

- [ ]* 22.4 Write integration tests for provider lifecycle
  - Test initialization on login
  - Test data loading
  - Test cleanup on logout
  - _Requirements: 9.5_

### 23. Performance Optimization

- [ ] 23.1 Optimize list rendering
  - Verify ListView.builder usage
  - Add RepaintBoundary to list items
  - Implement AutomaticKeepAliveClientMixin
  - _Requirements: 12.1, 12.2, 12.5_

- [ ] 23.2 Optimize network calls
  - Implement request cancellation on dispose
  - Add debouncing for filter operations
  - Verify exponential backoff for retries
  - _Requirements: 12.3, 12.4_

- [ ] 23.3 Optimize cache operations
  - Ensure cache operations don't block UI thread
  - Implement cache compression if needed
  - _Requirements: 12.6_

- [ ]* 23.4 Write performance tests
  - Test initial render time (<500ms)
  - Test scroll performance (60fps)
  - Test filter operation time (<100ms)
  - _Requirements: 12.1, 12.2, 12.3_

### 24. Final Integration Testing

- [ ]* 24.1 Write end-to-end integration tests
  - Test complete point earning flow
  - Test complete point usage flow
  - Test complete point refund flow
  - Test offline mode
  - Test error scenarios
  - _Requirements: 9.5_

- [ ]* 24.2 Verify test coverage
  - Run coverage report
  - Ensure >80% coverage
  - Identify and test uncovered code
  - _Requirements: 9.6_

### 25. Final Checkpoint - Ensure all tests pass
- Ensure all tests pass, ask the user if questions arise.

---

## Phase 7: Backend Coordination and Documentation

### 26. Backend API Verification

- [ ] 26.1 Document required API endpoints
  - Create API specification document
  - Include request/response examples
  - Document business logic requirements
  - Document error responses
  - _Requirements: 8.11_

- [ ] 26.2 Coordinate with backend team
  - Share API specification
  - Verify endpoint availability
  - Test endpoints with Postman/curl
  - Verify business logic implementation
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8, 8.9, 8.10_

- [ ] 26.3 Test API integration
  - Test all endpoints with real backend
  - Verify response formats
  - Test error scenarios
  - Test authentication
  - _Requirements: 8.9, 8.10_

### 27. Documentation

- [ ] 27.1 Create user guide
  - How to earn points
  - How to use points
  - How to view history
  - How to filter history
  - Business rules explanation
  - _Requirements: 10.8_

- [ ] 27.2 Create developer documentation
  - Architecture overview
  - Component documentation
  - API integration guide
  - Testing guide
  - Troubleshooting guide

- [ ] 27.3 Update existing documentation
  - Update app README
  - Update CHANGELOG
  - Update API documentation

### 28. Final Review and Deployment

- [ ] 28.1 Code review
  - Review all code changes
  - Ensure code quality standards
  - Verify error handling
  - Verify accessibility compliance

- [ ] 28.2 Manual testing
  - Test on multiple devices
  - Test different screen sizes
  - Test offline scenarios
  - Test error scenarios
  - Test accessibility with screen reader

- [ ] 28.3 Prepare for deployment
  - Create release notes
  - Update version number
  - Tag release in git
  - Build release APK

---

## Summary

**Total Tasks:** 28 main tasks with 80+ sub-tasks
**Estimated Timeline:** 3-4 weeks
**Test Coverage Target:** >80%

**Key Milestones:**
1. ✅ Phase 1: Foundation (Data Models & Services)
2. ✅ Phase 2: State Management (Provider)
3. ✅ Phase 3: UI Components
4. ✅ Phase 4: Point Page
5. ✅ Phase 5: Booking Integration
6. ✅ Phase 6: Testing & Optimization
7. ✅ Phase 7: Backend & Documentation

**Success Criteria:**
- All requirements implemented
- All tests passing with >80% coverage
- Business logic validated (1 poin per Rp1.000, 1 poin = Rp100, 30% max)
- Point usage integrated in booking flow
- Backend API endpoints available and tested
- Performance targets met (60fps, <500ms load)
- No regressions in existing features
- User can understand point value (Rp equivalent displayed)
- System consistent with UC006 from SKPPL
