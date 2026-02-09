import 'dart:async';
import 'package:audio_call_task/core/utils/logger.dart';
import 'package:audio_call_task/features/reels/data/reels_api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/audio_player_service.dart';
import 'reels_event.dart';
import 'reels_state.dart';

class ReelsBloc extends Bloc<ReelsEvent, ReelsState> {
  final AudioPlayerService audioService;
  final ReelsApiService reelsApiService;

  ReelsLoaded? _latestState;
  Timer? _overlayTimer;

  bool _wasPlayingBeforeCall = false;

  ReelsBloc(this.audioService, this.reelsApiService) : super(ReelsLoading()) {
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
    emit(ReelsLoading());

    try {
      final result = await reelsApiService.fetchReels(limit: 10);
      final reels = result.reels;

      if (reels.isEmpty) {
        throw Exception('No reels received from API');
      }

      // UI FIRST
      emit(
        ReelsLoaded(
          reels: reels,
          currentIndex: 0,
          isPlaying: true,
          showOverlayIcon: false,
        ),
      );

      _latestState = state as ReelsLoaded;

      // AUDIO AFTER UI
      await audioService.init();
      await audioService.play(reels.first.audioUrl);
    } catch (e, stack) {
      emit(ReelsError('Failed to load reels $e, $stack'));
      rethrow;
    }
  }

  Future<void> _onReelChanged(
    ReelChanged event,
    Emitter<ReelsState> emit,
  ) async {
    final current = state as ReelsLoaded;

    emit(
      current.copyWith(
        currentIndex: event.index,
        isPlaying: true,
        showOverlayIcon: false,
      ),
    );

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
