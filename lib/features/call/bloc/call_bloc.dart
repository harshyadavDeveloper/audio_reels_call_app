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
    print('📞 CallBloc: IncomingCall event received');
    final call = CallModel(
      callId: const Uuid().v4(),
      callerName: event.callerName,
      status: CallStatus.incoming,
    );
    print('📞 CallBloc: Emitting CallInProgress state');

    emit(CallInProgress(call));
  }

  void _onAcceptCall(
    AcceptCall event,
    Emitter<CallState> emit,
  ) {
    print('📞 CallBloc: AcceptCall event received');
    final current = state as CallInProgress;

    emit(CallInProgress(
      current.call.copyWith(status: CallStatus.accepted),
    ));
  }

  void _onDeclineCall(
    DeclineCall event,
    Emitter<CallState> emit,
  ) {
    print('📞 CallBloc: DeclineCall event received');
    emit(CallIdle());
  }

  void _onEndCall(
    EndCall event,
    Emitter<CallState> emit,
  ) {
    print('📞 CallBloc: EndCall event received');
    emit(CallIdle());
  }
}
