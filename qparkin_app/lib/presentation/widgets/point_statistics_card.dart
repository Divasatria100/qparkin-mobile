import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../data/models/point_statistics_model.dart';
import '../../utils/responsive_helper.dart';

/// A card widget displaying point statistics in a grid layout
/// Shows 4 metrics: total earned, total used, month earned, month used
/// Optimized with RepaintBoundary to isolate repaints
class PointStatisticsCard extends StatelessWidget {
  final PointStatistics? statistics;
  final bool isLoading;

  const PointStatisticsCard({
    Key? key,
    this.statistics,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = ResponsiveHelper.getBorderRadius(context);
    final padding = ResponsiveHelper.getCardPadding(context);

    return Semantics(
      label: _getSemanticLabel(),
      child: RepaintBoundary(
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                if (isLoading)
                  _buildLoadingState(context)
                else
                  _buildStatisticsGrid(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(context, 18);

    return Row(
      children: [
        Icon(
          Icons.bar_chart,
          color: AppTheme.brandIndigo,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          'Statistik Poin',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive grid dimensions based on screen size and orientation
        final crossAxisCount = ResponsiveHelper.getGridColumnCount(context, defaultColumns: 2);
        final spacing = ResponsiveHelper.getGridSpacing(context);
        final itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
        final itemHeight = itemWidth * 0.8;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: itemWidth / itemHeight,
          children: List.generate(
            4,
            (index) => _ShimmerBox(
              width: itemWidth,
              height: itemHeight,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatisticsGrid(BuildContext context) {
    if (statistics == null) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive grid dimensions based on screen size and orientation
        final crossAxisCount = ResponsiveHelper.getGridColumnCount(context, defaultColumns: 2);
        final spacing = ResponsiveHelper.getGridSpacing(context);
        final itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
        final itemHeight = itemWidth * 0.8;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: itemWidth / itemHeight,
          children: [
            _buildStatItem(
              context,
              label: 'Total Didapat',
              value: statistics!.formattedTotalEarned,
              icon: Icons.add_circle_outline,
              color: Colors.green,
              semanticLabel: 'Total poin yang didapat: ${statistics!.formattedTotalEarned}',
            ),
            _buildStatItem(
              context,
              label: 'Total Digunakan',
              value: statistics!.formattedTotalUsed,
              icon: Icons.remove_circle_outline,
              color: Colors.red,
              semanticLabel: 'Total poin yang digunakan: ${statistics!.formattedTotalUsed}',
            ),
            _buildStatItem(
              context,
              label: 'Bulan Ini Didapat',
              value: statistics!.formattedThisMonthEarned,
              icon: Icons.trending_up,
              color: Colors.blue,
              semanticLabel: 'Poin yang didapat bulan ini: ${statistics!.formattedThisMonthEarned}',
            ),
            _buildStatItem(
              context,
              label: 'Bulan Ini Digunakan',
              value: statistics!.formattedThisMonthUsed,
              icon: Icons.trending_down,
              color: Colors.orange,
              semanticLabel: 'Poin yang digunakan bulan ini: ${statistics!.formattedThisMonthUsed}',
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required String semanticLabel,
  }) {
    final labelFontSize = ResponsiveHelper.getResponsiveFontSize(context, 12);
    final valueFontSize = ResponsiveHelper.getResponsiveFontSize(context, 20);

    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: labelFontSize,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: valueFontSize,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSemanticLabel() {
    if (isLoading) {
      return 'Memuat statistik poin';
    }
    if (statistics == null) {
      return 'Statistik poin tidak tersedia';
    }
    return 'Statistik poin. Total didapat ${statistics!.formattedTotalEarned}, '
        'Total digunakan ${statistics!.formattedTotalUsed}, '
        'Bulan ini didapat ${statistics!.formattedThisMonthEarned}, '
        'Bulan ini digunakan ${statistics!.formattedThisMonthUsed}';
  }
}

/// Simple shimmer loading effect widget
class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;

  const _ShimmerBox({
    required this.width,
    required this.height,
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
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[300],
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
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
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
