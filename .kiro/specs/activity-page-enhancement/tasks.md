# Implementation Plan

- [x] 1. Create data models and state management foundation




  - Create ActiveParkingModel class with all required fields (idTransaksi, qrCode, mall info, vehicle info, time fields, cost fields)
  - Implement duration calculation methods (getElapsedDuration, getRemainingDuration)
  - Implement cost calculation methods (calculateCurrentCost, isPenaltyApplicable)
  - Create TimerState class for managing timer-specific state
  - Implement JSON serialization methods (fromJson, toJson)
  - _Requirements: 1.1, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 3.10_

- [x] 2. Implement ActiveParkingProvider for state management




  - Create ActiveParkingProvider class extending ChangeNotifier
  - Implement fetchActiveParking method to retrieve data from API
  - Implement timer management (start, stop, update) with 1-second intervals
  - Implement real-time cost calculation logic based on elapsed time and tarif_parkir
  - Implement penalty calculation when current time exceeds waktuSelesaiEstimas
  - Implement 30-second periodic background refresh
  - Add proper disposal of timers and resources
  - Handle loading, error, and empty states
  - _Requirements: 1.1, 2.1, 2.2, 3.7, 3.9, 3.10, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 3. Create CircularTimerWidget with animated progress ring




  - Create StatefulWidget for CircularTimerWidget
  - Implement CustomPainter for circular progress rendering
  - Create gradient shader with colors #8D71FA to #3B77DC
  - Implement clockwise progress animation using Canvas.drawArc
  - Display large HH:MM:SS time format in center (48sp, Bold, White)
  - Display label below time ("Durasi Parkir" or "Sisa Waktu Booking")
  - Implement timer update callback to parent
  - Set widget dimensions to 240px diameter with 12px ring thickness
  - Apply white background with subtle shadow
  - Optimize rendering with shouldRepaint logic
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 4. Create BookingDetailCard component




  - Create StatelessWidget for BookingDetailCard
  - Implement layout structure with icon + text rows
  - Display mall location (nama_mall) with location icon
  - Display parking slot (id_parkiran, kodeSlot) with parking icon
  - Display vehicle information (plat, jenis_kendaraan, merk, tipe) with car icon
  - Display waktu_masuk formatted as time string with clock icon
  - Display waktuSelesaiEstimas with timer icon
  - Display real-time calculated parking cost with money icon
  - Display penalty amount highlighted in warning color (orange/red) when applicable
  - Apply white background, 16px rounded corners, subtle shadow
  - Implement 20px padding and 12px row spacing
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 3.10_

- [x] 5. Create QRExitButton component





  - Create StatelessWidget for QRExitButton
  - Implement full-width button with purple gradient background (#573ED1)
  - Add QR code icon on the left side
  - Add "Tampilkan QR Keluar" text in white, 16sp, Bold
  - Set button height to 56px with 12px border radius
  - Apply elevation 4 for shadow effect
  - Implement enabled/disabled states based on active parking existence
  - Add onPressed callback to navigate to QR display screen
  - Implement loading state during QR generation
  - Apply gray background and reduced opacity for disabled state
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 6. Integrate components into ActivityPage





  - Wrap Aktivitas tab content with Consumer<ActiveParkingProvider>
  - Implement conditional rendering: show CircularTimerWidget when active parking exists
  - Position CircularTimerWidget at top as focal point
  - Place BookingDetailCard below timer with 24px spacing
  - Position QRExitButton at bottom with 24px margin
  - Preserve existing AppBar with "Aktivitas & Riwayat" title
  - Preserve existing TabBar with "Aktivitas" and "Riwayat" tabs
  - Maintain existing Riwayat tab content unchanged
  - Apply 24px horizontal and 16px vertical page padding
  - Implement EmptyStateWidget when no active parking exists
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 7. Implement API service integration





  - Create or update ParkingService class in lib/data/services
  - Implement getActiveParking API endpoint call
  - Implement proper error handling with try-catch blocks
  - Parse API response to ActiveParkingModel
  - Handle network errors with user-friendly messages
  - Implement retry mechanism for failed requests
  - Add timeout configuration (10 seconds)
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [x] 8. Implement navigation and QR display





  - Create QRExitDialog or QRExitScreen for displaying exit QR code
  - Implement navigation from QRExitButton to QR display
  - Display QR code from booking.qrCode field
  - Add close/back button on QR display
  - Implement QR code generation if needed
  - Handle QR display errors gracefully
  - _Requirements: 4.2, 4.3_

- [x] 9. Add error handling and edge cases





  - Implement loading state UI with shimmer or progress indicator
  - Implement error state UI with retry button
  - Handle missing or null data fields gracefully
  - Implement network error handling with snackbar notifications
  - Handle booking expiration during active session
  - Implement timer synchronization with server time
  - Add logging for debugging purposes
  - _Requirements: 6.4, 6.5, 6.6, 7.4_

- [x] 10. Optimize performance and lifecycle management





  - Implement proper timer disposal in dispose() method
  - Use ValueNotifier for timer updates to minimize rebuilds
  - Implement CustomPainter caching for gradient shader
  - Optimize shouldRepaint logic in CustomPainter
  - Implement app lifecycle handling (pause/resume)
  - Save timer state to prevent reset on rebuild
  - Test memory usage during extended sessions
  - Verify smooth 60fps animation performance
  - _Requirements: 6.6, 7.5_

- [x] 11. Implement accessibility features




  - Add semantic labels to all icons for screen readers
  - Ensure color contrast meets WCAG AA standards (4.5:1)
  - Set minimum touch target size to 48x48dp for buttons
  - Implement screen reader announcements for timer updates (every minute)
  - Add clear, actionable error messages
  - Test with TalkBack/VoiceOver enabled
  - _Requirements: 1.2, 1.3, 4.1, 4.4_

- [x] 12. Write unit tests for models and logic




  - Write tests for ActiveParkingModel duration calculations
  - Write tests for cost calculation with various tariffs
  - Write tests for penalty calculation logic
  - Write tests for timer accuracy over extended periods
  - Write tests for progress calculation for circular animation
  - Write tests for JSON parsing and serialization
  - Write tests for provider state management
  - _Requirements: 2.1, 2.2, 3.7, 3.9, 3.10_

- [x] 13. Write widget tests for UI components




  - Write tests for CircularTimerWidget display updates
  - Write tests for progress animation rendering
  - Write tests for BookingDetailCard data formatting
  - Write tests for penalty highlighting
  - Write tests for QRExitButton enabled/disabled states
  - Write tests for EmptyStateWidget display
  - Write tests for responsive layout
  - _Requirements: 1.2, 1.3, 2.4, 3.8, 3.10, 4.1, 4.5_

- [x] 14. Write integration tests




  - Write test for full page flow (load data → display timer → tap button)
  - Write test for timer running for 60 seconds
  - Write test for provider state updates propagating to UI
  - Write test for API integration with mock responses
  - Write test for error handling and retry mechanism
  - Write test for 30-second periodic refresh
  - _Requirements: 6.1, 6.2, 6.3, 7.4, 7.5_
