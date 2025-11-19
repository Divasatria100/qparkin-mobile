import 'package:flutter/material.dart';
import '/utils/security_utils.dart';

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

  Future<void> sendResetCode(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kode terkirim (mock)')),
    );
  }

  Future<String?> getToken() async {
    // Return token only if logged in
    return isLoggedIn ? 'mock_token_123' : null;
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google login sukses (mock)')),
    );
  }
}
