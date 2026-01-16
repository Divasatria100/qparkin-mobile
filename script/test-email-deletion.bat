@echo off
echo ========================================
echo Testing Email Deletion Feature
echo ========================================
echo.

cd qparkin_backend

echo Step 1: Get user profile before deletion
echo ----------------------------------------
curl -X GET "http://localhost:8000/api/user/profile" ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE" ^
  -H "Accept: application/json"
echo.
echo.

echo Step 2: Delete email (set to null)
echo ----------------------------------------
curl -X PUT "http://localhost:8000/api/user/profile" ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE" ^
  -H "Content-Type: application/json" ^
  -H "Accept: application/json" ^
  -d "{\"name\":\"Test User\",\"email\":null}"
echo.
echo.

echo Step 3: Get user profile after deletion
echo ----------------------------------------
curl -X GET "http://localhost:8000/api/user/profile" ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE" ^
  -H "Accept: application/json"
echo.
echo.

echo ========================================
echo Test Complete
echo ========================================
echo.
echo Instructions:
echo 1. Replace YOUR_TOKEN_HERE with actual auth token
echo 2. Run this script to test email deletion
echo 3. Check that email is null in step 3
echo.
pause
