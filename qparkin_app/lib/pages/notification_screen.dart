import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final todayNotifications = [
    {
      'message':
          'Anda keluar pukul 14:20 WIB. Pembayaran berhasil diproses di gate, Hati-hati di jalan!',
      'time': '14:01',
      'type': 'exit',
    },
    {
      'message':
          'Selamat datang di One Mall! Parkir Anda tercatat pukul 09:45 WIB',
      'time': '09:45',
      'type': 'entry',
    },
  ];

  final yesterdayNotifications = [
    {
      'message':
          'Anda keluar pukul 14:20 WIB. Pembayaran berhasil diproses di gate, Hati-hati di jalan!',
      'time': '14:20',
      'type': 'exit',
    },
    {
      'message':
          'Selamat datang di One Mall! Parkir Anda tercatat pukul 09:45 WIB',
      'time': '09:45',
      'type': 'entry',
    },
  ];

  final thisWeekNotifications = [
    {
      'message':
          'Anda keluar pukul 14:20 WIB. Pembayaran berhasil diproses di gate, Hati-hati di jalan!',
      'time': '14:20',
      'type': 'exit',
    },
    {
      'message':
          'Selamat datang di One Mall! Parkir Anda tercatat pukul 09:45 WIB',
      'time': '09:45',
      'type': 'entry',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // HEADER
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7C5ED1), Color(0xFF573ED1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Notifikasi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // CONTENT
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  MediaQuery.of(context).size.height * 0.12 + 20,
                ),
                children: [
                  _buildSection('Hari Ini', todayNotifications),
                  const SizedBox(height: 24),
                  _buildSection('Kemarin', yesterdayNotifications),
                  const SizedBox(height: 24),
                  _buildSection('Minggu Ini', thisWeekNotifications),
                ],
              ),
            ),
          ),
        ],
      ),

      // ============================
      // BOTTOM NAV DIHAPUS SESUAI PERMINTAAN
      // ============================

    );
  }

  Widget _buildSection(String title, List<Map<String, String>> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...data.map((item) => _buildNotificationCard(item)),
      ],
    );
  }

  Widget _buildNotificationCard(Map<String, String> item) {
    IconData icon;
    Color iconColor;

    switch (item['type']) {
      case 'exit':
        icon = Icons.exit_to_app;
        iconColor = const Color(0xFFF44336);
        break;
      case 'entry':
        icon = Icons.login;
        iconColor = const Color(0xFF4CAF50);
        break;
      default:
        icon = Icons.notifications;
        iconColor = const Color(0xFF573ED1);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _AnimatedCard(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['message']!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          item['time']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;

  const _AnimatedCard({
    required this.child,
    this.onTap,
    this.borderRadius = 16,
  });

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            splashColor: const Color(0xFF573ED1).withOpacity(0.15),
            highlightColor: const Color(0xFF573ED1).withOpacity(0.08),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
