@echo off
echo ================================
echo   Menjalankan QPARKIN Project
echo ================================

:: Jalankan Laravel Backend
start cmd /k "cd qparkin_backend && php artisan serve"

:: Jalankan Flutter Frontend (web di Chrome)
start cmd /k "cd qparkin_app && flutter run"

echo Semua service sudah dijalankan!
pause
