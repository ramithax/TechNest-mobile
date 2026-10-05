import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
          'Privacy Policy',
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
              _buildLastUpdated(),
              const SizedBox(height: 20),
              _buildIntro(),
              const SizedBox(height: 20),
              _buildSection(
                number: '1',
                title: 'Information We Collect',
                content:
                    'We collect information you provide directly to us, including:\n\n'
                    '• Personal information (name, email, phone number, shipping address)\n'
                    '• Payment information (processed securely through our payment partners)\n'
                    '• Account credentials (encrypted passwords)\n'
                    '• Order history and preferences\n'
                    '• Communication records when you contact our support team',
              ),
              const SizedBox(height: 16),
              _buildSection(
                number: '2',
                title: 'How We Use Your Information',
                content:
                    'We use the information we collect to:\n\n'
                    '• Process and fulfill your orders\n'
                    '• Send you order confirmations and updates\n'
                    '• Provide customer support and respond to inquiries\n'
                    '• Improve our services and user experience\n'
                    '• Send promotional communications (with your consent)\n'
                    '• Prevent fraud and ensure platform security',
              ),
              const SizedBox(height: 16),
              _buildSection(
                number: '3',
                title: 'Information Sharing',
                content:
                    'We do not sell your personal information. We may share your information with:\n\n'
                    '• Service providers who assist in our operations (payment processors, delivery partners)\n'
                    '• Legal authorities when required by law\n'
                    '• Business partners in connection with a merger or acquisition\n\n'
                    'All third-party service providers are bound by confidentiality agreements.',
              ),
              const SizedBox(height: 16),
              _buildSection(
                number: '4',
                title: 'Data Security',
                content:
                    'We implement industry-standard security measures to protect your information:\n\n'
                    '• Encryption of sensitive data during transmission\n'
                    '• Secure storage of personal information\n'
                    '• Regular security audits and updates\n'
                    '• Access controls and authentication protocols\n\n'
                    'However, no method of transmission over the Internet is 100% secure.',
              ),
              const SizedBox(height: 16),
              _buildSection(
                number: '5',
                title: 'Your Rights',
                content:
                    'You have the right to:\n\n'
                    '• Access your personal information\n'
                    '• Correct inaccurate data\n'
                    '• Request deletion of your account and data\n'
                    '• Opt-out of marketing communications\n'
                    '• Request a copy of your data\n\n'
                    'To exercise these rights, contact us at privacy@technest.com',
              ),
              const SizedBox(height: 16),
              _buildSection(
                number: '6',
                title: 'Cookies and Tracking',
                content:
                    'We use cookies and similar technologies to:\n\n'
                    '• Remember your preferences\n'
                    '• Analyze usage patterns\n'
                    '• Improve our services\n'
                    '• Provide personalized experiences\n\n'
                    'You can control cookie settings through your browser preferences.',
              ),
              const SizedBox(height: 16),
              _buildSection(
                number: '7',
                title: 'Children\'s Privacy',
                content: 'Our services are not intended for children under 18 years of age. We do not knowingly collect personal information from children. If we become aware that we have collected data from a child, we will delete it immediately.',
              ),
              const SizedBox(height: 16),
              _buildSection(
                number: '8',
                title: 'Changes to This Policy',
                content: 'We may update this privacy policy from time to time. We will notify you of any significant changes by posting a notice on our platform or sending you an email. Your continued use of our services after changes constitutes acceptance of the updated policy.',
              ),
              const SizedBox(height: 16),
              _buildSection(
                number: '9',
                title: 'Contact Us',
                content:
                    'If you have questions about this privacy policy or our data practices, please contact us:\n\n'
                    'Email: privacy@technest.com\n'
                    'Phone: +94 11 234 5678\n'
                    'Address: 123 Tech Street, Colombo, Sri Lanka',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastUpdated() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.update_outlined, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Last updated: January 2026',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        'This Privacy Policy describes how TechNest ("we", "us", or "our") collects, uses, and protects your personal information when you use our website and services. By using TechNest, you agree to the collection and use of information in accordance with this policy.',
        style: TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildSection({
    required String number,
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
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
}
