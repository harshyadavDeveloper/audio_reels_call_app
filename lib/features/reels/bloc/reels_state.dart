import 'package:audio_call_task/features/reels/data/reels_audio.dart';

abstract class ReelsState {}

class ReelsLoading extends ReelsState {}

class ReelsLoaded extends ReelsState {
  final List<ReelAudio> reels;
  final int currentIndex;

  ReelsLoaded({
    required this.reels,
    required this.currentIndex,
  });
}
