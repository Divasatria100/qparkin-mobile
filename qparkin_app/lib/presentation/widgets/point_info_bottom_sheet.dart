import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../utils/responsive_helper.dart';

/// Bottom sheet widget that explains how the point system works
/// Displays information about earning points, using points, conversion rules, and penalties
class PointInfoBottomSheet extends StatelessWidget {
  const PointInfoBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxHeight = ResponsiveHelper.getBottomSheetMaxHeight(context);
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Cara Kerja Poin',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Tombol tutup',
                    hint: 'Ketuk untuk menutup informasi cara kerja poin',
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Tutup',
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content - Scrollable
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Introduction
                    _buildIntroSection(context),
                    const SizedBox(height: 24),

                    // How to earn points
                    _buildEarnPointsSection(context),
                    const SizedBox(height: 24),

                    // How to use points
                    _buildUsePointsSection(context),
                    const SizedBox(height: 24),

                    // Conversion rules
                    _buildConversionSection(context),
                    const SizedBox(height: 24),

                    // Penalty system
                    _buildPenaltySection(context),
                    const SizedBox(height: 24),

                    // Tips
                    _buildTipsSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.brandNavy.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.brandNavy.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.brandNavy,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.stars,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Sistem poin reward QPARKIN memungkinkan Anda mendapatkan poin dari setiap transaksi parkir dan menggunakannya untuk diskon pembayaran.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarnPointsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Row(
            children: [
              const ExcludeSemantics(
                child: Icon(
                  Icons.add_circle,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Cara Mendapatkan Poin',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          context,
          icon: Icons.local_parking,
          iconColor: Colors.blue,
          title: 'Transaksi Parkir',
          description:
              'Setiap kali Anda menyelesaikan pembayaran parkir, sistem akan otomatis menambahkan poin ke akun Anda berdasarkan total biaya parkir.',
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          context,
          icon: Icons.event_available,
          iconColor: Colors.purple,
          title: 'Booking Parkir',
          description:
              'Poin juga diberikan saat Anda melakukan booking slot parkir dan menyelesaikan transaksi dengan sukses.',
        ),
      ],
    );
  }

  Widget _buildUsePointsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Row(
            children: [
              const ExcludeSemantics(
                child: Icon(
                  Icons.payment,
                  color: AppTheme.brandNavy,
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Cara Menggunakan Poin',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          context,
          icon: Icons.discount,
          iconColor: Colors.orange,
          title: 'Diskon Pembayaran',
          description:
              'Gunakan poin Anda sebagai metode pembayaran untuk memotong biaya parkir. Pilih opsi "Gunakan Poin" saat melakukan pembayaran.',
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          context,
          icon: Icons.account_balance_wallet,
          iconColor: Colors.teal,
          title: 'Pembayaran Fleksibel',
          description:
              'Jika poin tidak mencukupi, sistem akan menggunakan semua poin yang tersedia dan menampilkan sisa biaya yang perlu dibayar dengan metode lain.',
        ),
      ],
    );
  }

  Widget _buildConversionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Row(
            children: [
              const ExcludeSemantics(
                child: Icon(
                  Icons.currency_exchange,
                  color: Colors.amber,
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Aturan Konversi Poin',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.shade50,
                Colors.orange.shade50,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.amber.shade200,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.stars,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '100 Poin',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.brandNavy,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.amber,
                      size: 24,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Rp 1.000',
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.green.shade700,
                              ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Setiap 100 poin dapat digunakan untuk mengurangi biaya parkir sebesar Rp 1.000',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black87,
                      fontStyle: FontStyle.italic,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPenaltySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Row(
            children: [
              const ExcludeSemantics(
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Sistem Penalty',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red.shade200,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Keterlambatan (Overstay)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade900,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Jika Anda melebihi waktu booking atau durasi parkir yang diizinkan, sistem akan otomatis menghitung biaya penalty tambahan yang akan ditambahkan ke total tagihan parkir Anda.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Penalty akan mengurangi poin Anda atau ditambahkan ke biaya parkir',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Row(
            children: [
              const ExcludeSemantics(
                child: Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber,
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Tips Memaksimalkan Poin',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildTipItem(
          context,
          '✓ Selalu selesaikan pembayaran parkir untuk mendapatkan poin',
        ),
        _buildTipItem(
          context,
          '✓ Gunakan poin untuk diskon pembayaran parkir berikutnya',
        ),
        _buildTipItem(
          context,
          '✓ Hindari keterlambatan untuk menghindari penalty',
        ),
        _buildTipItem(
          context,
          '✓ Cek riwayat poin secara berkala untuk memantau perolehan',
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black87,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
