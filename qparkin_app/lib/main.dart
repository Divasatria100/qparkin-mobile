// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'data/services/auth_service.dart';
import 'data/services/parking_service.dart';
import 'data/services/profile_service.dart';
import 'logic/providers/active_parking_provider.dart';
import 'logic/providers/profile_provider.dart';
import 'logic/providers/notification_provider.dart';

import 'presentation/screens/about_page.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/signup_screen.dart';
import 'presentation/screens/home_page.dart';
import 'presentation/screens/map_page.dart';
import 'presentation/screens/activity_page.dart';
import 'presentation/screens/profile_page.dart';
import 'presentation/screens/list_kendaraan.dart';
import 'pages/notification_screen.dart';
import 'pages/scan_screen.dart';
import 'pages/point_screen.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Indonesian locale for date formatting
  await initializeDateFormatting('id_ID', null);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ActiveParkingProvider untuk mengelola state parkir aktif
        ChangeNotifierProvider(
          create: (_) => ActiveParkingProvider(
            parkingService: ParkingService(),
          ),
        ),
        // ProfileProvider untuk mengelola state profil pengguna
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(),
        ),
        // NotificationProvider untuk mengelola state notifikasi
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'QParkin Mobile',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: FutureBuilder(
          future: AuthService().getToken(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            // JIKA SUDAH LOGIN (ada token) -> langsung ke HomePage
            if (snapshot.hasData && snapshot.data != null) {
              return const HomePage();
            }
            
            // JIKA BELUM LOGIN -> tampilkan AboutPage pertama kali
            return const AboutPage();
          },
        ),
        initialRoute: '/about',
        routes: { 
          '/about': (context) => const AboutPage(),
          LoginScreen.routeName: (context) => const LoginScreen(),
          SignUpScreen.routeName: (context) => const SignUpScreen(),
          '/home': (context) => const HomePage(),
          '/map': (context) => const MapPage(),
          '/activity': (context) => const ActivityPage(),
          '/profile': (context) => const ProfilePage(),
          '/list-kendaraan': (context) => const VehicleListPage(),
          '/notifikasi': (context) => const NotificationScreen(),
          '/scan': (context) => const ScanScreen(),
          '/point': (context) => const PointScreen(),
        },
      ),
    );
  }
}

