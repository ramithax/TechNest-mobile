import 'package:dio/dio.dart';

import '../core/constants/supabase_constants.dart';

class SupabaseStorageService {
  final Dio _dio = Dio();

  Future<String> uploadRepairImage({
    required List<int> imageBytes,
    required String fileName,
    required String contentType,
  }) async {
    final path = 'repairs/$fileName';

    final url =
        '${SupabaseConstants.projectUrl}/storage/v1/object/${SupabaseConstants.storageBucket}/$path';

    try {
      final response = await _dio.post(
        url,
        data: imageBytes,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${SupabaseConstants.publishableKey}',
            'apikey': SupabaseConstants.publishableKey,
            'Content-Type': contentType,
            'x-upsert': 'true',
          },
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Image upload failed: ${response.statusCode}');
      }

      return '${SupabaseConstants.projectUrl}/storage/v1/object/public/'
          '${SupabaseConstants.storageBucket}/$path';
    } on DioException catch (e) {
      final message = e.response?.data ?? e.message;
      throw Exception('Image upload failed: $message');
    }
  }
}
