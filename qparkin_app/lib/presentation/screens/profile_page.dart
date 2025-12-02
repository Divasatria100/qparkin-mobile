import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';
import 'list_kendaraan.dart';
import 'vehicle_detail_page.dart';
import 'edit_profile_page.dart';
import 'welcome_screen.dart';
import '../widgets/bottom_nav.dart';
import '/utils/navigation_utils.dart';
import '/utils/page_transitions.dart';
import '../../logic/providers/profile_provider.dart';
import '../../logic/providers/notification_provider.dart';
import '../widgets/profile/profile_shimmer_loading.dart';
import '../widgets/common/empty_state_widget.dart';
import '../widgets/common/notification_badge.dart';
import '../widgets/common/cached_profile_image.dart';
import '../widgets/profile/vehicle_card.dart';
import '../widgets/premium_points_card.dart';
import '../../pages/point_screen.dart';
import '../../pages/notification_screen.dart';
import '../../data/services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _previousLoadingState = false;
  bool _previousErrorState = false;

  @override
  void initState() {
    super.initState();
    // Fetch user data and vehicles when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProfileProvider>();
      provider.fetchUserData();
      provider.fetchVehicles();
      
      // Fetch unread notification count
      final notificationProvider = context.read<NotificationProvider>();
      notificationProvider.fetchUnreadCount();
      
      // Announce loading state
      _announceToScreenReader('Memuat data profil');
    });
  }

  /// Announce message to screen readers
  void _announceToScreenReader(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        // Detect and announce state changes
        _handleStateChangeAnnouncements(provider);

        // Handle loading state
        if (provider.isLoading) {
          return _buildLoadingState();
        }

        // Handle error state
        if (provider.hasError) {
          return _buildErrorState(provider);
        }

        // Handle success state
        return _buildSuccessState(provider);
      },
    );
  }

  /// Handle state change announcements for screen readers
  void _handleStateChangeAnnouncements(ProfileProvider provider) {
    // Announce loading state changes
    if (provider.isLoading && !_previousLoadingState) {
      _announceToScreenReader('Memuat data profil');
    }

    // Announce when loading completes successfully
    if (!provider.isLoading && _previousLoadingState && !provider.hasError) {
      _announceToScreenReader('Data profil berhasil dimuat');
    }

    // Announce error state changes
    if (provider.hasError && !_previousErrorState) {
      final errorMsg = provider.errorMessage ?? 'Terjadi kesalahan';
      _announceToScreenReader('Error: $errorMsg');
    }

    // Announce when error is cleared
    if (!provider.hasError && _previousErrorState) {
      _announceToScreenReader('Error telah diperbaiki');
    }

    // Update previous states
    _previousLoadingState = provider.isLoading;
    _previousErrorState = provider.hasError;
  }

  Widget _buildLoadingState() {
    return const ProfilePageShimmer();
  }

  Widget _buildErrorState(ProfileProvider provider) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Semantics(
          label: 'Halaman profil dalam keadaan error',
          child: EmptyStateWidget(
            icon: Icons.error_outline,
            title: 'Terjadi Kesalahan',
            description: provider.errorMessage ?? 'Gagal memuat data profil. Silakan coba lagi.',
            actionText: 'Coba Lagi',
            iconColor: Colors.red[400],
            onAction: () {
              provider.clearError();
              provider.fetchUserData();
              provider.fetchVehicles();
            },
          ),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: 3,
        onTap: (index) => NavigationUtils.handleNavigation(context, index, 3),
      ),
    );
  }

  Widget _buildSuccessState(ProfileProvider provider) {
    final user = provider.user;
    final vehicles = provider.vehicles;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF573ED1),
          onRefresh: () async {
            // Announce refresh start
            if (mounted) {
              _announceToScreenReader('Memperbarui data profil');
            }
            
            try {
              await provider.refreshAll();
              
              if (!mounted) return;
              
              if (provider.hasError) {
                // Announce refresh failure
                _announceToScreenReader('Gagal memperbarui data profil');
                
                // Show error snackbar if refresh fails
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      provider.errorMessage ?? 'Gagal memperbarui data',
                      style: const TextStyle(fontFamily: 'Nunito'),
                    ),
                    backgroundColor: Colors.red[400],
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                  ),
                );
              } else {
                // Announce refresh success
                _announceToScreenReader('Data profil berhasil diperbarui');
                
                // Show success snackbar if refresh succeeds
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Data berhasil diperbarui',
                      style: TextStyle(fontFamily: 'Nunito'),
                    ),
                    backgroundColor: Color(0xFF4CAF50),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              if (!mounted) return;
              
              // Announce unexpected error
              _announceToScreenReader('Terjadi kesalahan saat memperbarui data');
              
              // Handle any unexpected errors
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Terjadi kesalahan saat memperbarui data',
                    style: TextStyle(fontFamily: 'Nunito'),
                  ),
                  backgroundColor: Colors.red[400],
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // 🔷 Header dengan gradient
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Profile",
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        // Notification icon with badge
                        Consumer<NotificationProvider>(
                          builder: (context, notificationProvider, child) {
                            return Semantics(
                              button: true,
                              label: notificationProvider.hasUnread
                                  ? 'Notifikasi, ${notificationProvider.unreadCount} notifikasi belum dibaca'
                                  : 'Notifikasi, tidak ada notifikasi baru',
                              hint: 'Ketuk untuk membuka halaman notifikasi',
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    PageTransitions.slideFromRight(
                                      page: const NotificationScreen(),
                                    ),
                                  ).then((_) {
                                    // Mark notifications as read when returning from notification screen
                                    notificationProvider.markAllAsRead();
                                  });
                                },
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Stack(
                                    children: [
                                      const Center(
                                        child: Icon(
                                          Icons.notifications_outlined,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      if (notificationProvider.hasUnread)
                                        Positioned(
                                          right: 8,
                                          top: 8,
                                          child: NotificationBadge(
                                            count: notificationProvider.unreadCount,
                                            size: 18,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        CachedProfileImage(
                          imageUrl: user?.photoUrl,
                          size: 56,
                          semanticLabel: 'Foto profil ${user?.name ?? 'pengguna'}',
                          fallbackIcon: Icons.person,
                          fallbackIconSize: 30,
                          fallbackIconColor: Colors.black,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Semantics(
                          label: 'Informasi pengguna',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Semantics(
                                label: 'Nama pengguna: ${user?.name ?? 'Pengguna'}',
                                child: Text(
                                  user?.name ?? 'Pengguna',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Semantics(
                                label: 'Email: ${user?.email ?? 'email@example.com'}',
                                child: Text(
                                  user?.email ?? 'email@example.com',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Premium Points Card
                    Semantics(
                      label: 'Kartu poin, saldo poin Anda: ${user?.saldoPoin ?? 0} poin',
                      button: true,
                      hint: 'Ketuk untuk melihat riwayat poin',
                      child: PremiumPointsCard(
                        points: user?.saldoPoin ?? 0,
                        variant: PointsCardVariant.purple,
                        onTap: () {
                          Navigator.of(context).push(
                            PageTransitions.slideFromRight(
                              page: const PointScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // 🔹 Konten utama
              Transform.translate(
                offset: const Offset(0, -70),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    children: [
                      // Section: Informasi Kendaraan
                      Semantics(
                        header: true,
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Informasi Kendaraan",
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color.fromARGB(255, 250, 245, 245),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      vehicles.isEmpty
                          ? Semantics(
                              label: 'Daftar kendaraan kosong',
                              child: Container(
                                height: 200,
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: EmptyStateWidget(
                                  icon: Icons.directions_car_outlined,
                                  title: 'Tidak ada kendaraan terdaftar',
                                  description: 'Anda belum memiliki kendaraan terdaftar. Tambahkan kendaraan untuk memulai parkir.',
                                  actionText: 'Tambah Kendaraan',
                                  onAction: () {
                                    Navigator.of(context).push(
                                      PageTransitions.slideFromRight(
                                        page: const VehicleListPage(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          : Semantics(
                              label: 'Daftar kendaraan terdaftar, ${vehicles.length} kendaraan',
                              child: SizedBox(
                                height: 120,
                                child: PageView.builder(
                                  controller:
                                      PageController(viewportFraction: 0.9),
                                  itemCount: vehicles.length,
                                  itemBuilder: (context, index) {
                                    final vehicle = vehicles[index];
                                    return Semantics(
                                      label: 'Kendaraan ${index + 1} dari ${vehicles.length}',
                                      hint: 'Geser untuk melihat kendaraan lain, ketuk untuk detail',
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 12),
                                        child: VehicleCard(
                                          vehicle: vehicle,
                                          isActive: vehicle.isActive,
                                          onTap: () {
                                            Navigator.of(context).push(
                                              PageTransitions.slideFromRight(
                                                page: VehicleDetailPage(
                                                  vehicle: vehicle,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                      const SizedBox(height: 20),

                      // Section Akun
                      Semantics(
                        label: 'Bagian menu akun',
                        child: _sectionCard(
                          context,
                          title: "Akun",
                          items: [
                            _menuItem(
                              context,
                              Icons.edit,
                              "Ubah informasi akun",
                              "Ganti nama, pin, dan e-mail ...",
                              () async {
                                // Navigate to edit profile page with slide transition
                                final navigator = Navigator.of(context);
                                final result = await navigator.push(
                                  PageTransitions.slideFromRight(
                                    page: const EditProfilePage(),
                                  ),
                                );
                                
                                // Refresh profile data after returning from edit page
                                if (!mounted) return;
                                
                                if (result != null) {
                                  final provider = context.read<ProfileProvider>();
                                  _announceToScreenReader('Memuat ulang data profil');
                                  await provider.fetchUserData();
                                }
                              },
                            ),
                            _menuItem(
                              context,
                              Icons.directions_car,
                              "List Kendaraan",
                              "Kamu dapat menambahkan kendaraan ...",
                              () {
                                final navigator = Navigator.of(context);
                                navigator.push(
                                  PageTransitions.slideFromRight(
                                    page: const VehicleListPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Section Lainnya
                      Semantics(
                        label: 'Bagian menu lainnya',
                        child: _sectionCard(
                          context,
                          title: "Lainnya",
                          items: [
                            _menuItem(
                              context,
                              Icons.help_outline,
                              "Bantuan",
                              "Kamu dapat mengganti metode pembayaran ...",
                              null,
                            ),
                            _menuItem(
                              context,
                              Icons.privacy_tip,
                              "Kebijakan Privasi",
                              "Pelajari kebijakan privasi pengguna aplikasi",
                              null,
                            ),
                            _menuItem(
                              context,
                              Icons.info_outline,
                              "Tentang Aplikasi",
                              "Versi 3.6.2",
                              null,
                            ),
                            _logoutMenuItem(context),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
          ),
        ),
      bottomNavigationBar: Semantics(
        label: 'Navigasi bawah, halaman profil aktif',
        child: CurvedNavigationBar(
          index: 3,
          onTap: (index) => NavigationUtils.handleNavigation(context, index, 3),
        ),
      ),
    );
  }

  Widget _sectionCard(BuildContext context,
      {required String title, required List<Widget> items}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title,
      String subtitle, VoidCallback? onTap) {
    return Semantics(
      button: true,
      label: '$title, $subtitle',
      hint: onTap != null ? 'Ketuk untuk membuka $title' : 'Tidak tersedia',
      enabled: onTap != null,
      child: InkWell(
        onTap: onTap ?? () {},
        splashColor: Colors.blue.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Semantics(
                label: 'Ikon $title',
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.grey[500]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF969696),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Semantics(
                label: 'Ikon panah kanan',
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Logout menu item with red color to indicate destructive action
  Widget _logoutMenuItem(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Keluar, Keluar dari akun Anda',
      hint: 'Ketuk untuk keluar dari akun',
      child: InkWell(
        onTap: () => _showLogoutConfirmationDialog(context),
        splashColor: Colors.red.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Semantics(
                label: 'Ikon keluar',
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.logout,
                    color: Colors.red[600],
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Keluar',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.red[600],
                      ),
                    ),
                    const Text(
                      'Keluar dari akun Anda',
                      style: TextStyle(
                        color: Color(0xFF969696),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Semantics(
                label: 'Ikon panah kanan',
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.red[300],
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show logout confirmation dialog
  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Semantics(
          label: 'Dialog konfirmasi keluar',
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange[700],
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Konfirmasi Keluar',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: const Text(
              'Apakah Anda yakin ingin keluar dari akun Anda? '
              'Anda perlu login kembali untuk mengakses aplikasi.',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                height: 1.5,
              ),
            ),
            actions: [
              Semantics(
                button: true,
                label: 'Tombol batal',
                hint: 'Ketuk untuk membatalkan keluar',
                child: TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      color: Color(0xFF8E8E93),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Semantics(
                button: true,
                label: 'Tombol keluar',
                hint: 'Ketuk untuk keluar dari akun',
                child: TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Keluar',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      color: Colors.red[600],
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    // If user confirmed logout
    if (confirmed == true && context.mounted) {
      await _performLogout(context);
    }
  }

  /// Perform logout operation
  Future<void> _performLogout(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF573ED1)),
            ),
          );
        },
      );

      // Clear authentication data
      final authService = AuthService();
      await authService.logout();

      if (!mounted) return;

      // Clear provider data
      final provider = context.read<ProfileProvider>();
      provider.clearError();

      // Announce logout to screen reader
      _announceToScreenReader('Berhasil keluar dari akun');

      // Close loading dialog and navigate
      final navigator = Navigator.of(context);
      navigator.pop(); // Close loading dialog
      
      // Navigate to welcome screen and clear navigation stack
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const WelcomeScreen(),
        ),
        (route) => false, // Remove all routes from stack
      );
    } catch (e) {
      if (!mounted) return;
      
      // Announce error to screen reader
      _announceToScreenReader('Gagal keluar dari akun');

      // Close loading dialog and show error
      Navigator.of(context).pop(); // Close loading dialog
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal keluar: ${e.toString()}',
            style: const TextStyle(fontFamily: 'Nunito'),
          ),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}