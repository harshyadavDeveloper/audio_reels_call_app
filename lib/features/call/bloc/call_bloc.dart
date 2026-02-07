import 'package:audio_call_task/core/notifications/call_notification_service.dart';
import 'package:audio_call_task/core/utils/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../data/call_model.dart';
import 'call_event.dart';
import 'call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  CallBloc() : super(CallIdle()) {
    on<IncomingCall>(_onIncomingCall);
    on<AcceptCall>(_onAcceptCall);
    on<DeclineCall>(_onDeclineCall);
    on<EndCall>(_onEndCall);
  }

  void _onIncomingCall(
    IncomingCall event,
    Emitter<CallState> emit,
  ) {
    final call = CallModel(
      callId: const Uuid().v4(),
      callerName: event.callerName,
      status: CallStatus.incoming,
    );

    CallNotificationService.showIncomingCall(
      callerName: event.callerName,
    );

    emit(CallInProgress(call));
  }

  void _onAcceptCall(
    AcceptCall event,
    Emitter<CallState> emit,
  ) {
    Logger.info('📞 CallBloc: AcceptCall event received');
    final current = state as CallInProgress;

    emit(CallInProgress(
      current.call.copyWith(status: CallStatus.accepted),
    ));
  }

  void _onDeclineCall(
    DeclineCall event,
    Emitter<CallState> emit,
  ) {
    Logger.info('📞 CallBloc: DeclineCall event received');
    emit(CallIdle());
  }

  void _onEndCall(
    EndCall event,
    Emitter<CallState> emit,
  ) {
    Logger.info('📞 CallBloc: EndCall event received');
    emit(CallIdle());
  }
}
