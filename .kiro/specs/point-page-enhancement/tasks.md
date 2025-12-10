# Implementation Plan: Point Page Enhancement

## Overview
This implementation plan transforms the existing static point page into a fully functional, data-driven point management system integrated with the QPARKIN backend. The plan follows clean architecture principles with clear separation between presentation, logic, and data layers.

---

## Phase 1: Data Layer Foundation

- [x] 1. Create point data models





  - Create `lib/data/models/point_history_model.dart` with fromJson/toJson methods
  - Create `lib/data/models/point_statistics_model.dart` with computed properties
  - Create `lib/data/models/point_filter_model.dart` with filter logic
  - Add validation methods and helper getters (isAddition, isDeduction, etc.)
  - _Requirements: 2.1, 2.2, 3.1, 4.1_
-

- [x] 2. Implement PointService for API communication




  - Create `lib/data/services/point_service.dart` following existing service patterns
  - Implement `getBalance()` method with error handling
  - Implement `getHistory()` method with pagination support
  - Implement `getStatistics()` method for aggregated data
  - Implement `usePoints()` method for payment integration
  - Add timeout handling and retry logic consistent with BookingService
  - _Requirements: 1.1, 2.1, 4.1, 6.1_

---

## Phase 2: Backend API Endpoints
-

- [x] 3. Create backend API endpoints for point operations




  - Create `app/Http/Controllers/PointController.php`
  - Implement `GET /api/points/balance` endpoint (returns user.saldo_poin)
  - Implement `GET /api/points/history` endpoint with pagination and filtering
  - Implement `GET /api/points/statistics` endpoint with aggregated calculations
  - Implement `POST /api/points/use` endpoint for payment deduction
  - Add authentication middleware and validation
  - Register routes in `routes/api.php`
  - _Requirements: 1.1, 2.1, 4.1, 6.1_

---

## Phase 3: State Management Layer

- [x] 4. Create PointProvider for state management





  - Create `lib/logic/providers/point_provider.dart` extending ChangeNotifier
  - Implement balance state management with loading/error states
  - Implement history state management with pagination
  - Implement statistics state management
  - Implement filter state management with `_applyFilter()` method
  - Add caching logic using SharedPreferences
  - Implement `fetchBalance()`, `fetchHistory()`, `fetchStatistics()` methods
  - Implement `refreshAll()` for pull-to-refresh
  - Implement `usePoints()` for payment integration
  - Add auto-sync logic (check if last sync > 30 seconds)
  - _Requirements: 1.1, 1.3, 2.1, 3.1, 4.1, 6.1, 8.1, 8.4_

---

## Phase 4: Reusable Widget Components


- [x] 5. Create PointBalanceCard widget



  - Create `lib/presentation/widgets/point_balance_card.dart`
  - Display large balance with star/coin icon as focal point
  - Implement shimmer loading state
  - Add error state with retry button
  - Ensure 48x48dp minimum touch targets
  - _Requirements: 1.2, 1.4, 1.5, 9.2_

- [x] 6. Create PointHistoryItem widget





  - Create `lib/presentation/widgets/point_history_item.dart`
  - Display date, amount, description with proper formatting
  - Color-code: green for addition (+), red for deduction (-)
  - Add tap handler for navigation to transaction details
  - Include semantic labels for accessibility
  - _Requirements: 2.2, 2.3, 2.4, 2.5, 9.3_
-

- [x] 7. Create PointStatisticsCard widget




  - Create `lib/presentation/widgets/point_statistics_card.dart`
  - Display 4 metrics in grid layout: total earned, total used, month earned, month used
  - Add loading shimmer state
  - Ensure responsive layout for different screen sizes
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 9.1_

- [x] 8. Create FilterBottomSheet widget





  - Create `lib/presentation/widgets/filter_bottom_sheet.dart`
  - Implement type filter: All, Addition, Deduction
  - Implement period filter: All Time, This Month, Last 3 Months, Last 6 Months
  - Add apply and reset buttons
  - Show active filter count indicator
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_


- [x] 9. Create PointInfoBottomSheet widget



  - Create `lib/presentation/widgets/point_info_bottom_sheet.dart`
  - Explain how to earn points (from parking transactions)
  - Explain how to use points (as payment method)
  - Display point conversion rules (e.g., 100 poin = Rp 1.000)
  - Explain penalty system
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6_

- [x] 10. Create EmptyStateWidget for point history





  - Create `lib/presentation/widgets/point_empty_state.dart`
  - Display "Belum ada riwayat poin" message
  - Add appropriate illustration or icon
  - Include call-to-action text
  - _Requirements: 2.6_

---

## Phase 5: Main Point Page Implementation

- [x] 11. Implement new PointPage screen




  - Create `lib/presentation/screens/point_page.dart` (replace existing)
  - Set up Provider consumer for PointProvider
  - Implement TabBar with Overview and History tabs
  - Add pull-to-refresh functionality
  - Implement auto-sync on page resume (if > 30 seconds)
  - Add floating action button for "Cara Kerja Poin"
  - Handle loading, error, and empty states
  - Implement proper error messages with retry options
  - _Requirements: 1.1, 1.3, 1.4, 2.1, 5.1, 8.1, 8.2, 8.3, 8.4, 8.5, 10.1, 10.2, 10.3, 10.4_

- [x] 12. Implement Overview tab content





  - Display PointBalanceCard at top
  - Display PointStatisticsCard below balance
  - Add "Lihat Riwayat" button to navigate to History tab
  - Ensure responsive layout
  - _Requirements: 1.1, 1.2, 4.1, 9.1_

- [x] 13. Implement History tab content





  - Display filter chips at top
  - Implement scrollable list of PointHistoryItem widgets
  - Add pagination/infinite scroll for large datasets
  - Show empty state when no history matches filter
  - Display active filter indicator
  - Handle tap on history item to show transaction details
  - _Requirements: 2.1, 2.2, 2.5, 2.6, 3.1, 3.5_

---

## Phase 6: Payment Integration
-

- [x] 14. Integrate point usage in payment flow







  - Update payment page to display "Gunakan Poin" option
  - Show current point balance in payment page
  - Implement point amount selector (slider or input)
  - Calculate and display cost reduction based on point conversion
  - Handle insufficient points scenario (use all available, show remaining cost)
  - Handle sufficient points scenario (use only needed amount)
  - Call PointProvider.usePoints() on payment confirmation
  - Update point balance after successful payment
  - Record transaction in riwayat_poin via backend
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6_

---

## Phase 7: Notification System

- [x] 15. Implement point change notifications


































































- [ ] 15. Implement point change notifications

  - Add notification pop-up when points are earned (after parking payment)
  - Add notification pop-up when points are used (after payment with points)
  - Add warning notification for penalty deductions
  - Include "Lihat Detail" button in notifications that opens PointPage
  - Add badge indicator on point page icon when points change
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

---

## Phase 8: Offline Support & Caching
-

- [x] 16. Implement offline data caching

















  - Cache balance, history, and statistics in SharedPreferences
  - Load cached data on app start
  - Display "Data mungkin tidak terkini" indicator when offline
  - Implement cache invalidation strategy
  - Sync cached data with server when connection restored
  - _Requirements: 10.1, 10.2, 10.4_
- [x] 17. Implement comprehensive error handling



- [ ] 17. Implement comprehensive error handling







  - Handle network errors with user-friendly messages
  - Handle timeout errors with retry option
  - Handle backend API errors with appropriate messages
  - Show "Memerlukan koneksi internet" for actions requiring network
  - Log errors for debugging with error codes
  - _Requirements: 1.4, 8.3, 10.2, 10.3, 10.5_

---

## Phase 9: Accessibility & Responsive Design
-

- [x] 18. Implement accessibility features




  - Add semantic labels to all interactive elements
  - Ensure minimum 48x48dp touch targets
  - Implement proper contrast ratios (WCAG AA)
  - Add screen reader support with descriptive labels
  - Test with TalkBack/VoiceOver
  - _Requirements: 9.2, 9.3, 9.4_

- [x] 19. Implement responsive design




  - Test layout on various Android screen sizes
  - Adjust grid layouts for tablets
  - Ensure proper text scaling
  - Test in landscape orientation
  - Add motion reduction support for animations
  - _Requirements: 9.1, 9.5_

---

## Phase 10: Provider Registration & Navigation

- [x] 20. Register PointProvider in app





  - Add PointProvider to MultiProvider in `main.dart`
  - Update navigation routes to include new PointPage
  - Update bottom navigation bar to navigate to PointPage
  - Ensure proper provider disposal
  - _Requirements: 1.1, 1.3_
-

- [x] 21. Update existing point_screen.dart




  - Remove or deprecate old static `lib/pages/point_screen.dart`
  - Update all references to use new `lib/presentation/screens/point_page.dart`
  - Ensure bottom navigation still works correctly
  - _Requirements: 1.1_

---

## Phase 11: Testing & Validation

- [ ]* 22. Write unit tests for models
  - Test PointHistory.fromJson() and toJson()
  - Test PointStatistics calculations
  - Test PointFilter.matches() logic
  - Test edge cases (null values, invalid data)
  - _Requirements: 2.1, 3.1, 4.1_

- [ ]* 23. Write unit tests for PointService
  - Test API call success scenarios
  - Test error handling (network, timeout, server errors)
  - Test pagination logic
  - Test retry mechanism
  - Mock HTTP responses
  - _Requirements: 1.1, 2.1, 4.1, 10.2, 10.3_

- [ ]* 24. Write unit tests for PointProvider
  - Test state management (balance, history, statistics)
  - Test filter application logic
  - Test caching behavior
  - Test auto-sync logic
  - Test error state handling
  - Mock PointService
  - _Requirements: 1.3, 2.1, 3.1, 4.1, 8.4, 10.1_

- [ ]* 25. Write widget tests for point components
  - Test PointBalanceCard rendering and states
  - Test PointHistoryItem color coding and tap handling
  - Test PointStatisticsCard layout
  - Test FilterBottomSheet interactions
  - Test PointInfoBottomSheet content
  - _Requirements: 1.2, 2.2, 2.3, 2.4, 3.1, 4.1, 5.1_

- [ ]* 26. Write integration tests for PointPage
  - Test full page rendering with real provider
  - Test tab switching
  - Test pull-to-refresh
  - Test filter application
  - Test navigation to transaction details
  - Test error recovery flows
















  
  - _Requirements: 1.1, 2.1, 3.1, 8.1, 10.1_

- [ ]* 27. Write integration tests for payment with points
  - Test point selection in payment flow
  - Test cost calculation with points
  - Test successful payment with points
  - Test insufficient points scenario
  - Test point balance update after payment
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6_

---

## Phase 12: Final Polish & Documentation
-

- [x] 28. Checkpoint - Ensure all tests pass



  - Run all unit tests and verify they pass
  - Run all widget tests and verify they pass
  - Run all integration tests and verify they pass
  - Fix any failing tests
  - Ensure code coverage meets standards
  - Ask the user if questions arise



- [x] 29. Performance optimization








  - Profile page load times
  - Optimize list rendering with ListView.builder
  - Implement pagination for large history lists
  - Reduce unnecessary rebuilds
  - Optimize image assets
  - _Requirements: 8.1, 8.5_

- [ ]* 30. Create user documentation
  - Document point earning rules
  - Document point usage process
  - Document filter functionality
  - Create FAQ section
  - Add troubleshooting guide
  - _Requirements: 5.1, 5.2, 5.3, 5
.4, 5.5, 5.6_

- [x] 31. Final integration testing





































- [ ] 31. Final integration testing

  - Test complete user flow: earn points → view history → use points
  - Test offline scenarios
  - Test error recovery
  - Test on multiple devices
  - Verify accessibility compliance
  - Test with real backend API
  - _Requirements: All requirements_

---

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP delivery
- Each task builds incrementally on previous tasks
- Backend API endpoints (Phase 2) can be developed in parallel with Flutter data layer (Phase 1)
- Testing tasks are marked optional but highly recommended for production quality
- All implementations should follow existing QPARKIN code patterns and architecture
