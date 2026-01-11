import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../../config/design_constants.dart';
import '../../data/models/vehicle_model.dart';
import '../../data/services/vehicle_api_service.dart';
import 'base_parking_card.dart';
import 'booking_shimmer_loading.dart';
import 'validation_error_text.dart';

/// Widget for selecting a vehicle from the user's registered vehicles
/// Uses Modal Bottom Sheet for elegant vehicle selection
///
/// Requirements: 3.1-3.7, 11.3, 12.1-12.9, 13.2
class VehicleSelector extends StatefulWidget {
  final VehicleModel? selectedVehicle;
  final Function(VehicleModel?) onVehicleSelected;
  final VehicleApiService vehicleService;
  final String? validationError;

  const VehicleSelector({
    Key? key,
    required this.selectedVehicle,
    required this.onVehicleSelected,
    required this.vehicleService,
    this.validationError,
  }) : super(key: key);

  @override
  State<VehicleSelector> createState() => _VehicleSelectorState();
}

class _VehicleSelectorState extends State<VehicleSelector> {
  List<VehicleModel> _vehicles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  Future<void> _fetchVehicles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('[VehicleSelector] Fetching vehicles from API...');
      final vehicles = await widget.vehicleService.getVehicles();
      debugPrint(
          '[VehicleSelector] Vehicles fetched successfully: ${vehicles.length} vehicles');

      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
      });

      // Auto-select active vehicle if no vehicle is currently selected
      _autoSelectActiveVehicle();
    } catch (e) {
      debugPrint('[VehicleSelector] Error fetching vehicles: $e');

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Auto-select the active vehicle if available and no vehicle is currently selected
  void _autoSelectActiveVehicle() {
    // Only auto-select if no vehicle is currently selected
    if (widget.selectedVehicle != null) {
      debugPrint(
          '[VehicleSelector] Vehicle already selected, skipping auto-selection');
      return;
    }

    // Find the first active vehicle
    try {
      final activeVehicle = _vehicles.firstWhere(
        (vehicle) => vehicle.isActive == true,
      );

      debugPrint(
          '[VehicleSelector] Auto-selecting active vehicle: ${activeVehicle.platNomor}');

      // Notify parent to update selected vehicle
      widget.onVehicleSelected(activeVehicle);

      // Announce to screen readers
      SemanticsService.announce(
        'Kendaraan aktif ${activeVehicle.platNomor} dipilih secara otomatis',
        TextDirection.ltr,
      );
    } catch (e) {
      debugPrint(
          '[VehicleSelector] No active vehicle found for auto-selection');
    }
  }

  IconData _getVehicleIcon(String jenisKendaraan) {
    switch (jenisKendaraan.toLowerCase()) {
      case 'roda dua':
        return Icons.two_wheeler;
      case 'roda tiga':
        return Icons.electric_rickshaw;
      case 'roda empat':
        return Icons.directions_car;
      case 'lebih dari enam':
        return Icons.local_shipping;
      default:
        return Icons.directions_car;
    }
  }

  void _navigateToAddVehicle() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Navigasi ke halaman tambah kendaraan'),
        backgroundColor: DesignConstants.primaryColor,
      ),
    );
  }

  /// Show vehicle selection bottom sheet
  void _showVehicleBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _VehicleSelectionBottomSheet(
        vehicles: _vehicles,
        selectedVehicle: widget.selectedVehicle,
        onVehicleSelected: (vehicle) {
          widget.onVehicleSelected(vehicle);
          Navigator.pop(context);
          if (vehicle != null) {
            SemanticsService.announce(
              'Kendaraan ${vehicle.platNomor} dipilih',
              TextDirection.ltr,
            );
          }
        },
        getVehicleIcon: _getVehicleIcon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasValidationError =
        widget.validationError != null && widget.validationError!.isNotEmpty;

    return BaseParkingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Kendaraan',
            style: DesignConstants.getHeadingStyle(
              fontSize: DesignConstants.fontSizeH4,
            ),
          ),
          const SizedBox(height: DesignConstants.spaceMd),

          if (_isLoading)
            _buildLoadingState()
          else if (_errorMessage != null)
            _buildErrorState()
          else if (_vehicles.isEmpty)
            _buildEmptyState()
          else
            _buildVehicleSelector(),

          // Validation error display
          if (hasValidationError)
            ValidationErrorText(errorText: widget.validationError),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Semantics(
      label: 'Memuat daftar kendaraan',
      hint: 'Mohon tunggu, sedang memuat data kendaraan Anda',
      child: const VehicleSelectorShimmer(),
    );
  }

  Widget _buildErrorState() {
    return Semantics(
      label: 'Gagal memuat kendaraan',
      hint:
          'Terjadi kesalahan saat memuat data kendaraan. Ketuk tombol coba lagi untuk memuat ulang',
      child: Container(
        padding: DesignConstants.cardPadding,
        decoration: BoxDecoration(
          color: DesignConstants.errorSurface,
          borderRadius:
              BorderRadius.circular(DesignConstants.cardBorderRadius),
        ),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: DesignConstants.errorColor,
              size: DesignConstants.iconSizeXLarge,
            ),
            const SizedBox(height: DesignConstants.spaceSm),
            Text(
              'Gagal memuat kendaraan',
              style: DesignConstants.getBodyStyle(
                fontWeight: DesignConstants.fontWeightSemiBold,
                color: DesignConstants.errorColor,
              ),
            ),
            const SizedBox(height: DesignConstants.spaceSm),
            Semantics(
              label: 'Tombol coba lagi',
              hint: 'Ketuk untuk memuat ulang data kendaraan',
              button: true,
              child: TextButton(
                onPressed: _fetchVehicles,
                style: TextButton.styleFrom(
                  minimumSize: const Size(
                    DesignConstants.minTouchTarget,
                    DesignConstants.minTouchTarget,
                  ),
                ),
                child: const Text('Coba Lagi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Semantics(
      label:
          'Belum ada kendaraan terdaftar. Tambahkan kendaraan terlebih dahulu untuk melanjutkan booking',
      child: Container(
        padding: DesignConstants.cardPadding,
        decoration: BoxDecoration(
          border: Border.all(
            color: DesignConstants.borderPrimary,
            width: DesignConstants.cardBorderWidthFocused,
          ),
          borderRadius:
              BorderRadius.circular(DesignConstants.cardBorderRadius),
        ),
        child: Column(
          children: [
            Semantics(
              label: 'Ikon tambah kendaraan',
              child: Icon(
                Icons.add_circle,
                color: DesignConstants.primaryColor,
                size: DesignConstants.iconSizeXLarge,
              ),
            ),
            const SizedBox(height: DesignConstants.spaceSm),
            Text(
              'Belum ada kendaraan',
              style: DesignConstants.getHeadingStyle(
                fontSize: DesignConstants.fontSizeH4,
              ),
            ),
            const SizedBox(height: DesignConstants.spaceXs),
            Text(
              'Tambahkan kendaraan terlebih dahulu',
              style: DesignConstants.getBodyStyle(
                color: DesignConstants.textTertiary,
              ),
            ),
            const SizedBox(height: DesignConstants.spaceMd),
            Semantics(
              label: 'Tombol tambah kendaraan',
              hint: 'Ketuk untuk menambahkan kendaraan baru',
              button: true,
              child: TextButton(
                onPressed: _navigateToAddVehicle,
                style: TextButton.styleFrom(
                  foregroundColor: DesignConstants.primaryColor,
                  minimumSize: const Size(
                    DesignConstants.minTouchTarget,
                    DesignConstants.minTouchTarget,
                  ),
                ),
                child: Text(
                  'Tambah Kendaraan',
                  style: DesignConstants.getBodyStyle(
                    fontWeight: DesignConstants.fontWeightSemiBold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build vehicle selector button that opens bottom sheet
  Widget _buildVehicleSelector() {
    VehicleModel? matchingVehicle;
    if (widget.selectedVehicle != null) {
      try {
        matchingVehicle = _vehicles.firstWhere(
          (v) => v.idKendaraan == widget.selectedVehicle!.idKendaraan,
        );
      } catch (e) {
        matchingVehicle = null;
      }
    }

    return Semantics(
      label:
          'Pilih kendaraan untuk booking. ${matchingVehicle != null ? "Kendaraan terpilih: ${matchingVehicle.platNomor}, ${matchingVehicle.jenisKendaraan}, ${matchingVehicle.merk} ${matchingVehicle.tipe}" : "Belum ada kendaraan dipilih"}',
      hint: 'Ketuk untuk memilih kendaraan dari daftar kendaraan terdaftar',
      button: true,
      child: InkWell(
        onTap: _showVehicleBottomSheet,
        borderRadius: BorderRadius.circular(DesignConstants.cardBorderRadius),
        child: Container(
          padding: const EdgeInsets.all(DesignConstants.spaceMd),
          decoration: BoxDecoration(
            border: Border.all(
              color: DesignConstants.borderPrimary,
              width: DesignConstants.cardBorderWidth,
            ),
            borderRadius:
                BorderRadius.circular(DesignConstants.cardBorderRadius),
          ),
          child: Row(
            children: [
              Expanded(
                child: matchingVehicle != null
                    ? Row(
                        children: [
                          Icon(
                            _getVehicleIcon(matchingVehicle.jenisKendaraan),
                            color: DesignConstants.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: DesignConstants.spaceMd),
                          Expanded(
                            child: Text(
                              '${matchingVehicle.platNomor} - ${matchingVehicle.merk} ${matchingVehicle.tipe}',
                              style: DesignConstants.getBodyStyle(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Pilih kendaraan Anda',
                        style: DesignConstants.getBodyStyle(
                          color: DesignConstants.textTertiary,
                        ),
                      ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: DesignConstants.primaryColor,
                size: DesignConstants.iconSizeMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom Sheet for vehicle selection
class _VehicleSelectionBottomSheet extends StatelessWidget {
  final List<VehicleModel> vehicles;
  final VehicleModel? selectedVehicle;
  final Function(VehicleModel?) onVehicleSelected;
  final IconData Function(String) getVehicleIcon;

  const _VehicleSelectionBottomSheet({
    Key? key,
    required this.vehicles,
    required this.selectedVehicle,
    required this.onVehicleSelected,
    required this.getVehicleIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(DesignConstants.spaceLg),
            child: Row(
              children: [
                Text(
                  'Pilih Kendaraan',
                  style: DesignConstants.getHeadingStyle(
                    fontSize: DesignConstants.fontSizeH3,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Tutup',
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Vehicle list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(
                vertical: DesignConstants.spaceSm,
              ),
              itemCount: vehicles.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                indent: DesignConstants.spaceLg,
                endIndent: DesignConstants.spaceLg,
              ),
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                final isSelected =
                    selectedVehicle?.idKendaraan == vehicle.idKendaraan;
                
                return _buildVehicleItem(
                  context,
                  vehicle,
                  isSelected,
                );
              },
            ),
          ),
          
          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildVehicleItem(
    BuildContext context,
    VehicleModel vehicle,
    bool isSelected,
  ) {
    final selectedBackgroundColor = const Color(0xFFF5F3FF); // Soft lavender
    
    return Semantics(
      label:
          'Kendaraan ${vehicle.platNomor}, ${vehicle.jenisKendaraan}, ${vehicle.merk} ${vehicle.tipe}${vehicle.isActive ? ", kendaraan aktif" : ""}${isSelected ? ", terpilih" : ""}',
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: () => onVehicleSelected(vehicle),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignConstants.spaceLg,
            vertical: DesignConstants.spaceLg,
          ),
          color: isSelected ? selectedBackgroundColor : Colors.transparent,
          child: Row(
            children: [
              // Vehicle Icon
              Icon(
                getVehicleIcon(vehicle.jenisKendaraan),
                color: isSelected
                    ? DesignConstants.primaryColor
                    : Colors.grey.shade600,
                size: 24,
              ),
              const SizedBox(width: DesignConstants.spaceLg),
              
              // Vehicle Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plat Nomor with Active Badge
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            vehicle.platNomor,
                            style: DesignConstants.getBodyStyle(
                              fontSize: DesignConstants.fontSizeBodyLarge,
                              fontWeight: DesignConstants.fontWeightSemiBold,
                              color: isSelected
                                  ? DesignConstants.primaryColor
                                  : DesignConstants.textPrimary,
                            ),
                          ),
                        ),
                        if (vehicle.isActive) ...[
                          const SizedBox(width: DesignConstants.spaceXs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981), // Green
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Aktif',
                              style: DesignConstants.getBodyStyle(
                                fontSize: 10,
                                fontWeight: DesignConstants.fontWeightSemiBold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Merk, Tipe, Jenis
                    Text(
                      '${vehicle.merk} ${vehicle.tipe}',
                      style: DesignConstants.getBodyStyle(
                        fontSize: DesignConstants.fontSizeBody,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vehicle.jenisKendaraan,
                      style: DesignConstants.getBodyStyle(
                        fontSize: DesignConstants.fontSizeBodySmall,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Checkmark Icon
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: DesignConstants.primaryColor,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}


