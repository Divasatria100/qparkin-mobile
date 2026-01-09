@echo off
echo ========================================
echo Testing Login Attempts System
echo ========================================
echo.

echo [1/6] Failed Login Attempt 1...
curl -s -X POST http://localhost:8000/signin -d "email=test@example.com&password=wrong1" > nul
echo Done

echo [2/6] Failed Login Attempt 2...
curl -s -X POST http://localhost:8000/signin -d "email=test@example.com&password=wrong2" > nul
echo Done

echo [3/6] Failed Login Attempt 3...
curl -s -X POST http://localhost:8000/signin -d "email=test@example.com&password=wrong3" > nul
echo Done

echo [4/6] Failed Login Attempt 4...
curl -s -X POST http://localhost:8000/signin -d "email=test@example.com&password=wrong4" > nul
echo Done

echo [5/6] Failed Login Attempt 5 - Should Lock Account...
curl -s -X POST http://localhost:8000/signin -d "email=test@example.com&password=wrong5" > nul
echo Done - Account should be LOCKED now

echo [6/6] Try Login While Locked...
curl -s -X POST http://localhost:8000/signin -d "email=test@example.com&password=correct" > nul
echo Done - Should show locked message

echo.
echo ========================================
echo Test Complete!
echo ========================================
echo.
echo Check database to verify:
echo   php artisan tinker
echo   App\Models\LoginAttempt::count();
echo   App\Models\AccountLockout::all();
echo.
pause
