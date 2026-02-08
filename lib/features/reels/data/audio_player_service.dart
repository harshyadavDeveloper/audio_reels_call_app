import 'package:audio_call_task/core/utils/logger.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  AudioSession? _session;

  bool get isPlaying => _player.playing;

  /// Initialize audio session for reels playback
  Future<void> init() async {
    _session = await AudioSession.instance;
    await _session!.configure(
      const AudioSessionConfiguration.music(),
    );
  }

  Future<void> play(String url) async {
    await _player.setUrl(url);
    await _player.play();
  }

  Future<void> pause() async {
    Logger.info('🎵 AUDIO → pause() called');
    await _player.pause();
    Logger.info('🎵 AUDIO → paused, playing=${_player.playing}');
  }

  Future<void> resume() async {
    Logger.info('🎵 AUDIO → resume() called');
    await _player.play();
    Logger.info('🎵 AUDIO → playing=${_player.playing}');
  }

  Future<void> stop() async {
    await _player.stop();
  }

  /// 🔴 VERY IMPORTANT
  /// Fully release audio focus so Agora can capture microphone
  Future<void> release() async {
    await _player.stop();
    await _session?.setActive(false);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
