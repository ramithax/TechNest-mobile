import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

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
          'Terms & Conditions',
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
                title: 'Acceptance of Terms',
                content: 'By accessing or using TechNest services, you agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use our services. We reserve the right to modify these terms at any time, and your continued use constitutes acceptance of any changes.',
              ),
              const SizedBox(height: 16),
              _buildSection(
                number: '2',
                title: 'User Accounts',
                content:
                    'To use certain features, you must create an account. You agree to:\n\n'
                    '• Provide accurate and complete information\n'
                    '• Maintain the security of your password\n'
                    '• Accept all risks of unauthorized access to your account\n'
                    '• Notify us immediately of any security breaches\n'
                    '• Not share your account credentials with others\n\n'
                    'We reserve the right to suspend or terminate accounts that violate these terms.',
              ),
              const SizedBox(height: 16),
              _buildSection(
                number: '3',
                title: 'Products and Services',
                content:
                    'TechNest provides computer parts, PC building services, and repair services. We reserve the right to:\n\n'
                    '• Modify product descriptions and pricing without notice\n'
                    '• Limit quantities or refuse service to anyone\n'
                    '• Discontinue products or services at any time\n'
                    '• Correct errors in product information\n\n'
                    'Product images are for illustration purposes only. Actual products may vary slightly.',
              ),
              const SizedBox(height: 16),
              _buildSection(
                number: '4',
                title: 'Orders and Payment',
                content:
                    'When placing an order, you agree to:\n\n'
                    '• Provide accurate billing and shipping information\n'
                    '• Pay all charges at the prices quoted\n'
                    '• Accept responsibility for all orders made through your account\n'
                    '• Comply with all applicable laws and regulations\n\n'
                    'We reserve the right to cancel orders due to stock unavailability, pricing errors, or suspected fraud.',
              ),
              const SizedBox(height: 16),
              _buildSection(
                number: '5',
                title: 'Shipping and Delivery',
                content:
                    'Delivery times are estimates and not guaranteed. We are not liable for delays caused by:\n\n'
                    '• Carrier delays or failures\n'
                    '• Incorrect shipping information provided by you\n'
                    '• Customs clearance issues\n'
                    '• Force majeure events\n\n'
                    'Risk of loss passes to you upon delivery to the carrier.',
              ),
              const SizedBox(height: 16),
              _buildSection(
                number: '6',
                title: 'Returns and Refunds',
                content:
                    'Our return policy allows returns within 14 days of delivery for:\n\n'
                    '• Defective or damaged products\n'
                    '• Incorrect items received\n'
                    '• Products not as described\n\n'
                    'Custom-built PCs and opened software may have different return policies. Refunds will be processed to the original payment method within 5-7 business days.',
              ),
              const SizedBox(height: 16),
              _buildSection(
                number: '7',
                title: 'Warranties',
                content:
                    'Products come with manufacturer warranties as specified. TechNest provides:\n\n'
                    '• 30-day warranty on repair services\n'
                    '• Standard manufacturer warranties on new products\n'
                    '• Limited warranty on refurbished items\n\n'
                    'Warranties do not cover damage from misuse, unauthorized modifications, or normal wear and tear.',
              ),
              const SizedBox(height: 16),
              _buildSection(
                number: '8',
                title: 'Intellectual Property',
                content:
                    'All content on TechNest, including text, graphics, logos, and software, is the property of TechNest or its licensors and is protected by copyright laws. You may not:\n\n'
                    '• Reproduce or distribute our content without permission\n'
                    '• Modify or create derivative works\n'
                    '• Use our trademarks without authorization\n'
                    '• Reverse engineer our software',
              ),
              const SizedBox(height: 16),
              _buildSection(
                number: '9',
                title: 'Prohibited Activities',
                content:
                    'You agree not to:\n\n'
                    '• Use our services for illegal purposes\n'
                    '• Violate any applicable laws or regulations\n'
                    '• Infringe on intellectual property rights\n'
                    '• Transmit viruses or malicious code\n'
                    '• Attempt to gain unauthorized access\n'
                    '• Interfere with our services or networks\n'
                    '• Impersonate any person or entity',
              ),
              const SizedBox(height: 16),
              _buildSection(
                number: '10',
                title: 'Limitation of Liability',
                content:
                    'To the maximum extent permitted by law, TechNest shall not be liable for:\n\n'
                    '• Indirect, incidental, or consequential damages\n'
                    '• Loss of profits, data, or business opportunities\n'
                    '• Service interruptions or delays\n'
                    '• Errors or inaccuracies in content\n\n'
                    'Our total liability shall not exceed the amount you paid us in the 12 months preceding the claim.',
              ),
              const SizedBox(height: 16),
              _buildSection(
                number: '11',
                title: 'Indemnification',
                content:
                    'You agree to indemnify and hold harmless TechNest, its officers, directors, and employees from any claims, damages, losses, or expenses arising from:\n\n'
                    '• Your use of our services\n'
                    '• Your violation of these terms\n'
                    '• Your violation of any third-party rights',
              ),
              const SizedBox(height: 16),
              _buildSection(
                number: '12',
                title: 'Governing Law',
                content: 'These terms are governed by the laws of Sri Lanka. Any disputes shall be resolved in the courts of Colombo, Sri Lanka. You agree to submit to the jurisdiction of these courts.',
              ),
              const SizedBox(height: 16),
              _buildSection(
                number: '13',
                title: 'Contact Information',
                content:
                    'For questions about these Terms and Conditions, please contact us:\n\n'
                    'Email: legal@technest.com\n'
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
        'Welcome to TechNest. These Terms and Conditions govern your use of our website and services. Please read them carefully. By using our services, you agree to be bound by these terms.',
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
