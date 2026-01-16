@echo off
echo ========================================
echo Testing Midtrans Integration Setup
echo ========================================
echo.

echo Step 1: Clearing Laravel cache...
php qparkin_backend/artisan config:clear
php qparkin_backend/artisan cache:clear
echo.

echo Step 2: Checking Midtrans configuration...
php qparkin_backend/artisan tinker --execute="echo 'Server Key: ' . config('services.midtrans.server_key') . PHP_EOL; echo 'Client Key: ' . config('services.midtrans.client_key') . PHP_EOL; echo 'Is Production: ' . (config('services.midtrans.is_production') ? 'true' : 'false') . PHP_EOL;"
echo.

echo Step 3: Testing booking endpoint...
curl -X GET "http://localhost:8000/api/bookings/28/payment/snap-token" ^
  -H "Accept: application/json" ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
echo.

echo ========================================
echo Test Complete!
echo ========================================
echo.
echo If you see a snap_token in the response, Midtrans is working!
echo.
pause
