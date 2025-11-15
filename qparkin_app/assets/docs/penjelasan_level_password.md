# Penjelasan Level Password 02

Level password 02 mengacu pada implementasi validasi PIN 6 digit untuk autentikasi pengguna dalam aplikasi QParkin Mobile.

## Deskripsi Level

Level ini fokus pada penggunaan PIN numerik 6 digit sebagai mekanisme autentikasi utama, yang menyediakan keseimbangan antara kemudahan penggunaan dan tingkat keamanan yang memadai untuk aplikasi mobile.

## Implementasi Teknis

### Validator PIN 6 Digit

- **Lokasi**: `lib/utils/validators.dart`
- **Fungsi**: `Validators.pin6(String? value)`
- **Validasi yang dilakukan**:
  - Memastikan input tidak kosong atau null
  - Memverifikasi input hanya terdiri dari karakter numerik (0-9)
  - Mengecek panjang input tepat 6 digit

### Penggunaan dalam UI

#### Login Screen
- Field PIN menggunakan validator `Validators.pin6`
- Input dibatasi dengan `maxLength: 6` dan `inputFormatters: [FilteringTextInputFormatter.digitsOnly]`
- Validasi dilakukan saat form disubmit

#### New PIN Sheet (Reset Password)
- Field "PIN" dan "Konfirmasi PIN" keduanya menggunakan `Validators.pin6`
- Validasi tambahan untuk memastikan kedua field PIN cocok
- Input disembunyikan secara default dengan opsi toggle visibility

## Aspek Keamanan

### Kekuatan Password
- PIN 6 digit memberikan 1.000.000 kombinasi possible (10^6)
- Lebih aman daripada PIN 4 digit (10.000 kombinasi) namun tetap mudah diingat

### Pencegahan Input Tidak Valid
- Input dibatasi hanya angka melalui `FilteringTextInputFormatter.digitsOnly`
- Panjang maksimal 6 digit dicegah melalui `maxLength`
- Validasi real-time saat form submission

### UX Considerations
- Field PIN menggunakan `obscureText: true` secara default
- Icon toggle untuk menampilkan/menyembunyikan PIN
- Error message yang jelas dan user-friendly

## Kesimpulan

Implementasi level password 02 memastikan autentikasi yang aman namun user-friendly melalui validasi PIN 6 digit yang ketat, dengan fokus pada pencegahan input tidak valid dan pengalaman pengguna yang baik.
