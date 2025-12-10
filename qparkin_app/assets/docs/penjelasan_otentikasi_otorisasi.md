# Penjelasan Otentikasi dan Otorisasi di Aplikasi QParkin Mobile

## Pendahuluan
Aplikasi QParkin Mobile adalah aplikasi untuk driver yang menggunakan sistem otentikasi berbasis nomor HP dan PIN. Sistem ini dirancang untuk memastikan keamanan dan kemudahan akses bagi pengguna driver, dengan pembatasan akses untuk Admin Mall dan SuperAdmin yang hanya dapat login melalui platform web.

## Otentikasi (Authentication)
Otentikasi adalah proses verifikasi identitas pengguna untuk memastikan bahwa pengguna yang mengakses aplikasi adalah orang yang benar.

### Mekanisme Otentikasi di QParkin Mobile
1. **Input Otentikasi**:
   - Nomor HP: Menggunakan format internasional (+62) tanpa awalan 0.
   - PIN: 6 digit angka yang bersifat rahasia.

2. **Verifikasi Data**:
   - Data diverifikasi menggunakan dummy credentials di frontend untuk keperluan demo.
   - Dummy credentials:
     - Nomor HP: 81234567890
     - PIN: 123456

3. **Proses Login**:
   - Pengguna memasukkan nomor HP dan PIN di halaman login.
   - Sistem memeriksa kecocokan data dengan dummy credentials.
   - Jika valid, pengguna diarahkan ke DriverDashboard (HomePage).
   - Jika tidak valid, muncul pesan error.

4. **Pembatasan Akses**:
   - Admin Mall dan SuperAdmin tidak dapat login melalui aplikasi mobile.
   - Mereka hanya dapat mengakses sistem melalui platform web.

### Kode Otentikasi
Berikut adalah implementasi otentikasi di file `auth_service.dart`:

```dart
class AuthService {
  static bool isLoggedIn = false;

  // Dummy credentials
  static const String dummyPhone = '81234567890';
  static const String dummyPin = '123456';

  Future<void> login(BuildContext context, String phone, String pin) async {
    // Clean phone number by removing non-digits (spaces, etc.)
    String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone == dummyPhone && pin == dummyPin) {
      isLoggedIn = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login sukses')),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login gagal: kredensial salah')),
      );
    }
  }
}
```

## Otorisasi (Authorization)
Otorisasi adalah proses menentukan hak akses pengguna setelah berhasil diotentikasi.

### Mekanisme Otorisasi di QParkin Mobile
1. **Role-Based Access Control (RBAC)**:
   - Aplikasi mobile hanya untuk driver.
   - Admin Mall dan SuperAdmin dikecualikan dari akses mobile.

2. **Session Management**:
   - Menggunakan flag `isLoggedIn` untuk menentukan status login.
   - Token mock ('mock_token_123') digunakan untuk simulasi.

3. **Navigasi Berdasarkan Status Login**:
   - Jika sudah login, langsung ke HomePage.
   - Jika belum login, tampilkan AboutPage terlebih dahulu.

### Kode Otorisasi
Implementasi otorisasi di `main.dart`:

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ...
      home: FutureBuilder(
        future: AuthService().getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          // JIKA SUDAH LOGIN (ada token) -> langsung ke HomePage
          if (snapshot.hasData && snapshot.data != null) {
            return const HomePage();
          }
          
          // JIKA BELUM LOGIN -> tampilkan AboutPage pertama kali
          return const AboutPage();
        },
      ),
      // ...
    );
  }
}
```

## Keamanan Basis Data
Untuk keperluan praktikum keamanan basis data, sistem ini menggunakan dummy data di frontend. Dalam implementasi nyata, data harus disimpan dan diverifikasi di backend dengan enkripsi yang kuat.

### Rekomendasi Keamanan
1. **Enkripsi PIN**: Gunakan hashing seperti bcrypt atau Argon2.
2. **Token JWT**: Implementasikan JWT untuk session management yang aman.
3. **Rate Limiting**: Batasi jumlah percobaan login untuk mencegah brute force.
4. **Two-Factor Authentication (2FA)**: Tambahkan verifikasi SMS untuk keamanan ekstra.
5. **Audit Logging**: Catat semua aktivitas login untuk monitoring.

## Kesimpulan
Sistem otentikasi dan otorisasi di QParkin Mobile menggunakan nomor HP dan PIN dengan verifikasi dummy untuk demo. Sistem ini memastikan hanya driver yang dapat mengakses aplikasi mobile, sementara admin menggunakan platform web. Implementasi ini dapat dikembangkan lebih lanjut dengan integrasi backend yang aman untuk production use.
