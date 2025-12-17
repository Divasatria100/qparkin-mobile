import 'package:flutter/material.dart';
import '../../utils/responsive_helper.dart';

/// Bottom sheet widget displaying information about the point system
///
/// Provides users with information about:
/// - How to earn points
/// - How to use points
/// - Point expiration policy
/// - Terms and conditions
///
/// Requirements: 4.1
class PointInfoBottomSheet extends StatelessWidget {
  const PointInfoBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF573ED1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.stars,
                      color: Color(0xFF573ED1),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Tentang Poin QParkin',
                      style: TextStyle(
                        fontSize: isTablet ? 22 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Introduction
              _buildSection(
                icon: Icons.info_outline,
                title: 'Apa itu Poin QParkin?',
                content:
                    'Poin QParkin adalah sistem reward yang memberikan Anda poin setiap kali melakukan booking parkir. Poin yang terkumpul dapat digunakan untuk mendapatkan diskon pada booking berikutnya.',
                isTablet: isTablet,
              ),
              const SizedBox(height: 20),

              // How to earn
              _buildSection(
                icon: Icons.add_circle_outline,
                title: 'Cara Mendapatkan Poin',
                content: 'Dapatkan 1 poin untuk setiap Rp1.000 yang Anda bayarkan untuk parkir.',
                isTablet: isTablet,
                children: [
                  _buildExample(
                    'Contoh:',
                    'Parkir Rp50.000 = 50 poin',
                    isTablet: isTablet,
                  ),
                  _buildExample(
                    '',
                    'Parkir Rp100.000 = 100 poin',
                    isTablet: isTablet,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // How to use
              _buildSection(
                icon: Icons.redeem,
                title: 'Cara Menggunakan Poin',
                content: 'Tukarkan poin Anda untuk mendapatkan diskon saat booking parkir. 1 poin = Rp100 diskon.',
                isTablet: isTablet,
                children: [
                  _buildBulletPoint(
                    '✨ Minimum penggunaan: 10 poin (Rp1.000)',
                    isTablet: isTablet,
                  ),
                  _buildBulletPoint(
                    '🎯 Maksimum diskon: 30% dari total biaya',
                    isTablet: isTablet,
                  ),
                  _buildExample(
                    'Contoh:',
                    'Biaya Rp50.000, gunakan 100 poin = diskon Rp10.000',
                    isTablet: isTablet,
                  ),
                  _buildExample(
                    '',
                    'Biaya Rp100.000, maksimal 300 poin = diskon Rp30.000',
                    isTablet: isTablet,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Refund policy
              _buildSection(
                icon: Icons.refresh,
                title: 'Kebijakan Refund',
                content:
                    'Jika Anda membatalkan booking yang menggunakan poin, poin akan dikembalikan ke saldo Anda secara otomatis.',
                isTablet: isTablet,
              ),
              const SizedBox(height: 20),

              // Terms
              _buildSection(
                icon: Icons.description_outlined,
                title: 'Syarat & Ketentuan',
                content: null,
                isTablet: isTablet,
                children: [
                  _buildBulletPoint(
                    'Poin tidak dapat ditransfer ke akun lain',
                    isTablet: isTablet,
                  ),
                  _buildBulletPoint(
                    'Poin tidak dapat ditukar dengan uang tunai',
                    isTablet: isTablet,
                  ),
                  _buildBulletPoint(
                    'QParkin berhak mengubah kebijakan poin',
                    isTablet: isTablet,
                  ),
                  _buildBulletPoint(
                    'Penyalahgunaan poin dapat mengakibatkan pemblokiran akun',
                    isTablet: isTablet,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF573ED1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Mengerti',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    String? content,
    required bool isTablet,
    List<Widget>? children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: isTablet ? 24 : 20,
              color: const Color(0xFF573ED1),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (content != null)
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Text(
              content,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        if (children != null)
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
      ],
    );
  }

  Widget _buildBulletPoint(String text, {required bool isTablet}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isTablet ? 16 : 14,
          color: Colors.grey[700],
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildExample(String label, String text, {required bool isTablet}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF573ED1).withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF573ED1).withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            if (label.isNotEmpty) ...[
              Text(
                label,
                style: TextStyle(
                  fontSize: isTablet ? 15 : 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF573ED1),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: isTablet ? 15 : 13,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
