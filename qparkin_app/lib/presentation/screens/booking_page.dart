import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/booking_provider.dart';
import '../../logic/providers/active_parking_provider.dart';
import '../../logic/providers/point_provider.dart';
import '../../data/services/vehicle_service.dart';
import '../../data/models/vehicle_model.dart';
import '../../utils/responsive_helper.dart';
import '../../utils/point_error_handler.dart';
import '../widgets/mall_info_card.dart';
import '../widgets/vehicle_selector.dart';
import '../widgets/time_duration_picker.dart';
import '../widgets/slot_availability_indicator.dart';
import '../widgets/cost_breakdown_card.dart';
import '../widgets/booking_summary_card.dart';
import '../widgets/point_usage_card.dart';
import '../widgets/error_retry_widget.dart';
import '../widgets/slot_unavailable_widget.dart';
import '../widgets/booking_conflict_dialog.dart';
import '../dialogs/booking_confirmation_dialog.dart';

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
  late VehicleService _vehicleService;
  String? _authToken;
  BookingProvider? _bookingProvider;
  
  // Track orientation to detect changes
  Orientation? _previousOrientation;

  @override
  void initState() {
    super.initState();
    
    // TODO: Get baseUrl from config and auth token from secure storage
    const baseUrl = 'http://192.168.1.1:8000'; // Placeholder
    _authToken = 'dummy_token'; // Placeholder
    
    _vehicleService = VehicleService(
      baseUrl: baseUrl,
      authToken: _authToken,
    );
    
    // Initialize provider with mall data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      _bookingProvider!.initialize(widget.mall);
    });
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
    final bottomPadding = isLandscape ? 80.0 : 100.0;
    
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            // Scrollable content
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(padding, padding, padding, bottomPadding),
              child: Column(
                children: [
                  // Error display (if any)
                  if (provider.errorMessage != null && !provider.isLoading)
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
                    distance: widget.mall['distance'] ?? '0 km',
                    availableSlots: provider.availableSlots,
                  ),
                  
                  SizedBox(height: spacing),
                  
                  // Vehicle Selector
                  VehicleSelector(
                    selectedVehicle: provider.selectedVehicle != null
                        ? VehicleModel.fromJson(provider.selectedVehicle!)
                        : null,
                    onVehicleSelected: (vehicle) {
                      if (vehicle != null) {
                        provider.selectVehicle(vehicle.toJson());
                        
                        // Clear validation error when user selects vehicle
                        provider.clearValidationErrors();
                        
                        // Start periodic availability check if all data is set
                        if (provider.startTime != null &&
                            provider.bookingDuration != null &&
                            _authToken != null) {
                          provider.startPeriodicAvailabilityCheck(token: _authToken!);
                        }
                      }
                    },
                    vehicleService: _vehicleService,
                    validationError: provider.validationErrors['vehicleId'],
                  ),
                  
                  SizedBox(height: spacing),
                  
                  // Time Duration Picker
                  TimeDurationPicker(
                    startTime: provider.startTime,
                    duration: provider.bookingDuration,
                    onStartTimeChanged: (time) {
                      provider.setStartTime(time, token: _authToken);
                      
                      // Clear validation error when user changes time
                      provider.clearValidationErrors();
                      
                      // Start periodic availability check if all data is set
                      if (provider.selectedVehicle != null &&
                          provider.bookingDuration != null &&
                          _authToken != null) {
                        provider.startPeriodicAvailabilityCheck(token: _authToken!);
                      }
                    },
                    onDurationChanged: (duration) {
                      provider.setDuration(duration, token: _authToken);
                      
                      // Clear validation error when user changes duration
                      provider.clearValidationErrors();
                      
                      // Start periodic availability check if all data is set
                      if (provider.selectedVehicle != null &&
                          provider.startTime != null &&
                          _authToken != null) {
                        provider.startPeriodicAvailabilityCheck(token: _authToken!);
                      }
                    },
                    startTimeError: provider.validationErrors['startTime'],
                    durationError: provider.validationErrors['duration'],
                  ),
                  
                  SizedBox(height: spacing),
                  
                  // Slot Availability Indicator
                  if (provider.selectedVehicle != null)
                    SlotAvailabilityIndicator(
                      availableSlots: provider.availableSlots,
                      vehicleType: provider.selectedVehicle!['jenis_kendaraan'] ??
                          provider.selectedVehicle!['jenis'] ??
                          '',
                      isLoading: provider.isCheckingAvailability,
                      onRefresh: () {
                        if (_authToken != null) {
                          provider.refreshAvailability(token: _authToken!);
                        }
                      },
                    ),
                  
                  if (provider.selectedVehicle != null)
                    SizedBox(height: spacing),
                  
                  // Slot unavailability warning with alternatives
                  if (provider.availableSlots == 0 &&
                      provider.startTime != null &&
                      provider.bookingDuration != null &&
                      !provider.isCheckingAvailability)
                    Padding(
                      padding: EdgeInsets.only(bottom: spacing),
                      child: SlotUnavailableWidget(
                        currentStartTime: provider.startTime!,
                        currentDuration: provider.bookingDuration!,
                        onSelectAlternative: (time, duration) {
                          provider.setStartTime(time, token: _authToken);
                          provider.setDuration(duration, token: _authToken);
                          
                          // Trigger availability check
                          if (_authToken != null) {
                            provider.startPeriodicAvailabilityCheck(token: _authToken!);
                          }
                        },
                        onModifyTime: () {
                          // Scroll to time picker (optional enhancement)
                          // For now, just show a message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Silakan ubah waktu dan durasi di atas'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  
                  // Cost Breakdown Card
                  if (provider.bookingDuration != null && provider.costBreakdown != null)
                    CostBreakdownCard(
                      firstHourRate: provider.firstHourRate,
                      additionalHoursRate: provider.costBreakdown!['additionalHoursTotal'] ?? 0.0,
                      additionalHours: provider.costBreakdown!['additionalHours'] ?? 0,
                      totalCost: provider.estimatedCost,
                    ),
                  
                  if (provider.bookingDuration != null && provider.costBreakdown != null)
                    SizedBox(height: spacing),
                  
                  // Point Usage Card
                  if (provider.estimatedCost > 0)
                    Consumer<PointProvider>(
                      builder: (context, pointProvider, child) {
                        return PointUsageCard(
                          availablePoints: pointProvider.balance ?? 0,
                          totalCost: provider.estimatedCost,
                          pointConversionRate: 10.0, // 100 points = Rp 1,000
                          onPointsChanged: (points) {
                            provider.setPointsToUse(points, pointConversionRate: 10.0);
                          },
                          isLoading: provider.isLoading || pointProvider.isLoadingBalance,
                        );
                      },
                    ),
                  
                  if (provider.estimatedCost > 0)
                    SizedBox(height: spacing),
                  
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
                      totalCost: provider.estimatedCost,
                      pointsUsed: provider.pointsToUse > 0 ? provider.pointsToUse : null,
                      pointReduction: provider.pointReduction > 0 ? provider.pointReduction : null,
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
      onSuccess: (booking) async {
        // Stop periodic availability check
        provider.stopPeriodicAvailabilityCheck();
        
        // Use points if selected
        if (provider.pointsToUse > 0) {
          try {
            final pointProvider = Provider.of<PointProvider>(context, listen: false);
            final pointsUsed = await pointProvider.usePoints(
              amount: provider.pointsToUse,
              transactionId: booking.idTransaksi ?? booking.idBooking.toString(),
              token: _authToken,
            );
            
            if (pointsUsed) {
              debugPrint('[BookingPage] Points used successfully: ${provider.pointsToUse}');
            } else {
              debugPrint('[BookingPage] Failed to use points');
              // Show warning but don't fail the booking
              _showErrorSnackbar('Booking berhasil, tetapi gagal menggunakan poin');
            }
          } catch (e) {
            // Log error with context
            PointErrorHandler.logError(e, context: 'usePointsInBooking');
            
            // Show specific error message but don't fail the booking
            final requiresInternet = PointErrorHandler.requiresInternetMessage(e);
            final errorMessage = requiresInternet
                ? 'Booking berhasil, tetapi memerlukan koneksi internet untuk menggunakan poin'
                : 'Booking berhasil, tetapi gagal menggunakan poin: ${PointErrorHandler.getUserFriendlyMessage(e)}';
            _showErrorSnackbar(errorMessage);
          }
        }
        
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
    
    // Show confirmation dialog as full-screen route
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => BookingConfirmationDialog(
          booking: booking,
          onViewActivity: () async {
            // Close dialog
            Navigator.pop(context);
            
            // Trigger ActiveParkingProvider to fetch new booking data
            final activeParkingProvider = Provider.of<ActiveParkingProvider>(
              context,
              listen: false,
            );
            
            // Fetch active parking data to display the new booking
            await activeParkingProvider.fetchActiveParking(token: _authToken);
            
            // Navigate to Activity Page with initialTab: 0 (Aktivitas tab)
            Navigator.pushReplacementNamed(
              context,
              '/activity',
              arguments: {'initialTab': 0},
            );
          },
          onBackToHome: () {
            // Close dialog
            Navigator.pop(context);
            
            // Navigate to Home Page
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Stop periodic availability check when leaving page
    _bookingProvider?.stopPeriodicAvailabilityCheck();
    
    // Dispose vehicle service if it has a dispose method
    // Note: VehicleService doesn't have dispose in current implementation
    // but we document this for future reference
    
    // Clear references to large objects
    _bookingProvider = null;
    
    super.dispose();
  }
}
