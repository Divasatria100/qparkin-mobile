import 'package:flutter/material.dart';
import '/config/app_theme.dart';
import 'login_screen.dart';

/// Onboarding page with consistent visual design across all slides
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              AppTheme.primaryPurple.withOpacity(0.03),
              AppTheme.primaryPurple.withOpacity(0.06),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with logo and skip
              _buildHeader(theme),

              // PageView with slides
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  physics: const BouncingScrollPhysics(),
                  children: const [
                    OnboardingSlide(
                      title: 'Temukan Parkir\nDengan Mudah',
                      description:
                          'Cari lokasi parkir terdekat dan lihat ketersediaan slot secara real-time di peta interaktif.',
                      illustrationWidget: ParkingMapIllustration(),
                    ),
                    OnboardingSlide(
                      title: 'Pembayaran\nTanpa Ribet',
                      description:
                          'Bayar parkir secara digital tanpa perlu uang tunai. Aman, cepat, dan praktis.',
                      illustrationWidget: DigitalPaymentIllustration(),
                    ),
                    OnboardingSlide(
                      title: 'Keluar Parkir\nTanpa Antri',
                      description:
                          'Scan QR code untuk keluar. Tidak perlu antri di kasir, hemat waktu Anda.',
                      illustrationWidget: QRExitIllustration(),
                    ),
                  ],
                ),
              ),

              // Footer with indicators and button
              _buildFooter(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // QParkin logo
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryPurple,
                      AppTheme.brandIndigo,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_parking,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'QParkin',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryPurple,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          // Skip button
          if (_currentPage < 2)
            TextButton(
              onPressed: _navigateToLogin,
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                foregroundColor: AppTheme.primaryPurple,
              ),
              child: const Text(
                'Lewati',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) {
                final isActive = _currentPage == index;
                return AnimatedContainer(
                  key: ValueKey('indicator_$index'),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? const LinearGradient(
                            colors: [
                              AppTheme.primaryPurple,
                              AppTheme.brandIndigo,
                            ],
                          )
                        : null,
                    color: isActive ? null : AppTheme.primaryPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          // Action button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                shadowColor: AppTheme.primaryPurple.withOpacity(0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentPage == 2 ? 'Mulai Sekarang' : 'Lanjutkan',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _currentPage == 2
                        ? Icons.arrow_forward_rounded
                        : Icons.arrow_forward_ios_rounded,
                    size: _currentPage == 2 ? 22 : 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual onboarding slide with cohesive design
class OnboardingSlide extends StatelessWidget {
  final String title;
  final String description;
  final Widget illustrationWidget;

  const OnboardingSlide({
    super.key,
    required this.title,
    required this.description,
    required this.illustrationWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 1),

          // Unified illustration
          SizedBox(
            height: screenSize.height * 0.35,
            child: illustrationWidget,
          ),

          const Spacer(flex: 1),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryPurple,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 20),

          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              color: Colors.black.withOpacity(0.6),
              height: 1.6,
              letterSpacing: 0.1,
            ),
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

/// Simplified illustration: Finding parking location (consistent with Slide 2)
class ParkingMapIllustration extends StatelessWidget {
  const ParkingMapIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 320,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPurple.withOpacity(0.1),
            AppTheme.brandIndigo.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Location pin icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryPurple,
                  AppTheme.brandIndigo,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          // Simple indicator bars
          ...List.generate(3, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
              height: 12,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.2 - (index * 0.05)),
                borderRadius: BorderRadius.circular(6),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Unified illustration: Digital payment (reference design - simplified)
class DigitalPaymentIllustration extends StatelessWidget {
  const DigitalPaymentIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 320,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPurple.withOpacity(0.1),
            AppTheme.brandIndigo.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Payment icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryPurple,
                  AppTheme.brandIndigo,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.credit_card,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          // Payment bars
          ...List.generate(3, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
              height: 12,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.2 - (index * 0.05)),
                borderRadius: BorderRadius.circular(6),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Simplified illustration: QR scan exit (consistent with Slide 2)
class QRExitIllustration extends StatelessWidget {
  const QRExitIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 320,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPurple.withOpacity(0.1),
            AppTheme.brandIndigo.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // QR scan icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryPurple,
                  AppTheme.brandIndigo,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.qr_code_scanner,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          // Simple indicator bars
          ...List.generate(3, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
              height: 12,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.2 - (index * 0.05)),
                borderRadius: BorderRadius.circular(6),
              ),
            );
          }),
        ],
      ),
    );
  }
}
