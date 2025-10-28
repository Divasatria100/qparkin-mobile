// lib/presentation/screens/booking_payment_page.dart
import 'package:flutter/material.dart';

class BookingPaymentPage extends StatefulWidget {
  final int totalAmount;
  final String bookingId;

  const BookingPaymentPage({
    super.key,
    this.totalAmount = 10000,
    this.bookingId = 'BK123456789',
  });

  @override
  State<BookingPaymentPage> createState() => _BookingPaymentPageState();
}

class _BookingPaymentPageState extends State<BookingPaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'QParkin',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.purple.shade50.withOpacity(0.3),
            ],
            stops: const [0.7, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Judul
              const Text(
                'QRIS Pembayaran',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Instruksi
              Text(
                'scan qris kode untuk membayar',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue[400],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // QR Code Container
              Container(
                width: 260,
                height: 260,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: QRCodePainter(),
                  child: Container(),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Info Tagihan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Tagihan Sebesar',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'RP. ${_formatCurrency(widget.totalAmount)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B6B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total yang harus di bayarkan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Informasi Tambahan
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue[200]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Scan QR Code menggunakan aplikasi e-wallet atau mobile banking Anda',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[900],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

// Custom Painter untuk QR Code Pattern
class QRCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final squareSize = size.width / 25;

    // Pattern QR Code sederhana (dummy)
    final pattern = [
      [1,1,1,1,1,1,1,0,1,0,1,0,1,1,0,0,1,0,1,1,1,1,1,1,1],
      [1,0,0,0,0,0,1,0,0,1,0,1,1,0,1,0,0,0,1,0,0,0,0,0,1],
      [1,0,1,1,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,1,1,0,1],
      [1,0,1,1,1,0,1,0,0,1,1,0,0,1,0,1,0,0,1,0,1,1,1,0,1],
      [1,0,1,1,1,0,1,0,1,0,1,1,0,1,0,0,1,0,1,0,1,1,1,0,1],
      [1,0,0,0,0,0,1,0,1,1,0,1,1,0,1,1,0,0,1,0,0,0,0,0,1],
      [1,1,1,1,1,1,1,0,1,0,1,0,1,0,1,0,1,0,1,1,1,1,1,1,1],
      [0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0],
      [1,0,1,1,0,1,1,1,1,0,1,1,0,1,0,1,1,0,0,1,0,1,0,1,0],
      [0,1,0,1,1,0,0,0,0,1,0,0,1,0,1,0,0,1,1,0,1,0,1,0,1],
      [1,0,1,0,0,1,1,1,1,0,1,1,0,1,0,1,0,0,1,1,0,1,0,1,0],
      [0,1,1,1,0,0,0,0,0,1,0,0,1,0,1,1,1,1,0,0,1,0,1,0,1],
      [1,0,0,0,1,1,1,1,1,0,1,1,0,1,0,0,0,0,1,1,0,1,0,1,0],
      [0,1,1,0,1,0,0,0,0,1,0,0,1,0,1,1,1,1,0,0,1,0,1,0,1],
      [1,0,1,1,0,1,1,1,1,0,1,1,0,1,0,0,0,0,1,1,0,1,0,1,0],
      [0,1,0,0,1,0,0,0,0,1,0,0,1,0,1,1,1,1,0,0,1,0,1,0,1],
      [1,0,1,1,0,1,1,1,0,1,1,0,1,0,1,0,0,1,1,0,1,0,1,1,0],
      [0,0,0,0,0,0,0,0,1,0,0,1,0,1,0,1,1,0,0,1,0,1,0,0,1],
      [1,1,1,1,1,1,1,0,1,1,0,1,1,0,1,0,0,1,1,0,1,0,1,1,0],
      [1,0,0,0,0,0,1,0,0,0,1,0,0,1,0,1,1,0,0,1,0,1,0,0,1],
      [1,0,1,1,1,0,1,0,1,1,0,1,1,0,1,0,0,1,1,0,1,0,1,1,0],
      [1,0,1,1,1,0,1,0,0,0,1,0,0,1,0,1,1,0,0,1,0,1,0,0,1],
      [1,0,1,1,1,0,1,0,1,1,0,1,1,0,1,0,0,1,1,0,1,0,1,1,0],
      [1,0,0,0,0,0,1,0,0,0,1,0,0,1,0,1,1,0,0,1,0,1,0,0,1],
      [1,1,1,1,1,1,1,0,1,1,0,1,1,0,1,0,0,1,1,0,1,0,1,1,0],
    ];

    for (int i = 0; i < pattern.length; i++) {
      for (int j = 0; j < pattern[i].length; j++) {
        if (pattern[i][j] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(
              j * squareSize,
              i * squareSize,
              squareSize,
              squareSize,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}