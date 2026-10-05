import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../core/constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../widgets/product_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late VideoPlayerController _carouselController;

  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  List<ProductModel> products = [];

  bool isLoadingProducts = true;
  bool _isChangingPage = false;

  String? productError;

  int _currentPage = 1;
  final int _pageSize = 10;
  int _totalPages = 1;

  String _searchQuery = '';
  String? _selectedCategory;

  Timer? _searchDebounce;

  final List<Map<String, String>> categories = [
    {'name': 'Laptops', 'value': 'Laptop', 'image': 'assets/images/laptop.jpg'},
    {
      'name': 'Monitors',
      'value': 'Monitor',
      'image': 'assets/images/monitor.jpg',
    },
    {
      'name': 'Motherboards',
      'value': 'Motherboard',
      'image': 'assets/images/motherboard.jpg',
    },
    {
      'name': 'Graphics Cards',
      'value': 'GPU',
      'image': 'assets/images/gpu.jpg',
    },
    {
      'name': 'Processors',
      'value': 'Processor',
      'image': 'assets/images/proccessor.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();

    _carouselController =
        VideoPlayerController.asset('assets/images/caruosal.mp4')
          ..initialize()
              .then((_) {
                if (!mounted) return;

                setState(() {});

                _carouselController
                  ..setLooping(true)
                  ..setVolume(0)
                  ..play();
              })
              .catchError((error) {
                debugPrint('Carousel video error: $error');
              });

    _loadProducts(page: 1);
  }

  // ============================================================
  // LOAD PRODUCTS
  // ============================================================

  Future<void> _loadProducts({required int page}) async {
    if (_isChangingPage) return;

    setState(() {
      if (page == 1 && products.isEmpty) {
        isLoadingProducts = true;
      } else {
        _isChangingPage = true;
      }

      productError = null;
    });

    try {
      debugPrint(
        'Loading products: '
        'page=$page, '
        'search=$_searchQuery, '
        'category=$_selectedCategory',
      );

      final result = await _productService.getProducts(
        page: page,
        pageSize: _pageSize,
        search: _searchQuery,
        category: _selectedCategory,
      );

      if (!mounted) return;

      setState(() {
        products = result.items;

        _currentPage = result.page;
        _totalPages = result.totalPages;

        isLoadingProducts = false;
        _isChangingPage = false;
        productError = null;
      });

      debugPrint(
        'Loaded page ${result.page}: '
        '${result.items.length} products | '
        'Total: ${result.totalCount} | '
        'Total pages: ${result.totalPages}',
      );
    } catch (e) {
      debugPrint('Product loading error: $e');

      if (!mounted) return;

      setState(() {
        isLoadingProducts = false;
        _isChangingPage = false;
        productError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _onSearchChanged(String value) {
    _searchQuery = value;

    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      _loadProducts(page: 1);
    });
  }

  // ============================================================
  // CATEGORY FILTER
  // ============================================================

  void _selectCategory(String category) {
    if (_isChangingPage) return;

    setState(() {
      if (_selectedCategory == category) {
        _selectedCategory = null;
      } else {
        _selectedCategory = category;
      }
    });

    _loadProducts(page: 1);
  }

  // ============================================================
  // CLEAR FILTERS
  // ============================================================

  void _clearFilters() {
    if (_isChangingPage) return;

    _searchDebounce?.cancel();
    _searchController.clear();

    setState(() {
      _searchQuery = '';
      _selectedCategory = null;
    });

    _loadProducts(page: 1);
  }

  // ============================================================
  // CHANGE PAGE
  // ============================================================

  void _changePage(int page) {
    if (page < 1 || page > _totalPages) return;
    if (page == _currentPage) return;
    if (_isChangingPage) return;

    _loadProducts(page: page);
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _carouselController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool hasActiveFilter =
        _searchQuery.trim().isNotEmpty || _selectedCategory != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildCarousel()),
            SliverToBoxAdapter(child: _buildCategories()),
            if (hasActiveFilter)
              SliverToBoxAdapter(child: _buildActiveFilter()),
            SliverToBoxAdapter(
              child: _buildSectionHeader(title: 'Top Selling', showDeal: true),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              sliver: _buildProductsSection(),
            ),
            if (!isLoadingProducts && productError == null)
              SliverToBoxAdapter(child: _buildPagination()),
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCTS SECTION
  // ============================================================

  Widget _buildProductsSection() {
    if (isLoadingProducts) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      );
    }

    if (productError != null) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: Colors.grey,
                ),
                const SizedBox(height: 12),
                Text(
                  productError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isChangingPage
                      ? null
                      : () {
                          _loadProducts(page: _currentPage);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 42,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                const Text(
                  'No products found',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Try another search or category.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 16),
                if (_searchQuery.isNotEmpty || _selectedCategory != null)
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text(
                      'Clear Filters',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverGrid(
          delegate: SliverChildBuilderDelegate((context, index) {
            return ProductCard(product: products[index]);
          }, childCount: products.length),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 14,
            childAspectRatio: 0.67,
          ),
        ),
        if (_isChangingPage)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // ACTIVE FILTER
  // ============================================================

  Widget _buildActiveFilter() {
    String? selectedCategoryName;

    if (_selectedCategory != null) {
      for (final category in categories) {
        if (category['value'] == _selectedCategory) {
          selectedCategoryName = category['name'];
          break;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                if (_selectedCategory != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.category_outlined,
                          size: 15,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          selectedCategoryName ?? _selectedCategory!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_searchQuery.trim().isNotEmpty) ...[
                  if (_selectedCategory != null) const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 15,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '"$_searchQuery"',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _isChangingPage ? null : _clearFilters,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Clear',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGINATION
  // ============================================================

  Widget _buildPagination() {
    if (_totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPaginationButton(
            icon: Icons.chevron_left_rounded,
            enabled: _currentPage > 1,
            onPressed: () {
              _changePage(_currentPage - 1);
            },
          ),
          const SizedBox(width: 8),
          ...List.generate(_totalPages, (index) {
            final page = index + 1;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildPageNumber(page),
            );
          }),
          const SizedBox(width: 8),
          _buildPaginationButton(
            icon: Icons.chevron_right_rounded,
            enabled: _currentPage < _totalPages,
            onPressed: () {
              _changePage(_currentPage + 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPageNumber(int page) {
    final bool isSelected = page == _currentPage;

    return GestureDetector(
      onTap: _isChangingPage
          ? null
          : () {
              _changePage(page);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Text(
          '$page',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: enabled && !_isChangingPage ? onPressed : null,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? AppColors.surface : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          size: 22,
          color: enabled ? AppColors.textPrimary : AppColors.textMuted,
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(
                    Icons.search_rounded,
                    color: Colors.grey.shade500,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2D3436),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      onPressed: _isChangingPage
                          ? null
                          : () {
                              _searchDebounce?.cancel();
                              _searchController.clear();

                              setState(() {
                                _searchQuery = '';
                              });

                              _loadProducts(page: 1);
                            },
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                  Container(
                    width: 1,
                    height: 24,
                    color: Colors.grey.shade200,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  IconButton(
                    onPressed: () {
                      _showFilterInfo();
                    },
                    icon: Icon(
                      Icons.tune_rounded,
                      color: _selectedCategory != null
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 22,
                    ),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildHeaderButton(
            icon: Icons.notifications_none_rounded,
            onTap: () {},
            showBadge: true,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTER BUTTON
  // ============================================================

  void _showFilterInfo() {
    _showCategoryBottomSheet();
  }

  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Filter by Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _selectedCategory == null
                        ? AppColors.primary
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.apps_rounded,
                    color: _selectedCategory == null
                        ? Colors.white
                        : Colors.grey.shade600,
                  ),
                ),
                title: const Text(
                  'All Products',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                trailing: _selectedCategory == null
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  Navigator.pop(context);

                  if (_selectedCategory != null) {
                    setState(() {
                      _selectedCategory = null;
                    });

                    _loadProducts(page: 1);
                  }
                },
              ),
              ...categories.map((category) {
                final String name = category['name']!;
                final String value = category['value']!;

                final bool selected = _selectedCategory == value;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 42,
                    height: 42,
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image.asset(category['image']!, fit: BoxFit.cover),
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: selected
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.primary,
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    _selectCategory(value);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
    bool showBadge = false,
  }) {
    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: AppColors.textPrimary, size: 22),
          ),
        ),
        if (showBadge)
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFE74C3C),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // CAROUSEL
  // ============================================================

  Widget _buildCarousel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 210,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child:
            _carouselController.value.isInitialized &&
                _carouselController.value.size.width > 0 &&
                _carouselController.value.size.height > 0
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _carouselController.value.size.width,
                    height: _carouselController.value.size.height,
                    child: VideoPlayer(_carouselController),
                  ),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
      ),
    );
  }

  // ============================================================
  // CATEGORIES
  // ============================================================

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        children: [
          _buildSectionHeader(title: 'Categories', showDeal: false),
          const SizedBox(height: 16),
          SizedBox(
            height: 115,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (_, __) {
                return const SizedBox(width: 14);
              },
              itemBuilder: (context, index) {
                final category = categories[index];

                return _buildCategoryCard(category);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, String> category) {
    final String name = category['name']!;
    final String value = category['value']!;

    final bool isSelected = _selectedCategory == value;

    return GestureDetector(
      onTap: _isChangingPage
          ? null
          : () {
              _selectCategory(value);
            },
      child: SizedBox(
        width: 82,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72,
              height: 72,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryMuted : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(category['image']!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader({required String title, required bool showDeal}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          if (showDeal) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'SUPER DEAL',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
          const Spacer(),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 2),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 10,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
