class ProductModel {
  final int id;
  final String name;
  final String description;
  final double labelPrice;
  final double actualPrice;
  final int stockQuantity;
  final String category;
  final String brand;
  final List<String> images;
  final bool isActive;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.labelPrice,
    required this.actualPrice,
    required this.stockQuantity,
    required this.category,
    required this.brand,
    required this.images,
    required this.isActive,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      labelPrice: (json['labelPrice'] ?? 0).toDouble(),
      actualPrice: (json['actualPrice'] ?? 0).toDouble(),
      stockQuantity: json['stockQuantity'] ?? 0,
      category: json['category'] ?? '',
      brand: json['brand'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      isActive: json['isActive'] ?? false,
    );
  }
}
