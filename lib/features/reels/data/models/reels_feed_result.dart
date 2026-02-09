import 'reel_audio_model.dart';

class ReelsFeedResult {
  final List<ReelAudio> reels;
  final String? nextCursor;

  ReelsFeedResult({
    required this.reels,
    required this.nextCursor,
  });
}
