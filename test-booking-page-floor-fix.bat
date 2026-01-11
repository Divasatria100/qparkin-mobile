@echo off
REM Test script for Booking Page Floor UI Fix
REM Tests vehicle selection, floor filtering, and cost display logic

echo ========================================
echo Booking Page Floor UI Fix - Test Script
echo ========================================
echo.

echo [TEST 1] Checking booking_page.dart syntax...
cd qparkin_app
call flutter analyze lib/presentation/screens/booking_page.dart
if %ERRORLEVEL% NEQ 0 (
    echo [FAIL] Syntax errors found in booking_page.dart
    exit /b 1
)
echo [PASS] No syntax errors
echo.

echo [TEST 2] Checking booking_provider.dart syntax...
call flutter analyze lib/logic/providers/booking_provider.dart
if %ERRORLEVEL% NEQ 0 (
    echo [FAIL] Syntax errors found in booking_provider.dart
    exit /b 1
)
echo [PASS] No syntax errors
echo.

echo ========================================
echo Manual Testing Checklist:
echo ========================================
echo.
echo [ ] 1. Open booking page without selecting vehicle
echo      Expected: No cost card shown
echo.
echo [ ] 2. Select a "Roda Dua" vehicle
echo      Expected: 
echo        - Floors filtered to show only "Roda Dua" floors
echo        - Slot availability shows correct count
echo        - No "0 slot tersedia" error
echo.
echo [ ] 3. Select duration (e.g., 2 hours)
echo      Expected:
echo        - Cost shown in BookingSummaryCard only
echo        - No duplicate CostBreakdownCard
echo        - Point usage widget appears
echo.
echo [ ] 4. Select a "Roda Empat" vehicle
echo      Expected:
echo        - Floors filtered to show only "Roda Empat" floors
echo        - Slot availability updates correctly
echo.
echo [ ] 5. Select time when slots are full
echo      Expected:
echo        - "Slot parkir penuh" message appears
echo        - Alternative times shown
echo.
echo [ ] 6. Deselect vehicle (if possible)
echo      Expected:
echo        - Cost card disappears
echo        - Point usage widget disappears
echo.
echo ========================================
echo Test completed successfully!
echo ========================================
echo.
echo Next steps:
echo 1. Run the Flutter app: flutter run
echo 2. Navigate to booking page
echo 3. Follow the manual testing checklist above
echo 4. Verify all expected behaviors
echo.

cd ..
pause
