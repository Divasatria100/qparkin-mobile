# Implementation Plan

## Overview

This implementation plan breaks down the Booking Page enhancements into discrete, manageable tasks. The plan follows a logical sequence: data models → services → state management → UI components → integration → testing.

**Key Change**: This plan implements **Hybrid Slot Reservation** where users select floors and the system automatically assigns specific slots, rather than manual slot selection.

## Task List

- [x] 1. Create data models for slot reservation





  - Create ParkingFloorModel with properties and methods
  - Create ParkingSlotModel for visualization (non-interactive)
  - Create SlotReservationModel for reserved slot data
  - Implement fromJson() and toJson() serialization
  - Add validation methods
  - Write unit tests for models
  - _Requirements: 10.1-10.9_

- [x] 2. Extend BookingService with slot reservation APIs





  - [x] 2.1 Implement getFloors() method

    - Add GET /api/parking/floors/{mallId} endpoint call
    - Parse response to List<ParkingFloorModel>
    - Implement error handling and retry logic
    - _Requirements: 11.1-11.10_
  

  - [x] 2.2 Implement getSlotsForVisualization() method





    - Add GET /api/parking/slots/{floorId}/visualization endpoint call
    - Support vehicle type filtering
    - Parse response to List<ParkingSlotModel> (display-only)
    - Implement caching strategy
    - _Requirements: 11.1-11.10_

  
  - [x] 2.3 Implement reserveRandomSlot() method





    - Add POST /api/parking/slots/reserve-random endpoint call
    - Handle system-assigned slot reservation
    - Parse response to SlotReservationModel
    - Implement timeout handling (5 minutes)
    - _Requirements: 11.1-11.10_
  
  - [x] 2.4 Write service tests






    - Test API calls with mock responses
    - Test error scenarios (no slots available, timeout)
    - Test caching behavior
    - _Requirements: 16.1-16.10_

- [x] 3. Update BookingProvider with slot reservation state




  - [x] 3.1 Add slot reservation state properties


    - Add floors, selectedFloor, slotsVisualization, reservedSlot properties
    - Add loading states for floors, slots, and reservation
    - Add getters for computed properties
    - _Requirements: 12.1-12.11_
  
  - [x] 3.2 Implement floor selection methods


    - Implement fetchFloors() with caching
    - Implement selectFloor() with validation
    - Clear reservation when floor changes
    - _Requirements: 12.1-12.11_
  
  - [x] 3.3 Implement slot visualization methods


    - Implement fetchSlotsForVisualization() with filtering
    - Implement refreshSlotVisualization() with debouncing
    - Update visualization data without user interaction
    - _Requirements: 12.1-12.11_
  
  - [x] 3.4 Implement slot reservation methods


    - Implement reserveRandomSlot() with floor validation
    - Handle system-assigned slot response
    - Implement clearReservation()
    - Add reservation timeout management
    - _Requirements: 12.1-12.11_
  
  - [x] 3.5 Add slot refresh and reservation timers


    - Implement startSlotRefreshTimer() (15s interval)
    - Implement stopSlotRefreshTimer()
    - Implement startReservationTimer() (5 min timeout)
    - Implement stopReservationTimer()
    - _Requirements: 11.10, 14.1-14.10_
  
  - [x] 3.6 Update booking confirmation


    - Validate slot reservation before booking
    - Include reserved slot ID and reservation ID in BookingRequest
    - Handle reservation expiration errors
    - _Requirements: 9.1-9.9, 12.1-12.11_
  
  - [x] 3.7 Write provider tests






    - Test floor selection and slot visualization logic
    - Test slot reservation and timeout handling
    - Test validation and error handling
    - _Requirements: 16.1-16.10_



- [x] 4. Create FloorSelectorWidget






  - [x] 4.1 Build floor card layout

    - Create card with floor number badge
    - Display floor name and availability
    - Add chevron icon for navigation
    - Apply purple accent for selected state
    - _Requirements: 1.1-1.9, 13.1-13.10_
  

  - [x] 4.2 Implement floor selection interaction


    - Handle tap to select floor
    - Disable unavailable floors
    - Provide haptic feedback
    - Announce selection to screen readers
    - _Requirements: 1.1-1.9, 9.1-9.10_

  
  - [x] 4.3 Add loading and error states


    - Show shimmer loading for floors
    - Display error message with retry
    - Handle empty state
    - _Requirements: 15.1-15.9_
  
  - [x] 4.4 Write widget tests





    - Test floor display and selection
    - Test loading and error states
    - Test accessibility features
    - _Requirements: 16.1-16.10_

- [x] 5. Create SlotVisualizationWidget (Non-Interactive)




  - [x] 5.1 Build slot visualization layout


    - Implement GridView with responsive columns
    - Create slot card with status colors (display-only)
    - Display slot code and type icon
    - NO tap/click interaction
    - NO selection state or borders
    - _Requirements: 2.1-2.11, 13.1-13.10_
  
  - [x] 5.2 Add visualization header and controls

    - Display "Ketersediaan Slot" header
    - Show available slots count
    - Add last updated timestamp
    - Add refresh button with loading indicator
    - _Requirements: 2.1-2.11, 14.1-14.10_
  
  - [x] 5.3 Optimize visualization rendering

    - Use ListView.builder for performance
    - Implement lazy loading for large grids
    - Cache rendered visualization
    - _Requirements: 14.1-14.10_
  
  - [x] 5.4 Write widget tests






    - Test slot visualization display
    - Test refresh functionality
    - Verify no interaction capabilities
    - _Requirements: 16.1-16.10_

- [x] 6. Create SlotReservationButton




  - [x] 6.1 Build reservation button layout

    - Create full-width button (56px height)
    - Display "Pesan Slot Acak di [Nama Lantai]" text
    - Add random/casino icon
    - Apply purple background and white text
    - _Requirements: 3.1-3.12, 13.1-13.10_
  

  - [x] 6.2 Implement reservation interaction
    - Handle tap to trigger random slot reservation
    - Show loading indicator during reservation
    - Provide haptic feedback
    - Announce reservation status to screen readers
    - _Requirements: 3.1-3.12, 9.1-9.10_

  
  - [x] 6.3 Add button states

    - Enabled: Purple background, white text
    - Loading: Purple background, CircularProgressIndicator
    - Disabled: Grey background, grey text
    - _Requirements: 3.1-3.12_
  
  - [x] 6.4 Write widget tests






    - Test button display and interaction
    - Test loading and disabled states
    - Test accessibility features
    - _Requirements: 16.1-16.10_

- [x] 7. Create ReservedSlotInfoCard




  - [x] 7.1 Build reserved slot display


    - Create card with reserved slot details
    - Display slot code and floor name
    - Show slot type and expiration time
    - Add success checkmark icon
    - _Requirements: 3.1-3.12, 13.1-13.10_
  
  - [x] 7.2 Add slide-up animation

    - Implement AnimatedContainer
    - Slide up from bottom (300ms)
    - Scale in effect (1.0 to 1.05 to 1.0)
    - _Requirements: 13.1-13.10_
  
  - [x] 7.3 Write widget tests




    - Test reserved slot info display
    - Test animation
    - Test expiration countdown
    - _Requirements: 16.1-16.10_



- [x] 8. Create UnifiedTimeDurationCard



  - [x] 8.1 Build unified card layout

    - Create single card container
    - Add "Waktu & Durasi Booking" header
    - Organize sections with dividers
    - Apply consistent spacing and padding
    - _Requirements: 4.1-4.9, 13.1-13.10_
  

  - [x] 8.2 Implement date & time section
    - Display current date in readable format
    - Display current time prominently
    - Add calendar icon
    - Handle tap to open date picker
    - _Requirements: 5.1-5.11_

  
  - [x] 8.3 Implement enhanced date picker
    - Open Material DatePicker with purple theme
    - Validate date selection (not past, max 7 days)
    - Auto-open TimePicker after date selection
    - Default to current time + 15 minutes
    - Add "Sekarang + 15 menit" quick action

    - _Requirements: 5.1-5.11_
  
  - [x] 8.4 Create large duration chips
    - Build DurationChip component (80x56px)
    - Implement preset durations (1h, 2h, 3h, 4h, >4h)
    - Add checkmark icon to selected chip
    - Apply purple background for selected
    - Implement scale animation on tap
    - Provide haptic feedback

    - _Requirements: 6.1-6.13_
  
  - [x] 8.5 Implement custom duration dialog
    - Create dialog with hour/minute pickers
    - Validate minimum 30 minutes

    - Display total duration preview
    - _Requirements: 6.1-6.13_
  
  - [x] 8.6 Build calculated end time display
    - Create light purple container
    - Display end time with clock icon
    - Show duration summary
    - Animate changes (200ms fade)
    - _Requirements: 7.1-7.9_
  

  - [x] 8.7 Implement responsive layout

    - Adapt padding for screen sizes
    - Stack chips vertically on small screens
    - Maintain 48dp touch targets
    - Support 200% font scaling
    - _Requirements: 8.1-8.8_
  
  - [x] 8.8 Write widget tests






    - Test date/time selection
    - Test duration chip selection
    - Test custom duration dialog
    - Test end time calculation
    - Test responsive behavior
    - _Requirements: 16.1-16.10_

- [x] 9. Update BookingPage with slot reservation





  - [x] 9.1 Add slot reservation section

    - Insert FloorSelectorWidget after VehicleSelector
    - Show SlotVisualizationWidget when floor selected
    - Display SlotReservationButton below visualization
    - Show ReservedSlotInfoCard when slot reserved
    - Add section header and spacing
    - _Requirements: 3.1-3.12_
  

  - [x] 9.2 Replace TimeDurationPicker

    - Remove old TimeDurationPicker widget
    - Add UnifiedTimeDurationCard
    - Update callback handlers
    - Maintain state consistency
    - _Requirements: 4.1-4.9_
  

  - [x] 9.3 Update BookingSummaryCard

    - Add reserved slot information display
    - Show floor and slot code
    - Display slot type and expiration
    - _Requirements: 3.1-3.12_
  

  - [x] 9.4 Update validation logic

    - Require slot reservation before confirmation
    - Update canConfirmBooking getter
    - Check reservation expiration
    - Add slot validation error messages
    - _Requirements: 3.1-3.12, 15.1-15.10_
  

  - [x] 9.5 Handle reservation errors

    - Show error when no slots available
    - Suggest alternative floors
    - Handle reservation timeout
    - Auto-refresh slot status
    - _Requirements: 15.1-15.10_
  
  - [x] 9.6 Write integration tests





    - Test complete slot reservation flow
    - Test time/duration selection flow
    - Test booking with reserved slot
    - _Requirements: 16.1-16.10_



- [x] 10. Update BookingConfirmationDialog



  - [x] 10.1 Add reserved slot information display


    - Show reserved slot in confirmation
    - Display floor and slot code
    - Include slot location in QR code data
    - Show reservation details
    - _Requirements: 3.1-3.12_
  
  - [x] 10.2 Write dialog tests






    - Test reserved slot info display
    - Test QR code with slot data
    - _Requirements: 16.1-16.10_

- [x] 11. Implement accessibility features




  - [x] 11.1 Add semantic labels


    - Label all floor and slot elements
    - Announce availability status
    - Provide hints for interactions
    - _Requirements: 9.1-9.10_
  
  - [x] 11.2 Implement keyboard navigation


    - Support arrow keys in slot grid
    - Tab navigation through floors
    - Enter key to select
    - _Requirements: 9.1-9.10_
  
  - [x] 11.3 Add focus indicators


    - Purple 2px border for focused elements
    - Clear visual feedback
    - Maintain 48dp touch targets
    - _Requirements: 9.1-9.10_
  
  - [x] 11.4 Ensure color contrast


    - Verify 4.5:1 minimum contrast
    - Add text labels for color-coded status
    - Test with accessibility tools
    - _Requirements: 9.1-9.10_
  
  - [x] 11.5 Test with screen readers




    - Test VoiceOver/TalkBack navigation
    - Verify announcements
    - Test focus order
    - _Requirements: 16.1-16.10_

- [-] 12. Implement error handling




  - [x] 12.1 Add floor loading errors




    - Display "Gagal memuat data lantai"
    - Provide retry button
    - Log errors for debugging
    - _Requirements: 15.1-15.10_
  
  - [x] 12.2 Add slot visualization loading errors




    - Display "Gagal memuat tampilan slot"
    - Provide retry button
    - Handle network timeouts
    - _Requirements: 15.1-15.10_
  
  - [x] 12.3 Handle no slots available




    - Notify when no slots available for reservation
    - Suggest alternative floors
    - Provide clear guidance
    - _Requirements: 15.1-15.10_
  
  - [ ] 12.4 Add reservation errors
    - Handle reservation failure
    - Handle reservation timeout (5 min)
    - Provide clear error messages
    - Allow retry or floor change
    - _Requirements: 15.1-15.10_
  
  - [ ]* 12.5 Test error scenarios
    - Test network failures
    - Test no slots available
    - Test timeout handling
    - _Requirements: 16.1-16.10_

- [ ] 13. Optimize performance
  - [ ] 13.1 Implement caching
    - Cache floor data (5 minutes)
    - Cache slot data (2 minutes)
    - Clear expired cache
    - _Requirements: 14.1-14.10_
  
  - [ ] 13.2 Add lazy loading
    - Load slots only when floor selected
    - Use ListView.builder for grids
    - Implement pagination if needed
    - _Requirements: 14.1-14.10_
  
  - [ ] 13.3 Implement debouncing
    - Debounce slot refresh (500ms)
    - Debounce search/filter (300ms)
    - Cancel pending requests
    - _Requirements: 14.1-14.10_
  
  - [ ] 13.4 Add loading placeholders
    - Shimmer loading for floors
    - Shimmer loading for slots
    - Skeleton screens
    - _Requirements: 14.1-14.10_
  
  - [ ]* 13.5 Performance testing
    - Test load times
    - Test scroll performance
    - Profile memory usage
    - _Requirements: 16.1-16.10_



- [ ] 14. Update documentation
  - [ ] 14.1 Update booking_api_documentation.md
    - Document new slot reservation endpoints
    - Add request/response examples for random reservation
    - Document error codes
    - _Requirements: 17.1-17.9_
  
  - [ ] 14.2 Update booking_user_guide.md
    - Add slot reservation instructions
    - Add screenshots of new UI
    - Document time/duration improvements
    - Explain random slot assignment process
    - _Requirements: 17.1-17.9_
  
  - [ ] 14.3 Update booking_component_guide.md
    - Document new widgets
    - Add usage examples
    - Document props and callbacks
    - _Requirements: 17.1-17.9_
  
  - [ ] 14.4 Create migration guide
    - Document database changes
    - Provide migration scripts
    - Document backward compatibility
    - _Requirements: 17.1-17.9_

- [ ] 15. Database migration
  - [ ] 15.1 Add slot_id and reservation_id columns
    - Add booking.id_slot (nullable)
    - Add booking.reservation_id (nullable)
    - Add transaksi_parkir.id_slot (nullable)
    - Create foreign key constraints
    - _Requirements: 17.1-17.9_
  
  - [ ] 15.2 Create migration script
    - Write SQL migration script
    - Test on development database
    - Document rollback procedure
    - _Requirements: 17.1-17.9_
  
  - [ ] 15.3 Update backend API
    - Support optional slot_id and reservation_id in booking request
    - Implement random slot reservation logic
    - Handle auto-assignment fallback
    - _Requirements: 17.1-17.9_

- [ ] 16. Feature flag implementation
  - [ ] 16.1 Add mall-level feature flag
    - Add has_slot_reservation_enabled to mall table
    - Implement feature flag check in app
    - Default to false for gradual rollout
    - _Requirements: 17.1-17.9_
  
  - [ ] 16.2 Conditional UI rendering
    - Show slot reservation if enabled
    - Use auto-assignment if disabled
    - Maintain consistent UX
    - _Requirements: 17.1-17.9_

- [ ] 17. End-to-end testing
  - [ ]* 17.1 Test complete booking flow
    - Test with slot selection
    - Test without slot selection
    - Test error scenarios
    - _Requirements: 16.1-16.10_
  
  - [ ]* 17.2 Test on different devices
    - Test on small screens (320px)
    - Test on large screens (768px)
    - Test in landscape orientation
    - _Requirements: 8.1-8.8, 16.1-16.10_
  
  - [ ]* 17.3 Accessibility testing
    - Test with VoiceOver/TalkBack
    - Test keyboard navigation
    - Test color contrast
    - _Requirements: 9.1-9.10, 16.1-16.10_
  
  - [ ]* 17.4 Performance testing
    - Measure load times
    - Test with slow network
    - Profile memory usage
    - _Requirements: 14.1-14.10, 16.1-16.10_

## Notes

- Tasks marked with `*` are optional testing tasks that can be skipped for MVP
- Each task includes requirement references for traceability
- Sub-tasks should be completed before marking parent task as complete
- Integration tests should be run after completing related feature groups
- Documentation should be updated incrementally as features are implemented

