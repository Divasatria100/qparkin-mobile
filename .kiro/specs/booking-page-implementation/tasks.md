# Implementation Plan

## Overview

This implementation plan breaks down the Booking Page feature into discrete, manageable tasks that build incrementally. Each task is designed to be implemented and tested independently while contributing to the complete booking flow.

## Task List

- [x] 1. Set up project structure and core data models





  - Create directory structure for booking feature components
  - Define BookingModel, BookingRequest, and BookingResponse classes
  - Implement JSON serialization/deserialization methods
  - Add validation methods to models
  - _Requirements: 15.1, 15.2, 15.3_

- [x] 2. Implement BookingService for API communication





  - [x] 2.1 Create BookingService class with HTTP client integration


    - Implement createBooking() method with error handling
    - Implement checkSlotAvailability() method
    - Implement retry logic for network failures
    - Add request/response logging for debugging
    - _Requirements: 9.1-9.9, 15.4_

  - [x] 2.2 Write unit tests for BookingService






    - Test successful booking creation
    - Test network error handling
    - Test slot availability checks
    - Test retry logic
    - _Requirements: 15.10_

- [x] 3. Implement CostCalculator utility






  - [x] 3.1 Create CostCalculator class with tariff-based calculations

    - Implement estimateCost() method using first hour + additional hours formula
    - Implement formatCurrency() method with thousand separators
    - Add cost breakdown generation method
    - Handle edge cases (0 hours, fractional hours)
    - _Requirements: 6.1-6.7_

  - [x] 3.2 Write unit tests for CostCalculator






    - Test first hour calculation
    - Test additional hours calculation
    - Test different vehicle types
    - Test edge cases
    - _Requirements: 15.10_

- [x] 4. Implement BookingValidator utility




  - [x] 4.1 Create BookingValidator class with input validation


    - Implement validateStartTime() method (past/future checks)
    - Implement validateDuration() method (min/max checks)
    - Implement validateVehicle() method
    - Add comprehensive error messages
    - _Requirements: 4.9, 11.3_

  - [x] 4.2 Write unit tests for BookingValidator






    - Test start time validation scenarios
    - Test duration validation scenarios
    - Test vehicle validation
    - _Requirements: 15.10_

- [x] 5. Implement BookingProvider for state management




  - [x] 5.1 Create BookingProvider class extending ChangeNotifier


    - Implement state properties (mall, vehicle, time, duration, cost, etc.)
    - Implement initialize() method to set mall data
    - Implement selectVehicle() method with validation
    - Implement setStartTime() and setDuration() methods
    - Implement calculateCost() method using CostCalculator
    - _Requirements: 15.1, 15.8_

  - [x] 5.2 Implement booking creation logic in provider


    - Implement confirmBooking() method calling BookingService
    - Add loading state management
    - Add error handling with user-friendly messages
    - Implement success callback for navigation
    - _Requirements: 9.1-9.9, 11.1-11.7_

  - [x] 5.3 Implement real-time slot availability checking


    - Add Timer for periodic availability checks (30s interval)
    - Implement checkAvailability() method
    - Update availableSlots state on changes
    - Dispose timer properly in dispose() method
    - _Requirements: 5.1-5.7, 15.7_

  - [x] 5.4 Write unit tests for BookingProvider





    - Test state initialization
    - Test vehicle selection
    - Test time/duration changes
    - Test cost calculation
    - Test booking creation success/failure
    - _Requirements: 15.10_



- [x] 6. Create reusable widget components





  - [x] 6.1 Implement MallInfoCard widget


    - Create stateless widget displaying mall details
    - Add mall name, address, distance display
    - Add available slots indicator with color coding
    - Apply card styling (white background, rounded corners, shadow)
    - _Requirements: 2.1-2.7, 12.1-12.9_


  - [x] 6.2 Implement VehicleSelector widget

    - Create stateful widget with dropdown functionality
    - Fetch vehicles using existing VehicleService
    - Display vehicle cards with icons, plat, jenis, merk
    - Implement empty state with "Tambah Kendaraan" button
    - Add purple border on focus
    - _Requirements: 3.1-3.7, 12.1-12.9_

  - [x] 6.3 Implement TimeDurationPicker widget


    - Create stateful widget with two-column layout
    - Add date/time picker for start time
    - Add duration selector with preset chips (1h, 2h, 3h, 4h, Custom)
    - Display calculated end time with purple background
    - Implement custom duration picker dialog
    - _Requirements: 4.1-4.9, 12.1-12.9_

  - [x] 6.4 Implement SlotAvailabilityIndicator widget


    - Create stateful widget with real-time updates
    - Display slot count with color-coded status (green/yellow/red)
    - Add refresh icon for manual refresh
    - Implement shimmer loading during refresh
    - _Requirements: 5.1-5.7, 12.1-12.9_

  - [x] 6.5 Implement CostBreakdownCard widget


    - Create stateless widget displaying pricing details
    - Show first hour rate and additional hours breakdown
    - Display total cost with purple emphasis
    - Add info box explaining final cost calculation
    - Implement animated number changes
    - _Requirements: 6.1-6.7, 12.1-12.9_

  - [x] 6.6 Implement BookingSummaryCard widget


    - Create stateless widget with purple border
    - Display all booking details in organized sections
    - Show location, vehicle, time, and cost information
    - Use dividers between sections
    - Apply elevation 4 for emphasis
    - _Requirements: 7.1-7.7, 12.1-12.9_

  - [x] 6.7 Write widget tests for all components





    - Test MallInfoCard rendering
    - Test VehicleSelector interactions
    - Test TimeDurationPicker functionality
    - Test SlotAvailabilityIndicator updates
    - Test CostBreakdownCard calculations
    - Test BookingSummaryCard data display
    - _Requirements: 15.11_

- [x] 7. Implement BookingPage main screen


  - [x] 7.1 Create BookingPage stateful widget with scaffold


    - Set up AppBar with back button and "Booking Parkir" title
    - Implement ScrollView for content area
    - Add fixed bottom button container
    - Apply purple theme to AppBar
    - _Requirements: 1.1-1.5, 12.1-12.9_

  - [x] 7.2 Integrate all widget components in BookingPage

    - Add MallInfoCard at top
    - Add VehicleSelector below mall info
    - Add TimeDurationPicker for time selection
    - Add SlotAvailabilityIndicator for real-time status
    - Add CostBreakdownCard for pricing
    - Add BookingSummaryCard for final review
    - Apply consistent spacing (16-24px) between components
    - _Requirements: 2.1-7.7, 12.1-12.9_


  - [x] 7.3 Implement "Konfirmasi Booking" button
    - Create fixed bottom button with purple gradient
    - Set minimum height to 56dp for accessibility
    - Implement enable/disable logic based on form validation
    - Add loading indicator during booking creation
    - Apply shadow effect for prominence
    - _Requirements: 8.1-8.7, 14.1-14.8_

  - [x] 7.4 Implement form validation and error handling

    - Validate all inputs before enabling confirm button
    - Display inline errors for invalid fields
    - Show Snackbar for network/server errors
    - Implement retry logic for failed bookings
    - _Requirements: 11.1-11.7_


  - [x] 7.5 Connect BookingPage to BookingProvider


    - Wrap page with ChangeNotifierProvider
    - Use Consumer widgets for reactive updates
    - Implement provider method calls on user actions
    - Handle loading and error states from provider
    - _Requirements: 15.8_

  - [x] 7.6 Write widget tests for BookingPage





    - Test initial render with mall data
    - Test form field interactions
    - Test button enable/disable states
    - Test loading states
    - Test error states
    - _Requirements: 15.11_



- [x] 8. Implement BookingConfirmationDialog





  - [x] 8.1 Create full-screen dialog with success animation


    - Implement Lottie success checkmark animation
    - Display "Booking Berhasil!" message with green color
    - Show booking ID prominently
    - Add transparent AppBar with close button
    - _Requirements: 10.1-10.3_

  - [x] 8.2 Display QR code and booking details

    - Generate and display QR code (200x200px)
    - Show compact booking summary
    - Add "Tunjukkan di gerbang masuk" instruction
    - Apply card styling for QR container
    - _Requirements: 10.4_

  - [x] 8.3 Implement navigation action buttons

    - Add "Lihat Aktivitas" button navigating to Activity Page
    - Add "Kembali ke Beranda" button navigating to Home
    - Position buttons at bottom with proper spacing
    - Apply purple gradient to primary button
    - _Requirements: 10.5-10.6_

  - [x] 8.4 Write widget tests for confirmation dialog





    - Test dialog display with booking data
    - Test QR code rendering
    - Test navigation button actions
    - _Requirements: 15.11_

- [x] 9. Implement navigation integration






  - [x] 9.1 Update MapPage to navigate to BookingPage

    - Modify _navigateToBooking() method to push BookingPage
    - Pass selected mall data as constructor parameter
    - Add page transition animation
    - _Requirements: 1.1-1.5_

  - [x] 9.2 Implement Activity Page integration


    - Trigger ActiveParkingProvider.fetchActiveParking() after booking
    - Navigate to Activity Page with initialTab: 0
    - Ensure new booking displays immediately
    - _Requirements: 10.8_

  - [x] 9.3 Implement History integration


    - Verify booking appears in history after completion
    - Ensure status updates correctly
    - Test history page display
    - _Requirements: 10.9_

  - [x] 9.4 Write integration tests for navigation flow







    - Test Map → Booking navigation
    - Test Booking → Activity navigation
    - Test booking display in Activity Page
    - Test booking display in History
    - _Requirements: 15.11_

- [x] 10. Implement performance optimizations




  - [x] 10.1 Add caching for frequently accessed data


    - Cache mall data from navigation
    - Cache vehicle list for session
    - Cache tariff data to reduce API calls
    - Implement cache expiration logic
    - _Requirements: 13.3_

  - [x] 10.2 Implement debouncing for user inputs


    - Debounce duration changes (300ms) before cost recalculation
    - Debounce slot availability checks (500ms) after time changes
    - Prevent excessive API calls
    - _Requirements: 13.4_

  - [x] 10.3 Add shimmer loading placeholders


    - Implement shimmer for vehicle list loading
    - Implement shimmer for slot availability loading
    - Implement shimmer for cost calculation loading
    - Use consistent shimmer animation (1500ms)
    - _Requirements: 13.2_

  - [x] 10.4 Optimize memory management


    - Dispose timers in dispose() method
    - Cancel pending API calls on page exit
    - Clear large objects when not needed
    - Implement proper controller disposal
    - _Requirements: 15.7_

  - [x] 10.5 Write performance tests





    - Test page load time (< 2 seconds)
    - Test scroll performance (60fps)
    - Test memory usage
    - Test API call frequency
    - _Requirements: 13.1, 13.8_



- [x] 11. Implement accessibility features



  - [x] 11.1 Add semantic labels and screen reader support


    - Add Semantics widgets to all interactive elements
    - Provide meaningful labels for icons and buttons
    - Implement proper focus order
    - Announce state changes to screen readers
    - _Requirements: 14.1_

  - [x] 11.2 Ensure visual accessibility compliance


    - Verify 4.5:1 contrast ratio for all text
    - Use icons + text for status indicators (not color alone)
    - Test font scaling up to 200%
    - Add clear visual focus indicators
    - _Requirements: 14.2, 14.6_

  - [x] 11.3 Implement motor accessibility features


    - Ensure all touch targets are minimum 48dp
    - Add adequate spacing between interactive elements (8dp+)
    - Test with alternative input methods
    - Remove time-based interaction requirements
    - _Requirements: 14.3, 14.8_

  - [x] 11.4 Write accessibility tests






    - Test screen reader navigation
    - Test contrast ratios
    - Test touch target sizes
    - Test font scaling
    - _Requirements: 14.1-14.8_

- [x] 12. Implement error handling and edge cases





  - [x] 12.1 Handle network errors gracefully

    - Display user-friendly error messages
    - Provide retry buttons for recoverable errors
    - Implement exponential backoff for retries
    - Show offline indicator when network unavailable
    - _Requirements: 11.1_


  - [x] 12.2 Handle slot unavailability scenarios

    - Detect when slots become unavailable during booking
    - Suggest alternative time slots
    - Display clear unavailability message
    - Allow user to modify time/duration
    - _Requirements: 11.2_


  - [x] 12.3 Handle validation errors

    - Highlight invalid fields with red border
    - Display error text below invalid fields
    - Prevent form submission when invalid
    - Clear errors when user corrects input
    - _Requirements: 11.3_



  - [x] 12.4 Handle booking conflicts




    - Detect existing active bookings
    - Display conflict message with option to view existing booking
    - Prevent duplicate bookings
    - _Requirements: 11.6_

  - [x] 12.5 Write tests for error scenarios




    - Test network error handling
    - Test slot unavailability handling
    - Test validation error display
    - Test booking conflict handling
    - _Requirements: 15.11_

- [x] 13. Implement responsive design





  - [x] 13.1 Add responsive layout adaptations


    - Implement breakpoint-based padding adjustments
    - Adjust font sizes for different screen sizes
    - Optimize card spacing for small screens
    - Test on multiple device sizes (320px - 768px)
    - _Requirements: 13.7_

  - [x] 13.2 Handle orientation changes


    - Preserve form data on orientation change
    - Adjust layout for landscape mode
    - Test rotation without data loss
    - _Requirements: 13.6_

  - [x] 13.3 Write responsive design tests




    - Test on small screens (320px)
    - Test on medium screens (375px)
    - Test on large screens (414px+)
    - Test orientation changes
    - _Requirements: 13.7_

- [x] 14. Final integration and testing




  - [x] 14.1 Perform end-to-end integration testing


    - Test complete booking flow from Map to Activity
    - Test all success scenarios
    - Test all error scenarios
    - Verify data persistence across pages
    - _Requirements: All requirements_

  - [x] 14.2 Conduct user acceptance testing

    - Test with real users for usability feedback
    - Identify and fix UX issues
    - Verify all requirements are met
    - Document any deviations or improvements
    - _Requirements: All requirements_

  - [x] 14.3 Perform code review and refactoring


    - Review code for best practices compliance
    - Refactor duplicated code
    - Optimize performance bottlenecks
    - Add missing documentation
    - _Requirements: 15.11, 15.12_

  - [x] 14.4 Update documentation


    - Document API endpoints and request/response formats
    - Document component usage and props
    - Add inline code comments for complex logic
    - Create user guide for booking feature
    - _Requirements: 15.12_

## Notes

- All tasks marked with `*` are optional testing tasks that can be skipped for MVP but are recommended for production quality
- Tasks should be implemented in order as they build upon each other
- Each task should be tested independently before moving to the next
- Integration tests should be performed after completing related task groups
- Performance optimizations can be implemented incrementally throughout development

