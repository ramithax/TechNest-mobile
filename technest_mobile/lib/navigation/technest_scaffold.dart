import 'package:flutter/material.dart';

import '../widgets/bottom_nav_bar.dart';

class TechNestScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const TechNestScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  void _navigate(BuildContext context, int index) {
    String? route;

    switch (index) {
      case 0:
        route = '/home';
        break;
      case 1:
        route = '/cart';
        break;
      case 2:
        route = '/ai-chat';
        break;
      case 3:
        route = '/pc-builder';
        break;
      case 4:
        route = '/repair';
        break;
      case 5:
        route = '/profile';
        break;
      default:
        return;
    }

    if (ModalRoute.of(context)?.settings.name == route) {
      return;
    }

    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: TechNestBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          _navigate(context, index);
        },
      ),
    );
  }
}
