import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  final OrderService _orderService = OrderService();

  List<OrderModel> _orders = [];

  bool _isLoading = true;
  bool _isChangingPage = false;

  int _currentPage = 1;
  final int _pageSize = 5;

  int _totalPages = 1;
  int _totalCount = 0;

  String _selectedStatusFilter = 'All';
  int? _cancellingOrderId;

  @override
  void initState() {
    super.initState();
    _loadOrders(1);
  }

  Future<void> _loadOrders(int page) async {
    if (_isChangingPage) return;

    setState(() {
      if (_orders.isEmpty) {
        _isLoading = true;
      } else {
        _isChangingPage = true;
      }
    });

    try {
      final response = await _orderService.getOrders(
        page: page,
        pageSize: _pageSize,
      );

      if (!mounted) return;

      setState(() {
        _orders = response.items;
        _currentPage = response.page;
        _totalPages = response.totalPages;
        _totalCount = response.totalCount;
        _isLoading = false;
        _isChangingPage = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isChangingPage = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_getErrorMessage(e))));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isChangingPage = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load orders: $e')));
    }
  }

  void _changePage(int page) {
    if (page < 1 ||
        page > _totalPages ||
        page == _currentPage ||
        _isChangingPage)
      return;
    _loadOrders(page);
  }

  Future<void> _refreshOrders() async => await _loadOrders(1);

  void _changeFilter(String status) {
    setState(() {
      _selectedStatusFilter = status;
    });
  }

  // ============================================================
  // FIX: Filter out CustomPC orders from this page
  // ============================================================
  List<OrderModel> get _filteredOrders {
    final normalOrders = _orders
        .where((order) => order.orderType.toLowerCase() != 'custompc')
        .toList();

    if (_selectedStatusFilter == 'All') return normalOrders;

    return normalOrders.where((order) {
      return order.status.toLowerCase() == _selectedStatusFilter.toLowerCase();
    }).toList();
  }

  Future<void> _cancelOrder(OrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkCard
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Cancel Order',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.white
                  : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Are you sure you want to cancel Order #${order.id}? This action cannot be undone.',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textSecondary
                  : AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No, Keep It'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    setState(() => _cancellingOrderId = order.id);

    try {
      await _orderService.cancelOrder(order.id);
      if (!mounted) return;
      setState(() => _cancellingOrderId = null);
      await _loadOrders(_currentPage);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order cancelled successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _cancellingOrderId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getErrorMessage(e)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _cancellingOrderId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel order: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showOrderDetails(OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.textMuted : AppColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkTertiary
                              : AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.receipt_long_outlined,
                          color: isDark ? AppColors.white : AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${order.id}',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(order.createdAt),
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.textMuted
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close_rounded,
                          color: isDark
                              ? AppColors.textMuted
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailSection(
                          title: 'Order Information',
                          isDark: isDark,
                          children: [
                            _buildDetailRow('Status', order.status, isDark),
                            _buildDetailRow(
                              'Order Type',
                              order.orderType == 'CustomPC'
                                  ? 'Custom PC Build'
                                  : order.orderType,
                              isDark,
                            ),
                            _buildDetailRow(
                              'Total Amount',
                              _formatPrice(order.totalAmount),
                              isDark,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildDetailSection(
                          title: 'Customer Information',
                          isDark: isDark,
                          children: [
                            _buildDetailRow('Name', order.customerName, isDark),
                            _buildDetailRow(
                              'Email',
                              order.customerEmail,
                              isDark,
                            ),
                            _buildDetailRow(
                              'Contact',
                              order.contactNumber,
                              isDark,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildDetailSection(
                          title: 'Delivery Information',
                          isDark: isDark,
                          children: [
                            _buildDetailRow(
                              'Address',
                              order.shippingAddress,
                              isDark,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildDetailSection(
                          title: 'Items',
                          isDark: isDark,
                          children: [
                            ...order.items.map(
                              (item) => _buildOrderItem(item, isDark),
                            ),
                          ],
                        ),
                        if (order.trackingNumber != null &&
                            order.trackingNumber!.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildDetailSection(
                            title: 'Tracking',
                            isDark: isDark,
                            children: [
                              _buildDetailRow(
                                'Tracking Number',
                                order.trackingNumber!,
                                isDark,
                              ),
                            ],
                          ),
                        ],
                        if (order.status.toLowerCase() == 'pending') ...[
                          const SizedBox(height: 25),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _cancellingOrderId == order.id
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                      _cancelOrder(order);
                                    },
                              icon: _cancellingOrderId == order.id
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.cancel_outlined),
                              label: const Text('Cancel Order'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade50,
                                foregroundColor: Colors.red.shade700,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailSection({
    required String title,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkTertiary : const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.darkTertiary : AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textMuted : AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItemModel item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkTertiary : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkTertiary
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: isDark ? AppColors.textMuted : AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.white : AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity} • Unit: ${_formatPrice(item.unitPrice)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textMuted
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatPrice(item.totalPrice),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.white : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, bool isDark) {
    final statusColor = _getStatusColor(order.status);
    final statusIcon = _getStatusIcon(order.status);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkTertiary : AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(order.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textMuted
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 5),
                      Text(
                        order.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkTertiary
                    : const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkTertiary : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 20,
                    color: isDark
                        ? AppColors.textMuted
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${order.items.length} item${order.items.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textMuted
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    _formatPrice(order.totalAmount),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.white : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showOrderDetails(order),
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (order.status.toLowerCase() == 'pending') ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _cancellingOrderId == order.id
                          ? null
                          : () => _cancelOrder(order),
                      icon: _cancellingOrderId == order.id
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(bool isDark) {
    if (_totalPages <= 1) return const SizedBox(height: 20);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNavigationButton(
            icon: Icons.chevron_left,
            enabled: _currentPage > 1 && !_isChangingPage,
            isDark: isDark,
            onPressed: () => _changePage(_currentPage - 1),
          ),
          const SizedBox(width: 8),
          ...List.generate(_totalPages, (index) {
            final page = index + 1;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildPageNumberButton(page, isDark),
            );
          }),
          const SizedBox(width: 8),
          _buildNavigationButton(
            icon: Icons.chevron_right,
            enabled: _currentPage < _totalPages && !_isChangingPage,
            isDark: isDark,
            onPressed: () => _changePage(_currentPage + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildPageNumberButton(int page, bool isDark) {
    final bool selected = page == _currentPage;
    return SizedBox(
      width: 42,
      height: 42,
      child: ElevatedButton(
        onPressed: selected || _isChangingPage ? null : () => _changePage(page),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: EdgeInsets.zero,
          backgroundColor: selected
              ? AppColors.primary
              : (isDark ? AppColors.darkTertiary : Colors.white),
          foregroundColor: selected
              ? Colors.white
              : (isDark ? AppColors.white : AppColors.primary),
          disabledBackgroundColor: selected
              ? AppColors.primary
              : (isDark ? AppColors.darkTertiary : Colors.grey.shade100),
          disabledForegroundColor: selected
              ? Colors.white
              : (isDark ? AppColors.textMuted : Colors.grey.shade400),
          side: BorderSide(
            color: selected
                ? AppColors.primary
                : (isDark ? AppColors.darkTertiary : AppColors.border),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          '$page',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required bool enabled,
    required bool isDark,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 42,
      height: 42,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: AppColors.primary,
          disabledForegroundColor: isDark
              ? AppColors.textMuted
              : Colors.grey.shade400,
          side: BorderSide(
            color: enabled
                ? (isDark ? AppColors.darkTertiary : AppColors.border)
                : Colors.transparent,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Icon(icon, size: 22),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    const filters = [
      'All',
      'Pending',
      'Processing',
      'Shipped',
      'Delivered',
      'Cancelled',
    ];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = _selectedStatusFilter == filter;
          return ChoiceChip(
            label: Text(filter),
            selected: selected,
            onSelected: (_) => _changeFilter(filter),
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: selected
                  ? Colors.white
                  : (isDark ? AppColors.white : AppColors.textPrimary),
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
            backgroundColor: isDark
                ? AppColors.darkTertiary
                : const Color(0xFFF5F5F5),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.access_time;
      case 'processing':
        return Icons.sync;
      case 'shipped':
        return Icons.local_shipping_outlined;
      case 'delivered':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  String _formatPrice(double price) => formatPrice(price, prefix: 'Rs. ');

  String _getErrorMessage(DioException e) {
    if (e.response?.data is Map) {
      final data = e.response!.data as Map;
      if (data['message'] != null) return data['message'].toString();
      if (data['title'] != null) return data['title'].toString();
    }
    if (e.type == DioExceptionType.connectionTimeout)
      return 'Connection timeout. Please try again.';
    if (e.type == DioExceptionType.connectionError)
      return 'Unable to connect to the server.';
    return e.message ?? 'Something went wrong.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredOrders = _filteredOrders;

    return Scaffold(
      backgroundColor: isDark ? AppColors.dark : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.dark : AppColors.background,
        elevation: 0,
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _refreshOrders,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshOrders,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 10),
                      child: _buildFilterChips(isDark),
                    ),
                  ),
                  if (filteredOrders.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkTertiary
                                    : AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.receipt_long_outlined,
                                size: 36,
                                color: isDark
                                    ? AppColors.textMuted
                                    : AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No orders found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your ${_selectedStatusFilter == 'All' ? '' : _selectedStatusFilter.toLowerCase() + ' '}orders will appear here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.textMuted
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildOrderCard(filteredOrders[index], isDark),
                        childCount: filteredOrders.length,
                      ),
                    ),
                  if (filteredOrders.isNotEmpty)
                    SliverToBoxAdapter(child: _buildPagination(isDark)),
                ],
              ),
            ),
    );
  }
}
