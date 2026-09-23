import '../models/product_model.dart';
import 'api_service.dart';

class ProductService {
  final ApiService _apiService = ApiService();

  Future<List<ProductModel>> getProducts() async {
    final response = await _apiService.dio.get('/api/Product');

    final List<dynamic> data = response.data;

    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<ProductModel> getProductById(int id) async {
    final response = await _apiService.dio.get('/api/Product/$id');

    return ProductModel.fromJson(Map<String, dynamic>.from(response.data));
  }
}
