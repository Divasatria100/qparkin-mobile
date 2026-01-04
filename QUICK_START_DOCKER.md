# 🚀 Quick Start - Docker QParkin

Panduan cepat untuk menjalankan aplikasi QParkin menggunakan Docker.

## ⚡ Cara Tercepat (Windows)

### 1. Install Docker Desktop
Download dan install dari: https://www.docker.com/products/docker-desktop

### 2. Jalankan Aplikasi
Double-click file: **`start-docker.bat`**

Atau via command prompt:
```cmd
start-docker.bat
```

### 3. Akses Aplikasi
- **Backend API**: http://localhost:8000
- **PHPMyAdmin**: http://localhost:8080
- **Database**: localhost:3307

### 4. Stop Aplikasi
Double-click file: **`stop-docker.bat`**

---

## 🔧 Manual Setup (Semua OS)

### Langkah 1: Start Services
```bash
docker-compose up -d --build
```

### Langkah 2: Cek Status
```bash
docker-compose ps
```

### Langkah 3: Setup Database (Pertama Kali)
```bash
docker-compose exec backend php artisan migrate --seed
docker-compose exec backend php artisan passport:install
```

### Langkah 4: Test API
Buka browser: http://localhost:8000

---

## 📱 Connect Flutter App

Edit file `qparkin_app/lib/config/constants.dart`:

```dart
// Ganti dengan IP komputer Anda
const String API_URL = 'http://192.168.1.100:8000';
```

Cara cek IP komputer:
- **Windows**: `ipconfig` (lihat IPv4 Address)
- **Mac/Linux**: `ifconfig` atau `ip addr`

Jalankan Flutter app:
```bash
cd qparkin_app
flutter run --dart-define=API_URL=http://192.168.1.100:8000
```

---

## 🔍 Troubleshooting

### Port sudah digunakan?
Edit `docker-compose.yml`, ganti port:
```yaml
ports:
  - "8001:8000"  # Ganti 8000 jadi 8001
```

### Database tidak connect?
```bash
# Cek logs MySQL
docker-compose logs mysql

# Restart backend
docker-compose restart backend
```

### Lihat logs error
```bash
docker-compose logs -f backend
```

---

## 📦 Export untuk Presentasi

Jalankan: **`export-docker-image.bat`**

File akan tersimpan di folder `docker_exports/`

---

## 🎯 Perintah Berguna

```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# Restart
docker-compose restart

# Logs
docker-compose logs -f

# Masuk ke container
docker-compose exec backend bash

# Hapus semua (reset)
docker-compose down -v
```

---

## 📊 Default Credentials

### Database
- Host: `localhost:3307` (dari host) atau `mysql:3306` (dari container)
- Database: `qparkin`
- Username: `qparkin_user`
- Password: `qparkin_password`

### PHPMyAdmin
- URL: http://localhost:8080
- Server: `mysql`
- Username: `qparkin_user`
- Password: `qparkin_password`

---

## ✅ Checklist Presentasi

- [ ] Docker Desktop terinstall dan running
- [ ] Jalankan `start-docker.bat`
- [ ] Akses http://localhost:8000 (Backend)
- [ ] Akses http://localhost:8080 (PHPMyAdmin)
- [ ] Test API dengan Postman/curl
- [ ] Connect Flutter app ke backend
- [ ] Export image dengan `export-docker-image.bat`
- [ ] Tunjukkan `docker-compose ps`
- [ ] Tunjukkan `docker stats`

---

**Butuh bantuan lengkap?** Baca: `DOCKER_SETUP_GUIDE.md`
