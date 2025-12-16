# **BAB I PENDAHULUAN** 
1. **Deskripsi Umum Perangkat Lunak PBL** 

   QPARKIN  merupakan  aplikasi  parkir  digital  berbasis  mobile  yang  dikembangkan dalam rangka kegiatan Project Based Learning (PBL) pada Program Studi Teknologi Rekayasa Perangkat Lunak. Aplikasi ini dirancang untuk menggantikan sistem tiket parkir konvensional dengan  solusi  digital  terintegrasi  yang  memanfaatkan  QR  Code,  aplikasi  mobile,  dan pembayaran non-tunai, khususnya pada area parkir pusat perbelanjaan. 

   Aplikasi  ini  berfungsi  sebagai  sistem  end-to-end  parking  management,  yang mencakup  proses  registrasi pengguna, booking slot parkir, validasi masuk dan keluar area parkir  melalui  pemindaian  QR  Code,  hingga  pembayaran  digital  dan  pencatatan  riwayat transaksi. Sistem ini ditujukan untuk meningkatkan efisiensi operasional, mengurangi antrean di gerbang parkir, serta meningkatkan transparansi dan keamanan data transaksi parkir. 

   Dari sisi teknologi, QPARKIN dibangun menggunakan arsitektur client–server dengan pembagian sebagai berikut: 

1. Frontend  Mobile  dikembangkan  menggunakan  Flutter  (bahasa  Dart)  untuk platform Android, berfungsi sebagai antarmuka utama bagi pengguna (driver). 
1. Frontend  Web  Admin  dikembangkan  menggunakan  Laravel,  digunakan  oleh Admin Mall dan Super Admin untuk monitoring dan manajemen sistem. 
1. Backend  Server  menangani  logika  bisnis,  autentikasi,  validasi  transaksi, manajemen booking, perhitungan tarif, penalti, dan poin. 
1. Sistem Basis Data menggunakan MySQL, berperan sebagai penyimpanan terpusat untuk  data  pengguna,  kendaraan,  transaksi  parkir,  pembayaran,  dan  log operasional. 
1. Web  Service  API  digunakan  sebagai  penghubung  antara  aplikasi  mobile, dashboard admin, serta simulasi gerbang parkir (API Gate Virtual). 

Sistem  QPARKIN  mendukung  beberapa  peran  pengguna,  yaitu  Customer  (Driver), Admin  Mall,  dan  Super  Admin,  yang  masing-masing  memiliki  hak akses dan kewenangan berbeda. Pembagian peran ini menjadi dasar dalam penerapan kontrol akses (access control) dan perancangan keamanan basis data. Dengan adanya QPARKIN, diharapkan proses parkir menjadi lebih cepat, aman, dan terukur, sekaligus memberikan kemudahan bagi pengelola dalam melakukan monitoring operasional dan pelaporan keuangan secara real-time 

2. **User Stories** 

   `           `Berikut adalah user story yang menjadi dasar analisis risiko keamanan basis data pada aplikasi QPARKIN: 

   **US-01 Registrasi dan Login** 

   ` `Sebagai pengguna (driver), saya ingin dapat melakukan registrasi dan login ke aplikasi agar saya bisa mengakses fitur booking, pembayaran, dan riwayat transaksi. 

   **US-02 Booking Slot Parkir** 

   Sebagai driver, saya ingin dapat memesan slot parkir agar saya memiliki jaminan tempat parkir di pusat perbelanjaan. 

   **US-03 Akses Masuk dan Keluar Menggunakan QR Code** 

   Sebagai driver, saya ingin menggunakan scan QR untuk masuk dan keluar area parkir agar proses lebih cepat tanpa tiket fisik. 

   **US-04 Pembayaran Digital** 

   Sebagai driver, saya ingin dapat melakukan pembayaran melalui simulasi digital (QRIS, e-wallet, TapCash, poin) agar transaksi lebih fleksibel. 

   **US-05 Manajemen Poin dan Penalti** 

   Sebagai driver, saya ingin mendapatkan poin dari transaksi agar dapat saya gunakan sebagai diskon, sekaligus mengetahui penalti jika melewati durasi booking. 

   **US-06 Notifikasi dan Riwayat Transaksi** 

   Sebagai driver, saya ingin menerima notifikasi dan melihat riwayat transaksi agar saya dapat memantau status booking dan pembayaran saya. 

   **US-07 Manajemen Data Pengguna** 

   Sebagai admin, saya ingin dapat mengelola data pengguna agar sistem tetap terorganisir dan data yang tidak relevan bisa diperbarui. 

   **US-08 Pengaturan Tarif dan Laporan** 

   Sebagai admin, saya ingin mengatur tarif, memantau aktivitas parkir, dan melihat laporan keuangan agar saya bisa mengawasi operasional dengan baik. 

   **US-09 Monitoring oleh Super Admin** 

   Sebagai super admin, saya ingin memantau laporan pendapatan semua lokasi parkir dan audit log admin agar saya dapat membandingkan performa antar lokasi. 

   Skenario penggunaan secara rinci untuk setiap user story telah didokumentasikan dalam dokumen SKPPL. Pada laporan ini, user stories digunakan sebagai dasar identifikasi area risiko keamanan basis data dan kontrol pengamanan yang diperlukan. 
   ### *Tabel 1.1 Pemetaan User Stories terhadap Area Risiko Basis Data*

|**Kode US** |**Fitur Utama** |**Area Risiko Basis Data** |
| - | - | - |
|US-01 |Registrasi & Login |Kebocoran data pengguna, autentikasi |
|US-02 |Booking Parkir |Manipulasi data booking |
|US-03 |QR Masuk/Keluar |Validasi transaksi parkir |
|US-04 |Pembayaran |Integritas transaksi keuangan |
|US-05 |Poin & Penalti |Konsistensi data poin |
|US-09 |Monitoring Admin |Akses tidak sah, audit log |

User story yang tidak dicantumkan dalam tabel ini tetap didukung oleh sistem, namun memiliki keterkaitan risiko yang lebih dominan pada lapisan aplikasi dan kontrol akses, sehingga tidak menjadi fokus utama dalam analisis risiko keamanan basis data. 

3. **Skema Basis Data** 

   Basis data QPARKIN dirancang menggunakan sistem manajemen basis data relasional MySQL  dengan  tujuan  menjamin  konsistensi  data,  integritas  referensial,  dan  keamanan transaksi parkir. Struktur basis data disusun berdasarkan kebutuhan fungsional sistem, peran pengguna, serta proses bisnis parkir digital yang diimplementasikan. Secara konseptual, basis data QPARKIN terdiri dari beberapa kelompok entitas utama sebagai berikut: 
   ### *Tabel 1.2 Ringkasan Entitas Utama Basis Data Qparkin* 

|**Kelompok Entitas** |**Nama Tabel** |**Fungsi Utama** |
| - | - | - |
|Pengguna & Hak Akses |user |Menyimpan data akun dan autentikasi pengguna |
||customer |Data tambahan pengguna parkir |
||admin\_mall |Relasi admin dengan mall |
||super\_admin |Data administrator sistem |
|Kendaraan & Lokasi |kendaraan |Data kendaraan pengguna |



||mall |Informasi pusat perbelanjaan |
| :- | - | - |
||parkiran |Data slot dan kapasitas parkir |
||gerbang |Data gerbang masuk dan keluar |
|Transaksi & Booking |transaksi\_parkir |Data transaksi parkir |
||booking |Data pemesanan parkir |
||riwayat\_gerbang |Riwayat keluar-masuk kendaraan |
|Pembayaran & Poin |pembayaran |Data pembayaran parkir |
||riwayat\_poin |Histori poin pengguna |
|Keamanan & Audit |notifikasi |Pesan dan peringatan sistem |
||oauth\_\* |Manajemen token autentikasi API |

Struktur  ini  dirancang  untuk  mendukung  kebutuhan  monitoring,  audit  keamanan, dan manajemen risiko basis data, khususnya terhadap kehilangan data, manipulasi transaksi, dan penyalahgunaan akses. Skema basis data QPARKIN secara keseluruhan telah disesuaikan dengan proses bisnis parkir digital serta mendukung penerapan kontrol keamanan melalui validasi input, pembatasan akses berbasis peran, dan otomatisasi logika bisnis di tingkat basis data. 
