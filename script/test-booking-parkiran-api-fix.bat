@echo off
REM Test script for booking parkiran API fix
REM Tests that id_parkiran is now included in mall API response

echo ========================================
echo Testing Mall API with id_parkiran Field
echo ========================================
echo.

REM Test 1: Get all malls and check for id_parkiran
echo [TEST 1] GET /api/mall - Check id_parkiran in response
curl -X GET "http://192.168.0.101:8000/api/mall" ^
  -H "Accept: application/json" ^
  -H "Content-Type: application/json"
echo.
echo.

REM Test 2: Get specific mall (Panbil Mall - id_mall: 4)
echo [TEST 2] GET /api/mall/4 - Check Panbil Mall id_parkiran
curl -X GET "http://192.168.0.101:8000/api/mall/4" ^
  -H "Accept: application/json" ^
  -H "Content-Type: application/json"
echo.
echo.

REM Test 3: Get Mega Mall Batam Centre (id_mall: 1)
echo [TEST 3] GET /api/mall/1 - Check Mega Mall id_parkiran
curl -X GET "http://192.168.0.101:8000/api/mall/1" ^
  -H "Accept: application/json" ^
  -H "Content-Type: application/json"
echo.
echo.

echo ========================================
echo Test Complete
echo ========================================
echo.
echo Expected Results:
echo - Each mall should have "id_parkiran" field
echo - Panbil Mall (id_mall: 4) should have id_parkiran: 1
echo - Mega Mall (id_mall: 1) should have id_parkiran: 2
echo.
pause
