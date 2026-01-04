# 🐳 Panduan Docker untuk Aplikasi QParkin PBL

## 📋 Identifikasi Aplikasi

### 1. Jenis Aplikasi dan Platform
Aplikasi QParkin terdiri dari **2 komponen utama**:

- **Backend API (Laravel)**: Web-based REST API
  - Platform: Server-side
  - Fungsi: Menyediakan API untuk mobile app, admin dashboard web
  
- **Mobile App (Flutter)**: Cross-platform mobile application
  - Platform: Android, iOS
  - Fungsi: Aplikasi mobile untuk pengguna akhir

### 2. Teknologi yang Digunakan

#### Backend (qparkin_backend)
- **Bahasa**: PHP 8.2
- **Framework**: Laravel 12
- **Database**: MySQL 8.0
- **Authentication**: Laravel Passport (OAuth2), Sanctum
- **Dependencies Utama**:
  - Google API Client (Google Sign-In)
  - SimpleSoftwareIO QR Code Generator
  - Maatwebsite Excel (Export data)
  - Laravel Socialite

#### Mobile App (qparkin_app)
- **Bahasa**: Dart
- **Framework**: Flutter 3.0+
- **Dependencies Utama**:
  - HTTP client untuk API calls
  - Google Sign-In
  - QR Scanner & Generator
  - OSM Maps (OpenStreetMap)
  - Secure Storage
  - Provider (State Management)

### 3. Services yang Dibutuhkan untuk Docker

Berdasarkan analisis, aplikasi membutuhkan **3 services utama**:

1. **MySQL Database** (Port 3307)
   - Menyimpan data aplikasi
   - Persistent storage dengan volume

2. **Laravel Backend API** (Port 8000)
   - REST API server
   - Terhubung ke MySQL
   - Menjalankan queue workers

3. **PHPMyAdmin** (Port 8080) - Opsional
   - Web interface untuk manajemen database
   - Berguna untuk development dan debugging

**Catatan**: Flutter app **tidak perlu** di-dockerize karena:
- Mobile app di-build menjadi APK/IPA untuk instalasi di device
- Development Flutter dilakukan langsung di host machine
- Flutter hanya perlu terhubung ke Backend API

---

## 🚀 Cara Menjalankan Aplikasi dengan Docker

### Prasyarat
Pastikan sudah terinstall:
- Docker Desktop (Windows/Mac) atau Docker Engine (Linux)
- Docker Compose
- Git (untuk clone repository)

### Langkah 1: Persiapan File Environment

Sebelum menjalankan Docker, pastikan file `.env` di backend sudah dikonfigurasi:

```bash
# Edit file qparkin_backend/.env
# Sesuaikan konfigurasi database dengan Docker:

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=qparkin
DB_USERNAME=qparkin_user
DB_PASSWORD=qparkin_password
```

### Langkah 2: Build dan Jalankan Container

Buka terminal/command prompt di root folder project, lalu jalankan:

```bash
# Build images dan start semua services
docker-compose up -d --build
```

**Penjelasan perintah**:
- `up`: Membuat dan menjalankan container
- `-d`: Detached mode (berjalan di background)
- `--build`: Build ulang image jika ada perubahan

### Langkah 3: Cek Status Container

```bash
# Lihat status semua container
docker-compose ps

# Lihat logs jika ada error
docker-compose logs backend
docker-compose logs mysql
```

### Langkah 4: Setup Database (Pertama Kali)

Jika database belum ter-setup, jalankan migrasi:

```bash
# Masuk ke container backend
docker-compose exec backend bash

# Jalankan migrasi
php artisan migrate --seed

# Generate Passport keys
php artisan passport:install

# Keluar dari container
exit
```

---

## ✅ Cara Uji Coba Aplikasi Berhasil Berjalan

### 1. Cek Backend API

**Test 1: Health Check**
```bash
# Buka browser atau gunakan curl
curl http://localhost:8000/api/health

# Atau buka di browser:
http://localhost:8000
```

**Test 2: Test API Endpoint**
```bash
# Test endpoint login (contoh)
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'
```

**Test 3: Akses Admin Dashboard**
```
http://localhost:8000/admin
```

### 2. Cek Database

**Opsi A: Menggunakan PHPMyAdmin**
```
1. Buka browser: http://localhost:8080
2. Login dengan:
   - Server: mysql
   - Username: qparkin_user
   - Password: qparkin_password
3. Pilih database "qparkin"
4. Cek apakah tabel sudah terbuat
```

**Opsi B: Menggunakan MySQL CLI**
```bash
# Masuk ke container MySQL
docker-compose exec mysql mysql -u qparkin_user -p

# Masukkan password: qparkin_password

# Cek database
SHOW DATABASES;
USE qparkin;
SHOW TABLES;
SELECT * FROM users LIMIT 5;
```

### 3. Cek Logs Container

```bash
# Lihat logs real-time
docker-compose logs -f backend

# Lihat logs MySQL
docker-compose logs -f mysql

# Lihat semua logs
docker-compose logs
```

### 4. Test dari Flutter App

Edit file Flutter untuk connect ke Docker backend:

```dart
// qparkin_app/lib/config/constants.dart
const String API_URL = 'http://192.168.x.x:8000'; // Ganti dengan IP host
```

Lalu jalankan Flutter app:
```bash
cd qparkin_app
flutter run --dart-define=API_URL=http://192.168.x.x:8000
```

**Catatan**: Ganti `192.168.x.x` dengan IP address komputer Anda (bukan localhost karena emulator/device berbeda network).

---

## 📦 Cara Export Docker Image

### Metode 1: Export Image untuk Distribusi

**Export Backend Image**:
```bash
# Build image terlebih dahulu
docker-compose build backend

# Export ke file .tar
docker save qparkin_backend:latest -o qparkin_backend_image.tar

# Compress untuk ukuran lebih kecil
gzip qparkin_backend_image.tar
```

**Import di Komputer Lain**:
```bash
# Extract jika di-compress
gunzip qparkin_backend_image.tar.gz

# Load image
docker load -i qparkin_backend_image.tar

# Jalankan dengan docker-compose
docker-compose up -d
```

### Metode 2: Export Seluruh Stack (Semua Services)

```bash
# Export semua images
docker save mysql:8.0 phpmyadmin:latest qparkin_backend:latest -o qparkin_full_stack.tar

# Compress
gzip qparkin_full_stack.tar
```

### Metode 3: Push ke Docker Hub (Recommended untuk Tim)

```bash
# Login ke Docker Hub
docker login

# Tag image dengan username Docker Hub
docker tag qparkin_backend:latest username/qparkin_backend:v1.0

# Push ke Docker Hub
docker push username/qparkin_backend:v1.0

# Tim lain bisa pull dengan:
docker pull username/qparkin_backend:v1.0
```

### Metode 4: Export dengan Data (Backup Lengkap)

```bash
# Backup database
docker-compose exec mysql mysqldump -u qparkin_user -p qparkin > backup_qparkin.sql

# Export volumes
docker run --rm -v qparkin_mysql_data:/data -v $(pwd):/backup \
  alpine tar czf /backup/mysql_data_backup.tar.gz -C /data .

# Kirim file backup bersama docker-compose.yml
```

---

## 🛠️ Perintah Docker Berguna

### Manajemen Container

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# Restart service tertentu
docker-compose restart backend

# Stop dan hapus semua (termasuk volumes)
docker-compose down -v

# Rebuild tanpa cache
docker-compose build --no-cache
```

### Debugging

```bash
# Masuk ke container backend
docker-compose exec backend bash

# Masuk ke container MySQL
docker-compose exec mysql bash

# Lihat resource usage
docker stats

# Inspect container
docker inspect qparkin_backend
```

### Maintenance

```bash
# Hapus container yang tidak digunakan
docker container prune

# Hapus image yang tidak digunakan
docker image prune -a

# Hapus volumes yang tidak digunakan
docker volume prune

# Bersihkan semua (hati-hati!)
docker system prune -a --volumes
```

---

## 📊 Arsitektur Docker QParkin

```
┌─────────────────────────────────────────────────┐
│                  Host Machine                    │
│                                                  │
│  ┌────────────────────────────────────────────┐ │
│  │         Docker Network (qparkin_network)   │ │
│  │                                            │ │
│  │  ┌──────────┐  ┌──────────┐  ┌─────────┐ │ │
│  │  │  MySQL   │  │ Backend  │  │PHPMyAdmin│ │
│  │  │  :3306   │◄─┤ Laravel  │◄─┤  :80    │ │ │
│  │  │          │  │  :8000   │  │         │ │ │
│  │  └────┬─────┘  └────┬─────┘  └─────────┘ │ │
│  │       │             │                     │ │
│  │       │             │                     │ │
│  └───────┼─────────────┼─────────────────────┘ │
│          │             │                        │
│  Port Mapping:         │                        │
│  3307:3306 ───────────┘                        │
│  8000:8000 ────────────────────────────────────┘
│  8080:80 (PHPMyAdmin)                           │
│                                                  │
│  ┌────────────────────────────────────────────┐ │
│  │         Flutter App (Native)               │ │
│  │         Connects to: localhost:8000        │ │
│  └────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

---

## 🎓 Tips untuk Presentasi Praktikum

### Poin-Poin Penting yang Harus Dijelaskan:

1. **Kenapa Pakai Docker?**
   - Konsistensi environment (dev = production)
   - Mudah setup di komputer berbeda
   - Isolasi dependencies
   - Mudah scale dan deploy

2. **Komponen yang Di-dockerize**:
   - ✅ Backend Laravel (API Server)
   - ✅ MySQL Database
   - ✅ PHPMyAdmin (Development tool)
   - ❌ Flutter App (Build native, tidak perlu Docker)

3. **Keuntungan untuk Tim**:
   - Tidak perlu install PHP, MySQL, Composer manual
   - Satu perintah untuk setup lengkap
   - Environment sama untuk semua anggota tim
   - Mudah rollback jika ada masalah

4. **Demo yang Bisa Ditunjukkan**:
   - `docker-compose up -d` → Semua jalan
   - Akses PHPMyAdmin → Lihat database
   - Test API dengan Postman/curl
   - Connect Flutter app ke Docker backend
   - Export image → Import di laptop lain

---

## 🔧 Troubleshooting

### Problem: Port sudah digunakan
```bash
# Cek port yang digunakan
netstat -ano | findstr :8000  # Windows
lsof -i :8000                 # Mac/Linux

# Solusi: Ganti port di docker-compose.yml
ports:
  - "8001:8000"  # Ganti 8000 jadi 8001
```

### Problem: Database connection refused
```bash
# Cek status MySQL
docker-compose logs mysql

# Tunggu sampai MySQL ready
docker-compose exec mysql mysqladmin ping -h localhost

# Restart backend setelah MySQL ready
docker-compose restart backend
```

### Problem: Permission denied di Linux
```bash
# Berikan permission ke storage folder
sudo chown -R $USER:$USER qparkin_backend/storage
sudo chmod -R 775 qparkin_backend/storage
```

---

## 📝 Checklist Presentasi

- [ ] Jelaskan arsitektur aplikasi (Backend + Mobile)
- [ ] Tunjukkan file docker-compose.yml
- [ ] Jelaskan setiap service yang digunakan
- [ ] Demo: `docker-compose up -d`
- [ ] Demo: Akses PHPMyAdmin
- [ ] Demo: Test API endpoint
- [ ] Demo: Connect Flutter app
- [ ] Jelaskan cara export/import image
- [ ] Tunjukkan monitoring dengan `docker stats`
- [ ] Jelaskan keuntungan menggunakan Docker

---

## 📚 Referensi

- Docker Documentation: https://docs.docker.com/
- Docker Compose: https://docs.docker.com/compose/
- Laravel Docker: https://laravel.com/docs/sail
- MySQL Docker: https://hub.docker.com/_/mysql

---

**Dibuat untuk**: Praktikum PBL - Aplikasi QParkin  
**Tanggal**: 2026  
**Versi**: 1.0
