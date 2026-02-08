import 'dart:async';
import 'package:audio_call_task/core/utils/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/audio_player_service.dart';
import '../data/reels_audio.dart';
import 'reels_event.dart';
import 'reels_state.dart';

class ReelsBloc extends Bloc<ReelsEvent, ReelsState> {
  final AudioPlayerService audioService;

  ReelsLoaded? _latestState;
  Timer? _overlayTimer;

  bool _wasPlayingBeforeCall = false;

  ReelsBloc(this.audioService) : super(ReelsLoading()) {
    on<LoadReels>(_onLoadReels);
    on<ReelChanged>(_onReelChanged);
    on<TogglePlayPause>(_onTogglePlayPause);
    on<HideOverlayIcon>(_onHideOverlayIcon);
    on<PauseForCall>(_onPauseForCall);
    on<ResumeAfterCall>(_onResumeAfterCall);
  }

  // -------------------- LOAD REELS --------------------
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

    emit(ReelsLoaded(
      reels: reels,
      currentIndex: 0,
      isPlaying: true,
      showOverlayIcon: false,
    ));

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
    final current = state as ReelsLoaded;
    final bool nextIsPlaying = !current.isPlaying;

    Logger.info('🟡 TAP → nextIsPlaying=$nextIsPlaying');

    _overlayTimer?.cancel();

    emit(current.copyWith(
      isPlaying: nextIsPlaying,
      showOverlayIcon: true,
    ));

    _overlayTimer = Timer(
      const Duration(milliseconds: 1200),
      () {
        Logger.success('🔴 OVERLAY HIDDEN');
        add(HideOverlayIcon());
      },
    );

    if (nextIsPlaying) {
      Logger.info('🎵 AUDIO → resume() called');
      await audioService.resume();
    } else {
      Logger.info('🎵 AUDIO → pause() called');
      await audioService.pause();
    }
  }

  void _onHideOverlayIcon(
    HideOverlayIcon event,
    Emitter<ReelsState> emit,
  ) {
    final current = state;
    if (current is ReelsLoaded && current.showOverlayIcon) {
      Logger.info('🔴 OVERLAY HIDDEN');
      emit(current.copyWith(showOverlayIcon: false));
    }
  }

  // -------------------- CALL INTERRUPTION --------------------

  Future<void> _onPauseForCall(
    PauseForCall event,
    Emitter<ReelsState> emit,
  ) async {
    if (_latestState == null) return;

    _wasPlayingBeforeCall = _latestState!.isPlaying;

    if (_wasPlayingBeforeCall) {
      await audioService.pause();

      await audioService.release();

      _latestState = _latestState!.copyWith(
        isPlaying: false,
        showOverlayIcon: false,
      );
      emit(_latestState!);
    }
  }

  Future<void> _onResumeAfterCall(
    ResumeAfterCall event,
    Emitter<ReelsState> emit,
  ) async {
    if (_latestState == null) return;

    if (_wasPlayingBeforeCall) {
      await audioService.init();
      await audioService.resume();

      _latestState = _latestState!.copyWith(
        isPlaying: true,
        showOverlayIcon: false,
      );
      emit(_latestState!);
    }

    _wasPlayingBeforeCall = false;
  }

  // -------------------- CLEANUP --------------------

  @override
  Future<void> close() {
    _overlayTimer?.cancel();
    audioService.dispose();
    return super.close();
  }
}
