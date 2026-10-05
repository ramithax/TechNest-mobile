import 'build_item_model.dart';

class BuildSummaryModel {
  final int pcBuildId;
  final List<BuildItemModel> items;
  final double totalPrice;

  BuildSummaryModel({
    required this.pcBuildId,
    required this.items,
    required this.totalPrice,
  });

  factory BuildSummaryModel.fromJson(Map<String, dynamic> json) {
    return BuildSummaryModel(
      pcBuildId: int.tryParse(json['pcBuildId']?.toString() ?? '') ?? 0,
      items: json['items'] is List
          ? (json['items'] as List)
                .map(
                  (item) =>
                      BuildItemModel.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : [],
      totalPrice: double.tryParse(json['totalPrice']?.toString() ?? '') ?? 0,
    );
  }
}
