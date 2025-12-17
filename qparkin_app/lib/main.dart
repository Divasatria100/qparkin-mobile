// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/services/auth_service.dart';
import 'data/services/parking_service.dart';
import 'data/services/point_service.dart';
import 'logic/providers/active_parking_provider.dart';
import 'logic/providers/profile_provider.dart';
import 'logic/providers/notification_provider.dart';
import 'logic/providers/point_provider.dart';
import 'presentation/screens/about_page.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/signup_screen.dart';
import 'presentation/screens/home_page.dart';
import 'presentation/screens/map_page.dart';
import 'presentation/screens/activity_page.dart';
import 'presentation/screens/profile_page.dart';
import 'presentation/screens/list_kendaraan.dart';
import 'presentation/screens/point_page.dart';
import 'presentation/screens/notification_screen.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Indonesian locale for date formatting
  await initializeDateFormatting('id_ID', null);
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // NotificationProvider - Created first so other providers can depend on it
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
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
        // PointProvider untuk mengelola state poin pengguna
        ChangeNotifierProxyProvider<NotificationProvider, PointProvider>(
          create: (context) => PointProvider(
            pointService: PointService(),
            notificationProvider: context.read<NotificationProvider>(),
            prefs: prefs,
          ),
          update: (context, notificationProvider, previousPointProvider) =>
              previousPointProvider ??
              PointProvider(
                pointService: PointService(),
                notificationProvider: notificationProvider,
                prefs: prefs,
              ),
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
          '/point': (context) => const PointPage(),
          '/notifikasi': (context) => const NotificationScreen(),
        },
      ),
    );
  }
}

