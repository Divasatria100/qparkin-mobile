@echo off
echo ========================================
echo Testing Lokasi Mall Map Display
echo ========================================
echo.

echo [1] Checking if CSS file exists...
if exist "qparkin_backend\public\css\lokasi-mall.css" (
    echo    ✓ CSS file found
) else (
    echo    ✗ CSS file NOT found
    echo    Creating CSS file...
)

echo.
echo [2] Checking if view file exists...
if exist "qparkin_backend\resources\views\admin\lokasi-mall.blade.php" (
    echo    ✓ View file found
) else (
    echo    ✗ View file NOT found
)

echo.
echo [3] Starting Laravel server...
echo    Server will start at http://localhost:8000
echo.
echo [4] Open browser and navigate to:
echo    http://localhost:8000/admin/lokasi-mall
echo.
echo [5] Login credentials:
echo    Email: admin@qparkin.com
echo    Password: password
echo.
echo [6] Check browser console (F12) for:
echo    - "Initializing map..."
echo    - "Map initialized successfully"
echo    - "Tiles added successfully"
echo.
echo [7] Verify map display:
echo    - Map tiles should load
echo    - Can zoom in/out
echo    - Can click to add marker
echo    - Coordinates update when clicking
echo.
echo ========================================
echo Starting server...
echo ========================================
echo.

cd qparkin_backend
php artisan serve

pause
