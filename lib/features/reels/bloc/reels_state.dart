import 'package:audio_call_task/features/reels/data/reels_audio.dart';

abstract class ReelsState {}

class ReelsLoading extends ReelsState {}

class ReelsLoaded extends ReelsState {
  final List<ReelAudio> reels;
  final int currentIndex;
  final bool isPlaying;
  final bool showOverlayIcon;

  ReelsLoaded({
    required this.reels,
    required this.currentIndex,
    required this.isPlaying,
    required this.showOverlayIcon,
  });

  ReelsLoaded copyWith({
    int? currentIndex,
    bool? isPlaying,
    bool? showOverlayIcon,
  }) {
    return ReelsLoaded(
      reels: reels,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      showOverlayIcon: showOverlayIcon ?? this.showOverlayIcon,
    );
  }
}
