import 'package:flutter/material.dart';

class AuthService {
  Future<void> login(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login sukses (mock)')),
    );
  }

  Future<void> signup(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sign Up sukses (mock)')),
    );
  }

  Future<void> sendResetCode(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kode terkirim (mock)')),
    );
  }
}
