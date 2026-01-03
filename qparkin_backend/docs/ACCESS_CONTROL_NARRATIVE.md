# QParkin Access Control - Rancangan Naratif

## Konsep Dasar Sistem Akses

Sistem QParkin dirancang dengan pendekatan Role-Based Access Control (RBAC) yang membagi pengguna ke dalam empat tingkatan hierarki yang jelas. Setiap tingkatan memiliki batasan akses yang berbeda sesuai dengan tanggung jawab dan kebutuhan operasional mereka. Sistem ini memastikan bahwa setiap pengguna hanya dapat mengakses fitur dan data yang relevan dengan peran mereka, sehingga menjaga keamanan dan integritas data aplikasi.

Hierarki akses dimulai dari Super Admin di puncak yang memiliki kontrol penuh atas seluruh sistem, diikuti oleh Mall Manager yang mengelola operasional mall tertentu, kemudian Security/Operator yang menangani operasional harian, dan terakhir Regular User yang menggunakan aplikasi mobile untuk keperluan parkir. Setiap level memiliki batasan yang jelas dan tidak dapat mengakses fitur yang berada di atas level mereka.

## Super Admin - Kendali Penuh Sistem

Super Admin merupakan level tertinggi dalam sistem QParkin yang memiliki akses tidak terbatas ke seluruh fitur dan data aplikasi. Mereka bertanggung jawab atas manajemen strategis dan operasional tingkat enterprise. Super Admin dapat mengelola seluruh mall yang terdaftar dalam sistem, termasuk menambah, mengubah, atau menghapus data mall. Mereka juga memiliki wewenang untuk menyetujui atau menolak pengajuan pendaftaran mall baru yang masuk ke sistem.

Dalam aspek pelaporan, Super Admin dapat mengakses laporan global yang mencakup seluruh mall, memberikan mereka pandangan menyeluruh tentang performa bisnis. Mereka juga bertanggung jawab atas manajemen pengguna di seluruh sistem, termasuk mengassign role kepada pengguna baru dan mengubah role pengguna yang sudah ada. Konfigurasi sistem seperti pengaturan global, parameter aplikasi, dan maintenance sistem juga berada di bawah kendali Super Admin. Selain itu, mereka memiliki akses penuh ke audit logs untuk monitoring aktivitas sistem dan investigasi jika terjadi masalah keamanan.

## Mall Manager - Pengelola Operasional Mall

Mall Manager atau Admin Mall memiliki fokus pada pengelolaan operasional mall tertentu yang telah diassign kepada mereka. Mereka tidak dapat mengakses data atau mengubah pengaturan mall lain, sehingga menjaga privasi dan keamanan data antar mall. Mall Manager memiliki akses penuh ke dashboard analytics yang menampilkan data performa parkir, revenue, dan statistik penggunaan khusus untuk mall mereka.

Dalam pengelolaan parkiran, Mall Manager dapat menambah, mengubah, atau menghapus area parkir, mengatur kapasitas, dan mengelola layout parkiran sesuai kebutuhan mall. Mereka juga memiliki kontrol penuh atas pengaturan tarif parkir, termasuk membuat skema tarif yang berbeda untuk berbagai jenis kendaraan atau waktu tertentu. Pengelolaan tiket parkir juga menjadi tanggung jawab mereka, mulai dari melihat tiket yang aktif, menangani dispute, hingga melakukan refund jika diperlukan.

Mall Manager dapat mengelola sistem notifikasi untuk mall mereka, termasuk mengatur pesan promosi, pengumuman maintenance, atau informasi penting lainnya kepada pengguna. Mereka juga dapat mengupdate profil mall dan informasi operasional seperti jam buka, kontak, dan fasilitas yang tersedia. Namun, mereka tidak memiliki akses untuk menyetujui pengajuan mall baru atau mengakses data mall lain demi menjaga kerahasiaan bisnis.

## Security/Operator - Pelaksana Operasional Harian

Security atau Operator merupakan pengguna yang menangani operasional parkir sehari-hari di lapangan. Mereka memiliki akses terbatas yang fokus pada tugas operasional tanpa kemampuan untuk mengubah pengaturan strategis. Security dapat melihat dashboard mall dalam mode read-only untuk memantau status parkiran secara real-time, termasuk jumlah slot yang tersedia, tingkat okupansi, dan tren penggunaan.

Tugas utama Security adalah melakukan scan QR code dan validasi tiket parkir ketika kendaraan masuk atau keluar. Mereka dapat melihat detail tiket, memverifikasi pembayaran, dan memproses entry/exit secara digital. Dalam situasi tertentu dimana sistem QR mengalami gangguan, Security juga dapat melakukan input manual untuk entry dan exit kendaraan dengan mencatat nomor plat dan waktu secara manual dalam sistem.

Security menerima notifikasi operasional yang relevan dengan tugas mereka, seperti alert ketika parkiran hampir penuh, notifikasi tiket yang bermasalah, atau instruksi khusus dari Mall Manager. Namun, mereka tidak memiliki akses untuk mengubah tarif parkir, mengelola area parkiran, atau mengakses data finansial mall. Batasan ini memastikan bahwa perubahan strategis hanya dapat dilakukan oleh level yang berwenang.

## Regular User - Pengguna Aplikasi Mobile

Regular User adalah pengguna akhir yang menggunakan aplikasi mobile QParkin untuk keperluan parkir mereka. Mereka tidak memiliki akses ke sistem web admin dan hanya berinteraksi melalui API endpoints yang dirancang khusus untuk mobile application. Proses dimulai dari registrasi dan login melalui aplikasi mobile, dimana mereka dapat menggunakan email/password atau login sosial seperti Google Sign-In.

Fitur utama yang dapat diakses Regular User adalah booking slot parkir di mall yang mereka tuju. Mereka dapat melihat ketersediaan slot secara real-time, memilih durasi parkir, dan melakukan reservasi. Setelah booking berhasil, sistem akan generate QR code yang berfungsi sebagai tiket digital untuk entry dan exit. Proses pembayaran juga terintegrasi dalam aplikasi, mendukung berbagai metode pembayaran digital.

Regular User dapat melihat history parkir mereka, termasuk detail waktu, lokasi, durasi, dan biaya untuk setiap sesi parkir. Mereka juga menerima notifikasi personal seperti reminder waktu parkir hampir habis, konfirmasi pembayaran, atau informasi promosi dari mall. Namun, mereka tidak dapat mengakses data pengguna lain, informasi operasional mall, atau fitur administratif apapun.

## Implementasi Keamanan dan Monitoring

Sistem keamanan diimplementasikan berlapis dengan autentikasi yang berbeda untuk setiap platform. API mobile menggunakan JWT tokens untuk memastikan setiap request terautentikasi, sementara web admin menggunakan session-based authentication dengan CSRF protection. Super Admin accounts dilengkapi dengan two-factor authentication (2FA) untuk lapisan keamanan tambahan mengingat level akses mereka yang tinggi.

Setiap akses data dibatasi berdasarkan scope mall, dimana pengguna hanya dapat mengakses data mall yang telah diassign kepada mereka. Implementasi ini dilakukan melalui middleware yang secara otomatis memfilter query database berdasarkan mall_id yang terkait dengan user. Permission checking juga dilakukan di level controller untuk memastikan setiap action telah diotorisasi dengan benar.

Sistem audit logging mencatat seluruh aktivitas penting seperti login/logout, perubahan role, modifikasi data, dan percobaan akses yang gagal. Monitoring real-time dilakukan untuk mendeteksi pola akses yang mencurigakan, percobaan privilege escalation, atau aktivitas yang tidak normal. Alert otomatis akan dikirim kepada Super Admin jika terdeteksi aktivitas yang berpotensi membahayakan keamanan sistem.

## Strategi Pengembangan dan Maintenance

Implementasi access control dilakukan secara bertahap mulai dari core RBAC system, kemudian mall scoping, fine-grained permissions, dan terakhir advanced features. Setiap fase diuji secara menyeluruh dengan unit tests, feature tests, dan integration tests untuk memastikan sistem berjalan sesuai spesifikasi dan tidak ada celah keamanan.

Maintenance sistem meliputi regular security audit, update permission matrix sesuai kebutuhan bisnis yang berkembang, dan monitoring performa sistem. Documentation akan selalu diupdate seiring dengan perubahan sistem, dan training akan diberikan kepada pengguna baru untuk memastikan mereka memahami batasan dan tanggung jawab sesuai role mereka.

Sistem ini dirancang untuk scalable dan flexible, sehingga dapat dengan mudah diadaptasi ketika ada penambahan role baru, perubahan business process, atau integrasi dengan sistem eksternal. Arsitektur modular memungkinkan pengembangan fitur baru tanpa mengganggu sistem yang sudah berjalan, sementara comprehensive logging memastikan setiap perubahan dapat ditrack dan di-rollback jika diperlukan.