import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../models/paged_product_response.dart';
import '../models/product_model.dart';
import 'api_service.dart';

class ProductService {
  final ApiService _apiService = ApiService();

  // ============================================================
  // GET PRODUCTS
  // ============================================================

  Future<PagedProductResponse> getProducts({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? category,
  }) async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.products,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
          if (category != null && category.trim().isNotEmpty)
            'category': category.trim(),
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load products.');
      }

      if (response.data is! Map) {
        throw Exception('Invalid product response from server.');
      }

      return PagedProductResponse.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;

      if (responseData is String && responseData.isNotEmpty) {
        throw Exception(responseData);
      }

      if (responseData is Map) {
        final message =
            responseData['message'] ??
            responseData['title'] ??
            responseData['error'];

        if (message != null) {
          throw Exception(message.toString());
        }
      }

      if (e.response?.statusCode == 401) {
        throw Exception('Your session has expired. Please log in again.');
      }

      if (e.response?.statusCode == 404) {
        throw Exception('Product endpoint was not found.');
      }

      if (e.response?.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      }

      throw Exception(
        'Failed to load products. '
        'Please check your connection.',
      );
    }
  }

  // ============================================================
  // GET PRODUCT BY ID
  // ============================================================

  Future<ProductModel> getProductById(int id) async {
    try {
      final response = await _apiService.dio.get(
        '${ApiConstants.products}/$id',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load product.');
      }

      if (response.data is! Map) {
        throw Exception('Invalid product response from server.');
      }

      return ProductModel.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      final responseData = e.response?.data;

      if (responseData is String && responseData.isNotEmpty) {
        throw Exception(responseData);
      }

      if (responseData is Map) {
        final message =
            responseData['message'] ??
            responseData['title'] ??
            responseData['error'];

        if (message != null) {
          throw Exception(message.toString());
        }
      }

      if (e.response?.statusCode == 401) {
        throw Exception('Your session has expired. Please log in again.');
      }

      if (e.response?.statusCode == 404) {
        throw Exception('Product not found.');
      }

      if (e.response?.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      }

      throw Exception(
        'Failed to load product. '
        'Please check your connection.',
      );
    }
  }
}
