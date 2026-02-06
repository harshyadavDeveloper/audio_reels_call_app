import 'package:audio_call_task/features/reels/data/reels_audio.dart';

abstract class ReelsEvent {}

class LoadReels extends ReelsEvent {}

class ReelChanged extends ReelsEvent {
  final int index;
  final ReelAudio reel;

  ReelChanged(this.index, this.reel);
}

class TogglePlayPause extends ReelsEvent {}

class HideOverlayIcon extends ReelsEvent {}

