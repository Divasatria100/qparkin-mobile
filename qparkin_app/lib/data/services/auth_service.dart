import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
static const String baseUrl = String.fromEnvironment('API_URL');
  static const String loginEndpoint = '/api/login';

  final _secureStorage = const FlutterSecureStorage();

  /// Login menggunakan nomor HP dan PIN
  /// Returns: {'success': bool, 'message': string, 'user': Map?, 'token': string?}
  Future<Map<String, dynamic>> login({
    required String phone,
    required String pin,
    required bool rememberMe,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$loginEndpoint');

      // Persiapan request body
      final body = {
        'nomor_hp': phone,
        'pin': pin,
      };

      // Lakukan HTTP POST request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Koneksi timeout. Silakan coba lagi.'),
      );

      // Parsing response
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      // Status 200 - Login berhasil
      if (response.statusCode == 200) {
        final token = responseData['token'] as String?;
        final user = responseData['user'] as Map<String, dynamic>?;

        if (token != null && token.isNotEmpty) {
          // Simpan token ke secure storage
          await _secureStorage.write(key: 'auth_token', value: token);

          // Simpan user data
          if (user != null) {
            await _secureStorage.write(
              key: 'user_data',
              value: jsonEncode(user),
            );
          }

          // Jika rememberMe aktif, simpan nomor HP
          if (rememberMe) {
            await _secureStorage.write(key: 'saved_phone', value: phone);
          } else {
            await _secureStorage.delete(key: 'saved_phone');
          }

          return {
            'success': true,
            'message': 'Login berhasil',
            'user': user,
            'token': token,
          };
        } else {
          return {
            'success': false,
            'message': 'Token tidak ditemukan dalam response',
          };
        }
      }

      // Status 401 - Unauthorized (nomor HP tidak ditemukan atau PIN salah)
      else if (response.statusCode == 401) {
        final message = responseData['message'] ?? 'Login gagal. Nomor HP atau PIN salah.';
        return {
          'success': false,
          'message': message,
        };
      }

      // Status 403 - Forbidden (akun tidak aktif)
      else if (response.statusCode == 403) {
        final message = responseData['message'] ?? 'Akun tidak aktif.';
        return {
          'success': false,
          'message': message,
        };
      }

      // Status 500 - Server error
      else if (response.statusCode == 500) {
        final message = responseData['message'] ?? 'Terjadi kesalahan pada server.';
        return {
          'success': false,
          'message': message,
        };
      }

      // Status code lainnya
      else {
        return {
          'success': false,
          'message': 'Terjadi kesalahan. Status code: ${response.statusCode}',
        };
      }
    } on TimeoutException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// Ambil token yang tersimpan
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: 'auth_token');
    } catch (e) {
      return null;
    }
  }

  /// Ambil data user yang tersimpan
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final userJson = await _secureStorage.read(key: 'user_data');
      if (userJson != null) {
        return jsonDecode(userJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Ambil nomor HP yang tersimpan (jika rememberMe aktif)
  Future<String?> getSavedPhone() async {
    try {
      return await _secureStorage.read(key: 'saved_phone');
    } catch (e) {
      return null;
    }
  }

  /// Registrasi menggunakan nama, nomor HP, dan PIN
  /// Returns: {'success': bool, 'message': string}
  Future<Map<String, dynamic>> register({
    required String nama,
    required String nomorHp,
    required String pin,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/register');

      // Persiapan request body
      final body = {
        'nama': nama,
        'nomor_hp': nomorHp,
        'pin': pin,
      };

      // Lakukan HTTP POST request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Koneksi timeout. Silakan coba lagi.'),
      );

      // Parsing response
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      // Status 201 - Registrasi berhasil (Created)
      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Registrasi berhasil',
        };
      }

      // Status 200 - OK (jika backend menggunakan 200)
      else if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Registrasi berhasil',
        };
      }

      // Status 400 - Bad Request (validasi gagal)
      else if (response.statusCode == 400) {
        final message = responseData['message'] ?? 'Data tidak valid.';
        return {
          'success': false,
          'message': message,
        };
      }

      // Status 409 - Conflict (nomor HP sudah terdaftar)
      else if (response.statusCode == 409) {
        final message = responseData['message'] ?? 'Nomor HP sudah terdaftar.';
        return {
          'success': false,
          'message': message,
        };
      }

      // Status 500 - Server error
      else if (response.statusCode == 500) {
        final message = responseData['message'] ?? 'Terjadi kesalahan pada server.';
        return {
          'success': false,
          'message': message,
        };
      }

      // Status code lainnya
      else {
        return {
          'success': false,
          'message': 'Terjadi kesalahan. Status code: ${response.statusCode}',
        };
      }
    } on TimeoutException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// Cek apakah user sudah login
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Logout - hapus semua data tersimpan
  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'user_data');
      await _secureStorage.delete(key: 'saved_phone');
    } catch (e) {
      throw Exception('Error logging out: $e');
    }
  }

  /// Buat header dengan Bearer token untuk request autentikasi
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}