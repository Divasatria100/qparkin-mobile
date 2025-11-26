import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '/utils/navigation_utils.dart';
import 'booking_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  late TabController _tabController;
  int? _selectedMallIndex;
  Map<String, dynamic>? _selectedMall;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['initialTab'] == 1) {
        _tabController.animateTo(1);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _selectMall(int index) {
    setState(() {
      _selectedMallIndex = index;
      _selectedMall = nearbyLocations[index];
    });
  }

  void _showRouteOnMap(Map<String, dynamic> mall) {
    setState(() {
      _selectedMall = mall;
    });
    _tabController.animateTo(0); // Switch to map tab
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

  final List<Map<String, dynamic>> nearbyLocations = [
    {
      'name': 'Mega Mall Batam Centre',
      'distance': '1.3 km',
      'address': 'Jl. Engku Putri no.1, Batam Centre',
      'available': 45,
    },
    {
      'name': 'One Batam Mall',
      'distance': '1.5 km',
      'address': 'Jl. Raja H. Fisabilillah No. 9, Batam Center',
      'available': 32,
    },
    {
      'name': 'SNL Food Bengkong',
      'distance': '7 km',
      'address': 'Garden Avenue Square, Bengkong, Batam',
      'available': 18,
    },
    {
      'name': 'Mall Plaza Indonesia',
      'distance': '2.2 km',
      'address': 'Jl. MH Thamrin, Jakarta Pusat',
      'available': 28,
    },
    {
      'name': 'Grand Indonesia Mall',
      'distance': '3.0 km',
      'address': 'Jl. MH Thamrin No.1, Jakarta Pusat',
      'available': 50,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Peta Lokasi Parkir',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF573ED1),
        elevation: 0,
      ),
      body: Column(
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
      bottomNavigationBar: CurvedNavigationBar(
        index: 2,
        onTap: (index) => NavigationUtils.handleNavigation(context, index, 2),
      ),
    );
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        // Map placeholder
        Container(
          color: Colors.grey.shade200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedMall != null
                      ? 'Menampilkan rute ke\n${_selectedMall!['name']}'
                      : 'Peta akan ditampilkan di sini',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // My Location Button
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Menampilkan lokasi Anda'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            backgroundColor: const Color(0xFF573ED1),
            child: const Icon(
              Icons.my_location,
              color: Colors.white,
            ),
          ),
        ),
        
        // Selected Mall Info Card (if mall is selected)
        if (_selectedMall != null)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF573ED1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFF573ED1),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedMall!['name'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_selectedMall!['distance']} dari lokasi Anda',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        setState(() {
                          _selectedMall = null;
                          _selectedMallIndex = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMallListView() {
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
              itemCount: nearbyLocations.length,
              itemBuilder: (context, index) {
                final mall = nearbyLocations[index];
                final isSelected = _selectedMallIndex == index;
                
                return Column(
                  children: [
                    _buildMallCard(mall, index, isSelected),
                    
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
                      ? const Color(0xFF573ED1).withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: isSelected ? 12 : 8,
                  offset: const Offset(0, 2),
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
    );
  }
}
