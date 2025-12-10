import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart'; // komponen bottom nav


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int _selectedIndex = 3; // posisi tab 'Notifikasi'

  final todayNotifications = [
    {
      'message':
          'Anda keluar pukul 14:20 WIB. Pembayaran berhasil diproses di gate, Hati-hati di jalan!',
      'time': '14:01am',
    },
    {
      'message':
          'Selamat datang di One Mall! Parkir Anda tercatat pukul 09:45 WIB',
      'time': '9:01am',
    },
  ];

  final yesterdayNotifications = [
    {
      'message':
          'Anda keluar pukul 14:20 WIB. Pembayaran berhasil diproses di gate, Hati-hati di jalan!',
      'time': '14:01am',
    },
    {
      'message':
          'Selamat datang di One Mall! Parkir Anda tercatat pukul 09:45 WIB',
      'time': '9:01am',
    },
  ];

  final thisWeekNotifications = [
    {
      'message':
          'Anda keluar pukul 14:20 WIB. Pembayaran berhasil diproses di gate, Hati-hati di jalan!',
      'time': '14:01am',
    },
    {
      'message':
          'Selamat datang di One Mall! Parkir Anda tercatat pukul 09:45 WIB',
      'time': '9:01am',
    },
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    // TODO: Tambahkan navigasi antar halaman nanti di sini
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          buildSection('Today', todayNotifications),
          buildSection('Yesterday', yesterdayNotifications),
          buildSection('This week', thisWeekNotifications),
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget buildSection(String title, List<Map<String, String>> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ...data.map((item) => buildNotificationTile(item)).toList(),
      ],
    );
  }

  Widget buildNotificationTile(Map<String, String> item) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage('assets/avatar.png'),
          ),
          title: Text(
            item['message']!,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF555555),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              item['time']!,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF999999),
              ),
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
