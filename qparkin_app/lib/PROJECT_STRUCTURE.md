# 🧭 **Dokumentasi Struktur Folder Proyek Flutter – Parkey**

## 📱 Tentang Proyek

**Nama Aplikasi:** Parkey
**Deskripsi:**
*Inovasi Aplikasi Mobile Berbasis QR Code untuk Sistem Tiket Parkir Digital di Pusat Perbelanjaan.*

Parkey dirancang untuk mempermudah proses parkir dengan sistem tiket digital menggunakan QR Code, mulai dari proses masuk parkir, scan tiket, hingga keluar area parkir.

---

## 📂 Struktur Folder Utama

```
lib/
├── main.dart
├── config/
├── data/
├── logic/
├── presentation/
├── utils/
└── assets/ (di luar lib, hanya referensi)
```

---

## 🏠 1. `main.dart`

### 📌 Fungsi:

* Titik awal aplikasi (`void main()`).
* Menjalankan fungsi `runApp()`.
* Menyambungkan aplikasi ke konfigurasi tema, route, dan provider (jika ada).

### 🧭 Contoh isi:

```dart
void main() {
  runApp(const ParkeyApp());
}

class ParkeyApp extends StatelessWidget {
  const ParkeyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parkey',
      theme: appTheme,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
```

---

## ⚙️ 2. `config/`

### 📌 Fungsi:

Menyimpan semua **konfigurasi global** aplikasi — hal-hal yang sifatnya *tidak tergantung fitur tertentu*, seperti:

* Tema
* Konstanta
* Route navigasi

### 📁 Subfolder & File:

```
config/
├── constants.dart
├── routes.dart
└── theme.dart
```

### 📄 Penjelasan:

* `constants.dart` → menyimpan nilai konstan seperti warna, ukuran font, durasi animasi, dan teks global.
* `routes.dart` → mendefinisikan semua route (halaman) beserta nama route-nya.
* `theme.dart` → menyimpan konfigurasi `ThemeData` seperti warna primer, font, button style, dsb.

### 🧭 Best Practice:

* Simpan semua nilai warna utama dalam `constants.dart` supaya konsisten di seluruh aplikasi.
* Jangan tulis warna atau ukuran secara langsung di dalam widget.

---

## 🗄️ 3. `data/`

### 📌 Fungsi:

Berisi **representasi data dan koneksi ke sumber data eksternal**, seperti:

* Model data (User, Ticket, Vehicle)
* Koneksi API / database
* Logika QR Code

### 📁 Subfolder & File:

```
data/
├── models/
│   ├── user_model.dart
│   ├── vehicle_model.dart
│   └── ticket_model.dart
└── services/
    ├── api_service.dart
    ├── auth_service.dart
    └── qr_service.dart
```

### 📄 Penjelasan:

* `models/` → berisi class untuk menampung struktur data (seperti JSON mapping).
* `services/` → tempat logika komunikasi dengan backend (API), database lokal, atau QR.

### 🧭 Best Practice:

* Gunakan penamaan class dengan huruf kapital awal (`UserModel`).
* Gunakan metode `fromJson` dan `toJson` di setiap model untuk parsing data API.
* Buat satu file service untuk satu tanggung jawab (contoh: jangan campur login & QR code dalam satu file).

---

## 🧠 4. `logic/`

### 📌 Fungsi:

Menyimpan **state management & logika bisnis**. Semua proses yang mengatur *bagaimana data bekerja* ditempatkan di sini.

### 📁 Subfolder & File:

```
logic/
└── providers/
    ├── auth_provider.dart
    ├── ticket_provider.dart
    └── vehicle_provider.dart
```

### 📄 Penjelasan:

* `providers/` → mengatur aliran data dan notifikasi perubahan state ke UI.
  Misalnya saat user login berhasil, UI akan tahu dari sini.

### 🧭 Best Practice:

* Gunakan `ChangeNotifier` (Provider), `Riverpod`, atau `GetX` sesuai kesepakatan tim.
* Satu provider = satu tanggung jawab. Contoh:

  * `AuthProvider` → login/logout
  * `TicketProvider` → tiket parkir
  * `VehicleProvider` → kendaraan user
* Jangan letakkan logika API langsung di UI.

---

## 🎨 5. `presentation/`

### 📌 Fungsi:

Berisi seluruh **tampilan (UI/UX)** aplikasi Parkey.

### 📁 Subfolder & File:

```
presentation/
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── dashboard_screen.dart
│   ├── scan_qr_screen.dart
│   ├── parking_history_screen.dart
│   └── profile_screen.dart
├── widgets/
│   ├── custom_button.dart
│   ├── ticket_card.dart
│   └── qr_display.dart
└── dialogs/
    └── confirm_exit_dialog.dart
```

### 📄 Penjelasan:

* `screens/` → setiap halaman utama aplikasi.
* `widgets/` → komponen kecil yang dapat dipakai ulang, seperti tombol, kartu, dan tampilan QR.
* `dialogs/` → pop-up atau modal dialog (misalnya konfirmasi logout atau keluar aplikasi).

### 🧭 Best Practice:

* Jangan menulis logika bisnis di dalam `screens/`.
* Gunakan widget custom jika elemen UI akan dipakai di lebih dari 1 halaman.
* Gunakan struktur widget yang rapi: `Scaffold` → `AppBar` → `Body`.

---

## 🧩 6. `utils/`

### 📌 Fungsi:

Berisi fungsi bantu (helper functions) dan validasi umum.

### 📁 Subfolder & File:

```
utils/
├── helpers.dart
└── validators.dart
```

### 📄 Penjelasan:

* `helpers.dart` → fungsi umum (format tanggal, konversi teks, dsb.)
* `validators.dart` → validasi input form (misalnya NIK, nomor kendaraan, password)

### 🧭 Best Practice:

* Jangan letakkan fungsi kecil seperti format tanggal langsung di dalam screen.
* Gunakan helper agar kode utama tetap bersih dan terstruktur.

---

## 🖼️ 7. `assets/` *(di luar `lib`)*

### 📌 Fungsi:

Menampung file statis seperti:

* Gambar (`/images`)
* Ikon (`/icons`)
* Font (`/fonts`)

### 📄 Penjelasan:

* Aset harus dideklarasikan di `pubspec.yaml`.
* Gunakan struktur folder yang jelas agar mudah mencari aset.

```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
```

---

## 📝 8. Konvensi Penamaan

| Jenis    | Contoh              | Catatan                            |
| -------- | ------------------- | ---------------------------------- |
| File     | `login_screen.dart` | Gunakan **snake_case**             |
| Class    | `LoginScreen`       | Gunakan **PascalCase**             |
| Variabel | `userName`          | Gunakan **camelCase**              |
| Folder   | `presentation`      | Gunakan **snake_case** tanpa spasi |

🧠 **Tips:** Konsistensi penamaan akan sangat membantu kerja tim, terutama saat aplikasi makin besar.

---

## 🧭 9. Alur Kerja Pengembangan

1. **Tambah Halaman Baru**
   → Buat file baru di `presentation/screens/`
   → Daftarkan route di `config/routes.dart`.

2. **Tambah Model Baru**
   → Buat file baru di `data/models/`.
   → Tambahkan parsing `fromJson` & `toJson`.

3. **Tambah Fungsi API Baru**
   → Tambahkan fungsi di `data/services/api_service.dart` (atau buat service baru).
   → Panggil fungsi dari `logic/providers/`.

4. **Tambah Widget Reusable**
   → Buat di `presentation/widgets/`.
   → Import dan gunakan di screen manapun.

5. **Validasi atau Helper**
   → Tambahkan di `utils/` agar kode tetap bersih.

---

## 📌 10. Tips Kolaborasi Tim

* Setiap anggota tim **wajib memahami struktur folder** ini.
* Jangan mencampur UI, logika, dan data dalam satu file.
* Gunakan `git branch` untuk fitur baru agar mudah di-review.
* Tambahkan komentar pendek di atas setiap class atau fungsi penting.
* Hindari penamaan ambigu seperti `test.dart` atau `new.dart`.

---

## 📎 Contoh Tambahan: Struktur Folder dengan Penjelasan Singkat

```
lib/
├── main.dart                  # Titik masuk aplikasi
├── config/                    # Tema, route, konstanta global
├── data/                      # Model data & service API
├── logic/                     # State management
├── presentation/              # Tampilan aplikasi
├── utils/                     # Helper & validator
└── assets/                    # (di luar lib) Gambar, ikon, font
```

---

✅ **Dengan dokumentasi ini, semua anggota tim Parkey:**

* Tahu di mana meletakkan file.
* Bisa menjaga struktur proyek tetap konsisten.
* Mudah memahami alur kerja saat aplikasi berkembang.

---