import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/storage/token_storage.dart';
import '../models/repair_model.dart';
import 'api_service.dart';
import 'supabase_storage_service.dart';

class RepairService {
  final ApiService _apiService = ApiService();
  final TokenStorage _tokenStorage = TokenStorage();
  final SupabaseStorageService _storageService = SupabaseStorageService();

  Future<Map<String, dynamic>> createRepair({
    required String deviceModel,
    required String issueDescription,
    required DateTime appointmentDate,
    List<int>? imageBytes,
    String? fileName,
    String? contentType,
  }) async {
    final userId = await _tokenStorage.getUserId();

    if (userId == null) {
      throw Exception('User is not logged in');
    }

    String? imageUrl;

    if (imageBytes != null && fileName != null && contentType != null) {
      imageUrl = await _storageService.uploadRepairImage(
        imageBytes: imageBytes,
        fileName: fileName,
        contentType: contentType,
      );
    }

    try {
      final response = await _apiService.dio.post(
        ApiConstants.repairs,
        data: {
          'customerId': userId.toString(),
          'deviceModel': deviceModel,
          'issueDescription': issueDescription,
          'imageUrl': imageUrl,
          'appointmentDate': appointmentDate.toIso8601String(),
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to submit repair request');
      }

      if (response.data is! Map) {
        throw Exception('Invalid response from server');
      }

      return Map<String, dynamic>.from(response.data);
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

      if (e.response?.statusCode == 400) {
        throw Exception('Invalid repair request.');
      }

      if (e.response?.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      }

      throw Exception(
        'Failed to submit repair request. '
        'Please check your connection.',
      );
    }
  }

  Future<List<RepairModel>> getMyRepairs() async {
    try {
      final response = await _apiService.dio.get(
        '${ApiConstants.repairs}/my-repairs',
      );

      print('MY REPAIRS STATUS: ${response.statusCode}');
      print('MY REPAIRS DATA: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load repair history. Status: ${response.statusCode}',
        );
      }

      if (response.data is! List) {
        throw Exception('Invalid response format: ${response.data}');
      }

      return (response.data as List)
          .map((item) => RepairModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (e) {
      print('MY REPAIRS ERROR: ${e.message}');
      print('MY REPAIRS STATUS: ${e.response?.statusCode}');
      print('MY REPAIRS RESPONSE: ${e.response?.data}');
      print('MY REPAIRS URL: ${e.requestOptions.uri}');

      throw Exception(
        e.response?.data?.toString() ??
            e.message ??
            'Failed to load repair history',
      );
    } catch (e) {
      print('MY REPAIRS GENERAL ERROR: $e');
      rethrow;
    }
  }
}
