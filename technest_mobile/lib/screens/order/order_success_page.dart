import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/order_model.dart';

class OrderSuccessPage extends StatelessWidget {
  final OrderModel order;

  const OrderSuccessPage({super.key, required this.order});

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
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
                'Order Placed Successfully',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                'Your order has been successfully placed. '
                'Please keep the details below for reference.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 30),
              _buildOrderDetailsCard(),
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
                    'Continue Shopping',
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

  Widget _buildOrderDetailsCard() {
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
          _buildRow('Order ID', '#${order.id}'),
          const Divider(height: 24),
          _buildRow(
            'Status',
            order.status.isNotEmpty ? order.status : 'Pending',
          ),
          const Divider(height: 24),
          _buildRow('Order Date', _formatDate(order.createdAt)),
          const Divider(height: 24),
          _buildRow('Order Time', _formatTime(order.createdAt)),
          const Divider(height: 24),
          _buildRow('Items', '${order.items.length}'),
          const Divider(height: 24),
          _buildRow(
            'Total Amount',
            formatPrice(order.totalAmount, prefix: 'Rs. '),
          ),
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
