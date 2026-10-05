import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../auth/login_page.dart';
import '../order/my_orders_page.dart';
import '../repairs/my_repairs_page.dart';
import '../pc_builder/pc_build_history_page.dart';
import '../settings/settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();

  String _username = 'User';
  String _email = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _getUserFromToken();

      if (!mounted) return;

      setState(() {
        _username = user['username'] ?? 'User';
        _email = user['email'] ?? '';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  Future<Map<String, String>> _getUserFromToken() async {
    final token = await _authService.getAccessToken();

    if (token == null || token.isEmpty) {
      return {};
    }

    final parts = token.split('.');

    if (parts.length != 3) {
      return {};
    }

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final payloadMap = jsonDecode(decoded);

    final username =
        payloadMap['unique_name'] ??
        payloadMap['name'] ??
        payloadMap['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] ??
        payloadMap['preferred_username'];

    final email =
        payloadMap['email'] ??
        payloadMap['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'];

    return {
      'username': username?.toString() ?? 'User',
      'email': email?.toString() ?? '',
    };
  }

  Future<void> _logout() async {
    await _authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _openSettings() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const SettingsPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            children: [
              const SizedBox(height: 10),

              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: Center(
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _username.isNotEmpty
                              ? _username[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                _loading ? 'Loading...' : _username,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),

              if (_email.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  _email,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],

              const SizedBox(height: 30),

              _buildSectionTitle('Account'),

              const SizedBox(height: 10),

              _buildMenuItem(
                icon: Icons.shopping_bag_outlined,
                title: 'My Orders',
                subtitle: 'View your orders and delivery status',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyOrdersPage()),
                  );
                },
              ),

              _buildMenuItem(
                icon: Icons.build_outlined,
                title: 'Repair Requests',
                subtitle: 'View your repair requests',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyRepairsPage()),
                  );
                },
              ),

              _buildMenuItem(
                icon: Icons.computer_outlined,
                title: 'My PC Builds',
                subtitle: 'View your saved PC builds',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PcBuildHistoryPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('Other'),

              const SizedBox(height: 10),

              _buildMenuItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                subtitle: 'Manage your account and preferences',
                onTap: _openSettings,
              ),

              const SizedBox(height: 20),

              _buildMenuItem(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out of your account',
                isLogout: true,
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    final Color itemColor = isLogout ? Colors.red : AppColors.textPrimary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isLogout
                        ? Colors.red.withValues(alpha: 0.10)
                        : AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isLogout ? Colors.red : AppColors.primary,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: itemColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
