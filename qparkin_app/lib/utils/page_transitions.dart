import 'package:flutter/material.dart';

/// Custom page transitions for consistent navigation experience
/// Provides slide transitions with configurable direction and duration
class PageTransitions {
  /// Default transition duration (300ms for consistency)
  static const Duration defaultDuration = Duration(milliseconds: 300);

  /// Creates a slide transition route from right to left (forward navigation)
  /// 
  /// This is the standard transition for navigating to a new page
  /// 
  /// Example:
  /// ```dart
  /// Navigator.of(context).push(
  ///   PageTransitions.slideFromRight(
  ///     page: EditProfilePage(),
  ///   ),
  /// );
  /// ```
  static Route<T> slideFromRight<T>({
    required Widget page,
    Duration duration = defaultDuration,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Slide from right to left
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
    );
  }

  /// Creates a slide transition route from left to right (backward navigation)
  /// 
  /// This can be used for navigating back or to a previous context
  static Route<T> slideFromLeft<T>({
    required Widget page,
    Duration duration = defaultDuration,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Slide from left to right
        const begin = Offset(-1.0, 0.0);
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
    );
  }

  /// Creates a slide transition route from bottom to top
  /// 
  /// Useful for modal-like pages or detail views
  static Route<T> slideFromBottom<T>({
    required Widget page,
    Duration duration = defaultDuration,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Slide from bottom to top
        const begin = Offset(0.0, 1.0);
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
    );
  }

  /// Creates a fade transition route
  /// 
  /// Useful for subtle transitions or overlay pages
  static Route<T> fade<T>({
    required Widget page,
    Duration duration = defaultDuration,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// Creates a scale transition route
  /// 
  /// Useful for dialog-like pages or emphasis
  static Route<T> scale<T>({
    required Widget page,
    Duration duration = defaultDuration,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;
        var tween = Tween(begin: 0.8, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return ScaleTransition(
          scale: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}
