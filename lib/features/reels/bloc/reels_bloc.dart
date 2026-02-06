import 'package:audio_call_task/features/reels/data/reels_audio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/audio_player_service.dart';
import 'reels_event.dart';
import 'reels_state.dart';

class ReelsBloc extends Bloc<ReelsEvent, ReelsState> {
  final AudioPlayerService audioService;

  ReelsBloc(this.audioService) : super(ReelsLoading()) {
    on<LoadReels>(_onLoadReels);
    on<ReelChanged>(_onReelChanged);
  }

  Future<void> _onLoadReels(
    LoadReels event,
    Emitter<ReelsState> emit,
  ) async {
    final reels = [
      ReelAudio(
        id: '1',
        title: 'Sample 1',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      ),
      ReelAudio(
        id: '2',
        title: 'Sample 2',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      ),
    ];

    emit(ReelsLoaded(reels: reels, currentIndex: 0));
    await audioService.play(reels.first.audioUrl);
  }

  Future<void> _onReelChanged(
    ReelChanged event,
    Emitter<ReelsState> emit,
  ) async {
    await audioService.stop();
    await audioService.play(event.reel.audioUrl);

    emit(ReelsLoaded(
      reels: (state as ReelsLoaded).reels,
      currentIndex: event.index,
    ));
  }

  @override
  Future<void> close() {
    audioService.dispose();
    return super.close();
  }
}
