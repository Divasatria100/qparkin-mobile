@echo off
echo ========================================
echo Lokasi Mall @yield/@section Fix Verification
echo ========================================
echo.

echo [1/3] Checking Layout File...
findstr /C:"@yield('styles')" qparkin_backend\resources\views\layouts\admin.blade.php >nul
if %errorlevel%==0 (
    echo [OK] Layout uses @yield for styles
) else (
    echo [FAIL] Layout missing @yield for styles
)

findstr /C:"@yield('scripts')" qparkin_backend\resources\views\layouts\admin.blade.php >nul
if %errorlevel%==0 (
    echo [OK] Layout uses @yield for scripts
) else (
    echo [FAIL] Layout missing @yield for scripts
)

findstr /C:"@stack" qparkin_backend\resources\views\layouts\admin.blade.php >nul
if %errorlevel%==0 (
    echo [FAIL] Layout still has @stack directive
) else (
    echo [OK] Layout has no @stack directive
)

echo.
echo [2/3] Checking Lokasi Mall Page...
findstr /C:"@section('styles')" qparkin_backend\resources\views\admin\lokasi-mall.blade.php >nul
if %errorlevel%==0 (
    echo [OK] Page uses @section for styles
) else (
    echo [FAIL] Page missing @section for styles
)

findstr /C:"@section('scripts')" qparkin_backend\resources\views\admin\lokasi-mall.blade.php >nul
if %errorlevel%==0 (
    echo [OK] Page uses @section for scripts
) else (
    echo [FAIL] Page missing @section for scripts
)

findstr /C:"@push" qparkin_backend\resources\views\admin\lokasi-mall.blade.php >nul
if %errorlevel%==0 (
    echo [FAIL] Page still has @push directive
) else (
    echo [OK] Page has no @push directive
)

echo.
echo [3/3] Checking Asset Files...
if exist "qparkin_backend\public\css\lokasi-mall.css" (
    echo [OK] lokasi-mall.css exists
) else (
    echo [FAIL] lokasi-mall.css missing
)

if exist "qparkin_backend\public\js\lokasi-mall.js" (
    echo [OK] lokasi-mall.js exists
) else (
    echo [FAIL] lokasi-mall.js missing
)

echo.
echo ========================================
echo Verification Complete!
echo ========================================
echo.
echo Next Steps:
echo 1. Run: cd qparkin_backend
echo 2. Run: php artisan serve
echo 3. Login as admin mall
echo 4. Navigate to "Lokasi Mall" page
echo 5. Check Console (F12) - should see no errors
echo 6. Check Network tab - all assets should load (200 OK)
echo 7. Map should display with OpenStreetMap tiles
echo.
pause
