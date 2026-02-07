import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audio_call_task/core/utils/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  late final RtcEngine _engine;
  bool _initialized = false;

  Future<void> init(String appId) async {
    if (_initialized) return;

    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      throw Exception('Microphone permission not granted');
    }

    _engine = createAgoraRtcEngine();

    await _engine.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
        audioScenario: AudioScenarioType.audioScenarioDefault,
      ),
    );

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          Logger.success('✅ Agora joined channel: ${connection.channelId}');
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          Logger.info('👤 Remote user joined: $remoteUid');
        },
        onUserOffline: (connection, remoteUid, reason) {
          Logger.info('👋 Remote user left: $remoteUid');
        },
        onError: (err, msg) {
          Logger.error('❌ Agora error: $err, $msg');
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableAudio();
    await _engine.enableLocalAudio(true);

    _initialized = true;
  }

  Future<void> joinChannel({
  required String channelId,
  required String token,
}) async {
  await _engine.joinChannel(
    token: token,
    channelId: channelId,
    uid: 0,
    options: const ChannelMediaOptions(
      publishMicrophoneTrack: true,
      autoSubscribeAudio: true,
    ),
  );
}

  Future<void> leaveChannel() async {
    if (!_initialized) return;
    await _engine.leaveChannel();
  }

  Future<void> dispose() async {
    if (!_initialized) return;
    await _engine.release();
    _initialized = false;
  }
}
