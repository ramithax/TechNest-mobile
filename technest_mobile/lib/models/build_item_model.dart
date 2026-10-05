class BuildItemModel {
  final int id;
  final int productId;
  final String productName;
  final String category;
  final String brand;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final List<String> images;

  BuildItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.category,
    required this.brand,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    required this.images,
  });

  factory BuildItemModel.fromJson(Map<String, dynamic> json) {
    return BuildItemModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      productId: int.tryParse(json['productId']?.toString() ?? '') ?? 0,
      productName: json['productName']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      unitPrice: double.tryParse(json['unitPrice']?.toString() ?? '') ?? 0,
      quantity: int.tryParse(json['quantity']?.toString() ?? '') ?? 1,
      totalPrice: double.tryParse(json['totalPrice']?.toString() ?? '') ?? 0,
      images: json['images'] is List
          ? (json['images'] as List).map((image) => image.toString()).toList()
          : [],
    );
  }
}
