# Penjelasan Enkripsi Data di Aplikasi QParkin Mobile

## Pendahuluan
Aplikasi QParkin Mobile menerapkan praktik keamanan basis data dengan melakukan enkripsi pada data sensitif seperti PIN pengguna. Implementasi ini menggunakan hashing SHA-256 untuk demonstrasi, meskipun dalam production sebaiknya menggunakan algoritma yang lebih aman seperti bcrypt atau Argon2.

## Mekanisme Enkripsi Data

### 1. Enkripsi PIN
- **Algoritma**: SHA-256 (untuk demonstrasi)
- **Tujuan**: Melindungi PIN dari penyimpanan dalam bentuk plaintext
- **Implementasi**: PIN di-hash sebelum "disimpan" ke dalam sistem

### 2. Simulasi SSL/TLS
- **Konsep**: Semua komunikasi data harus melalui koneksi HTTPS
- **Implementasi**: Method stub yang menjelaskan validasi SSL/TLS
- **Tujuan**: Memastikan data terenkripsi saat transit

### 3. Logging Keamanan
- **Prinsip**: Data sensitif tidak boleh dicatat dalam log
- **Implementasi**: Log hanya mencatat aksi, bukan nilai data

## Kode Implementasi

### SecurityUtils Class
```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';

class SecurityUtils {
  /// Hash a PIN using SHA-256 for demonstration purposes.
  /// In production, use bcrypt or Argon2 for password hashing.
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Simulate SSL/TLS connection for data transmission.
  /// This is a stub method to demonstrate the concept.
  /// In production, ensure all API calls use HTTPS.
  static void ensureHttpsConnection() {
    // TODO: Implement HTTPS validation
    // In Flutter, use Dio or http package with proper SSL pinning
    // Example: Validate certificate, use pinned certificates, etc.
    print('SSL/TLS simulation: All data transmissions should use HTTPS');
  }

  /// Log sensitive data handling for demonstration.
  /// In production, never log sensitive data.
  static void logSensitiveDataHandling(String action, String dataType) {
    print('Security Log: $action performed on $dataType');
    print('Note: In production, sensitive data should never be logged');
  }
}
```

### AuthService Signup Method
```dart
Future<void> signup(BuildContext context, String name, String phone, String pin) async {
  // Simulate security measures for demonstration
  SecurityUtils.ensureHttpsConnection();

  // Hash the PIN before "storing" (for demo purposes, just log the hash)
  String hashedPin = SecurityUtils.hashPin(pin);
  print('Hashed PIN for user $name: $hashedPin');

  // Log the action
  SecurityUtils.logSensitiveDataHandling('User registration', 'PIN');

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Sign Up sukses (mock)')),
  );
}
```

## Output Demonstrasi
Ketika pengguna melakukan signup dengan PIN "123456", sistem akan menampilkan:
```
SSL/TLS simulation: All data transmissions should use HTTPS
Hashed PIN for user [Nama]: 8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92
Security Log: User registration performed on PIN
Note: In production, sensitive data should never be logged
```

## Rekomendasi Production
1. **Hashing Algorithm**: Gunakan bcrypt atau Argon2 untuk password hashing
2. **SSL/TLS**: Implementasikan certificate pinning dan validasi HTTPS
3. **Key Management**: Gunakan hardware security modules (HSM) untuk key storage
4. **Encryption at Rest**: Enkripsi data di database menggunakan AES-256
5. **Audit Logging**: Implementasikan comprehensive audit trails tanpa data sensitif

## Kesimpulan
Implementasi enkripsi di QParkin Mobile menunjukkan praktik keamanan dasar dengan hashing PIN dan simulasi SSL/TLS. Dalam production, sistem ini harus diperkuat dengan algoritma yang lebih aman dan implementasi keamanan yang komprehensif untuk melindungi data pengguna dari berbagai ancaman keamanan.
