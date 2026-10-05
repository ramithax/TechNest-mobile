import 'package:dio/dio.dart';

import '../models/agent_workflow.dart';
import 'api_service.dart';

class AgentService {
  final ApiService _apiService = ApiService();

  Future<AgentWorkflow> startWorkflow({
    required String objective,
    required List<Map<String, String>> conversation,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/api/Agent/workflow',
        data: {'objective': objective, 'conversation': conversation},
        options: Options(
          sendTimeout: const Duration(minutes: 4),
          receiveTimeout: const Duration(minutes: 4),
        ),
      );

      print('[AGENT] Status: ${response.statusCode}');
      print('[AGENT] Response: ${response.data}');

      final workflow = AgentWorkflow.fromJson(
        Map<String, dynamic>.from(response.data),
      );

      print('[AGENT] Chat response: ${workflow.chatResponse}');
      print('[AGENT] Ready to build: ${workflow.readyToBuild}');

      return workflow;
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;

        if (data is Map<String, dynamic>) {
          throw Exception(data['message'] ?? 'Failed to start AI workflow.');
        }

        throw Exception(
          'AI workflow failed with status '
          '${e.response?.statusCode}.',
        );
      }

      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection to the server timed out.');
      }

      if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
          'The AI agent is taking too long to respond. Please try again.',
        );
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Could not connect to the server.');
      }

      throw Exception('Network error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      throw Exception('Failed to start AI workflow: $e');
    }
  }
}
