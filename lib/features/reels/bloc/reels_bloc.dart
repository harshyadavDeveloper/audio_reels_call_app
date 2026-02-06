import 'dart:async';
import 'package:audio_call_task/features/reels/data/reels_audio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/audio_player_service.dart';
import 'reels_event.dart';
import 'reels_state.dart';

class ReelsBloc extends Bloc<ReelsEvent, ReelsState> {
  final AudioPlayerService audioService;
  Timer? _overlayTimer;

  ReelsBloc(this.audioService) : super(ReelsLoading()) {
    on<LoadReels>(_onLoadReels);
    on<ReelChanged>(_onReelChanged);
    on<TogglePlayPause>(_onTogglePlayPause);
    on<HideOverlayIcon>(_onHideOverlayIcon);
  }

  Future<void> _onLoadReels(
    LoadReels event,
    Emitter<ReelsState> emit,
  ) async {
    final reels = [
      ReelAudio(
        id: '1',
        title: 'Sample 1',
        audioUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      ),
      ReelAudio(
        id: '2',
        title: 'Sample 2',
        audioUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      ),
    ];

    // ✅ Emit UI state immediately
    emit(ReelsLoaded(
      reels: reels,
      currentIndex: 0,
      isPlaying: true,
      showOverlayIcon: false,
    ));

    // ✅ Audio work happens AFTER UI is ready
    await audioService.init();
    await audioService.play(reels.first.audioUrl);
  }

  Future<void> _onReelChanged(
    ReelChanged event,
    Emitter<ReelsState> emit,
  ) async {
    final currentState = state as ReelsLoaded;

    emit(currentState.copyWith(
      currentIndex: event.index,
      isPlaying: true,
      showOverlayIcon: false,
    ));

    await audioService.stop();
    await audioService.play(event.reel.audioUrl);
  }

  Future<void> _onTogglePlayPause(
    TogglePlayPause event,
    Emitter<ReelsState> emit,
  ) async {
    final currentState = state as ReelsLoaded;

    // Cancel any previous timer immediately
    _overlayTimer?.cancel();

    if (audioService.isPlaying) {
      // 🔹 PAUSE
      emit(currentState.copyWith(
        isPlaying: false,
        showOverlayIcon: true,
      ));

      await audioService.pause();
    } else {
      // 🔹 RESUME
      emit(currentState.copyWith(
        isPlaying: true,
        showOverlayIcon: true,
      ));

      await audioService.resume();
    }

    // 🔹 Start fresh timer AFTER emit
    _overlayTimer = Timer(
      const Duration(milliseconds: 1500),
      () => add(HideOverlayIcon()),
    );
  }

  void _onHideOverlayIcon(
    HideOverlayIcon event,
    Emitter<ReelsState> emit,
  ) {
    emit((state as ReelsLoaded).copyWith(showOverlayIcon: false));
  }

  @override
  Future<void> close() {
    _overlayTimer?.cancel();
    audioService.dispose();
    return super.close();
  }
}
