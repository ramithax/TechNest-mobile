import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../services/product_service.dart';

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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null || product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: Center(child: Text(error ?? 'Product not found')),
      );
    }

    final item = product!;
    final hasDiscount = item.labelPrice > item.actualPrice;

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.images.isNotEmpty)
              SizedBox(
                height: 300,
                width: double.infinity,
                child: PageView.builder(
                  itemCount: item.images.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      item.images[index],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.image_not_supported, size: 60),
                        );
                      },
                    );
                  },
                ),
              )
            else
              const SizedBox(
                height: 300,
                child: Center(child: Icon(Icons.image_not_supported, size: 60)),
              ),

            const SizedBox(height: 24),

            Text(
              item.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              '${item.brand} • ${item.category}',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Rs. ${item.actualPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (hasDiscount) ...[
                  const SizedBox(width: 12),
                  Text(
                    'Rs. ${item.labelPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 20),

            Text(
              item.stockQuantity > 0
                  ? 'In Stock (${item.stockQuantity} available)'
                  : 'Out of Stock',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: item.stockQuantity > 0 ? Colors.green : Colors.red,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Description',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              item.description,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: item.stockQuantity > 0
                    ? () {
                        // Add to cart later
                      }
                    : null,
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
