import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../logic/providers/booking_provider.dart';
import '../../logic/providers/active_parking_provider.dart';
import '../../logic/providers/profile_provider.dart';
import '../../data/services/vehicle_api_service.dart';
import '../../data/models/vehicle_model.dart';
import '../../utils/responsive_helper.dart';
import '../widgets/mall_info_card.dart';
import '../widgets/vehicle_selector.dart';
import '../widgets/floor_selector_widget.dart';
import '../widgets/unified_time_duration_card.dart';
import '../widgets/time_duration_picker.dart';
import '../widgets/slot_availability_indicator.dart';
import '../widgets/cost_breakdown_card.dart';
import '../widgets/booking_summary_card.dart';
import '../widgets/error_retry_widget.dart';
import '../widgets/booking_conflict_dialog.dart';
import '../widgets/point_usage_widget.dart';
import '../widgets/base_parking_card.dart';
import '../dialogs/booking_confirmation_dialog.dart';
import '../../logic/providers/point_provider.dart';
import 'midtrans_payment_page.dart';

/// Main booking page for reserving parking slots
///
/// Allows users to select vehicle, time, duration and confirm booking
/// with real-time slot availability and cost calculation.
///
/// This widget wraps itself with ChangeNotifierProvider to provide
/// BookingProvider to all child widgets.
///
/// Requirements: 1.1-1.5, 12.1-12.9, 15.8
class BookingPage extends StatelessWidget {
  final Map<String, dynamic> mall;

  const BookingPage({
    Key? key,
    required this.mall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookingProvider(),
      child: _BookingPageContent(mall: mall),
    );
  }
}

/// Internal stateful widget for BookingPage content
///
/// Separated to allow Provider access in initState
class _BookingPageContent extends StatefulWidget {
  final Map<String, dynamic> mall;

  const _BookingPageContent({
    Key? key,
    required this.mall,
  }) : super(key: key);

  @override
  State<_BookingPageContent> createState() => _BookingPageContentState();
}

class _BookingPageContentState extends State<_BookingPageContent> {
  VehicleApiService? _vehicleService;
  String? _authToken;
  String? _baseUrl;
  BookingProvider? _bookingProvider;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Track orientation to detect changes
  Orientation? _previousOrientation;
  
  // Scroll controller for auto-scroll functionality
  final ScrollController _scrollController = ScrollController();
  
  // Global key for PointUsageWidget to get its position
  final GlobalKey _pointUsageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    
    // Initialize and fetch auth data
    _initializeAuthData();
  }
  
  /// Initialize authentication data from secure storage and config
  Future<void> _initializeAuthData() async {
    try {
      // Get auth token from secure storage
      final token = await _storage.read(key: 'auth_token');
      
      // Get base URL from environment variable (same as main.dart)
      const baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8000');
      
      debugPrint('[BookingPage] Initializing with baseUrl: $baseUrl');
      debugPrint('[BookingPage] Auth token available: ${token != null}');
      
      if (!mounted) return;
      
      setState(() {
        _authToken = token;
        _baseUrl = baseUrl;
      });
      
      // Initialize vehicle service with real credentials
      _vehicleService = VehicleApiService(
        baseUrl: baseUrl,
      );
      
      // Initialize provider with mall data (async to fetch parkiran)
      if (mounted) {
        _bookingProvider = Provider.of<BookingProvider>(context, listen: false);
        await _bookingProvider!.initialize(widget.mall, token: _authToken);
        
        // Fetch floors for slot reservation
        if (_authToken != null) {
          _bookingProvider!.fetchFloors(token: _authToken!);
        }
      }
    } catch (e) {
      debugPrint('[BookingPage] Error initializing auth data: $e');
      
      // Fallback to default values if secure storage fails
      const baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8000');
      
      if (!mounted) return;
      
      setState(() {
        _baseUrl = baseUrl;
        _authToken = null;
      });
      
      _vehicleService = VehicleApiService(
        baseUrl: baseUrl,
      );
      
      // Initialize provider with mall data (without token - will fail at booking)
      if (mounted) {
        _bookingProvider = Provider.of<BookingProvider>(context, listen: false);
        await _bookingProvider!.initialize(widget.mall);
      }
    }
  }
  
  /// Auto-scroll to PointUsageWidget when it expands
  void _scrollToPointUsageWidget() {
    try {
      final context = _pointUsageKey.currentContext;
      if (context != null) {
        // Get the RenderBox of the widget
        final box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          // Get the position of the widget relative to the viewport
          final position = box.localToGlobal(Offset.zero);
          
          // Calculate the target scroll position
          // We want to scroll so the widget is visible with some padding from top
          final targetScroll = _scrollController.offset + position.dy - 100;
          
          // Animate to the target position
          _scrollController.animateTo(
            targetScroll,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    } catch (e) {
      debugPrint('[BookingPage] Error scrolling to PointUsageWidget: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detect orientation changes
    final currentOrientation = MediaQuery.of(context).orientation;
    if (_previousOrientation != null && _previousOrientation != currentOrientation) {
      // Orientation changed - trigger rebuild with preserved state
      // The Provider pattern automatically preserves state
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Force a rebuild to adjust layout for new orientation
        if (mounted) {
          setState(() {});
        }
      });
    }
    _previousOrientation = currentOrientation;
    
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// Build AppBar with back button and title
  ///
  /// Requirements: 1.1-1.5, 12.1-12.9, 13.7
  PreferredSizeWidget _buildAppBar() {
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(context, 20);
    
    return AppBar(
      centerTitle: true,
      title: Text(
        'Booking Parkir',
        style: TextStyle(
          color: Colors.white,
          fontSize: titleFontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color(0xFF573ED1),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: Semantics(
        label: 'Tombol kembali',
        hint: 'Ketuk untuk kembali ke halaman sebelumnya',
        button: true,
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Kembali',
          iconSize: 24,
          constraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
        ),
      ),
    );
  }

  /// Build main body with scrollable content and fixed bottom button
  ///
  /// Requirements: 1.1-1.5, 12.1-12.9, 13.7, 13.6
  Widget _buildBody() {
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final spacing = ResponsiveHelper.getCardSpacing(context);
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    
    // Adjust bottom padding for landscape mode (smaller button area)
    // Increased padding to prevent PointUsageWidget from being cut off by confirm button
    final bottomPadding = isLandscape ? 120.0 : 140.0;
    
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        // Check if parkiran is available for this mall
        final hasParkiranError = provider.errorMessage != null && 
            (provider.errorMessage!.contains('Parkiran tidak tersedia') ||
             provider.errorMessage!.contains('parkiran configured'));
        
        return Stack(
          children: [
            // Scrollable content
            SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(padding, padding, padding, bottomPadding),
              child: Column(
                children: [
                  // Parkiran availability warning (if no parkiran found)
                  if (hasParkiranError)
                    Container(
                      margin: EdgeInsets.only(bottom: spacing),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange.shade700,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Parkiran Tidak Tersedia',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  provider.errorMessage!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Error display (if any other errors)
                  if (provider.errorMessage != null && !provider.isLoading && !hasParkiranError)
                    Padding(
                      padding: EdgeInsets.only(bottom: spacing),
                      child: ErrorRetryWidget(
                        errorMessage: provider.errorMessage!,
                        isNetworkError: _isNetworkError(provider.errorMessage!),
                        isOffline: _isOfflineError(provider.errorMessage!),
                        onRetry: _canRetryError(provider.errorMessage!) 
                            ? () => _handleConfirmBooking(provider)
                            : null,
                      ),
                    ),
                  
                  // Mall Info Card
                  MallInfoCard(
                    mallName: widget.mall['name'] ?? widget.mall['nama_mall'] ?? '',
                    address: widget.mall['address'] ?? widget.mall['alamat'] ?? '',
                    availableSlots: provider.availableSlots,
                  ),
                  
                  SizedBox(height: spacing),
                  
                  // Vehicle Selector - only show when service is initialized
                  if (_vehicleService != null)
                    VehicleSelector(
                      selectedVehicle: provider.selectedVehicle != null
                          ? VehicleModel.fromJson(provider.selectedVehicle!)
                          : null,
                      onVehicleSelected: (vehicle) {
                        if (vehicle != null) {
                          // Pass token to selectVehicle for floor filtering
                          provider.selectVehicle(vehicle.toJson(), token: _authToken);
                          
                          // Clear validation error when user selects vehicle
                          provider.clearValidationErrors();
                          
                          // REMOVED: startPeriodicAvailabilityCheck
                          // Slot availability is now determined solely by loadFloorsForVehicle()
                          // which is called inside selectVehicle()
                        }
                      },
                      vehicleService: _vehicleService!,
                      validationError: provider.validationErrors['vehicleId'],
                    ),
                  
                  SizedBox(height: spacing),
                  
                  // Slot Availability Indicator - show immediately after vehicle selection
                  // This provides instant feedback about available slots for selected vehicle type
                  if (provider.selectedVehicle != null &&
                      !provider.isLoadingFloors)
                    SlotAvailabilityIndicator(
                      availableSlots: provider.availableSlots,
                      vehicleType: provider.selectedVehicle!['jenis_kendaraan'] ??
                          provider.selectedVehicle!['jenis'] ??
                          '',
                      isLoading: provider.isLoadingFloors,
                      onRefresh: () {
                        // Refresh floors data to get latest slot availability
                        if (_authToken != null && provider.selectedVehicle != null) {
                          final jenisKendaraan = provider.selectedVehicle!['jenis_kendaraan']?.toString() ??
                              provider.selectedVehicle!['jenis']?.toString();
                          if (jenisKendaraan != null) {
                            provider.loadFloorsForVehicle(
                              jenisKendaraan: jenisKendaraan,
                              token: _authToken!,
                            );
                          }
                        }
                      },
                    ),
                  
                  if (provider.selectedVehicle != null &&
                      !provider.isLoadingFloors)
                    SizedBox(height: spacing),
                  
                  // Floor Selection Section - show after user sees total availability
                  // User can now make informed decision about which floor to choose
                  _buildSlotReservationSection(provider, spacing),
                  
                  SizedBox(height: spacing),
                  
                  // Unified Time Duration Card (NEW)
                  UnifiedTimeDurationCard(
                    startTime: provider.startTime,
                    duration: provider.bookingDuration,
                    onTimeChanged: (time) {
                      provider.setStartTime(time, token: _authToken);
                      
                      // Clear validation error when user changes time
                      provider.clearValidationErrors();
                      
                      // REMOVED: startPeriodicAvailabilityCheck
                      // Time selection doesn't affect slot availability
                      // Slots are determined by vehicle type and floor configuration
                    },
                    onDurationChanged: (duration) {
                      provider.setDuration(duration, token: _authToken);
                      
                      // Clear validation error when user changes duration
                      provider.clearValidationErrors();
                      
                      // REMOVED: startPeriodicAvailabilityCheck
                      // Duration selection doesn't affect slot availability
                      // Slots are determined by vehicle type and floor configuration
                    },
                    startTimeError: provider.validationErrors['startTime'],
                    durationError: provider.validationErrors['duration'],
                  ),
                  
                  SizedBox(height: spacing),
                  
                  // REMOVED: SlotUnavailableWidget - Caused data inconsistency
                  // Slot availability is now solely determined by loadFloorsForVehicle()
                  // which calculates available slots from filtered floors
                  
                  // Booking Summary Card
                  if (_canShowSummary(provider))
                    BookingSummaryCard(
                      mallName: widget.mall['name'] ?? widget.mall['nama_mall'] ?? '',
                      mallAddress: widget.mall['address'] ?? widget.mall['alamat'] ?? '',
                      vehiclePlat: provider.selectedVehicle!['plat_nomor'] ?? '',
                      vehicleType: provider.selectedVehicle!['jenis_kendaraan'] ?? '',
                      vehicleBrand: '${provider.selectedVehicle!['merk']} ${provider.selectedVehicle!['tipe']}',
                      startTime: provider.startTime!,
                      duration: provider.bookingDuration!,
                      endTime: provider.calculatedEndTime!,
                      totalCost: provider.finalCost, // Use finalCost which includes point discount
                      reservedSlotCode: provider.reservedSlot?.slotCode,
                      reservedFloorName: provider.reservedSlot?.floorName,
                      reservedSlotType: provider.reservedSlot?.typeLabel,
                      // Point discount information
                      pointsUsed: provider.selectedPoints > 0 ? provider.selectedPoints : null,
                      pointDiscount: provider.pointDiscount > 0 ? provider.pointDiscount : null,
                      originalCost: provider.selectedPoints > 0 ? provider.estimatedCost : null,
                    ),
                  
                  if (_canShowSummary(provider))
                    SizedBox(height: spacing),
                  
                  // Point Usage Widget - only show when vehicle is selected
                  // MOVED DOWN: Show AFTER booking summary to keep cost flow uninterrupted
                  if (provider.selectedVehicle != null &&
                      provider.bookingDuration != null && 
                      provider.estimatedCost > 0)
                    PointUsageWidget(
                      key: _pointUsageKey,
                      parkingCost: provider.estimatedCost.toInt(),
                      onPointsSelected: (points) {
                        provider.setSelectedPoints(points);
                      },
                      initialPoints: provider.selectedPoints,
                      onExpanded: _scrollToPointUsageWidget,
                    ),
                ],
              ),
            ),
            
            // Fixed bottom button
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildConfirmButton(provider),
            ),
            
            // Loading overlay
            if (provider.isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF573ED1)),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Check if we can show the booking summary card
  bool _canShowSummary(BookingProvider provider) {
    return provider.selectedVehicle != null &&
        provider.startTime != null &&
        provider.bookingDuration != null &&
        provider.calculatedEndTime != null;
  }

  /// Build slot reservation section with floor selector only (auto-assignment)
  ///
  /// Simplified flow: User selects floor → System auto-assigns slot on booking confirmation.
  /// No manual slot selection or reservation needed.
  ///
  /// Requirements: 3.1-3.12, 17.1-17.9
  Widget _buildSlotReservationSection(BookingProvider provider, double spacing) {
    // Check if slot reservation is enabled for this mall
    // If feature is disabled, return empty container (auto-assignment will be used)
    if (!provider.isSlotReservationEnabled) {
      return const SizedBox.shrink();
    }
    
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(context, 18);
    
    // Wrap entire section in ONE BaseParkingCard for consistency
    return BaseParkingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Semantics(
            header: true,
            child: Text(
              'Pilih Lantai Parkir',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: spacing * 0.5),
          
          // Info text
          Text(
            'Pilih lantai parkir yang diinginkan. Slot akan dipilihkan otomatis oleh sistem.',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              color: Colors.grey[600],
            ),
          ),
          
          SizedBox(height: spacing * 0.75),
          
          // Floor Selector Widget (no external card wrapper)
          FloorSelectorWidget(
            floors: provider.floors,
            selectedFloor: provider.selectedFloor,
            isLoading: provider.isLoadingFloors,
            onFloorSelected: (floor) {
              provider.selectFloor(floor, token: _authToken);
              
              // Clear any previous error
              provider.clearError();
              
              // Show success feedback
              _showSuccessSnackbar('Lantai ${floor.floorName} dipilih');
            },
            onRetry: () {
              if (_authToken != null) {
                provider.fetchFloors(token: _authToken!);
              }
            },
          ),
          
          // Show selected floor info
          if (provider.selectedFloor != null) ...[
            SizedBox(height: spacing),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF573ED1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF573ED1).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF573ED1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_parking,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.selectedFloor!.floorName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${provider.selectedFloor!.availableSlots} slot tersedia',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 14,
                                color: const Color(0xFF4CAF50),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Slot akan dipilihkan otomatis',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF4CAF50),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      provider.selectFloor(provider.selectedFloor!, token: null);
                      // This will deselect the floor
                      setState(() {});
                    },
                    tooltip: 'Batalkan pilihan lantai',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Check if error is a network error
  bool _isNetworkError(String message) {
    return message.contains('internet') || 
           message.contains('koneksi') ||
           message.contains('timeout') ||
           message.contains('network');
  }

  /// Check if error is an offline error
  bool _isOfflineError(String message) {
    return message.contains('internet') || 
           message.contains('koneksi');
  }

  /// Check if error can be retried
  bool _canRetryError(String message) {
    return _isNetworkError(message) ||
           message.contains('timeout') ||
           message.contains('server') ||
           message.contains('coba lagi');
  }

  /// Build confirm booking button with gradient and validation
  ///
  /// Requirements: 8.1-8.7, 14.1-14.8, 13.7
  Widget _buildConfirmButton(BookingProvider provider) {
    final isEnabled = provider.canConfirmBooking;
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final fontSize = ResponsiveHelper.getResponsiveFontSize(context, 16);
    final borderRadius = ResponsiveHelper.getBorderRadius(context);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.all(padding),
      child: SafeArea(
        child: Semantics(
          label: isEnabled 
              ? 'Tombol konfirmasi booking' 
              : 'Tombol konfirmasi booking tidak aktif. Lengkapi semua data terlebih dahulu',
          hint: isEnabled 
              ? 'Ketuk untuk mengkonfirmasi dan membuat booking parkir' 
              : 'Lengkapi kendaraan, waktu, dan durasi untuk mengaktifkan tombol',
          button: true,
          enabled: isEnabled,
          child: SizedBox(
            height: 56,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isEnabled ? () => _handleConfirmBooking(provider) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isEnabled
                    ? const Color(0xFF573ED1)
                    : Colors.grey.shade300,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                elevation: isEnabled ? 8 : 0,
                shadowColor: const Color(0xFF573ED1).withOpacity(0.4),
                minimumSize: const Size(double.infinity, 56),
                padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
              ),
              child: provider.isLoading
                  ? Semantics(
                      label: 'Memproses booking',
                      child: const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : Text(
                      'Konfirmasi Booking',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  /// Handle confirm booking button press
  ///
  /// Requirements: 9.1-9.9, 11.1-11.7, 11.6
  Future<void> _handleConfirmBooking(BookingProvider provider) async {
    // Validate all inputs
    if (!provider.canConfirmBooking) {
      _showErrorSnackbar('Mohon lengkapi semua data dengan benar');
      return;
    }

    if (_authToken == null) {
      _showErrorSnackbar('Sesi Anda telah berakhir. Silakan login kembali.');
      return;
    }

    // Clear any previous errors
    provider.clearError();
    
    // Announce to screen reader
    SemanticsService.announce(
      'Memproses booking parkir',
      TextDirection.ltr,
    );

    // Check for existing active booking before proceeding
    final hasActive = await provider.hasActiveBooking(token: _authToken!);
    if (hasActive) {
      // Show booking conflict dialog
      _showBookingConflictDialog();
      
      // Announce conflict to screen reader
      SemanticsService.announce(
        'Anda sudah memiliki booking aktif',
        TextDirection.ltr,
      );
      return;
    }

    // Attempt to create booking
    final success = await provider.confirmBooking(
      token: _authToken!,
      skipActiveCheck: true, // Skip check since we already checked above
      onSuccess: (booking) {
        // Stop periodic availability check
        provider.stopPeriodicAvailabilityCheck();
        
        // Announce success to screen reader
        SemanticsService.announce(
          'Booking berhasil dibuat',
          TextDirection.ltr,
        );
        
        // Show confirmation dialog with booking details
        _showConfirmationDialog(booking);
      },
    );

    // Show error if booking failed
    if (!success && provider.errorMessage != null) {
      // Check if it's a booking conflict error (backend validation)
      if (_isBookingConflict(provider.errorMessage!)) {
        _showBookingConflictDialog();
      } else {
        _showErrorSnackbar(provider.errorMessage!);
      }
      
      // Announce error to screen reader
      SemanticsService.announce(
        'Booking gagal. ${provider.errorMessage}',
        TextDirection.ltr,
      );
    }
  }

  /// Check if error is a booking conflict
  bool _isBookingConflict(String message) {
    return message.contains('booking aktif') ||
           message.contains('active booking') ||
           message.contains('sudah memiliki') ||
           message.contains('conflict');
  }

  /// Show booking conflict dialog
  void _showBookingConflictDialog() {
    BookingConflictDialog.show(
      context: context,
      onViewExisting: () {
        // Navigate to Activity Page to view existing booking
        Navigator.pushReplacementNamed(
          context,
          '/activity',
          arguments: {'initialTab': 0},
        );
      },
      onCancel: () {
        // Just close the dialog and stay on booking page
        // User can modify their booking or go back
      },
    );
  }

  /// Show error snackbar with retry option
  ///
  /// Requirements: 11.1-11.7
  void _showErrorSnackbar(String message) {
    final isNetworkError = message.contains('internet') || 
                          message.contains('koneksi') ||
                          message.contains('timeout') ||
                          message.contains('network');
    
    final isOffline = message.contains('internet') || 
                     message.contains('koneksi');
    
    // Show offline indicator if network is unavailable
    if (isOffline) {
      ErrorSnackbarHelper.showOffline(context);
      return;
    }
    
    // Show error with retry button for recoverable errors
    ErrorSnackbarHelper.showError(
      context: context,
      message: message,
      isNetworkError: isNetworkError,
      onRetry: isNetworkError ? () {
        final provider = Provider.of<BookingProvider>(context, listen: false);
        _handleConfirmBooking(provider);
      } : null,
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

  /// Show booking confirmation dialog
  ///
  /// Requirements: 10.1-10.6, 10.8
  void _showConfirmationDialog(booking) {
    // Pop the booking page first
    Navigator.pop(context);
    
    // Navigate to Midtrans payment page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MidtransPaymentPage(booking: booking),
      ),
    );
  }

  @override
  void dispose() {
    // Stop periodic availability check when leaving page
    _bookingProvider?.stopPeriodicAvailabilityCheck();
    
    // Dispose scroll controller
    _scrollController.dispose();
    
    // Dispose vehicle service if it has a dispose method
    // Note: VehicleService doesn't have dispose in current implementation
    // but we document this for future reference
    
    // Clear references to large objects
    _bookingProvider = null;
    
    super.dispose();
  }
}
