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
    return Scaffold(
      backgroundColor: Colors.white,
      body: const ProfilePageShimmer(),
      bottomNavigationBar: CurvedNavigationBar(
        index: 3,
        onTap: (index) => NavigationUtils.handleNavigation(context, index, 3),
      ),
    );
  }

  Widget _buildErrorState(ProfileProvider provider) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      backgroundColor: Colors.white,
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
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF7C5ED1),
                      Color(0xFF573ED1),
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
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
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
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      const Center(
                                        child: Icon(
                                          Icons.notifications,
                                          color: Colors.white,
                                          size: 28,
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
                          fallbackIconSize: 32,
                          fallbackIconColor: Colors.white,
                          backgroundColor: Colors.white.withOpacity(0.3),
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
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              Semantics(
                                label: 'Email: ${user?.email ?? 'email@example.com'}',
                                child: Text(
                                  user?.email ?? 'email@example.com',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      vehicles.isEmpty
                          ? Semantics(
                              label: 'Daftar kendaraan kosong',
                              child: Container(
                                height: 200,
                                padding: const EdgeInsets.all(16),
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
                      const SizedBox(height: 24),

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
          Semantics(
            header: true,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
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
        splashColor: const Color(0xFF573ED1).withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Semantics(
                label: 'Ikon $title',
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF573ED1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF573ED1),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
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
                  color: Colors.grey.shade400,
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
        splashColor: Colors.red.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Semantics(
                label: 'Ikon keluar',
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.logout,
                    color: Colors.red[600],
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Keluar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.red[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Keluar dari akun Anda',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
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
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: const Text(
              'Apakah Anda yakin ingin keluar dari akun Anda? '
              'Anda perlu login kembali untuk mengakses aplikasi.',
              style: TextStyle(
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
                      color: Colors.red[600],
                      fontWeight: FontWeight.bold,
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
          ),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}