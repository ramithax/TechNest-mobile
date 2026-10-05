import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About TechNest',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSection(
                icon: Icons.lightbulb_outline,
                title: 'Our Mission',
                content: 'At TechNest, we believe everyone deserves access to quality technology. Our mission is to provide a seamless platform where customers can find the best computer parts, build their dream PCs, and get expert repair services—all in one place.',
              ),
              const SizedBox(height: 20),
              _buildSection(
                icon: Icons.store_outlined,
                title: 'What We Offer',
                content:
                    '• Wide selection of computer components from trusted brands\n'
                    '• Custom PC building service with expert guidance\n'
                    '• Professional repair and maintenance services\n'
                    '• Competitive prices and regular deals\n'
                    '• Fast and reliable delivery across the country',
              ),
              const SizedBox(height: 20),
              _buildSection(
                icon: Icons.people_outline,
                title: 'Our Team',
                content: 'We are a passionate team of tech enthusiasts, engineers, and customer service experts dedicated to helping you find the perfect technology solutions. With years of experience in the industry, we understand what our customers need.',
              ),
              const SizedBox(height: 20),
              _buildSection(
                icon: Icons.verified_outlined,
                title: 'Why Choose Us',
                content:
                    '✓ Quality guaranteed products\n'
                    '✓ Expert technical support\n'
                    '✓ Secure payment options\n'
                    '✓ Easy returns and exchanges\n'
                    '✓ Transparent pricing with no hidden fees',
              ),
              const SizedBox(height: 30),
              _buildContactCard(),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'TechNest v1.0.0',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.computer_outlined,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'TechNest',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your Trusted Technology Partner',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.headset_mic_outlined, color: Colors.white, size: 28),
          const SizedBox(height: 12),
          const Text(
            'Get in Touch',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Have questions? We are here to help!',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 16),
          _buildContactRow(Icons.email_outlined, 'support@technest.com'),
          const SizedBox(height: 8),
          _buildContactRow(Icons.phone_outlined, '+94 11 234 5678'),
          const SizedBox(height: 8),
          _buildContactRow(Icons.location_on_outlined, 'Colombo, Sri Lanka'),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontSize: 13, color: Colors.white)),
      ],
    );
  }
}
