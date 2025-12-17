import 'package:flutter/material.dart';
import '../../utils/responsive_helper.dart';

/// Empty state widget for point history
///
/// Displays when user has no point transaction history.
/// Provides helpful information about how to earn points.
///
/// Requirements: 2.1
class PointEmptyState extends StatelessWidget {
  const PointEmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 48.0 : 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: isTablet ? 140 : 120,
              height: isTablet ? 140 : 120,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(87, 62, 209, 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.stars_outlined,
                size: isTablet ? 70 : 60,
                color: const Color(0xFF573ED1),
              ),
            ),
            SizedBox(height: isTablet ? 32 : 24),

            // Title
            Text(
              'Belum Ada Riwayat Poin',
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 16 : 12),

            // Description
            Text(
              'Anda belum memiliki transaksi poin.\nMulai kumpulkan poin dengan booking parkir!',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 32 : 24),

            // Info cards
            _buildInfoCard(
              icon: Icons.local_parking,
              title: 'Booking Parkir',
              description: 'Dapatkan 1 poin per Rp1.000 pembayaran',
              isTablet: isTablet,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.redeem,
              title: 'Tukar Poin',
              description: '1 poin = Rp100 diskon (maks 30%)',
              isTablet: isTablet,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.refresh,
              title: 'Refund Otomatis',
              description: 'Poin dikembalikan jika booking dibatalkan',
              isTablet: isTablet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isTablet,
  }) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 14 : 12),
            decoration: BoxDecoration(
              color: const Color(0xFF573ED1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: isTablet ? 26 : 24,
              color: const Color(0xFF573ED1),
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
