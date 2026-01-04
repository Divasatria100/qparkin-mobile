# Praktikum Docker – Tugas D
## Aplikasi QParkin

---

## Slide 1: Judul

**PRAKTIKUM DOCKER – TUGAS D**

**Aplikasi: QParkin**  
Sistem Manajemen Parkir Pintar

**Tim PBL:**
- [Nama Anggota 1]
- [Nama Anggota 2]
- [Nama Anggota 3]

**Program Studi Teknik Informatika**  
**Politeknik Negeri [Nama]**  
**2026**

---

## Slide 2: Gambaran Aplikasi

### Arsitektur Aplikasi QParkin

QParkin adalah aplikasi manajemen parkir berbasis mobile dan web yang terdiri dari tiga komponen utama:

**Backend API (Laravel 12)**
- Framework PHP 8.2 untuk REST API
- Mengelola logika bisnis dan autentikasi
- Port: 8000

**Database (MySQL 8.0)**
- Menyimpan data pengguna, parkiran, booking, dan transaksi
- Port: 3307

**Mobile App (Flutter 3.0+)**
- Aplikasi cross-platform untuk pengguna
- Terhubung ke Backend API

---

## Slide 3: Service Docker yang Digunakan

### Struktur Service Docker

Aplikasi QParkin menggunakan tiga service Docker yang saling terhubung:

**1. Laravel Backend (qparkin_backend)**
- Service penyedia REST API untuk aplikasi mobile
- Build dari Dockerfile custom dengan PHP 8.2 dan Composer

**2. MySQL Database (mysql:8.0)**
- Service penyimpanan data aplikasi
- Menggunakan volume untuk persistensi data

**3. PHPMyAdmin (phpmyadmin:latest)**
- Service pengelolaan database melalui web interface
- Memudahkan monitoring dan administrasi database

Ketiga service ini terhubung melalui Docker network bernama `qparkin_network`.

---

## Slide 4: Docker Compose

### Pengelolaan Service dengan Docker Compose

Docker Compose digunakan untuk mengelola ketiga service secara terpadu:

**Konfigurasi Utama:**
- File `docker-compose.yml` mendefinisikan semua service
- Mengatur port mapping untuk akses dari host
- Mengelola environment variables untuk konfigurasi
- Mengatur dependencies antar service (backend bergantung pada MySQL)

**Keuntungan:**
- Semua service dapat dijalankan dengan satu perintah
- Komunikasi antar container otomatis melalui network
- Konfigurasi terpusat dan mudah dikelola

---

## Slide 5: Uji Coba Menjalankan Docker

### Eksekusi Docker Compose

**Perintah yang dijalankan:**
```bash
docker-compose up -d --build
```

**Screenshot:**
[Tampilkan screenshot terminal saat menjalankan docker-compose up]

Perintah ini melakukan build image backend, pull image MySQL dan PHPMyAdmin, kemudian menjalankan semua container dalam mode detached (background).

---

## Slide 6: Container Berjalan

### Verifikasi Container Aktif

**Perintah yang dijalankan:**
```bash
docker-compose ps
```

**Screenshot:**
[Tampilkan screenshot output docker-compose ps menunjukkan 3 container UP]

Output menunjukkan tiga container berjalan dengan status "Up" beserta port mapping masing-masing service (MySQL:3307, Backend:8000, PHPMyAdmin:8080).

---

## Slide 7: Aplikasi Berhasil Diakses

### Pengujian Akses Service

**Backend API (http://localhost:8000)**

**Screenshot:**
[Tampilkan screenshot browser mengakses localhost:8000]

**PHPMyAdmin (http://localhost:8080)**

**Screenshot:**
[Tampilkan screenshot PHPMyAdmin login/dashboard dengan database qparkin]

Kedua service berhasil diakses melalui browser, menunjukkan bahwa container berjalan dengan baik dan port mapping berfungsi sesuai konfigurasi.

---

## Slide 8: Export Docker Image

### Proses Export Image Docker

**Perintah yang dijalankan:**
```bash
docker save qparkin_backend:latest -o qparkin_backend.tar
```

**Screenshot:**
[Tampilkan screenshot proses docker save]

**File hasil export:**

**Screenshot:**
[Tampilkan screenshot file .tar di folder docker_exports dengan ukuran file]

Image backend berhasil di-export menjadi file .tar yang dapat dipindahkan ke perangkat lain dan di-import menggunakan perintah `docker load`.

---

## Slide 9: Kesimpulan

### Manfaat Penggunaan Docker

Dari praktikum ini, dapat disimpulkan bahwa Docker memberikan manfaat signifikan:

- **Memudahkan deployment aplikasi** dengan konfigurasi yang terpusat dan otomatis
- **Lingkungan aplikasi konsisten** di berbagai perangkat tanpa masalah kompatibilitas
- **Mudah dipindahkan ke perangkat lain** melalui export/import image atau Docker Hub

Docker terbukti efektif untuk mengelola aplikasi multi-service seperti QParkin dengan setup yang cepat dan reliable.
