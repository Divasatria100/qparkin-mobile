# SPESIFIKASI KEBUTUHAN DAN PERANCANGAN

# PERANGKAT LUNAK

# Parkey: Inovasi Aplikasi Mobile Berbasis QR Code untuk

# Sistem Tiket Parkir Digital di Pusat Perbelanjaan

# (QPARKIN)

## Dipersiapkan oleh:

## Berkat Tua Siallagan - 4342401085

## Diva Satria - 4342401072

## Jerimy Steven Robert Monangin - 4342401077

## Ananda Meliana Sembiring - 4342401086

## Suci Aqila Nasution - 4342401087

```
Program Studi Teknologi Rekayasa Perangkat Lunak
Politeknik Negeri Batam
Jl. Ahmad Yani, Batam 29461
2025
```

## Daftar Isi


- 1 PENDAHULUAN
   - 1.1 TUJUAN
   - 1.2 LINGKUP MASALAH
   - 1.3 DEFINISI, AKRONIM DAN SINGKATAN
   - 1.4 ATURAN PENAMAAN DAN PENOMORAN
   - 1.5 REFERENSI
   - 1.6 IKHTISAR DOKUMEN
- 2 DESKRIPSI UMUM PERANGKAT LUNAK
   - 2.1 DESKRIPSI UMUM SISTEM
   - 2.2 PROSES BISNIS SISTEM
   - 2.3 KARAKTERISTIK PENGGUNA
   - 2.4 BATASAN
   - 2.5 RANCANGAN LINGKUNGAN IMPLEMENTASI
- 3 DESKRIPSI RINCI KEBUTUHAN
   - 3.1 DESKRIPSI FUNGSIONAL
      - 3.1.1 Use Case Diagram
      - 3.1.2 Use Case Melakukan Registrasi
      - 3.1.3 Use Case Melakukan Login
      - 3.1.4 Use Case Booking Slot Parkir
      - 3.1.5 Use Case Scan QR Masuk/Keluar
      - 3.1.6 Use Case Melakukan Pembayaran Digital
      - 3.1.7 Use Case Manajemen Poin dan Penalti
      - 3.1.8 Use Case Melihat Riwayat Parkir
      - 3.1.9 Use Case Memanajemen Data Pengguna
      - 3.1.10 Use Case Mengatur Tarif Parkir
      - 3.1.11 Use Case Booking Slot Parkir
      - 3.1.12 Use Case Melakukan Pembayaran Digital
      - 3.1.13 Use Case Mengatur Tarif Parkir
   - 3.2 DESKRIPSI KEBUTUHAN NON FUNGSIONAL
- 4 DESKRIPSI KELAS-KELAS
   - 4.1 CLASS DIAGRAM
   - 4.2 CLASS <PENGGUNA>
   - 4.3 CLASS <DRIVER>
   - 4.4 CLASS <ADMIN>
   - 4.5 CLASS <SLOTPARKIR>
   - 4.6 CLASS <TARIFPARKIR>
   - 4.7 CLASS <BOOKING>
   - 4.8 CLASS <TRANSAKSIPARKIR>
   - 4.9 STATE MACHINE DIAGRAM
      - Deskripsi State Machine Diagram Transaksi Parkir
- 5 DESKRIPSI DATA
   - 5.1 ENTITY-RELATIONSHIP DIAGRAM
   - 5.2 DAFTAR TABEL
   - 5.3 STRUKTUR TABEL <USER>
   - 5.4 STRUKTUR TABEL <MALL>
   - 5.5 STRUKTUR TABEL <ADMIN_MALL>
   - 5.6 STRUKTUR TABEL <CUSTOMER>
   - 5.7 SSTRUKTUR TABEL <KENDARAAN>
   - 5.8 STRUKTUR TABEL <GERBANG>
   - 5.9 STRUKTUR TABEL <PARKIRAN>
   - 5.10 STRUKTUR TABEL <TARIF_PARKIR>
   - 5.11 STRUKTUR TABEL <TRANSAKSI_PARKIR>
   - 5.12 STRUKTUR TABEL <BOOKING>
   - 5.13 STRUKTUR TABEL <PEMBAYARAN>
   - 5.14 STRUKTUR TABEL<RIWAYAT_POIN>
   - 5.15 STRUKTUR TABEL<NOTIFIKASI>
   - 5.16 STRUKTUR TABEL<RIWAYAT_GERBANG>
   - 5.17 STRUKTUR TABEL<SUPER_ADMIN>
   - 5.18 SKEMA RELASI ANTAR TABEL
      - Deskripsi Relasi Antar Entitas Utama Basis Data QPARKIN
- 6 PERANCANGAN ANTARMUKA
   - 6.1 ANTARMUKA MOBILE
- 7 MATRIKS KETERUNUTAN


## 1 PENDAHULUAN

Sistem tiket parkir tradisional yang mengandalkan kertas dan pembayaran tunai sering
kali menimbulkan berbagai permasalahan, seperti antrean panjang di gerbang, potensi
kebocoran pendapatan, dan kurang efisiennya pengelolaan slot parkir. Inovasi teknologi
dalam pengelolaan parkir, khususnya di pusat perbelanjaan, menjadi krusial untuk
meningkatkan efisiensi dan pengalaman pengguna (User Experience/UX) [6].

Perangkat lunak **QPARKIN** ini dikembangkan sebagai solusi untuk mengatasi
tantangan tersebut, dengan mengimplementasikan sistem parkir digital yang terintegrasi
penuh. Sistem ini memanfaatkan teknologi aplikasi _mobile_ dan kode **QR (QR Code)**
untuk proses _check-in_ dan _check-out_ yang cepat dan akurat [1], serta didukung oleh
layanan _Web Service API_ untuk menjamin komunikasi data yang andal [7]. Selain itu,
QPARKIN juga mencakup fitur penting seperti _booking_ slot parkir untuk menjamin
ketersediaan [5] dan integrasi pembayaran digital seperti **QRIS** untuk mempermudah
transaksi [3]. Dokumen Spesifikasi Kebutuhan dan Perancangan Perangkat Lunak
(SKPPL) ini bertujuan untuk mendefinisikan secara detail kebutuhan fungsional dan
non-fungsional, serta perancangan sistem QPARKIN.

### 1.1 TUJUAN

Tujuan dari penyusunan dokumen ini dan pengembangan sistem QPARKIN secara
umum adalah sebagai berikut:

```
a. Mendefinisikan Kebutuhan: Menyediakan spesifikasi yang jelas, terstruktur,
dan terperinci mengenai semua kebutuhan fungsional dan non-fungsional dari
sistem QPARKIN, termasuk fitur booking dan manajemen poin.
b. Merancang Sistem: Merancang arsitektur perangkat lunak, termasuk
perancangan database dengan penggunaan trigger untuk otomatisasi [5], serta
memodelkan alur transaksi parkir yang kompleks menggunakan State Machine
Diagram [4].
c. Mewujudkan Sistem Tiket Digital: Mengembangkan aplikasi mobile bagi
pengguna untuk melakukan pendaftaran kendaraan, booking , check-in , check-out
berbasis QR Code [1], dan pembayaran digital yang terintegrasi dengan QRIS
[3].
d. Menjadi Pedoman Implementasi: Menjadi dokumen acuan utama bagi tim
pengembang dalam fase implementasi dan pengujian perangkat lunak,
memastikan setiap modul yang dikembangkan sesuai dengan kebutuhan yang
telah disepakati.
```
### 1.2 LINGKUP MASALAH

Batasan dan lingkup pengembangan sistem QPARKIN dalam dokumen ini adalah:

```
a. Pengembangan Perangkat Lunak: Fokus utama adalah pada perancangan dan
implementasi aplikasi mobile sisi pengguna ( customer ) dan antarmuka web sisi
pengelola ( Admin Mall dan Super Admin ), yang dikembangkan melalui Web
Service API [7].
```

```
b. Fitur Fungsional: Sistem mencakup modul registrasi pengguna dan kendaraan,
booking slot parkir [5], check-in dan check-out menggunakan pemindaian QR
Code [1], perhitungan tarif, kalkulasi penalty , serta modul pembayaran
multi-metode (termasuk Poin dan QRIS [3]).
c. Peran Pengguna: Meliputi tiga peran utama, yaitu Customer (melakukan
transaksi parkir), Admin Mall (mengelola area parkir dan melihat laporan
transaksi di mallnya), dan Super Admin (mengelola data Mall dan akun
Admin).
d. Batasan Non-Fungsional: Sistem dirancang untuk memastikan keamanan data
transaksi, kecepatan pemrosesan (latency rendah), dan ketersediaan sistem yang
tinggi.
e. Batasan Integrasi (Non-Fokus): Dokumen ini tidak mencakup perancangan
perangkat keras (seperti palang parkir otomatis atau mikrokontroler ) [2]. Asumsi
integrasi gerbang dilakukan melalui sinyal trigger yang dikirim dari Web Service
API setelah transaksi pembayaran diverifikasi.
```
### 1.3 DEFINISI, AKRONIM DAN SINGKATAN

```
a. Definisi Operasional
```
```
Istilah Definisi
```
```
QPARKIN Aplikasi mobile berbasis QR Code untuk sistem
tiket parkir digital di pusat perbelanjaan.
```
```
Pengguna (Driver) Individu yang menggunakan aplikasi Parkey
untuk melakukan proses parkir kendaraan.
```
```
Admin Pengelola parkir yang bertugas memantau
operasional parkir melalui dashboard web.
```
```
Super Admin Administrator tingkat tinggi yang dapat
memantau laporan semua lokasi parkir.
```
```
Booking Slot Fitur pemesanan tempat parkir secara terlebih
dahulu melalui aplikasi.
```
```
QR Code Kode matriks yang dapat dipindai oleh perangkat
mobile untuk mengakses informasi atau
melakukan validasi.
```
```
QRIS Quick Response Code Indonesian Standard,
standar pembayaran digital berbasis QR code di
Indonesia.
```
```
TapCash Kartu elektronik atau sistem pembayaran
nirsentuh yang dapat digunakan untuk transaksi
parkir.
```

```
Poin Reward Sistem reward yang diberikan kepada pengguna
berdasarkan transaksi parkir, yang dapat
ditukarkan sebagai diskon atau pembayaran.
```
```
Penalty Denda yang dikenakan kepada pengguna karena
melanggar ketentuan, seperti melebihi durasi
booking.
```
```
Dashboard Admin Antarmuka web untuk pengelola dalam
memantau dan mengelola sistem parkir.
```
```
API Gate Virtual Simulasi antarmuka perangkat keras gerbang
parkir yang digunakan untuk pengujian sistem.
```
```
P-A-D-I-T Metode pengembangan proyek yang terdiri dari
Planning, Analysis, Design, Implementation, dan
Testing.
b. Akronim/Singkatan
```
```
Akronim/
Singkatan
```
```
Kepanjangan
```
```
SKPPL Spesifikasi Kebutuhan dan Perancangan
Perangkat Lunak
```
```
PBL Project Based Learning
```
```
TRPL Teknologi Rekayasa Perangkat Lunak
```
```
QRIS Quick Response Code Indonesian Standard
```
```
API Application Programming Interface
```
```
UI/UX User Interface / User Experience
```
### 1.4 ATURAN PENAMAAN DAN PENOMORAN

```
Hal/Bagian Aturan Penamaan/Penomoran
```
```
Kebutuhan
Fungsional
```
```
FXXX: "FXXX" berarti Fungsional yang ke “XXX”, mengacu pada
fitur atau fungsi utama yang harus ada dalam sistem agar bisa
berjalan sesuai tujuan.
```
```
Kebutuhan
Non
Fungsional
```
```
NFXXX: "NFXXX" berarti Non Fungsional yang ke “XXX”,
mengacu pada aspek yang mendukung sistem tetapi bukan fitur
utama, seperti keamanan, performa, atau skalabilitas.
```

```
Use Case UCXXX: “UCXXX” berarti Use Case yang ke “XXX”, mengacu
pada skenario atau langkah-langkah bagaimana pengguna
berinteraksi dengan sistem.
```
### 1.5 REFERENSI

Dokumen ini merujuk pada beberapa sumber sebagai acuan dalam penyusunannya,
yaitu:

```
[1] Koten, G. R., Probodinanti, H., Daulat T., Krisnawi S., Kwa, S. A.,
Hadisantono, & Dewa, P. K. (2024). Penerapan internet of things pada
smart parking system untuk kebutuhan pengembangan smart city. Jurnal
Teknik Industri dan Manajemen Rekayasa, v1i1.
doi:10.24002/jtimr.v1i1.7204.
```
```
[2] Tobi, M. H. (2023). Design of Automatic Parking Access System Based on
Internet of Things (IoT). Brilliance: Research of Artificial Intelligence,
v2i2. doi:10.47709/brilliance.v2i2.1561.
```
```
[3] Firmansah, A. (2025). Implementation of a Web-Mobile-Based Cashless
Parking Retribution Payment System Using QR Code Method. Conference
on Business, Social Sciences and Technology (CoNeScINTech), Vol. 5 No.
```
1. doi:10.37253/conescintech.v5i1.10521.

```
[4] Lestari, A., Sopandi, L. M., & Rakhmawati, I. (2023). Analysis of the use
of Quick Response Code Indonesian Standard (Qris) on Parking
Retribution in Mataram City. East Asian Journal of Multidisciplinary
Research, v3i6. doi:10.55927/eajmr.v3i6.9582.
```
```
[5] Dana, L. F., & Selfiani, S. (2025). Pengaruh penggunaan QRIS terhadap
pembayaran e-parking dengan variabel digitalisasi ekonomi sebagai
pemoderasi. Jurnal Akuntansi, Keuangan, Pajak dan Informasi (JAKPI),
v5i1, pp.127-140.
```

### 1.6 IKHTISAR DOKUMEN

Dokumen ini merupakan SKPPL untuk aplikasi QPARKIN, sebuah sistem yang
dirancang untuk menggantikan sistem konvensional dengan solusi terintegrasi yang
memanfaatkan teknologi QR code dan mobile app, guna meningkatkan efisiensi,
kecepatan, dan transparansi dalam pengelolaan parkir.

```
Dokumen ini terdiri dari beberapa bagian utama:
a. BAB I Pendahuluan: Menjelaskan tujuan sistem, lingkup masalah yang ingin
diselesaikan, definisi istilah, serta aturan penamaan yang digunakan.
b. BAB II Deskripsi Umum Perangkat Lunak: Menggambarkan sistem secara
keseluruhan, termasuk proses bisnis, karakteristik pengguna, batasan sistem,
dan lingkungan implementasi.
c. BAB III Deskripsi Rinci Kebutuhan: Merinci kebutuhan sistem, mencakup
kebutuhan fungsional dengan Use Case Diagram, serta kebutuhan
non-fungsional.
d. BAB IV Deskripsi Kelas-Kelas: Memaparkan struktur kelas dalam sistem
melalui Class Diagram, definisi kelas, dan State Machine Diagram.
e. BAB V Deskripsi Data: Menyajikan model data dengan Entity-Relationship
Diagram (ERD), daftar tabel, struktur tabel, dan relasi antar tabel.
f. BAB VI Perancangan Antarmuka: Menguraikan tampilan antarmuka pengguna
dengan sketsa atau wireframe setiap halaman sistem.
g. BAB VII Matriks Keterunutan: Menyediakan hubungan antara kebutuhan
sistem dan elemen yang diimplementasikan untuk memastikan konsistensi
pengembangan.
```
## 2 DESKRIPSI UMUM PERANGKAT LUNAK

Perangkat lunak QPARKIN merupakan aplikasi mobile berbasis Android yang
dikembangkan menggunakan framework Flutter dengan bahasa pemrograman Dart.
Aplikasi ini berfungsi sebagai antarmuka utama bagi pengguna (driver) untuk
mengakses layanan parkir digital. Perangkat lunak ini terintegrasi dengan backend
server yang dibangun menggunakan teknologi web modern dan database MySQL untuk
penyimpanan data.

### 2.1 DESKRIPSI UMUM SISTEM

Sistem Parkey (QPARKIN) adalah sebuah ecosystem digital terpadu yang terdiri
dari beberapa komponen yang saling terintegrasi untuk menyediakan solusi parkir
digital end-to-end. Sistem ini mencakup:
a. Aplikasi Mobile (Frontend) - Antarmuka pengguna untuk driver yang
menyediakan fitur booking, pembayaran, dan riwayat transaksi
b. Dashboard Web Admin - Platform manajemen untuk pengelola parkir dengan
fitur monitoring real-time dan laporan keuangan


```
c. Backend Server - Inti pemrosesan data yang menangani logika bisnis, validasi,
dan integrasi antar komponen
d. Database System - Penyimpanan terpusat untuk data pengguna, transaksi,
kendaraan, dan operasional
e. API Gateway - Layer integrasi untuk terhubung dengan sistem eksternal
(pembayaran digital, layanan peta, virtual gate)
```
### 2.2 PROSES BISNIS SISTEM

```
Gambar 2.2 Activity Diagram
```
Sistem Tiket Parkir Digital **QPARKIN** dirancang untuk mendigitalisasi dan

mengotomatisasi seluruh alur layanan parkir di pusat perbelanjaan, mulai dari registrasi


kendaraan, pemesanan slot (booking), check-in/check-out menggunakan QR Code,

hingga proses pembayaran yang terintegrasi. Proses bisnis utama dalam sistem ini

mencakup Pendaftaran Akun dan Kendaraan, Pemesanan Parkir (Booking), Verifikasi

Masuk dan Keluar Gerbang, serta Penyelesaian Pembayaran dan pencatatan riwayat

poin.

### 2.3 KARAKTERISTIK PENGGUNA

Sistem Qparkin ditujukan bagi tiga kelompok utama pengguna, yaitu pengguna
umum (pengunjung mall), admin mall, dan manajemen mall (super admin). Setiap
pengguna memiliki hak akses dan kebutuhan yang berbeda sesuai dengan peran mereka
dalam ekosistem sistem parkir digital.

```
a. Pengguna Umum (pengunjung mall)
Pengguna umum merupakan pihak yang menggunakan aplikasi Qparkin
untuk melakukan aktivitas parkir di pusat perbelanjaan secara digital.
```
```
Karakteristik:
```
1. Merupakan pengendara kendaraan yang berkunjung ke pusat
    perbelanjaan.
2. Memiliki smartphone dan akses internet untuk menjalankan aplikasi
    Qparkin
3. Terbiasa menggunakan teknologi digital seperti aplikasi mobile dan
    metode pembayaran nontunai (QRIS, e-wallet, TapCash).
4. Menginginkan proses parkir yang cepat, efisien, dan tanpa kontak fisik.

```
Kebutuhan Utama:
```
1. Kemudahan dalam proses masuk dan keluar area parkir menggunakan
    QR code.
2. Pilihan metode pembayaran digital yang fleksibel dan aman.
3. Informasi parkir yang transparan, termasuk durasi, tarif, dan riwayat
    transaksi.
4. Fitur booking tempat parkir untuk memastikan ketersediaan slot sebelum
    tiba di lokasi.
5. Sistem poin reward yang dapat digunakan untuk membayar parkir atau
    denda.

```
b. Admin Mall
Admin mall adalah petugas operasional yang bertanggung jawab mengelola
sistem parkir digital di lokasi mall masing-masing. Mereka berfungsi sebagai
penghubung antara sistem QPARKIN dan operasional di lapangan.
```
```
Karateristik:
```
1. Menguasai dasar operasional sistem berbasis web.
2. Bertanggung jawab terhadap pengaturan tarif, laporan pendapatan, dan
    pengelolaan pengguna.


3. Memerlukan akses dashboard admin untuk monitoring secara real-time.

```
Hak Akses & Kebutuhan:
```
1. Mengelola data pengguna dan kendaraan.
2. Mengatur tarif parkir dan penalti keterlambatan.
3. Memantau aktivitas kendaraan masuk/keluar melalui dashboard.
4. Melihat laporan keuangan otomatis dan log aktivitas operasional.
5. Melakukan validasi transaksi dan penanganan error di lapangan.

```
c. Manajemen Mall (super admin)
Super admin adalah pihak manajemen tingkat atas yang memiliki akses
terhadap seluruh data parkir lintas lokasi. Mereka bertanggung jawab atas analisis
performa dan pengambilan keputusan strategis.
```
```
Karakteristik:
```
1. Memiliki akses administratif tertinggi di sistem QPARKIN.
2. Berperan dalam evaluasi performa dan efisiensi sistem parkir di seluruh
    cabang.
3. Memerlukan akses ke laporan keuangan agregat, analisis performa, dan
    audit log admin.

```
Hak Akses & Kebutuhan:
```
1. Melihat laporan pendapatan seluruh lokasi parkir.
2. Membandingkan kinerja antar lokasi melalui data visualisasi dashboard.
3. Mengakses audit log aktivitas admin.
4. Melakukan pemantauan sistem secara menyeluruh untuk menjaga
    konsistensi dan keamanan data.

### 2.4 BATASAN

Batasan-batasan untuk pengembangan perangkat lunak QPARKIN ini adalah
sebagai berikut:

```
a. Lingkup Fungsional Inti
Aplikasi ini hanya akan diimplementasikan untuk sistem tiket parkir digital,
mencakup booking slot , scan QR masuk/keluar , dan pembayaran digital.
```
```
b. Integrasi Perangkat Keras (Hardware)
Pada tahap pengembangan dan pengujian proyek ini, sistem tidak
mengimplementasikan atau berintegrasi langsung dengan perangkat keras (IoT)
seperti palang pintu parkir fisik atau mesin tiket. Fungsi scan QR masuk/keluar
disimulasikan sepenuhnya di dalam aplikasi ( API Gate Virtual ).
```
```
c. Platform Pengembangan
Aplikasi mobile (untuk Driver ) hanya dikembangkan untuk platform Android
menggunakan framework Flutter dan bahasa pemrograman Dart.
```
```
d. Lingkup Lokasi
```

```
Pengembangan dan pengujian sistem ini diasumsikan hanya berlaku untuk satu
atau beberapa pusat perbelanjaan (mall) simulasi, tidak mencakup implementasi di
berbagai jenis lokasi parkir umum lainnya.
```
```
e. Metode Pembayaran
Metode pembayaran digital yang diintegrasikan dalam simulasi terbatas pada
opsi yang disebutkan (QRIS, e-wallet , TapCash, dan penukaran poin).
```
```
f. Sistem Peta
Integrasi layanan peta hanya terbatas pada penyediaan informasi navigasi
lokasi parkir dan tidak mencakup navigasi detail di dalam gedung atau indoor.
```
### 2.5 RANCANGAN LINGKUNGAN IMPLEMENTASI

```
Agar sistem QPARKIN (Parkey) dapat beroperasi secara optimal, dibutuhkan
```
lingkungan implementasi terpadu yang terdiri dari perangkat keras, perangkat lunak,
infrastruktur jaringan, dan sumber daya manusia.

```
a. Perangkat Keras
● Server/Cloud VPS: Untuk hosting Backend Server dan Database System
yang menangani logika bisnis, data transaksi, dan integrasi antar komponen.
● Perangkat Pengguna (Driver): Smartphone berbasis Android dengan
koneksi internet untuk menjalankan Aplikasi Mobile QPARKIN.
● Perangkat Pengelola (Admin/Super Admin): Komputer/Laptop ( desktop
atau web browser ) untuk mengakses Dashboard Web Admin dan memantau
operasional.
● Perangkat Gerbang Parkir (Simulasi): Perangkat mobile atau komponen
simulasi internal (API Gate Virtual) untuk memindai QR Code di gerbang
masuk/keluar.
```
```
b. Perangkat Lunak
● Aplikasi Frontend Mobile (Driver): Dikembangkan menggunakan Flutter
dan bahasa pemrograman Dart.
● Aplikasi Frontend Web (Admin/Super Admin): Dikembangkan
menggunakan Laravel.
● Backend Server: Dikembangkan menggunakan teknologi web modern untuk
pemrosesan data dan validasi.
● Sistem Basis Data (Database System): MySQL untuk penyimpanan data
pengguna, transaksi, dan operasional.
● Integrasi Pihak Ketiga: API Gateway untuk terhubung dengan simulasi
sistem pembayaran digital (QRIS, e-wallet , TapCash) dan layanan peta
(misalnya GIS).
```
```
c. Jaringan & Keamanan
● Koneksi Jaringan Stabil: Koneksi internet yang andal dan stabil diperlukan
```

```
untuk semua perangkat pengguna dan server agar notifikasi real-time dan
pemrosesan transaksi di bawah 3 detik dapat tercapai.
● Keamanan Data: Implementasi Enkripsi SSL/TLS dan memastikan akses
sistem hanya dengan kredensial yang valid.
● Ketersediaan (Availability): Sistem harus tersedia 24/7 dan memiliki
mekanisme backup serta rencana pemulihan data.
```
```
d. Sumber Daya Manusia (Pengguna Sistem)
● Driver/Pengguna Umum: Menggunakan Aplikasi Mobile untuk booking ,
scan QR, dan pembayaran.
● Admin Mall: Mengelola operasional parkir, mengatur tarif, dan memantau
melalui Dashboard Admin.
● Super Admin/Manajemen Mall: Mengawasi laporan pendapatan lintas
lokasi dan audit log melalui Dashboard Web.
● Tim IT (Pengembang): Bertanggung jawab untuk pemeliharaan sistem,
skalabilitas, dan perbaikan berkelanjutan.
```
```
e. Metode Implementasi Proyek
● Pengujian Fungsi (Testing): Melakukan testing menyeluruh untuk
memastikan semua Kebutuhan Fungsional (F001 - F009) dan Kebutuhan
Non-Fungsional terpenuhi, termasuk performance testing untuk waktu
respons transaksi di bawah 3 detik.
● Implementasi Modul Simulasi: Membangun dan menguji API Gate Virtual
untuk memastikan simulasi scan QR dan pembayaran berjalan lancar
sebelum peluncuran.
● Pelatihan Pengguna: Memberikan panduan penggunaan aplikasi untuk
Driver dan pelatihan Dashboard Web untuk Admin/Super Admin.
```
## 3 DESKRIPSI RINCI KEBUTUHAN

Bagian ini menjelaskan secara rinci kebutuhan aplikasi QPARKIN yang diperlukan
untuk memenuhi tujuan proyek.

### 3.1 DESKRIPSI FUNGSIONAL

```
Tabel 3.1 Kebutuhan Fugsional
```
```
Kode Kebutuhan Fungsional
F001 Sistem harus menyediakan fitur registrasi dan login agar pengguna (driver),
admin, dan super admin dapat mengakses aplikasi menggunakan kredensial
yang sesuai.
F002 Sistem harus menyediakan fitur booking slot yang memungkinkan pengguna
(driver) memesan slot parkir, melihat informasi lokasi parkir, dan melakukan
pembayaran di muka.
```

```
F003 Sistem harus menyediakan fitur akses otomatis menggunakan scan QR untuk
masuk dan keluar area parkir yang disimulasikan langsung di dalam aplikasi
(tanpa integrasi perangkat IoT) oleh pengguna (driver).
F004 Sistem harus menyediakan simulator pembayaran digital di dalam aplikasi
yang mendukung opsi pembayaran seperti QRIS, e-wallet, TapCash, serta
mendukung mekanisme tukar poin yang dilakukan oleh pengguna (driver).
F005 Sistem harus memberikan reward poin setiap transaksi parkir atau booking
dan menyediakan manajemen poin, termasuk penggunaan poin untuk diskon
serta perhitungan penalti jika melebihi durasi booking.
F006 Sistem harus mengirimkan notifikasi real-time dan menyimpan riwayat
transaksi lengkap yang dapat diakses pengguna.
F007 Sistem harus menyediakan fitur bagi admin untuk mengelola data pengguna,
termasuk menambah, mengubah, atau menghapus data.
F
Sistem harus menyediakan fitur bagi admin untuk mengatur tarif parkir,
memantau aktivitas operasional melalui dashboard, serta mengakses laporan
keuangan otomatis dan audit log.
F009 Sistem harus menyediakan fitur bagi super admin untuk memantau laporan
pendapatan dari semua lokasi parkir, membandingkan performa antar lokasi,
dan mengakses audit log aktivitas admin.
```
#### 3.1.1 Use Case Diagram

Gambar yang tertera dibawah ini merupakan use case diagram dari sistem QPARKIN
yang digunakan untuk mewakili kebutuhan fungsional sistem secara keseluruhan.


```
Gambar 3.1.1 Use Case Diagram
```
#### 3.1.2 Use Case Melakukan Registrasi

3.1.2.1 Skenario Melakukan Registrasi

```
Tabel 3.1.2.1 Use Case Skenario Melakukan Registrasi
```
```
Identifikasi
```
```
Nomor UC
```
```
Nama Melakukan Registrasi.
```

**Tujuan** Memungkinkan _Driver_ mendaftarkan
akun baru agar dapat masuk ke dalam
sistem QPARKIN.

**Deskripsi** Fitur ini memungkinkan _Driver_ untuk
mendaftar sebagai pengguna baru dengan
mengisi data diri seperti nama, email, dan
kata sandi. Setelah proses registrasi
berhasil, _Driver_ akan memiliki akun
untuk masuk dan menggunakan fitur
parkir.

**Aktor** _Driver_

**Skenario Utama**

**Kondisi Awal**

_Driver_ belum memiliki akun dan berada di halaman utama aplikasi.

**Aksi Aktor
Reaksi Sistem**

1. _Driver_ membuka halaman
    registrasi.

```
Sistem menampilkan form registrasi.
```
2. _Driver_ mengisi nama, email dan
    kata sandi.

```
Sistem melakukan validasi format data
yang di- input.
```
3. _Driver_ menekan tombol " **Daftar** ". Jika data valid dan belum terdaftar,
    sistem menyimpan data dan
    menampilkan notifikasi " **Pendaftaran**
    **berhasil** ". Jika data tidak valid, sistem
    menampilkan pesan kesalahan yang
    sesuai.

**Skenario Alternatif**

**Aksi Aktor Reaksi Sistem**

_Driver_ mencoba untuk melakukan
pendaftaran dengan email atau nomor
telepon yang sudah terdaftar.

```
Sistem menampilkan pesan " Email
sudah digunakan. Silakan masuk. " dan
memberikan link ke halaman masuk.
```
_Driver_ mengisi kolom registrasi dengan
data yang tidak lengkap atau format salah
(misalnya, email tidak valid).

```
Sistem menampilkan pesan "Mohon
lengkapi semua kolom dengan format
yang benar." dan menyoroti kolom yang
bermasalah
```

```
Kondisi Akhir
```
```
Driver berhasil terdaftar dan bisa masuk menggunakan akun tersebut di masa depan.
```
#### 3.1.3 Use Case Melakukan Login

3.1.3.1 Skenario Melakukan Login

```
Tabel 3.1.3.1 Use Case Skenario Melakukan Login
```
```
Identifikasi
```
```
Nomor UC
```
```
Nama Melakukan Login.
```
```
Tujuan Memungkinkan pengguna ( Driver ,
Admin, dan Superadmin ) untuk masuk ke
dalam sistem menggunakan kredensial
(email dan kata sandi).
```
```
Deskripsi Fitur ini memungkinkan Driver , Admin,
dan Superadmin dapat melakukan masuk
ke dalam sistem menggunakan email
yang telah mereka daftarkan untuk
mengakses dashboard atau fitur sesuai
peran mereka.
```
```
Aktor Driver, Admin , Superadmin
```
```
Skenario Utama
```
```
Kondisi Awal
```
```
Pengguna sudah memiliki akun yang terdaftar dan berada di halaman utama aplikasi.
```
```
Aksi Aktor
Reaksi Sistem
```
1. Pengguna membuka halaman
    masuk.

```
Sistem menampilkan form masuk.
```
2. Pengguna mengisi email dan kata
    sandi.

```
Sistem memvalidasi input format data.
```

3. Pengguna menekan tombol
    " **Login** ".

```
Sistem memverifikasi email dan kata
sandi terhadap database. Jika valid,
sistem mengarahkan pengguna ke
dashboard yang sesuai dengan perannya.
Jika tidak valid, sistem menampilkan
pesan error.
```
```
Skenario Alternatif
```
```
Aksi Aktor Reaksi Sistem
```
```
Pengguna mengisi kredensial yang salah. Sistem menampilkan pesan " Email atau
kata sandi salah. "
```
```
Pengguna lupa kata sandi dan memilih
opsi " Lupa kata sandi ".
```
```
Sistem akan mengarahkan pengguna ke
proses pemulihan kata sandi (seperti
mengirimkan link reset via email).
```
```
Kondisi Akhir
```
```
Pengguna berhasil masuk ke sistem sesuai perannya ( Driver , Admin, atau
Superadmin ).
```
#### 3.1.4 Use Case Booking Slot Parkir

3.1.4.1 Skenario Booking Slot Parkir

```
Tabel 3.1.4.1 Use Case Skenario Booking Slot Parkir
```
```
Identifikasi
```
```
Nomor UC
```
```
Nama Booking Slot Parkir
```
```
Tujuan Memungkinkan Driver untuk memesan
slot parkir sebelum tiba di lokasi.
```
```
Deskripsi Driver dapat melihat ketersediaan slot
parkir, memilih lokasi, dan melakukan
booking untuk mendapatkan tiket parkir
digital (QR Code) yang valid untuk
waktu tertentu.
```
```
Aktor Driver
```

**Skenario Utama**

**Kondisi Awal**

_Driver_ sudah _login_ ke dalam sistem dan berada di halaman utama aplikasi.

**Aksi Aktor
Reaksi Sistem**

1. _Driver_ memilih menu "Booking
    Parkir".

```
Sistem menampilkan peta atau daftar
lokasi parkir dengan indikator
ketersediaan slot secara real-time.
```
2. _Driver_ memilih lokasi parkir dan
    memasukkan perkiraan waktu
    masuk.

```
Sistem menampilkan daftar slot yang
tersedia dan biaya estimasi.
```
3. _Driver_ memilih slot dan menekan
    tombol "Booking Sekarang".

```
Sistem mengunci slot parkir untuk Driver
tersebut dan menghasilkan tiket parkir
digital berupa QR Code.
```
4. _Driver_ menerima notifikasi
    _booking_ berhasil.

```
Sistem menampilkan QR Code, informasi
booking (lokasi, waktu booking ), dan
waktu kedaluwarsa booking jika Driver
tidak tiba tepat waktu.
```
**Skenario Alternatif**

**Aksi Aktor Reaksi Sistem**

_Driver_ mencoba _booking_ saat semua slot
di lokasi tersebut penuh.

```
Sistem menampilkan pesan "Parkir
penuh. Silakan coba lokasi lain atau
booking nanti."
```
Waktu _booking_ kedaluwarsa karena
_Driver_ tidak tiba tepat waktu.

```
Sistem secara otomatis membatalkan
booking , membebaskan slot, dan
mengirim notifikasi pembatalan kepada
Driver.
```
**Kondisi Akhir**

_Driver_ berhasil mendapatkan tiket parkir digital dan slot parkir siap digunakan.


#### 3.1.5 Use Case Scan QR Masuk/Keluar

3.1.5.1 Skenario Scan QR Masuk/Keluar

```
Tabel 3.1.5.1 Use Case Skenario Scan QR Masuk/Keluar
```
```
Identifikasi
```
```
Nomor UC
```
```
Nama Scan QR Masuk/Keluar
```
```
Tujuan Memungkinkan Driver menggunakan
tiket parkir digital (QR Code) untuk
mengakses palang masuk dan keluar area
parkir.
```
```
Deskripsi Driver memindai QR Code tiket parkir
yang telah di- booking atau yang baru
dibuat untuk mencatat waktu masuk dan
keluar, serta membuka palang parkir.
```
```
Aktor Driver
```
```
Skenario Utama
```
```
Kondisi Awal
```
```
Driver sudah berada di gerbang masuk/keluar parkir dan memiliki QR Code tiket
parkir (baik dari booking atau tiket baru).
```
```
Aksi Aktor
Reaksi Sistem
```
1. _Driver_ mengarahkan QR Code
    tiket parkir pada _scanner_ di
    gerbang masuk/keluar.

```
Sistem memindai dan memverifikasi QR
Code.
```
```
Saat Masuk: Jika QR Code valid, sistem
mencatat waktu masuk dan membuka
palang.
Saat Keluar: Jika QR Code valid dan
pembayaran telah selesai, sistem
mencatat waktu keluar dan membuka
palang.
```
2. _Driver_ melewati palang yang
    terbuka.

```
Sistem menutup palang.
```
```
Skenario Alternatif
```

```
Aksi Aktor Reaksi Sistem
```
```
Driver memindai QR Code yang
kedaluwarsa atau tidak valid.
```
```
Sistem menampilkan pesan "QR Code
tidak valid atau kedaluwarsa" dan palang
tetap tertutup.
```
```
Driver mencoba keluar sebelum
melakukan pembayaran (jika belum
booking atau durasi parkir melebihi
booking ).
```
```
Sistem menampilkan pesan "Mohon
selesaikan pembayaran parkir Anda" dan
palang tetap tertutup.
```
```
Kondisi Akhir
```
```
Driver berhasil masuk atau keluar area parkir, dan sistem mencatat waktu
masuk/keluar serta durasi parkir.
```
#### 3.1.6 Use Case Melakukan Pembayaran Digital

3.1.6.1 Skenario Melakukan Pembayaran Digital

```
Tabel 3.1.6.1 Use Case Skenario Melakukan Pembayaran Digital
```
```
Identifikasi
```
```
Nomor UC005
```
```
Nama Melakukan Pembayaran Digital
```
```
Tujuan Memungkinkan Driver untuk
menyelesaikan tagihan parkir
menggunakan metode pembayaran
digital.
```
```
Deskripsi Setelah memindai tiket keluar, sistem
menghitung biaya parkir dan Driver
dapat memilih metode pembayaran
digital (misalnya e-wallet, virtual
account ) untuk menyelesaikan transaksi.
```
```
Aktor Driver
```
```
Skenario Utama
```
```
Kondisi Awal
```

```
Driver telah menyelesaikan sesi parkir, memindai tiket keluar, dan sistem telah
menampilkan total biaya parkir.
```
```
Aksi Aktor
Reaksi Sistem
```
1. _Driver_ memilih opsi "Bayar
    Sekarang".

```
Sistem menampilkan rincian tagihan
(durasi, biaya) dan opsi metode
pembayaran digital.
```
2. _Driver_ memilih salah satu metode
    pembayaran (misalnya e-wallet).

```
Sistem mengarahkan ke halaman
pembayaran atau menampilkan kode
pembayaran (misalnya QRIS).
```
3. _Driver_ menyelesaikan
    pembayaran melalui aplikasi
    pembayaran yang dipilih.

```
Sistem menerima konfirmasi pembayaran
dari payment gateway.
```
```
Sistem mencatat transaksi sebagai lunas
dan mengirimkan notifikasi "Pembayaran
Berhasil".
```
```
Skenario Alternatif
```
```
Aksi Aktor Reaksi Sistem
```
```
Pembayaran gagal karena saldo tidak
mencukupi atau gangguan koneksi.
```
```
Sistem menampilkan pesan "Pembayaran
Gagal. Silakan coba lagi atau pilih
metode pembayaran lain."
```
```
Driver membatalkan pembayaran
sebelum selesai.
```
```
Sistem membatalkan proses pembayaran
dan Driver kembali ke halaman rincian
tagihan.
```
```
Kondisi Akhir
```
```
Pembayaran parkir lunas, dan Driver dapat memindai tiket keluar untuk membuka
palang.
```
#### 3.1.7 Use Case Manajemen Poin dan Penalti

3.1.7.1 Skenario Manajemen Poin dan Penalti

```
Tabel 3.1.7.1 Use Case Skenario Manajemen Poin dan Penalti
```
```
Identifikasi
```

**Nomor** UC006

**Nama** Manajemen Poin dan Penalti

**Tujuan** Memungkinkan _Driver_ untuk
mendapatkan poin _reward_ dan **sistem**
untuk menghitung penalti tambahan
biaya ( _overstay_ ).

**Deskripsi** _Driver_ mendapatkan poin _reward_ dari
setiap transaksi parkir yang berhasil.
**Sistem** secara otomatis menghitung dan
menerapkan penalti tambahan biaya jika
_Driver_ melebihi waktu _booking_ atau
durasi parkir yang diizinkan.

**Aktor** _Driver_

**Skenario Utama (Driver Mendapatkan Poin)**

**Kondisi Awal**

_Driver_ berhasil menyelesaikan pembayaran parkir.

**Aksi Aktor
Reaksi Sistem**

(Tidak ada aksi khusus, otomatis) Sistem menghitung jumlah poin yang
didapat berdasarkan total biaya parkir
atau aturan yang berlaku.

```
Sistem menambahkan poin ke saldo akun
Driver dan menampilkan notifikasi
perolehan poin.
```
**Skenario Utama (Penalti Otomatis Sistem - Overstay)**

**Kondisi Awal**

_Driver_ terlambat keluar melebihi waktu _booking_ atau durasi parkir yang diizinkan.

**Aksi Aktor
Reaksi Sistem**

1. _Driver_ memindai tiket keluar. Sistem menghitung selisih waktu.

(Tidak ada aksi khusus, otomatis) Sistem secara otomatis menerapkan
perhitungan tarif penalti ( _overstay_ ) ke
dalam total tagihan.


```
Skenario Alternatif
```
```
Aksi Aktor Reaksi Sistem
```
```
Driver mencoba menukarkan poin yang
jumlahnya tidak mencukupi untuk reward
tertentu.
```
```
Sistem menampilkan pesan " Poin tidak
mencukupi. "
```
```
Kondisi Akhir
```
```
Poin Driver bertambah dan/atau penalti overstay sudah dihitung ke dalam biaya
parkir.
```
#### 3.1.8 Use Case Melihat Riwayat Parkir

3.1.8.1 Skenario Melihat Riwayat Parkir

```
Tabel 3.1.8.1 Use Case Skenario Melihat Riwayat Parkir
```
```
Identifikasi
```
```
Nomor UC007
```
```
Nama Melihat Riwayat Parkir
```
```
Tujuan Memungkinkan Driver dan Admin
melihat daftar lengkap riwayat parkir
yang telah dilakukan.
```
```
Deskripsi Pengguna dapat melihat detail setiap sesi
parkir, termasuk waktu masuk, waktu
keluar, durasi, biaya, dan status
pembayaran.
```
```
Aktor Driver, Admin
```
```
Skenario Utama
```
```
Kondisi Awal
```
```
Pengguna telah login ke sistem.
```

```
Aksi Aktor
Reaksi Sistem
```
1. Pengguna membuka menu
    " **Riwayat Parkir** ".

```
Jika Driver : Sistem menampilkan
riwayat parkir Driver itu sendiri.
Jika Admin: Sistem menampilkan opsi
filter untuk mencari riwayat parkir
(berdasarkan tanggal, lokasi, atau
Driver).
```
2. Pengguna (Admin/ _Driver_ )
    memilih salah satu riwayat
    transaksi.

```
Sistem menampilkan detail transaksi
parkir (waktu, lokasi, durasi, biaya, status
pembayaran, dan poin/penalti yang
terkait).
```
```
Skenario Alternatif
```
```
Aksi Aktor Reaksi Sistem
```
```
Driver belum pernah melakukan parkir. Sistem menampilkan pesan " Belum ada
riwayat parkir yang tercatat. "
```
```
Admin memasukkan filter pencarian
yang tidak ditemukan datanya.
```
```
Sistem menampilkan pesan " Data
riwayat parkir tidak ditemukan. "
```
```
Kondisi Akhir
```
```
Pengguna berhasil melihat riwayat parkir yang tercatat.
```
#### 3.1.9 Use Case Memanajemen Data Pengguna

3.1.9.1 Skenario Memanajemen Data Pengguna

```
Tabel 3.1.9.1 Use Case Skenario Memanajemen Data Pengguna
```
```
Identifikasi
```
```
Nomor UC008
```
```
Nama Memanajemen Data Pengguna
```
```
Tujuan Memungkinkan calon Admin
mengajukan akun, dan Superadmin
memproses pengajuan serta mengelola
akun Admin yang sudah aktif.
```

**Deskripsi** Calon Admin dapat mengajukan
permohonan akun melalui _form_.
_Superadmin_ memiliki hak untuk
menyetujui, menolak, atau mengelola
data akun Admin yang sudah ada
(tambah, ubah, non-aktifkan).

**Aktor** Calon Admin _, Superadmin_

**Skenario Utama (Pengajuan Akun Admin)**

**Kondisi Awal**

Calon Admin belum memiliki akun dan berada di halaman _login_.

**Aksi Aktor
Reaksi Sistem**

1. Calon Admin menekan tombol
    " **Ajukan Akun Admin** ".

```
Sistem menampilkan form pengajuan
```
2. Calon Admin mengisi _form_ dan
    menekan tombol " **Kirim**
    **Pengajuan** ".

```
Sistem memvalidasi data dan menyimpan
pengajuan ke database dengan status
" Menunggu Persetujuan ".
```
```
(Pengajuan menunggu) Sistem mengirim notifikasi kepada
Superadmin mengenai pengajuan baru.
```
**Skenario Utama (Persetujuan/Penolakan Pengajuan oleh Superadmin)**

**Kondisi Awal**

Superadmin _login_ dan membuka menu " **Manajemen Pengguna** ”.

**Aksi Aktor
Reaksi Sistem**

_Superadmin_ melihat rincian pengajuan
dari Calon Admin dan memilih " **Setujui** "
atau " **Tolak** ".

```
Jika Disetujui , sistem membuat akun
Admin aktif, menetapkan kata sandi
awal, dan mengirim notifikasi ke Admin
baru. Jika Ditolak , sistem mencatat
penolakan dan mengirim notifikasi ke
Calon Admin.
```
**Skenario Alternatif (Superadmin Mengelola Akun Aktif)**

**Aksi Aktor
Reaksi Sistem**


```
Superadmin memilih akun Admin yang
sudah aktif untuk diubah data atau
perannya.
```
```
Sistem menampilkan form edit,
memungkinkan Superadmin
memperbarui data atau status akun
Admin tersebut.
```
```
Kondisi Akhir
```
```
Akun Admin telah berhasil dibuat dan diaktifkan, atau pengajuan telah diproses oleh
Superadmin.
```
#### 3.1.10 Use Case Mengatur Tarif Parkir

3.1.10.1 Skenario Mengatur Tarif Parkir

```
Tabel 3.1.10.1 Use Case Skenario Mengatur Tarif Parkir
```
```
Identifikasi
```
```
Nomor UC009
```
```
Nama Mengatur Tarif Parkir
```
```
Tujuan Memungkinkan Admin untuk
menetapkan, mengubah, dan mengelola
struktur tarif parkir untuk mall yang
menjadi tanggung jawabnya.
```
```
Deskripsi Admin dapat mengatur tarif harian
berdasarkan jenis kendaraan, durasi (jam
pertama, jam berikutnya, tarif maksimal),
sesuai kebijakan mall yang dikelolanya.
```
```
Aktor Admin
```
```
Skenario Utama
```
```
Kondisi Awal
```
```
Admin sudah login ke dalam sistem.
```
```
Aksi Aktor
Reaksi Sistem
```
1. Admin membuka menu
    " **Pengaturan Tarif Parkir** ".

```
Sistem menampilkan daftar tarif yang
berlaku saat ini untuk lokasi mall Admin
```

```
tersebut.
```
2. Admin memilih opsi " **Tambah**
    **Tarif Baru** " atau memilih tarif
    yang sudah ada untuk diubah.

```
Sistem menampilkan form untuk
memasukkan rincian tarif (jenis
kendaraan, tarif per jam, tarif maksimal
harian, dll.).
```
3. Admin mengisi _form_ dan
    menekan tombol " **Simpan**
    **Perubahan** ".

```
Sistem memvalidasi input. Jika valid,
sistem menyimpan konfigurasi tarif
baru/perubahan tarif ke database dan
menandainya sebagai berlaku efektif.
```
```
Sistem menampilkan notifikasi
" Pengaturan Tarif Berhasil
Diperbarui ".
```
```
Skenario Alternatif
```
```
Aksi Aktor Reaksi Sistem
```
```
Admin memasukkan konfigurasi tarif
yang bertentangan dengan batasan sistem
(misalnya: tarif jam berikutnya lebih
rendah dari jam pertama).
```
```
Sistem menampilkan pesan kesalahan
dan menolak penyimpanan.
```
```
Kondisi Akhir
```
```
Tarif parkir untuk mall yang dikelola Admin berhasil diperbarui dan diterapkan.
```
#### 3.1.11 Use Case Booking Slot Parkir

3.1.11.1 Interaksi Objek

```
Sequence Diagram 3.1.11.1 Booking Slot Parkir
```

```
Objek Deskripsi
```
```
Driver Aktor yang melakukan booking melalui
aplikasi.
```
```
UI_BookingSlot (View) Antarmuka mobile yang menampilkan
form booking dan hasil.
```
```
BookingController (Logic) Kelas yang menangani validasi,
perhitungan waktu, dan alokasi slot.
```
```
M_SlotParkir (Model) Kelas yang merepresentasikan status slot
dan ketersediaan.
```
```
M_Booking (Model) Kelas yang merepresentasikan data
booking yang baru dibuat.
```
```
DatabaseSystem (DB) Sistem basis data untuk penyimpanan dan
pembaruan data.
```
#### 3.1.12 Use Case Melakukan Pembayaran Digital


3.1.12.1 Interaksi Objek Melakukan Pembayaran Digital

```
Sequence Diagram 3.1.12.1 Melakukan Pembayaran Digital
```
```
Objek Deskripsi
```
```
Driver Aktor yang menyelesaikan pembayaran
melalui aplikasi.
```
```
UI_Pembayaran (View) Antarmuka mobile yang menampilkan
tagihan dan opsi pembayaran.
```
```
PaymentController (Logic) Kelas yang menangani perhitungan biaya,
validasi, dan koordinasi transaksi.
```
```
TarifModel (Model) Kelas yang menyimpan data tarif yang
berlaku.
```
```
M_Transaksi (Model) Kelas yang merepresentasikan data
transaksi parkir.
```
```
PaymentGatewaySim (External System) Modul simulasi pihak ketiga
(QRIS/E-Wallet) untuk memproses
pembayaran.
```
```
DatabaseSystem (DB) Sistem basis data untuk penyimpanan dan
pembaruan data transaksi.
```

#### 3.1.13 Use Case Mengatur Tarif Parkir

3.1.13.1 Interaksi Objek

```
Sequence Diagram 3.1.13.1 Mengatur Tarif Parkir
```
```
Objek Deskripsi
```
```
Admin Aktor yang memulai proses melalui web
dashboard.
```
```
UI_PengaturanTarif (View) Antarmuka web yang menampilkan form
dan daftar tarif.
```
```
TarifController (Logic) Kelas yang menangani logika bisnis,
validasi, dan koordinasi data.
```
```
TarifModel (Model) Kelas yang merepresentasikan struktur
data tarif parkir.
```
```
DatabaseSystem (DB) Sistem basis data yang menyimpan data
tarif.
```

### 3.2 DESKRIPSI KEBUTUHAN NON FUNGSIONAL

```
Tabel 3.2 Kebutuhan Non Fungsional
```
```
Kode Parameter Requirement
NF001 Availability Sistem harus tersedia 24/7 dan memiliki mekanisme
backup serta rencana pemulihan data jika terjadi gangguan
teknis.
NF002 Scalability Sistem harus mudah dikembangkan dan mampu menangani
peningkatan jumlah pengguna maupun transaksi parkir
tanpa mengurangi kinerja.
NF003 Usability Antarmuka aplikasi harus mudah digunakan oleh pengguna
(driver, admin, super admin) tanpa memerlukan pelatihan
khusus.
NF004 Performance Sistem harus memproses validasi QR dan transaksi
simulasi pembayaran dengan waktu respon kurang dari 3
detik agar tetap real-time.
NF005 Operating
Mode
```
```
Sistem harus dapat diakses melalui aplikasi mobile untuk
pengguna (driver) dan melalui browser desktop/web untuk
admin serta super admin.
NF006 Ergonomics Tampilan antarmuka harus responsif dan menyesuaikan
ukuran layar (mobile, tablet, dan desktop).
NF007 Security Sistem harus menggunakan enkripsi (misalnya SSL/TLS)
serta memastikan hanya pengguna terdaftar yang dapat
masuk dengan kredensial valid.
NF008 Integration Sistem harus mendukung integrasi dengan modul simulasi
internal (scan QR dan pembayaran) serta dapat diperluas
untuk integrasi ke perangkat IoT/hardware di masa depan.
NF009 Language Sistem harus menggunakan Bahasa Indonesia dan Bahasa
Inggris yang jelas dan mudah dipahami.
```
## 4 DESKRIPSI KELAS-KELAS

### 4.1 CLASS DIAGRAM

```
Class diagram sistem tiket parkir digital QPARKIN (Parkey) terdiri dari kelas
```
Pengguna, Driver, Admin, Booking, TransaksiParkir, SlotParkir, dan TarifParkir. Kelas

Pengguna menjadi dasar bagi Driver dan Admin yang menyimpan data otentikasi.

Driver melakukan booking, scan QR, dan pembayaran parkir, sedangkan Admin
mengelola slot parkir dan tarif. Booking mencatat pemesanan slot tertentu, sementara

TransaksiParkir merekam waktu masuk, keluar, dan total biaya berdasarkan TarifParkir.

Relasi antar kelas memastikan proses parkir berjalan terintegrasi, akurat, dan tercatat

dengan baik.


```
Gambar 4.1 Class Diagram
```
### 4.2 CLASS <PENGGUNA>

Kelas abstrak dasar ini menyimpan informasi otentikasi umum yang diwarisi oleh
Driver dan Admin.

```
Tabel 4.2 Class Pengguna
```
```
Atribut / Metode Visibility Tipe Data Keterangan
```
```
Atribut
```
```
id private int Kunci utama (PK)
untuk pengguna.
```
```
nama private string Nama lengkap
pengguna.
```
```
email private string Alamat email
(digunakan untuk
login).
```
```
password private string Kata sandi
```

```
terenkripsi.
```
```
Metode
```
```
login() public Fungsi untuk
otentikasi pengguna.
```
```
logout() public Fungsi untuk keluar
dari sistem.
```
### 4.3 CLASS <DRIVER>

Kelas ini mewarisi dari Pengguna dan menyimpan detail spesifik untuk pengguna
aplikasi mobile.

```
Tabel 4.3 Class Driver
```
```
Atribut / Metode Visibility Tipe Data Keterangan
```
```
Atribut
```
```
idDriver private int Kunci utama (id)
sebagai Driver.
```
```
noHP private string Nomor telepon
Driver.
```
```
noPlatKendaraan private string Nomor plat
kendaraan yang
digunakan.
```
```
jenisKendaraan private string Jenis kendaraan
(Mobil/Motor) untuk
tarif.
```
```
saldoEwallet private float Saldo internal untuk
simulasi pembayaran
(jika digunakan).
```
```
Metode
```
```
bookingSlot() public Membuat permintaan
pemesanan slot.
```
```
scanQR() public Memproses
pemindaian QR
(masuk/keluar).
```
```
bayarParkir() public Memulai proses
pembayaran.
```

```
topupEwallet() public Menambah saldo
e-wallet (simulasi).
```
### 4.4 CLASS <ADMIN>

Kelas ini mewarisi dari Pengguna dan berfungsi untuk mengelola operasional
sistem.

```
Tabel 4.4 Class Admin
```
```
Atribut / Metode Visibility Tipe Data Keterangan
```
```
Atribut
```
```
idAdmin private int Kunci utama (id)
sebagai Admin.
```
```
levelAkses private string Hak akses Admin
(Mall/Super Admin).
```
```
Metode
```
```
aturTarif() public Mengatur dan
menyimpan aturan
TarifParkir.
```
```
kelolaLaporan() public Mengakses dan
mengekspor laporan
transaksi.
```
```
kelolaSlotParkir() public Mengubah status
SlotParkir secara
manual (misalnya
Maintenance ).
```
### 4.5 CLASS <SLOTPARKIR>

Kelas ini merepresentasikan objek fisik slot parkir di lokasi.

```
Tabel 4.5.1 Class SlotParkir
```
```
Atribut / Metode Visibility Tipe Data Keterangan
```
```
Atribut
```
```
idSlot private int Kunci utama slot
parkir.
```
```
kodeSlot private string Kode unik slot
```

```
(misal: A01, B15).
```
```
lokasiParkir private string Area/lantai parkir.
```
```
statusSlot private string Status saat ini
( Available , Reserved ,
Occupied ,
Maintenance ).
```
```
jenisSlot private string Jenis slot ( Regular ,
Disable ).
```
```
Metode
```
```
getKetersediaan() public boolean Memeriksa apakah
slot tersedia.
```
```
updateStatus(newStat
us)
```
```
public Memperbarui status
slot.
```
### 4.6 CLASS <TARIFPARKIR>

```
Kelas ini menyimpan aturan biaya parkir yang berlaku.
```
```
Tabel 4.6.1 Class TarifParkir
```
```
Atribut / Metode Visibility Tipe Data Keterangan
```
```
Atribut
```
```
idTarif private int Kunci utama aturan
tarif.
```
```
jenisKendaraan private string Jenis kendaraan yang
dikenakan tarif.
```
```
tarifJamPertama private float Biaya untuk jam
pertama parkir.
```
```
tarifJamBerikutnya private float Biaya untuk jam-jam
berikutnya.
```
```
tarifMaksimumHaria
n
```
```
private float Batas biaya harian
(jika ada).
```
```
isActive private boolean Status apakah tarif
masih berlaku.
```
```
Metode
```
```
getTarif() public Mengembalikan
```

```
detail tarif.
```
```
updateTarif() public Menyimpan
perubahan aturan
tarif.
```
### 4.7 CLASS <BOOKING>

```
Kelas ini mencatat detail pesanan slot parkir yang dilakukan sebelum kedatangan.
```
```
Tabel 4.7.1 Class Booking
```
```
Atribut / Metode Visibility Tipe Data Keterangan
```
```
Atribut
```
```
idBooking private int Kunci utama
pesanan.
```
```
waktuMulai private datetime Waktu mulai booking
yang dipilih Driver.
```
```
waktuSelesaiEstimas
i
```
```
private datetime Waktu berakhir
estimasi booking.
```
```
qrCode private string String unik untuk QR
Code tiket.
```
```
statusBooking private string Status ( Active , Used ,
Expired , Canceled ).
```
```
Metode
```
```
createBooking() public Membuat catatan
booking baru.
```
```
generateQR() public Menghasilkan QR
Code unik.
```
```
cancelBooking() public Membatalkan
booking.
```
### 4.8 CLASS <TRANSAKSIPARKIR>

```
Kelas ini mencatat sesi parkir dari masuk hingga pembayaran lunas.
```
```
Tabel 4.8.1 Class TransaksiParkir
```
```
Atribut / Metode Visibility Tipe Data Keterangan
```

```
Atribut
```
```
idTransaksi private int Kunci utama
transaksi.
```
```
waktuMasuk private datetime Cap waktu saat
Driver scan masuk.
```
```
waktuKeluar private datetime Cap waktu saat
Driver scan keluar.
```
```
totalBiaya private float Total biaya parkir
yang harus dibayar.
```
```
statusPembayaran private string Status ( Pending ,
Paid , Failed ).
```
```
metodePembayaran private string Metode yang
digunakan ( QRIS ,
E-Wallet , dll.).
```
```
Metode
```
```
hitungBiaya() public float Menghitung biaya
berdasarkan durasi
dan tarif.
```
```
updatePembayaran(st
atus)
```
```
public Memperbarui status
pembayaran.
```
### 4.9 STATE MACHINE DIAGRAM


```
Gambar 4.9 State Machine Diagram
```
#### Deskripsi State Machine Diagram Transaksi Parkir

```
Diagram ini menggambarkan siklus hidup (lifecycle) dari entitas Transaksi
```
**Parkir** dalam sistem QPARKIN, yang diwakili oleh tabel transaksi_parkir dan booking.
Proses ini menunjukkan bagaimana status transaksi berubah dari awal pemesanan

hingga transaksi selesai atau berakhir.

**1. State Awal – Inisiasi Transaksi**
    **a. State: BelumAdaTransaksi**
       Kondisi awal di mana pengguna belum memiliki transaksi aktif.

```
Transisi:
```
```
b. Driver melakukan booking = sistem membuat entri baru di
transaksi_parkir (jenis_transaksi = 'booking') dan tabel booking. Status
berpindah ke TungguMasuk.
```

**2. State: TungguMasuk**
    Transaksi booking sudah dibuat (status aktif di tabel booking), namun kendaraan
    belum memasuki area parkir.
    **Transisi:**
       a. Driver scan QR masuk = sistem mengisi waktu_masuk di
          transaksi_parkir, lalu berpindah ke **ParkirAktif**.
       b. Waktu booking habis = sistem mengubah status menjadi expired,
          menghitung penalti, dan membebaskan slot parkir (melalui trigger
          trg_booking_after_update_penalty). Status berpindah ke **Expired**.
**3. State Aktivitas – Proses Parkir dan Pembayaran**

```
a. State: ParkirAktif
Kendaraan telah berada di dalam area parkir.
Transisi: Driver scan QR keluar = sistem menghitung biaya parkir
(durasi, biaya, penalti jika ada) dan membuat entri pembayaran dengan
status pending. Status berpindah ke TungguBayar.
```
```
b. State: TungguBayar
Biaya sudah dihitung dan pengguna perlu menyelesaikan pembayaran.
Transisi: Driver mulai bayar = sistem memproses pembayaran dan
berpindah ke PembayaranPending.
```
```
c. State: PembayaranPending
Pembayaran sedang diproses, misalnya menunggu konfirmasi dari
penyedia layanan (QRIS/Bank).
Transisi:
i. Pembayaran sukses = status di tabel pembayaran berubah
menjadi berhasil, sistem mencatat waktu_keluar di
transaksi_parkir, lalu berpindah ke Lunas.
ii. Pembayaran gagal = status kembali ke TungguBayar untuk
mencoba ulang.
```
**4. State Akhir – Penyelesaian Transaksi**

```
a. State: Lunas
Transaksi telah selesai. Pembayaran berhasil, kendaraan tercatat keluar,
dan slot parkir dikembalikan ke sistem.
Transisi: Transaksi diarsipkan = mencapai terminal state.
b. State: Expired
Transaksi booking dibatalkan karena pengguna tidak masuk sesuai
waktu yang ditentukan. Sistem dapat mengenakan penalti sesuai
kebijakan.
Transisi: Transaksi dihapus atau dibatalkan = mencapai terminal state.
```

## 5 DESKRIPSI DATA

### 5.1 ENTITY-RELATIONSHIP DIAGRAM

```
Gambar 5.1 Entity-Relationship Diagram
```
### 5.2 DAFTAR TABEL

**Daftar Tabel Basis Data QPARKIN**

```
Bagian ini memuat daftar tabel yang digunakan sebagai media penyimpanan data
```
( _data storage_ ) pada basis data sistem **QPARKIN**. Setiap tabel berfungsi untuk
menyimpan informasi yang mendukung proses autentikasi, transaksi parkir, manajemen

pengguna, hingga pemrosesan sistem internal.

**Tabel Utama**

```
a. user : Menyimpan data akun pengguna, meliputi id_user, name, email, password,
role (customer, admin_mall, super_admin), saldo_poin, dan status.
b. customer, admin_mall, super_admin : Menyimpan data lanjutan berdasarkan
peran pengguna, seperti nomor HP, mall yang dikelola, dan hak akses.
c. mall : Berisi data mall yang bekerja sama, mencakup nama_mall, lokasi,
kapasitas, dan alamat_gmaps.
d. gerbang : Menyimpan data gerbang parkir tiap mall beserta waktu pembuatan.
e. parkiran : Menyimpan data area parkir berdasarkan jenis kendaraan dan status
ketersediaan.
f. tarif_parkir : Menentukan tarif berdasarkan jenis kendaraan, jam pertama, dan
tarif per jam berikutnya.
g. kendaraan : Menyimpan data kendaraan milik pengguna seperti plat, jenis,
merk, dan tipe.
h. transaksi_parkir : Mencatat transaksi parkir, termasuk waktu masuk, keluar,
```

```
durasi, biaya, dan penalti.
i. booking : Menyimpan data pemesanan slot parkir dengan status aktif, selesai,
atau kedaluwarsa.
j. pembayaran : Mencatat detail pembayaran (metode, nominal, status, waktu
bayar).
k. riwayat_poin : Menyimpan catatan perubahan poin pengguna (penambahan atau
pengurangan).
l. notifikasi : Menyimpan pesan notifikasi pengguna beserta status keterbacaannya.
m. riwayat_gerbang : Mencatat aktivitas pembukaan atau penutupan gerbang
parkir.
```
**Tabel Sistem dan Otentikasi**

Tabel-tabel berikut mendukung fungsi internal sistem, autentikasi, dan keamanan data:

1. **cache** , **cache_locks** : Menyimpan data sementara dan penguncian cache.
2. **failed_jobs** , **jobs** , **job_batches** : Mengelola antrean pekerjaan dan pencatatan
    kegagalan eksekusi.
3. **migrations** : Menyimpan riwayat migrasi basis data.
4. **oauth_access_tokens** , **oauth_auth_codes** , **oauth_clients** , **oauth_device_codes** ,
    **oauth_refresh_tokens** : Mendukung sistem otentikasi berbasis OAuth.
5. **password_reset_tokens** : Menyimpan token untuk proses reset kata sandi.
6. **personal_access_tokens** : Menyimpan token akses pribadi untuk API.
7. **sessions** : Mencatat sesi login pengguna, termasuk IP dan _user agent_.

### 5.3 STRUKTUR TABEL <USER>

```
Tabel 5.3 user
```
```
Nama Tipe Data Panjang Key Deskripsi
```
```
id_user bigint UNSIGNED Primary Key ID unik
pengguna
```
```
name varchar 255 - Nama
pengguna
```
```
no_hp varchar 20 Unique Nomor HP
pengguna
```
```
email varchar 255 Unique Alamat email
pengguna
```
```
email_verifie
d_at
```
```
timestamp - - Tanggal dan
waktu
verifikasi
```

```
email
```
```
password varchar 255 - Kata sandi
pengguna
```
```
provider varchar 255 - Provider
otentikasi
pihak ketiga
(misalnya
Google)
```
```
provider_id varchar 255 - ID dari
provider
otentikasi
pihak ketiga
```
```
role enum ('customer','a
dmin_mall','s
uper_admin')
```
- Peran
    pengguna
    dalam sistem

```
saldo_poin int - - Saldo poin
yang dimiliki
pengguna
```
```
status enum ('aktif','non-a
ktif')
```
- Status
    keaktifan
    akun
    pengguna

```
remember_to
ken
```
```
varchar 100 - Token untuk
fungsi "ingat
saya"
```
```
created_at timestamp - - Tanggal dan
waktu
pembuatan
akun
```
```
updated_at timestamp - - Tanggal dan
waktu
pembaruan
terakhir
```
### 5.4 STRUKTUR TABEL <MALL>

```
Tabel 5.4 mall
```

```
Nama Tipe Data Panjang Key Deskripsi
```
```
id_mall bigint UNSIGNED Primary Key ID unik mall
```
```
nama_mall varchar 100 - Nama
lengkap mall
```
```
lokasi varchar 255 - Deskripsi
lokasi
(opsional)
```
```
kapasitas int - - Total
kapasitas
parkir mall
```
```
alamat_gmap
s
```
```
varchar 255 - Link atau
deskripsi
lokasi Gmaps
```
### 5.5 STRUKTUR TABEL <ADMIN_MALL>

```
Tabel 5.5 admin_mall
```
```
Nama Tipe Data Panjang Key Deskripsi
```
```
id_user bigint UNSIGNED Primary Key,
Foreign Key
```
```
ID pengguna
yang berperan
sebagai Admin
Mall
```
```
id_mall bigint UNSIGNED Foreign Key ID Mall yang
dikelola oleh
Admin
```
```
hak_akses varchar 50 - Hak akses
spesifik Admin
Mall
```
### 5.6 STRUKTUR TABEL <CUSTOMER>

```
Tabel 5.6 customer
```
```
Nama Tipe Data Panjang Key Deskripsi
```
```
id_user bigint UNSIGNED Primary Key,
Foreign Key
```
```
ID pengguna
yang berperan
sebagai
```

```
Customer
```
```
no_hp varchar 20 - Nomor HP
Customer
(redundansi
dari tabel user)
```
**5.7 Struktur Tabel <kendaraan>**

```
Tabel 5.7 kendaraan
```
```
Nama Tipe Data Panjang Key Deskripsi
```
```
id_kendaraan bigint UNSIGNED Primary Key ID unik
kendaraan
```
```
id_user bigint UNSIGNED Foreign Key ID pengguna
pemilik
kendaraan
```
```
plat varchar 20 Unique Nomor plat
kendaraan
```
```
jenis enum ('Roda
Dua','Roda
Tiga','Roda
Empat','Lebih
dari Enam')
```
```
Jenis
kendaraan
```
```
merk varchar 50 - Merk
kendaraan
```
```
tipe varchar 50 - Tipe/Model
kendaraan
```
### 5.8 STRUKTUR TABEL <GERBANG>

```
Tabel 5.8 gerbang
```
```
Nama Tipe Data Panjang Key Deskripsi
```
```
id_gerbang bigint UNSIGNED Primary Key ID unik
gerbang
```
```
id_mall bigint UNSIGNED Foreign Key ID Mall tempat
gerbang
berada
```

```
nama_gerbang varchar 255 - Nama atau
identitas
gerbang
(misalnya
"Gerbang
Masuk A")
```
```
lokasi varchar 255 - Deskripsi
lokasi fisik
gerbang
```
```
dibuat_pada datetime - - Tanggal dan
waktu
pembuatan
data gerbang
```
### 5.9 STRUKTUR TABEL <PARKIRAN>

```
Tabel 5.9 parkiran
```
```
Nama Tipe Data Panjang Key Deskripsi
```
```
id_parkiran bigint UNSIGNED Primary Key ID unik area
parkir/slot
```
```
id_mall bigint UNSIGNED Foreign Key ID Mall tempat
parkiran
berada
```
```
jenis_kendara
an
```
```
enum ('Roda
Dua','Roda
Tiga','Roda
Empat','Lebih
dari Enam')
```
```
Jenis
kendaraan
yang dilayani
parkiran ini
```
```
kapasitas int - - Jumlah slot
parkir yang
tersedia
```
```
status enum ('Tersedia','Ditu
tup')
```
- Status
    operasional
    area parkir

### 5.10 STRUKTUR TABEL <TARIF_PARKIR>

```
Tabel 5.10 tarif_parkir
```

```
Nama Tipe Data Panjang Key Deskripsi
```
```
id_tarif bigint UNSIGNED Primary Key ID unik tarif
parkir
```
```
id_mall bigint UNSIGNED Foreign Key ID Mall di
mana tarif ini
berlaku
```
```
jenis_kendara
an
```
```
enum ('Roda
Dua','Roda
Tiga','Roda
Empat','Lebih
dari Enam')
```
```
Jenis
kendaraan
yang
dikenakan tarif
```
```
satu_jam_pert
ama
```
```
decimal 10,2 - Biaya parkir
untuk satu jam
pertama
```
```
tarif_parkir_per
_jam
```
```
decimal 10,2 - Biaya parkir
untuk setiap
jam berikutnya
```
### 5.11 STRUKTUR TABEL <TRANSAKSI_PARKIR>

```
Tabel 5.11 transaksi_parkir
```
```
Nama Tipe Data Panjang Key Deskripsi
```
```
id_transaksi bigint UNSIGNED Primary Key ID unik
transaksi
parkir
```
```
id_user bigint UNSIGNED Foreign Key ID pengguna
yang
melakukan
transaksi
```
```
id_kendaraan bigint UNSIGNED Foreign Key ID kendaraan
yang terlibat
dalam
transaksi
```
```
id_mall bigint UNSIGNED Foreign Key ID Mall lokasi
parkir
```
```
id_parkiran bigint UNSIGNED Foreign Key ID area/slot
parkir yang
digunakan
```

```
jenis_transaksi enum ('umum','booki
ng')
```
- Tipe transaksi
    parkir

```
waktu_masuk datetime - - Waktu
kendaraan
masuk
```
```
waktu_keluar datetime - - Waktu
kendaraan
keluar
```
```
durasi int - - Total durasi
parkir (dalam
jam)
```
```
biaya decimal 10,2 - Total biaya
parkir (belum
termasuk
penalty)
```
```
penalty decimal 10,2 - Biaya penalty
(misalnya
karena
booking
expired)
```
### 5.12 STRUKTUR TABEL <BOOKING>

```
Tabel 5.12 booking
```
```
Nama Tipe Data Panjang Key Deskripsi
```
```
id_transaksi bigint UNSIGNED Primary Key,
Foreign Key
```
```
ID Transaksi
Parkir yang
terkait dengan
booking
```
```
waktu_mulai datetime - - Waktu mulai
booking
```
```
waktu_selesai datetime - - Waktu selesai
booking
```
```
durasi_bookin
g
```
```
int - - Durasi
booking
(dalam jam)
```
```
status enum ('aktif','selesai',
'expired')
```
- Status booking


```
dibooking_pad
a
```
```
datetime - - Waktu booking
dibuat
```
### 5.13 STRUKTUR TABEL <PEMBAYARAN>

```
Tabel 5.13 pembayaran
```
```
Nama Tipe Data Panjang Key Deskripsi
```
```
id_pembayaran bigint
UNSIGNED
```
- Primary Key ID unik
    pembayaran

```
id_transaksi bigint
UNSIGNED
```
- Foreign Key ID Transaksi
    Parkir yang
    dibayar

```
id_gerbang bigint
UNSIGNED
```
- Foreign Key ID Gerbang
    tempat
    pembayaran
    dilakukan

```
metode enum('qris','tap
cash','poin')
```
- - Metode
    pembayaran
    yang
    digunakan

```
nominal decimal(10,2) - - Jumlah
nominal yang
dibayar
```
```
status enum('pending'
,'berhasil','gaga
l')
```
- - Status
    pembayaran

```
waktu_bayar datetime - - Tanggal dan
waktu
pembayaran
```
### 5.14 STRUKTUR TABEL<RIWAYAT_POIN>

```
Tabel 5.14 riwayat_poin
```
```
Nama Tipe Data Panjang Key Deskripsi
```
```
id_poin bigint - Primary Key ID unik riwayat
```

```
UNSIGNED poin
```
```
id_user bigint
UNSIGNED
```
- Foreign Key ID pengguna
    yang saldonya
    berubah

```
id_transaksi bigint
UNSIGNED
```
- Foreign Key
    (opsional)

```
ID Transaksi
yang terkait
dengan
perubahan
poin (jika ada)
```
```
poin int - - Jumlah poin
yang
ditambahkan
atau dikurangi
```
```
perubahan enum('tambah'
,'kurang')
```
- - Jenis
    perubahan
    saldo poin

```
keterangan varchar(255) - - Deskripsi atau
alasan
perubahan
poin
```
```
waktu datetime - - Tanggal dan
waktu
terjadinya
perubahan
poin
```
### 5.15 STRUKTUR TABEL<NOTIFIKASI>

```
Tabel 5.15 notifikasi
```
```
Nama Tipe Data Panjang Key Deskripsi
```
```
id_notifikasi bigint
UNSIGNED
```
- Primary Key ID unik untuk
    setiap
    notifikasi

```
id_user bigint
UNSIGNED
```
- Foreign Key
    (opsional)

```
ID pengguna
penerima
notifikasi (jika
ditujukan ke
user tertentu)
```
```
pesan text - - Isi pesan atau
```

```
konten dari
notifikasi
```
```
waktu_kirim datetime - - Tanggal dan
waktu
notifikasi
dikirim
```
```
status enum('terbaca',
'belum')
```
- - Status
    notifikasi
    (apakah sudah
    dibaca atau
    belum)

### 5.16 STRUKTUR TABEL<RIWAYAT_GERBANG>

```
Tabel 5.16 riwayat_gerbang
```
```
Nama Tipe Data Panjang Key Deskripsi
```
```
id_riwayat_ger
bang
```
```
bigint
UNSIGNED
```
- Primary Key ID unik untuk
    setiap catatan
    riwayat
    perubahan
    gerbang

```
id_gerbang bigint
UNSIGNED
```
- Foreign Key ID gerbang
    yang statusnya
    mengalami
    perubahan

```
aksi enum('terbuka',
'tertutup')
```
- - Aksi yang
    dilakukan pada
    gerbang
    (membuka/me
    nutup)

```
status_sebelum enum('terbuka',
'tertutup')
```
- - Status gerbang
    sebelum aksi
    dilakukan

```
status_sesudah enum('terbuka',
'tertutup')
```
- - Status gerbang
    setelah aksi
    dilakukan

```
dibuat_pada timestamp - - Tanggal dan
```

```
waktu riwayat
perubahan
dicatat
```
### 5.17 STRUKTUR TABEL<SUPER_ADMIN>

```
Tabel 5.17 super_admin
```
```
Nama Tipe Data Panjang Key Deskripsi
```
```
id_user bigint
UNSIGNED
```
- Primary Key,
    Foreign Key

```
ID pengguna
yang berperan
sebagai Super
Admin
```
```
hak_akses varchar 50 - Hak akses
spesifik yang
dimiliki Super
Admin
```
### 5.18 SKEMA RELASI ANTAR TABEL

#### Deskripsi Relasi Antar Entitas Utama Basis Data QPARKIN

Basis data QPARKIN dirancang dengan sejumlah relasi kunci yang menghubungkan

data pengguna, mall, area parkir, dan transaksi agar sistem dapat beroperasi secara
terintegrasi dan konsisten. Berikut penjelasan tiap relasi utamanya:


**1. Relasi Pengguna (user) dan Entitas Terkait**

```
a. Tabel user berfungsi sebagai pusat identitas seluruh pengguna sistem.
b. user – customer / admin_mall / super_admin : Relasi One-to-One
(1:1). Setiap pengguna hanya memiliki satu peran spesifik yang
direpresentasikan di salah satu tabel peran, dengan id_user sebagai
primary key sekaligus foreign key.
c. user – kendaraan : Relasi One-to-Many (1:M). Satu pengguna dapat
memiliki banyak kendaraan, dihubungkan melalui id_user pada tabel
kendaraan.
d. user – transaksi_parkir / riwayat_poin / notifikasi : Relasi
One-to-Many (1:M). Seorang pengguna dapat melakukan banyak
transaksi parkir, memiliki beberapa riwayat poin, serta menerima
```
## berbagai notifikasi, semuanya terhubung lewat id_user.

## 2. Relasi Mall (mall) dan Entitas Terkait

```
a. Tabel mall menyimpan informasi lokasi parkir dan menjadi pusat bagi
pengelolaan area parkir.
b. mall – admin_mall : Relasi One-to-Many (1:M). Satu mall dapat memiliki
beberapa admin yang mengelolanya, dengan hubungan melalui id_mall
pada tabel admin_mall.
c. mall – gerbang / parkiran / tarif_parkir : Relasi One-to-Many (1:M).
Setiap mall memiliki banyak gerbang masuk/keluar, beberapa area
parkir, dan beragam jenis tarif, dihubungkan melalui id_mall.
d. mall – transaksi_parkir : Relasi One-to-Many (1:M). Setiap transaksi
parkir tercatat pada mall tempat transaksi tersebut terjadi.
```
3. **Relasi Transaksi Parkir (transaksi_parkir) dan Detailnya**

```
Tabel transaksi_parkir mencatat seluruh sesi parkir pengguna, baik yang
bersifat umum maupun hasil booking.
a. transaksi_parkir – booking : Relasi One-to-One (1:1). Setiap transaksi
dengan jenis booking memiliki satu detail pemesanan yang tersimpan di
tabel booking , terhubung melalui id_transaksi.
b. transaksi_parkir – pembayaran : Relasi One-to-One (1:1). Setiap
transaksi parkir memiliki satu catatan pembayaran di tabel pembayaran.
c. transaksi_parkir – kendaraan / mall / parkiran : Relasi Many-to-One
(M:1). Setiap transaksi terkait dengan satu kendaraan, satu mall, dan satu
area parkir tertentu.
d. transaksi_parkir – riwayat_poin : Relasi One-to-Many (1:M). Satu
transaksi dapat menghasilkan beberapa perubahan poin, baik
penambahan (bonus) maupun pengurangan (penalty).
```
4. **Relasi Gerbang (gerbang) dan Aktivitasnya**

```
Tabel gerbang merekam aktivitas keluar-masuk kendaraan di setiap mall.
```

```
gerbang – pembayaran / riwayat_gerbang : Relasi One-to-Many (1:M). Satu
gerbang dapat memiliki banyak catatan pembayaran yang dilakukan saat keluar
serta riwayat perubahan status buka/tutup gerbang, terhubung melalui
id_gerbang.
```
## 6 PERANCANGAN ANTARMUKA

### 6.1 ANTARMUKA MOBILE

```
Welcome Page Login Page
```


**Sign Up Page Forgot Password Page**


**Verify Code Confirm Page**


**Change Password Home**


**Scan QR Masuk - Manual History Page**


**Activitas Page Barcode QR (untuk keluar)**


**Peta Perbelanjaan Terdekat Lokasi Perbelanjaan**


**Jenis Kendaraan Page Lokasi Area Parkir Perbelanjaan**


**Batch Parkir Pusat Perbelanjaan Detail Booking Area Parkir**


**QR Pembayaran QR Booking - Masuk**


**Ubah Informasi Akun Page Dropdown Status pada Ubah Informasi
Akun**


**List Kendaraan Page Form Tambah Kendaraan**


**Dropdown Tipe Customer pada Form
Tambah Kendaraan**

```
Daftar Kendaraan yang Sudah Ditambahkan
```

**Bantuan Page Kebijakan Privasi Page**


**Tentang Aplikasi Page**


## 7 MATRIKS KETERUNUTAN

Matriks Keterunutan Kebutuhan Desain dan Implementasi

Implementasi untuk sistem **QPARKIN** saat ini masih berada pada tahap **desain dan
implementasi** , sehingga pengujian sistem belum dilakukan.
Matriks keterunutan berikut disusun untuk memetakan setiap **Kebutuhan Fungsional (FR)**
terhadap elemen desain utama yang merealisasikannya, meliputi:

```
a. Use Case , yang menggambarkan interaksi antara aktor dan sistem,
b. Class/Controller , yang merepresentasikan logika dan fungsi utama sistem,
c. Tabel Database , yang digunakan untuk menyimpan data terkait kebutuhan tersebut,
serta.
d. Antarmuka Pengguna (UI) , yang menjadi tampilan interaksi bagi pengguna.
```
```
Tabel 7.1 Matriks Keterunutan Kebutuhan Desain dan Impelementasi
```
```
ID Kebutuhan
Fungsional
```
```
ID Use Case Nama
Class/Controlle
r
```
```
Nama Tabel
(Database)
```
```
Nama
Antarmuka
(UI)
```
```
FR-01 UC-01 UserController user, kendaraan Form Registrasi
& Kelola
Kendaraan
```
```
FR-02 UC-02 BookingControll
er
```
```
booking,
transaksi_parkir,
parkiran
```
```
Halaman
Booking Slot
Parkir
```
```
FR-03 UC-03 GateController transaksi_parkir,
gerbang,
riwayat_gerbang
```
```
QR Scanner
(Gerbang
Masuk/Keluar)
```
```
FR-04 UC-04 TransactionCont
roller
```
```
transaksi_parkir,
tarif_parkir
```
```
Halaman Detail
Transaksi Parkir
```
```
FR-05 UC-05 PaymentControll pembayaran, Halaman
Pembayaran
```

```
er transaksi_parkir (Pilih Metode)
```
```
FR-06 UC-06 PointController riwayat_poin,
user
```
```
Halaman
Riwayat Poin &
Saldo Poin
```
```
FR-07 UC-07 PenaltyControlle
r
```
```
booking,
transaksi_parkir
```
```
Notifikasi
Penalty
(Pop-up/Detail
Transaksi)
```
```
FR-08 UC-08 PointController riwayat_poin,
transaksi_parkir
```
```
Halaman
Riwayat Poin
(Bonus)
```
```
FR-09 UC-09 AdminMallContr
oller
```
```
transaksi_parkir,
mall,
admin_mall
```
```
Dashboard
Admin Mall
(Laporan
Transaksi)
```
Dengan demikian, matriks ini menunjukkan keterhubungan antara **spesifikasi kebutuhan
perangkat lunak** dengan **komponen desain dan implementasi** yang sedang dikembangkan.


