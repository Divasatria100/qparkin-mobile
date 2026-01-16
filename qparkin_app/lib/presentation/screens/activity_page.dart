import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/circular_timer_widget.dart';
import '../widgets/qr_exit_button.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/pending_payment_card.dart';
import '/utils/navigation_utils.dart';
import '/logic/providers/active_parking_provider.dart';
import '/data/services/booking_service.dart';
import '/data/models/booking_model.dart';
import 'detail_history.dart';
import 'midtrans_payment_page.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> with TickerProviderStateMixin {
  late TabController _tabController;
  String? _lastErrorShown;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final BookingService _bookingService = BookingService();
  List<BookingModel> _pendingPayments = [];
  bool _isLoadingPendingPayments = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['initialTab'] == 1) {
        _tabController.animateTo(1);
      }
      // Fetch active parking data
      _fetchActiveParkingWithErrorHandling();
      // Fetch pending payments
      _fetchPendingPayments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bookingService.dispose();
    super.dispose();
  }

  /// Fetch pending payments
  Future<void> _fetchPendingPayments() async {
    setState(() {
      _isLoadingPendingPayments = true;
    });

    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        debugPrint('[ActivityPage] No auth token found');
        return;
      }

      final pendingPayments = await _bookingService.getPendingPayments(token: token);
      
      if (mounted) {
        setState(() {
          _pendingPayments = pendingPayments;
          _isLoadingPendingPayments = false;
        });
        
        debugPrint('[ActivityPage] Loaded ${pendingPayments.length} pending payments');
      }
    } catch (e) {
      debugPrint('[ActivityPage] Error fetching pending payments: $e');
      if (mounted) {
        setState(() {
          _isLoadingPendingPayments = false;
        });
      }
    }
  }

  /// Handle continue payment action
  Future<void> _handleContinuePayment(BookingModel booking) async {
    // Navigate to Midtrans payment page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MidtransPaymentPage(booking: booking),
      ),
    ).then((_) {
      // Refresh pending payments after returning from payment page
      _fetchPendingPayments();
      _fetchActiveParkingWithErrorHandling();
    });
  }

  /// Handle cancel payment action
  Future<void> _handleCancelPayment(BookingModel booking) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Booking?'),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan booking ini? '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final success = await _bookingService.cancelPendingPayment(
        bookingId: booking.idBooking,
        token: token,
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (success) {
        // Show success message
        _showSuccessSnackbar('Booking berhasil dibatalkan');
        // Refresh pending payments
        _fetchPendingPayments();
      } else {
        _showErrorSnackbar('Gagal membatalkan booking. Silakan coba lagi.');
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      _showErrorSnackbar('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Fetch active parking and show snackbar on error
  Future<void> _fetchActiveParkingWithErrorHandling() async {
    final provider = Provider.of<ActiveParkingProvider>(context, listen: false);
    
    // Skip API call if in demo mode
    if (provider.isDemoMode) {
      debugPrint('[ActivityPage] Skipping API call - demo mode active');
      return;
    }
    
    await provider.fetchActiveParking();
    
    // Show snackbar if there's an error
    if (mounted && provider.errorMessage != null && provider.errorMessage != _lastErrorShown) {
      _lastErrorShown = provider.errorMessage;
      _showErrorSnackbar(provider.errorMessage!);
    }
  }

  /// Show error snackbar with retry action
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF44336),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Coba Lagi',
          textColor: Colors.white,
          onPressed: () {
            _lastErrorShown = null;
            _fetchActiveParkingWithErrorHandling();
          },
        ),
      ),
    );
  }

  /// Show success snackbar
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Format last sync time as relative time
  String _formatLastSync(DateTime lastSync) {
    final now = DateTime.now();
    final difference = now.difference(lastSync);
    
    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return '${difference.inHours} jam yang lalu';
    }
  }

  final List<Map<String, dynamic>> parkingHistory = [
    {
      'location': 'Mega Mall Batam Centre',
      'date': '15 Nov 2023',
      'time': '10:00 - 12:30',
      'duration': '2 jam 30 menit',
      'cost': 'Rp 15.000',
    },
    {
      'location': 'One Batam Mall',
      'date': '14 Nov 2023',
      'time': '15:45 - 17:15',
      'duration': '1 jam 30 menit',
      'cost': 'Rp 10.000',
    },
    {
      'location': 'SNL Food Bengkong',
      'date': '13 Nov 2023',
      'time': '19:00 - 21:00',
      'duration': '2 jam',
      'cost': 'Rp 12.000',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Aktivitas & Riwayat',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Color(0xFF573ED1),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Aktivitas'),
                Tab(text: 'Riwayat'),
              ],
              indicatorColor: Color(0xFF573ED1),
              labelColor: Color(0xFF573ED1),
              unselectedLabelColor: Colors.grey,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Aktivitas Tab - ENHANCED with Provider
                Consumer<ActiveParkingProvider>(
                  builder: (context, provider, child) {
                    // Show shimmer loading on initial load
                    if (provider.isLoading && provider.activeParking == null) {
                      return const ActivityPageShimmer();
                    }

                    // Show error state with retry button
                    if (provider.errorMessage != null && provider.activeParking == null) {
                      return Container(
                        color: Colors.white,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Semantics(
                              label: 'Terjadi kesalahan: ${provider.errorMessage}',
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Semantics(
                                    label: 'Ikon kesalahan',
                                    child: Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF44336).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: const Icon(
                                        Icons.error_outline,
                                        size: 48,
                                        color: Color(0xFFF44336),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ExcludeSemantics(
                                    child: const Text(
                                      'Terjadi Kesalahan',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ExcludeSemantics(
                                    child: Text(
                                      provider.errorMessage!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Semantics(
                                    label: 'Tombol coba lagi. Ketuk untuk memuat ulang data parkir',
                                    button: true,
                                    child: SizedBox(
                                      height: 56, // Meets minimum 48dp touch target
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          _lastErrorShown = null;
                                          _fetchActiveParkingWithErrorHandling();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF573ED1),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        icon: const Icon(Icons.refresh, color: Colors.white, semanticLabel: 'Ikon refresh'),
                                        label: ExcludeSemantics(
                                          child: const Text(
                                            'Coba Lagi',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    if (provider.activeParking == null) {
                      // Empty State - but check for pending payments first
                      return Container(
                        color: Colors.white,
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await _fetchActiveParkingWithErrorHandling();
                            await _fetchPendingPayments();
                            if (mounted && provider.errorMessage == null) {
                              _showSuccessSnackbar('Data berhasil diperbarui');
                            }
                          },
                          color: const Color(0xFF573ED1),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Pending Payments Section
                                if (_pendingPayments.isNotEmpty) ...[
                                  const Text(
                                    'Menunggu Pembayaran',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ..._pendingPayments.map((booking) => PendingPaymentCard(
                                    booking: booking,
                                    onContinuePayment: () => _handleContinuePayment(booking),
                                    onCancel: () => _handleCancelPayment(booking),
                                  )),
                                  const SizedBox(height: 24),
                                  const Divider(),
                                  const SizedBox(height: 24),
                                ],
                                
                                // Empty state for active parking
                                Center(
                                  child: Semantics(
                                    label: 'Tidak ada parkir aktif. Mulai parkir untuk melihat aktivitas Anda',
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Semantics(
                                          label: 'Ikon mobil',
                                          child: Container(
                                            padding: const EdgeInsets.all(24),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius: BorderRadius.circular(50),
                                            ),
                                            child: Icon(
                                              Icons.directions_car,
                                              size: 48,
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ExcludeSemantics(
                                          child: const Text(
                                            'Tidak ada parkir aktif',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ExcludeSemantics(
                                          child: Text(
                                            'Mulai parkir untuk melihat aktivitas Anda',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                            textAlign: TextAlign.center,
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
                      );
                    }

                    // Active Parking Display
                    final parking = provider.activeParking!;
                    
                    // Show warning snackbar if booking expired
                    if (parking.isPenaltyApplicable() && mounted) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: const [
                                  Icon(Icons.warning, color: Colors.white),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Waktu booking telah habis. Penalty akan dikenakan.',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFFFF9800),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      });
                    }
                    
                    return Container(
                      color: Colors.white,
                      child: RefreshIndicator(
                        onRefresh: () async {
                          // Skip refresh in demo mode
                          if (provider.isDemoMode) {
                            _showSuccessSnackbar('Mode Demo - Data tidak diperbarui');
                            return;
                          }
                          await _fetchActiveParkingWithErrorHandling();
                          await _fetchPendingPayments();
                          if (mounted && provider.errorMessage == null) {
                            _showSuccessSnackbar('Data berhasil diperbarui');
                          }
                        },
                        color: const Color(0xFF573ED1),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Pending Payments Section
                              if (_pendingPayments.isNotEmpty) ...[
                                const Text(
                                  'Menunggu Pembayaran',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ..._pendingPayments.map((booking) => PendingPaymentCard(
                                  booking: booking,
                                  onContinuePayment: () => _handleContinuePayment(booking),
                                  onCancel: () => _handleCancelPayment(booking),
                                )),
                                const SizedBox(height: 24),
                                const Divider(),
                                const SizedBox(height: 24),
                                const Text(
                                  'Parkir Aktif',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              
                              // CircularTimerWidget at top as focal point - ENLARGED
                              Center(
                                child: CircularTimerWidget(
                                  startTime: parking.waktuMasuk,
                                  endTime: parking.waktuSelesaiEstimas,
                                  isBooking: parking.isBooking,
                                  onTimerUpdate: (duration) {
                                    // Timer update callback handled by provider
                                  },
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // QRExitButton at bottom
                              QRExitButton(
                                qrCode: parking.qrCode,
                                isEnabled: true,
                                mallName: parking.namaMall,
                                slotCode: parking.kodeSlot,
                              ),
                              
                              // Last sync indicator
                              if (provider.lastSyncTime != null) ...[
                                const SizedBox(height: 16),
                                Text(
                                  'Terakhir diperbarui: ${_formatLastSync(provider.lastSyncTime!)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Riwayat Tab
                Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: const Text(
                          'Riwayat Parkir',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                          itemCount: parkingHistory.length,
                          itemBuilder: (context, index) {
                            final history = parkingHistory[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailHistoryPage(history: history),
                                    ),
                                  );
                                },
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
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFF573ED1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        child: const Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              history['location'],
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${history['date']} • ${history['time']}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Durasi: ${history['duration']} • Biaya: ${history['cost']}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.grey.shade400,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: 1,
        onTap: (index) => NavigationUtils.handleNavigation(context, index, 1),
      ),
    ));
  }
}
