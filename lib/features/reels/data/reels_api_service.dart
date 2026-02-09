// call the api/ print required details

import 'package:audio_call_task/core/utils/logger.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class ReelsApiService {
  final ApiClient _apiClient;

  ReelsApiService(this._apiClient);

  Future<Map<String, dynamic>> fetchReels({
    String? cursor,
    int limit = 10,
  }) async {
    try {
      final Response response = await _apiClient.dio.get(
        '/api/v1/user/user-feed',
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
        },
      );

      final data = response.data as Map<String, dynamic>;

      final randomJamme = data['randomJamme'] as List<dynamic>? ?? [];
      final nextCursor = data['nextCursor'];

      Logger.success('✅ API SUCCESS');
      Logger.info('🎧 Reels fetched: ${randomJamme.length}');
      Logger.info('➡️ Next cursor: $nextCursor');

      return data;
    } catch (e, stack) {
      Logger.error('❌ API ERROR: $e');
      Logger.error(stack.toString());
      rethrow;
    }
  }
}
