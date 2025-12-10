import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../utils/responsive_helper.dart';

/// A card widget displaying the user's current point balance
/// Shows balance with star icon as focal point, with loading and error states
/// Optimized with RepaintBoundary to isolate repaints
class PointBalanceCard extends StatelessWidget {
  final int? balance;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;

  const PointBalanceCard({
    Key? key,
    this.balance,
    this.isLoading = false,
    this.error,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = ResponsiveHelper.getBorderRadius(context);
    final padding = ResponsiveHelper.getCardPadding(context);

    return Semantics(
      label: _getSemanticLabel(),
      child: RepaintBoundary(
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.heroGradient,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: AppTheme.brandIndigo.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: padding,
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState(context);
    }

    if (error != null) {
      return _buildErrorState(context);
    }

    return _buildBalanceDisplay(context);
  }

  Widget _buildLoadingState(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        // Shimmer effect for icon
        _ShimmerBox(
          width: 80,
          height: 80,
          borderRadius: 40,
        ),
        const SizedBox(height: 16),
        // Shimmer effect for text
        _ShimmerBox(
          width: 120,
          height: 24,
        ),
        const SizedBox(height: 8),
        _ShimmerBox(
          width: 180,
          height: 40,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final bodyFontSize = ResponsiveHelper.getResponsiveFontSize(context, 14);
    
    return ExcludeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          // Error icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          // Error message
          Text(
            error ?? 'Gagal memuat saldo',
            style: TextStyle(
              fontSize: bodyFontSize,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Retry button with minimum 48x48dp touch target
          if (onRetry != null)
            Semantics(
              label: 'Tombol coba lagi',
              button: true,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: onRetry,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.refresh,
                          size: 20,
                          color: AppTheme.brandIndigo,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Coba Lagi',
                          style: TextStyle(
                            fontSize: bodyFontSize,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.brandIndigo,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBalanceDisplay(BuildContext context) {
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(context, 16);
    final balanceFontSize = ResponsiveHelper.getResponsiveFontSize(context, 36);
    final iconSize = ResponsiveHelper.getIconSize(context, 80);

    return ExcludeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          // Star/coin icon as focal point
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.stars,
              size: iconSize * 0.6,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 16),
          // "Saldo Poin" label
          Text(
            'Saldo Poin',
            style: TextStyle(
              fontSize: titleFontSize,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          // Balance amount
          Text(
            _formatBalance(balance ?? 0),
            style: TextStyle(
              fontSize: balanceFontSize,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _formatBalance(int balance) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(balance);
  }

  String _getSemanticLabel() {
    if (isLoading) {
      return 'Memuat saldo poin';
    }
    if (error != null) {
      return 'Error memuat saldo poin. $error. Tombol coba lagi tersedia';
    }
    return 'Saldo poin Anda. ${_formatBalance(balance ?? 0)} poin';
  }
}

/// Simple shimmer loading effect widget
class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    // Only animate if motion is not reduced
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !ResponsiveHelper.shouldReduceMotion(context)) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shouldAnimate = !ResponsiveHelper.shouldReduceMotion(context);
    
    if (!shouldAnimate) {
      // Static shimmer for reduced motion
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          color: Colors.white.withOpacity(0.2),
        ),
      );
    }
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.1),
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}
