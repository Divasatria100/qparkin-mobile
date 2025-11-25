import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/bottom_nav.dart';
import '/utils/navigation_utils.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  late TabController _tabController;

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
        backgroundColor: Color(0xFF573ED1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Peta'),
                Tab(text: 'Daftar'),
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
                // Map View
                Stack(
                  children: [
                    Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Text(
                          'Peta akan ditampilkan di sini',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton(
                        onPressed: () {},
                        backgroundColor: Color(0xFF573ED1),
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.white,
                        ),
                        tooltip: 'Tampilkan Lokasi Saya',
                      ),
                    ),
                  ],
                ),
                // List View
                Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: const Text(
                          'Lokasi Terdekat',
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
                          itemCount: nearbyLocations.length,
                          itemBuilder: (context, index) {
                            final location = nearbyLocations[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
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
                                      child: Icon(
                                        Icons.local_parking,
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
                                            location['name'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            location['address'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    size: 16,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    location['distance'],
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              ElevatedButton.icon(
                                                onPressed: () {},
                                                icon: const Icon(
                                                  Icons.navigation,
                                                  size: 16,
                                                ),
                                                label: const Text('Lihat Rute'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Color(0xFF573ED1),
                                                  foregroundColor: Colors.white,
                                                  elevation: 0,
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
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
        index: 2,
        onTap: (index) => NavigationUtils.handleNavigation(context, index, 2),
      ),
    );
  }
}
