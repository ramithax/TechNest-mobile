class OrderItemModel {
  final int id;
  final int productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double totalPrice;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] ?? 0,
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
    );
  }
}

class OrderModel {
  final int id;
  final int userId;
  final String customerName;
  final String customerEmail;
  final String shippingAddress;
  final String contactNumber;
  final String orderType;
  final String status;
  final double totalAmount;
  final String? trackingNumber;
  final int? pcBuildId;
  final List<OrderItemModel> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.customerEmail,
    required this.shippingAddress,
    required this.contactNumber,
    required this.orderType,
    required this.status,
    required this.totalAmount,
    this.trackingNumber,
    this.pcBuildId,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      customerName: json['customerName'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
      shippingAddress: json['shippingAddress'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      orderType: json['orderType'] ?? '',
      status: json['status'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      trackingNumber: json['trackingNumber'],
      pcBuildId: json['pcBuildId'],
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}
