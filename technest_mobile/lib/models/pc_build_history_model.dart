class PcBuildHistoryModel {
  final int id;
  final DateTime createdAt;
  final int itemCount;
  final double totalPrice;

  PcBuildHistoryModel({
    required this.id,
    required this.createdAt,
    required this.itemCount,
    required this.totalPrice,
  });

  factory PcBuildHistoryModel.fromJson(Map<String, dynamic> json) {
    return PcBuildHistoryModel(
      id: json['id'] ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      itemCount: int.tryParse(json['itemCount']?.toString() ?? '') ?? 0,
      totalPrice: double.tryParse(json['totalPrice']?.toString() ?? '') ?? 0,
    );
  }
}
