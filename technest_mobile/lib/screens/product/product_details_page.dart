import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../widgets/bottom_nav_bar.dart';

class ProductDetailsPage extends StatefulWidget {
  final int productId;

  const ProductDetailsPage({super.key, required this.productId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final ProductService _productService = ProductService();

  ProductModel? product;
  bool isLoading = true;
  String? error;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final result = await _productService.getProductById(widget.productId);

      if (!mounted) return;

      setState(() {
        product = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Product details error: $e');

      if (!mounted) return;

      setState(() {
        error = 'Failed to load product';
        isLoading = false;
      });
    }
  }

  void _handleBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pop(context);
    }
  }

  void _addToCart() {
    if (product == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${product!.name} added to cart',
          style: GoogleFonts.poppins(),
        ),
      ),
    );
  }

  void _buyNow() {
    if (product == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Buy Now selected for ${product!.name}',
          style: GoogleFonts.poppins(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null || product == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Product Details',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
        body: Center(
          child: Text(
            error ?? 'Product not found',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }

    final item = product!;
    final hasDiscount = item.labelPrice > item.actualPrice;
    final isInStock = item.stockQuantity > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Color(0xFF2D3436),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Product Details',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3436),
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(18),
              ),
              child: item.images.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: PageView.builder(
                        itemCount: item.images.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            item.images[index],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 60,
                                  color: Color(0xFFCCCCCC),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 60,
                        color: Color(0xFFCCCCCC),
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            Text(
              item.name,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3436),
              ),
            ),

            const SizedBox(height: 7),

            Text(
              '${item.brand} • ${item.category}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Text(
                  'Rs. ${item.actualPrice.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF765B2D),
                  ),
                ),
                if (hasDiscount) ...[
                  const SizedBox(width: 12),
                  Text(
                    'Rs. ${item.labelPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: isInStock
                    ? const Color(0xFFEAF7EE)
                    : const Color(0xFFFFEEEE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isInStock
                    ? 'In Stock • ${item.stockQuantity} available'
                    : 'Out of Stock',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isInStock
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
              ),
            ),

            const SizedBox(height: 28),

            Text(
              'Description',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3436),
              ),
            ),

            const SizedBox(height: 9),

            Text(
              item.description,
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.6,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: isInStock ? _addToCart : null,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF765B2D)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Add to Cart',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF765B2D),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isInStock ? _buyNow : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF765B2D),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Buy Now',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      bottomNavigationBar: TechNestBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _handleBottomNavTap,
      ),
    );
  }
}
