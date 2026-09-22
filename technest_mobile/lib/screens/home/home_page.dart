import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../../widgets/bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late VideoPlayerController _carouselController;

  final List<Map<String, String>> categories = [
    {'name': 'Laptops', 'image': 'assets/images/laptop.jpg'},
    {'name': 'Monitors', 'image': 'assets/images/monitor.jpg'},
    {'name': 'Motherboards', 'image': 'assets/images/motherboard.jpg'},
    {'name': 'Graphics Cards', 'image': 'assets/images/gpu.jpg'},
    {'name': 'Processors', 'image': 'assets/images/proccessor.jpg'},
  ];

  final List<Map<String, String>> products = [
    {
      'name': 'Product will be loaded from database',
      'price': 'Rs. 0.00',
      'oldPrice': 'Rs. 0.00',
      'discount': 'SALE',
    },
    {
      'name': 'Product will be loaded from database',
      'price': 'Rs. 0.00',
      'oldPrice': 'Rs. 0.00',
      'discount': 'SALE',
    },
    {
      'name': 'Product will be loaded from database',
      'price': 'Rs. 0.00',
      'oldPrice': 'Rs. 0.00',
      'discount': 'SALE',
    },
    {
      'name': 'Product will be loaded from database',
      'price': 'Rs. 0.00',
      'oldPrice': 'Rs. 0.00',
      'discount': 'SALE',
    },
  ];

  @override
  void initState() {
    super.initState();

    _carouselController =
        VideoPlayerController.asset('assets/images/caruosal.mp4')
          ..initialize().then((_) {
            if (!mounted) return;

            setState(() {});

            _carouselController
              ..setLooping(true)
              ..setVolume(0)
              ..play();
          }).catchError((error) {
            debugPrint('Carousel video error: $error');
          });
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
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _buildProductCard(products[index]);
                }, childCount: products.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.67,
                ),
              ),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.035),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF2D3436),
                ),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.grey.shade600,
                    size: 22,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _buildHeaderButton(
            icon: Icons.notifications_none_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: const Color(0xFF2D3436), size: 22),
      ),
    );
  }

  Widget _buildCarousel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 205,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: _carouselController.value.isInitialized &&
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
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.035),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(category['image']!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category['name']!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
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
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFC29A55),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'SUPER DEAL',
                style: GoogleFonts.poppins(
                  fontSize: 8,
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
            child: Text(
              'See all',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF765B2D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, String> product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Center(
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 42,
                  color: Color(0xFFCCCCCC),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 2, 12, 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name']!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  product['price']!,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF765B2D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product['oldPrice']!,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade500,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
