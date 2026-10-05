import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';

class RepairSuccessPage extends StatelessWidget {
  final Map<String, dynamic> repair;

  const RepairSuccessPage({super.key, required this.repair});

  String _formatDate(String? value) {
    if (value == null) return '-';

    final date = DateTime.tryParse(value);

    if (date == null) return '-';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatTime(String? value) {
    if (value == null) return '-';

    final date = DateTime.tryParse(value);

    if (date == null) return '-';

    final hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  String _formatCost(dynamic value) {
    if (value == null) return 'Pending';

    final cost = double.tryParse(value.toString());

    if (cost == null || cost == 0) {
      return 'Pending';
    }

    return formatPrice(cost, prefix: 'Rs. ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
          child: Column(
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.green,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Repair Request Submitted',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                'Your repair request has been successfully submitted. '
                'Please keep the details below for reference.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 30),
              _buildDetailsCard(),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    final appointmentDate = repair['appointmentDate']?.toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildRow('Repair ID', '#${repair['id'] ?? '-'}'),
          const Divider(height: 24),
          _buildRow('Device', repair['deviceModel']?.toString() ?? '-'),
          const Divider(height: 24),
          _buildRow('Status', repair['status']?.toString() ?? 'Pending'),
          const Divider(height: 24),
          _buildRow('Appointment Date', _formatDate(appointmentDate)),
          const Divider(height: 24),
          _buildRow('Appointment Time', _formatTime(appointmentDate)),
          const Divider(height: 24),
          _buildRow('Estimated Cost', _formatCost(repair['estimatedCost'])),
        ],
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ),
        const SizedBox(width: 20),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
