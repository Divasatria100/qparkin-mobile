import 'package:flutter/material.dart';
import 'shimmer_loading.dart';

/// A card widget for displaying point balance with equivalent Rupiah value
///
/// Features:
/// - Displays current point balance
/// - Shows equivalent Rupiah value (1 poin = Rp100)
/// - Loading state with shimmer effect
/// - Error state with retry button
/// - Tap interaction for navigation
/// - Accessibility support
///
/// Example usage:
/// ```dart
/// PointBalanceCard(
///   balance: 150,
///   equivalentValue: 'Rp15.000',
///   isLoading: false,
///   onTap: () => Navigator.pushNamed(context, '/points'),
/// )
/// ```
class PointBalanceCard extends StatelessWidget {
  /// Current point balance
  final int balance;

  /// Equivalent Rupiah value (formatted string)
  final String equivalentValue;

  /// Whether the card is in loading state
  final bool isLoading;

  /// Error message to display (null if no error)
  final String? error;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when retry button is tapped (in error state)
  final VoidCallback? onRetry;

  const PointBalanceCard({
    Key? key,
    required this.balance,
    required this.equivalentValue,
    this.isLoading = false,
    this.error,
    this.onTap,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (error != null) {
      return _buildErrorState(context);
    }

    return _buildNormalState(context);
  }

  /// Build normal state with balance display
  Widget _buildNormalState(BuildContext context) {
    return Semantics(
      label: 'Saldo poin Anda: $balance poin, setara dengan $equivalentValue. Ketuk untuk melihat detail',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6B4FE0), Color(0xFF573ED1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF573ED1).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with icon and label
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.stars,
                        color: Colors.white,
                        size: 20,
                        semanticLabel: 'Ikon bintang poin',
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: ExcludeSemantics(
                        child: Text(
                          'Saldo Poin',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (onTap != null)
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 24,
                        semanticLabel: 'Panah navigasi',
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Balance display
                ExcludeSemantics(
                  child: Text(
                    '$balance Poin',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Equivalent value
                ExcludeSemantics(
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Colors.white.withOpacity(0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Setara $equivalentValue',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build loading state with shimmer effect
  Widget _buildLoadingState() {
    return Semantics(
      label: 'Memuat saldo poin',
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF573ED1).withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF573ED1).withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header shimmer
            Row(
              children: [
                ShimmerLoading(
                  width: 36,
                  height: 36,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: ShimmerLoading(
                    width: double.infinity,
                    height: 16,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Balance shimmer
            ShimmerLoading(
              width: 150,
              height: 32,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            // Equivalent value shimmer
            ShimmerLoading(
              width: 120,
              height: 14,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  /// Build error state with retry button
  Widget _buildErrorState(BuildContext context) {
    return Semantics(
      label: 'Gagal memuat saldo poin. $error. Ketuk tombol coba lagi untuk memuat ulang',
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.red.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error icon and message
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 20,
                    semanticLabel: 'Ikon error',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ExcludeSemantics(
                    child: Text(
                      'Gagal Memuat',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Error message
            ExcludeSemantics(
              child: Text(
                error ?? 'Terjadi kesalahan',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Retry button
            if (onRetry != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF573ED1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
