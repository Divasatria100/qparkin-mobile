import 'package:flutter/material.dart';

class InTicketPage extends StatelessWidget {
  final String locationName;
  final String distance;
  final String qrData;
  final String startTime;
  final String endTime;
  final String date;
  final String floor;

  const InTicketPage({
    Key? key,
    required this.locationName,
    required this.distance,
    required this.qrData,
    required this.startTime,
    required this.endTime,
    required this.date,
    required this.floor,
  }) : super(key: key);

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
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // Title
                      const Text(
                        'QR Tampil',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Ticket Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Location Info Section
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Text(
                                    locationName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.directions_walk,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        distance,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            // QR Code Section
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'scan qr code ini pada saat masuk',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF6B9BD1),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  
                                  // QR Code (Dummy)
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: DummyQrCode(
                                      data: qrData,
                                      size: 200,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Dashed Divider
                            CustomPaint(
                              size: const Size(double.infinity, 1),
                              painter: DashedLinePainter(),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Booking Details Section
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            startTime,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            locationName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.directions_walk,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                floor,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      
                                      // Center dot indicator
                                      Column(
                                        children: [
                                          const SizedBox(height: 8),
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFFFB74D),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            endTime,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            date,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle button action
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D5A99),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for Dashed Line
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.5;

    const dashWidth = 5.0;
    const dashSpace = 5.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Dummy QR Code Widget
class DummyQrCode extends StatelessWidget {
  final String data;
  final double size;

  const DummyQrCode({
    Key? key,
    required this.data,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: CustomPaint(
        painter: QrPatternPainter(),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Text(
              data.length > 15 ? '${data.substring(0, 15)}...' : data,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Painter for QR Pattern (Dummy)
class QrPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final blockSize = size.width / 20;

    // Draw random QR-like pattern
    for (int i = 0; i < 20; i++) {
      for (int j = 0; j < 20; j++) {
        // Create a pseudo-random pattern based on position
        final isBlack = ((i + j) * 7) % 3 == 0 || 
                       (i * j) % 5 == 0 ||
                       ((i - j).abs()) % 4 == 0;
        
        // Skip center area for data text
        final isCenterArea = i > 7 && i < 13 && j > 7 && j < 13;
        
        if (isBlack && !isCenterArea) {
          canvas.drawRect(
            Rect.fromLTWH(
              i * blockSize,
              j * blockSize,
              blockSize * 0.9,
              blockSize * 0.9,
            ),
            paint,
          );
        }
      }
    }

    // Draw corner position markers (QR code characteristic)
    drawPositionMarker(canvas, paint, 0, 0, blockSize);
    drawPositionMarker(canvas, paint, 13, 0, blockSize);
    drawPositionMarker(canvas, paint, 0, 13, blockSize);
  }

  void drawPositionMarker(Canvas canvas, Paint paint, int x, int y, double blockSize) {
    // Outer square
    canvas.drawRect(
      Rect.fromLTWH(x * blockSize, y * blockSize, blockSize * 7, blockSize * 7),
      paint,
    );
    
    // Inner white square
    canvas.drawRect(
      Rect.fromLTWH(
        (x + 1) * blockSize,
        (y + 1) * blockSize,
        blockSize * 5,
        blockSize * 5,
      ),
      Paint()..color = Colors.white,
    );
    
    // Center black square
    canvas.drawRect(
      Rect.fromLTWH(
        (x + 2) * blockSize,
        (y + 2) * blockSize,
        blockSize * 3,
        blockSize * 3,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Example usage:
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => InTicketPage(
//       locationName: 'Mega Mall Batam Center',
//       distance: '2 km',
//       qrData: 'YOUR_QR_CODE_DATA_HERE',
//       startTime: '10:00 AM',
//       endTime: '13:00 PM',
//       date: '11 Apr, 2021',
//       floor: 'Basement, lantai 2',
//     ),
//   ),
// );