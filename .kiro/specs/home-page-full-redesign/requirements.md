# Requirements Document

## Introduction

Dokumen ini mendefinisikan kebutuhan untuk improvisasi lanjutan tampilan Home Page aplikasi QPARKIN agar lebih konsisten dengan desain Activity Page dan Map Page. Tujuannya adalah meningkatkan konsistensi visual, keterbacaan, dan kualitas tampilan secara keseluruhan tanpa mengubah fungsionalitas yang sudah ada.

## Glossary

- **Home Page**: Halaman utama aplikasi QPARKIN yang menampilkan informasi lokasi parkir terdekat dan akses cepat ke fitur-fitur utama
- **Activity Page**: Halaman yang menampilkan aktivitas parkir aktif dan riwayat parkir pengguna
- **Map Page**: Halaman yang menampilkan peta lokasi parkir dan daftar mall
- **Card Component**: Komponen UI berbentuk kartu dengan background putih, border radius, dan shadow
- **Quick Actions**: Grid tombol akses cepat ke fitur-fitur utama aplikasi
- **Parking Location Card**: Kartu yang menampilkan informasi lokasi parkir terdekat
- **Design System**: Sistem desain yang konsisten mencakup warna, tipografi, spacing, dan komponen UI
- **8dp Grid**: Sistem spacing berbasis kelipatan 8 density-independent pixels

## Requirements

### Requirement 1

**User Story:** Sebagai pengguna aplikasi QPARKIN, saya ingin melihat tampilan Home Page yang konsisten dengan halaman lain, sehingga pengalaman visual saya lebih kohesif dan profesional.

#### Acceptance Criteria

1. WHEN pengguna membuka Home Page, THE System SHALL menampilkan card putih dengan border radius 16px untuk semua komponen kartu
2. WHEN pengguna melihat Parking Location Cards, THE System SHALL menampilkan shadow dengan opacity 0.05 dan blur radius 8px
3. WHEN pengguna melihat Quick Actions grid, THE System SHALL menampilkan 4 kolom dengan spacing 12px antar item
4. WHERE card components digunakan, THE System SHALL menggunakan warna border Colors.grey.shade200 dengan width 1px
5. WHILE pengguna melihat Home Page, THE System SHALL menampilkan background putih (Colors.white) untuk content section

### Requirement 2

**User Story:** Sebagai pengguna aplikasi QPARKIN, saya ingin interaksi yang responsif pada setiap elemen yang dapat diklik, sehingga saya mendapat feedback visual yang jelas.

#### Acceptance Criteria

1. WHEN pengguna mengetuk Parking Location Card, THE System SHALL menampilkan ripple effect dengan InkWell
2. WHEN pengguna mengetuk Quick Action button, THE System SHALL menampilkan ripple effect dengan border radius 16px
3. WHEN pengguna mengetuk card yang dapat diklik, THE System SHALL menavigasi ke halaman tujuan yang sesuai
4. WHERE interactive elements digunakan, THE System SHALL menggunakan Material + InkWell pattern untuk feedback visual
5. WHILE pengguna berinteraksi dengan card, THE System SHALL mempertahankan border radius yang konsisten pada ripple effect

### Requirement 3

**User Story:** Sebagai pengguna aplikasi QPARKIN, saya ingin melihat hierarki informasi yang jelas pada Parking Location Cards, sehingga saya dapat dengan mudah memahami informasi penting.

#### Acceptance Criteria

1. WHEN pengguna melihat Parking Location Card, THE System SHALL menampilkan nama lokasi dengan font size 16px bold
2. WHEN pengguna melihat distance information, THE System SHALL menampilkan dalam badge dengan background Colors.grey.shade100
3. WHEN pengguna melihat available slots, THE System SHALL menampilkan dalam badge hijau dengan dot indicator
4. WHERE address text ditampilkan, THE System SHALL menggunakan font size 14px dengan color Colors.grey.shade600
5. WHILE card menampilkan informasi, THE System SHALL menggunakan spacing 8px dan 12px untuk hierarchy yang jelas

### Requirement 4

**User Story:** Sebagai pengguna aplikasi QPARKIN, saya ingin Quick Actions yang terorganisir dengan baik, sehingga saya dapat dengan cepat mengakses fitur-fitur utama.

#### Acceptance Criteria

1. WHEN pengguna melihat Quick Actions section, THE System SHALL menampilkan grid 4 kolom dengan aspect ratio 0.85
2. WHEN pengguna melihat Quick Action card, THE System SHALL menampilkan icon dalam container dengan padding 12px
3. WHEN pengguna melihat Quick Action label, THE System SHALL menampilkan text dengan font size 12px dan weight w600
4. WHERE Quick Action card ditampilkan, THE System SHALL menggunakan border dengan color accent dan opacity 0.2
5. WHILE pengguna melihat icon container, THE System SHALL menampilkan background color dengan opacity 0.1 sesuai accent color

### Requirement 5

**User Story:** Sebagai pengguna aplikasi QPARKIN, saya ingin tipografi yang konsisten di seluruh Home Page, sehingga tampilan lebih profesional dan mudah dibaca.

#### Acceptance Criteria

1. WHEN pengguna melihat section title, THE System SHALL menampilkan text dengan font size 20px bold
2. WHEN pengguna melihat card title, THE System SHALL menampilkan text dengan font size 16px bold
3. WHEN pengguna melihat body text, THE System SHALL menampilkan text dengan font size 14px regular
4. WHERE badge text ditampilkan, THE System SHALL menggunakan font size 12px dengan weight w600
5. WHILE text ditampilkan, THE System SHALL menggunakan color Colors.black87 untuk primary text dan Colors.grey.shade600 untuk secondary text

### Requirement 6

**User Story:** Sebagai pengguna aplikasi QPARKIN, saya ingin spacing yang konsisten mengikuti 8dp grid system, sehingga layout terlihat rapi dan terorganisir.

#### Acceptance Criteria

1. WHEN pengguna melihat content section, THE System SHALL menggunakan horizontal padding 24px
2. WHEN pengguna melihat spacing antar cards, THE System SHALL menggunakan gap 12px
3. WHEN pengguna melihat spacing antar sections, THE System SHALL menggunakan gap 24px
4. WHERE card padding digunakan, THE System SHALL menggunakan padding 16px
5. WHILE icon container ditampilkan, THE System SHALL menggunakan padding 12px

### Requirement 7

**User Story:** Sebagai pengguna aplikasi QPARKIN, saya ingin warna aksen yang konsisten dengan brand QPARKIN, sehingga identitas visual aplikasi terjaga.

#### Acceptance Criteria

1. WHEN pengguna melihat primary action, THE System SHALL menggunakan warna ungu #573ED1
2. WHEN pengguna melihat map/navigation action, THE System SHALL menggunakan warna biru #3B82F6
3. WHEN pengguna melihat points/rewards action, THE System SHALL menggunakan warna gold #FFA726
4. WHERE history action ditampilkan, THE System SHALL menggunakan warna hijau #4CAF50
5. WHILE success indicator ditampilkan, THE System SHALL menggunakan warna hijau dengan shade yang sesuai

### Requirement 8

**User Story:** Sebagai pengguna aplikasi QPARKIN, saya ingin Parking Location Cards yang lebih informatif dan mudah dipahami, sehingga saya dapat membuat keputusan parkir dengan cepat.

#### Acceptance Criteria

1. WHEN pengguna melihat Parking Location Card, THE System SHALL menampilkan icon lokasi dalam container ungu dengan border radius 12px
2. WHEN pengguna melihat available slots badge, THE System SHALL menampilkan dengan background Colors.green.shade50 dan text Colors.green.shade700
3. WHEN pengguna melihat distance badge, THE System SHALL menampilkan dalam container dengan background Colors.grey.shade100
4. WHERE navigation arrow ditampilkan, THE System SHALL menggunakan icon arrow_forward_ios dengan size 16px dan color Colors.grey.shade400
5. WHILE card menampilkan address, THE System SHALL membatasi maksimal 2 baris dengan ellipsis overflow

### Requirement 9

**User Story:** Sebagai developer, saya ingin komponen yang reusable untuk Quick Actions, sehingga kode lebih maintainable dan konsisten.

#### Acceptance Criteria

1. WHEN developer membuat Quick Action card, THE System SHALL menyediakan method _buildQuickActionCard dengan parameter yang jelas
2. WHEN method dipanggil, THE System SHALL menerima parameter icon, label, color, onTap, dan useFontAwesome
3. WHEN card dirender, THE System SHALL menggunakan styling yang konsisten untuk semua Quick Actions
4. WHERE FontAwesome icon digunakan, THE System SHALL support parameter useFontAwesome boolean
5. WHILE card dibuat, THE System SHALL menggunakan Material + InkWell pattern untuk interactivity

### Requirement 10

**User Story:** Sebagai pengguna dengan kebutuhan aksesibilitas, saya ingin touch target yang memadai pada semua elemen interaktif, sehingga saya dapat dengan mudah berinteraksi dengan aplikasi.

#### Acceptance Criteria

1. WHEN pengguna mengetuk Quick Action card, THE System SHALL menyediakan touch target minimal 48dp
2. WHEN pengguna mengetuk Parking Location Card, THE System SHALL menyediakan touch target yang memadai dengan padding 16px
3. WHEN pengguna melihat text, THE System SHALL memastikan contrast ratio minimal 4.5:1 untuk WCAG AA compliance
4. WHERE interactive elements ditampilkan, THE System SHALL menyediakan visual feedback yang jelas
5. WHILE pengguna berinteraksi, THE System SHALL mempertahankan semantic structure yang proper

### Requirement 11

**User Story:** Sebagai pengguna aplikasi QPARKIN, saya ingin melihat loading state yang informatif saat data sedang dimuat, sehingga saya tahu bahwa aplikasi sedang bekerja.

#### Acceptance Criteria

1. WHEN Home Page pertama kali dibuka, THE System SHALL menampilkan shimmer loading untuk Parking Location Cards
2. WHEN data lokasi parkir sedang dimuat, THE System SHALL menampilkan skeleton placeholder dengan ukuran yang sama dengan card asli
3. WHEN shimmer loading ditampilkan, THE System SHALL menggunakan animasi gradient yang smooth
4. WHERE loading state digunakan, THE System SHALL menggunakan warna Colors.grey.shade200 dan Colors.grey.shade100
5. WHILE data dimuat, THE System SHALL mempertahankan layout structure yang konsisten

### Requirement 12

**User Story:** Sebagai pengguna aplikasi QPARKIN, saya ingin melihat empty state yang informatif ketika tidak ada data atau terjadi error, sehingga saya memahami situasi dan tahu apa yang harus dilakukan.

#### Acceptance Criteria

1. WHEN tidak ada lokasi parkir tersedia, THE System SHALL menampilkan empty state dengan icon dan pesan yang jelas
2. WHEN terjadi error saat memuat data, THE System SHALL menampilkan error state dengan tombol retry
3. WHEN empty state ditampilkan, THE System SHALL menggunakan icon dengan size 48px dan color Colors.grey.shade400
4. WHERE error state ditampilkan, THE System SHALL menyediakan tombol "Coba Lagi" dengan warna primary
5. WHILE empty/error state ditampilkan, THE System SHALL menggunakan text yang friendly dan helpful

### Requirement 13

**User Story:** Sebagai pengguna aplikasi QPARKIN, saya ingin micro interaction yang smooth pada setiap interaksi, sehingga pengalaman menggunakan aplikasi terasa lebih responsif dan menyenangkan.

#### Acceptance Criteria

1. WHEN pengguna mengetuk card, THE System SHALL menampilkan subtle scale animation dengan duration 150ms
2. WHEN card ditekan, THE System SHALL menggunakan scale transform 0.98 untuk pressed state
3. WHEN card dilepas, THE System SHALL kembali ke scale 1.0 dengan smooth animation
4. WHERE ripple effect ditampilkan, THE System SHALL menggunakan InkWell dengan splash color yang sesuai
5. WHILE animasi berjalan, THE System SHALL menggunakan curve Curves.easeInOut untuk smooth transition

### Requirement 14

**User Story:** Sebagai pengguna aplikasi QPARKIN, saya ingin Parking Location Cards di Home Page hanya menampilkan 3 lokasi terdekat dengan tombol "Rute", sehingga saya dapat dengan cepat melihat opsi parkir terdekat tanpa distraksi.

#### Acceptance Criteria

1. WHEN pengguna melihat section "Lokasi Parkir Terdekat", THE System SHALL menampilkan maksimal 3 lokasi parkir terdekat
2. WHEN pengguna melihat Parking Location Card, THE System SHALL TIDAK menampilkan tombol "Booking Sekarang"
3. WHEN pengguna mengetuk card, THE System SHALL menavigasi ke Map Page untuk melihat detail dan melakukan booking
4. WHERE tombol "Rute" ditampilkan, THE System SHALL menggunakan icon navigation dengan size 16px
5. WHILE section ditampilkan, THE System SHALL menyediakan tombol "Lihat Semua" yang mengarah ke Map Page
