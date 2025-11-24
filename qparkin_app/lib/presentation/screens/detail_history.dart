import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/bottom_nav.dart';
import '/utils/navigation_utils.dart';

class DetailHistoryPage extends StatefulWidget {
  final Map<String, dynamic> history;

  const DetailHistoryPage({Key? key, required this.history}) : super(key: key);

  @override
  _DetailHistoryPageState createState() => _DetailHistoryPageState();
}

class _DetailHistoryPageState extends State<DetailHistoryPage> {
  bool _isCostValid = false;
  bool _isTimeValid = false;
  String _costValidationMessage = '';
  String _timeValidationMessage = '';

  @override
  void initState() {
    super.initState();
    _validateDataIntegrity();
  }

  void _validateDataIntegrity() {
    _validateCost();
    _validateTime();
  }

  void _validateCost() {
    // Simulasi validasi konsistensi perhitungan biaya
    // Asumsikan tarif 5000 per jam
    const int ratePerHour = 5000;
    const int penaltyThresholdHours = 24; // Penalti jika lebih dari 24 jam
    const int penaltyAmount = 10000;

    // Parse durasi: misal '2 jam 30 menit' -> 2.5 jam
    String durationStr = widget.history['duration'];
    double totalHours = _parseDurationToHours(durationStr);

    int baseCost = (totalHours * ratePerHour).round();
    int penalty = totalHours > penaltyThresholdHours ? penaltyAmount : 0;
    int expectedCost = baseCost + penalty;

    // Parse cost dari history: hapus 'Rp ' dan ','
    String costStr = widget.history['cost'].replaceAll('Rp ', '').replaceAll(',', '');
    int actualCost = int.tryParse(costStr) ?? 0;

    if (expectedCost == actualCost) {
      _isCostValid = true;
      _costValidationMessage = 'Biaya konsisten dengan durasi dan tarif.';
    } else {
      _isCostValid = false;
      _costValidationMessage = 'Biaya tidak konsisten. Diharapkan: Rp ${expectedCost.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    }
  }

  double _parseDurationToHours(String duration) {
    // Sederhana: asumsikan format 'X jam Y menit'
    RegExp regExp = RegExp(r'(\d+)\s*jam\s*(\d+)\s*menit');
    Match? match = regExp.firstMatch(duration);
    if (match != null) {
      int hours = int.parse(match.group(1)!);
      int minutes = int.parse(match.group(2)!);
      return hours + (minutes / 60.0);
    }
    return 0.0;
  }

  void _validateTime() {
    // Validasi format data waktu
    String timeStr = widget.history['time'];
    List<String> times = timeStr.split(' - ');
    if (times.length != 2) {
      _isTimeValid = false;
      _timeValidationMessage = 'Format waktu tidak valid.';
      return;
    }

    DateTime? entryTime = _parseTime(times[0]);
    DateTime? exitTime = _parseTime(times[1]);

    if (entryTime == null || exitTime == null) {
      _isTimeValid = false;
      _timeValidationMessage = 'Waktu masuk atau keluar tidak valid.';
      return;
    }

    if (exitTime.isBefore(entryTime)) {
      _isTimeValid = false;
      _timeValidationMessage = 'Waktu keluar sebelum waktu masuk.';
      return;
    }

    Duration calculatedDuration = exitTime.difference(entryTime);
    double hours = calculatedDuration.inMinutes / 60.0;
    double expectedHours = _parseDurationToHours(widget.history['duration']);

    if ((hours - expectedHours).abs() < 0.1) { // Toleransi 6 menit
      _isTimeValid = true;
      _timeValidationMessage = 'Data waktu valid dan durasi logis.';
    } else {
      _isTimeValid = false;
      _timeValidationMessage = 'Durasi tidak sesuai dengan waktu masuk dan keluar.';
    }
  }

  DateTime? _parseTime(String timeStr) {
    // Asumsikan format 'HH:mm'
    try {
      List<String> parts = timeStr.split(':');
      if (parts.length == 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        // Gunakan tanggal dummy untuk parsing
        return DateTime(2023, 1, 1, hour, minute);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/activity');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Detail Riwayat Parkir',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Color(0xFF573ED1),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF573ED1), Color(0xFF7C3AED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF573ED1).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.history['location'],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Parkir Selesai',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.attach_money,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.history['cost'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Detail Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailCard(
                          icon: Icons.calendar_today,
                          title: 'Tanggal',
                          value: widget.history['date'],
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailCard(
                          icon: Icons.access_time,
                          title: 'Waktu',
                          value: widget.history['time'],
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailCard(
                          icon: Icons.timer,
                          title: 'Durasi',
                          value: widget.history['duration'],
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailCard(
                          icon: Icons.check_circle,
                          title: 'Status',
                          value: 'Selesai',
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Timeline Section
                  Container(
                    padding: const EdgeInsets.all(20),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Timeline Parkir',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTimelineItem(
                          icon: Icons.directions_car,
                          title: 'Masuk Parkir',
                          subtitle: '${widget.history['date']} • ${widget.history['time'].split(' - ')[0]}',
                          isFirst: true,
                        ),
                        _buildTimelineItem(
                          icon: Icons.exit_to_app,
                          title: 'Keluar Parkir',
                          subtitle: '${widget.history['date']} • ${widget.history['time'].split(' - ')[1]}',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Action to share or print receipt
                        // Pada implementasi backend, sebelum share, verifikasi hash untuk memastikan data sah.
                      },
                      icon: const Icon(Icons.share, color: Colors.white),
                      label: const Text(
                        'Bagikan Bukti Parkir',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF573ED1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: CurvedNavigationBar(
          index: 1,
          onTap: (index) => NavigationUtils.handleNavigation(context, index, 1),
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFF573ED1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
