import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/storage/token_storage.dart';
import '../models/order_model.dart';
import '../models/paged_order_response.dart';

class OrderService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  final TokenStorage _tokenStorage = TokenStorage();

  Future<OrderModel> createOrder({
    required int userId,
    required String customerName,
    required String customerEmail,
    required String shippingAddress,
    required String contactNumber,
    String orderType = 'Product',
    required List<Map<String, dynamic>> items,
  }) async {
    final accessToken = await _tokenStorage.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Authentication required.');
    }

    final response = await _dio.post(
      '/api/Order',
      data: {
        'userId': userId,
        'customerName': customerName,
        'customerEmail': customerEmail,
        'shippingAddress': shippingAddress,
        'contactNumber': contactNumber,
        'orderType': orderType,
        'items': items,
      },
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return OrderModel.fromJson(Map<String, dynamic>.from(response.data));
    }

    throw Exception('Failed to create order.');
  }

  Future<OrderModel> createPcBuildOrder({
    required int pcBuildId,
    required String customerName,
    required String customerEmail,
    required String shippingAddress,
    required String contactNumber,
  }) async {
    final accessToken = await _tokenStorage.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Authentication required.');
    }

    final response = await _dio.post(
      '/api/Order/pc-build',
      data: {
        'pcBuildId': pcBuildId,
        'customerName': customerName,
        'customerEmail': customerEmail,
        'shippingAddress': shippingAddress,
        'contactNumber': contactNumber,
      },
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return OrderModel.fromJson(Map<String, dynamic>.from(response.data));
    }

    throw Exception('Failed to create PC build order.');
  }

  Future<PagedOrderResponse> getOrders({
    int page = 1,
    int pageSize = 10,
  }) async {
    final accessToken = await _tokenStorage.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Authentication required.');
    }

    final response = await _dio.get(
      '/api/Order/my-orders',
      queryParameters: {'page': page, 'pageSize': pageSize},
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load orders.');
    }

    if (response.data is! Map) {
      throw Exception('Invalid order response from server.');
    }

    return PagedOrderResponse.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<OrderModel> getOrderById(int orderId) async {
    final accessToken = await _tokenStorage.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Authentication required.');
    }

    final response = await _dio.get(
      '/api/Order/$orderId',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    return OrderModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<void> cancelOrder(int orderId) async {
    final accessToken = await _tokenStorage.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Authentication required.');
    }

    await _dio.delete(
      '/api/Order/$orderId',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }
}
