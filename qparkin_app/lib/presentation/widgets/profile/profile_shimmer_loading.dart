import 'package:flutter/material.dart';

/// Shimmer loading component for the profile page
/// Provides consistent loading placeholders while data is being fetched
class ProfilePageShimmer extends StatefulWidget {
  const ProfilePageShimmer({super.key});

  @override
  State<ProfilePageShimmer> createState() => _ProfilePageShimmerState();
}

class _ProfilePageShimmerState extends State<ProfilePageShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header shimmer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 100),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF42CBF8),
                      Color(0xFF573ED1),
                      Color(0xFF39108A),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerBox(
                      width: 80,
                      height: 22,
                      borderRadius: 4,
                    ),
                    const SizedBox(height: 20),
                    const UserInfoShimmer(),
                  ],
                ),
              ),

              // Content shimmer
              Transform.translate(
                offset: const Offset(0, -70),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vehicle section title
                      _buildShimmerBox(
                        width: 180,
                        height: 17,
                        borderRadius: 4,
                      ),
                      const SizedBox(height: 12),

                      // Vehicle card shimmer
                      const VehicleCardShimmer(),
                      const SizedBox(height: 25),

                      // Account section shimmer
                      _buildSectionShimmer(),
                      const SizedBox(height: 16),

                      // Other section shimmer
                      _buildSectionShimmer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionShimmer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _buildShimmerBox(
              width: 100,
              height: 16,
              borderRadius: 4,
            ),
          ),
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  _buildShimmerBox(
                    width: 36,
                    height: 36,
                    borderRadius: 8,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildShimmerBox(
                          width: double.infinity,
                          height: 14,
                          borderRadius: 4,
                        ),
                        const SizedBox(height: 4),
                        _buildShimmerBox(
                          width: 200,
                          height: 12,
                          borderRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildShimmerBox(
                    width: 20,
                    height: 20,
                    borderRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    required double borderRadius,
  }) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.5),
                Colors.white.withOpacity(0.3),
              ],
              stops: [
                _shimmerController.value - 0.3,
                _shimmerController.value,
                _shimmerController.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Shimmer loading component for vehicle cards
class VehicleCardShimmer extends StatefulWidget {
  const VehicleCardShimmer({super.key});

  @override
  State<VehicleCardShimmer> createState() => _VehicleCardShimmerState();
}

class _VehicleCardShimmerState extends State<VehicleCardShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildShimmerBox(
            width: 72,
            height: 72,
            borderRadius: 12,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildShimmerBox(
                  width: double.infinity,
                  height: 16,
                  borderRadius: 4,
                ),
                const SizedBox(height: 8),
                _buildShimmerBox(
                  width: 100,
                  height: 13,
                  borderRadius: 4,
                ),
                const SizedBox(height: 8),
                _buildShimmerBox(
                  width: 120,
                  height: 14,
                  borderRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    required double borderRadius,
  }) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFE0E0E0),
                Color(0xFFF5F5F5),
                Color(0xFFE0E0E0),
              ],
              stops: [
                _shimmerController.value - 0.3,
                _shimmerController.value,
                _shimmerController.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Shimmer loading component for user info section
class UserInfoShimmer extends StatefulWidget {
  const UserInfoShimmer({super.key});

  @override
  State<UserInfoShimmer> createState() => _UserInfoShimmerState();
}

class _UserInfoShimmerState extends State<UserInfoShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildShimmerBox(
          width: 56,
          height: 56,
          borderRadius: 28,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerBox(
              width: 150,
              height: 17,
              borderRadius: 4,
            ),
            const SizedBox(height: 6),
            _buildShimmerBox(
              width: 200,
              height: 14,
              borderRadius: 4,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    required double borderRadius,
  }) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.5),
                Colors.white.withOpacity(0.3),
              ],
              stops: [
                _shimmerController.value - 0.3,
                _shimmerController.value,
                _shimmerController.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}
