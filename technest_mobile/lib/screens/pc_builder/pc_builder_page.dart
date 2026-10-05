import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/build_item_model.dart';
import '../../models/product_model.dart';
import '../../models/pc_build_model.dart';
import '../../services/pc_build_service.dart';
import '../../services/product_service.dart';
import 'product_selection_sheet.dart';

class PcBuilderPage extends StatefulWidget {
  const PcBuilderPage({super.key});

  @override
  State<PcBuilderPage> createState() => _PcBuilderPageState();
}

class _PcBuilderPageState extends State<PcBuilderPage> {
  final PcBuildService _pcBuildService = PcBuildService();
  final ProductService _productService = ProductService();

  static const Color primaryBrown = AppColors.primary;
  static const Color lightBrown = AppColors.chipBg;
  static const Color borderBrown = AppColors.border;

  PcBuildModel? _build;
  List<ProductModel> _products = [];

  bool _isLoading = true;
  String? _errorMessage;

  final List<String> _categories = [
    'Processor',
    'Motherboard',
    'GPU',
    'RAM',
    'Storage',
    'PSU',
    'Case',
    'Cooler',
  ];

  @override
  void initState() {
    super.initState();
    _initializeBuilder();
  }

  Future<void> _initializeBuilder() async {
    try {
      final products = await _loadAllProducts();

      if (!mounted) return;

      setState(() {
        _products = products;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<List<ProductModel>> _loadAllProducts() async {
    final List<ProductModel> allProducts = [];

    int page = 1;
    const int pageSize = 50;

    while (true) {
      final response = await _productService.getProducts(
        page: page,
        pageSize: pageSize,
      );

      allProducts.addAll(response.items);

      if (!response.hasNextPage) {
        break;
      }

      page++;
    }

    return allProducts;
  }

  Future<void> _selectProduct(String category) async {
    final categoryProducts = _products
        .where(
          (product) =>
              product.category.toLowerCase() == category.toLowerCase() &&
              product.isActive &&
              product.stockQuantity > 0,
        )
        .toList();

    if (categoryProducts.isEmpty) {
      _showMessage('No $category products available.');
      return;
    }

    final selectedProduct = await showModalBottomSheet<ProductModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ProductSelectionSheet(
          category: category,
          products: categoryProducts,
        );
      },
    );

    if (selectedProduct == null) return;

    await _addOrUpdateProduct(category, selectedProduct);
  }

  Future<void> _addOrUpdateProduct(
    String category,
    ProductModel product,
  ) async {
    try {
      PcBuildModel? build = _build;

      // Create the PC build only when the user
      // actually selects the first component.
      if (build == null) {
        build = await _pcBuildService.createBuild();

        if (!mounted) return;

        setState(() {
          _build = build;
        });
      }

      final existingItem = _getItemForCategory(category);

      BuildItemModel updatedItem;

      if (existingItem != null) {
        updatedItem = await _pcBuildService.updateBuildItem(
          buildId: build.id,
          itemId: existingItem.id,
          productId: product.id,
          quantity: 1,
        );

        final updatedItems = build.items.map((item) {
          return item.id == existingItem.id ? updatedItem : item;
        }).toList();

        if (!mounted) return;

        setState(() {
          _build = PcBuildModel(
            id: build!.id,
            createdAt: build.createdAt,
            updatedAt: DateTime.now(),
            items: updatedItems,
          );
        });
      } else {
        updatedItem = await _pcBuildService.addBuildItem(
          buildId: build.id,
          productId: product.id,
          quantity: 1,
        );

        if (!mounted) return;

        setState(() {
          _build = PcBuildModel(
            id: build!.id,
            createdAt: build.createdAt,
            updatedAt: DateTime.now(),
            items: [...build.items, updatedItem],
          );
        });
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  BuildItemModel? _getItemForCategory(String category) {
    for (final item in _build?.items ?? []) {
      if (item.category.toLowerCase() == category.toLowerCase()) {
        return item;
      }
    }

    return null;
  }

  Future<void> _removeProduct(String category) async {
    if (_build == null) return;

    final item = _getItemForCategory(category);

    if (item == null) return;

    try {
      await _pcBuildService.deleteBuildItem(
        buildId: _build!.id,
        itemId: item.id,
      );

      if (!mounted) return;

      setState(() {
        _build = PcBuildModel(
          id: _build!.id,
          createdAt: _build!.createdAt,
          updatedAt: DateTime.now(),
          items: _build!.items
              .where((buildItem) => buildItem.id != item.id)
              .toList(),
        );
      });
    } catch (e) {
      if (!mounted) return;

      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  double get _totalPrice {
    return (_build?.items ?? []).fold(
      0,
      (total, item) => total + item.totalPrice,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryBrown,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatPrice(double price) {
    return formatPrice(price, prefix: 'Rs. ');
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Processor':
        return Icons.memory_outlined;
      case 'Motherboard':
        return Icons.developer_board_outlined;
      case 'GPU':
        return Icons.graphic_eq_outlined;
      case 'RAM':
        return Icons.storage_outlined;
      case 'Storage':
        return Icons.sd_storage_outlined;
      case 'PSU':
        return Icons.power_outlined;
      case 'Case':
        return Icons.desktop_windows_outlined;
      case 'Cooler':
        return Icons.ac_unit_outlined;
      default:
        return Icons.computer_outlined;
    }
  }

  Widget _buildComponentCard(String category, bool isDark) {
    final item = _getItemForCategory(category);

    return GestureDetector(
      onTap: () => _selectProduct(category),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.darkTertiary : borderBrown,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkTertiary : lightBrown,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _getCategoryIcon(category),
                size: 25,
                color: isDark ? AppColors.white : primaryBrown,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: item == null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Choose a component',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textMuted
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textMuted : primaryBrown,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatPrice(item.totalPrice),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.white : primaryBrown,
                          ),
                        ),
                      ],
                    ),
            ),
            if (item != null)
              IconButton(
                onPressed: () => _removeProduct(category),
                icon: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: isDark ? AppColors.textMuted : primaryBrown,
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? AppColors.textMuted : primaryBrown,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkTertiary : borderBrown,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Total',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textMuted
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _formatPrice(_totalPrice),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.white : primaryBrown,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            height: 48,
            child: ElevatedButton(
              onPressed: _build == null || _build!.items.isEmpty
                  ? null
                  : () {
                      Navigator.pushNamed(
                        context,
                        '/pc-build-summary',
                        arguments: _build!.id,
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBrown,
                foregroundColor: Colors.white,
                disabledBackgroundColor: isDark
                    ? AppColors.darkTertiary
                    : borderBrown,
                disabledForegroundColor: isDark
                    ? AppColors.textMuted
                    : AppColors.textSecondary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text(
                'Summary',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
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
                color: isDark ? AppColors.darkTertiary : lightBrown,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 44,
                color: isDark ? AppColors.textMuted : primaryBrown,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to Load PC Builder',
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
              onPressed: _initializeBuilder,
              icon: Icon(
                Icons.refresh_rounded,
                color: isDark ? AppColors.white : primaryBrown,
              ),
              label: Text(
                'Try Again',
                style: TextStyle(
                  color: isDark ? AppColors.white : primaryBrown,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDark ? AppColors.darkTertiary : borderBrown,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
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
          'PC Builder',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.white : primaryBrown,
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryBrown))
          : _errorMessage != null
          ? _buildErrorState(isDark)
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                    children: [
                      Text(
                        'Build Your PC',
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
                        'Choose the components for your custom PC.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textMuted
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ..._categories.map(
                        (category) => _buildComponentCard(category, isDark),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: _buildTotalCard(isDark),
                  ),
                ),
              ],
            ),
    );
  }
}
