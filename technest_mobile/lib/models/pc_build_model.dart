import 'build_item_model.dart';

class PcBuildModel {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<BuildItemModel> items;

  PcBuildModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  factory PcBuildModel.fromJson(Map<String, dynamic> json) {
    return PcBuildModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      items: json['items'] is List
          ? (json['items'] as List)
                .map(
                  (item) =>
                      BuildItemModel.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : [],
    );
  }
}
