# 🐳 QParkin Docker Setup

Dokumentasi lengkap untuk menjalankan aplikasi QParkin menggunakan Docker.

## 📁 Struktur File Docker

```
qparkin_pbl/
├── docker-compose.yml              # Orchestration semua services
├── .dockerignore                   # File yang diabaikan saat build
├── qparkin_backend/
│   └── Dockerfile                  # Blueprint untuk backend image
├── start-docker.bat/.sh            # Script start (Windows/Linux)
├── stop-docker.bat/.sh             # Script stop (Windows/Linux)
├── export-docker-image.bat/.sh     # Script export image
├── DOCKER_SETUP_GUIDE.md           # Panduan lengkap (BACA INI!)
├── QUICK_START_DOCKER.md           # Panduan cepat
└── PRESENTASI_DOCKER.md            # Panduan presentasi praktikum
```

## 🚀 Quick Start

### Windows
```cmd
start-docker.bat
```

### Linux/Mac
```bash
chmod +x start-docker.sh
./start-docker.sh
```

### Manual
```bash
docker-compose up -d --build
```

## 🌐 Akses Aplikasi

| Service | URL | Credentials |
|---------|-----|-------------|
| Backend API | http://localhost:8000 | - |
| PHPMyAdmin | http://localhost:8080 | User: qparkin_user<br>Pass: qparkin_password |
| MySQL | localhost:3307 | DB: qparkin<br>User: qparkin_user<br>Pass: qparkin_password |

## 📱 Connect Flutter App

1. Cek IP komputer Anda:
   - Windows: `ipconfig`
   - Mac/Linux: `ifconfig` atau `ip addr`

2. Edit `qparkin_app/lib/config/constants.dart`:
   ```dart
   const String API_URL = 'http://192.168.1.100:8000';
   ```

3. Jalankan Flutter:
   ```bash
   cd qparkin_app
   flutter run --dart-define=API_URL=http://192.168.1.100:8000
   ```

## 🛠️ Perintah Berguna

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Restart service
docker-compose restart backend

# Check status
docker-compose ps

# Enter container
docker-compose exec backend bash

# View resource usage
docker stats
```

## 📦 Export Image

### Windows
```cmd
export-docker-image.bat
```

### Linux/Mac
```bash
chmod +x export-docker-image.sh
./export-docker-image.sh
```

File akan tersimpan di folder `docker_exports/`

## 📚 Dokumentasi Lengkap

- **Setup Lengkap**: Baca `DOCKER_SETUP_GUIDE.md`
- **Quick Start**: Baca `QUICK_START_DOCKER.md`
- **Panduan Presentasi**: Baca `PRESENTASI_DOCKER.md`

## 🔧 Troubleshooting

### Port sudah digunakan
Edit `docker-compose.yml`, ganti port:
```yaml
ports:
  - "8001:8000"  # Ganti 8000 jadi 8001
```

### Database tidak connect
```bash
docker-compose logs mysql
docker-compose restart backend
```

### Permission denied (Linux)
```bash
sudo chown -R $USER:$USER qparkin_backend/storage
sudo chmod -R 775 qparkin_backend/storage
```

## 🎯 Untuk Presentasi

1. ✅ Install Docker Desktop
2. ✅ Jalankan `start-docker.bat`
3. ✅ Akses http://localhost:8000
4. ✅ Akses http://localhost:8080
5. ✅ Test API dengan Postman
6. ✅ Connect Flutter app
7. ✅ Export image
8. ✅ Tunjukkan `docker stats`

Baca `PRESENTASI_DOCKER.md` untuk panduan lengkap!

## 📊 Arsitektur

```
┌─────────────────────────────────────┐
│         Docker Host                 │
│  ┌───────────────────────────────┐ │
│  │    Docker Network             │ │
│  │  ┌─────────┐  ┌─────────┐   │ │
│  │  │  MySQL  │◄─┤ Laravel │   │ │
│  │  │  :3306  │  │ Backend │   │ │
│  │  └─────────┘  │  :8000  │   │ │
│  │       ▲       └─────────┘   │ │
│  │       │            ▲         │ │
│  │  ┌────┴────────────┴──────┐ │ │
│  │  │   PHPMyAdmin :80       │ │ │
│  │  └────────────────────────┘ │ │
│  └───────────────────────────────┘ │
│      :3307      :8000      :8080   │
└─────────────────────────────────────┘
```

## ✅ Checklist

- [ ] Docker Desktop terinstall
- [ ] Repository di-clone
- [ ] Jalankan `start-docker.bat/.sh`
- [ ] Akses backend (localhost:8000)
- [ ] Akses PHPMyAdmin (localhost:8080)
- [ ] Test API endpoint
- [ ] Connect Flutter app
- [ ] Export image berhasil

---

**Butuh bantuan?** Baca dokumentasi lengkap di `DOCKER_SETUP_GUIDE.md`
