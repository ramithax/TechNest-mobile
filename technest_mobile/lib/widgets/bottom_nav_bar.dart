import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class TechNestBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const TechNestBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 22),
            activeIcon: Icon(Icons.home, size: 22),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined, size: 22),
            activeIcon: Icon(Icons.shopping_bag, size: 22),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline, size: 22),
            activeIcon: Icon(Icons.chat_bubble, size: 22),
            label: 'AI Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border, size: 22),
            activeIcon: Icon(Icons.favorite, size: 22),
            label: 'Pc Builder',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_outlined, size: 22),
            activeIcon: Icon(Icons.build, size: 22),
            label: 'Repair',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 22),
            activeIcon: Icon(Icons.person, size: 22),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
