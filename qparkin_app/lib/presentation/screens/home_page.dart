import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/common/animated_card.dart';
import '/utils/navigation_utils.dart';
import '/utils/vehicle_icon_helper.dart';
import '../../logic/providers/profile_provider.dart';

/// Home Page - Main landing page of QPARKIN app
///
/// Displays:
/// - User profile and location search
/// - Premium points card
/// - Nearby parking locations (max 3)
/// - Quick action buttons for main features
///
/// Design follows the QPARKIN design system with:
/// - Purple gradient header (#7C5ED1 to #573ED1)
/// - White content section with consistent spacing (8dp grid)
/// - Card-based UI with subtle shadows
/// - Micro-interactions for better UX
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State management
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // Mock data for nearby parking locations
  // TODO: Replace with actual API call to fetch real-time parking data
  final List<Map<String, dynamic>> nearbyLocations = [
    {
      'id_mall': '1',
      'name': 'Mega Mall Batam Centre',
      'nama_mall': 'Mega Mall Batam Centre',
      'distance': '1.3 km',
      'address': 'Jl. Engku Putri no.1, Batam Centre',
      'alamat': 'Jl. Engku Putri no.1, Batam Centre',
      'available': 45,
      'has_slot_reservation_enabled': true, // Slot reservation enabled
    },
    {
      'id_mall': '2',
      'name': 'One Batam Mall',
      'nama_mall': 'One Batam Mall',
      'distance': '1.5 km',
      'address': 'Jl. Raja H. Fisabilillah No. 9, Batam Center',
      'alamat': 'Jl. Raja H. Fisabilillah No. 9, Batam Center',
      'available': 32,
      'has_slot_reservation_enabled': true, // Slot reservation enabled
    },
    {
      'id_mall': '3',
      'name': 'SNL Food Bengkong',
      'nama_mall': 'SNL Food Bengkong',
      'distance': '7 km',
      'address': 'Garden Avenue Square, Bengkong, Batam',
      'alamat': 'Garden Avenue Square, Bengkong, Batam',
      'available': 18,
      'has_slot_reservation_enabled': false, // Slot reservation disabled for testing
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    // Load profile data for header
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchUserData();
      context.read<ProfileProvider>().fetchVehicles();
    });
  }

  /// Loads parking location data from API
  ///
  /// Simulates API call with 2-second delay. In production, this should
  /// fetch real-time parking availability from the backend.
  ///
  /// Handles three states:
  /// - Loading: Shows shimmer skeleton
  /// - Success: Displays parking locations
  /// - Error: Shows error message with retry button
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      // Simulate loading data from API
      await Future.delayed(const Duration(seconds: 2));

      // Simulate potential error (for testing, remove in production)
      // Uncomment the line below to test error state
      // throw Exception('Failed to load parking locations');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  /// Builds a reusable Quick Action card component (2x2 Grid Style)
  ///
  /// Creates a modern, spacious card design for quick access buttons with:
  /// - Large icon container with colored background
  /// - Clear label text with subtitle support
  /// - Enhanced touch feedback with elevation changes
  /// - Consistent with Activity Page and Map Page styling
  ///
  /// Parameters:
  /// - [icon]: The icon to display (IconData)
  /// - [label]: Primary text label
  /// - [color]: Accent color for icon and effects
  /// - [onTap]: Callback when card is tapped
  /// - [useFontAwesome]: Whether to use FontAwesome icon (default: false)
  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
    bool useFontAwesome = false,
  }) {
    return Semantics(
      button: true,
      label: label,
      hint: 'Ketuk untuk membuka $label',
      child: AnimatedCard(
        onTap: onTap,
        borderRadius: 16,
        child: Container(
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
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon container with colored background
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: useFontAwesome
                      ? FaIcon(icon, color: color, size: 28)
                      : Icon(icon, color: color, size: 28),
                ),
              ),
              const SizedBox(height: 12),
              // Label text
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the empty state UI when no parking locations are available
  ///
  /// Displays:
  /// - Location off icon (48px, grey)
  /// - "Tidak ada lokasi parkir tersedia" message
  /// - Helpful suggestion text
  Widget _buildEmptyState() {
    return Semantics(
      label: 'Tidak ada lokasi parkir tersedia',
      hint: 'Coba lagi nanti atau cari di lokasi lain',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Semantics(
                label: 'Ikon tidak ada lokasi',
                child: Icon(
                  Icons.location_off,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tidak ada lokasi parkir tersedia',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Coba lagi nanti atau cari di lokasi lain',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the error state UI when data loading fails
  ///
  /// Displays:
  /// - Error icon (48px, red)
  /// - "Terjadi Kesalahan" title
  /// - Error message from exception
  /// - "Coba Lagi" button to retry loading
  Widget _buildErrorState() {
    return Semantics(
      label: 'Terjadi kesalahan',
      hint: _errorMessage.isNotEmpty
          ? _errorMessage
          : 'Gagal memuat data lokasi parkir',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Semantics(
                label: 'Ikon kesalahan',
                child: const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Color(0xFFF44336),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Terjadi Kesalahan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage.isNotEmpty
                    ? _errorMessage
                    : 'Gagal memuat data lokasi parkir',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Semantics(
                button: true,
                label: 'Coba lagi',
                hint: 'Ketuk untuk memuat ulang data lokasi parkir',
                child: ElevatedButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF573ED1),
                    foregroundColor: Colors.white,
                    // Minimum touch target: 48dp height
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Quick Actions configuration
    // Each action has an icon, label, color, and navigation handler
    final List<Widget> quickActions = [
      _buildQuickActionCard(
        icon: FontAwesomeIcons.squareParking,
        label: 'Booking',
        color: const Color(0xFF573ED1),
        useFontAwesome: true,
        onTap: () {
          // TODO: Navigate to booking page
        },
      ),
      _buildQuickActionCard(
        icon: FontAwesomeIcons.mapLocationDot,
        label: 'Peta',
        color: const Color(0xFF3B82F6),
        useFontAwesome: true,
        onTap: () {
          Navigator.pushNamed(context, '/map');
        },
      ),
      _buildQuickActionCard(
        icon: Icons.star,
        label: 'Tukar Poin',
        color: const Color(0xFFFFA726),
        onTap: () {
          // TODO: Navigate to points exchange page
        },
      ),
      _buildQuickActionCard(
        icon: Icons.history,
        label: 'Riwayat',
        color: const Color(0xFF4CAF50),
        onTap: () {
          Navigator.pushNamed(context, '/activity',
              arguments: {'initialTab': 1});
        },
      ),
    ];
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==================== HEADER SECTION ====================
            // Purple gradient header with user profile, points card, and search
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF7C5ED1), // Lighter purple
                    Color(0xFF573ED1), // Original purple
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20), // Consistent 16dp horizontal padding
                  child: Consumer<ProfileProvider>(
                    builder: (context, profileProvider, child) {
                      final user = profileProvider.user;
                      final vehicles = profileProvider.vehicles;
                      final isProfileIncomplete = 
                        user?.phoneNumber == null || 
                        user?.phoneNumber?.isEmpty == true ||
                        vehicles.isEmpty;

                      return Column(
                        children: [
                          // Top Row: Profile Avatar + Location + Notification
                          Row(
                            children: [
                              // Profile Avatar with Badge
                              Semantics(
                                button: true,
                                label: 'Profil pengguna',
                                hint: 'Ketuk untuk membuka halaman profil',
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/profile');
                                  },
                                  borderRadius: BorderRadius.circular(24),
                                  child: Stack(
                                    children: [
                                      Container(
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
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(24),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                            child: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                                              ? CircleAvatar(
                                                  radius: 24,
                                                  backgroundImage: NetworkImage(user.photoUrl!),
                                                  backgroundColor: Colors.transparent,
                                                  onBackgroundImageError: (_, __) {},
                                                  child: Container(), // Fallback handled by backgroundColor
                                                )
                                              : const Center(
                                                  child: Icon(
                                                    Icons.person,
                                                    color: Colors.white,
                                                    size: 28,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ),
                                      // Badge indicator for incomplete profile
                                      if (isProfileIncomplete)
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF44336),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: const Color(0xFF573ED1),
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Location Input
                              Expanded(
                                child: Semantics(
                                  label: 'Lokasi saat ini',
                                  hint: 'Ketuk untuk mengubah lokasi',
                                  textField: true,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 10, sigmaY: 10),
                                        child: TextField(
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            hintText: 'Lokasi saat ini',
                                            hintStyle: const TextStyle(
                                                color: Colors.white),
                                            prefixIcon: const Icon(
                                              Icons.location_on,
                                              color: Colors.white,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 16,
                                            ),
                                            filled: true,
                                            fillColor: Colors.transparent,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Notification Icon
                              Semantics(
                                button: true,
                                label: 'Notifikasi',
                                hint: 'Ketuk untuk melihat notifikasi',
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/notifikasi');
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
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: BackdropFilter(
                                        filter:
                                            ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                        child: const Center(
                                          child: Icon(
                                            Icons.notifications,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16), // 16dp spacing after Top Row
                          
                          // Welcome Text
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Selamat Datang Kembali!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8), // 8dp spacing after Welcome Text
                          
                          // Sub-Header: Vehicle Info + Points Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left: Active Vehicle Info
                              Expanded(
                                child: Semantics(
                                  button: true,
                                  label: vehicles.isNotEmpty 
                                    ? 'Kendaraan aktif: ${vehicles.firstWhere((v) => v.isActive, orElse: () => vehicles.first).merk} ${vehicles.firstWhere((v) => v.isActive, orElse: () => vehicles.first).tipe} - ${vehicles.firstWhere((v) => v.isActive, orElse: () => vehicles.first).platNomor}'
                                    : 'Belum ada kendaraan terdaftar',
                                  hint: 'Ketuk untuk melihat daftar kendaraan',
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/list-kendaraan');
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            vehicles.isNotEmpty
                                                ? VehicleIconHelper.getIcon(
                                                    vehicles.firstWhere((v) => v.isActive, orElse: () => vehicles.first).jenisKendaraan
                                                  )
                                                : Icons.directions_car,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              vehicles.isNotEmpty
                                                ? '${vehicles.firstWhere((v) => v.isActive, orElse: () => vehicles.first).merk} ${vehicles.firstWhere((v) => v.isActive, orElse: () => vehicles.first).tipe} - ${vehicles.firstWhere((v) => v.isActive, orElse: () => vehicles.first).platNomor}'
                                                : 'Tambah Kendaraan',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.white.withOpacity(0.7),
                                            size: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              // Right: Points Badge
                              Semantics(
                                button: true,
                                label: 'Poin Anda: ${user?.saldoPoin ?? 0} poin',
                                hint: 'Ketuk untuk melihat detail poin',
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/profile');
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFFA726),
                                          Color(0xFFFF9800),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFFA726).withOpacity(0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.stars,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${user?.saldoPoin ?? 0}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Search Field
                          Semantics(
                            textField: true,
                            label: 'Cari lokasi parkir',
                            hint:
                                'Ketik untuk mencari lokasi parkir, mal, atau jalan',
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText:
                                      'Cari lokasi parkir, mal, atau jalan...',
                                  hintStyle: const TextStyle(color: Colors.grey),
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            // ==================== CONTENT SECTION ====================
            // White background with nearby locations and quick actions
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  MediaQuery.of(context).size.height * 0.12 + 20,
                ),
                child: Column(
                  children: [
                    // Nearby Locations Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Semantics(
                          header: true,
                          child: const Text(
                            'Lokasi Parkir Terdekat',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Semantics(
                          button: true,
                          label: 'Lihat semua lokasi parkir',
                          hint:
                              'Ketuk untuk melihat semua lokasi parkir di peta',
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/map').then((_) {
                                // Reset to home index when returning from map
                                setState(() {});
                              });
                            },
                            child: const Text(
                              'Lihat Semua',
                              style: TextStyle(
                                color: Color(0xFF573ED1),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Nearby Locations List - Shows max 3 locations
                    // Handles three states: loading (shimmer), error, empty, success
                    _isLoading
                        ? const HomePageLocationShimmer()
                        : _hasError
                            ? _buildErrorState()
                            : nearbyLocations.isEmpty
                                ? _buildEmptyState()
                                : Column(
                                    children: nearbyLocations
                                        .take(3)
                                        .map((location) => Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 12),
                                              child: Semantics(
                                                button: true,
                                                label:
                                                    '${location['name']}, jarak ${location['distance']}, ${location['available']} slot tersedia',
                                                hint:
                                                    'Ketuk untuk melihat detail lokasi parkir di peta',
                                                child: AnimatedCard(
                                                  onTap: () {
                                                    Navigator.pushNamed(
                                                        context, '/map');
                                                  },
                                                  borderRadius: 16,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      border: Border.all(
                                                        color: Colors
                                                            .grey.shade200,
                                                        width: 1,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                  0.05),
                                                          blurRadius: 8,
                                                          offset: const Offset(
                                                              0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // Icon Container - 44x44px with purple background
                                                        Semantics(
                                                          label:
                                                              'Ikon lokasi parkir',
                                                          child: Container(
                                                            width: 44,
                                                            height: 44,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                  0xFF573ED1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                            ),
                                                            child: const Center(
                                                              child: FaIcon(
                                                                FontAwesomeIcons
                                                                    .bagShopping,
                                                                color: Colors
                                                                    .white,
                                                                size: 20,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 16),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              // Name + Distance Badge
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                      location[
                                                                          'name'],
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 8),
                                                                  // Distance Badge
                                                                  Semantics(
                                                                    label:
                                                                        'Jarak ${location['distance']}',
                                                                    child:
                                                                        Container(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            4,
                                                                      ),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade100,
                                                                        borderRadius:
                                                                            BorderRadius.circular(8),
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        location[
                                                                            'distance'],
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                  height: 8),
                                                              // Address - max 2 lines
                                                              Semantics(
                                                                label:
                                                                    'Alamat: ${location['address']}',
                                                                child: Text(
                                                                  location[
                                                                      'address'],
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .grey
                                                                        .shade600,
                                                                  ),
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 8),
                                                              // Available Slots Badge + Arrow
                                                              Row(
                                                                children: [
                                                                  // Available Slots Badge
                                                                  Flexible(
                                                                    child:
                                                                        Semantics(
                                                                      label:
                                                                          '${location['available']} slot parkir tersedia',
                                                                      child:
                                                                          Container(
                                                                        padding:
                                                                            const EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              8,
                                                                          vertical:
                                                                              4,
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color: Colors
                                                                              .green
                                                                              .shade50,
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                        ),
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            // Dot indicator
                                                                            Container(
                                                                              width: 6,
                                                                              height: 6,
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.green.shade600,
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(width: 6),
                                                                            Flexible(
                                                                              child: Text(
                                                                                '${location['available']} slot tersedia',
                                                                                style: TextStyle(
                                                                                  fontSize: 12,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  color: Colors.green.shade700,
                                                                                ),
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 8),
                                                                  // Navigation Arrow
                                                                  Semantics(
                                                                    label:
                                                                        'Navigasi',
                                                                    child: Icon(
                                                                      Icons
                                                                          .arrow_forward_ios,
                                                                      size: 16,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade400,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),

                    const SizedBox(height: 24),

                    // Quick Actions Section - 2x2 Grid Layout
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: const Text(
                            'Akses Cepat',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Semantics(
                          label: 'Menu akses cepat',
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.0,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: quickActions,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: 0,
        onTap: (index) => NavigationUtils.handleNavigation(context, index, 0),
      ),
    );
  }
}


