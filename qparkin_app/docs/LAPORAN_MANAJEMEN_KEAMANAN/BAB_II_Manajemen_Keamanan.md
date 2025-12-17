# **BAB II MONITORING DESAIN DAN SISTEM KEAMANAN** 
1. **Struktur Database Awal** 
#### *Gambar 2.1 Sturuktur Database Awal* 
![](Aspose.Words.7bf85e6c-d5fd-49f1-9ca8-69b3e70ce000.001.jpeg)

2. **Rancangan Access Control**
1. **Konsep Dasar Sistem Akses** 

   Sistem  QParkin  dirancang  dengan  pendekatan  Role-Based  Access  Control (RBAC) yang membagi pengguna ke dalam tiga tingkatan hierarki yang jelas. Setiap tingkatan memiliki batasan akses yang berbeda sesuai dengan tanggung jawab dan kebutuhan  operasional  mereka.  Sistem  ini  memastikan  bahwa  setiap  pengguna hanya dapat mengakses fitur dan data yang relevan dengan peran mereka, sehingga menjaga keamanan dan integritas data aplikasi. 

   Hierarki  akses  dimulai  dari  Super  Admin  di  puncak  yang  memiliki kontrol penuh  atas seluruh sistem, diikuti oleh Mall Manager yang mengelola operasional mall  tertentu  dan  terakhir  Regular User yang menggunakan aplikasi mobile untuk keperluan parkir. Setiap level memiliki batasan yang jelas dan tidak dapat mengakses fitur yang berada di atas level mereka.

2. **Super Admin - Kendali Penuh Sistem** 

   Super Admin merupakan level tertinggi dalam sistem QParkin yang memiliki akses tidak terbatas ke seluruh fitur dan data aplikasi. Mereka bertanggung jawab atas  manajemen  strategis  dan  operasional  tingkat  enterprise. Super Admin dapat mengelola  seluruh  mall  yang  terdaftar  dalam  sistem,  termasuk  menambah, mengubah,  atau  menghapus  data  mall.  Mereka  juga  memiliki  wewenang  untuk menyetujui atau menolak pengajuan pendaftaran mall baru yang masuk ke sistem. 

   Dalam aspek pelaporan, Super Admin dapat mengakses laporan global yang mencakup  seluruh  mall,  memberikan  mereka  pandangan  menyeluruh  tentang performa  bisnis.  Mereka  juga  bertanggung  jawab  atas  manajemen  pengguna  di seluruh  sistem,  termasuk  mengassign  role  kepada  pengguna baru dan mengubah role  pengguna  yang  sudah  ada.  Konfigurasi  sistem  seperti  pengaturan  global, parameter  aplikasi,  dan  maintenance  sistem  juga  berada  di  bawah  kendali Super Admin.  Selain  itu,  mereka  memiliki  akses  penuh  ke  audit  logs  untuk  monitoring aktivitas sistem dan investigasi jika terjadi masalah keamanan. 

3. **Mall Manager - Pengelola Operasional Mall** 
   ##### Mall Manager atau Admin Mall memiliki fokus pada pengelolaan operasional mall  tertentu  yang  telah  diassign  kepada mereka. Mereka tidak dapat mengakses data atau mengubah pengaturan mall lain, sehingga menjaga privasi dan keamanan data  antar  mall. Mall Manager memiliki akses penuh ke dashboard analytics yang menampilkan data performa parkir, revenue, dan statistik penggunaan khusus untuk mall mereka. 
   ##### Dalam  pengelolaan  parkiran,  Mall Manager dapat menambah, mengubah, atau  menghapus  area  parkir,  mengatur  kapasitas,  dan  mengelola  layout  parkiran sesuai  kebutuhan  mall.  Mereka juga memiliki kontrol penuh atas pengaturan tarif parkir, termasuk membuat skema tarif yang berbeda untuk berbagai jenis kendaraan atau waktu tertentu. Pengelolaan tiket parkir juga menjadi tanggung jawab mereka, mulai dari melihat tiket yang aktif, menangani dispute, hingga melakukan refund jika diperlukan. 
   ##### Mall  Manager  dapat  mengelola  sistem  notifikasi  untuk  mall  mereka, termasuk  mengatur  pesan  promosi,  pengumuman  maintenance,  atau  informasi penting lainnya kepada pengguna. Mereka juga dapat mengupdate profil mall dan informasi operasional seperti jam buka, kontak, dan fasilitas yang tersedia. Namun, mereka tidak memiliki akses untuk menyetujui pengajuan mall baru atau mengakses data mall lain demi menjaga kerahasiaan bisnis.
4. **Regular User - Pengguna Aplikasi Mobile** 
   ##### Regular  User  adalah  pengguna  akhir  yang  menggunakan  aplikasi  mobile QParkin untuk keperluan parkir mereka. Mereka tidak memiliki akses ke sistem web admin  dan hanya berinteraksi melalui API endpoints yang dirancang khusus untuk mobile application. Proses dimulai dari registrasi dan login melalui aplikasi mobile, dimana mereka dapat menggunakan email/password atau login sosial seperti Google Sign-In. 
   ##### Fitur utama yang dapat diakses Regular User adalah booking slot parkir di mall  yang  mereka  tuju.  Mereka  dapat  melihat  ketersediaan  slot secara real-time, memilih  durasi  parkir,  dan  melakukan  reservasi.  Setelah  booking  berhasil,  sistem akan  generate  QR  code  yang  berfungsi  sebagai  tiket  digital untuk entry dan exit. Proses  pembayaran  juga  terintegrasi dalam aplikasi, mendukung berbagai metode pembayaran digital. 
   ##### Regular  User  dapat  melihat  history parkir mereka, termasuk detail waktu, lokasi, durasi, dan biaya untuk setiap sesi parkir. Mereka juga menerima notifikasi personal seperti reminder waktu parkir hampir habis, konfirmasi pembayaran, atau informasi promosi dari mall. Namun, mereka tidak dapat mengakses data pengguna lain, informasi operasional mall, atau fitur administratif apapun. 
5. **Implementasi Keamanan dan Monitoring** 

   Sistem  keamanan  diimplementasikan  berlapis  dengan  autentikasi  yang berbeda  untuk  setiap  platform.  API  mobile  menggunakan  JWT  tokens  untuk memastikan  setiap  request  terautentikasi,  sementara  web  admin  menggunakan session-based  authentication  dengan  CSRF  protection.  Super  Admin  accounts dilengkapi  dengan  two-factor  authentication  (2FA)  untuk  lapisan  keamanan tambahan mengingat level akses mereka yang tinggi. 

   Setiap akses data dibatasi berdasarkan scope mall, dimana pengguna hanya dapat  mengakses  data  mall  yang  telah  diassign  kepada  mereka. Implementasi ini dilakukan  melalui  middleware  yang  secara  otomatis  memfilter  query  database berdasarkan mall\_id yang terkait dengan user. Permission checking juga dilakukan di level controller untuk memastikan setiap action telah diotorisasi dengan benar. 

   Sistem audit logging mencatat seluruh aktivitas penting seperti login/logout, perubahan  role,  modifikasi  data,  dan  percobaan  akses  yang  gagal.  Monitoring real-time  dilakukan  untuk  mendeteksi  pola  akses  yang  mencurigakan,  percobaan privilege  escalation,  atau  aktivitas  yang  tidak  normal. Alert otomatis akan dikirim kepada  Super  Admin  jika  terdeteksi  aktivitas  yang  berpotensi  membahayakan keamanan sistem.

6. **Strategi Pengembangan dan Maintenance** 

   Implementasi access control dilakukan secara bertahap mulai dari core RBAC system,  kemudian  mall  scoping,  fine-grained  permissions,  dan  terakhir  advanced features.  Setiap fase diuji secara menyeluruh dengan unit tests, feature tests, dan integration tests untuk memastikan sistem berjalan sesuai spesifikasi dan tidak ada celah keamanan. 

   Maintenance  sistem  meliputi  regular  security  audit,  update  permission matrix sesuai kebutuhan bisnis yang berkembang, dan monitoring performa sistem. Documentation akan selalu diupdate seiring dengan perubahan sistem, dan training akan  diberikan  kepada  pengguna  baru  untuk  memastikan  mereka  memahami batasan dan tanggung jawab sesuai role mereka. 

   Sistem  ini  dirancang  untuk  scalable  dan  flexible,  sehingga  dapat  dengan mudah diadaptasi ketika ada penambahan role baru, perubahan business process, atau  integrasi  dengan  sistem  eksternal.  Arsitektur  modular  memungkinkan pengembangan fitur baru tanpa mengganggu sistem yang sudah berjalan, sementara comprehensive logging memastikan setiap perubahan dapat ditrack dan di-rollback jika diperlukan. 

3. **Identifikasi Risiko Awal** 



|**Kode Risiko** |**Nama Risiko** |**Kategori** |**Deskripsi Risiko** |**Sumber Risiko (US)** |**Aset Terdampak** |**Likelihood** |**Impa ct** |**Level Risiko** |
| - | - | - | - | :-: | :- | - | :-: | - |
|**R-01** |Kebocoran Token Autentikasi |<p>Autentikasi </p><p>& Akses </p>|Token JWT dapat dicuri atau disadap jika tidak dikelola dengan baik pada aplikasi mobile |US-01 |user, customer, oauth\_\* |Medium |High |**HIGH** |
|**R-02** |Privilege Escalation |<p>Autentikasi </p><p>& Akses </p>|Pengguna dengan role rendah mengakses fitur/data yang seharusnya restricted untuk role lebih tinggi |US-07, US-08, US-09 |admin\_mal l, super\_adm in, semua tabel |Medium |High |**HIGH** |
|**R-03** |Session Hijacking Web Admin |<p>Autentikasi </p><p>& Akses </p>|Session ID admin dapat dicuri |US-08, US-09 |Dashboard admin, tabel konfigurasi |Low |Critic al |**HIGH** |



||||melalui XSS atau network sniffing ||||||
| :- | :- | :- | - | :- | :- | :- | :- | :- |
|**R-04** |Manipulasi Data Booking |Integritas Data |Data booking dimanipulasi untuk mendapatkan slot tanpa pembayaran atau melebihi kapasitas |US-02 |booking, parkiran, transaksi \_parkir |Medium |High |**HIGH** |
|**R-05** |Race Condition Booking |Integritas Data |Multiple users booking slot yang sama secara bersamaan menyebabkan overbooking |US-02 |booking, parkiran |High |Medi um |**HIGH** |
|**R-06** |Manipulasi QR Code |Integritas Data |QR Code diduplikasi, dimodifikasi, atau digunakan kembali untuk akses tidak sah |US-03 |transaksi \_parkir, riwayat\_g erbang, booking |Medium |High |**HIGH** |
|**R-07** |Inkonsistens i Data Pembayaran |Integritas Data |Ketidaksesuaian status pembayaran dengan status booking/transaksi parkir |US-04 |pembayara n, transaksi \_parkir, booking |Medium |Critic al |**CRITICA L** |
|**R-08** |SQL Injection |Kerahasiaan Data |Serangan injeksi SQL melalui input yang tidak tervalidasi dengan baik |Semua US |Seluruh basis data MySQL |Low |Critic al |**HIGH** |
|**R-09** |Kebocoran Data Pribadi |Kerahasiaan Data |Data pribadi (nomor telepon, email, riwayat) diakses pihak tidak berwenang |US-01, US-07 |user, customer, kendaraan |Medium |High |**HIGH** |



|**R-10** |Eksposur Data Keuangan |Kerahasiaan Data |Data pembayaran dan laporan keuangan bocor melalui API atau akses tidak sah |US-08, US-09 |pembayara n, laporan agregat |Low |Critic al |**HIGH** |
| - | :- | :- | :- | - | :- | - | :- | - |
|**R-11** |Denial of Service (DoS) |Ketersediaa n Sistem |Flooding request ke API menyebabkan sistem tidak dapat melayani pengguna legitimate |Semua US |Backend server, basis data |Medium |High |**HIGH** |
|**R-12** |Database Connection Exhaustion |Ketersediaa n Sistem |Koneksi database habis karena tidak di-manage dengan baik atau serangan |Traffic tinggi |MySQL database server |Low |High |**MEDIU M** |
|**R-13** |Manipulasi Poin & Penalti |Logika Bisnis |Logika perhitungan poin reward dan penalti dieksploitasi untuk keuntungan tidak sah |US-05 |riwayat\_p oin, transaksi \_parkir |Medium |Medi um |**MEDIU M** |
|**R-14** |Manipulasi Durasi Parkir |Logika Bisnis |Waktu masuk/keluar dimanipulasi untuk mengurangi biaya parkir |US-03 |riwayat\_g erbang, transaksi \_parkir |Medium |Medi um |**MEDIU M** |
|**R-15** |Ketidakleng kapan Audit Trail |Audit & Compliance |Aktivitas penting tidak tercatat, menyulitkan investigasi insiden |US-09 |Audit logs, semua tabel operasional |Low |Medi um |**MEDIU M** |
|**R-16** |Modifikasi/ Penghapusa n Log |Audit & Compliance |Log aktivitas dimodifikasi atau dihapus untuk menghilangkan jejak |Akses database |Audit logs, riwayat\_g erbang |Low |High |**MEDIU M** |



|**R-17** |Weak Database Credentials |Infrastruktu r |Password database lemah atau menggunakan default credentials |Konfigur asi |Seluruh sistem database |Low |Critic al |**HIGH** |
| - | :- | :- | :- | :- | :- | - | :- | - |
|**R-18** |Unencrypte d Database Backup |Infrastruktu r |Backup database tidak terenkripsi dan dapat diakses pihak tidak berwenang |Prosedur backup |File backup database |Low |High |**MEDIU M** |
|**R-19** |Man-in-the- Middle Attack |Komunikasi API |Data komunikasi mobile-backend disadap jika HTTPS tidak diimplementasikan benar |API commun ication |Semua data dalam transit |Low |High |**MEDIU M** |
|**R-20** |API Rate Limit Bypass |Komunikasi API |Mekanisme rate limiting di-bypass untuk brute force atau flooding |Endpoint API |Backend API, database |Medium |Medi um |**MEDIU M** |



|**Kode Risiko** |**Dampak terhadap Confidentiality** |**Dampak terhadap Integrity** |**Dampak terhadap Availability** |**Dampak Finansial** |**Dampak Reputasi** |
| - | :-: | - | :-: | - | - |
|**R-01** |✓ ✓ ✓ |✓ ✓ |✓ |✓ ✓ |✓ ✓ ✓ |
|**R-02** |✓ ✓ ✓ |✓ ✓ ✓ |✓ ✓ |✓ ✓ ✓ |✓ ✓ ✓ |
|**R-03** |✓ ✓ ✓ |✓ ✓ ✓ |✓ ✓ |✓ ✓ ✓ |✓ ✓ ✓ |
|**R-04** |✓ |✓ ✓ ✓ |✓ ✓ |✓ ✓ ✓ |✓ ✓ |
|**R-05** |- |✓ ✓ ✓ |✓ ✓ |✓ ✓ |✓ ✓ ✓ |
|**R-06** |✓ |✓ ✓ ✓ |✓ ✓ |✓ ✓ ✓ |✓ ✓ |
|**R-07** |✓ |✓ ✓ ✓ |✓ ✓ |✓ ✓ ✓ |✓ ✓ ✓ |



|**R-08** |✓ ✓ ✓ |✓ ✓ ✓ |✓ ✓ ✓ |✓ ✓ ✓ |✓ ✓ ✓ |
| - | - | - | - | - | - |
|**R-09** |✓ ✓ ✓ |✓ |- |✓ ✓ |✓ ✓ ✓ |
|**R-10** |✓ ✓ ✓ |✓ ✓ |- |✓ ✓ ✓ |✓ ✓ ✓ |
|**R-11** |- |✓ |✓ ✓ ✓ |✓ ✓ ✓ |✓ ✓ ✓ |
|**R-12** |- |✓ ✓ |✓ ✓ ✓ |✓ ✓ |✓ ✓ |
|**R-13** |- |✓ ✓ |- |✓ ✓ |✓ ✓ |
|**R-14** |- |✓ ✓ |- |✓ ✓ |✓ |
|**R-15** |✓ |✓ ✓ |- |✓ |✓ ✓ |
|**R-16** |✓ ✓ |✓ ✓ ✓ |- |✓ ✓ |✓ ✓ |
|**R-17** |✓ ✓ ✓ |✓ ✓ ✓ |✓ ✓ ✓ |✓ ✓ ✓ |✓ ✓ ✓ |
|**R-18** |✓ ✓ ✓ |✓ ✓ |- |✓ ✓ |✓ ✓ ✓ |
|**R-19** |✓ ✓ ✓ |✓ ✓ |- |✓ ✓ |✓ ✓ |
|**R-20** |✓ |✓ |✓ ✓ ✓ |✓ ✓ |✓ ✓ |

**Keterangan:** 

- ✓ ✓ ✓ = Dampak Tinggi 
- ✓ ✓ = Dampak Sedang 
- ✓ = Dampak Rendah 
- - = Tidak Ada Dampak Langsung 
### **Tabel 2.6 Pemetaan Risiko dengan User Stories** 


|**User Story** |**Area Risiko** |**Kode Risiko Terkait** |**Prioritas Penanganan** |
| - | - | - | :- |
|US-01: Registrasi & Login |Autentikasi, Kebocoran Data |R-01, R-08, R-09 |Prioritas 1 |



|US-02: Booking Slot Parkir |Integritas Data, Race Condition |R-04, R-05 |Prioritas 1 |
| - | :- | - | - |
|US-03: QR Masuk/Keluar |Validasi, Manipulasi Data |R-06, R-14 |Prioritas 2 |
|US-04: Pembayaran Digital |Integritas Transaksi |R-07 |Prioritas 1 |
|US-05: Poin & Penalti |Logika Bisnis |R-13 |Prioritas 3 |
|US-06: Notifikasi & Riwayat |Ketersediaan, Audit |R-11, R-15 |Prioritas 3 |
|US-07: Manajemen Data User |Access Control, Privacy |R-02, R-09 |Prioritas 2 |
|US-08: Pengaturan Tarif |Access Control, Data Keuangan |R-02, R-10 |Prioritas 2 |
|US-09: Monitoring Super Admin |Audit, Access Control |R-02, R-03, R-15, R-16 |Prioritas 2 |
### **Tabel 2.7 Matriks Likelihood vs Impact** 


|**Likelihood** |**Impact Low** |**Impact Medium** |**Impact High** |**Impact Critical** |
| - | :-: | - | - | - |
|**Likelihood High** |- |R-05 |- |- |
|**Likelihood Medium** |- |R-13, R-14, R-20 |R-01, R-02, R-04, R-06, R-09, R-11 |R-07 |
|**Likelihood Low** |- |R-12, R-15, R-18, R-19 |R-16 |R-03, R-08, R-10, R-17 |

**Warna Coding:** 

4. 🔴 **CRITICAL** (1 risiko): R-07 
4. 🟠 **HIGH** (11 risiko): R-01, R-02, R-03, R-04, R-05, R-06, R-08, R-09, R-10, R-11, R-17 
4. 🟡 **MEDIUM** (8 risiko): R-12, R-13, R-14, R-15, R-16, R-18, R-19, R-20 
### **Tabel 2.8 Ringkasan Kategori Risiko** 


|**Kategori Risiko** |**Jumlah** |**Kode Risiko** |**Persentase** |
| - | - | - | - |
|Autentikasi & Akses |3 |R-01, R-02, R-03 |15% |
|Integritas Data |4 |R-04, R-05, R-06, R-07 |20% |
|Kerahasiaan Data |3 |R-08, R-09, R-10 |15% |
|Ketersediaan Sistem |2 |R-11, R-12 |10% |
|Logika Bisnis |2 |R-13, R-14 |10% |
|Audit & Compliance |2 |R-15, R-16 |10% |
|Infrastruktur |2 |R-17, R-18 |10% |
|Komunikasi API |2 |R-19, R-20 |10% |
|**Total** |**20** ||**100%** |
### **Tabel 2.9 Prioritas Penanganan Risiko** 


|**Prioritas** |**Timeline** |**Kode Risiko** |**Jumlah** |**Justifikasi** |
| - | - | - | - | - |
|**Prioritas 1** (Critical) |1-2 Minggu |R-07, R-01, R-02, R-04, R-05 |5 |Risiko dengan dampak langsung pada transaksi keuangan dan data sensitif |



|**Prioritas 2** (High) |2-4 Minggu |R-06, R-08, R-09, R-10, R-17, R-03 |6 |Risiko keamanan fundamental yang dapat dieksploitasi |
| :- | :- | - | - | :- |
|**Prioritas 3** (Medium) |1-2 Bulan |R-11, R-13, R-14, R-15, R-16 |5 |Risiko operasional yang memerlukan monitoring berkelanjutan |
|**Prioritas 4** (Low) |Ongoing |R-12, R-18, R-19, R-20 |4 |Risiko dengan likelihood rendah namun perlu pemantauan |
### **Tabel 2.10 Mekanisme Kontrol yang Direkomendasikan** 


|**Kode Risiko** |**Kontrol Preventif** |**Kontrol Detektif** |**Kontrol Korektif** |
| - | - | - | - |
|**R-01** |Token encryption, Secure storage, Token expiration |Token usage monitoring, Anomaly detection |Token revocation, Force logout |
|**R-02** |RBAC middleware, Permission validation |Access log monitoring, Privilege audit |Access revocation, Role reset |
|**R-03** |CSRF protection, HttpOnly cookies, Session timeout |Session monitoring, IP validation |Session termination, Password reset |
|**R-04** |Transaction locks, Input validation |Booking audit log |Transaction rollback, Booking cancellation |
|**R-05** |Pessimistic locking, Atomic operations |Concurrent access monitoring |Booking conflict resolution |
|**R-06** |QR encryption, Timestamp validation, One-time use |QR scan log monitoring |QR invalidation, Transaction reversal |



|**R-07** |Database transactions, Payment validation |Payment reconciliation, Status monitoring |Manual reconciliation, Refund process |
| - | :- | :- | :- |
|**R-08** |Prepared statements, Input sanitization |SQL error monitoring, WAF logs |Query blocking, Database restore |
|**R-09** |Data encryption, Access control |Data access monitoring, DLP |Data breach response, User notification |
|**R-10** |Role-based filtering, Data masking |Financial report audit |Access restriction, Audit investigation |
|**R-11** |Rate limiting, WAF, Input validation |Traffic monitoring, Resource usage |Traffic blocking, Load balancing |
|**R-12** |Connection pooling, Timeout settings |Connection monitoring |Connection reset, Service restart |
|**R-13** |Business logic validation, Server-side calculation |Point audit log |Point adjustment, Manual review |
|**R-14** |Server timestamp, GPS validation |Time discrepancy monitoring |Manual verification, Charge adjustment |
|**R-15** |Comprehensive logging policy |Log completeness monitoring |Log restoration, Incident reconstruction |
|**R-16** |Log immutability, Append-only logs |Log integrity monitoring |Forensic analysis, Log recovery |



|**R-17** |Strong password policy, Secret management |Failed login monitoring |Password rotation, Access audit |
| - | :- | - | :- |
|**R-18** |Backup encryption, Access control |Backup integrity check |Secure backup storage, Access review |
|**R-19** |TLS/HTTPS enforcement, Certificate pinning |Traffic monitoring, MITM detection |Certificate renewal, Connection termination |
|**R-20** |Rate limiting per IP/user, CAPTCHA |Rate limit violation monitoring |IP blocking, Account suspension |

7. **Rencana Auditing** 
1. **Tujuan Auditing** 

   Rencana  auditing  sistem  Qparkin  bertujuan  untuk  mengevaluasi  tingkat keamanan aplikasi serta memastikan bahwa sistem telah dirancang dengan kontrol keamanan yang memadai. Proses auditing difokuskan pada identifikasi potensi risiko keamanan,  verifikasi  mekanisme  autentikasi  dan  otorisasi  pengguna,  serta  upaya menjaga integritas data transaksi parkir dan pembayaran. 

   Selain itu, auditing ini juga bertujuan untuk memastikan bahwa komunikasi data antara aplikasi mobile dan sistem backend berlangsung secara aman, sekaligus meminimalkan risiko penyalahgunaan akses terhadap sistem. 

2. **Ruang Lingkup Auditing** 

   Ruang  lingkup  auditing  mencakup  tiga  komponen  utama  dalam  sistem Qparkin, yaitu aplikasi mobile berbasis Flutter, backend API berbasis Laravel, serta basis data MySQL yang berfungsi menyimpan data pengguna dan transaksi parkir. 

   Audit difokuskan pada aspek keamanan autentikasi pengguna, pengelolaan akses  terhadap  API,  serta  integritas  data  yang  tersimpan  dalam  basis  data. Sementara  itu,  aspek  infrastruktur  server  dan  integrasi  dengan  layanan  eksternal tidak termasuk dalam ruang lingkup auditing. 
   ### *Tabel 2.1 Ruang Lingkup Auditing Sistem Qparkin* 

|**No** |**Komponen Sistem** |**Fokus Audit** |
| - | - | - |



|1 |Aplikasi Mobile (Flutter) |Autentikasi pengguna dan pengelolaan sesi |
| - | - | - |
|2 |Backend API (Laravel) |Kontrol akses endpoint dan validasi input |
|3 |Basis Data (MySQL) |Integritas data dan kontrol akses |
|4 |Infrastruktur Server |Tidak termasuk dalam audit |

3. **Metode Auditing**  

   Auditing sistem Qparkin direncanakan menggunakan beberapa pendekatan utama, yaitu sebagai berikut: 

- **Analisis Kode (Code Review)** 

  Analisis  kode  dilakukan  untuk  mengidentifikasi  potensi  kerentanan  pada kode aplikasi, khususnya yang berkaitan dengan validasi input, pengelolaan autentikasi, serta mekanisme penanganan error. 

- **Pengujian Sistem (Dynamic Testing)** 

  Pengujian  sistem  digunakan  untuk  mengevaluasi  keamanan  aplikasi  saat berjalan,  terutama  pada  mekanisme  login,  kontrol  akses  pengguna,  serta keamanan endpoint API. 

- **Audit Basis Data** 

  Audit basis data difokuskan pada pemeriksaan kontrol akses terhadap basis data  serta  konsistensi  data  transaksi  guna  memastikan  tidak  terjadinya manipulasi data. 
### *Tabel 2.2 Metode Auditing Sistem Qparkin* 

|**No** |**Metode Auditing** |**Objek Audit** |**Tujuan** |
| - | - | - | - |
|1 |Analisis Kode |Source code aplikasi |Identifikasi kerentanan |
|2 |Pengujian Sistem |API & fitur login |Uji keamanan saat runtime |
|3 |Audit Basis Data |Data transaksi |Menjamin integritas data |
|4 |Review Keamanan API |Endpoint API |Mencegah akses tidak sah |

4. **Pengamanan API Backend** 

   Pengamanan  API  pada  sistem  Qparkin  dirancang  dengan  menerapkan autentikasi berbasis token guna memastikan bahwa hanya pengguna yang memiliki kewenangan yang dapat mengakses layanan. Setiap endpoint API dilengkapi dengan mekanisme validasi input serta pembatasan akses berdasarkan peran pengguna. 

   Komunikasi data antara aplikasi dan sistem backend menggunakan protokol HTTPS untuk menjamin keamanan data selama proses transmisi. Selain itu, sistem juga  menerapkan  pembatasan  jumlah  permintaan  (*rate limiting*) serta pencatatan aktivitas penting sebagai bentuk pengendalian dan pemantauan keamanan sistem. 

8. **Rencana API Security** 
1. **Tujuan Pengamanan API** 

   Pengamanan  API  pada  Sistem  Qparkin  bertujuan  untuk  melindungi  data pengguna  dan  transaksi  parkir  dari  akses  tidak  sah  serta  menjaga  integritas  dan kerahasiaan  data.  Pengamanan  ini  dirancang  untuk  memastikan  hanya  pengguna yang  berwenang  yang  dapat  mengakses  sistem,  membatasi  akses  sesuai  peran pengguna, serta mendukung pengendalian dan penelusuran aktivitas sistem melalui mekanisme pencatatan yang memadai. 
   ### *Tabel 2.3 Kontrol Pengamanan API Sistem Qparkin* 

   |**No** |**Aspek Keamanan** |**Mekanisme Pengamanan** |**Tujuan** |
   | - | - | - | - |
   |1 |Autentikasi |Bearer Token |Verifikasi identitas pengguna |
   |2 |Otorisasi |RBAC |Pembatasan akses |
   |3 |Validasi Input |Validasi client & server |Mencegah input tidak valid |
   |4 |Keamanan Komunikasi |HTTPS/TLS |Perlindungan data |
   |5 |Logging |Audit trail |Penelusuran aktivitas |

2. **Autentikasi dan Otorisasi** 

   Sistem  Qparkin  menggunakan  mekanisme  autentikasi  berbasis  nomor telepon dan PIN yang menghasilkan token akses sebagai identitas pengguna dalam setiap  permintaan  API.  Token  ini  disimpan  secara aman pada aplikasi mobile dan digunakan untuk mengontrol akses ke layanan backend. 

   Otorisasi diterapkan menggunakan kontrol akses berbasis peran (Role-Based Access  Control)  yang  membedakan  hak  akses  antara  Customer,  Admin  Mall,  dan Super Admin. Setiap permintaan API divalidasi untuk memastikan pengguna hanya dapat mengakses data dan fitur sesuai dengan peran dan kepemilikannya. 

3. **Validasi Input dan Keamanan Komunikasi** 

   Validasi input dilakukan untuk memastikan data yang diproses sistem sesuai dengan format dan aturan yang telah ditetapkan. Validasi diterapkan baik pada sisi aplikasi  maupun  pada  sisi  server  untuk  mencegah  kesalahan  data  dan  potensi penyalahgunaan. 

   Keamanan komunikasi data dijaga melalui penggunaan protokol HTTPS/TLS sehingga  data  yang  dikirimkan  antara  aplikasi  dan  server  terlindungi  dari penyadapan.  Mekanisme  tambahan  direncanakan  untuk  memastikan  komunikasi hanya dilakukan dengan server yang sah. 

4. **Pembatasan Akses dan Pengendalian Sistem** 

   Pembatasan akses diterapkan untuk mencegah penyalahgunaan layanan API. Setiap  endpoint  memiliki  batasan  akses  berdasarkan  peran  pengguna  dan sensitivitas  layanan.  Selain  itu,  sistem  dirancang  untuk  membatasi  jumlah permintaan API dalam periode tertentu guna menghindari penggunaan berlebihan atau aktivitas yang mencurigakan. 

   Pemantauan  pola  penggunaan  API  dilakukan  untuk  mendeteksi  aktivitas yang tidak wajar, seperti percobaan akses berulang atau penggunaan layanan yang tidak sesuai dengan pola normal. 

5. **Logging dan Audit Trail** 

   Sistem Qparkin menerapkan mekanisme pencatatan aktivitas penting seperti autentikasi,  akses  data,  dan  transaksi.  Data  sensitif  tidak  dicatat  secara  langsung dalam log untuk mencegah kebocoran informasi. 

   Audit trail digunakan untuk mencatat perubahan pada data kritis sehingga aktivitas  sistem  dapat  ditelusuri  apabila terjadi kesalahan atau insiden keamanan. Mekanisme ini mendukung proses evaluasi dan pengendalian keamanan sistem. 
