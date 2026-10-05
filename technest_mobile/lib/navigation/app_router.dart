import 'package:flutter/material.dart';

import '../screens/auth/login_page.dart';
import '../screens/auth/register_page.dart';
import '../screens/auth/forgot_password_page.dart';
import '../screens/auth/reset_password_page.dart';
import '../screens/home/home_page.dart';
import '../screens/cart/cart_page.dart';
import '../screens/repairs/repair_page.dart';
import '../screens/product/product_details_page.dart';
import '../screens/checkout/checkout_page.dart';
import '../screens/profile/profile_page.dart';
import '../screens/pc_builder/pc_builder_page.dart';
import '../screens/pc_builder/pc_build_summary_page.dart';
import '../screens/agent/ai_build_page.dart';
import 'technest_scaffold.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name ?? '/';
    final routeUri = Uri.parse(routeName);

    switch (routeUri.path) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );

      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );

      case '/forgot-password':
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordPage(),
          settings: settings,
        );

      case '/register':
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
          settings: settings,
        );

      case '/home':
        return MaterialPageRoute(
          builder: (_) =>
              const TechNestScaffold(currentIndex: 0, child: HomePage()),
          settings: settings,
        );

      case '/cart':
        return MaterialPageRoute(
          builder: (_) =>
              const TechNestScaffold(currentIndex: 1, child: CartPage()),
          settings: settings,
        );

      case '/pc-builder':
        return MaterialPageRoute(
          builder: (_) =>
              const TechNestScaffold(currentIndex: 3, child: PcBuilderPage()),
          settings: settings,
        );

      case '/pc-build-summary':
        final buildId = settings.arguments as int;

        return MaterialPageRoute(
          builder: (_) => PcBuildSummaryPage(buildId: buildId),
          settings: settings,
        );

      case '/repair':
        return MaterialPageRoute(
          builder: (_) =>
              const TechNestScaffold(currentIndex: 4, child: RepairPage()),
          settings: settings,
        );

      case '/profile':
        return MaterialPageRoute(
          builder: (_) =>
              const TechNestScaffold(currentIndex: 5, child: ProfilePage()),
          settings: settings,
        );

      case '/product-details':
        final productId = settings.arguments as int;

        return MaterialPageRoute(
          builder: (_) => TechNestScaffold(
            currentIndex: 0,
            child: ProductDetailsPage(productId: productId),
          ),
          settings: settings,
        );

      case '/checkout':
        final arguments = settings.arguments as Map<String, dynamic>;

        return MaterialPageRoute(
          builder: (_) => CheckoutPage(
            items: arguments['items'],
            clearCartAfterOrder: arguments['clearCartAfterOrder'] ?? false,
          ),
          settings: settings,
        );

      case '/ai-chat':
        return MaterialPageRoute(
          builder: (_) =>
              const TechNestScaffold(currentIndex: 2, child: AiBuildPage()),
          settings: settings,
        );

      case '/reset-password':
        String? token = routeUri.queryParameters['token'];

        // Flutter Web hash URLs keep the query inside the fragment.
        if (token == null || token.isEmpty) {
          final fragmentUri = Uri.parse(Uri.base.fragment);
          token = fragmentUri.queryParameters['token'];
        }

        if (token == null || token.isEmpty) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Invalid password reset link')),
            ),
            settings: settings,
          );
        }

        return MaterialPageRoute(
          builder: (_) => ResetPasswordPage(token: token!),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
          settings: settings,
        );
    }
  }
}
