import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../models/build_summary_model.dart';
import '../models/pc_build_history_model.dart';
import '../models/build_item_model.dart';
import '../models/pc_build_model.dart';
import 'api_service.dart';

class PcBuildService {
  final ApiService _apiService = ApiService();

  Future<PcBuildModel> createBuild() async {
    try {
      final response = await _apiService.dio.post(ApiConstants.pcBuild);

      if (response.statusCode != 200) {
        throw Exception('Failed to create PC build.');
      }

      return PcBuildModel.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to create PC build.');
    }
  }

  Future<PcBuildModel> getBuild(int buildId) async {
    try {
      final response = await _apiService.dio.get(
        '${ApiConstants.pcBuild}/$buildId',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load PC build.');
      }

      return PcBuildModel.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to load PC build.');
    }
  }

  Future<BuildItemModel> addBuildItem({
    required int buildId,
    required int productId,
    int quantity = 1,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '${ApiConstants.pcBuild}/$buildId/items',
        data: {'productId': productId, 'quantity': quantity},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add product to build.');
      }

      return BuildItemModel.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to add product to build.');
    }
  }

  Future<BuildItemModel> updateBuildItem({
    required int buildId,
    required int itemId,
    required int productId,
    int quantity = 1,
  }) async {
    try {
      final response = await _apiService.dio.put(
        '${ApiConstants.pcBuild}/$buildId/items/$itemId',
        data: {'productId': productId, 'quantity': quantity},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update build item.');
      }

      return BuildItemModel.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to update build item.');
    }
  }

  Future<void> deleteBuildItem({
    required int buildId,
    required int itemId,
  }) async {
    try {
      final response = await _apiService.dio.delete(
        '${ApiConstants.pcBuild}/$buildId/items/$itemId',
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to remove product from build.');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to remove product from build.');
    }
  }

  Future<BuildSummaryModel> getBuildSummary(int buildId) async {
    try {
      final response = await _apiService.dio.get(
        '${ApiConstants.pcBuild}/$buildId/summary',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load build summary.');
      }

      return BuildSummaryModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to load build summary.');
    }
  }

  Future<List<PcBuildHistoryModel>> getBuildHistory() async {
    try {
      final response = await _apiService.dio.get(
        '${ApiConstants.pcBuild}/history',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load PC build history.');
      }

      if (response.data is! List) {
        throw Exception('Invalid response from server.');
      }

      return (response.data as List)
          .map(
            (item) =>
                PcBuildHistoryModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to load PC build history.');
    }
  }

  Exception _handleError(DioException e, String defaultMessage) {
    final responseData = e.response?.data;

    if (responseData is String && responseData.isNotEmpty) {
      return Exception(responseData);
    }

    if (responseData is Map) {
      final message =
          responseData['message'] ??
          responseData['title'] ??
          responseData['error'];

      if (message != null) {
        return Exception(message.toString());
      }
    }

    if (e.response?.statusCode == 401) {
      return Exception('Your session has expired. Please log in again.');
    }

    if (e.response?.statusCode == 404) {
      return Exception('PC build was not found.');
    }

    if (e.response?.statusCode == 400) {
      return Exception('Invalid PC build request.');
    }

    if (e.response?.statusCode == 500) {
      return Exception('Server error. Please try again later.');
    }

    return Exception('$defaultMessage Please check your connection.');
  }
}
