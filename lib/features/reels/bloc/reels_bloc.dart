import 'dart:async';
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

  // -------------------- CALL INTERRUPTION --------------------

  /// 🔴 VERY IMPORTANT
  /// Pause reels AND fully release audio session
  Future<void> _onPauseForCall(
    PauseForCall event,
    Emitter<ReelsState> emit,
  ) async {
    if (_latestState == null) return;

    _wasPlayingBeforeCall = _latestState!.isPlaying;

    if (_wasPlayingBeforeCall) {
      await audioService.pause();

      // 🔴 RELEASE AUDIO SESSION SO AGORA CAN USE MIC
      await audioService.release();

      _latestState = _latestState!.copyWith(
        isPlaying: false,
        showOverlayIcon: false,
      );
      emit(_latestState!);
    }
  }

  /// 🔴 Re-acquire audio session AFTER call ends
  Future<void> _onResumeAfterCall(
    ResumeAfterCall event,
    Emitter<ReelsState> emit,
  ) async {
    if (_latestState == null) return;

    if (_wasPlayingBeforeCall) {
      // 🔴 RE-INITIALIZE AUDIO SESSION
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
