// call the api/ print required details

import 'package:audio_call_task/features/reels/data/models/reels_feed_result.dart';
import 'package:dio/dio.dart';
import 'package:audio_call_task/core/utils/logger.dart';
import '../../../core/network/api_client.dart';
import '../../reels/data/reel_audio_model.dart';

class ReelsApiService {
  final ApiClient _apiClient;

  ReelsApiService(this._apiClient);

  /// Fetch reels feed and convert to ReelAudio list
  Future<ReelsFeedResult> fetchReels({
    String? cursor,
    int limit = 10,
  }) async {
    try {
      Logger.info('📡 Fetching reels feed...');

      final Response response = await _apiClient.dio.get(
        '/api/v1/user/user-feed',
        queryParameters: {
          'limit': limit,
          if (cursor != null) 'cursor': cursor,
        },
      );

      final Map<String, dynamic> data =
          response.data as Map<String, dynamic>;

      final List<dynamic> randomJamme =
          data['randomJamme'] as List<dynamic>? ?? [];

      final String? nextCursor = data['nextCursor']?.toString();

      final reels = randomJamme
          .map((e) => ReelAudio.fromJson(e as Map<String, dynamic>))
          .where((reel) => reel.audioUrl.isNotEmpty) // 🔒 safety
          .toList();

      Logger.success('✅ API SUCCESS');
      Logger.info('🎧 Reels parsed: ${reels.length}');
      Logger.info('➡️ Next cursor: $nextCursor');

      return ReelsFeedResult(
        reels: reels,
        nextCursor: nextCursor,
      );
    } catch (e, stack) {
      Logger.error('❌ API ERROR: $e');
      Logger.error(stack.toString());
      rethrow;
    }
  }
}
