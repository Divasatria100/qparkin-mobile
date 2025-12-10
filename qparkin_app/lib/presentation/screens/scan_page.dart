import 'package:flutter/material.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan'),
        backgroundColor: const Color(0xFF573ED1),
      ),
      body: const Center(
        child: Text('Scan Page - Coming Soon'),
      ),
    );
  }
}
