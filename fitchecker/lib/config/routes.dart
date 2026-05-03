import 'package:flutter/material.dart';
import '../config/constants.dart';

class FadeSlideRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeSlideRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: AppConstants.pageTransition,
          reverseTransitionDuration: AppConstants.pageTransition,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(0.0, 0.05),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ));

            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ));

            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: offsetAnimation,
                child: child,
              ),
            );
          },
        );
}

class AppRoutes {
  static const String login = '/login';
  static const String userSelection = '/user-selection';
  static const String addPerson = '/add-person';
  static const String home = '/home';
  static const String upload = '/upload';
  static const String result = '/result';
  static const String profile = '/profile';
}
