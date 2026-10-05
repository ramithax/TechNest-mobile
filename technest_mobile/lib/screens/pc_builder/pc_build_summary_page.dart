import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/build_item_model.dart';
import '../../models/build_summary_model.dart';
import '../../services/pc_build_service.dart';
import '../checkout/checkout_page.dart';

class PcBuildSummaryPage extends StatefulWidget {
  final int buildId;

  const PcBuildSummaryPage({super.key, required this.buildId});

  @override
  State<PcBuildSummaryPage> createState() => _PcBuildSummaryPageState();
}

class _PcBuildSummaryPageState extends State<PcBuildSummaryPage> {
  static const Color primaryAccent = AppColors.primary;
  static const Color lightBg = AppColors.chipBg;
  static const Color borderLight = AppColors.border;

  final PcBuildService _pcBuildService = PcBuildService();

  BuildSummaryModel? _summary;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    try {
      final summary = await _pcBuildService.getBuildSummary(widget.buildId);

      if (!mounted) return;

      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String _formatPrice(double price) {
    return formatPrice(price);
  }

  String _getImageUrl(BuildItemModel item) {
    if (item.images.isEmpty) return '';

    final image = item.images.first;
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }

    return item.images.first;
  }

  Widget _buildProductImage(BuildItemModel item, bool isDark) {
    final imageUrl = _getImageUrl(item);

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : lightBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkTertiary : borderLight,
        ),
      ),
      child: imageUrl.isEmpty
          ? Icon(
              Icons.image_outlined,
              color: isDark ? AppColors.textMuted : AppColors.primary,
              size: 30,
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.image_not_supported_outlined,
                    color: isDark ? AppColors.textMuted : AppColors.primary,
                    size: 30,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isDark ? AppColors.white : AppColors.primary,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildComponentCard(BuildItemModel item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkTertiary : borderLight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImage(item, isDark),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.category,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.white
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkTertiary : lightBg,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        'Qty: ${item.quantity}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textMuted : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatPrice(item.unitPrice),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textMuted
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatPrice(item.totalPrice),
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.white : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout() {
    if (_summary == null || _summary!.items.isEmpty) {
      _showMessage('Please select components first.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutPage(
          items: const [],
          pcBuildId: widget.buildId,
          clearCartAfterOrder: false,
        ),
      ),
    );
  }

  Widget _buildTotalCard(BuildSummaryModel summary, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkTertiary : borderLight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkTertiary : lightBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.memory_rounded,
                  size: 18,
                  color: isDark ? AppColors.white : AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Selected Components',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textMuted
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                '${summary.items.length}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.white : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: isDark ? AppColors.darkTertiary : borderLight),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Estimated Total',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textMuted
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                _formatPrice(summary.totalPrice),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.white : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _proceedToCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dark,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Proceed to Checkout',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 17),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkTertiary : lightBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.computer_outlined,
                size: 42,
                color: isDark ? AppColors.textMuted : AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Components Selected',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Go back and choose components for your PC build.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textMuted : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dark,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: const Text(
                'Back to Builder',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkTertiary : lightBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 44,
                color: isDark ? AppColors.textMuted : AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to Load Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textMuted : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _loadSummary,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.dark : Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? AppColors.dark : Colors.white,
        foregroundColor: isDark ? AppColors.white : AppColors.textPrimary,
        title: const Text(
          'Build Summary',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.white : AppColors.textPrimary,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _errorMessage != null
          ? _buildErrorState(isDark)
          : _summary == null || _summary!.items.isEmpty
          ? _buildEmptyState(isDark)
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                    children: [
                      Text(
                        'Your Custom PC',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Review the components selected for your build.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textMuted
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ..._summary!.items.map(
                        (item) => _buildComponentCard(item, isDark),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: _buildTotalCard(_summary!, isDark),
                  ),
                ),
              ],
            ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
