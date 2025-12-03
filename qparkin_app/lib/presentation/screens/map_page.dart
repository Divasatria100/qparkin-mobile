import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/map_view.dart';
import '/utils/navigation_utils.dart';
import '/utils/map_error_utils.dart';
import '/logic/providers/map_provider.dart';
import '/data/models/mall_model.dart';
import '/data/services/location_service.dart';
import '/data/services/route_service.dart';
import 'booking_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late MapProvider _mapProvider;
  int? _selectedMallIndex;
  Map<String, dynamic>? _selectedMall;
  bool _isMapFocusMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize MapProvider
    // The provider maintains state across device rotations because it's
    // stored in the State object, which persists across configuration changes
    // Requirements: 6.5
    _mapProvider = MapProvider();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['initialTab'] == 1) {
        _tabController.animateTo(1);
      }
    });
  }

  void _toggleMapFocusMode() {
    setState(() {
      _isMapFocusMode = !_isMapFocusMode;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mapProvider.dispose();
    super.dispose();
  }

  Future<void> _selectMall(int index) async {
    // Get the mall from MapProvider's mall list
    final mall = _mapProvider.malls[index];
    
    setState(() {
      _selectedMallIndex = index;
      _selectedMall = {
        'name': mall.name,
        'distance': '', // Will be calculated by MapProvider
        'address': mall.address,
        'available': mall.availableSlots,
      };
    });
    
    try {
      // Use MapProvider to select the mall
      await _mapProvider.selectMall(mall);
      
      // Automatically switch to map tab
      _tabController.animateTo(0);
    } catch (e) {
      debugPrint('[MapPage] Error selecting mall: $e');
      
      // Maintain app stability - still switch to map tab
      // The mall will be selected, just without route
      _tabController.animateTo(0);
      
      // Show error if it's a route calculation issue
      if (e is RouteCalculationException || e is NetworkException) {
        if (mounted) {
          MapErrorUtils.showRouteCalculationError(
            context,
            onRetry: () async {
              await _selectMall(index);
            },
          );
        }
      }
    }
  }

  Future<void> _showRouteOnMap(Map<String, dynamic> mallData) async {
    setState(() {
      _selectedMall = mallData;
    });
    
    // Find the corresponding MallModel from MapProvider
    final mall = _mapProvider.malls.firstWhere(
      (m) => m.name == mallData['name'],
      orElse: () => _mapProvider.malls.first,
    );
    
    try {
      // Use MapProvider to select the mall (this will trigger route calculation)
      await _mapProvider.selectMall(mall);
      
      // Switch to map tab and activate focus mode
      _tabController.animateTo(0);
      
      // Activate map focus mode after a short delay to ensure tab switch completes
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        setState(() {
          _isMapFocusMode = true;
        });
      }
    } on RouteCalculationException catch (_) {
      // Show route calculation error snackbar
      if (mounted) {
        MapErrorUtils.showRouteCalculationError(
          context,
          onRetry: () async {
            await _showRouteOnMap(mallData);
          },
        );
      }
      
      // Still switch to map tab and activate focus mode to show the mall
      _tabController.animateTo(0);
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        setState(() {
          _isMapFocusMode = true;
        });
      }
    } on NetworkException catch (_) {
      // Show network error banner
      if (mounted) {
        MapErrorUtils.showNetworkErrorBanner(
          context,
          onRetry: () async {
            await _showRouteOnMap(mallData);
          },
        );
      }
      
      // Still switch to map tab and activate focus mode to show the mall
      _tabController.animateTo(0);
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        setState(() {
          _isMapFocusMode = true;
        });
      }
    } catch (e) {
      debugPrint('[MapPage] Error showing route: $e');
      
      // Show general error
      if (mounted) {
        MapErrorUtils.showGeneralError(
          context,
          message: 'Gagal menampilkan rute',
          onRetry: () async {
            await _showRouteOnMap(mallData);
          },
        );
      }
      
      // Still switch to map tab and activate focus mode to show the mall
      _tabController.animateTo(0);
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        setState(() {
          _isMapFocusMode = true;
        });
      }
    }
  }

  void _navigateToBooking() {
    if (_selectedMall != null) {
      // Navigate to BookingPage with selected mall data and page transition animation
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => BookingPage(
            mall: _selectedMall!,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Slide transition from right to left
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MapProvider>.value(
      value: _mapProvider,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          leading: _isMapFocusMode
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: _toggleMapFocusMode,
                  tooltip: 'Kembali',
                )
              : null,
          title: Text(
            _isMapFocusMode ? 'Mode Fokus Peta' : 'Peta Lokasi Parkir',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF573ED1),
          elevation: 0,
        ),
        body: _isMapFocusMode
            ? _buildFullScreenMapView()
            : Column(
                children: [
                  // Tab Bar
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(
                          icon: Icon(Icons.map, size: 20),
                          text: 'Peta',
                        ),
                        Tab(
                          icon: Icon(Icons.list, size: 20),
                          text: 'Daftar Mall',
                        ),
                      ],
                      indicatorColor: const Color(0xFF573ED1),
                      labelColor: const Color(0xFF573ED1),
                      unselectedLabelColor: Colors.grey,
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Map View
                        _buildMapView(),
                        
                        // Tab 2: Mall List View
                        _buildMallListView(),
                      ],
                    ),
                  ),
                ],
              ),
        bottomNavigationBar: _isMapFocusMode
            ? null
            : CurvedNavigationBar(
                index: 2,
                onTap: (index) => NavigationUtils.handleNavigation(context, index, 2),
              ),
      ),
    );
  }

  Widget _buildMapView() {
    // Use MapView widget that consumes MapProvider with blur overlay
    return Stack(
      children: [
        const MapView(),
        
        // Blur overlay with tap to activate
        Positioned.fill(
          child: GestureDetector(
            onTap: _toggleMapFocusMode,
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.touch_app,
                                size: 48,
                                color: const Color(0xFF573ED1),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Ketuk untuk Melihat Peta',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF573ED1),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sentuh untuk Berinteraksi',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
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
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFullScreenMapView() {
    // Full screen map view without overlay
    return const MapView();
  }

  Widget _buildMallListView() {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, child) {
        // Show loading state while malls are being loaded
        if (mapProvider.malls.isEmpty && mapProvider.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF573ED1)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Memuat daftar mall...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        // Show error state if there's an error
        if (mapProvider.malls.isEmpty && mapProvider.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal memuat daftar mall',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mapProvider.errorMessage ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          color: Colors.grey.shade50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Mall',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ketuk mall untuk memilih lokasi parkir',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Mall List with Booking Button
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  itemCount: mapProvider.malls.length,
                  itemBuilder: (context, index) {
                    final mall = mapProvider.malls[index];
                    final isSelected = _selectedMallIndex == index;
                    
                    // Convert MallModel to Map for compatibility with existing card
                    final mallData = {
                      'name': mall.name,
                      'distance': '', // Distance will be calculated
                      'address': mall.address,
                      'available': mall.availableSlots,
                    };
                    
                    return Column(
                      children: [
                        _buildMallCard(mallData, index, isSelected),
                        
                        // Booking Button appears right after selected card
                        if (isSelected)
                          _buildBookingButton(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookingButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      child: TweenAnimationBuilder<double>(
        key: ValueKey(_selectedMallIndex), // Reset animation when mall changes
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          // Clamp values to ensure they're within valid ranges
          final clampedScale = value.clamp(0.0, 2.0); // Allow scale up to 2.0 for bounce effect
          final clampedOpacity = value.clamp(0.0, 1.0); // Ensure opacity is between 0.0 and 1.0
          
          return Transform.scale(
            scale: clampedScale,
            child: Opacity(
              opacity: clampedOpacity,
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF573ED1),
                Color(0xFF6B4FE0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF573ED1).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _navigateToBooking,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.event_available,
                      size: 24,
                      color: Colors.white,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Booking Sekarang',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMallCard(Map<String, dynamic> mall, int index, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(isSelected ? 1.02 : 1.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectMall(index),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected 
                      ? const Color(0xFF573ED1) 
                      : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFF573ED1).withOpacity(0.2)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: isSelected ? 16 : 8,
                    offset: Offset(0, isSelected ? 4 : 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF573ED1)
                            : const Color(0xFF573ED1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.local_parking,
                        color: isSelected ? Colors.white : const Color(0xFF573ED1),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Mall Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mall['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected 
                                  ? const Color(0xFF573ED1) 
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                mall['distance'],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Selection Indicator
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF573ED1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Address
                Text(
                  mall['address'],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 12),
                
                // Bottom Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Available Slots
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${mall['available']} slot tersedia',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Route Button
                    TextButton.icon(
                      onPressed: () => _showRouteOnMap(mall),
                      icon: const Icon(
                        Icons.navigation,
                        size: 16,
                      ),
                      label: const Text('Rute'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF573ED1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
