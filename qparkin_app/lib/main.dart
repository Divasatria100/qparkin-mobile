// lib/main.dart
import 'package:flutter/material.dart';
import 'data/services/auth_service.dart'; // Add this import
// import 'package:get/get.dart';

import 'presentation/screens/about_page.dart';
import 'presentation/screens/login_page.dart';
// import 'presentation/screens/signup_page.dart';
// import 'presentation/screens/forgot_password_page.dart';
// import 'presentation/screens/verify_code_page.dart';
// import 'presentation/screens/confirm_pin_page.dart';
// import 'presentation/screens/change_pin_page.dart';
import 'presentation/screens/home_page.dart';
import 'presentation/screens/map_page.dart';
import 'presentation/screens/activity_page.dart';
import 'presentation/screens/scan_page.dart';
import 'presentation/widgets/bottom_nav.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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

          // JIKA SUDAH LOGIN (ada token) -> langsung ke MainNavigationPage
          if (snapshot.hasData && snapshot.data != null) {
            return const MainNavigationPage();
          }

          // JIKA BELUM LOGIN -> tampilkan AboutPage pertama kali
          return const AboutPage();
        },
      ),
      initialRoute: '/about',
      routes: {
        '/about': (context) => const AboutPage(),
        '/login': (context) => const LoginPage(),
        // '/signup': (context) => const SignupPage(),
        // '/forgot-password': (context) => const ForgotPasswordPage(),
        // '/verify-code': (context) => const VerifyCodePage(),
        // '/confirm-pin': (context) => const ConfirmPinPage(),
        // '/change-pin': (context) => const ChangePinPage(),
        '/home': (context) => const HomePage(),
        '/map': (context) => const MapPage(),
        '/activity': (context) => const ActivityPage(),
        '/scan': (context) => const ScanPage(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 700),
            );
          case '/activity':
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const ActivityPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            );
          case '/scan':
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const ScanPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            );
          case '/map':
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const MapPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            );
          default:
            return null;
        }
      },
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  late PageController _pageController;
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ActivityPage(),
    const ScanPage(),
    const MapPage(),
    // Placeholder for notifications/profile if needed
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onNavBarTapped(int index) {
    if (index != _currentIndex) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe, only use nav bar
        children: _pages,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        onTap: _onNavBarTapped,
      ),
    );
  }
}

