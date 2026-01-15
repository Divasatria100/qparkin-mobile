@echo off
echo ========================================
echo Testing Booking Detail Page
echo ========================================
echo.

echo [1/4] Checking Flutter installation...
flutter --version
if errorlevel 1 (
    echo ERROR: Flutter not found!
    exit /b 1
)
echo.

echo [2/4] Getting dependencies...
cd qparkin_app
call flutter pub get
if errorlevel 1 (
    echo ERROR: Failed to get dependencies!
    exit /b 1
)
echo.

echo [3/4] Running analyzer...
call flutter analyze lib/presentation/screens/booking_detail_page.dart
if errorlevel 1 (
    echo WARNING: Analyzer found issues
)
echo.

echo [4/4] Testing Instructions:
echo ========================================
echo Manual Testing Steps:
echo.
echo 1. Run the app:
echo    flutter run --dart-define=API_URL=http://192.168.x.xx:8000
echo.
echo 2. Login and create a booking
echo.
echo 3. Proceed to payment (Midtrans)
echo.
echo 4. Use test card:
echo    - Card: 4811 1111 1111 1114
echo    - Exp: 01/25
echo    - CVV: 123
echo.
echo 5. Complete payment
echo.
echo 6. Verify:
echo    [x] Auto-redirect to Booking Detail Page
echo    [x] Success header displayed
echo    [x] All booking info shown correctly
echo    [x] "Lihat Parkir Aktif" button works
echo    [x] "Kembali ke Beranda" button works
echo.
echo ========================================
echo.

echo Would you like to run the app now? (Y/N)
set /p choice=
if /i "%choice%"=="Y" (
    echo.
    echo Starting Flutter app...
    echo Press Ctrl+C to stop
    echo.
    flutter run --dart-define=API_URL=http://192.168.1.6:8000
)

cd ..
