import 'package:audio_call_task/core/notifications/call_notification_service.dart';
import 'package:audio_call_task/core/utils/logger.dart';
import 'package:audio_call_task/features/call/data/agora_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/call_model.dart';
import 'call_event.dart';
import 'call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  final AgoraService _agoraService;

  static const String _agoraAppId = '64f337370e9447f1ac5f73aecd774e87';
  static const String _tempToken =
      '007eJxTYNj0RtH8YUTstUXBjnf2SBtfurzr62NZ/fTXV615jjDeu7lHgcHMJM3Y2NzY3CDV0sTEPM0wMdk0zdw4MTU5xdzcJNXCPFqoPbMhkJFBdXcTAyMUgvhCDCWpxSXxien5RYnxyRmJeXmpOQwMANHSJmk=';

  CallBloc(this._agoraService) : super(CallIdle()) {
    on<IncomingCall>(_onIncomingCall);
    on<AcceptCall>(_onAcceptCall);
    on<DeclineCall>(_onDeclineCall);
    on<EndCall>(_onEndCall);
  }

  // call_bloc.dart
  void _onIncomingCall(
    IncomingCall event,
    Emitter<CallState> emit,
  ) {
    final call = CallModel(
      callId: event.channelId, // ✅ Use provided channel ID
      callerName: event.callerName,
      status: CallStatus.incoming,
    );
    Logger.info('📡 Agora channelId: ${call.callId}');

    CallNotificationService.showIncomingCall(
      callerName: event.callerName,
    );

    emit(CallInProgress(call));
  }

  Future<void> _onAcceptCall(
    AcceptCall event,
    Emitter<CallState> emit,
  ) async {
    Logger.info('📞 CallBloc: AcceptCall event received');
    final current = state as CallInProgress;

    await _agoraService.init(_agoraAppId);
    await _agoraService.joinChannel(
        channelId: current.call.callId, token: _tempToken);

    emit(CallInProgress(
      current.call.copyWith(status: CallStatus.accepted),
    ));
  }

  Future<void> _onDeclineCall(
    DeclineCall event,
    Emitter<CallState> emit,
  ) async {
    Logger.info('📞 CallBloc: DeclineCall event received');
    await _agoraService.leaveChannel();
    emit(CallIdle());
  }

  Future<void> _onEndCall(
    EndCall event,
    Emitter<CallState> emit,
  ) async {
    Logger.info('📞 CallBloc: EndCall event received');
    await _agoraService.leaveChannel();
    emit(CallIdle());
  }

  @override
  Future<void> close() async {
    await _agoraService.dispose();
    return super.close();
  }
}
