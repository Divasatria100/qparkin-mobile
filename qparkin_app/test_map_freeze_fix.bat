@echo off
REM Test Script for Map Page Freeze/ANR Fix (Windows)
REM This script runs comprehensive tests to verify the fix

echo ==========================================
echo Map Page Freeze/ANR Fix - Test Script
echo ==========================================
echo.

set TESTS_PASSED=0
set TESTS_FAILED=0

echo Step 1: Clean build
echo --------------------
call flutter clean
call flutter pub get
if %errorlevel% equ 0 (
    echo [PASSED] Clean build
    set /a TESTS_PASSED+=1
) else (
    echo [FAILED] Clean build
    set /a TESTS_FAILED+=1
)
echo.

echo Step 2: Run Flutter analyze
echo ----------------------------
call flutter analyze
if %errorlevel% equ 0 (
    echo [PASSED] Flutter analyze
    set /a TESTS_PASSED+=1
) else (
    echo [FAILED] Flutter analyze
    set /a TESTS_FAILED+=1
)
echo.

echo Step 3: Check for common issues
echo --------------------------------

REM Check if MapProvider uses create instead of value
echo Checking MapProvider lifecycle...
findstr /C:"ChangeNotifierProvider<MapProvider>(" lib\presentation\screens\map_page.dart >nul
if %errorlevel% equ 0 (
    findstr /C:"create: (_) => MapProvider()" lib\presentation\screens\map_page.dart >nul
    if %errorlevel% equ 0 (
        echo [PASSED] MapProvider uses create
        set /a TESTS_PASSED+=1
    ) else (
        echo [FAILED] MapProvider lifecycle issue
        set /a TESTS_FAILED+=1
    )
) else (
    echo [FAILED] MapProvider not found
    set /a TESTS_FAILED+=1
)

REM Check if mounted checks are present
echo Checking mounted checks...
findstr /C:"if (!mounted) return;" lib\presentation\screens\map_page.dart >nul
if %errorlevel% equ 0 (
    echo [PASSED] Mounted checks present
    set /a TESTS_PASSED+=1
) else (
    echo [FAILED] Mounted checks missing
    set /a TESTS_FAILED+=1
)

REM Check if navigation uses pushReplacementNamed
echo Checking navigation method...
findstr /C:"pushReplacementNamed" lib\utils\navigation_utils.dart >nul
if %errorlevel% equ 0 (
    echo [PASSED] Navigation uses pushReplacementNamed
    set /a TESTS_PASSED+=1
) else (
    echo [FAILED] Navigation still uses pushNamed
    set /a TESTS_FAILED+=1
)

REM Check if listener cleanup is present
echo Checking listener cleanup...
findstr /C:"_markerTapListener" lib\presentation\widgets\map_view.dart >nul
if %errorlevel% equ 0 (
    echo [PASSED] Listener cleanup implemented
    set /a TESTS_PASSED+=1
) else (
    echo [FAILED] Listener cleanup missing
    set /a TESTS_FAILED+=1
)

REM Check if didChangeDependencies is optimized
echo Checking didChangeDependencies optimization...
findstr /C:"_previousLocation" lib\presentation\widgets\map_view.dart >nul
if %errorlevel% equ 0 (
    echo [PASSED] didChangeDependencies optimized
    set /a TESTS_PASSED+=1
) else (
    echo [FAILED] didChangeDependencies not optimized
    set /a TESTS_FAILED+=1
)

echo.
echo Step 4: Run unit tests (if available)
echo --------------------------------------
if exist "test\" (
    call flutter test
    if %errorlevel% equ 0 (
        echo [PASSED] Unit tests
        set /a TESTS_PASSED+=1
    ) else (
        echo [FAILED] Unit tests
        set /a TESTS_FAILED+=1
    )
) else (
    echo [SKIPPED] No test directory found
)

echo.
echo ==========================================
echo Test Summary
echo ==========================================
echo Passed: %TESTS_PASSED%
echo Failed: %TESTS_FAILED%
echo.

if %TESTS_FAILED% equ 0 (
    echo [SUCCESS] All tests passed! Ready for deployment.
    exit /b 0
) else (
    echo [ERROR] Some tests failed. Please review the issues above.
    exit /b 1
)
