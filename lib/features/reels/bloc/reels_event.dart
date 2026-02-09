import '../data/models/reel_audio_model.dart';
abstract class ReelsEvent {}

class LoadReels extends ReelsEvent {}

class ReelChanged extends ReelsEvent {
  final int index;
  final ReelAudio reel;

  ReelChanged(this.index, this.reel);
}

class TogglePlayPause extends ReelsEvent {}

class HideOverlayIcon extends ReelsEvent {}

class PauseForCall extends ReelsEvent {}

class ResumeAfterCall extends ReelsEvent {}
