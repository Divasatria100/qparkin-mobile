// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/services/auth_service.dart';
import 'data/services/parking_service.dart';
import 'data/services/point_service.dart';
import 'logic/providers/active_parking_provider.dart';
import 'logic/providers/point_provider.dart';
import 'logic/providers/notification_provider.dart';

import 'presentation/screens/about_page.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/signup_screen.dart';
import 'presentation/screens/home_page.dart';
import 'presentation/screens/map_page.dart';
import 'presentation/screens/activity_page.dart';
import 'presentation/screens/point_page.dart';
import 'pages/notification_screen.dart';
import 'pages/scan_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // NotificationProvider untuk mengelola notifikasi dan badge
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
        // ActiveParkingProvider untuk mengelola state parkir aktif
        ChangeNotifierProvider(
          create: (_) => ActiveParkingProvider(
            parkingService: ParkingService(),
          ),
        ),
        // PointProvider untuk mengelola state poin reward
        ChangeNotifierProxyProvider<NotificationProvider, PointProvider>(
          create: (context) => PointProvider(
            pointService: PointService(),
            notificationProvider: context.read<NotificationProvider>(),
          ),
          update: (context, notificationProvider, previous) =>
              previous ?? PointProvider(
                pointService: PointService(),
                notificationProvider: notificationProvider,
              ),
        ),
        // Tambahkan provider lain di sini jika diperlukan
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
        routes: {
          '/about': (context) => const AboutPage(),
          LoginScreen.routeName: (context) => const LoginScreen(),
          SignUpScreen.routeName: (context) => const SignUpScreen(),
          '/home': (context) => const HomePage(),
          '/map': (context) => const MapPage(),
          '/activity': (context) => const ActivityPage(),
          '/notifikasi': (context) => const NotificationScreen(),
          '/scan': (context) => const ScanScreen(),
          '/point': (context) => const PointPage(),
        },
      ),
    );
  }
}

