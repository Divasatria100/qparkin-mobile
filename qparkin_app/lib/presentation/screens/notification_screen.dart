import 'package:flutter/material.dart';

/// Notification screen placeholder
/// TODO: Implement full notification functionality
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: const Color(0xFF573ED1),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Halaman Notifikasi - Coming Soon'),
      ),
    );
  }
}
