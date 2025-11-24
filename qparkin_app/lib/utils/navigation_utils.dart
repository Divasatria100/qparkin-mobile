import 'package:flutter/material.dart';

class NavigationUtils {
  static const Map<int, String> routes = {
    0: '/home',
    1: '/activity',
    2: '/map',
    // 3: '/notifications', // TODO: Add notifications page route when implemented
    // 4: '/profile', // TODO: Add profile page route when implemented
  };

  static void handleNavigation(BuildContext context, int tappedIndex, int currentIndex) {
    if (tappedIndex == currentIndex) return; // No navigation if already on the page
    final route = routes[tappedIndex];
    if (route != null) {
      Navigator.pushNamed(context, route);
    } else {
      // Handle unimplemented routes, e.g., show a snackbar or do nothing
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Feature not implemented yet')),
      );
    }
  }
}
