import 'product_model.dart';

class PagedProductResponse {
  final List<ProductModel> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;

  PagedProductResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
  });

  factory PagedProductResponse.fromJson(Map<String, dynamic> json) {
    return PagedProductResponse(
      items: (json['items'] as List)
          .map(
            (item) => ProductModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      page: json['page'],
      pageSize: json['pageSize'],
      totalCount: json['totalCount'],
      totalPages: json['totalPages'],
      hasNextPage: json['hasNextPage'],
    );
  }
}