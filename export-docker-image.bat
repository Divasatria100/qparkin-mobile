@echo off
REM Script untuk export Docker image QParkin
REM Untuk Windows

echo ========================================
echo   QParkin Docker Image Export
echo ========================================
echo.

set OUTPUT_DIR=docker_exports
set TIMESTAMP=%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%

echo Creating export directory...
if not exist %OUTPUT_DIR% mkdir %OUTPUT_DIR%
echo.

echo [1/3] Exporting Backend Image...
docker save qparkin_backend:latest -o %OUTPUT_DIR%/qparkin_backend_%TIMESTAMP%.tar
echo Backend image exported: %OUTPUT_DIR%/qparkin_backend_%TIMESTAMP%.tar
echo.

echo [2/3] Exporting MySQL Image...
docker save mysql:8.0 -o %OUTPUT_DIR%/mysql_8.0_%TIMESTAMP%.tar
echo MySQL image exported: %OUTPUT_DIR%/mysql_8.0_%TIMESTAMP%.tar
echo.

echo [3/3] Exporting PHPMyAdmin Image...
docker save phpmyadmin:latest -o %OUTPUT_DIR%/phpmyadmin_%TIMESTAMP%.tar
echo PHPMyAdmin image exported: %OUTPUT_DIR%/phpmyadmin_%TIMESTAMP%.tar
echo.

echo ========================================
echo   Export Complete!
echo ========================================
echo.
echo Exported files location: %OUTPUT_DIR%/
echo.
echo To import on another machine:
echo   docker load -i qparkin_backend_%TIMESTAMP%.tar
echo   docker load -i mysql_8.0_%TIMESTAMP%.tar
echo   docker load -i phpmyadmin_%TIMESTAMP%.tar
echo.
echo Then run: docker-compose up -d
echo.
pause
