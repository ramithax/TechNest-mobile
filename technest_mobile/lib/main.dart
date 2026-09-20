import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/login_page.dart';

void main() {
  runApp(const TechNestApp());
}

class TechNestApp extends StatelessWidget {
  const TechNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TechNest',
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
    );
  }
}
