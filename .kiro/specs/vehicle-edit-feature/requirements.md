# Requirements Document

## Introduction

Fitur Edit Kendaraan memungkinkan pengguna untuk mengubah informasi kendaraan yang sudah terdaftar dalam sistem QParkin. Fitur ini akan menggunakan kembali (reuse) halaman tambah kendaraan yang sudah ada dengan menambahkan mode edit, sehingga tidak perlu membuat halaman baru yang duplikatif. Implementasi ini fokus pada frontend Flutter tanpa mengubah backend atau API yang sudah ada.

## Glossary

- **Edit Mode**: Mode operasi halaman tambah kendaraan ketika digunakan untuk mengedit kendaraan yang sudah ada
- **Add Mode**: Mode operasi halaman tambah kendaraan ketika digunakan untuk menambahkan kendaraan baru
- **VehicleSelectionPage**: Halaman Flutter untuk menambah/edit kendaraan (file: tambah_kendaraan.dart)
- **VehicleDetailPage**: Halaman Flutter yang menampilkan detail kendaraan
- **ProfileProvider**: State management provider yang mengelola data profil dan kendaraan pengguna
- **VehicleModel**: Model data yang merepresentasikan kendaraan pengguna
- **Read-only Field**: Field form yang tidak dapat diedit dan hanya ditampilkan sebagai informasi
- **Editable Field**: Field form yang dapat diubah oleh pengguna
- **Prefill**: Mengisi field form secara otomatis dengan data yang sudah ada

## Requirements

### Requirement 1

**User Story:** Sebagai pengguna, saya ingin dapat mengedit informasi kendaraan yang sudah terdaftar, sehingga saya dapat memperbarui data kendaraan tanpa harus menghapus dan menambahkan ulang.

#### Acceptance Criteria

1. WHEN VehicleSelectionPage menerima parameter isEditMode=true dan vehicle object THEN the system SHALL menampilkan halaman dalam mode edit dengan data kendaraan yang sudah ada
2. WHEN VehicleSelectionPage dalam edit mode THEN the system SHALL mengisi semua field form dengan data dari vehicle object yang diterima
3. WHEN pengguna membuka VehicleSelectionPage dalam edit mode THEN the system SHALL menampilkan judul halaman "Edit Kendaraan" bukan "Tambah Kendaraan"
4. WHEN VehicleSelectionPage dalam edit mode THEN the system SHALL menampilkan tombol submit dengan teks "Simpan Perubahan" bukan "Tambahkan Kendaraan"
5. WHEN VehicleSelectionPage dalam add mode (isEditMode=false atau null) THEN the system SHALL beroperasi seperti biasa untuk menambah kendaraan baru

### Requirement 2

**User Story:** Sebagai pengguna, saya ingin field jenis kendaraan dan plat nomor tidak dapat diubah saat edit, sehingga integritas data kendaraan tetap terjaga.

#### Acceptance Criteria

1. WHEN VehicleSelectionPage dalam edit mode THEN the system SHALL menampilkan field jenis kendaraan sebagai read-only dengan visual yang berbeda dari field editable
2. WHEN VehicleSelectionPage dalam edit mode THEN the system SHALL menampilkan field plat nomor sebagai read-only dengan visual yang berbeda dari field editable
3. WHEN pengguna mencoba berinteraksi dengan field jenis kendaraan dalam edit mode THEN the system SHALL tidak mengizinkan perubahan nilai
4. WHEN pengguna mencoba berinteraksi dengan field plat nomor dalam edit mode THEN the system SHALL tidak mengizinkan perubahan nilai
5. WHEN VehicleSelectionPage dalam add mode THEN the system SHALL mengizinkan pengguna memilih jenis kendaraan dan mengisi plat nomor seperti biasa

### Requirement 3

**User Story:** Sebagai pengguna, saya ingin dapat mengubah merek, tipe, warna, foto, dan status kendaraan, sehingga saya dapat memperbarui informasi yang berubah seiring waktu.

#### Acceptance Criteria

1. WHEN VehicleSelectionPage dalam edit mode THEN the system SHALL mengizinkan pengguna mengubah field merek kendaraan
2. WHEN VehicleSelectionPage dalam edit mode THEN the system SHALL mengizinkan pengguna mengubah field tipe kendaraan
3. WHEN VehicleSelectionPage dalam edit mode THEN the system SHALL mengizinkan pengguna mengubah field warna kendaraan
4. WHEN VehicleSelectionPage dalam edit mode THEN the system SHALL mengizinkan pengguna mengubah atau menghapus foto kendaraan
5. WHEN VehicleSelectionPage dalam edit mode THEN the system SHALL mengizinkan pengguna mengubah status kendaraan antara "Kendaraan Utama" dan "Kendaraan Tamu"

### Requirement 4

**User Story:** Sebagai pengguna, saya ingin navigasi ke mode edit mudah diakses dari halaman detail kendaraan, sehingga saya dapat dengan cepat mengedit kendaraan yang sedang saya lihat.

#### Acceptance Criteria

1. WHEN pengguna menekan tombol "Edit Kendaraan" di VehicleDetailPage THEN the system SHALL menavigasi ke VehicleSelectionPage dengan parameter isEditMode=true dan vehicle object
2. WHEN navigasi ke edit mode berhasil THEN the system SHALL menampilkan VehicleSelectionPage dengan semua data kendaraan sudah terisi
3. WHEN pengguna menekan tombol back di VehicleSelectionPage edit mode THEN the system SHALL kembali ke VehicleDetailPage tanpa menyimpan perubahan
4. WHEN pengguna berhasil menyimpan perubahan THEN the system SHALL kembali ke halaman sebelumnya dan menampilkan notifikasi sukses
5. WHEN navigasi ke edit mode gagal THEN the system SHALL menampilkan pesan error yang informatif

### Requirement 5

**User Story:** Sebagai pengguna, saya ingin perubahan data kendaraan disimpan melalui API yang sudah ada, sehingga data saya tersinkronisasi dengan backend.

#### Acceptance Criteria

1. WHEN pengguna menekan tombol "Simpan Perubahan" dalam edit mode THEN the system SHALL mengirim request PUT ke endpoint /api/kendaraan/{id}
2. WHEN request PUT berhasil THEN the system SHALL memperbarui data di ProfileProvider
3. WHEN request PUT berhasil THEN the system SHALL menampilkan notifikasi "Kendaraan berhasil diperbarui"
4. WHEN request PUT gagal THEN the system SHALL menampilkan pesan error yang diterima dari API
5. WHEN VehicleSelectionPage dalam add mode THEN the system SHALL tetap menggunakan POST /api/kendaraan seperti biasa

### Requirement 6

**User Story:** Sebagai pengguna, saya ingin validasi form tetap berjalan saat edit kendaraan, sehingga saya tidak dapat menyimpan data yang tidak valid.

#### Acceptance Criteria

1. WHEN pengguna mengosongkan field merek dalam edit mode THEN the system SHALL menampilkan pesan error "Masukkan merek kendaraan"
2. WHEN pengguna mengosongkan field tipe dalam edit mode THEN the system SHALL menampilkan pesan error "Masukkan tipe kendaraan"
3. WHEN pengguna mengosongkan field warna dalam edit mode THEN the system SHALL menampilkan pesan error "Warna kendaraan wajib diisi"
4. WHEN pengguna mencoba submit form dengan data tidak valid dalam edit mode THEN the system SHALL mencegah pengiriman request dan menampilkan pesan error
5. WHEN semua field valid dalam edit mode THEN the system SHALL mengizinkan pengiriman request PUT

### Requirement 7

**User Story:** Sebagai pengguna, saya ingin foto kendaraan yang sudah ada ditampilkan saat edit, sehingga saya dapat melihat foto lama sebelum menggantinya.

#### Acceptance Criteria

1. WHEN VehicleSelectionPage dalam edit mode dan vehicle memiliki foto THEN the system SHALL menampilkan foto kendaraan yang sudah ada di section foto
2. WHEN pengguna memilih foto baru dalam edit mode THEN the system SHALL mengganti preview foto dengan foto baru yang dipilih
3. WHEN pengguna menghapus foto dalam edit mode THEN the system SHALL menghapus preview foto dan menampilkan placeholder "Tambah Foto"
4. WHEN pengguna tidak mengubah foto dalam edit mode THEN the system SHALL tetap menggunakan foto yang sudah ada saat submit
5. WHEN VehicleSelectionPage dalam edit mode dan vehicle tidak memiliki foto THEN the system SHALL menampilkan placeholder "Tambah Foto" seperti biasa

### Requirement 8

**User Story:** Sebagai pengguna, saya ingin UI/UX yang konsisten antara mode add dan edit, sehingga saya tidak bingung saat menggunakan fitur ini.

#### Acceptance Criteria

1. WHEN VehicleSelectionPage dalam edit mode THEN the system SHALL menggunakan layout yang sama dengan add mode
2. WHEN VehicleSelectionPage dalam edit mode THEN the system SHALL menggunakan styling yang konsisten dengan add mode kecuali untuk field read-only
3. WHEN field dalam mode read-only THEN the system SHALL memiliki visual yang jelas membedakannya dari field editable (misalnya background abu-abu, disabled state)
4. WHEN loading state aktif dalam edit mode THEN the system SHALL menampilkan loading indicator yang sama dengan add mode
5. WHEN error terjadi dalam edit mode THEN the system SHALL menampilkan error message dengan format yang sama dengan add mode
