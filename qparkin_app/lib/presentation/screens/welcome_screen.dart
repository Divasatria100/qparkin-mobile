import 'package:flutter/material.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  static const routeName = '/welcome';
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // === Background solid biru tua ===
          Container(color: const Color(0xFF1D3D98)),

          // === Ilustrasi mobil di tengah layar ===
          Align(
            alignment: const Alignment(0, -0.60),
            child: Image.asset(
              'assets/images/mobil.png',
              width: MediaQuery.of(context).size.width * 1.4, // responsif
              fit: BoxFit.contain,
            ),
          ),

          // === Kartu putih di bawah (isi teks & tombol "Mulai") ===
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              padding: const EdgeInsets.fromLTRB(20, 13, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF535AD7),
                    offset: Offset(0, 15),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === Judul dan ikon (ellipse gradient) ===
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 27),
                              child: ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: (Rect bounds) {
                                  return const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFFFFFFFF),
                                      Color(0xFF999999),
                                    ],
                                  ).createShader(
                                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                                  );
                                },
                                child: Text(
                                  'Selamat Datang.',
                                  style: Theme.of(context).textTheme.headlineSmall!,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                        ),
                      ),

                      // === Ellipse dengan fill linear, drop shadow, dan gambar tengah ===
                      Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: Container(
                          width: 54,
                          height: 53,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(100)),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFF5585E3), // 18%
                                Color(0xFF573ED1), // 51%
                                Color(0xFF2C0678), // 81%
                              ],
                              stops: [0.18, 0.51, 0.81],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x1A1872B3), // #1872B3 @10%
                                offset: Offset(0, -5),
                                blurRadius: 20,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/q.png',
                              width: 28,
                              height: 28,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Text(
                    'Aplikasi Qparkin dirancang sebagai solusi digital modern '
                    'untuk menggantikan sistem parkir berbasis tiket kertas '
                    'yang umum digunakan di pusat perbelanjaan.',
                    style: TextStyle(
                      color: Color(0xFF6E819B),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // === Tombol "Mulai" (ubah ke warna E32935) ===
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE32935), // warna baru
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        LoginScreen.routeName,
                      ),
                      child: const Text('Mulai'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}