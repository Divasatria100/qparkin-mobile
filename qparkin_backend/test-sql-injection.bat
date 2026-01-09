@echo off
echo ========================================
echo SQL Injection Security Test
echo ========================================
echo.
echo Testing SQL Injection Detection System
echo This will attempt various SQL injection patterns
echo All attempts will be logged for documentation
echo.
pause
echo.

echo [Test 1] Basic SQL Injection - OR 1=1
curl -X POST http://localhost:8000/signin -d "email=admin@example.com' OR '1'='1&password=test" -v
echo.
echo ----------------------------------------
echo.

echo [Test 2] UNION SELECT Attack
curl -X POST http://localhost:8000/signin -d "email=admin@example.com' UNION SELECT * FROM user--&password=test" -v
echo.
echo ----------------------------------------
echo.

echo [Test 3] Comment Injection
curl -X POST http://localhost:8000/signin -d "email=admin@example.com'--&password=test" -v
echo.
echo ----------------------------------------
echo.

echo [Test 4] DROP TABLE Attack
curl -X POST http://localhost:8000/signin -d "email=admin@example.com'; DROP TABLE user;--&password=test" -v
echo.
echo ----------------------------------------
echo.

echo [Test 5] Time-based Blind SQL Injection
curl -X POST http://localhost:8000/signin -d "email=admin@example.com' AND SLEEP(5)--&password=test" -v
echo.
echo ----------------------------------------
echo.

echo [Test 6] Hex Encoding Attack
curl -X POST http://localhost:8000/signin -d "email=0x61646d696e&password=test" -v
echo.
echo ----------------------------------------
echo.

echo [Test 7] Information Schema Query
curl -X POST http://localhost:8000/signin -d "email=admin@example.com' AND 1=1 UNION SELECT * FROM INFORMATION_SCHEMA.TABLES--&password=test" -v
echo.
echo ----------------------------------------
echo.

echo [Test 8] Multiple SQL Keywords
curl -X POST http://localhost:8000/signin -d "email=admin@example.com' OR 1=1; DELETE FROM user WHERE 1=1--&password=test" -v
echo.
echo ----------------------------------------
echo.

echo.
echo ========================================
echo Test Complete!
echo ========================================
echo.
echo View logs with:
echo   php artisan security:logs
echo   php artisan security:logs --stats
echo.
echo Or check:
echo   storage/logs/security.log
echo.
pause
