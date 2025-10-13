// lib/screens/about_page.dart
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A), // Warna biru tua seperti di gambar
      body: SafeArea(
        child: Column(
          children: [
            // Bagian atas dengan ilustrasi
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32.0),
                child: Image.asset(
                  'assets/images/parking_illustration.png', // Ganti dengan path ilustrasi Anda
                  fit: BoxFit.contain,
                ),
              ),
            ),
            
            // Bagian bawah dengan card putih
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Qparkin di pojok kanan atas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 48), // Spacer untuk balance
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5), // Warna ungu/biru
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.local_parking,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Judul
                    const Text(
                      'Selamat Datang.',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF94A3B8), // Abu-abu muda
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Deskripsi
                    const Text(
                      'Aplikasi Qparkin dirancang sebagai solusi digital modern untuk menggantikan sistem parkir berbasis tiket kertas yang umum digunakan di pusat perbelanjaan.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF94A3B8),
                        height: 1.5,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Button Mulai
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444), // Merah
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Mulai',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}