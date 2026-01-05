Periksa IPv4 Address menggunakan ipconfig di cmd

salin addressnya dan tempel di "flutter run --dart-define=API_URL=http://192.168.x.xx:8000" <- pakai IPv4 Address masing-masing

untuk menjalankan laravel, tulis perintah "php artisan serve --host=0.0.0.0 --port=8000"

untuk menjalankan mailpit, tulis perintah "cd C:\mailpit" enter dan tulis "./mailpit.exe" maka akan muncul contoh log berikut:
"time="2026/01/06 00:15:39" level=info msg="[smtpd] starting on [::]:1025 (no encryption)"
time="2026/01/06 00:15:39" level=info msg="[http] starting on [::]:8025"
time="2026/01/06 00:15:39" level=info msg="[http] accessible via http://localhost:8025/""