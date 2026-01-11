import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../../data/models/vehicle_model.dart';
import '../../data/services/vehicle_api_service.dart';
import 'booking_shimmer_loading.dart';
import 'validation_error_text.dart';

/// Widget for selecting a vehicle from the user's registered vehicles
/// Displays a dropdown with vehicle cards showing icons, plat, jenis, and merk
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
  bool _isFocused = false;

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
      debugPrint('[VehicleSelector] Vehicles fetched successfully: ${vehicles.length} vehicles');
      
      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[VehicleSelector] Error fetching vehicles: $e');
      
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
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
    // TODO: Navigate to vehicle registration page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigasi ke halaman tambah kendaraan'),
        backgroundColor: Color(0xFF573ED1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasValidationError = widget.validationError != null && widget.validationError!.isNotEmpty;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: hasValidationError
              ? const Color(0xFFF44336)
              : _isFocused
                  ? const Color(0xFF573ED1)
                  : Colors.transparent,
          width: 2,
        ),
      ),
      color: hasValidationError ? Colors.red.shade50 : Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Kendaraan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            
            if (_isLoading)
              _buildLoadingState()
            else if (_errorMessage != null)
              _buildErrorState()
            else if (_vehicles.isEmpty)
              _buildEmptyState()
            else
              _buildVehicleDropdown(),
            
            // Validation error display
            if (hasValidationError)
              ValidationErrorText(errorText: widget.validationError),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    // Use shimmer loading for better UX
    // Requirements: 13.2
    return Semantics(
      label: 'Memuat daftar kendaraan',
      hint: 'Mohon tunggu, sedang memuat data kendaraan Anda',
      child: const VehicleSelectorShimmer(),
    );
  }

  Widget _buildErrorState() {
    return Semantics(
      label: 'Gagal memuat kendaraan',
      hint: 'Terjadi kesalahan saat memuat data kendaraan. Ketuk tombol coba lagi untuk memuat ulang',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade700,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Gagal memuat kendaraan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Semantics(
            label: 'Tombol coba lagi',
            hint: 'Ketuk untuk memuat ulang data kendaraan',
            button: true,
            child: TextButton(
              onPressed: _fetchVehicles,
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 48),
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
      label: 'Belum ada kendaraan terdaftar. Tambahkan kendaraan terlebih dahulu untuk melanjutkan booking',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Semantics(
              label: 'Ikon tambah kendaraan',
              child: Icon(
                Icons.add_circle,
                color: const Color(0xFF573ED1),
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Belum ada kendaraan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tambahkan kendaraan terlebih dahulu',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Semantics(
              label: 'Tombol tambah kendaraan',
              hint: 'Ketuk untuk menambahkan kendaraan baru',
              button: true,
              child: TextButton(
                onPressed: _navigateToAddVehicle,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF573ED1),
                  minimumSize: const Size(48, 48),
                ),
                child: const Text(
                  'Tambah Kendaraan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleDropdown() {
    // Debug: Log vehicles and selected vehicle
    debugPrint('[VehicleSelector] Building dropdown with ${_vehicles.length} vehicles');
    if (widget.selectedVehicle != null) {
      debugPrint('[VehicleSelector] Selected vehicle ID: ${widget.selectedVehicle!.idKendaraan}');
      debugPrint('[VehicleSelector] Selected vehicle plat: ${widget.selectedVehicle!.platNomor}');
    }
    
    // Find matching vehicle in list by ID (not by instance)
    VehicleModel? matchingVehicle;
    if (widget.selectedVehicle != null) {
      try {
        matchingVehicle = _vehicles.firstWhere(
          (v) => v.idKendaraan == widget.selectedVehicle!.idKendaraan,
        );
        debugPrint('[VehicleSelector] Found matching vehicle: ${matchingVehicle.platNomor}');
      } catch (e) {
        debugPrint('[VehicleSelector] No matching vehicle found in list');
        matchingVehicle = null;
      }
    }
    
    return Semantics(
      label: 'Pilih kendaraan untuk booking. ${matchingVehicle != null ? "Kendaraan terpilih: ${matchingVehicle.platNomor}, ${matchingVehicle.jenisKendaraan}, ${matchingVehicle.merk} ${matchingVehicle.tipe}" : "Belum ada kendaraan dipilih"}',
      hint: 'Ketuk untuk memilih kendaraan dari daftar kendaraan terdaftar',
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _isFocused = hasFocus;
          });
        },
        child: DropdownButtonFormField<VehicleModel>(
          value: matchingVehicle, // Use matching vehicle from list, not the passed one
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF573ED1),
                width: 2,
              ),
            ),
          ),
          hint: const Text('Pilih kendaraan Anda'),
          isExpanded: true,
          items: _vehicles.map((vehicle) {
            return DropdownMenuItem<VehicleModel>(
              value: vehicle,
              child: Semantics(
                label: 'Kendaraan ${vehicle.platNomor}, ${vehicle.jenisKendaraan}, ${vehicle.merk} ${vehicle.tipe}',
                child: _buildVehicleItem(vehicle),
              ),
            );
          }).toList(),
          onChanged: (VehicleModel? newValue) {
            debugPrint('[VehicleSelector] Vehicle selected: ${newValue?.platNomor}');
            widget.onVehicleSelected(newValue);
            if (newValue != null) {
              // Announce selection to screen reader
              SemanticsService.announce(
                'Kendaraan ${newValue.platNomor} dipilih',
                TextDirection.ltr,
              );
            }
          },
          selectedItemBuilder: (BuildContext context) {
            return _vehicles.map((vehicle) {
              return _buildVehicleItem(vehicle);
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _buildVehicleItem(VehicleModel vehicle) {
    // Simplified single-line layout to avoid overflow
    return Row(
      children: [
        Icon(
          _getVehicleIcon(vehicle.jenisKendaraan),
          color: const Color(0xFF573ED1),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '${vehicle.platNomor} - ${vehicle.merk} ${vehicle.tipe}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
