import 'order_model.dart';

class PagedOrderResponse {
  final List<OrderModel> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;

  PagedOrderResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
  });

  factory PagedOrderResponse.fromJson(Map<String, dynamic> json) {
    return PagedOrderResponse(
      items: (json['items'] as List? ?? [])
          .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      hasNextPage: json['hasNextPage'] ?? false,
    );
  }
}
