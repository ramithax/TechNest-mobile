import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/product_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late VideoPlayerController _carouselController;

  final ProductService _productService = ProductService();

  List<ProductModel> products = [];
  bool isLoadingProducts = true;
  String? productError;

  final List<Map<String, String>> categories = [
    {'name': 'Laptops', 'image': 'assets/images/laptop.jpg'},
    {'name': 'Monitors', 'image': 'assets/images/monitor.jpg'},
    {'name': 'Motherboards', 'image': 'assets/images/motherboard.jpg'},
    {'name': 'Graphics Cards', 'image': 'assets/images/gpu.jpg'},
    {'name': 'Processors', 'image': 'assets/images/proccessor.jpg'},
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

    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final result = await _productService.getProducts();

      if (!mounted) return;

      setState(() {
        products = result;
        isLoadingProducts = false;
      });
    } catch (e) {
      debugPrint('Product loading error: $e');

      if (!mounted) return;

      setState(() {
        productError = 'Failed to load products';
        isLoadingProducts = false;
      });
    }
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildCarousel()),
            SliverToBoxAdapter(child: _buildCategories()),
            SliverToBoxAdapter(
              child: _buildSectionHeader(title: 'Top Selling', showDeal: true),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
              sliver: _buildProductsSection(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: TechNestBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildProductsSection() {
    if (isLoadingProducts) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: CircularProgressIndicator(color: Color(0xFFC29A55)),
          ),
        ),
      );
    }

    if (productError != null) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Text(
              productError!,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
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
            child: Text(
              'No products available',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return SliverGrid(
      delegate: SliverChildBuilderDelegate((context, index) {
        return ProductCard(product: products[index]);
      }, childCount: products.length),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
        childAspectRatio: 0.67,
      ),
    );
  }

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
                    color: Colors.black.withOpacity(0.04),
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
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF2D3436),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        hintStyle: GoogleFonts.poppins(
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
                  Container(
                    width: 1,
                    height: 24,
                    color: Colors.grey.shade200,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.tune_rounded,
                      color: Colors.grey.shade600,
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
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: const Color(0xFF2D3436), size: 22),
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

  Widget _buildCarousel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 210,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
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
                child: CircularProgressIndicator(color: Color(0xFFC29A55)),
              ),
      ),
    );
  }

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
    return SizedBox(
      width: 82,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
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
            category['name']!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2D3436),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required bool showDeal}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          if (showDeal) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFAA8022)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC29A55).withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'SUPER DEAL',
                style: GoogleFonts.poppins(
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'See all',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF765B2D),
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 10,
                  color: Color(0xFF765B2D),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
