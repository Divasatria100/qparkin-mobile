// lib/screens/about_page.dart
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      body: SafeArea(
        child: Column(
          children: [
            // Bagian atas dengan ilustrasi
            Expanded(
              flex: isMobile ? 5 : 6,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
                child: Image.asset(
                  'assets/images/mobil.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            
            // Bagian bawah dengan card putih
            Expanded(
              flex: isMobile ? 5 : 4,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                padding: EdgeInsets.all(isMobile ? 20.0 : 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Qparkin di pojok kanan atas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: isMobile ? 30 : 48),
                        Container(
                          width: isMobile ? 60 : 80,
                          height: isMobile ? 60 : 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.local_parking,
                            color: Colors.white,
                            size: isMobile ? 28 : 40,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isMobile ? 16 : 24),
                    
                    // Judul
                    Text(
                      'Selamat Datang.',
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    SizedBox(height: isMobile ? 12 : 16),
                    
                    // Deskripsi
                    Text(
                      'Aplikasi Qparkin dirancang sebagai solusi digital modern untuk menggantikan sistem parkir berbasis tiket kertas yang umum digunakan di pusat perbelanjaan.',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 16,
                        color: const Color(0xFF94A3B8),
                        height: 1.5,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Button Mulai
                    SizedBox(
                      width: double.infinity,
                      height: isMobile ? 48 : 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Mulai',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isMobile ? 12 : 16),
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