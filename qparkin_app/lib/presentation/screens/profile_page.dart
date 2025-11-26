import 'package:flutter/material.dart';
import 'list_kendaraan.dart'; // ⭐ TAMBAHKAN INI - Import file VehicleListPage

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicles = [
      {
        "name": "Mercedes G 65",
        "type": "Personal",
        "plate": "A61206",
        "points": 201,
      },
      {
        "name": "Toyota Avanza",
        "type": "Keluarga",
        "plate": "BK 1234 AB",
        "points": 89,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔷 Header dengan gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 100),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF42CBF8),
                      Color(0xFF573ED1),
                      Color(0xFF39108A),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Profile",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.person, size: 30, color: Colors.black),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Diva Satria",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "divasatria@gmail.com",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 🔹 Konten utama
              Transform.translate(
                offset: const Offset(0, -70),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Section: Informasi Kendaraan
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Informasi Kendaraan",
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color.fromARGB(255, 250, 245, 245),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 150,
                        child: PageView.builder(
                          controller: PageController(viewportFraction: 0.9),
                          itemCount: vehicles.length,
                          itemBuilder: (context, index) {
                            final v = vehicles[index];
                            return Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE3F2FD),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.directions_car,
                                      color: Color(0xFF1872B3),
                                      size: 40,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          v['name'] as String,
                                          style: const TextStyle(
                                            fontFamily: 'Nunito',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: Color(0xFF1A1A1A),
                                          ),
                                        ),
                                        Text(
                                          v['type'] as String,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF8E8E93),
                                          ),
                                        ),
                                        Text(
                                          v['plate'] as String,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1872B3),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "${v['points']}",
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const Icon(Icons.star,
                                              color: Color(0xFF1872B3), size: 18),
                                        ],
                                      ),
                                      const Text(
                                        "Points",
                                        style: TextStyle(
                                          color: Color(0xFF8E8E93),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Section Akun
                      _sectionCard(
                        context, // ⭐ TAMBAHKAN context
                        title: "Akun",
                        items: [
                          _menuItem(
                            context, // ⭐ TAMBAHKAN context
                            Icons.edit,
                            "Ubah informasi akun",
                            "Ganti nama, pin, dan e-mail ...",
                            null, // ⭐ TAMBAHKAN parameter onTap
                          ),
                          _menuItem(
                            context, // ⭐ TAMBAHKAN context
                            Icons.directions_car,
                            "List Kendaraan",
                            "Kamu dapat menambahkan kendaraan ...",
                            () {
                              // ⭐ TAMBAHKAN FUNGSI NAVIGASI INI
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const VehicleListPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      // Section Lainnya
                      _sectionCard(
                        context, // ⭐ TAMBAHKAN context
                        title: "Lainnya",
                        items: [
                          _menuItem(
                            context, // ⭐ TAMBAHKAN context
                            Icons.help_outline,
                            "Bantuan",
                            "Kamu dapat mengganti metode pembayaran ...",
                            null, // ⭐ TAMBAHKAN parameter onTap
                          ),
                          _menuItem(
                            context, // ⭐ TAMBAHKAN context
                            Icons.privacy_tip,
                            "Kebijakan Privasi",
                            "Pelajari kebijakan privasi pengguna aplikasi",
                            null, // ⭐ TAMBAHKAN parameter onTap
                          ),
                          _menuItem(
                            context, // ⭐ TAMBAHKAN context
                            Icons.info_outline,
                            "Tentang Aplikasi",
                            "Versi 3.6.2",
                            null, // ⭐ TAMBAHKAN parameter onTap
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ⭐ UBAH: Tambahkan BuildContext dan onTap parameter
  Widget _sectionCard(BuildContext context,
      {required String title, required List<Widget> items}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  // ⭐ UBAH: Tambahkan BuildContext dan VoidCallback? onTap
  Widget _menuItem(BuildContext context, IconData icon, String title,
      String subtitle, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap ?? () {}, // ⭐ GUNAKAN onTap parameter
      splashColor: Colors.blue.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.grey[500]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF969696),
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // ⭐ TAMBAHKAN ICON CHEVRON
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}