import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<dynamic> navigateTo(String routeName) {
    return navigatorKey.currentState!.pushNamed(routeName);
  }

  static Future<dynamic> navigateToReplacement(Widget screen) {
    return navigatorKey.currentState!.pushReplacement(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  static void goBack() {
    return navigatorKey.currentState!.pop();
  }
}
