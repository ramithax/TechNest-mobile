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
  final DateTime createdAt;
  final DateTime updatedAt;

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
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      labelPrice: double.tryParse(json['labelPrice']?.toString() ?? '') ?? 0,
      actualPrice: double.tryParse(json['actualPrice']?.toString() ?? '') ?? 0,
      stockQuantity: int.tryParse(json['stockQuantity']?.toString() ?? '') ?? 0,
      category: json['category']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      images: json['images'] is List
          ? (json['images'] as List).map((image) => image.toString()).toList()
          : [],
      isActive: json['isActive'] == true,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
